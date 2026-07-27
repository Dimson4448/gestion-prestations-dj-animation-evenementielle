from datetime import datetime, timedelta

from django.db import transaction
from django.utils import timezone

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.payments.models import Invoice

from .models import Booking, Contract, Quote


class QuoteAcceptanceError(Exception):
    """Erreur fonctionnelle empêchant la conversion complète d'un devis."""


class ContractSigningError(Exception):
    """Erreur fonctionnelle empêchant la signature d'un contrat."""


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
