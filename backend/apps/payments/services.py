from decimal import Decimal, ROUND_HALF_UP

import stripe
from django.conf import settings
from django.db import transaction
from django.utils import timezone

from .models import Invoice, Payment


class StripeConfigurationError(Exception):
    """La configuration Stripe requise n'est pas disponible."""


class StripeCheckoutError(Exception):
    """Stripe n'a pas pu créer la session Checkout."""


def amount_to_cents(amount: Decimal) -> int:
    return int((amount * Decimal("100")).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def create_deposit_checkout(invoice: Invoice) -> tuple[Payment, str]:
    if not settings.STRIPE_SECRET_KEY or not settings.STRIPE_SECRET_KEY.startswith("sk_test_"):
        raise StripeConfigurationError("Une clé secrète Stripe de test est requise.")

    if invoice.invoice_type != Invoice.DEPOSIT:
        raise ValueError("Seule une facture d'acompte peut être payée avec ce parcours.")
    if invoice.status == Invoice.PAID:
        raise ValueError("Cette facture est déjà payée.")
    if invoice.status == Invoice.CANCELLED:
        raise ValueError("Cette facture est annulée.")
    if invoice.amount <= 0:
        raise ValueError("Le montant de la facture doit être supérieur à zéro.")

    stripe.api_key = settings.STRIPE_SECRET_KEY
    try:
        session = stripe.checkout.Session.create(
            mode="payment",
            success_url=settings.STRIPE_SUCCESS_URL,
            cancel_url=settings.STRIPE_CANCEL_URL,
            client_reference_id=str(invoice.booking_id),
            customer_email=invoice.booking.client.user.email or None,
            metadata={
                "invoice_id": str(invoice.pk),
                "booking_id": str(invoice.booking_id),
                "payment_kind": "deposit",
            },
            line_items=[
                {
                    "price_data": {
                        "currency": "eur",
                        "product_data": {
                            "name": f"Acompte Ultimate DJ — {invoice.invoice_number}",
                        },
                        "unit_amount": amount_to_cents(invoice.amount),
                    },
                    "quantity": 1,
                }
            ],
            payment_intent_data={
                "metadata": {
                    "invoice_id": str(invoice.pk),
                    "booking_id": str(invoice.booking_id),
                }
            },
        )
    except stripe.StripeError as exc:
        raise StripeCheckoutError("La session de paiement n'a pas pu être créée.") from exc

    payment, _ = Payment.objects.update_or_create(
        stripe_session_id=session.id,
        defaults={
            "booking": invoice.booking,
            "invoice": invoice,
            "stripe_payment_intent_id": session.payment_intent or None,
            "amount": invoice.amount,
            "currency": "EUR",
            "status": Payment.PENDING,
        },
    )
    return payment, session.url


@transaction.atomic
def confirm_checkout_payment(session) -> bool:
    """Confirme un acompte une seule fois à partir d'une session Stripe vérifiée."""
    payment = (
        Payment.objects.select_for_update()
        .select_related("invoice", "booking")
        .get(stripe_session_id=session["id"])
    )

    if payment.status == Payment.PAID:
        return False

    expected_amount = amount_to_cents(payment.amount)
    received_amount = session.get("amount_total")
    received_currency = (session.get("currency") or "").upper()
    if session.get("payment_status") != "paid":
        raise ValueError("Stripe ne confirme pas le paiement de cette session.")
    if received_amount != expected_amount or received_currency != payment.currency:
        raise ValueError("Le montant ou la devise Stripe ne correspond pas au paiement attendu.")

    metadata = session.get("metadata") or {}
    if str(payment.invoice_id) != str(metadata.get("invoice_id")):
        raise ValueError("La facture Stripe ne correspond pas au paiement attendu.")

    payment.status = Payment.PAID
    payment.stripe_payment_intent_id = session.get("payment_intent") or payment.stripe_payment_intent_id
    payment.paid_at = timezone.now()
    payment.save(update_fields=["status", "stripe_payment_intent_id", "paid_at"])

    invoice = payment.invoice
    invoice.status = Invoice.PAID
    invoice.save(update_fields=["status"])

    booking = payment.booking
    booking.deposit_paid = True
    if booking.status == booking.PREPARATORY_MEETING:
        booking.status = booking.CONFIRMED
        booking.save(update_fields=["deposit_paid", "status"])
    else:
        booking.save(update_fields=["deposit_paid"])
    return True


@transaction.atomic
def fail_checkout_payment(session_id: str) -> bool:
    payment = Payment.objects.select_for_update().filter(stripe_session_id=session_id).first()
    if not payment or payment.status != Payment.PENDING:
        return False
    payment.status = Payment.FAILED
    payment.save(update_fields=["status"])
    return True
