from datetime import date

from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import FileExtensionValidator
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
        raise ValidationError("Vous devez être majeur.")


def validate_application_file_size(value):
    if value.size > 5 * 1024 * 1024:
        raise ValidationError("Chaque justificatif doit peser au maximum 5 Mo.")


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


class AccountDeletionRequest(models.Model):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    CANCELLED = "cancelled"
    STATUS_CHOICES = [
        (PENDING, "En attente"),
        (APPROVED, "Approuvée"),
        (REJECTED, "Refusée"),
        (CANCELLED, "Annulée par le client"),
    ]

    client = models.ForeignKey(ClientProfile, on_delete=models.PROTECT, related_name="deletion_requests", verbose_name="client")
    reason = models.TextField("motif")
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=PENDING)
    review_message = models.TextField("réponse administrative", blank=True)
    requested_at = models.DateTimeField("demandée le", auto_now_add=True)
    reviewed_at = models.DateTimeField("traitée le", blank=True, null=True)
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="reviewed_account_deletion_requests",
        verbose_name="traitée par",
        blank=True,
        null=True,
    )

    class Meta:
        db_table = "account_deletion_requests"
        verbose_name = "demande de suppression de compte"
        verbose_name_plural = "demandes de suppression de compte"
        ordering = ["-requested_at"]

    def __str__(self):
        return f"Suppression #{self.pk} - {self.client}"


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


class DJApplication(models.Model):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    STATUS_CHOICES = [(PENDING, "En attente"), (APPROVED, "Approuvée"), (REJECTED, "Refusée")]

    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="dj_application", verbose_name="candidat")
    stage_name = models.CharField("nom de scène", max_length=100, unique=True)
    date_of_birth = models.DateField("date de naissance", validators=[validate_adult])
    phone = models.CharField("téléphone", max_length=30)
    city = models.CharField("ville", max_length=80)
    preferred_language = models.CharField("langue préférée", max_length=5, choices=LANGUAGE_CHOICES, default="fr")
    bio = models.TextField("présentation")
    music_styles = models.CharField("styles musicaux", max_length=255)
    base_hourly_rate = models.DecimalField("tarif horaire souhaité", max_digits=10, decimal_places=2)
    years_experience = models.PositiveSmallIntegerField("années d'expérience", default=1)
    identity_document = models.FileField(
        "pièce d'identité", upload_to="private/dj-applications/identity/%Y/%m/",
        validators=[FileExtensionValidator(["pdf", "jpg", "jpeg", "png"]), validate_application_file_size],
    )
    insurance_document = models.FileField(
        "assurance responsabilité civile", upload_to="private/dj-applications/insurance/%Y/%m/",
        validators=[FileExtensionValidator(["pdf", "jpg", "jpeg", "png"]), validate_application_file_size],
    )
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=PENDING)
    review_message = models.TextField("réponse administrative", blank=True)
    submitted_at = models.DateTimeField("envoyée le", auto_now_add=True)
    reviewed_at = models.DateTimeField("traitée le", blank=True, null=True)
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="reviewed_dj_applications",
        verbose_name="traitée par", blank=True, null=True,
    )

    class Meta:
        db_table = "dj_applications"
        verbose_name = "candidature DJ"
        verbose_name_plural = "candidatures DJ"
        ordering = ["-submitted_at"]
        constraints = [models.CheckConstraint(check=models.Q(base_hourly_rate__gte=0), name="dj_application_rate_positive")]

    def __str__(self):
        return f"{self.stage_name} — {self.get_status_display()}"
