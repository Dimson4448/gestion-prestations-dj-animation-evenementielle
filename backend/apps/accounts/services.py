from django.db import transaction
from django.utils import timezone

from .models import DJApplication, DJProfile


class DJApplicationApprovalError(Exception):
    pass


@transaction.atomic
def approve_dj_application(application, reviewer):
    if application.status == DJApplication.REJECTED:
        raise DJApplicationApprovalError("Cette candidature a déjà été traitée.")
    if not application.user.is_active:
        raise DJApplicationApprovalError("Le candidat doit d’abord confirmer son adresse e-mail.")

    profile, _ = DJProfile.objects.get_or_create(
        user=application.user,
        defaults={
            "stage_name": application.stage_name,
            "bio": application.bio,
            "base_hourly_rate": application.base_hourly_rate,
            "years_experience": application.years_experience,
            "is_available": False,
        },
    )
    if application.status == DJApplication.PENDING:
        application.status = DJApplication.APPROVED
        application.review_message = application.review_message or "Candidature approuvée par l’administration Ultimate DJ."
        application.reviewed_at = timezone.now()
        application.reviewed_by = reviewer
        application.save(update_fields=["status", "review_message", "reviewed_at", "reviewed_by"])
    return profile
