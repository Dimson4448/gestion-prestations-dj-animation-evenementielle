from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.db import transaction


def _send_after_commit(subject, message, recipients):
    recipients = [email for email in recipients if email]
    if not recipients:
        return
    transaction.on_commit(
        lambda: send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, recipients, fail_silently=True)
    )


def notify_cancellation_requested(cancellation_request):
    admin_emails = list(
        get_user_model().objects.filter(is_staff=True, is_active=True).exclude(email="").values_list("email", flat=True)
    )
    booking = cancellation_request.booking
    _send_after_commit(
        f"Ultimate DJ - demande d'annulation n°{cancellation_request.pk}",
        (
            f"Une demande d'annulation concerne la réservation n°{booking.pk} "
            f"du {booking.event_date:%d/%m/%Y}.\n\nMotif : {cancellation_request.reason}\n\n"
            "Connectez-vous à l'espace administrateur pour la traiter."
        ),
        admin_emails,
    )


def notify_cancellation_reviewed(cancellation_request):
    booking = cancellation_request.booking
    client_email = booking.client.user.email
    accepted = cancellation_request.status == cancellation_request.APPROVED
    decision = "acceptée" if accepted else "refusée"
    details = (
        f"Motif d'annulation enregistré : {booking.cancellation_reason}"
        if accepted
        else f"Réponse de l'administration : {cancellation_request.review_message}"
    )
    _send_after_commit(
        f"Ultimate DJ - demande d'annulation {decision}",
        (
            f"Votre demande concernant la réservation n°{booking.pk} du {booking.event_date:%d/%m/%Y} "
            f"a été {decision}.\n\n{details}\n\nVous pouvez consulter le dossier dans votre espace client."
        ),
        [client_email],
    )
