from datetime import date, timedelta
from urllib.parse import parse_qs, urlparse
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.core import mail
from django.test import override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import AccountDeletionRequest, ClientProfile, DJProfile
from apps.availability.models import DJAvailability
from apps.bookings.models import Booking, CancellationRequest, Contract, Playlist, PlaylistSong, PreparatoryAppointment, Quote, Review, Venue
from apps.catalog.models import EventType, MusicStyle, Package
from apps.payments.models import Invoice, Payment, Refund
from apps.bookings.services import accept_quote


class ApiUltimateDJTests(APITestCase):
    def setUp(self):
        cache.clear()
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

    def test_renouvelle_la_session_jwt_et_accede_au_profil(self):
        authenticated = self.client.post(
            "/api/v1/auth/token/",
            {"username": self.client_user.username, "password": "MotDePasseTest2026!"},
            format="json",
        )
        self.assertEqual(authenticated.status_code, status.HTTP_200_OK)

        refreshed = self.client.post(
            "/api/v1/auth/token/refresh/",
            {"refresh": authenticated.data["refresh"]},
            format="json",
        )
        self.assertEqual(refreshed.status_code, status.HTTP_200_OK)
        self.assertTrue(refreshed.data["access"])
        self.assertTrue(refreshed.data["refresh"])

        old_refresh_rejected = self.client.post(
            "/api/v1/auth/token/refresh/",
            {"refresh": authenticated.data["refresh"]},
            format="json",
        )
        self.assertEqual(old_refresh_rejected.status_code, status.HTTP_401_UNAUTHORIZED)

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {refreshed.data['access']}")
        profile = self.client.get("/api/v1/auth/me/")
        self.assertEqual(profile.status_code, status.HTTP_200_OK)
        self.assertEqual(profile.data["email"], self.client_user.email)

        logout = self.client.post(
            "/api/v1/auth/logout/",
            {"refresh": refreshed.data["refresh"]},
            format="json",
        )
        self.assertEqual(logout.status_code, status.HTTP_204_NO_CONTENT)
        revoked_refresh = self.client.post(
            "/api/v1/auth/token/refresh/",
            {"refresh": refreshed.data["refresh"]},
            format="json",
        )
        self.assertEqual(revoked_refresh.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_connexion_est_limitee_apres_trop_de_tentatives(self):
        for _ in range(10):
            response = self.client.post(
                "/api/v1/auth/token/",
                {"username": self.client_user.username, "password": "MotDePasseIncorrect!"},
                format="json",
            )
            self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        blocked = self.client.post(
            "/api/v1/auth/token/",
            {"username": self.client_user.username, "password": "MotDePasseIncorrect!"},
            format="json",
        )
        self.assertEqual(blocked.status_code, status.HTTP_429_TOO_MANY_REQUESTS)

    def test_demandes_sensibles_sont_limitees_par_adresse_ip(self):
        for index in range(5):
            response = self.client.post(
                "/api/v1/auth/password-reset/",
                {"email": f"inconnu-{index}@example.com"},
                format="json",
            )
            self.assertEqual(response.status_code, status.HTTP_200_OK)
        blocked = self.client.post(
            "/api/v1/auth/password-reset/",
            {"email": "inconnu-bloque@example.com"},
            format="json",
        )
        self.assertEqual(blocked.status_code, status.HTTP_429_TOO_MANY_REQUESTS)

    def test_client_consulte_et_modifie_ses_coordonnees(self):
        self.client.force_authenticate(user=self.client_user)
        profile = self.client.get("/api/v1/auth/profile/")
        self.assertEqual(profile.status_code, status.HTTP_200_OK)
        self.assertEqual(profile.data["email"], self.client_user.email)
        self.assertEqual(profile.data["billing_city"], "Bruxelles")

        updated = self.client.patch(
            "/api/v1/auth/profile/",
            {
                "first_name": "Vianney",
                "phone": "+32479999999",
                "billing_address": "Avenue de la Musique 44",
                "billing_city": "Mons",
                "billing_postal_code": "7000",
                "preferred_language": "nl",
                "email": "tentative@example.com",
            },
            format="json",
        )
        self.assertEqual(updated.status_code, status.HTTP_200_OK)
        self.client_user.refresh_from_db()
        self.client_profile.refresh_from_db()
        self.assertEqual(self.client_user.first_name, "Vianney")
        self.assertEqual(self.client_user.email, "client@example.com")
        self.assertEqual(self.client_profile.billing_city, "Mons")
        self.assertEqual(self.client_profile.preferred_language, "nl")

    def test_profil_client_refuse_mineur_et_utilisateur_sans_profil(self):
        self.client.force_authenticate(user=self.client_user)
        minor = self.client.patch(
            "/api/v1/auth/profile/",
            {"date_of_birth": str(date.today() - timedelta(days=365 * 10))},
            format="json",
        )
        self.assertEqual(minor.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("date_of_birth", minor.data)

        user_without_profile = get_user_model().objects.create_user(
            username="utilisateur_sans_profil",
            password="MotDePasseSansProfil2026!",
        )
        self.client.force_authenticate(user=user_without_profile)
        forbidden = self.client.get("/api/v1/auth/profile/")
        self.assertEqual(forbidden.status_code, status.HTTP_403_FORBIDDEN)

    def test_client_change_mot_de_passe_et_revoque_sa_session(self):
        tokens = self.client.post(
            "/api/v1/auth/token/",
            {"username": self.client_user.username, "password": "MotDePasseTest2026!"},
            format="json",
        ).data
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access']}")

        wrong = self.client.post(
            "/api/v1/auth/password-change/",
            {
                "current_password": "MotDePasseIncorrect2026!",
                "new_password": "NouveauMotDePasse2026!",
                "refresh": tokens["refresh"],
            },
            format="json",
        )
        self.assertEqual(wrong.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("current_password", wrong.data)

        changed = self.client.post(
            "/api/v1/auth/password-change/",
            {
                "current_password": "MotDePasseTest2026!",
                "new_password": "NouveauMotDePasse2026!",
                "refresh": tokens["refresh"],
            },
            format="json",
        )
        self.assertEqual(changed.status_code, status.HTTP_204_NO_CONTENT)
        self.client_user.refresh_from_db()
        self.assertTrue(self.client_user.check_password("NouveauMotDePasse2026!"))

        old_access = self.client.get("/api/v1/auth/me/")
        self.assertEqual(old_access.status_code, status.HTTP_401_UNAUTHORIZED)
        self.client.credentials()
        revoked_refresh = self.client.post(
            "/api/v1/auth/token/refresh/",
            {"refresh": tokens["refresh"]},
            format="json",
        )
        self.assertEqual(revoked_refresh.status_code, status.HTTP_401_UNAUTHORIZED)
        new_login = self.client.post(
            "/api/v1/auth/token/",
            {"username": self.client_user.username, "password": "NouveauMotDePasse2026!"},
            format="json",
        )
        self.assertEqual(new_login.status_code, status.HTTP_200_OK)

    def test_client_enregistre_et_annule_une_demande_suppression(self):
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post(
            "/api/v1/auth/deletion-requests/",
            {"reason": "Je souhaite fermer définitivement mon espace client."},
            format="json",
        )
        self.assertEqual(created.status_code, status.HTTP_201_CREATED)
        self.assertEqual(created.data["status"], AccountDeletionRequest.PENDING)
        self.assertEqual(AccountDeletionRequest.objects.get().client, self.client_profile)

        duplicate = self.client.post(
            "/api/v1/auth/deletion-requests/",
            {"reason": "Une seconde demande ne doit pas être créée."},
            format="json",
        )
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(AccountDeletionRequest.objects.count(), 1)

        listed = self.client.get("/api/v1/auth/deletion-requests/")
        self.assertEqual(listed.status_code, status.HTTP_200_OK)
        self.assertEqual(len(listed.data), 1)

        cancelled = self.client.post(f"/api/v1/auth/deletion-requests/{created.data['id']}/cancel/")
        self.assertEqual(cancelled.status_code, status.HTTP_200_OK)
        self.assertEqual(cancelled.data["status"], AccountDeletionRequest.CANCELLED)

    def test_client_ne_peut_pas_annuler_la_demande_suppression_d_un_autre(self):
        deletion_request = AccountDeletionRequest.objects.create(
            client=self.client_profile,
            reason="Demande appartenant au premier client.",
        )
        other_user = get_user_model().objects.create_user(
            username="autre_suppression",
            email="autre-suppression@example.com",
            password="MotDePasseAutre2026!",
        )
        ClientProfile.objects.create(
            user=other_user,
            date_of_birth=date(1991, 1, 1),
            phone="+32473333333",
            billing_address="Rue Autre 3",
            billing_city="Charleroi",
            billing_postal_code="6000",
        )
        self.client.force_authenticate(user=other_user)
        forbidden = self.client.post(f"/api/v1/auth/deletion-requests/{deletion_request.pk}/cancel/")
        self.assertEqual(forbidden.status_code, status.HTTP_404_NOT_FOUND)

    @override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend")
    def test_administrateur_refuse_une_demande_suppression_avec_reponse(self):
        deletion_request = AccountDeletionRequest.objects.create(
            client=self.client_profile,
            reason="Je souhaite fermer mon compte après mon événement.",
        )
        self.client.force_authenticate(user=self.client_user)
        forbidden = self.client.post(
            f"/api/v1/auth/deletion-requests/{deletion_request.pk}/review/",
            {"decision": "rejected", "review_message": "Le dossier financier doit encore être clôturé."},
            format="json",
        )
        self.assertEqual(forbidden.status_code, status.HTTP_403_FORBIDDEN)

        admin = get_user_model().objects.create_superuser(
            username="admin_suppression",
            email="admin-suppression@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)
        reviewed = self.client.post(
            f"/api/v1/auth/deletion-requests/{deletion_request.pk}/review/",
            {"decision": "rejected", "review_message": "Le dossier financier doit encore être clôturé."},
            format="json",
        )
        self.assertEqual(reviewed.status_code, status.HTTP_200_OK)
        self.assertEqual(reviewed.data["status"], AccountDeletionRequest.REJECTED)
        self.assertEqual(reviewed.data["client_email"], self.client_user.email)
        self.assertEqual(len(mail.outbox), 1)
        self.client_user.refresh_from_db()
        self.assertTrue(self.client_user.is_active)

    @override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend")
    def test_approbation_suppression_desactive_compte_et_revoque_sessions(self):
        tokens = self.client.post(
            "/api/v1/auth/token/",
            {"username": self.client_user.username, "password": "MotDePasseTest2026!"},
            format="json",
        ).data
        deletion_request = AccountDeletionRequest.objects.create(
            client=self.client_profile,
            reason="Je confirme la fermeture de mon compte client.",
        )
        admin = get_user_model().objects.create_superuser(
            username="admin_approbation_suppression",
            email="admin-approbation@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)
        approved = self.client.post(
            f"/api/v1/auth/deletion-requests/{deletion_request.pk}/review/",
            {"decision": "approved", "review_message": "Le compte est désactivé, les pièces légales sont conservées."},
            format="json",
        )
        self.assertEqual(approved.status_code, status.HTTP_200_OK)
        self.assertEqual(approved.data["status"], AccountDeletionRequest.APPROVED)
        self.client_user.refresh_from_db()
        self.assertFalse(self.client_user.is_active)

        self.client.force_authenticate(user=None)
        revoked = self.client.post("/api/v1/auth/token/refresh/", {"refresh": tokens["refresh"]}, format="json")
        self.assertEqual(revoked.status_code, status.HTTP_401_UNAUTHORIZED)

    @override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend", FRONTEND_URL="http://localhost:5173")
    def test_inscription_cree_un_profil_inactif_puis_verifie_email(self):
        response = self.client.post(
            "/api/v1/auth/register/",
            {
                "username": "nouveau_client",
                "email": "nouveau@example.com",
                "password": "MotDePasseNouveau2026!",
                "first_name": "Nouveau",
                "last_name": "Client",
                "date_of_birth": "1992-06-18",
                "phone": "+32471111111",
                "billing_address": "Rue du Test 4",
                "billing_city": "Namur",
                "billing_postal_code": "5000",
                "preferred_language": "fr",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        user = get_user_model().objects.get(username="nouveau_client")
        self.assertTrue(user.check_password("MotDePasseNouveau2026!"))
        self.assertEqual(user.client_profile.billing_city, "Namur")
        self.assertFalse(user.is_active)
        self.assertEqual(len(mail.outbox), 1)

        blocked_login = self.client.post(
            "/api/v1/auth/token/",
            {"username": "nouveau_client", "password": "MotDePasseNouveau2026!"},
            format="json",
        )
        self.assertEqual(blocked_login.status_code, status.HTTP_401_UNAUTHORIZED)

        verification_url = next(line for line in mail.outbox[0].body.splitlines() if line.startswith("http://"))
        parameters = parse_qs(urlparse(verification_url).query)
        verification_payload = {
            "uid": parameters["verify_uid"][0],
            "token": parameters["verify_token"][0],
        }
        verified = self.client.post("/api/v1/auth/verify-email/", verification_payload, format="json")
        self.assertEqual(verified.status_code, status.HTTP_204_NO_CONTENT)
        user.refresh_from_db()
        self.assertTrue(user.is_active)

        authenticated = self.client.post(
            "/api/v1/auth/token/",
            {"username": "nouveau_client", "password": "MotDePasseNouveau2026!"},
            format="json",
        )
        self.assertEqual(authenticated.status_code, status.HTTP_200_OK)
        replayed = self.client.post("/api/v1/auth/verify-email/", verification_payload, format="json")
        self.assertEqual(replayed.status_code, status.HTTP_400_BAD_REQUEST)

    def test_inscription_refuse_doublon_mot_de_passe_faible_et_mineur(self):
        base_payload = {
            "username": "client_invalide",
            "email": "autre@example.com",
            "password": "court",
            "first_name": "Petit",
            "last_name": "Client",
            "date_of_birth": str(date.today() - timedelta(days=365 * 10)),
            "phone": "+32472222222",
            "billing_address": "Rue du Refus 2",
            "billing_city": "Liège",
            "billing_postal_code": "4000",
            "preferred_language": "fr",
        }
        response = self.client.post("/api/v1/auth/register/", base_payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("date_of_birth", response.data)
        self.assertFalse(get_user_model().objects.filter(email="autre@example.com").exists())

        base_payload["date_of_birth"] = "1990-01-01"
        weak_password = self.client.post("/api/v1/auth/register/", base_payload, format="json")
        self.assertEqual(weak_password.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("password", weak_password.data)

        base_payload.update(
            username=self.client_user.username,
            password="MotDePasseValide2026!",
        )
        duplicate = self.client.post("/api/v1/auth/register/", base_payload, format="json")
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("username", duplicate.data)

    @override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend", FRONTEND_URL="http://localhost:5173")
    def test_renvoi_verification_reste_discret_et_limite_aux_comptes_inactifs(self):
        self.client_user.is_active = False
        self.client_user.save(update_fields=["is_active"])
        resent = self.client.post(
            "/api/v1/auth/verify-email/resend/",
            {"email": self.client_user.email},
            format="json",
        )
        unknown = self.client.post(
            "/api/v1/auth/verify-email/resend/",
            {"email": "inconnu@example.com"},
            format="json",
        )
        self.assertEqual(resent.status_code, status.HTTP_200_OK)
        self.assertEqual(unknown.status_code, status.HTTP_200_OK)
        self.assertEqual(resent.data, unknown.data)
        self.assertEqual(len(mail.outbox), 1)

        self.client_user.is_active = True
        self.client_user.save(update_fields=["is_active"])
        active = self.client.post(
            "/api/v1/auth/verify-email/resend/",
            {"email": self.client_user.email},
            format="json",
        )
        self.assertEqual(active.status_code, status.HTTP_200_OK)
        self.assertEqual(active.data, unknown.data)
        self.assertEqual(len(mail.outbox), 1)

    @override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend", FRONTEND_URL="http://localhost:5173")
    def test_reinitialisation_du_mot_de_passe_par_lien_email(self):
        authenticated = self.client.post(
            "/api/v1/auth/token/",
            {"username": self.client_user.username, "password": "MotDePasseTest2026!"},
            format="json",
        )
        requested = self.client.post(
            "/api/v1/auth/password-reset/",
            {"email": self.client_user.email},
            format="json",
        )
        self.assertEqual(requested.status_code, status.HTTP_200_OK)
        self.assertEqual(len(mail.outbox), 1)
        reset_url = next(line for line in mail.outbox[0].body.splitlines() if line.startswith("http://"))
        parameters = parse_qs(urlparse(reset_url).query)

        confirmed = self.client.post(
            "/api/v1/auth/password-reset/confirm/",
            {
                "uid": parameters["reset_uid"][0],
                "token": parameters["reset_token"][0],
                "password": "NouveauMotDePasse2026!",
            },
            format="json",
        )
        self.assertEqual(confirmed.status_code, status.HTTP_204_NO_CONTENT)
        self.client_user.refresh_from_db()
        self.assertTrue(self.client_user.check_password("NouveauMotDePasse2026!"))
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {authenticated.data['access']}")
        revoked_session = self.client.get("/api/v1/auth/me/")
        self.assertEqual(revoked_session.status_code, status.HTTP_401_UNAUTHORIZED)
        self.client.credentials()

        replayed = self.client.post(
            "/api/v1/auth/password-reset/confirm/",
            {
                "uid": parameters["reset_uid"][0],
                "token": parameters["reset_token"][0],
                "password": "EncoreUnMotDePasse2026!",
            },
            format="json",
        )
        self.assertEqual(replayed.status_code, status.HTTP_400_BAD_REQUEST)

    @override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend")
    def test_demande_mot_de_passe_ne_revele_pas_les_comptes(self):
        existing = self.client.post("/api/v1/auth/password-reset/", {"email": self.client_user.email}, format="json")
        unknown = self.client.post("/api/v1/auth/password-reset/", {"email": "inconnu@example.com"}, format="json")
        self.assertEqual(existing.status_code, status.HTTP_200_OK)
        self.assertEqual(unknown.status_code, status.HTTP_200_OK)
        self.assertEqual(existing.data, unknown.data)
        self.assertEqual(len(mail.outbox), 1)

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

    def test_dj_gere_ses_disponibilites_sans_modifier_un_creneau_reserve(self):
        dj, public_slot = self.create_available_dj()
        self.client.force_authenticate(user=self.client_user)
        forbidden = self.client.post(
            "/api/v1/availability/",
            {
                "available_date": str(date.today() + timedelta(days=31)),
                "start_time": "18:00:00",
                "end_time": "23:00:00",
            },
            format="json",
        )
        self.assertEqual(forbidden.status_code, status.HTTP_403_FORBIDDEN)

        self.client.force_authenticate(user=dj.user)
        created = self.client.post(
            "/api/v1/availability/",
            {
                "available_date": str(date.today() + timedelta(days=31)),
                "start_time": "18:00:00",
                "end_time": "23:00:00",
                "status": DJAvailability.AVAILABLE,
            },
            format="json",
        )
        self.assertEqual(created.status_code, status.HTTP_201_CREATED)
        self.assertEqual(created.data["dj"]["id"], dj.pk)

        blocked = self.client.patch(
            f"/api/v1/availability/{created.data['id']}/",
            {"status": DJAvailability.BLOCKED, "reason": "Indisponibilité personnelle"},
            format="json",
        )
        self.assertEqual(blocked.status_code, status.HTTP_200_OK)
        self.assertEqual(blocked.data["status"], DJAvailability.BLOCKED)

        reserved_slot = DJAvailability.objects.create(
            dj=dj,
            available_date=date.today() + timedelta(days=32),
            start_time="18:00:00",
            end_time="23:00:00",
            status=DJAvailability.RESERVED,
        )
        protected_update = self.client.patch(
            f"/api/v1/availability/{reserved_slot.pk}/",
            {"status": DJAvailability.AVAILABLE},
            format="json",
        )
        protected_delete = self.client.delete(f"/api/v1/availability/{reserved_slot.pk}/")
        self.assertEqual(protected_update.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(protected_delete.status_code, status.HTTP_400_BAD_REQUEST)

        self.client.force_authenticate(user=None)
        public_response = self.client.get("/api/v1/availability/")
        public_ids = {item["id"] for item in public_response.data["results"]}
        self.assertIn(public_slot.pk, public_ids)
        self.assertNotIn(created.data["id"], public_ids)
        self.assertNotIn(reserved_slot.pk, public_ids)

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

    def test_documents_pdf_restent_disponibles_apres_remboursement_et_annulation(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        invoice = booking.invoices.get(invoice_type=Invoice.DEPOSIT)
        payment = Payment.objects.create(
            booking=booking,
            invoice=invoice,
            stripe_session_id="cs_test_pdf_cancelled",
            stripe_payment_intent_id="pi_test_pdf_cancelled",
            amount=invoice.amount,
            currency="EUR",
            status=Payment.REFUNDED,
            paid_at=timezone.now(),
        )
        Refund.objects.create(
            payment=payment,
            stripe_refund_id="re_test_pdf_cancelled",
            amount=payment.amount,
            currency=payment.currency,
            internal_reason="Annulation confirmée et remboursée",
            status=Refund.SUCCEEDED,
            processed_at=timezone.now(),
        )
        invoice.status = Invoice.CANCELLED
        invoice.save(update_fields=["status"])
        booking.status = Booking.CANCELLED
        booking.cancellation_reason = "Événement annulé à la demande du client"
        booking.save(update_fields=["status", "cancellation_reason"])
        contract.status = Contract.CANCELLED
        contract.save(update_fields=["status"])
        self.client.force_authenticate(user=self.client_user)

        contract_response = self.client.get(f"/api/v1/contracts/{contract.pk}/pdf/")
        invoice_response = self.client.get(f"/api/v1/invoices/{invoice.pk}/pdf/")

        self.assertEqual(contract_response.status_code, status.HTTP_200_OK)
        self.assertEqual(invoice_response.status_code, status.HTTP_200_OK)
        self.assertTrue(contract_response.content.startswith(b"%PDF-"))
        self.assertTrue(invoice_response.content.startswith(b"%PDF-"))
        self.assertGreater(len(contract_response.content), 2500)
        self.assertGreater(len(invoice_response.content), 2500)

    def test_client_ne_peut_pas_fabriquer_reservation_contrat_ou_facture(self):
        self.client.force_authenticate(user=self.client_user)

        booking_response = self.client.post("/api/v1/bookings/", {}, format="json")
        contract_response = self.client.post("/api/v1/contracts/", {}, format="json")
        invoice_response = self.client.post("/api/v1/invoices/", {}, format="json")

        self.assertEqual(booking_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(contract_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(invoice_response.status_code, status.HTTP_403_FORBIDDEN)

    def test_client_ne_peut_pas_modifier_les_documents_generes(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        invoice = booking.invoices.get(invoice_type=Invoice.DEPOSIT)
        self.client.force_authenticate(user=self.client_user)

        booking_response = self.client.patch(f"/api/v1/bookings/{booking.pk}/", {"status": Booking.PAID}, format="json")
        contract_response = self.client.patch(f"/api/v1/contracts/{contract.pk}/", {"status": Contract.SIGNED}, format="json")
        invoice_response = self.client.patch(f"/api/v1/invoices/{invoice.pk}/", {"status": Invoice.PAID}, format="json")

        self.assertEqual(booking_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(contract_response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(invoice_response.status_code, status.HTTP_403_FORBIDDEN)
        booking.refresh_from_db()
        contract.refresh_from_db()
        invoice.refresh_from_db()
        self.assertNotEqual(booking.status, Booking.PAID)
        self.assertEqual(contract.status, Contract.SENT)
        self.assertEqual(invoice.status, Invoice.SENT)

    def test_playlist_exige_une_reservation_confirmee(self):
        contract = self.create_contract_for_client()
        style = MusicStyle.objects.create(name="Disco")
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(
            "/api/v1/playlists/",
            {"booking": contract.booking_id, "main_style": style.pk, "notes": "Ambiance festive"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("booking", response.data)
        self.assertFalse(Playlist.objects.filter(booking=contract.booking).exists())

    def test_client_cree_sa_playlist_et_le_dj_valide_une_chanson(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        booking.deposit_paid = True
        booking.status = Booking.CONFIRMED
        booking.save(update_fields=["deposit_paid", "status"])
        style = MusicStyle.objects.create(name="Soul")
        self.client.force_authenticate(user=self.client_user)
        playlist_response = self.client.post(
            "/api/v1/playlists/",
            {"booking": booking.pk, "main_style": style.pk, "notes": "Entrée douce puis danse"},
            format="json",
        )

        self.assertEqual(playlist_response.status_code, status.HTTP_201_CREATED)
        playlist_id = playlist_response.data["id"]
        forbidden_status = self.client.post(
            "/api/v1/playlist-songs/",
            {"playlist": playlist_id, "title": "September", "artist": "Earth Wind & Fire", "status": PlaylistSong.APPROVED},
            format="json",
        )
        self.assertEqual(forbidden_status.status_code, status.HTTP_400_BAD_REQUEST)
        song_response = self.client.post(
            "/api/v1/playlist-songs/",
            {"playlist": playlist_id, "title": "September", "artist": "Earth Wind & Fire", "preference_level": PlaylistSong.MUST_PLAY},
            format="json",
        )
        self.assertEqual(song_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(song_response.data["status"], PlaylistSong.REQUESTED)

        other_user = get_user_model().objects.create_user(username="client_playlist_interdit", password="MotDePasseTest2026!")
        ClientProfile.objects.create(
            user=other_user,
            date_of_birth=date(1994, 4, 4),
            phone="+32474444444",
            billing_address="Rue Playlist 4",
            billing_city="Namur",
            billing_postal_code="5000",
        )
        self.client.force_authenticate(user=other_user)
        intrusion = self.client.post(
            "/api/v1/playlist-songs/",
            {"playlist": playlist_id, "title": "Intrusion", "artist": "Inconnu"},
            format="json",
        )
        self.assertEqual(intrusion.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(PlaylistSong.objects.filter(playlist_id=playlist_id).count(), 1)

        self.client.force_authenticate(user=booking.dj.user)
        approval = self.client.patch(
            f"/api/v1/playlist-songs/{song_response.data['id']}/",
            {"status": PlaylistSong.APPROVED},
            format="json",
        )
        self.assertEqual(approval.status_code, status.HTTP_200_OK)
        self.assertEqual(approval.data["status"], PlaylistSong.APPROVED)

    def test_rendez_vous_preparatoire_suit_la_reservation_confirmee(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        self.event_type.requires_preparatory_meeting = True
        self.event_type.save(update_fields=["requires_preparatory_meeting"])
        scheduled_at = (timezone.now() + timedelta(days=7)).isoformat()
        self.client.force_authenticate(user=self.client_user)

        past = self.client.post(
            "/api/v1/appointments/",
            {"booking": booking.pk, "scheduled_at": (timezone.now() - timedelta(days=1)).isoformat()},
            format="json",
        )
        after_event = self.client.post(
            "/api/v1/appointments/",
            {"booking": booking.pk, "scheduled_at": (timezone.now() + timedelta(days=40)).isoformat()},
            format="json",
        )
        self.assertEqual(past.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(after_event.status_code, status.HTTP_400_BAD_REQUEST)

        before_payment = self.client.post(
            "/api/v1/appointments/",
            {"booking": booking.pk, "scheduled_at": scheduled_at, "mode": PreparatoryAppointment.ONLINE},
            format="json",
        )
        self.assertEqual(before_payment.status_code, status.HTTP_400_BAD_REQUEST)

        booking.deposit_paid = True
        booking.status = Booking.CONFIRMED
        booking.save(update_fields=["deposit_paid", "status"])
        created = self.client.post(
            "/api/v1/appointments/",
            {"booking": booking.pk, "scheduled_at": scheduled_at, "mode": PreparatoryAppointment.ONLINE, "notes": "Préparer l'ouverture de bal"},
            format="json",
        )
        self.assertEqual(created.status_code, status.HTTP_201_CREATED)
        self.assertEqual(created.data["status"], PreparatoryAppointment.PLANNED)
        deletion = self.client.delete(f"/api/v1/appointments/{created.data['id']}/")
        self.assertEqual(deletion.status_code, status.HTTP_403_FORBIDDEN)

        duplicate = self.client.post(
            "/api/v1/appointments/",
            {"booking": booking.pk, "scheduled_at": (timezone.now() + timedelta(days=8)).isoformat()},
            format="json",
        )
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)

        forbidden_status = self.client.patch(
            f"/api/v1/appointments/{created.data['id']}/",
            {"status": PreparatoryAppointment.DONE},
            format="json",
        )
        self.assertEqual(forbidden_status.status_code, status.HTTP_400_BAD_REQUEST)

        self.client.force_authenticate(user=booking.dj.user)
        completed_too_early = self.client.patch(
            f"/api/v1/appointments/{created.data['id']}/",
            {"status": PreparatoryAppointment.DONE},
            format="json",
        )
        self.assertEqual(completed_too_early.status_code, status.HTTP_400_BAD_REQUEST)

        appointment = PreparatoryAppointment.objects.get(pk=created.data["id"])
        appointment.scheduled_at = timezone.now() - timedelta(hours=1)
        appointment.save(update_fields=["scheduled_at"])

        completed = self.client.patch(
            f"/api/v1/appointments/{created.data['id']}/",
            {"status": PreparatoryAppointment.DONE},
            format="json",
        )
        self.assertEqual(completed.status_code, status.HTTP_200_OK)
        self.assertEqual(completed.data["status"], PreparatoryAppointment.DONE)

    def test_avis_client_est_depose_apres_prestation_et_modere_par_admin(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        self.client.force_authenticate(user=self.client_user)

        too_early = self.client.post(
            "/api/v1/reviews/",
            {"booking": booking.pk, "rating": 5, "comment": "Trop tôt"},
            format="json",
        )
        self.assertEqual(too_early.status_code, status.HTTP_400_BAD_REQUEST)

        booking.status = Booking.PERFORMED
        booking.save(update_fields=["status"])
        self.client.force_authenticate(user=booking.dj.user)
        dj_attempt = self.client.post(
            "/api/v1/reviews/",
            {"booking": booking.pk, "rating": 5, "comment": "Avis créé par le DJ"},
            format="json",
        )
        self.assertEqual(dj_attempt.status_code, status.HTTP_400_BAD_REQUEST)

        self.client.force_authenticate(user=self.client_user)
        invalid_rating = self.client.post(
            "/api/v1/reviews/",
            {"booking": booking.pk, "rating": 6, "comment": "Note impossible"},
            format="json",
        )
        forbidden_status = self.client.post(
            "/api/v1/reviews/",
            {"booking": booking.pk, "rating": 5, "comment": "Excellente soirée", "status": Review.PUBLISHED},
            format="json",
        )
        self.assertEqual(invalid_rating.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(forbidden_status.status_code, status.HTTP_400_BAD_REQUEST)

        created = self.client.post(
            "/api/v1/reviews/",
            {"booking": booking.pk, "rating": 5, "comment": "Excellente soirée et DJ très professionnel"},
            format="json",
        )
        self.assertEqual(created.status_code, status.HTTP_201_CREATED)
        self.assertEqual(created.data["status"], Review.PENDING)
        self.assertEqual(created.data["client"], self.client_profile.pk)
        self.assertEqual(created.data["dj"], booking.dj_id)
        duplicate = self.client.post(
            "/api/v1/reviews/",
            {"booking": booking.pk, "rating": 4, "comment": "Deuxième avis interdit"},
            format="json",
        )
        deletion = self.client.delete(f"/api/v1/reviews/{created.data['id']}/")
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(deletion.status_code, status.HTTP_403_FORBIDDEN)

        edited = self.client.patch(
            f"/api/v1/reviews/{created.data['id']}/",
            {"comment": "Excellente soirée, DJ ponctuel et très professionnel"},
            format="json",
        )
        self.assertEqual(edited.status_code, status.HTTP_200_OK)

        admin = get_user_model().objects.create_superuser(
            username="admin_avis",
            email="admin-avis@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)
        published = self.client.patch(
            f"/api/v1/reviews/{created.data['id']}/",
            {"status": Review.PUBLISHED},
            format="json",
        )
        self.assertEqual(published.status_code, status.HTTP_200_OK)
        self.assertEqual(published.data["status"], Review.PUBLISHED)

        self.client.force_authenticate(user=self.client_user)
        locked = self.client.patch(
            f"/api/v1/reviews/{created.data['id']}/",
            {"rating": 1},
            format="json",
        )
        self.assertEqual(locked.status_code, status.HTTP_400_BAD_REQUEST)

    def test_dj_cloture_la_prestation_et_genere_la_facture_de_solde(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        deposit_invoice = booking.invoices.get(invoice_type=Invoice.DEPOSIT)
        booking.event_date = date.today() - timedelta(days=1)
        booking.deposit_paid = True
        booking.status = Booking.CONFIRMED
        booking.save(update_fields=["event_date", "deposit_paid", "status"])
        deposit_invoice.status = Invoice.PAID
        deposit_invoice.save(update_fields=["status"])

        self.client.force_authenticate(user=self.client_user)
        client_attempt = self.client.post(f"/api/v1/bookings/{booking.pk}/complete/", {}, format="json")
        self.assertEqual(client_attempt.status_code, status.HTTP_403_FORBIDDEN)

        self.client.force_authenticate(user=booking.dj.user)
        completed = self.client.post(f"/api/v1/bookings/{booking.pk}/complete/", {}, format="json")
        duplicate = self.client.post(f"/api/v1/bookings/{booking.pk}/complete/", {}, format="json")

        self.assertEqual(completed.status_code, status.HTTP_201_CREATED)
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)
        booking.refresh_from_db()
        self.assertEqual(booking.status, Booking.PERFORMED)
        balance = Invoice.objects.get(booking=booking, invoice_type=Invoice.BALANCE)
        self.assertEqual(balance.amount, booking.total_amount - deposit_invoice.amount)
        self.assertEqual(balance.status, Invoice.SENT)
        self.assertEqual(Invoice.objects.filter(booking=booking, invoice_type=Invoice.BALANCE).count(), 1)

    def test_admin_annule_un_dossier_sans_paiement_et_libere_le_dj(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        availability = DJAvailability.objects.get(dj=booking.dj, available_date=booking.event_date)
        appointment = PreparatoryAppointment.objects.create(
            booking=booking,
            scheduled_at=timezone.now() + timedelta(days=7),
            status=PreparatoryAppointment.PLANNED,
        )

        self.client.force_authenticate(user=self.client_user)
        client_attempt = self.client.post(
            f"/api/v1/bookings/{booking.pk}/cancel/",
            {"reason": "Annulation demandée par le client"},
            format="json",
        )
        self.client.force_authenticate(user=booking.dj.user)
        dj_attempt = self.client.post(
            f"/api/v1/bookings/{booking.pk}/cancel/",
            {"reason": "Indisponibilité communiquée par le DJ"},
            format="json",
        )
        self.assertEqual(client_attempt.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(dj_attempt.status_code, status.HTTP_403_FORBIDDEN)

        admin = get_user_model().objects.create_superuser(
            username="admin_cancellation",
            email="admin-cancellation@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)
        response = self.client.post(
            f"/api/v1/bookings/{booking.pk}/cancel/",
            {"reason": "Annulation confirmée avec le client"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        booking.refresh_from_db()
        contract.refresh_from_db()
        appointment.refresh_from_db()
        availability.refresh_from_db()
        self.assertEqual(booking.status, Booking.CANCELLED)
        self.assertFalse(booking.deposit_paid)
        self.assertEqual(booking.cancellation_reason, "Annulation confirmée avec le client")
        self.assertEqual(contract.status, Contract.CANCELLED)
        self.assertEqual(appointment.status, PreparatoryAppointment.CANCELLED)
        self.assertEqual(availability.status, DJAvailability.AVAILABLE)
        self.assertEqual(availability.reason, "")
        self.assertFalse(Invoice.objects.filter(booking=booking).exclude(status=Invoice.CANCELLED).exists())

    def test_client_demande_annulation_puis_admin_la_confirme(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        self.client.force_authenticate(user=self.client_user)

        response = self.client.post(
            f"/api/v1/bookings/{booking.pk}/request-cancellation/",
            {"reason": "Un imprévu familial empêche la tenue de l'événement"},
            format="json",
        )
        duplicate = self.client.post(
            f"/api/v1/bookings/{booking.pk}/request-cancellation/",
            {"reason": "Nouvelle demande identique"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)
        cancellation_request = CancellationRequest.objects.get(booking=booking)
        self.assertEqual(cancellation_request.status, CancellationRequest.PENDING)
        booking.refresh_from_db()
        self.assertNotEqual(booking.status, Booking.CANCELLED)

        admin = get_user_model().objects.create_superuser(
            username="admin_request_cancellation",
            email="admin-request-cancellation@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)
        cancelled = self.client.post(
            f"/api/v1/bookings/{booking.pk}/cancel/",
            {"reason": "Demande client vérifiée et acceptée"},
            format="json",
        )
        self.assertEqual(cancelled.status_code, status.HTTP_200_OK)
        cancellation_request.refresh_from_db()
        self.assertEqual(cancellation_request.status, CancellationRequest.APPROVED)
        self.assertEqual(cancellation_request.reviewed_by, admin)
        self.assertIsNotNone(cancellation_request.reviewed_at)

    def test_dj_ne_peut_pas_creer_la_demande_annulation_du_client(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        self.client.force_authenticate(user=booking.dj.user)

        response = self.client.post(
            f"/api/v1/bookings/{booking.pk}/request-cancellation/",
            {"reason": "Tentative de demande au nom du client"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(CancellationRequest.objects.filter(booking=booking).exists())

    def test_admin_refuse_une_demande_et_le_client_consulte_la_reponse(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        self.client.force_authenticate(user=self.client_user)
        created = self.client.post(
            f"/api/v1/bookings/{booking.pk}/request-cancellation/",
            {"reason": "Je souhaite déplacer la fête à une autre année"},
            format="json",
        )
        self.assertEqual(created.status_code, status.HTTP_201_CREATED)

        admin = get_user_model().objects.create_superuser(
            username="admin_reject_cancellation",
            email="admin-reject-cancellation@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)
        rejected = self.client.post(
            f"/api/v1/bookings/{booking.pk}/reject-cancellation/",
            {"message": "Le délai contractuel est dépassé ; contactez-nous pour déplacer la date."},
            format="json",
        )
        duplicate = self.client.post(
            f"/api/v1/bookings/{booking.pk}/reject-cancellation/",
            {"message": "Deuxième traitement impossible"},
            format="json",
        )
        self.assertEqual(rejected.status_code, status.HTTP_200_OK)
        self.assertEqual(rejected.data["status"], CancellationRequest.REJECTED)
        self.assertEqual(duplicate.status_code, status.HTTP_400_BAD_REQUEST)

        self.client.force_authenticate(user=self.client_user)
        history = self.client.get(f"/api/v1/bookings/{booking.pk}/cancellation-requests/")
        self.assertEqual(history.status_code, status.HTTP_200_OK)
        self.assertEqual(len(history.data), 1)
        self.assertEqual(history.data[0]["review_message"], rejected.data["review_message"])
        booking.refresh_from_db()
        self.assertNotEqual(booking.status, Booking.CANCELLED)

        self.client.force_authenticate(user=booking.dj.user)
        forbidden = self.client.get(f"/api/v1/bookings/{booking.pk}/cancellation-requests/")
        self.assertEqual(forbidden.status_code, status.HTTP_403_FORBIDDEN)

    @patch("apps.bookings.notifications.send_mail")
    def test_notifications_email_pour_demande_et_decision_annulation(self, send_mail):
        contract = self.create_contract_for_client()
        booking = contract.booking
        admin = get_user_model().objects.create_superuser(
            username="admin_email_cancellation",
            email="admin-email-cancellation@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=self.client_user)
        with self.captureOnCommitCallbacks(execute=True):
            requested = self.client.post(
                f"/api/v1/bookings/{booking.pk}/request-cancellation/",
                {"reason": "Un motif suffisamment détaillé pour prévenir l'administration"},
                format="json",
            )

        self.assertEqual(requested.status_code, status.HTTP_201_CREATED)
        self.assertEqual(send_mail.call_count, 1)
        self.assertIn("demande d'annulation", send_mail.call_args.args[0])
        self.assertIn(admin.email, send_mail.call_args.args[3])

        self.client.force_authenticate(user=admin)
        with self.captureOnCommitCallbacks(execute=True):
            rejected = self.client.post(
                f"/api/v1/bookings/{booking.pk}/reject-cancellation/",
                {"message": "Le délai prévu au contrat ne permet pas cette annulation."},
                format="json",
            )

        self.assertEqual(rejected.status_code, status.HTTP_200_OK)
        self.assertEqual(send_mail.call_count, 2)
        self.assertIn("refusée", send_mail.call_args.args[0])
        self.assertEqual(send_mail.call_args.args[3], [self.client_user.email])

    def test_admin_ne_peut_annuler_avant_le_remboursement_integral(self):
        contract = self.create_contract_for_client()
        booking = contract.booking
        invoice = booking.invoices.get(invoice_type=Invoice.DEPOSIT)
        payment = Payment.objects.create(
            booking=booking,
            invoice=invoice,
            stripe_session_id="cs_test_cancel_booking",
            stripe_payment_intent_id="pi_test_cancel_booking",
            amount=invoice.amount,
            currency="EUR",
            status=Payment.PAID,
            paid_at=timezone.now(),
        )
        invoice.status = Invoice.PAID
        invoice.save(update_fields=["status"])
        booking.status = Booking.CONFIRMED
        booking.deposit_paid = True
        booking.save(update_fields=["status", "deposit_paid"])
        admin = get_user_model().objects.create_superuser(
            username="admin_cancellation_refund",
            email="admin-cancellation-refund@example.com",
            password="MotDePasseAdmin2026!",
        )
        self.client.force_authenticate(user=admin)

        blocked = self.client.post(
            f"/api/v1/bookings/{booking.pk}/cancel/",
            {"reason": "Le client demande une annulation"},
            format="json",
        )
        self.assertEqual(blocked.status_code, status.HTTP_400_BAD_REQUEST)
        booking.refresh_from_db()
        self.assertEqual(booking.status, Booking.CONFIRMED)

        payment.status = Payment.REFUNDED
        payment.save(update_fields=["status"])
        invoice.status = Invoice.CANCELLED
        invoice.save(update_fields=["status"])
        cancelled = self.client.post(
            f"/api/v1/bookings/{booking.pk}/cancel/",
            {"reason": "Paiement remboursé, annulation confirmée"},
            format="json",
        )
        self.assertEqual(cancelled.status_code, status.HTTP_200_OK)
        booking.refresh_from_db()
        self.assertEqual(booking.status, Booking.CANCELLED)
