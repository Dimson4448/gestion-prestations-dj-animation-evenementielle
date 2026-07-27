from datetime import time, timedelta

import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import ClientProfile, DJProfile
from apps.bookings.models import Booking, BookingEquipment, Quote, Venue
from apps.catalog.models import Equipment, EventType, Package


EVENT_TYPE_RENAMES = {
    "Anniversaire": "Anniversaire adulte",
}

BOOKING_QUERY = """
    SELECT
        b.id AS legacy_booking_id,
        b.quote_id AS legacy_quote_id,
        client_user.email AS client_email,
        dj_user.email AS dj_email,
        et.name AS event_type_name,
        p.name AS package_name,
        v.name AS venue_name,
        v.street AS venue_street,
        v.postal_code AS venue_postal_code,
        v.city AS venue_city,
        b.event_date,
        b.start_time,
        b.end_time,
        b.status,
        b.total_amount,
        b.deposit_required,
        b.deposit_paid,
        b.cancellation_reason,
        b.created_at
    FROM bookings b
    JOIN client_profiles cp ON cp.id = b.client_profile_id
    JOIN users client_user ON client_user.id = cp.user_id
    JOIN dj_profiles dp ON dp.id = b.dj_profile_id
    JOIN users dj_user ON dj_user.id = dp.user_id
    JOIN event_types et ON et.id = b.event_type_id
    JOIN packages p ON p.id = b.package_id
    JOIN venues v ON v.id = b.venue_id
    ORDER BY b.id
"""

EQUIPMENT_QUERY = """
    SELECT
        be.booking_id AS legacy_booking_id,
        e.serial_number,
        be.quantity
    FROM booking_equipment be
    JOIN equipment e ON e.id = be.equipment_id
    ORDER BY be.booking_id, be.equipment_id
"""


def fetch_rows(connection, query):
    with connection.cursor() as cursor:
        cursor.execute(query)
        return list(cursor.fetchall())


def legacy_time(value):
    if isinstance(value, time):
        return value
    if isinstance(value, timedelta):
        seconds = int(value.total_seconds())
        hours, remainder = divmod(seconds, 3600)
        minutes, seconds = divmod(remainder, 60)
        return time(hour=hours, minute=minutes, second=seconds)
    raise CommandError(f"Valeur horaire historique incompatible : {type(value).__name__}")


def aware(value):
    if value is None or timezone.is_aware(value):
        return value
    return timezone.make_aware(value, timezone.get_default_timezone())


class Command(BaseCommand):
    help = "Importe les réservations et leur matériel depuis l'ancienne base XAMPP."

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

        counters = {
            "bookings_created": 0,
            "bookings_updated": 0,
            "equipment_created": 0,
            "equipment_updated": 0,
        }

        try:
            with transaction.atomic():
                self._import_bookings(legacy_connection, counters)
                self._import_equipment(legacy_connection, counters)
                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['bookings_created']} réservations créées, "
                f"{counters['bookings_updated']} mises à jour, "
                f"{counters['equipment_created']} matériels associés et "
                f"{counters['equipment_updated']} associations mises à jour."
            )
        )

    def _import_bookings(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, BOOKING_QUERY):
            try:
                quote = Quote.objects.get(pk=row["legacy_quote_id"])
                client = ClientProfile.objects.get(user__username=row["client_email"])
                dj = DJProfile.objects.get(user__username=row["dj_email"])
                event_type = EventType.objects.get(
                    name=EVENT_TYPE_RENAMES.get(row["event_type_name"], row["event_type_name"])
                )
                package = Package.objects.get(name=row["package_name"])
                venue = Venue.objects.get(
                    client=client,
                    name=row["venue_name"],
                    street=row["venue_street"],
                    postal_code=row["venue_postal_code"],
                    city=row["venue_city"],
                )
            except (
                Quote.DoesNotExist,
                ClientProfile.DoesNotExist,
                DJProfile.DoesNotExist,
                EventType.DoesNotExist,
                Package.DoesNotExist,
                Venue.DoesNotExist,
            ) as error:
                raise CommandError(
                    f"La réservation historique {row['legacy_booking_id']} référence une donnée non importée."
                ) from error

            booking, created = Booking.objects.update_or_create(
                pk=row["legacy_booking_id"],
                defaults={
                    "quote": quote,
                    "client": client,
                    "dj": dj,
                    "event_type": event_type,
                    "package": package,
                    "venue": venue,
                    "event_date": row["event_date"],
                    "start_time": legacy_time(row["start_time"]),
                    "end_time": legacy_time(row["end_time"]),
                    "status": row["status"],
                    "total_amount": row["total_amount"],
                    "deposit_required": row["deposit_required"],
                    "deposit_paid": bool(row["deposit_paid"]),
                    "cancellation_reason": row["cancellation_reason"] or "",
                },
            )
            Booking.objects.filter(pk=booking.pk).update(created_at=aware(row["created_at"]))
            counters["bookings_created" if created else "bookings_updated"] += 1

    def _import_equipment(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, EQUIPMENT_QUERY):
            try:
                booking = Booking.objects.get(pk=row["legacy_booking_id"])
                equipment = Equipment.objects.get(serial_number=row["serial_number"])
            except (Booking.DoesNotExist, Equipment.DoesNotExist) as error:
                raise CommandError(
                    f"Le matériel de la réservation {row['legacy_booking_id']} référence une donnée non importée."
                ) from error

            _, created = BookingEquipment.objects.update_or_create(
                booking=booking,
                equipment=equipment,
                defaults={"quantity": row["quantity"]},
            )
            counters["equipment_created" if created else "equipment_updated"] += 1
