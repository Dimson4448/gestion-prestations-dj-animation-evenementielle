from decimal import Decimal, ROUND_HALF_UP

import stripe
from django.conf import settings
from django.db import transaction
from django.db.models import Sum
from django.utils import timezone

from .models import Invoice, Payment, Refund


class StripeConfigurationError(Exception):
    """La configuration Stripe requise n'est pas disponible."""


class StripeCheckoutError(Exception):
    """Stripe n'a pas pu créer la session Checkout."""


class StripeRefundError(Exception):
    """Stripe n'a pas pu créer le remboursement."""


def amount_to_cents(amount: Decimal) -> int:
    return int((amount * Decimal("100")).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def create_invoice_checkout(invoice: Invoice) -> tuple[Payment, str]:
    if not settings.STRIPE_SECRET_KEY or not settings.STRIPE_SECRET_KEY.startswith("sk_test_"):
        raise StripeConfigurationError("Une clé secrète Stripe de test est requise.")

    if invoice.invoice_type not in {Invoice.DEPOSIT, Invoice.BALANCE, Invoice.FULL}:
        raise ValueError("Ce type de facture ne peut pas être payé avec ce parcours.")
    if invoice.status != Invoice.SENT:
        raise ValueError("Seule une facture envoyée et non payée peut démarrer un paiement.")
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
                "payment_kind": invoice.invoice_type,
            },
            line_items=[
                {
                    "price_data": {
                        "currency": "eur",
                        "product_data": {
                            "name": f"{invoice.get_invoice_type_display()} Ultimate DJ — {invoice.invoice_number}",
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


create_deposit_checkout = create_invoice_checkout


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
    if invoice.invoice_type == Invoice.DEPOSIT:
        booking.deposit_paid = True
        if booking.status == booking.PREPARATORY_MEETING:
            booking.status = booking.CONFIRMED
            booking.save(update_fields=["deposit_paid", "status"])
        else:
            booking.save(update_fields=["deposit_paid"])
    elif invoice.invoice_type in {Invoice.BALANCE, Invoice.FULL}:
        booking.status = booking.PAID
        booking.save(update_fields=["status"])
    return True


@transaction.atomic
def fail_checkout_payment(session_id: str) -> bool:
    payment = Payment.objects.select_for_update().filter(stripe_session_id=session_id).first()
    if not payment or payment.status != Payment.PENDING:
        return False
    payment.status = Payment.FAILED
    payment.save(update_fields=["status"])
    return True


@transaction.atomic
def prepare_payment_refund(
    payment_id: int,
    amount: Decimal | None,
    reason: str,
    internal_reason: str,
) -> Refund:
    payment = Payment.objects.select_for_update().select_related("invoice").get(pk=payment_id)
    if payment.status not in {Payment.PAID, Payment.REFUNDED}:
        raise ValueError("Seul un paiement confirmé peut être remboursé.")
    if not payment.stripe_payment_intent_id:
        raise ValueError("Le paiement ne possède pas de PaymentIntent Stripe remboursable.")

    reserved_amount = payment.refunds.exclude(status__in=[Refund.FAILED, Refund.CANCELLED]).aggregate(
        total=Sum("amount"),
    )["total"] or Decimal("0.00")
    available_amount = payment.amount - reserved_amount
    refund_amount = amount if amount is not None else available_amount
    if refund_amount <= 0:
        raise ValueError("Aucun montant ne reste disponible pour ce remboursement.")
    if refund_amount > available_amount:
        raise ValueError(f"Le montant remboursable restant est de {available_amount:.2f} {payment.currency}.")

    return Refund.objects.create(
        payment=payment,
        amount=refund_amount,
        currency=payment.currency,
        reason=reason,
        internal_reason=internal_reason,
    )


def create_payment_refund(
    payment_id: int,
    amount: Decimal | None,
    reason: str,
    internal_reason: str,
) -> Refund:
    if not settings.STRIPE_SECRET_KEY or not settings.STRIPE_SECRET_KEY.startswith("sk_test_"):
        raise StripeConfigurationError("Une clé secrète Stripe de test est requise.")

    refund = prepare_payment_refund(payment_id, amount, reason, internal_reason)
    stripe.api_key = settings.STRIPE_SECRET_KEY
    try:
        stripe_refund = stripe.Refund.create(
            payment_intent=refund.payment.stripe_payment_intent_id,
            amount=amount_to_cents(refund.amount),
            reason=refund.reason,
            metadata={
                "refund_id": str(refund.pk),
                "payment_id": str(refund.payment_id),
                "booking_id": str(refund.payment.booking_id),
            },
            idempotency_key=str(refund.idempotency_key),
        )
    except stripe.StripeError as exc:
        Refund.objects.filter(pk=refund.pk).update(status=Refund.FAILED, processed_at=timezone.now())
        raise StripeRefundError("Le remboursement Stripe n'a pas pu être créé.") from exc

    stripe_status = getattr(stripe_refund, "status", None) or stripe_refund.get("status")
    local_status = {
        "succeeded": Refund.SUCCEEDED,
        "failed": Refund.FAILED,
        "canceled": Refund.CANCELLED,
    }.get(stripe_status, Refund.PENDING)
    refund.stripe_refund_id = getattr(stripe_refund, "id", None) or stripe_refund.get("id")
    refund.status = local_status
    if local_status != Refund.PENDING:
        refund.processed_at = timezone.now()
    refund.save(update_fields=["stripe_refund_id", "status", "processed_at"])

    if refund.status == Refund.SUCCEEDED:
        succeeded_amount = refund.payment.refunds.filter(status=Refund.SUCCEEDED).aggregate(total=Sum("amount"))["total"]
        if succeeded_amount >= refund.payment.amount:
            refund.payment.status = Payment.REFUNDED
            refund.payment.save(update_fields=["status"])
            refund.payment.invoice.status = Invoice.CANCELLED
            refund.payment.invoice.save(update_fields=["status"])
    return refund
