"""Create a predictable set of sample records for the application.

The command is deliberately idempotent: it updates the accounts created by
``seed_jury_demo_accounts`` and recreates only records carrying the
``Événement suivi`` marker.  It never changes normal customer data.
"""

from datetime import datetime, time, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import ClientProfile, DJProfile
from apps.bookings.models import (
    Booking, Contract, Playlist, PlaylistSong, PreparatoryAppointment, Quote,
    Review, Venue,
)
from apps.catalog.models import EventType, MusicStyle, Package
from apps.payments.models import Invoice, Payment


MARKER = "Événement suivi"


class Command(BaseCommand):
    help = "Prépare cinq dossiers réalistes couvrant toutes les étapes du parcours."

    @transaction.atomic
    def handle(self, *args, **options):
        User = get_user_model()
        try:
            client_a = ClientProfile.objects.select_related("user").get(user__username="camille.desmet")
            client_b = ClientProfile.objects.select_related("user").get(user__username="margot.dubois")
            dj = DJProfile.objects.select_related("user").get(user__username="clara.vandenberg")
            event_type = EventType.objects.filter(name=EventType.ADULT_BIRTHDAY).first() or EventType.objects.first()
            package = Package.objects.filter(is_active=True).first()
        except (ClientProfile.DoesNotExist, DJProfile.DoesNotExist) as exc:
            raise CommandError("Créez d’abord les comptes avec seed_jury_demo_accounts.") from exc
        if not event_type or not package:
            raise CommandError("Le catalogue doit contenir au moins un type d’événement et une formule active.")

        # Keep the command rerunnable and isolate its records from real data.
        demo_quotes = Quote.objects.filter(venue__name__startswith=MARKER) | Quote.objects.filter(music_preferences__startswith="DEMO-JURY")
        Payment.objects.filter(booking__quote__in=demo_quotes).delete()
        Invoice.objects.filter(booking__quote__in=demo_quotes).delete()
        Booking.objects.filter(quote__in=demo_quotes).delete()
        demo_quotes.delete()

        today = timezone.localdate()
        styles = list(MusicStyle.objects.all()[:2])

        def quote(label, client, offset, status, preferences="Afrobeats, Pop"):
            venue, _ = Venue.objects.get_or_create(
                client=client, name=f"{MARKER} — {label}",
                defaults={
                    "street": client.billing_address or "Rue du Parc 1",
                    "postal_code": client.billing_postal_code or "1000",
                    "city": client.billing_city or "Bruxelles", "country": "Belgique",
                    "distance_km_from_base": Decimal("12.00"),
                },
            )
            return Quote.objects.create(
                client=client, requested_dj=dj if status != Quote.DRAFT else None,
                dj_decision=Quote.DJ_PENDING if status == Quote.SENT else Quote.DJ_ACCEPTED,
                dj_decided_at=timezone.now() if status == Quote.ACCEPTED else None,
                event_type=event_type, package=package, venue=venue,
                event_date=today + timedelta(days=offset), start_time=time(19, 0),
                duration_hours=Decimal("5.0"), guest_count=70, distance_km=Decimal("12.00"),
                parking_available=True, status=status,
                subtotal=Decimal("650.00"), travel_fee=Decimal("12.00"),
                total_amount=Decimal("662.00"), deposit_amount=Decimal("198.60"),
                music_preferences=preferences,
            )

        draft = quote("Devis à traiter", client_a, 14, Quote.DRAFT)
        pending_dj = quote("Réponse DJ attendue", client_b, 21, Quote.SENT)

        def booked(label, client, offset, state):
            q = quote(label, client, offset, Quote.ACCEPTED)
            booking = Booking.objects.create(
                quote=q, client=client, dj=dj, event_type=event_type, package=package, venue=q.venue,
                event_date=q.event_date, end_date=q.event_date + timedelta(days=1), start_time=time(19, 0), end_time=time(0, 0),
                status=Booking.PREPARATORY_MEETING, total_amount=q.total_amount, deposit_required=q.deposit_amount,
            )
            contract = Contract.objects.create(
                booking=booking, contract_number=f"UDJ-CON-{booking.event_date:%Y}-{booking.pk:06d}",
                status=Contract.SENT, refund_policy="Annulation et remboursement selon les conditions générales Ultimate DJ.",
            )
            deposit = Invoice.objects.create(
                booking=booking, invoice_number=f"UDJ-ACP-{booking.event_date:%Y}-{booking.pk:06d}", invoice_type=Invoice.DEPOSIT,
                amount=q.deposit_amount, status=Invoice.SENT, due_at=timezone.now() + timedelta(days=7),
            )
            if state in {"preparation", "closed"}:
                contract.status = Contract.SIGNED
                contract.signed_by_client_at = timezone.now() - timedelta(days=2)
                contract.save(update_fields=["status", "signed_by_client_at"])
                deposit.status = Invoice.PAID
                deposit.save(update_fields=["status"])
                Payment.objects.create(booking=booking, invoice=deposit, stripe_session_id=f"sample-deposit-{booking.pk}", amount=deposit.amount, status=Payment.PAID, paid_at=timezone.now() - timedelta(days=2))
                booking.status = Booking.CONFIRMED
                booking.deposit_paid = True
                booking.save(update_fields=["status", "deposit_paid"])
            if state == "preparation":
                PreparatoryAppointment.objects.create(booking=booking, scheduled_at=timezone.now() + timedelta(days=3), mode=PreparatoryAppointment.ONLINE, status=PreparatoryAppointment.ACCEPTED, notes="Préparation du déroulé de la soirée.")
                playlist = Playlist.objects.create(booking=booking, main_style=styles[0] if styles else None, notes="Ambiance validée pendant le rendez-vous.")
                playlist.styles.set(styles)
                PlaylistSong.objects.create(playlist=playlist, title="Tout oublier", artist="Angèle", preference_level=PlaylistSong.MUST_PLAY, status=PlaylistSong.APPROVED)
            if state == "closed":
                balance = Invoice.objects.create(booking=booking, invoice_number=f"UDJ-SOL-{booking.event_date:%Y}-{booking.pk:06d}", invoice_type=Invoice.BALANCE, amount=q.total_amount-q.deposit_amount, status=Invoice.PAID, due_at=timezone.now()-timedelta(days=1))
                Payment.objects.create(booking=booking, invoice=balance, stripe_session_id=f"sample-balance-{booking.pk}", amount=balance.amount, status=Payment.PAID, paid_at=timezone.now()-timedelta(days=1))
                booking.status = Booking.PAID
                booking.save(update_fields=["status"])
                Review.objects.create(booking=booking, client=client, dj=dj, rating=5, comment="Une animation professionnelle et une excellente ambiance.", status=Review.PUBLISHED, dj_response="Merci pour votre confiance !")
            return booking

        contract_booking = booked("Contrat et acompte", client_a, 28, "contract")
        preparation_booking = booked("Préparation", client_b, 35, "preparation")
        closed_booking = booked("Clôturé et payé", client_a, 42, "closed")

        self.stdout.write(self.style.SUCCESS(
            f"Dossiers prêts : devis #{draft.pk}, attente DJ #{pending_dj.pk}, "
            f"réservations #{contract_booking.pk}, #{preparation_booking.pk}, #{closed_booking.pk}."
        ))
