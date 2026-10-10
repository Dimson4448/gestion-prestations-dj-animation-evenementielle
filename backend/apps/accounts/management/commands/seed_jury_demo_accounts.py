from datetime import date, datetime, time, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import ClientProfile, DJProfile, NotificationPreference
from apps.availability.models import DJAvailability
from apps.catalog.models import MusicStyle


DEMO_PASSWORD = "DemoUltimateDJ2026!"
EMAIL_PREFIX = "ultimate.dj.be+"

CLIENTS = [
    ("camille.desmet", "Camille", "De Smet", "camille.desmet", "0470 12 34 56", "Bruxelles", "1000", "Rue de la Loi 18"),
    ("nora.elmansouri", "Nora", "El Mansouri", "nora.elmansouri", "0471 23 45 67", "Liège", "4000", "Rue Vinâve d'Île 22"),
    ("arthur.lambert", "Arthur", "Lambert", "arthur.lambert", "0472 34 56 78", "Namur", "5000", "Rue de Fer 31"),
    ("ines.vandamme", "Inès", "Van Damme", "ines.vandamme", "0473 45 67 89", "Gand", "9000", "Korenmarkt 9"),
    ("lucas.verhaegen", "Lucas", "Verhaegen", "lucas.verhaegen", "0474 56 78 90", "Haaltert", "9450", "Stationsstraat 14"),
    ("margot.dubois", "Margot", "Dubois", "margot.dubois", "0475 67 89 01", "Mons", "7000", "Rue de Nimy 42"),
    ("youssef.benali", "Youssef", "Benali", "youssef.benali", "0476 78 90 12", "Anvers", "2000", "Meir 63"),
]

DJS = [
    ("clara.vandenberg", "Clara", "Vandenberg", "DJ Clara Vandenberg", "Bruxelles", "Afrobeats, Pop, House", "95.00"),
    ("thomas.vermeulen", "Thomas", "Vermeulen", "DJ Thomas Vermeulen", "Anvers", "House, Techno, Pop", "100.00"),
    ("elise.dewilde", "Élise", "De Wilde", "DJ Élise De Wilde", "Gand", "Disco, Funk, Années 90", "90.00"),
    ("nathan.leclercq", "Nathan", "Leclercq", "DJ Nathan Leclercq", "Liège", "Rap, R&B, Afrobeats", "95.00"),
    ("ines.dupont", "Inès", "Dupont", "DJ Inès Dupont", "Charleroi", "Pop, Dance, Années 80", "85.00"),
    ("julien.massart", "Julien", "Massart", "DJ Julien Massart", "Namur", "Chanson française, Pop, Soul", "88.00"),
    ("lotte.vandamme", "Lotte", "Van Damme", "DJ Lotte Van Damme", "Bruges", "Ambient, Jazz, Lounge", "92.00"),
    ("arnaud.peeters", "Arnaud", "Peeters", "DJ Arnaud Peeters", "Louvain", "Electro, House, Indie pop", "98.00"),
    ("eva.janssen", "Eva", "Janssen", "DJ Eva Janssen", "Hasselt", "Latin pop, Reggaeton, Dancehall", "90.00"),
    ("romain.delcourt", "Romain", "Delcourt", "DJ Romain Delcourt", "Mons", "Rock, Pop rock, Blues", "86.00"),
    ("maarten.desmet", "Maarten", "De Smet", "DJ Maarten De Smet", "Haaltert", "Pop, Disco, Afrobeats", "89.00"),
]


def email(alias):
    return f"{EMAIL_PREFIX}{alias}@gmail.com"


class Command(BaseCommand):
    help = "Crée ou met à jour les comptes de démonstration réalistes pour la présentation au jury."

    @transaction.atomic
    def handle(self, *args, **options):
        user_model = get_user_model()
        styles_by_name = {style.name.casefold(): style for style in MusicStyle.objects.all()}
        created_clients = 0
        created_djs = 0

        for username, first_name, last_name, alias, phone, city, postal_code, address in CLIENTS:
            user, created = user_model.objects.get_or_create(
                username=username,
                defaults={"email": email(alias), "first_name": first_name, "last_name": last_name, "is_active": True},
            )
            user.email = email(alias)
            user.first_name = first_name
            user.last_name = last_name
            user.is_active = True
            user.set_password(DEMO_PASSWORD)
            user.save()
            ClientProfile.objects.update_or_create(
                user=user,
                defaults={
                    "date_of_birth": date(1990, 1, 1), "phone": phone,
                    "billing_address": address, "billing_city": city,
                    "billing_postal_code": postal_code, "preferred_language": "fr",
                },
            )
            NotificationPreference.objects.get_or_create(user=user)
            created_clients += int(created)

        first_slot_date = timezone.localdate() + timedelta(days=7)
        second_slot_date = first_slot_date + timedelta(days=7)
        for index, (username, first_name, last_name, stage_name, city, styles, rate) in enumerate(DJS):
            user, created = user_model.objects.get_or_create(
                username=username,
                defaults={"email": email(username), "first_name": first_name, "last_name": last_name, "is_active": True},
            )
            user.email = email(username)
            user.first_name = first_name
            user.last_name = last_name
            user.is_active = True
            user.set_password(DEMO_PASSWORD)
            user.save()
            dj, _ = DJProfile.objects.update_or_create(
                user=user,
                defaults={
                    "stage_name": stage_name,
                    "bio": f"DJ professionnel basé à {city}, spécialisé en {styles.lower()}.",
                    "base_hourly_rate": Decimal(rate), "travel_rate_per_km": Decimal("0.60"),
                    "years_experience": 6 + (index % 8), "is_available": True,
                },
            )
            selected_styles = [styles_by_name[name.strip().casefold()] for name in styles.split(",") if name.strip().casefold() in styles_by_name]
            dj.music_styles.set(selected_styles)
            NotificationPreference.objects.get_or_create(user=user)
            for slot_date in (first_slot_date, second_slot_date):
                DJAvailability.objects.update_or_create(
                    dj=dj, available_date=slot_date, start_time=time(18, 0),
                    defaults={"end_date": slot_date + timedelta(days=1), "end_time": time(4, 0), "status": DJAvailability.AVAILABLE, "reason": "Créneau de démonstration jury"},
                )
            created_djs += int(created)

        self.stdout.write(self.style.SUCCESS(
            f"Comptes jury prêts : {len(CLIENTS)} clients et {len(DJS)} DJ ({created_clients} clients et {created_djs} DJ nouvellement créés)."
        ))
        self.stdout.write(f"Mot de passe commun : {DEMO_PASSWORD}")
