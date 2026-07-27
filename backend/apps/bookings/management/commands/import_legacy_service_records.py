import MySQLdb
from MySQLdb.cursors import DictCursor

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.bookings.models import Booking, Contract, Playlist, PlaylistSong, Review
from apps.catalog.models import MusicStyle


CONTRACT_QUERY = """
    SELECT id, booking_id, contract_number, status, refund_policy,
           signed_by_client_at, created_at
    FROM contracts
    ORDER BY id
"""

PLAYLIST_QUERY = """
    SELECT p.id, p.booking_id, ms.name AS main_style_name, p.notes, p.created_at
    FROM playlists p
    JOIN music_styles ms ON ms.id = p.main_style_id
    ORDER BY p.id
"""

SONG_QUERY = """
    SELECT id, playlist_id, title, artist, preference_level, status
    FROM playlist_songs
    ORDER BY id
"""

REVIEW_QUERY = """
    SELECT id, booking_id, rating, comment, status, created_at
    FROM reviews
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
    help = "Importe contrats, playlists, morceaux et avis depuis l'ancienne base XAMPP."

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

        counters = {"contracts": 0, "playlists": 0, "songs": 0, "reviews": 0}
        try:
            with transaction.atomic():
                self._import_contracts(legacy_connection, counters)
                self._import_playlists(legacy_connection, counters)
                self._import_songs(legacy_connection, counters)
                self._import_reviews(legacy_connection, counters)
                if options["dry_run"]:
                    transaction.set_rollback(True)
        finally:
            legacy_connection.close()

        mode = "Simulation" if options["dry_run"] else "Import"
        self.stdout.write(
            self.style.SUCCESS(
                f"{mode} terminé : {counters['contracts']} contrats, "
                f"{counters['playlists']} playlists, {counters['songs']} morceaux "
                f"et {counters['reviews']} avis traités."
            )
        )

    def _booking(self, booking_id, record_name, record_id):
        try:
            return Booking.objects.select_related("client", "dj").get(pk=booking_id)
        except Booking.DoesNotExist as error:
            raise CommandError(
                f"Le {record_name} historique {record_id} référence une réservation non importée."
            ) from error

    def _import_contracts(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, CONTRACT_QUERY):
            booking = self._booking(row["booking_id"], "contrat", row["id"])
            contract, _ = Contract.objects.update_or_create(
                pk=row["id"],
                defaults={
                    "booking": booking,
                    "contract_number": row["contract_number"],
                    "status": row["status"],
                    "refund_policy": row["refund_policy"],
                    "signed_by_client_at": aware(row["signed_by_client_at"]),
                },
            )
            Contract.objects.filter(pk=contract.pk).update(created_at=aware(row["created_at"]))
            counters["contracts"] += 1

    def _import_playlists(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, PLAYLIST_QUERY):
            booking = self._booking(row["booking_id"], "playlist", row["id"])
            try:
                main_style = MusicStyle.objects.get(name=row["main_style_name"])
            except MusicStyle.DoesNotExist as error:
                raise CommandError(
                    f"La playlist historique {row['id']} référence un style non importé."
                ) from error

            playlist, _ = Playlist.objects.update_or_create(
                pk=row["id"],
                defaults={
                    "booking": booking,
                    "main_style": main_style,
                    "notes": row["notes"] or "",
                },
            )
            Playlist.objects.filter(pk=playlist.pk).update(created_at=aware(row["created_at"]))
            counters["playlists"] += 1

    def _import_songs(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, SONG_QUERY):
            try:
                playlist = Playlist.objects.get(pk=row["playlist_id"])
            except Playlist.DoesNotExist as error:
                raise CommandError(
                    f"Le morceau historique {row['id']} référence une playlist non importée."
                ) from error

            PlaylistSong.objects.update_or_create(
                pk=row["id"],
                defaults={
                    "playlist": playlist,
                    "title": row["title"],
                    "artist": row["artist"],
                    "preference_level": row["preference_level"],
                    "status": row["status"],
                },
            )
            counters["songs"] += 1

    def _import_reviews(self, legacy_connection, counters):
        for row in fetch_rows(legacy_connection, REVIEW_QUERY):
            booking = self._booking(row["booking_id"], "avis", row["id"])
            review, _ = Review.objects.update_or_create(
                pk=row["id"],
                defaults={
                    "booking": booking,
                    "client": booking.client,
                    "dj": booking.dj,
                    "rating": row["rating"],
                    "comment": row["comment"],
                    "status": row["status"],
                },
            )
            Review.objects.filter(pk=review.pk).update(created_at=aware(row["created_at"]))
            counters["reviews"] += 1
