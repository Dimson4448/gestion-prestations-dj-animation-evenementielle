from datetime import date

from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models


def validate_adult(value):
    today = date.today()
    age = today.year - value.year - ((today.month, today.day) < (value.month, value.day))
    if age < 18:
        raise ValidationError("Le client doit être majeur.")


class ClientProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="client_profile")
    preferred_language = models.CharField(max_length=5, choices=[("fr", "Français"), ("en", "Anglais"), ("nl", "Néerlandais")], default="fr")
    date_of_birth = models.DateField(validators=[validate_adult])
    phone = models.CharField(max_length=30)
    billing_address = models.CharField(max_length=255)
    billing_city = models.CharField(max_length=80)
    billing_postal_code = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "client_profiles"

    def __str__(self):
        return self.user.get_full_name() or self.user.email


class DJProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="dj_profile")
    stage_name = models.CharField(max_length=100, unique=True)
    bio = models.TextField()
    base_hourly_rate = models.DecimalField(max_digits=10, decimal_places=2)
    travel_rate_per_km = models.DecimalField(max_digits=10, decimal_places=2, default=0.60)
    years_experience = models.PositiveSmallIntegerField(default=1)
    is_available = models.BooleanField(default=True)

    class Meta:
        db_table = "dj_profiles"

    def __str__(self):
        return self.stage_name
