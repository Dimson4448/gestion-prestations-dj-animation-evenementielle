import logging

from django.conf import settings
from django.core.mail import send_mail
from django.db import transaction


logger = logging.getLogger(__name__)
SUPPORTED_LANGUAGES = {"fr", "en", "nl"}


def preferred_language(user):
    if user is None:
        return "fr"
    client = getattr(user, "client_profile", None)
    application = getattr(user, "dj_application", None)
    language = getattr(client, "preferred_language", None) or getattr(application, "preferred_language", None)
    return language if language in SUPPORTED_LANGUAGES else "fr"


def localized(values, language):
    return values.get(language) or values["fr"]


def send_user_email(user, subjects, messages, context=None, *, after_commit=True):
    if user is None or not user.email:
        return False
    language = preferred_language(user)
    context = context or {}
    subject = localized(subjects, language).format(**context)
    message = localized(messages, language).format(**context)

    def deliver():
        try:
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
                fail_silently=settings.EMAIL_FAIL_SILENTLY,
            )
        except Exception:
            logger.exception("Échec de l'envoi de l'e-mail %s à %s", subject, user.email)
            if not settings.EMAIL_FAIL_SILENTLY:
                raise

    if after_commit:
        transaction.on_commit(deliver)
    else:
        deliver()
    return True
