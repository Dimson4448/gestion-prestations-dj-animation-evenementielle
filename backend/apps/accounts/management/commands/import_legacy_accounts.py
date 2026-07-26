import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import identify_hasher
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import ClientProfile, DJProfile
from apps.catalog.models import MusicStyle


USER_QUERY = """
    SELECT
        u.id AS legacy_user_id,
        u.email,
        u.password_hash,
        u.first_name,
        u.last_name,
        u.phone,
        u.date_of_birth,
        u.is_active,
        u.created_at,
        r.code AS role_code,
        l.code AS language_code
    FROM users u
    JOIN roles r ON r.id = u.role_id
    JOIN languages l ON l.id = u.language_id
    ORDER BY u.id
"""

CLIENT_QUERY = """
    SELECT
        u.email,
        u.phone,
        u.date_of_birth,
        l.code AS language_code,
        cp.billing_address,
        cp.billing_city,
        cp.billing_postal_code,
        cp.created_at
    FROM client_profiles cp
    JOIN users u ON u.id = cp.user_id
    JOIN languages l ON l.id = u.language_id
    ORDER BY cp.id
"""

DJ_QUERY = """
    SELECT
        dp.id AS legacy_dj_id,
        u.email,
        dp.stage_name,
        dp.bio,
        dp.base_hourly_rate,
        dp.travel_rate_per_km,
        dp.years_experience,
        dp.is_available
    FROM dj_profiles dp
    JOIN users u ON u.id = dp.user_id
    ORDER BY dp.id
"""

DJ_STYLE_QUERY = """
    SELECT dms.dj_profile_id AS legacy_dj_id, ms.name AS style_name
    FROM dj_music_styles dms
    JOIN music_styles ms ON ms.id = dms.music_style_id
    ORDER BY dms.dj_profile_id, dms.music_style_id
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
    help = "Importe les utilisateurs et profils de l'ancienne base XAMPP."

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
            "users_created": 0,
            "users_updated": 0,
            "clients": 0,
            "djs": 0,
            "styles": 0,
        }

        try:
            with transaction.atomic():
                self._import_users(legacy_connection, counters)
                self._import_clients(legacy_connection, counters)
                self._import_djs(legacy_connection, counters)

                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['users_created']} utilisateurs créés, "
                f"{counters['users_updated']} mis à jour, {counters['clients']} clients, "
                f"{counters['djs']} DJ et {counters['styles']} associations musicales."
            )
        )

    def _import_users(self, legacy_connection, counters):
        user_model = get_user_model()
        for row in fetch_rows(legacy_connection, USER_QUERY):
            try:
                identify_hasher(row["password_hash"])
            except ValueError as error:
                raise CommandError(
                    f"Le mot de passe historique de l'utilisateur {row['legacy_user_id']} est incompatible."
                ) from error

            role_code = row["role_code"]
            defaults = {
                "email": row["email"],
                "password": row["password_hash"],
                "first_name": row["first_name"],
                "last_name": row["last_name"],
                "is_active": bool(row["is_active"]),
                "is_staff": role_code in {"admin", "staff"},
                "is_superuser": role_code == "admin",
                "date_joined": aware(row["created_at"]),
            }
            _, created = user_model.objects.update_or_create(
                username=row["email"],
                defaults=defaults,
            )
            counters["users_created" if created else "users_updated"] += 1

    def _import_clients(self, legacy_connection, counters):
        user_model = get_user_model()
        for row in fetch_rows(legacy_connection, CLIENT_QUERY):
            user = user_model.objects.get(username=row["email"])
            profile, _ = ClientProfile.objects.update_or_create(
                user=user,
                defaults={
                    "preferred_language": row["language_code"],
                    "date_of_birth": row["date_of_birth"],
                    "phone": row["phone"],
                    "billing_address": row["billing_address"],
                    "billing_city": row["billing_city"],
                    "billing_postal_code": row["billing_postal_code"],
                },
            )
            ClientProfile.objects.filter(pk=profile.pk).update(created_at=aware(row["created_at"]))
            counters["clients"] += 1

    def _import_djs(self, legacy_connection, counters):
        user_model = get_user_model()
        profiles_by_legacy_id = {}
        for row in fetch_rows(legacy_connection, DJ_QUERY):
            user = user_model.objects.get(username=row["email"])
            profile, _ = DJProfile.objects.update_or_create(
                user=user,
                defaults={
                    "stage_name": row["stage_name"],
                    "bio": row["bio"],
                    "base_hourly_rate": row["base_hourly_rate"],
                    "travel_rate_per_km": row["travel_rate_per_km"],
                    "years_experience": row["years_experience"],
                    "is_available": bool(row["is_available"]),
                },
            )
            profiles_by_legacy_id[row["legacy_dj_id"]] = profile
            counters["djs"] += 1

        styles_by_dj = {legacy_id: [] for legacy_id in profiles_by_legacy_id}
        for row in fetch_rows(legacy_connection, DJ_STYLE_QUERY):
            try:
                style = MusicStyle.objects.get(name=row["style_name"])
            except MusicStyle.DoesNotExist as error:
                raise CommandError(
                    f"Le style musical historique '{row['style_name']}' n'a pas été importé."
                ) from error
            styles_by_dj[row["legacy_dj_id"]].append(style)

        for legacy_id, profile in profiles_by_legacy_id.items():
            styles = styles_by_dj[legacy_id]
            profile.music_styles.set(styles)
            counters["styles"] += len(styles)
