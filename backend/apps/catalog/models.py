from django.db import models


class EventType(models.Model):
    name = models.CharField(max_length=80, unique=True)
    requires_preparatory_meeting = models.BooleanField(default=False)

    class Meta:
        db_table = "event_types"

    def __str__(self):
        return self.name


class MusicStyle(models.Model):
    name = models.CharField(max_length=80, unique=True)

    class Meta:
        db_table = "music_styles"

    def __str__(self):
        return self.name


class Package(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.CharField(max_length=255)
    included_hours = models.DecimalField(max_digits=4, decimal_places=1)
    base_price = models.DecimalField(max_digits=10, decimal_places=2)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "packages"

    def __str__(self):
        return self.name


class ServiceOption(models.Model):
    FIXED = "fixed"
    HOURLY = "hourly"
    PRICE_TYPE_CHOICES = [(FIXED, "Forfait"), (HOURLY, "Horaire")]

    name = models.CharField(max_length=100, unique=True)
    price_type = models.CharField(max_length=20, choices=PRICE_TYPE_CHOICES, default=FIXED)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "service_options"

    def __str__(self):
        return self.name
