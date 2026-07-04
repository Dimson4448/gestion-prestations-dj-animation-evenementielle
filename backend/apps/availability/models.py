from django.db import models

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

    dj = models.ForeignKey(DJProfile, on_delete=models.CASCADE, related_name="availabilities")
    available_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=AVAILABLE)

    class Meta:
        db_table = "dj_availabilities"
        constraints = [
            models.UniqueConstraint(fields=["dj", "available_date", "start_time"], name="unique_dj_availability_slot"),
            models.CheckConstraint(check=models.Q(end_time__gt=models.F("start_time")), name="availability_end_after_start"),
        ]
        indexes = [
            models.Index(fields=["available_date", "status"]),
        ]

    def __str__(self):
        return f"{self.dj} - {self.available_date} {self.start_time}"
