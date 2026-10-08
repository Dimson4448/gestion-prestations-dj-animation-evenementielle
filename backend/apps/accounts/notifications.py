from django.db import transaction

from .models import Notification


def create_notification_after_commit(user, title, message, notification_type=Notification.BOOKING, link="/compte"):
    """Enregistre une notification uniquement si la transaction métier est validée."""
    if not user or not user.pk:
        return
    transaction.on_commit(
        lambda: Notification.objects.create(
            user=user,
            title=title[:180],
            message=message,
            notification_type=notification_type,
            link=link[:120],
        )
    )
