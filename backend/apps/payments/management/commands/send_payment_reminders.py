from datetime import timedelta

from django.core.management.base import BaseCommand
from django.db.models import Q
from django.utils import timezone

from apps.accounts.emailing import send_user_email
from apps.accounts.models import Notification
from apps.accounts.notifications import create_notification_after_commit
from apps.payments.models import Invoice


class Command(BaseCommand):
    help = "Envoie les rappels de paiement aux factures bientôt échues ou échues."

    def add_arguments(self, parser):
        parser.add_argument("--days", type=int, default=3, help="Nombre de jours avant échéance à inclure.")
        parser.add_argument("--repeat-after-hours", type=int, default=24, help="Délai minimal entre deux rappels pour une même facture.")
        parser.add_argument("--dry-run", action="store_true", help="Liste les rappels sans les envoyer.")

    def handle(self, *args, **options):
        deadline = timezone.now() + timedelta(days=max(options["days"], 0))
        cooldown = timezone.now() - timedelta(hours=max(options["repeat_after_hours"], 1))
        invoices = Invoice.objects.select_related("booking__client__user").filter(
            status=Invoice.SENT,
            due_at__lte=deadline,
        ).filter(Q(last_payment_reminder_at__isnull=True) | Q(last_payment_reminder_at__lte=cooldown))
        count = 0
        for invoice in invoices:
            user = invoice.booking.client.user
            if options["dry_run"]:
                self.stdout.write(f"Rappel : {invoice.invoice_number} -> {user.email}")
                count += 1
                continue
            send_user_email(
                user,
                {"fr": "Ultimate DJ - rappel de paiement {invoice}", "en": "Ultimate DJ - payment reminder {invoice}", "nl": "Ultimate DJ - betalingsherinnering {invoice}"},
                {"fr": "La facture {invoice} de {amount} EUR arrive à échéance le {due}. Vous pouvez la régler depuis votre espace client.", "en": "Invoice {invoice} for {amount} EUR is due on {due}. You can pay it in your client area.", "nl": "Factuur {invoice} van {amount} EUR vervalt op {due}. U kunt ze betalen in uw klantenruimte."},
                {"invoice": invoice.invoice_number, "amount": f"{invoice.amount:.2f}", "due": invoice.due_at.strftime("%d/%m/%Y")},
                notification_type=Notification.PAYMENT,
            )
            create_notification_after_commit(user, "Ultimate DJ - paiement à échéance", f"La facture {invoice.invoice_number} arrive à échéance le {invoice.due_at:%d/%m/%Y}.", Notification.PAYMENT)
            invoice.last_payment_reminder_at = timezone.now()
            invoice.save(update_fields=["last_payment_reminder_at"])
            count += 1
        self.stdout.write(self.style.SUCCESS(f"{count} rappel(s) {'simulé(s)' if options['dry_run'] else 'envoyé(s)'}"))
