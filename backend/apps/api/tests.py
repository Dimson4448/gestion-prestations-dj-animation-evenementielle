from datetime import date, timedelta

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import ClientProfile
from apps.bookings.models import Quote, Venue
from apps.catalog.models import EventType, Package


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
