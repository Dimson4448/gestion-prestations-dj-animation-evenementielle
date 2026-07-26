import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from apps.catalog.models import Equipment, EventType, MusicStyle, Package, ServiceOption


EVENT_TYPE_RENAMES = {
    "Anniversaire": "Anniversaire adulte",
}


def fetch_rows(connection, table_name):
    with connection.cursor() as cursor:
        cursor.execute(f"SELECT * FROM `{table_name}` ORDER BY id")
        return list(cursor.fetchall())


class Command(BaseCommand):
    help = "Importe le catalogue de l'ancienne base XAMPP dans la base Django."

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

        counters = {"created": 0, "updated": 0}
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

        try:
            with transaction.atomic():
                self._import_event_types(legacy_connection, counters)
                self._import_named_rows(legacy_connection, MusicStyle, "music_styles", ("name",), counters)
                self._import_named_rows(
                    legacy_connection,
                    Package,
                    "packages",
                    ("name", "description", "included_hours", "base_price", "is_active"),
                    counters,
                )
                self._import_named_rows(
                    legacy_connection,
                    ServiceOption,
                    "service_options",
                    ("name", "price_type", "unit_price", "is_active"),
                    counters,
                )
                self._import_equipment(legacy_connection, counters)

                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['created']} créations, "
                f"{counters['updated']} mises à jour."
            )
        )

    def _import_event_types(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, "event_types"):
            name = EVENT_TYPE_RENAMES.get(row["name"], row["name"])
            self._upsert(
                EventType,
                {"name": name},
                {"requires_preparatory_meeting": bool(row["requires_preparatory_meeting"])},
                counters,
            )

    def _import_named_rows(self, legacy_connection, model, table_name, fields, counters):
        for row in fetch_rows(legacy_connection, table_name):
            lookup = {"name": row["name"]}
            defaults = {field: row[field] for field in fields if field != "name"}
            self._upsert(model, lookup, defaults, counters)

    def _import_equipment(self, legacy_connection, counters):
        fields = ("category", "name", "daily_cost", "replacement_value", "status")
        for row in fetch_rows(legacy_connection, "equipment"):
            defaults = {field: row[field] for field in fields}
            self._upsert(
                Equipment,
                {"serial_number": row["serial_number"]},
                defaults,
                counters,
            )

    @staticmethod
    def _upsert(model, lookup, defaults, counters):
        _, created = model.objects.update_or_create(defaults=defaults, **lookup)
        counters["created" if created else "updated"] += 1
