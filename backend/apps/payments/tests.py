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
    STRIPE_WEBHOOK_SECRET="whsec_beta",
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

    def create_pending_payment(self):
        return Payment.objects.create(
            booking=self.booking,
            invoice=self.invoice,
            stripe_session_id="cs_test_webhook_001",
            amount="180.00",
            currency="EUR",
        )

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

    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_refuse_une_facture_encore_en_brouillon(self, create_session):
        self.invoice.status = Invoice.DRAFT
        self.invoice.save(update_fields=["status"])

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        create_session.assert_not_called()

    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_cree_une_session_checkout_pour_une_facture_de_solde(self, create_session):
        self.invoice.invoice_type = Invoice.BALANCE
        self.invoice.invoice_number = "SOLDE-BETA-001"
        self.invoice.amount = "420.00"
        self.invoice.save(update_fields=["invoice_type", "invoice_number", "amount"])
        create_session.return_value = SimpleNamespace(
            id="cs_test_solde_001",
            payment_intent=None,
            url="https://checkout.stripe.com/c/pay/cs_test_solde_001",
        )

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        stripe_parameters = create_session.call_args.kwargs
        self.assertEqual(stripe_parameters["metadata"]["payment_kind"], Invoice.BALANCE)
        self.assertEqual(stripe_parameters["line_items"][0]["price_data"]["unit_amount"], 42000)

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

    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_un_autre_client_ne_peut_pas_acceder_a_la_facture(self, create_session):
        user_model = get_user_model()
        other_user = user_model.objects.create_user(username="autre_client", password="MotDePasseTest2026!")
        ClientProfile.objects.create(
            user=other_user,
            date_of_birth=date(1992, 2, 2),
            phone="+32470000002",
            billing_address="Rue Autre 3",
            billing_city="Liège",
            billing_postal_code="4000",
        )
        self.client.force_authenticate(other_user)

        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        create_session.assert_not_called()

    def test_interdit_la_creation_directe_d_un_paiement(self):
        response = self.client.post(
            "/api/v1/payments/",
            {
                "booking": self.booking.pk,
                "invoice": self.invoice.pk,
                "stripe_session_id": "cs_falsifie",
                "amount": "1.00",
                "currency": "EUR",
                "status": Payment.PAID,
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)
        self.assertFalse(Payment.objects.filter(stripe_session_id="cs_falsifie").exists())

    @override_settings(STRIPE_SECRET_KEY="sk_live_interdite")
    @patch("apps.payments.services.stripe.checkout.Session.create")
    def test_refuse_une_cle_stripe_live_pendant_la_beta(self, create_session):
        response = self.client.post(f"/api/v1/invoices/{self.invoice.pk}/checkout/")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        create_session.assert_not_called()

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_confirme_acompte_facture_et_reservation(self, construct_event):
        payment = self.create_pending_payment()
        construct_event.return_value = {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "id": payment.stripe_session_id,
                    "payment_status": "paid",
                    "payment_intent": "pi_test_beta_001",
                    "amount_total": 18000,
                    "currency": "eur",
                    "metadata": {"invoice_id": str(self.invoice.pk)},
                }
            },
        }
        self.client.force_authenticate(user=None)

        first_response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload brut Stripe",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )
        second_response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload brut Stripe",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(first_response.status_code, status.HTTP_200_OK)
        self.assertEqual(second_response.status_code, status.HTTP_200_OK)
        payment.refresh_from_db()
        self.invoice.refresh_from_db()
        self.booking.refresh_from_db()
        self.assertEqual(payment.status, Payment.PAID)
        self.assertEqual(payment.stripe_payment_intent_id, "pi_test_beta_001")
        self.assertIsNotNone(payment.paid_at)
        self.assertEqual(self.invoice.status, Invoice.PAID)
        self.assertTrue(self.booking.deposit_paid)
        self.assertEqual(self.booking.status, Booking.CONFIRMED)

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_confirme_le_solde_et_marque_la_reservation_payee(self, construct_event):
        self.invoice.invoice_type = Invoice.BALANCE
        self.invoice.invoice_number = "SOLDE-BETA-WEBHOOK"
        self.invoice.amount = "420.00"
        self.invoice.save(update_fields=["invoice_type", "invoice_number", "amount"])
        self.booking.deposit_paid = True
        self.booking.status = Booking.PERFORMED
        self.booking.save(update_fields=["deposit_paid", "status"])
        payment = self.create_pending_payment()
        payment.amount = self.invoice.amount
        payment.save(update_fields=["amount"])
        construct_event.return_value = {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "id": payment.stripe_session_id,
                    "payment_status": "paid",
                    "payment_intent": "pi_test_solde_001",
                    "amount_total": 42000,
                    "currency": "eur",
                    "metadata": {"invoice_id": str(self.invoice.pk)},
                }
            },
        }
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload solde Stripe",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.booking.refresh_from_db()
        self.invoice.refresh_from_db()
        self.assertEqual(self.booking.status, Booking.PAID)
        self.assertEqual(self.invoice.status, Invoice.PAID)

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_refuse_un_montant_incoherent(self, construct_event):
        payment = self.create_pending_payment()
        construct_event.return_value = {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "id": payment.stripe_session_id,
                    "payment_status": "paid",
                    "payment_intent": "pi_test_beta_bad_amount",
                    "amount_total": 100,
                    "currency": "eur",
                    "metadata": {"invoice_id": str(self.invoice.pk)},
                }
            },
        }
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload brut Stripe",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        payment.refresh_from_db()
        self.assertEqual(payment.status, Payment.PENDING)

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_refuse_une_signature_invalide(self, construct_event):
        import stripe

        construct_event.side_effect = stripe.SignatureVerificationError("Signature incorrecte", "signature_test")
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload falsifie",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    @override_settings(STRIPE_WEBHOOK_SECRET="")
    def test_webhook_refuse_de_fonctionner_sans_secret(self):
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_signale_une_session_inconnue(self, construct_event):
        construct_event.return_value = {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "id": "cs_test_inconnue",
                    "payment_status": "paid",
                    "amount_total": 18000,
                    "currency": "eur",
                    "metadata": {"invoice_id": str(self.invoice.pk)},
                }
            },
        }
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_marque_une_session_expiree_comme_echouee(self, construct_event):
        payment = self.create_pending_payment()
        construct_event.return_value = {
            "type": "checkout.session.expired",
            "data": {"object": {"id": payment.stripe_session_id}},
        }
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        payment.refresh_from_db()
        self.assertEqual(payment.status, Payment.FAILED)
        self.invoice.refresh_from_db()
        self.booking.refresh_from_db()
        self.assertNotEqual(self.invoice.status, Invoice.PAID)
        self.assertFalse(self.booking.deposit_paid)

    @patch("apps.payments.views.stripe.Webhook.construct_event")
    def test_webhook_refuse_des_metadonnees_de_facture_incorrectes(self, construct_event):
        payment = self.create_pending_payment()
        construct_event.return_value = {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "id": payment.stripe_session_id,
                    "payment_status": "paid",
                    "payment_intent": "pi_test_metadata_fausse",
                    "amount_total": 18000,
                    "currency": "eur",
                    "metadata": {"invoice_id": "999999"},
                }
            },
        }
        self.client.force_authenticate(user=None)

        response = self.client.post(
            "/api/v1/payments/webhook/",
            data=b"payload",
            content_type="application/json",
            HTTP_STRIPE_SIGNATURE="signature_test",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        payment.refresh_from_db()
        self.assertEqual(payment.status, Payment.PENDING)
