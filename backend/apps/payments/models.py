from django.db import models

from apps.bookings.models import Booking


class Invoice(models.Model):
    DEPOSIT = "deposit"
    BALANCE = "balance"
    FULL = "full"
    TYPE_CHOICES = [(DEPOSIT, "Acompte"), (BALANCE, "Solde"), (FULL, "Facture complète")]

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name="invoices")
    invoice_number = models.CharField(max_length=40, unique=True)
    invoice_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, default="draft")
    issued_at = models.DateTimeField(auto_now_add=True)
    due_at = models.DateTimeField()

    class Meta:
        db_table = "invoices"

    def __str__(self):
        return self.invoice_number


class Payment(models.Model):
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name="payments")
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE, related_name="payments")
    stripe_session_id = models.CharField(max_length=190, unique=True)
    stripe_payment_intent_id = models.CharField(max_length=190, unique=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default="EUR")
    status = models.CharField(max_length=20, default="pending")
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "payments"
