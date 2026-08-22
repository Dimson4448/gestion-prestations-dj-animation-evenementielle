from datetime import datetime, timedelta

from django.db import models, transaction
from django.utils import timezone

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.payments.models import Invoice, Payment

from .models import Booking, CancellationRequest, Contract, PreparatoryAppointment, Quote
from .notifications import notify_balance_invoice_created, notify_booking_cancelled, notify_cancellation_requested, notify_cancellation_reviewed, notify_quote_accepted, notify_contract_signed


class QuoteAcceptanceError(Exception):
    """Erreur fonctionnelle empêchant la conversion complète d'un devis."""


class ContractSigningError(Exception):
    """Erreur fonctionnelle empêchant la signature d'un contrat."""


class BookingCompletionError(Exception):
    """Erreur fonctionnelle empêchant la clôture d'une prestation."""


class BookingCancellationError(Exception):
    """Erreur fonctionnelle empêchant l'annulation d'une réservation."""


class CancellationRequestError(Exception):
    """Erreur fonctionnelle empêchant une demande d'annulation client."""


def _event_end(quote):
    start = datetime.combine(quote.event_date, quote.start_time)
    return start + timedelta(seconds=int(quote.duration_hours * 3600))


@transaction.atomic
def accept_quote(quote_id, dj_id):
    """Convertit atomiquement un devis envoyé en réservation exploitable."""
    quote = (
        Quote.objects.select_for_update()
        .select_related("client", "event_type", "package", "venue")
        .get(pk=quote_id)
    )

    if quote.status != Quote.SENT:
        raise QuoteAcceptanceError("Seul un devis envoyé peut être accepté.")
    if Booking.objects.filter(quote=quote).exists():
        raise QuoteAcceptanceError("Ce devis possède déjà une réservation.")

    try:
        dj = DJProfile.objects.select_for_update().get(pk=dj_id, is_available=True)
    except DJProfile.DoesNotExist as exc:
        raise QuoteAcceptanceError("Le DJ sélectionné est introuvable ou indisponible.") from exc

    event_start = datetime.combine(quote.event_date, quote.start_time)
    event_end = _event_end(quote)
    availability_candidates = (
        DJAvailability.objects.select_for_update()
        .filter(
            dj=dj,
            available_date__lte=quote.event_date,
            status=DJAvailability.AVAILABLE,
        )
        .filter(models.Q(end_date__gte=event_end.date()) | models.Q(end_date__isnull=True))
        .order_by("available_date", "start_time")
    )
    availability = next((slot for slot in availability_candidates if datetime.combine(slot.available_date, slot.start_time) <= event_start and datetime.combine(slot.end_date or slot.available_date, slot.end_time) >= event_end), None)
    if availability is None:
        raise QuoteAcceptanceError("Le DJ ne possède pas de créneau disponible couvrant toute la prestation.")

    possible_conflicts = Booking.objects.select_for_update().filter(dj=dj, event_date__lte=event_end.date()).exclude(status=Booking.CANCELLED)
    has_conflict = any(
        datetime.combine(item.event_date, item.start_time) < event_end
        and datetime.combine(item.end_date or item.event_date, item.end_time) > event_start
        for item in possible_conflicts
    )
    if has_conflict:
        raise QuoteAcceptanceError("Le DJ possède déjà une réservation sur ce créneau.")

    booking = Booking.objects.create(
        quote=quote,
        client=quote.client,
        dj=dj,
        event_type=quote.event_type,
        package=quote.package,
        venue=quote.venue,
        event_date=quote.event_date,
        end_date=event_end.date(),
        start_time=quote.start_time,
        end_time=event_end.time(),
        status=Booking.PREPARATORY_MEETING,
        total_amount=quote.total_amount,
        deposit_required=quote.deposit_amount,
    )
    contract = Contract.objects.create(
        booking=booking,
        contract_number=f"UDJ-CON-{quote.event_date:%Y}-{booking.pk:06d}",
        status=Contract.SENT,
        refund_policy="Annulation et remboursement selon les conditions générales Ultimate DJ.",
    )
    invoice = Invoice.objects.create(
        booking=booking,
        invoice_number=f"UDJ-ACP-{quote.event_date:%Y}-{booking.pk:06d}",
        invoice_type=Invoice.DEPOSIT,
        amount=quote.deposit_amount,
        status=Invoice.SENT,
        due_at=timezone.now() + timedelta(days=7),
    )

    availability.status = DJAvailability.RESERVED
    availability.reason = f"Réservation #{booking.pk}"
    availability.save(update_fields=["status", "reason"])
    quote.requested_dj = dj
    quote.dj_decision = Quote.DJ_ACCEPTED
    quote.dj_decided_at = timezone.now()
    quote.status = Quote.ACCEPTED
    quote.save(update_fields=["requested_dj", "dj_decision", "dj_decided_at", "status"])

    notify_quote_accepted(booking, contract, invoice)

    return booking, contract, invoice


