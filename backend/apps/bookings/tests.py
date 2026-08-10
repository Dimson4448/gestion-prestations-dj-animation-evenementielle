from django.test import SimpleTestCase, override_settings

from .documents import business_identity_rows


class BusinessIdentityDocumentTests(SimpleTestCase):
    @override_settings(
        BUSINESS_LEGAL_NAME="Ultimate DJ SRL",
        BUSINESS_ADDRESS="Rue de la Musique 12, 1000 Bruxelles",
        BUSINESS_COMPANY_NUMBER="0123.456.789",
        BUSINESS_VAT_NUMBER="BE0123456789",
        BUSINESS_EMAIL="contact@example.test",
        BUSINESS_PHONE="+32 470 00 00 00",
        BUSINESS_IBAN="BE00 0000 0000 0000",
    )
    def test_identite_complete_est_preparee_pour_les_documents(self):
        self.assertEqual(
            business_identity_rows("Émetteur"),
            [
                ("Émetteur", "Ultimate DJ SRL"),
                ("Adresse du prestataire", "Rue de la Musique 12, 1000 Bruxelles"),
                ("Numéro d'entreprise", "0123.456.789"),
                ("Numéro de TVA", "BE0123456789"),
                ("E-mail du prestataire", "contact@example.test"),
                ("Téléphone du prestataire", "+32 470 00 00 00"),
                ("IBAN", "BE00 0000 0000 0000"),
            ],
        )

    @override_settings(
        BUSINESS_LEGAL_NAME="Ultimate DJ",
        BUSINESS_ADDRESS="",
        BUSINESS_COMPANY_NUMBER="",
        BUSINESS_VAT_NUMBER="",
        BUSINESS_EMAIL="",
        BUSINESS_PHONE="",
        BUSINESS_IBAN="",
    )
    def test_champs_vides_ne_sont_pas_imprimes(self):
        self.assertEqual(business_identity_rows("Prestataire"), [("Prestataire", "Ultimate DJ")])
