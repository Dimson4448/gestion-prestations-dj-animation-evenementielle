from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.db import transaction

from apps.accounts.emailing import localized, preferred_language

from .models import Refund


def _send_after_commit(subject, message, recipients):
    recipients = [email for email in recipients if email]
    if recipients:
        transaction.on_commit(
            lambda: send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, recipients, fail_silently=settings.EMAIL_FAIL_SILENTLY)
        )


def notify_payment_confirmed(payment):
    invoice = payment.invoice
    user = payment.booking.client.user
    language = preferred_language(user)
    context = {"amount": f"{payment.amount:.2f}", "currency": payment.currency, "invoice": invoice.invoice_number}
    subject = localized({"fr": "Ultimate DJ - paiement confirmé {invoice}", "en": "Ultimate DJ - payment confirmed {invoice}", "nl": "Ultimate DJ - betaling bevestigd {invoice}"}, language).format(**context)
    message = localized({
        "fr": "Votre paiement de {amount} {currency} pour la facture {invoice} a été confirmé par Stripe.\n\nLa facture mise à jour est disponible dans votre espace client.",
        "en": "Your payment of {amount} {currency} for invoice {invoice} has been confirmed by Stripe.\n\nThe updated invoice is available in your client area.",
        "nl": "Uw betaling van {amount} {currency} voor factuur {invoice} werd door Stripe bevestigd.\n\nDe bijgewerkte factuur is beschikbaar in uw klantenruimte.",
    }, language).format(**context)
    _send_after_commit(subject, message, [user.email])


def notify_refund_processed(refund):
    payment = refund.payment
    user = payment.booking.client.user
    language = preferred_language(user)
    context = {"amount": f"{refund.amount:.2f}", "currency": refund.currency, "invoice": payment.invoice.invoice_number}
    if refund.status == Refund.SUCCEEDED:
        subject = localized({"fr": "Ultimate DJ - remboursement confirmé {invoice}", "en": "Ultimate DJ - refund confirmed {invoice}", "nl": "Ultimate DJ - terugbetaling bevestigd {invoice}"}, language).format(**context)
        message = localized({
            "fr": "Votre remboursement de {amount} {currency} a été confirmé par Stripe.\n\nLe suivi financier est disponible dans votre espace client.",
            "en": "Your refund of {amount} {currency} has been confirmed by Stripe.\n\nThe financial status is available in your client area.",
            "nl": "Uw terugbetaling van {amount} {currency} werd door Stripe bevestigd.\n\nDe financiële opvolging is beschikbaar in uw klantenruimte.",
        }, language).format(**context)
        recipients = [user.email]
    elif refund.status == Refund.FAILED:
        subject = localized({"fr": "Ultimate DJ - remboursement à vérifier {invoice}", "en": "Ultimate DJ - refund requires attention {invoice}", "nl": "Ultimate DJ - terugbetaling te controleren {invoice}"}, language).format(**context)
        message = localized({
            "fr": "Le remboursement de {amount} {currency} n'a pas été confirmé par Stripe.\n\nL'administration a été prévenue.",
            "en": "The refund of {amount} {currency} was not confirmed by Stripe.\n\nThe administration has been notified.",
            "nl": "De terugbetaling van {amount} {currency} werd niet door Stripe bevestigd.\n\nDe administratie werd verwittigd.",
        }, language).format(**context)
        admin_emails = list(get_user_model().objects.filter(is_staff=True, is_active=True).exclude(email="").values_list("email", flat=True))
        recipients = [user.email, *admin_emails]
    else:
        return
    _send_after_commit(subject, message, recipients)