@transaction.atomic
def sign_contract(contract_id, client):
    """Signe un contrat envoyé au nom de son unique client propriétaire."""
    contract = Contract.objects.select_for_update().select_related("booking__client").get(pk=contract_id)
    if client is None or contract.booking.client_id != client.pk:
        raise ContractSigningError("Seul le client de la réservation peut signer ce contrat.")
    if contract.status != Contract.SENT:
        raise ContractSigningError("Seul un contrat envoyé et non encore signé peut être signé.")

    contract.status = Contract.SIGNED
    contract.signed_by_client_at = timezone.now()
    contract.save(update_fields=["status", "signed_by_client_at"])
    notify_contract_signed(contract)
    return contract


@transaction.atomic
def complete_booking(booking_id, actor):
    """Marque une prestation réalisée et émet une unique facture de solde."""
    booking = (
        Booking.objects.select_for_update()
        .select_related("dj", "client", "event_type", "package")
        .get(pk=booking_id)
    )
    actor_dj = getattr(actor, "dj_profile", None)
    if not actor.is_staff and (actor_dj is None or actor_dj.pk != booking.dj_id):
        raise BookingCompletionError("Seul le DJ affecté ou l'administration peut clôturer cette prestation.")
    if booking.status != Booking.CONFIRMED or not booking.deposit_paid:
        raise BookingCompletionError("La réservation doit être confirmée et son acompte payé.")

    event_end = timezone.make_aware(datetime.combine(booking.end_date or booking.event_date, booking.end_time))
    if event_end > timezone.now():
        raise BookingCompletionError("La prestation ne peut pas être clôturée avant sa date de fin.")
    if Invoice.objects.select_for_update().filter(booking=booking, invoice_type=Invoice.BALANCE).exists():
        raise BookingCompletionError("Une facture de solde existe déjà pour cette réservation.")

    paid_amount = sum(
        (invoice.amount for invoice in Invoice.objects.select_for_update().filter(booking=booking, status=Invoice.PAID)),
        start=0,
    )
    balance_amount = booking.total_amount - paid_amount
    if balance_amount <= 0:
        raise BookingCompletionError("Aucun solde positif ne reste à facturer.")

    invoice = Invoice.objects.create(
        booking=booking,
        invoice_number=f"UDJ-SOL-{booking.event_date:%Y}-{booking.pk:06d}",
        invoice_type=Invoice.BALANCE,
        amount=balance_amount,
        status=Invoice.SENT,
        due_at=timezone.now() + timedelta(days=7),
    )
    booking.status = Booking.PERFORMED
    booking.save(update_fields=["status"])
    notify_balance_invoice_created(booking, invoice)
    return booking, invoice


