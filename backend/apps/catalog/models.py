from django.core.exceptions import ValidationError
from django.db import models


class EventType(models.Model):
    CHILD_BIRTHDAY = "Anniversaire enfant"
    ADULT_BIRTHDAY = "Anniversaire adulte"
    WEDDING = "Mariage"
    PRIVATE_PARTY = "Soirée privée"
    ALLOWED_NAMES = (CHILD_BIRTHDAY, ADULT_BIRTHDAY, WEDDING, PRIVATE_PARTY)

    name = models.CharField("nom", max_length=80, unique=True)
    requires_preparatory_meeting = models.BooleanField("rendez-vous préparatoire requis", default=False)

    class Meta:
        db_table = "event_types"
        verbose_name = "type d'événement"
        verbose_name_plural = "types d'événements"

    def __str__(self):
        return self.name

    def clean(self):
        super().clean()
        if self.name not in self.ALLOWED_NAMES:
            raise ValidationError({"name": "Ce type de prestation ne fait pas partie du cahier des charges."})


class MusicStyle(models.Model):
    name = models.CharField("nom", max_length=80, unique=True)

    class Meta:
        db_table = "music_styles"
        verbose_name = "style musical"
        verbose_name_plural = "styles musicaux"

    def __str__(self):
        return self.name


class Package(models.Model):
    name = models.CharField("nom", max_length=100, unique=True)
    description = models.CharField("description", max_length=255)
    included_hours = models.DecimalField("heures incluses", max_digits=4, decimal_places=1)
    base_price = models.DecimalField("prix de base", max_digits=10, decimal_places=2)
    is_active = models.BooleanField("actif", default=True)

    class Meta:
        db_table = "packages"
        verbose_name = "package"
        verbose_name_plural = "packages"
        constraints = [
            models.CheckConstraint(check=models.Q(base_price__gte=0), name="package_base_price_positive"),
            models.CheckConstraint(check=models.Q(included_hours__gt=0), name="package_included_hours_positive"),
        ]

    def __str__(self):
        return self.name


class ServiceOption(models.Model):
    FIXED = "fixed"
    HOURLY = "hourly"
    PRICE_TYPE_CHOICES = [
        (FIXED, "Forfait"),
        (HOURLY, "Horaire"),
    ]

    name = models.CharField("nom", max_length=100, unique=True)
    price_type = models.CharField("type de prix", max_length=20, choices=PRICE_TYPE_CHOICES, default=FIXED)
    unit_price = models.DecimalField("prix unitaire", max_digits=10, decimal_places=2)
    is_active = models.BooleanField("actif", default=True)

    class Meta:
        db_table = "service_options"
        verbose_name = "option de service"
        verbose_name_plural = "options de service"
        constraints = [
            models.CheckConstraint(check=models.Q(unit_price__gte=0), name="service_option_unit_price_positive"),
        ]

    def __str__(self):
        return self.name


class Equipment(models.Model):
    AVAILABLE = "available"
    MAINTENANCE = "maintenance"
    RESERVED = "reserved"
    STATUS_CHOICES = [
        (AVAILABLE, "Disponible"),
        (MAINTENANCE, "En maintenance"),
        (RESERVED, "Réservé"),
    ]

    category = models.CharField("catégorie", max_length=60)
    name = models.CharField("nom", max_length=120)
    serial_number = models.CharField("numéro de série", max_length=80, unique=True)
    daily_cost = models.DecimalField("coût journalier", max_digits=10, decimal_places=2)
    replacement_value = models.DecimalField("valeur de remplacement", max_digits=10, decimal_places=2)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=AVAILABLE)

    class Meta:
        db_table = "equipment"
        verbose_name = "matériel"
        verbose_name_plural = "matériel"
        indexes = [
            models.Index(fields=["category", "status"], name="idx_equipment_category_status"),
        ]
        constraints = [
            models.CheckConstraint(check=models.Q(daily_cost__gte=0), name="equipment_daily_cost_positive"),
            models.CheckConstraint(check=models.Q(replacement_value__gte=0), name="equipment_replacement_value_positive"),
        ]

    def __str__(self):
        return f"{self.name} ({self.serial_number})"
