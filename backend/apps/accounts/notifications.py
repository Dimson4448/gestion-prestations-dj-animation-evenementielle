from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.db import transaction

from .emailing import localized, preferred_language
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


def notify_administrators_after_commit(subjects, messages, context=None, notification_type=Notification.BOOKING, link="/administration"):
    """Alerte les administrateurs sans leur transmettre l'accès au dossier personnel."""
    administrators = list(get_user_model().objects.filter(is_staff=True, is_active=True))
    context = context or {}
    for administrator in administrators:
        language = preferred_language(administrator)
        subject = localized(subjects, language).format(**context)
        message = localized(messages, language).format(**context)
        transaction.on_commit(
            lambda administrator=administrator, subject=subject, message=message: Notification.objects.create(
                user=administrator,
                title=subject[:180],
                message=message,
                notification_type=notification_type,
                link=link[:120],
            )
        )
    recipients = list(settings.ADMIN_NOTIFICATION_EMAILS) or [email for email in [settings.BUSINESS_EMAIL] if email]
    if recipients:
        subject = localized(subjects, "fr").format(**context)
        message = localized(messages, "fr").format(**context)
        transaction.on_commit(
            lambda: send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, recipients, fail_silently=settings.EMAIL_FAIL_SILENTLY)
        )
