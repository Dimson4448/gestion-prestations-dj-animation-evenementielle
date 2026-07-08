from datetime import date

from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models


LANGUAGE_CHOICES = [
    ("fr", "Français"),
    ("en", "Anglais"),
    ("nl", "Néerlandais"),
]


def validate_adult(value):
    today = date.today()
    age = today.year - value.year - ((today.month, today.day) < (value.month, value.day))
    if age < 18:
        raise ValidationError("Le client doit être majeur.")


class ClientProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="client_profile",
        verbose_name="utilisateur",
    )
    preferred_language = models.CharField(
        "langue préférée",
        max_length=5,
        choices=LANGUAGE_CHOICES,
        default="fr",
    )
    date_of_birth = models.DateField("date de naissance", validators=[validate_adult])
    phone = models.CharField("téléphone", max_length=30)
    billing_address = models.CharField("adresse de facturation", max_length=255)
    billing_city = models.CharField("ville de facturation", max_length=80)
    billing_postal_code = models.CharField("code postal de facturation", max_length=20)
    created_at = models.DateTimeField("créé le", auto_now_add=True)

    class Meta:
        db_table = "client_profiles"
        verbose_name = "profil client"
        verbose_name_plural = "profils clients"
        indexes = [
            models.Index(fields=["billing_city"], name="idx_client_city"),
        ]

    def __str__(self):
        return self.user.get_full_name() or self.user.email


class DJProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="dj_profile",
        verbose_name="utilisateur",
    )
    stage_name = models.CharField("nom de scène", max_length=100, unique=True)
    bio = models.TextField("biographie")
    music_styles = models.ManyToManyField(
        "catalog.MusicStyle",
        blank=True,
        related_name="djs",
        verbose_name="styles musicaux",
    )
    base_hourly_rate = models.DecimalField("tarif horaire de base", max_digits=10, decimal_places=2)
    travel_rate_per_km = models.DecimalField("tarif de déplacement par km", max_digits=10, decimal_places=2, default=0.60)
    years_experience = models.PositiveSmallIntegerField("années d'expérience", default=1)
    is_available = models.BooleanField("disponible", default=True)

    class Meta:
        db_table = "dj_profiles"
        verbose_name = "profil DJ"
        verbose_name_plural = "profils DJ"
        indexes = [
            models.Index(fields=["is_available"], name="idx_dj_available"),
        ]
        constraints = [
            models.CheckConstraint(
                check=models.Q(base_hourly_rate__gte=0),
                name="dj_base_hourly_rate_positive",
            ),
            models.CheckConstraint(
                check=models.Q(travel_rate_per_km__gte=0),
                name="dj_travel_rate_positive",
            ),
        ]

    def __str__(self):
        return self.stage_name
