from datetime import time, timedelta

import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from apps.accounts.models import ClientProfile, DJProfile
from apps.availability.models import DJAvailability
from apps.bookings.models import Venue


VENUE_QUERY = """
    SELECT
        u.email,
        v.name,
        v.street,
        v.postal_code,
        v.city,
        v.country,
        v.has_parking,
        v.distance_km_from_base
    FROM venues v
    JOIN client_profiles cp ON cp.id = v.client_profile_id
    JOIN users u ON u.id = cp.user_id
    ORDER BY v.id
"""

AVAILABILITY_QUERY = """
    SELECT
        u.email,
        da.available_date,
        da.start_time,
        da.end_time,
        da.status
    FROM dj_availabilities da
    JOIN dj_profiles dp ON dp.id = da.dj_profile_id
    JOIN users u ON u.id = dp.user_id
    ORDER BY da.id
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


class Command(BaseCommand):
    help = "Importe les lieux clients et les disponibilités DJ de l'ancienne base XAMPP."

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
            "venues_created": 0,
            "venues_updated": 0,
            "slots_created": 0,
            "slots_updated": 0,
        }

        try:
            with transaction.atomic():
                self._import_venues(legacy_connection, counters)
                self._import_availabilities(legacy_connection, counters)
                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['venues_created']} lieux créés, "
                f"{counters['venues_updated']} mis à jour, "
                f"{counters['slots_created']} créneaux créés et "
                f"{counters['slots_updated']} mis à jour."
            )
        )

    def _import_venues(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, VENUE_QUERY):
            try:
                client = ClientProfile.objects.select_related("user").get(user__username=row["email"])
            except ClientProfile.DoesNotExist as error:
                raise CommandError(
                    "Un lieu historique référence un client qui n'a pas été importé."
                ) from error

            _, created = Venue.objects.update_or_create(
                client=client,
                name=row["name"],
                street=row["street"],
                postal_code=row["postal_code"],
                city=row["city"],
                defaults={
                    "country": row["country"],
                    "has_parking": bool(row["has_parking"]),
                    "distance_km_from_base": row["distance_km_from_base"],
                },
            )
            counters["venues_created" if created else "venues_updated"] += 1

    def _import_availabilities(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, AVAILABILITY_QUERY):
            try:
                dj = DJProfile.objects.select_related("user").get(user__username=row["email"])
            except DJProfile.DoesNotExist as error:
                raise CommandError(
                    "Un créneau historique référence un DJ qui n'a pas été importé."
                ) from error

            _, created = DJAvailability.objects.update_or_create(
                dj=dj,
                available_date=row["available_date"],
                start_time=legacy_time(row["start_time"]),
                defaults={
                    "end_time": legacy_time(row["end_time"]),
                    "status": row["status"],
                    "reason": "",
                },
            )
            counters["slots_created" if created else "slots_updated"] += 1
