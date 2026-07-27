from datetime import date, timedelta

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import ClientProfile, DJProfile
from apps.availability.models import DJAvailability
from apps.bookings.models import Booking, Contract, Quote, Venue
from apps.catalog.models import EventType, Package
from apps.payments.models import Invoice
from apps.bookings.services import accept_quote


class ApiUltimateDJTests(APITestCase):
    def setUp(self):
        self.package = Package.objects.create(
            name="Formule Essentielle",
            description="Prestation DJ pour soirée privée.",
            included_hours=4,
            base_price=450,
            is_active=True,
        )
        user_model = get_user_model()
        self.client_user = user_model.objects.create_user(
            username="client_test",
            email="client@example.com",
            password="MotDePasseTest2026!",
            first_name="Client",
            last_name="Test",
        )
        self.client_profile = ClientProfile.objects.create(
            user=self.client_user,
            preferred_language="fr",
            date_of_birth=date(1990, 5, 14),
            phone="+32470000000",
            billing_address="Rue de la Musique 12",
            billing_city="Bruxelles",
            billing_postal_code="1000",
        )
        self.event_type = EventType.objects.create(name="Anniversaire adulte")
        self.venue = Venue.objects.create(
            client=self.client_profile,
            name="Salle du client",
            street="Rue de la Fête 10",
            postal_code="1000",
            city="Bruxelles",
            country="Belgique",
            has_parking=True,
            distance_km_from_base="12.50",
        )

    def quote_payload(self, **overrides):
        payload = {
            "event_type": self.event_type.pk,
            "package": self.package.pk,
            "venue": self.venue.pk,
            "event_date": str(date.today() + timedelta(days=30)),
            "start_time": "18:00:00",
            "duration_hours": "5.0",
            "guest_count": 60,
            "distance_km": "20.00",
            "parking_available": True,
            "music_preferences": "Disco, pop et chansons des années 90",
        }
        payload.update(overrides)
        return payload

    def create_available_dj(self):
        dj_user = get_user_model().objects.create_user(
            username="dj_acceptation",
            email="dj-acceptation@example.com",
            password="MotDePasseDJ2026!",
        )
        dj = DJProfile.objects.create(
            user=dj_user,
            stage_name="DJ Acceptation",
            bio="DJ disponible pour les tests du parcours devis.",
            base_hourly_rate="95.00",
            travel_rate_per_km="0.65",
            years_experience=8,
            is_available=True,
        )
        availability = DJAvailability.objects.create(
            dj=dj,
            available_date=date.today() + timedelta(days=30),
            start_time="17:00:00",
            end_time="23:59:00",
        )
        return dj, availability

    def create_contract_for_client(self):
        quote = Quote.objects.create(
            client=self.client_profile,
            event_type=self.event_type,
            package=self.package,
            venue=self.venue,
            event_date=date.today() + timedelta(days=30),
            start_time="18:00:00",
            duration_hours="5.0",
            guest_count=60,
            distance_km="20.00",
            parking_available=True,
            status=Quote.SENT,
            subtotal="545.00",
            travel_fee="13.00",
            total_amount="558.00",
            deposit_amount="167.40",
        )
        dj, _ = self.create_available_dj()
        _, contract, _ = accept_quote(quote.pk, dj.pk)
        return contract

    def test_liste_des_packages_publique_avec_liens(self):
        response = self.client.get("/api/v1/packages/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        premier_resultat = response.data["results"][0]
        self.assertEqual(premier_resultat["name"], "Formule Essentielle")
        self.assertIn("liens", premier_resultat)
        self.assertIn("ressource", premier_resultat["liens"])
        self.assertIn("calculer_devis", premier_resultat["liens"])

    def test_calcul_de_devis_informatif(self):
        response = self.client.post(
            "/api/v1/quotes/calculate/",
            {"package_id": self.package.id, "duration_hours": "5.0", "distance_km": "20.00"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["subtotal"], "545.00")
        self.assertEqual(response.data["travel_fee"], "13.00")
        self.assertEqual(response.data["total_amount"], "558.00")
        self.assertEqual(response.data["deposit_amount"], "167.40")
        self.assertEqual(response.data["currency"], "EUR")

    def test_lieux_proteges_pour_un_visiteur_non_connecte(self):
        response = self.client.get("/api/v1/venues/")

        self.assertIn(response.status_code, [status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN])

    def test_utilisateur_connecte_connait_son_role(self):
        self.client.force_authenticate(user=self.client_user)

        response = self.client.get("/api/v1/auth/me/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["role"], "client")
        self.assertFalse(response.data["is_staff"])

    def test_endpoint_utilisateur_refuse_un_visiteur(self):
        response = self.client.get("/api/v1/auth/me/")

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_creation_lieu_associe_au_client_connecte(self):
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(
            "/api/v1/venues/",
            {
                "name": "Salle Harmonie",
                "street": "Avenue des Fêtes 20",
                "postal_code": "1050",
                "city": "Ixelles",
                "country": "Belgique",
                "has_parking": True,
                "distance_km_from_base": "12.50",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        venue = Venue.objects.get(pk=response.data["id"])
        self.assertEqual(venue.client, self.client_profile)
        self.assertIn("liens", response.data)

    def test_creation_devis_calculee_et_associee_au_client(self):
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        quote = Quote.objects.get(pk=response.data["id"])
        self.assertEqual(quote.client, self.client_profile)
        self.assertEqual(quote.status, Quote.DRAFT)
        self.assertEqual(response.data["subtotal"], "545.00")
        self.assertEqual(response.data["travel_fee"], "13.00")
        self.assertEqual(response.data["total_amount"], "558.00")
        self.assertEqual(response.data["deposit_amount"], "167.40")
        self.assertEqual(quote.music_preferences, "Disco, pop et chansons des années 90")

    def test_client_ne_peut_pas_choisir_un_statut_de_devis(self):
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(
            "/api/v1/quotes/",
            self.quote_payload(status=Quote.ACCEPTED),
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("status", response.data)

    def test_client_ne_peut_pas_utiliser_le_lieu_d_un_autre_client(self):
        user_model = get_user_model()
        other_user = user_model.objects.create_user(username="autre_lieu", password="MotDePasseTest2026!")
        other_profile = ClientProfile.objects.create(
            user=other_user,
            date_of_birth=date(1991, 1, 1),
            phone="+32471111111",
            billing_address="Rue Autre 1",
            billing_city="Namur",
            billing_postal_code="5000",
        )
        other_venue = Venue.objects.create(
            client=other_profile,
            name="Salle interdite",
            street="Rue Autre 2",
            postal_code="5000",
            city="Namur",
            distance_km_from_base="50.00",
        )
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(
            "/api/v1/quotes/",
            self.quote_payload(venue=other_venue.pk),
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("venue", response.data)

    def test_client_ne_peut_pas_modifier_un_devis_soumis(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")

        response = self.client.patch(
            f"/api/v1/quotes/{created.data['id']}/",
            {"guest_count": 200},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_refuse_un_devis_dans_le_passe(self):
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(
            "/api/v1/quotes/",
            self.quote_payload(event_date=str(date.today() - timedelta(days=1))),
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("event_date", response.data)

    def test_liste_devis_limitee_au_client_connecte(self):
        self.client.force_authenticate(user=self.client_user)
        own_quote = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")

        user_model = get_user_model()
        other_user = user_model.objects.create_user(username="client_devis_2", password="MotDePasseTest2026!")
        other_profile = ClientProfile.objects.create(
            user=other_user,
            date_of_birth=date(1993, 3, 3),
            phone="+32472222222",
            billing_address="Rue du Second Client 1",
            billing_city="Mons",
            billing_postal_code="7000",
        )
        other_venue = Venue.objects.create(
            client=other_profile,
            name="Salle du second client",
            street="Rue du Second Client 2",
            postal_code="7000",
            city="Mons",
            distance_km_from_base="60.00",
        )
        self.client.force_authenticate(user=other_user)
        other_quote = self.client.post(
            "/api/v1/quotes/",
            self.quote_payload(venue=other_venue.pk),
            format="json",
        )

        self.client.force_authenticate(user=self.client_user)
        response = self.client.get("/api/v1/quotes/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        quote_ids = {item["id"] for item in response.data["results"]}
        self.assertIn(own_quote.data["id"], quote_ids)
        self.assertNotIn(other_quote.data["id"], quote_ids)

    def test_administrateur_peut_mettre_a_jour_le_statut_du_devis(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")
        admin = get_user_model().objects.create_superuser(
            username="admin_devis",
            email="admin-devis@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)

        response = self.client.patch(
            f"/api/v1/quotes/{created.data['id']}/",
            {"status": Quote.SENT},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], Quote.SENT)

    def test_administrateur_accepte_un_devis_et_cree_le_dossier_complet(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")
        quote = Quote.objects.get(pk=created.data["id"])
        quote.status = Quote.SENT
        quote.save(update_fields=["status"])
        dj, availability = self.create_available_dj()
        admin = get_user_model().objects.create_superuser(
            username="admin_acceptation",
            email="admin-acceptation@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)

        response = self.client.post(f"/api/v1/quotes/{quote.pk}/accept/", {"dj": dj.pk}, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        quote.refresh_from_db()
        availability.refresh_from_db()
        booking = Booking.objects.get(quote=quote)
        self.assertEqual(quote.status, Quote.ACCEPTED)
        self.assertEqual(booking.dj, dj)
        self.assertEqual(booking.end_time.strftime("%H:%M:%S"), "23:00:00")
        self.assertEqual(availability.status, DJAvailability.RESERVED)
        self.assertTrue(Contract.objects.filter(booking=booking, status=Contract.SENT).exists())
        self.assertTrue(
            Invoice.objects.filter(
                booking=booking,
                invoice_type=Invoice.DEPOSIT,
                status=Invoice.SENT,
                amount=quote.deposit_amount,
            ).exists()
        )
        self.assertIn("booking", response.data)
        self.assertIn("contract", response.data)
        self.assertIn("deposit_invoice", response.data)

    def test_client_ne_peut_pas_accepter_lui_meme_un_devis(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")
        quote = Quote.objects.get(pk=created.data["id"])
        quote.status = Quote.SENT
        quote.save(update_fields=["status"])
        dj, _ = self.create_available_dj()

        response = self.client.post(f"/api/v1/quotes/{quote.pk}/accept/", {"dj": dj.pk}, format="json")

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(Booking.objects.filter(quote=quote).exists())

    def test_acceptation_refusee_sans_creneau_ne_cree_aucune_donnee(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")
        quote = Quote.objects.get(pk=created.data["id"])
        quote.status = Quote.SENT
        quote.save(update_fields=["status"])
        dj, availability = self.create_available_dj()
        availability.end_time = "20:00:00"
        availability.save(update_fields=["end_time"])
        admin = get_user_model().objects.create_superuser(
            username="admin_sans_creneau",
            email="admin-sans-creneau@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)

        response = self.client.post(f"/api/v1/quotes/{quote.pk}/accept/", {"dj": dj.pk}, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        quote.refresh_from_db()
        self.assertEqual(quote.status, Quote.SENT)
        self.assertFalse(Booking.objects.filter(quote=quote).exists())
        self.assertEqual(Contract.objects.count(), 0)
        self.assertEqual(Invoice.objects.count(), 0)

    def test_un_devis_accepte_ne_peut_pas_etre_converti_deux_fois(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post("/api/v1/quotes/", self.quote_payload(), format="json")
        quote = Quote.objects.get(pk=created.data["id"])
        quote.status = Quote.SENT
        quote.save(update_fields=["status"])
        dj, _ = self.create_available_dj()
        admin = get_user_model().objects.create_superuser(
            username="admin_doublon",
            email="admin-doublon@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)

        first = self.client.post(f"/api/v1/quotes/{quote.pk}/accept/", {"dj": dj.pk}, format="json")
        second = self.client.post(f"/api/v1/quotes/{quote.pk}/accept/", {"dj": dj.pk}, format="json")

        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Booking.objects.filter(quote=quote).count(), 1)
        self.assertEqual(Contract.objects.count(), 1)
        self.assertEqual(Invoice.objects.count(), 1)

    def test_client_peut_signer_son_contrat_envoye(self):
        contract = self.create_contract_for_client()
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(f"/api/v1/contracts/{contract.pk}/sign/", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        contract.refresh_from_db()
        self.assertEqual(contract.status, Contract.SIGNED)
        self.assertIsNotNone(contract.signed_by_client_at)

    def test_contrat_ne_peut_pas_etre_signe_deux_fois(self):
        contract = self.create_contract_for_client()
        self.client.force_authenticate(user=self.client_user)

        first = self.client.post(f"/api/v1/contracts/{contract.pk}/sign/", {}, format="json")
        second = self.client.post(f"/api/v1/contracts/{contract.pk}/sign/", {}, format="json")

        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)

    def test_autre_client_ne_peut_pas_signer_le_contrat(self):
        contract = self.create_contract_for_client()
        other_user = get_user_model().objects.create_user(
            username="client_contrat_interdit",
            password="MotDePasseTest2026!",
        )
        ClientProfile.objects.create(
            user=other_user,
            date_of_birth=date(1992, 2, 2),
            phone="+32473333333",
            billing_address="Rue Interdite 3",
            billing_city="Liège",
            billing_postal_code="4000",
        )
        self.client.force_authenticate(user=other_user)

        response = self.client.post(f"/api/v1/contracts/{contract.pk}/sign/", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        contract.refresh_from_db()
        self.assertEqual(contract.status, Contract.SENT)
        self.assertIsNone(contract.signed_by_client_at)

    def test_client_telecharge_son_contrat_et_sa_facture_en_pdf(self):
        contract = self.create_contract_for_client()
        invoice = contract.booking.invoices.get(invoice_type=Invoice.DEPOSIT)
        self.client.force_authenticate(user=self.client_user)

        contract_response = self.client.get(f"/api/v1/contracts/{contract.pk}/pdf/")
        invoice_response = self.client.get(f"/api/v1/invoices/{invoice.pk}/pdf/")

        self.assertEqual(contract_response.status_code, status.HTTP_200_OK)
        self.assertEqual(invoice_response.status_code, status.HTTP_200_OK)
        self.assertEqual(contract_response["Content-Type"], "application/pdf")
        self.assertEqual(invoice_response["Content-Type"], "application/pdf")
        self.assertTrue(contract_response.content.startswith(b"%PDF-"))
        self.assertTrue(invoice_response.content.startswith(b"%PDF-"))
        self.assertGreater(len(contract_response.content), 2000)
        self.assertGreater(len(invoice_response.content), 2000)
        self.assertIn(contract.contract_number, contract_response["Content-Disposition"])
        self.assertIn(invoice.invoice_number, invoice_response["Content-Disposition"])
