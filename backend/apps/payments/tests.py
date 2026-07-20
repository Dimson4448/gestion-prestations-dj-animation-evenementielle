from datetime import date, time, timedelta
from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import ClientProfile, DJProfile
from apps.bookings.models import Booking, Quote, Venue
from apps.catalog.models import EventType, Package

from .models import Invoice, Payment


@override_settings(
    STRIPE_SECRET_KEY="sk_test_beta",
    STRIPE_SUCCESS_URL="http://localhost:5173/?payment=success&session_id={CHECKOUT_SESSION_ID}",
    STRIPE_CANCEL_URL="http://localhost:5173/?payment=cancelled",
)
class DepositCheckoutTests(APITestCase):
    def setUp(self):
        user_model = get_user_model()
        self.client_user = user_model.objects.create_user(
            username="client_stripe",
            email="stripe@example.com",
            password="MotDePasseTest2026!",
        )
        self.client_profile = ClientProfile.objects.create(
            user=self.client_user,
            date_of_birth=date(1990, 1, 1),
            phone="+32470000001",
            billing_address="Rue du Test 1",
            billing_city="Bruxelles",
            billing_postal_code="1000",
        )
        dj_user = user_model.objects.create_user(username="dj_stripe", password="MotDePasseTest2026!")
        self.dj = DJProfile.objects.create(
            user=dj_user,
            stage_name="DJ Test Stripe",
            bio="DJ de test",
            base_hourly_rate="80.00",
        )
        self.event_type = EventType.objects.create(name="Mariage")
        self.package = Package.objects.create(
            name="Beta Stripe",
            description="Package de test",
            included_hours="6.0",
            base_price="600.00",
        )
        self.venue = Venue.objects.create(
            client=self.client_profile,
            name="Salle Beta",
            street="Rue du Test 2",
            postal_code="1000",
            city="Bruxelles",
            has_parking=True,
            distance_km_from_base="5.00",
        )
        event_date = date.today() + timedelta(days=30)
        self.quote = Quote.objects.create(
            client=self.client_profile,
            event_type=self.event_type,
            package=self.package,
            venue=self.venue,
            event_date=event_date,
            start_time=time(18, 0),
            duration_hours="6.0",
            guest_count=80,
            status=Quote.ACCEPTED,
            total_amount="600.00",
            deposit_amount="180.00",
        )
        self.booking = Booking.objects.create(
            quote=self.quote,
            client=self.client_profile,
            dj=self.dj,
            event_type=self.event_type,
            package=self.package,
            venue=self.venue,
            event_date=event_date,
            start_time=time(18, 0),
            end_time=time(23, 59),
            total_amount="600.00",
            deposit_required="180.00",
        )
        self.invoice = Invoice.objects.create(
            booking=self.booking,
            invoice_number="ACOMPTE-BETA-001",
            invoice_type=Invoice.DEPOSIT,
            amount="180.00",
            status=Invoice.SENT,
            due_at=timezone.now() + timedelta(days=7),
        )
        self.client.force_authenticate(self.client_user)

    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_cree_une_session_checkout_depuis_la_facture(self, create_session):
        create_session.return_value = SimpleNamespace(
            id="cs_test_beta_001",
            payment_intent=None,
            url="https://checkout.stripe.com/c/pay/cs_test_beta_001",
        )

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["session_id"], "cs_test_beta_001")
        payment = Payment.objects.get(stripe_session_id="cs_test_beta_001")
        self.assertEqual(payment.amount, Decimal("180.00"))
        self.assertEqual(payment.status, Payment.PENDING)
        stripe_parameters = create_session.call_args.kwargs
        self.assertEqual(stripe_parameters["line_items"][0]["price_data"]["unit_amount"], 18000)
        self.assertEqual(stripe_parameters["line_items"][0]["price_data"]["currency"], "eur")

    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_refuse_une_facture_deja_payee(self, create_session):
        self.invoice.status = Invoice.PAID
        self.invoice.save(update_fields=["status"])

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        create_session.assert_not_called()

    def test_refuse_un_visiteur_non_connecte(self):
        self.client.force_authenticate(user=None)

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertIn(response.status_code, [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_refuse_le_dj_associe_a_la_reservation(self, create_session):
        self.client.force_authenticate(self.dj.user)

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        create_session.assert_not_called()
