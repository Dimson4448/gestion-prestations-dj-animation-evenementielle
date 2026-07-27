import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.bookings.models import Booking
from apps.payments.models import Invoice, Payment


INVOICE_QUERY = """
    SELECT id, booking_id, invoice_number, invoice_type, amount, status,
           issued_at, due_at
    FROM invoices
    ORDER BY id
"""

PAYMENT_QUERY = """
    SELECT id, booking_id, invoice_id, stripe_session_id,
           stripe_payment_intent_id, amount, currency, status, paid_at
    FROM payments
    ORDER BY id
"""


def fetch_rows(connection, query):
    with connection.cursor() as cursor:
        cursor.execute(query)
        return list(cursor.fetchall())


def aware(value):
    if value is None or timezone.is_aware(value):
        return value
    return timezone.make_aware(value, timezone.get_default_timezone())


class Command(BaseCommand):
    help = "Importe les factures et paiements depuis l'ancienne base XAMPP."

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Simule l'import puis annule la transaction.",
        )

    def handle(self, *args, **options):
        legacy_settings = settings.LEGACY_DATABASE
        if not legacy_settings["NAME"]:
            raise CommandError(
                "La base historique est absente. Renseignez LEGACY_DB_NAME et les paramètres associés."
            )

        try:
            legacy_connection = MySQLdb.connect(
                host=legacy_settings["HOST"],
                port=legacy_settings["PORT"],
                user=legacy_settings["USER"],
                passwd=legacy_settings["PASSWORD"],
                db=legacy_settings["NAME"],
                charset="utf8mb4",
                cursorclass=DictCursor,
            )
        except MySQLdb.Error as error:
            raise CommandError(f"Connexion à la base historique impossible : {error}") from error

        counters = {"invoices": 0, "payments": 0}
        try:
            with transaction.atomic():
                self._import_invoices(legacy_connection, counters)
                self._import_payments(legacy_connection, counters)
                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['invoices']} factures "
                f"et {counters['payments']} paiements traités."
            )
        )

    def _booking(self, booking_id, record_name, record_id):
        try:
            return Booking.objects.get(pk=booking_id)
        except Booking.DoesNotExist as error:
            raise CommandError(
                f"Le {record_name} historique {record_id} référence une réservation non importée."
            ) from error

    def _import_invoices(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, INVOICE_QUERY):
            booking = self._booking(row["booking_id"], "facture", row["id"])
            invoice, _ = Invoice.objects.update_or_create(
                pk=row["id"],
                defaults={
                    "booking": booking,
                    "invoice_number": row["invoice_number"],
                    "invoice_type": row["invoice_type"],
                    "amount": row["amount"],
                    "status": row["status"],
                    "due_at": aware(row["due_at"]),
                },
            )
            Invoice.objects.filter(pk=invoice.pk).update(issued_at=aware(row["issued_at"]))
            counters["invoices"] += 1

    def _import_payments(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, PAYMENT_QUERY):
            booking = self._booking(row["booking_id"], "paiement", row["id"])
            try:
                invoice = Invoice.objects.get(pk=row["invoice_id"])
            except Invoice.DoesNotExist as error:
                raise CommandError(
                    f"Le paiement historique {row['id']} référence une facture non importée."
                ) from error

            if invoice.booking_id != booking.id:
                raise CommandError(
                    f"Le paiement historique {row['id']} relie une facture à une autre réservation."
                )

            Payment.objects.update_or_create(
                pk=row["id"],
                defaults={
                    "booking": booking,
                    "invoice": invoice,
                    "stripe_session_id": row["stripe_session_id"],
                    "stripe_payment_intent_id": row["stripe_payment_intent_id"],
                    "amount": row["amount"],
                    "currency": row["currency"],
                    "status": row["status"],
                    "paid_at": aware(row["paid_at"]),
                },
            )
            counters["payments"] += 1
