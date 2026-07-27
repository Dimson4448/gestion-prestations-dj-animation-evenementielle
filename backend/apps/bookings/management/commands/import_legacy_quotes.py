from datetime import time, timedelta

import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import ClientProfile
from apps.bookings.models import Quote, QuoteOption, Venue
from apps.catalog.models import EventType, Package, ServiceOption


EVENT_TYPE_RENAMES = {
    "Anniversaire": "Anniversaire adulte",
}

QUOTE_QUERY = """
    SELECT
        q.id AS legacy_quote_id,
        u.email,
        et.name AS event_type_name,
        p.name AS package_name,
        v.name AS venue_name,
        v.street AS venue_street,
        v.postal_code AS venue_postal_code,
        v.city AS venue_city,
        q.event_date,
        q.start_time,
        q.duration_hours,
        q.guest_count,
        q.distance_km,
        q.parking_available,
        q.status,
        q.subtotal,
        q.travel_fee,
        q.total_amount,
        q.deposit_amount,
        q.music_preferences,
        q.created_at
    FROM quotes q
    JOIN client_profiles cp ON cp.id = q.client_profile_id
    JOIN users u ON u.id = cp.user_id
    JOIN event_types et ON et.id = q.event_type_id
    JOIN packages p ON p.id = q.package_id
    JOIN venues v ON v.id = q.venue_id
    ORDER BY q.id
"""

OPTION_QUERY = """
    SELECT
        qo.id AS legacy_quote_option_id,
        qo.quote_id AS legacy_quote_id,
        so.name AS service_option_name,
        qo.quantity,
        qo.unit_price
    FROM quote_options qo
    JOIN service_options so ON so.id = qo.service_option_id
    ORDER BY qo.id
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
    help = "Importe les devis et leurs options depuis l'ancienne base XAMPP."

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
            "quotes_created": 0,
            "quotes_updated": 0,
            "options_created": 0,
            "options_updated": 0,
        }

        try:
            with transaction.atomic():
                self._import_quotes(legacy_connection, counters)
                self._import_options(legacy_connection, counters)
                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['quotes_created']} devis créés, "
                f"{counters['quotes_updated']} mis à jour, "
                f"{counters['options_created']} options créées et "
                f"{counters['options_updated']} mises à jour."
            )
        )

    def _import_quotes(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, QUOTE_QUERY):
            try:
                client = ClientProfile.objects.get(user__username=row["email"])
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
            except (ClientProfile.DoesNotExist, EventType.DoesNotExist, Package.DoesNotExist, Venue.DoesNotExist) as error:
                raise CommandError(
                    f"Le devis historique {row['legacy_quote_id']} référence une donnée non importée."
                ) from error

            quote, created = Quote.objects.update_or_create(
                pk=row["legacy_quote_id"],
                defaults={
                    "client": client,
                    "event_type": event_type,
                    "package": package,
                    "venue": venue,
                    "event_date": row["event_date"],
                    "start_time": legacy_time(row["start_time"]),
                    "duration_hours": row["duration_hours"],
                    "guest_count": row["guest_count"],
                    "distance_km": row["distance_km"],
                    "parking_available": bool(row["parking_available"]),
                    "status": row["status"],
                    "subtotal": row["subtotal"],
                    "travel_fee": row["travel_fee"],
                    "total_amount": row["total_amount"],
                    "deposit_amount": row["deposit_amount"],
                    "music_preferences": row["music_preferences"],
                },
            )
            Quote.objects.filter(pk=quote.pk).update(created_at=aware(row["created_at"]))
            counters["quotes_created" if created else "quotes_updated"] += 1

    def _import_options(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, OPTION_QUERY):
            try:
                quote = Quote.objects.get(pk=row["legacy_quote_id"])
                service_option = ServiceOption.objects.get(name=row["service_option_name"])
            except (Quote.DoesNotExist, ServiceOption.DoesNotExist) as error:
                raise CommandError(
                    f"L'option historique {row['legacy_quote_option_id']} référence une donnée non importée."
                ) from error

            _, created = QuoteOption.objects.update_or_create(
                pk=row["legacy_quote_option_id"],
                defaults={
                    "quote": quote,
                    "service_option": service_option,
                    "quantity": row["quantity"],
                    "unit_price": row["unit_price"],
                },
            )
            counters["options_created" if created else "options_updated"] += 1
