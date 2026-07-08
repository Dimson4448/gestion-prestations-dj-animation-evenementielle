from django.db import models
from django.utils import timezone

from apps.accounts.models import DJProfile


class DJAvailability(models.Model):
    AVAILABLE = "available"
    RESERVED = "reserved"
    BLOCKED = "blocked"
    STATUS_CHOICES = [
        (AVAILABLE, "Disponible"),
        (RESERVED, "Réservé"),
        (BLOCKED, "Bloqué"),
    ]

    dj = models.ForeignKey(DJProfile, on_delete=models.CASCADE, related_name="availabilities", verbose_name="DJ")
    available_date = models.DateField("date disponible")
    start_time = models.TimeField("heure de début")
    end_time = models.TimeField("heure de fin")
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=AVAILABLE)
    reason = models.CharField("motif", max_length=255, blank=True)
    created_at = models.DateTimeField("créé le", default=timezone.now)

    class Meta:
        db_table = "dj_availabilities"
        verbose_name = "créneau DJ"
        verbose_name_plural = "créneaux DJ"
        constraints = [
            models.UniqueConstraint(fields=["dj", "available_date", "start_time"], name="unique_dj_availability_slot"),
            models.CheckConstraint(check=models.Q(end_time__gt=models.F("start_time")), name="availability_end_after_start"),
        ]
        indexes = [
            models.Index(fields=["available_date", "status"], name="idx_availability_search"),
        ]

    def __str__(self):
        return f"{self.dj} - {self.available_date} {self.start_time}"
