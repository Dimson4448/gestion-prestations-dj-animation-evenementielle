import logging

import stripe
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from .models import Payment, Refund
from .services import confirm_checkout_payment, fail_checkout_payment, synchronize_refund_from_stripe


logger = logging.getLogger(__name__)


@csrf_exempt
@require_POST
def stripe_webhook(request):
    if not settings.STRIPE_WEBHOOK_SECRET:
        logger.error("stripe_webhook_unconfigured")
        return JsonResponse({"detail": "Webhook Stripe non configuré."}, status=503)

    signature = request.headers.get("Stripe-Signature", "")
    try:
        event = stripe.Webhook.construct_event(
            request.body,
            signature,
            settings.STRIPE_WEBHOOK_SECRET,
        )
    except (ValueError, stripe.SignatureVerificationError):
        logger.warning("stripe_webhook_invalid_signature")
        return JsonResponse({"detail": "Signature Stripe invalide."}, status=400)

    event_type = event["type"]
    stripe_object = event["data"]["object"]
    logger.info("stripe_webhook_received type=%s id=%s", event_type, event.get("id", "unknown"))
    try:
        if event_type in {"checkout.session.completed", "checkout.session.async_payment_succeeded"}:
            confirm_checkout_payment(stripe_object)
        elif event_type in {"checkout.session.expired", "checkout.session.async_payment_failed"}:
            fail_checkout_payment(stripe_object["id"])
        elif event_type in {"refund.created", "refund.updated", "refund.failed"}:
            synchronize_refund_from_stripe(stripe_object)
    except Payment.DoesNotExist:
        logger.error("stripe_webhook_unknown_payment type=%s", event_type)
        return JsonResponse({"detail": "Paiement Stripe inconnu."}, status=404)
    except Refund.DoesNotExist:
        logger.error("stripe_webhook_unknown_refund type=%s", event_type)
        return JsonResponse({"detail": "Remboursement Stripe inconnu."}, status=404)
    except ValueError as exc:
        logger.warning("stripe_webhook_rejected type=%s reason=%s", event_type, exc)
        return JsonResponse({"detail": str(exc)}, status=400)

    return JsonResponse({"received": True})
