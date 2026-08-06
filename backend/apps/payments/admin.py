from django.contrib import admin

from .models import Invoice, Payment, Refund


@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = ("invoice_number", "booking", "invoice_type", "amount", "status", "issued_at", "due_at")
    search_fields = ("invoice_number",)
    list_filter = ("invoice_type", "status")


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ("booking", "invoice", "amount", "currency", "status", "paid_at")
    search_fields = ("stripe_session_id", "stripe_payment_intent_id")
    list_filter = ("status", "currency")


@admin.register(Refund)
class RefundAdmin(admin.ModelAdmin):
    list_display = ("payment", "amount", "currency", "reason", "status", "created_at", "processed_at")
    search_fields = ("stripe_refund_id", "idempotency_key", "payment__stripe_payment_intent_id")
    list_filter = ("status", "reason", "currency")
    readonly_fields = ("stripe_refund_id", "idempotency_key", "created_at", "processed_at")
