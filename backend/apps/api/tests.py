from datetime import date

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import ClientProfile
from apps.bookings.models import Venue
from apps.catalog.models import Package


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
