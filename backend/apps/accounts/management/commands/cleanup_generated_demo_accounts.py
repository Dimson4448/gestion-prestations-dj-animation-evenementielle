import re

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.db.models import Q

from apps.accounts.models import AccountDeletionRequest, ClientProfile, DJProfile
from apps.bookings.models import Booking, Quote
from apps.payments.models import Refund


CLIENT_EMAIL_PATTERN = r"^client[0-9]{3}@ultimate-dj[.]test$"
DJ_EMAIL_PATTERN = r"^dj[0-9]{3}@ultimate-dj[.]test$"
DJ_STAGE_NAME_PATTERN = r"^DJ Horizon [0-9]{3}$"


class Command(BaseCommand):
    help = "Supprime exclusivement les comptes de démonstration générés en série."

    def add_arguments(self, parser):
        parser.add_argument(
            "--execute",
            action="store_true",
            help="Effectue réellement la suppression. Sans cette option, la commande affiche un aperçu.",
        )

    def handle(self, *args, **options):
        user_model = get_user_model()
        generated_client_users = user_model.objects.filter(
            email__regex=CLIENT_EMAIL_PATTERN,
            is_staff=False,
            is_superuser=False,
        )
        generated_dj_users = user_model.objects.filter(
            email__regex=DJ_EMAIL_PATTERN,
            is_staff=False,
            is_superuser=False,
            dj_profile__stage_name__regex=DJ_STAGE_NAME_PATTERN,
        )
        generated_clients = ClientProfile.objects.filter(user__in=generated_client_users)
        generated_djs = DJProfile.objects.filter(user__in=generated_dj_users)

        counts = {
            "clients": generated_clients.count(),
            "djs": generated_djs.count(),
            "bookings": Booking.objects.filter(Q(client__in=generated_clients) | Q(dj__in=generated_djs)).count(),
            "quotes": Quote.objects.filter(Q(client__in=generated_clients) | Q(requested_dj__in=generated_djs)).count(),
        }
        self.stdout.write(
            "Comptes générés détectés : "
            f"{counts['clients']} client(s), {counts['djs']} DJ, "
            f"{counts['quotes']} devis et {counts['bookings']} réservation(s)."
        )

        if not options["execute"]:
            self.stdout.write(self.style.WARNING("Aucune suppression effectuée. Ajoutez --execute pour confirmer."))
            return

        invalid_client_emails = [
            email
            for email in generated_client_users.values_list("email", flat=True)
            if not re.fullmatch(CLIENT_EMAIL_PATTERN, email)
        ]
        invalid_djs = [
            (email, stage_name)
            for email, stage_name in generated_dj_users.values_list("email", "dj_profile__stage_name")
            if not re.fullmatch(DJ_EMAIL_PATTERN, email) or not re.fullmatch(DJ_STAGE_NAME_PATTERN, stage_name)
        ]
        if invalid_client_emails or invalid_djs:
            raise CommandError("Le contrôle de sécurité des comptes générés a échoué.")

        with transaction.atomic():
            generated_bookings = Booking.objects.filter(Q(client__in=generated_clients) | Q(dj__in=generated_djs))
            Refund.objects.filter(payment__booking__in=generated_bookings).delete()
            generated_bookings.delete()
            Quote.objects.filter(Q(client__in=generated_clients) | Q(requested_dj__in=generated_djs)).delete()
            AccountDeletionRequest.objects.filter(client__in=generated_clients).delete()
            generated_client_users.delete()
            generated_dj_users.delete()

        self.stdout.write(
            self.style.SUCCESS(
                f"Nettoyage terminé : {counts['clients']} client(s) et {counts['djs']} DJ générés supprimés."
            )
        )