@transaction.atomic
def cancel_booking(booking_id, actor, reason):
    """Annule un dossier remboursé et libère toutes les ressources encore ouvertes."""
    if not actor.is_staff:
        raise BookingCancellationError("Seule l'administration peut confirmer l'annulation d'une réservation.")
    reason = reason.strip()
    if not reason:
        raise BookingCancellationError("Un motif d'annulation est obligatoire.")

    booking = (
        Booking.objects.select_for_update()
        .select_related("contract", "dj")
        .get(pk=booking_id)
    )
    if booking.status not in {Booking.PREPARATORY_MEETING, Booking.CONFIRMED, Booking.PAID}:
        raise BookingCancellationError("Cette réservation ne peut plus être annulée dans son état actuel.")
    event_start = timezone.make_aware(datetime.combine(booking.event_date, booking.start_time))
    if event_start <= timezone.now():
        raise BookingCancellationError("Une prestation déjà commencée ne peut plus être annulée.")

    blocking_payments = Payment.objects.select_for_update().filter(
        booking=booking,
        status__in=[Payment.PENDING, Payment.PAID],
    )
    if blocking_payments.exists():
        raise BookingCancellationError(
            "Tous les paiements en attente ou encaissés doivent être résolus et remboursés avant l'annulation."
        )

    booking.status = Booking.CANCELLED
    booking.deposit_paid = False
    booking.cancellation_reason = reason
    booking.save(update_fields=["status", "deposit_paid", "cancellation_reason"])

    if hasattr(booking, "contract") and booking.contract.status != Contract.CANCELLED:
        booking.contract.status = Contract.CANCELLED
        booking.contract.save(update_fields=["status"])
    PreparatoryAppointment.objects.select_for_update().filter(
        booking=booking,
        status__in=[
            PreparatoryAppointment.PROPOSED,
            PreparatoryAppointment.COUNTER_PROPOSED,
            PreparatoryAppointment.ACCEPTED,
        ],
    ).update(status=PreparatoryAppointment.CANCELLED)
    Invoice.objects.select_for_update().filter(
        booking=booking,
        status__in=[Invoice.DRAFT, Invoice.SENT],
    ).update(status=Invoice.CANCELLED)
    DJAvailability.objects.select_for_update().filter(
        dj=booking.dj,
        available_date=booking.event_date,
        status__in=[DJAvailability.RESERVED, DJAvailability.OCCUPIED],
        reason=f"Réservation #{booking.pk}",
    ).update(status=DJAvailability.AVAILABLE, reason="")
    pending_requests = list(CancellationRequest.objects.select_for_update().filter(
        booking=booking,
        status=CancellationRequest.PENDING,
    ))
    CancellationRequest.objects.filter(pk__in=[item.pk for item in pending_requests]).update(
        status=CancellationRequest.APPROVED, reviewed_at=timezone.now(), reviewed_by=actor
    )
    for cancellation_request in pending_requests:
        cancellation_request.status = CancellationRequest.APPROVED
        cancellation_request.reviewed_at = timezone.now()
        cancellation_request.reviewed_by = actor
        cancellation_request.booking = booking
        notify_cancellation_reviewed(cancellation_request)
    if not pending_requests:
        notify_booking_cancelled(booking, reason)
    return booking


@transaction.atomic
def request_booking_cancellation(booking_id, actor, reason):
    """Enregistre une demande client sans annuler ni rembourser automatiquement."""
    reason = reason.strip()
    if not reason:
        raise CancellationRequestError("Un motif d'annulation est obligatoire.")
    booking = Booking.objects.select_for_update().select_related("client__user").get(pk=booking_id)
    if actor.is_staff or booking.client.user_id != actor.pk:
        raise CancellationRequestError("Seul le client concerné peut demander cette annulation.")
    if booking.status not in {Booking.PREPARATORY_MEETING, Booking.CONFIRMED, Booking.PAID}:
        raise CancellationRequestError("Cette réservation ne peut plus faire l'objet d'une demande d'annulation.")
    event_start = timezone.make_aware(datetime.combine(booking.event_date, booking.start_time))
    if event_start <= timezone.now():
        raise CancellationRequestError("Une prestation déjà commencée ne peut plus être annulée.")
    if CancellationRequest.objects.select_for_update().filter(booking=booking, status=CancellationRequest.PENDING).exists():
        raise CancellationRequestError("Une demande d'annulation est déjà en attente pour cette réservation.")
    cancellation_request = CancellationRequest.objects.create(booking=booking, reason=reason)
    notify_cancellation_requested(cancellation_request)
    return cancellation_request


@transaction.atomic
def reject_booking_cancellation(booking_id, actor, message):
    """Refuse la demande en attente en conservant la réponse administrative."""
    if not actor.is_staff:
        raise CancellationRequestError("Seule l'administration peut traiter une demande d'annulation.")
    message = message.strip()
    if not message:
        raise CancellationRequestError("Une réponse au client est obligatoire.")
    cancellation_request = (
        CancellationRequest.objects.select_for_update()
        .filter(booking_id=booking_id, status=CancellationRequest.PENDING)
        .order_by("-requested_at")
        .first()
    )
    if cancellation_request is None:
        raise CancellationRequestError("Aucune demande d'annulation en attente n'a été trouvée.")
    cancellation_request.status = CancellationRequest.REJECTED
    cancellation_request.reviewed_at = timezone.now()
    cancellation_request.reviewed_by = actor
    cancellation_request.review_message = message
    cancellation_request.save(update_fields=["status", "reviewed_at", "reviewed_by", "review_message"])
    notify_cancellation_reviewed(cancellation_request)
    return cancellation_request
