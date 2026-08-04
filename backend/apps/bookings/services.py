from datetime import datetime, timedelta

from django.db import transaction
from django.utils import timezone

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.payments.models import Invoice, Payment

from .models import Booking, CancellationRequest, Contract, PreparatoryAppointment, Quote


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


def _event_end_time(quote):
    start = datetime.combine(quote.event_date, quote.start_time)
    end = start + timedelta(seconds=int(quote.duration_hours * 3600))
    if end.date() != quote.event_date:
        raise QuoteAcceptanceError(
            "La prestation dépasse minuit. Les créneaux sur plusieurs jours ne sont pas encore pris en charge."
        )
    return end.time()


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

    end_time = _event_end_time(quote)
    availability = (
        DJAvailability.objects.select_for_update()
        .filter(
            dj=dj,
            available_date=quote.event_date,
            status=DJAvailability.AVAILABLE,
            start_time__lte=quote.start_time,
            end_time__gte=end_time,
        )
        .order_by("start_time")
        .first()
    )
    if availability is None:
        raise QuoteAcceptanceError("Le DJ ne possède pas de créneau disponible couvrant toute la prestation.")

    conflict = Booking.objects.select_for_update().filter(
        dj=dj,
        event_date=quote.event_date,
        start_time__lt=end_time,
        end_time__gt=quote.start_time,
    ).exclude(status=Booking.CANCELLED)
    if conflict.exists():
        raise QuoteAcceptanceError("Le DJ possède déjà une réservation sur ce créneau.")

    booking = Booking.objects.create(
        quote=quote,
        client=quote.client,
        dj=dj,
        event_type=quote.event_type,
        package=quote.package,
        venue=quote.venue,
        event_date=quote.event_date,
        start_time=quote.start_time,
        end_time=end_time,
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
    quote.status = Quote.ACCEPTED
    quote.save(update_fields=["status"])

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

    event_end = timezone.make_aware(datetime.combine(booking.event_date, booking.end_time))
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
        status=PreparatoryAppointment.PLANNED,
    ).update(status=PreparatoryAppointment.CANCELLED)
    Invoice.objects.select_for_update().filter(
        booking=booking,
        status__in=[Invoice.DRAFT, Invoice.SENT],
    ).update(status=Invoice.CANCELLED)
    DJAvailability.objects.select_for_update().filter(
        dj=booking.dj,
        available_date=booking.event_date,
        status=DJAvailability.RESERVED,
        reason=f"Réservation #{booking.pk}",
    ).update(status=DJAvailability.AVAILABLE, reason="")
    CancellationRequest.objects.select_for_update().filter(
        booking=booking,
        status=CancellationRequest.PENDING,
    ).update(status=CancellationRequest.APPROVED, reviewed_at=timezone.now(), reviewed_by=actor)
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
    return CancellationRequest.objects.create(booking=booking, reason=reason)


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
    return cancellation_request
