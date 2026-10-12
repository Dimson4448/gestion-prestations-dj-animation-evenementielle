"""Create a small, reusable public catalogue for a fresh deployment."""

from decimal import Decimal

from django.core.management.base import BaseCommand
from django.db import transaction

from apps.catalog.models import EventType, MusicStyle, Package, ServiceOption


EVENT_TYPES = (
    (EventType.CHILD_BIRTHDAY, False),
    (EventType.ADULT_BIRTHDAY, False),
    (EventType.WEDDING, True),
    (EventType.PRIVATE_PARTY, False),
)

MUSIC_STYLES = (
    "Afrobeats", "Années 80", "Années 90", "Dance", "Disco", "Funk",
    "House", "Pop", "R&B", "Rap", "Soul", "Techno",
)

PACKAGES = (
    ("Essentiel", "Prestation DJ simple avec sonorisation légère.", "3.0", "420.00", (EventType.ADULT_BIRTHDAY, EventType.PRIVATE_PARTY)),
    ("Classic", "Animation complète pour soirée privée.", "5.0", "690.00", (EventType.ADULT_BIRTHDAY, EventType.PRIVATE_PARTY)),
    ("Premium", "DJ, sonorisation renforcée et éclairage d'ambiance.", "6.0", "950.00", (EventType.ADULT_BIRTHDAY, EventType.PRIVATE_PARTY, EventType.WEDDING)),
    ("Mariage Silver", "Formule mariage avec rendez-vous préparatoire.", "7.0", "1250.00", (EventType.WEDDING,)),
    ("Mariage Gold", "Formule mariage complète avec options avancées.", "9.0", "1690.00", (EventType.WEDDING,)),
    ("Sur mesure", "Contrat personnalisé selon les besoins.", "1.0", "250.00", EventType.ALLOWED_NAMES),
)

OPTIONS = (
    ("Éclairage architectural", ServiceOption.FIXED, "180.00"),
    ("Machine à fumée", ServiceOption.FIXED, "70.00"),
    ("Micro sans fil supplémentaire", ServiceOption.FIXED, "35.00"),
    ("Heure supplémentaire", ServiceOption.HOURLY, "95.00"),
)


class Command(BaseCommand):
    help = "Crée ou met à jour le catalogue de démonstration d'un déploiement vierge."

    def add_arguments(self, parser):
        parser.add_argument("--dry-run", action="store_true", help="Vérifie les données sans les enregistrer.")

    @transaction.atomic
    def handle(self, *args, **options):
        event_types = {}
        for name, requires_meeting in EVENT_TYPES:
            event_type, _ = EventType.objects.update_or_create(
                name=name,
                defaults={"requires_preparatory_meeting": requires_meeting},
            )
            event_types[name] = event_type

        for name in MUSIC_STYLES:
            MusicStyle.objects.get_or_create(name=name)

        for name, description, hours, price, compatible_types in PACKAGES:
            package, _ = Package.objects.update_or_create(
                name=name,
                defaults={
                    "description": description,
                    "included_hours": Decimal(hours),
                    "base_price": Decimal(price),
                    "is_active": True,
                },
            )
            package.event_types.set([event_types[event_type] for event_type in compatible_types])

        for name, price_type, price in OPTIONS:
            ServiceOption.objects.update_or_create(
                name=name,
                defaults={"price_type": price_type, "unit_price": Decimal(price), "is_active": True},
            )

        if options["dry_run"]:
            transaction.set_rollback(True)
            self.stdout.write(self.style.SUCCESS("Simulation réussie : le catalogue peut être créé."))
            return

        self.stdout.write(self.style.SUCCESS("Catalogue prêt : 6 formules actives, 4 types d'événements et 12 styles musicaux."))
