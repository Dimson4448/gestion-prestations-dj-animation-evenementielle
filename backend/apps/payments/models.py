from django.db import models

from apps.bookings.models import Booking


class Invoice(models.Model):
    DEPOSIT = "deposit"
    BALANCE = "balance"
    FULL = "full"
    TYPE_CHOICES = [
        (DEPOSIT, "Acompte"),
        (BALANCE, "Solde"),
        (FULL, "Facture complète"),
    ]

    DRAFT = "draft"
    SENT = "sent"
    PAID = "paid"
    CANCELLED = "cancelled"
    STATUS_CHOICES = [
        (DRAFT, "Brouillon"),
        (SENT, "Envoyée"),
        (PAID, "Payée"),
        (CANCELLED, "Annulée"),
    ]

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name="invoices", verbose_name="réservation")
    invoice_number = models.CharField("numéro de facture", max_length=40, unique=True)
    invoice_type = models.CharField("type de facture", max_length=20, choices=TYPE_CHOICES)
    amount = models.DecimalField("montant", max_digits=10, decimal_places=2)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=DRAFT)
    issued_at = models.DateTimeField("émise le", auto_now_add=True)
    due_at = models.DateTimeField("échéance")

    class Meta:
        db_table = "invoices"
        verbose_name = "facture"
        verbose_name_plural = "factures"
        indexes = [
            models.Index(fields=["status"], name="idx_invoice_status"),
        ]
        constraints = [
            models.CheckConstraint(check=models.Q(amount__gte=0), name="invoice_amount_positive"),
        ]

    def __str__(self):
        return self.invoice_number


class Payment(models.Model):
    PENDING = "pending"
    PAID = "paid"
    FAILED = "failed"
    REFUNDED = "refunded"
    STATUS_CHOICES = [
        (PENDING, "En attente"),
        (PAID, "Payé"),
        (FAILED, "Échoué"),
        (REFUNDED, "Remboursé"),
    ]

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name="payments", verbose_name="réservation")
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE, related_name="payments", verbose_name="facture")
    stripe_session_id = models.CharField("identifiant de session Stripe", max_length=190, unique=True)
    stripe_payment_intent_id = models.CharField("identifiant d'intention de paiement Stripe", max_length=190, unique=True)
    amount = models.DecimalField("montant", max_digits=10, decimal_places=2)
    currency = models.CharField("devise", max_length=3, default="EUR")
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=PENDING)
    paid_at = models.DateTimeField("payé le", null=True, blank=True)

    class Meta:
        db_table = "payments"
        verbose_name = "paiement"
        verbose_name_plural = "paiements"
        constraints = [
            models.CheckConstraint(check=models.Q(amount__gte=0), name="payment_amount_positive"),
        ]
