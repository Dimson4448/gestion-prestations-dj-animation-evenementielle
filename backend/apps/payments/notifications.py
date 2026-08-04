from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.db import transaction

from .models import Refund


def _send_after_commit(subject, message, recipients):
    recipients = [email for email in recipients if email]
    if recipients:
        transaction.on_commit(
            lambda: send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, recipients, fail_silently=True)
        )


def notify_payment_confirmed(payment):
    invoice = payment.invoice
    _send_after_commit(
        f"Ultimate DJ - paiement confirmé {invoice.invoice_number}",
        (
            f"Votre paiement de {payment.amount:.2f} {payment.currency} pour la facture "
            f"{invoice.invoice_number} a été confirmé par Stripe.\n\n"
            "La facture mise à jour est disponible dans votre espace client."
        ),
        [payment.booking.client.user.email],
    )


def notify_refund_processed(refund):
    payment = refund.payment
    client_email = payment.booking.client.user.email
    if refund.status == Refund.SUCCEEDED:
        subject = f"Ultimate DJ - remboursement confirmé {payment.invoice.invoice_number}"
        message = (
            f"Votre remboursement de {refund.amount:.2f} {refund.currency} a été confirmé par Stripe.\n\n"
            "Le suivi financier et la facture actualisée sont disponibles dans votre espace client."
        )
        recipients = [client_email]
    elif refund.status == Refund.FAILED:
        subject = f"Ultimate DJ - remboursement à vérifier {payment.invoice.invoice_number}"
        message = (
            f"Le remboursement de {refund.amount:.2f} {refund.currency} n'a pas été confirmé par Stripe.\n\n"
            "L'administration a été prévenue et doit vérifier l'opération avant l'annulation du dossier."
        )
        admin_emails = list(
            get_user_model().objects.filter(is_staff=True, is_active=True).exclude(email="").values_list("email", flat=True)
        )
        recipients = [client_email, *admin_emails]
    else:
        return
    _send_after_commit(subject, message, recipients)
