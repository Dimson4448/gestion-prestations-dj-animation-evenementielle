import stripe
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from .models import Payment, Refund
from .services import confirm_checkout_payment, fail_checkout_payment, synchronize_refund_from_stripe


@csrf_exempt
@require_POST
def stripe_webhook(request):
    if not settings.STRIPE_WEBHOOK_SECRET:
        return JsonResponse({"detail": "Webhook Stripe non configuré."}, status=503)

    signature = request.headers.get("Stripe-Signature", "")
    try:
        event = stripe.Webhook.construct_event(
            request.body,
            signature,
            settings.STRIPE_WEBHOOK_SECRET,
        )
    except (ValueError, stripe.SignatureVerificationError):
        return JsonResponse({"detail": "Signature Stripe invalide."}, status=400)

    event_type = event["type"]
    stripe_object = event["data"]["object"]
    try:
        if event_type in {"checkout.session.completed", "checkout.session.async_payment_succeeded"}:
            confirm_checkout_payment(stripe_object)
        elif event_type in {"checkout.session.expired", "checkout.session.async_payment_failed"}:
            fail_checkout_payment(stripe_object["id"])
        elif event_type in {"refund.created", "refund.updated", "refund.failed"}:
            synchronize_refund_from_stripe(stripe_object)
    except Payment.DoesNotExist:
        return JsonResponse({"detail": "Paiement Stripe inconnu."}, status=404)
    except Refund.DoesNotExist:
        return JsonResponse({"detail": "Remboursement Stripe inconnu."}, status=404)
    except ValueError as exc:
        return JsonResponse({"detail": str(exc)}, status=400)

    return JsonResponse({"received": True})
