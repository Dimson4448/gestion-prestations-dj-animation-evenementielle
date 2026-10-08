from django.db import transaction

from .models import Notification, NotificationPreference


def notification_is_enabled(user, notification_type):
    preference, _ = NotificationPreference.objects.get_or_create(user=user)
    if not preference.internal_enabled:
        return False
    return {
        Notification.BOOKING: preference.booking_enabled,
        Notification.PAYMENT: preference.payment_enabled,
        Notification.REVIEW: preference.review_enabled,
    }.get(notification_type, True)


def create_notification_after_commit(user, title, message, notification_type=Notification.BOOKING, link="/compte"):
    """Enregistre une notification uniquement si la transaction métier est validée."""
    if not user or not user.pk:
        return
    if not notification_is_enabled(user, notification_type):
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
