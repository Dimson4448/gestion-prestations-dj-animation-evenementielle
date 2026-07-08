from django.contrib import admin

from .models import Invoice, Payment


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
