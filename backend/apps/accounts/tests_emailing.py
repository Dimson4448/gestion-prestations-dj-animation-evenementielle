from types import SimpleNamespace

from django.core import mail
from django.test import SimpleTestCase, override_settings

from .emailing import preferred_language, send_user_email


@override_settings(
    EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend",
    EMAIL_FAIL_SILENTLY=False,
    DEFAULT_FROM_EMAIL="Ultimate DJ <test@ultimate-dj.test>",
)
class LocalizedEmailTests(SimpleTestCase):
    subjects = {"fr": "Confirmation", "en": "Confirmation", "nl": "Bevestiging"}
    messages = {"fr": "Bonjour {name}", "en": "Hello {name}", "nl": "Hallo {name}"}

    def user(self, language):
        profile = SimpleNamespace(preferred_language=language)
        return SimpleNamespace(email=f"client-{language}@example.test", client_profile=profile)

    def test_envoie_le_message_dans_les_trois_langues(self):
        for language, expected in (("fr", "Bonjour"), ("en", "Hello"), ("nl", "Hallo")):
            send_user_email(
                self.user(language), self.subjects, self.messages, {"name": "Alex"}, after_commit=False
            )
            self.assertIn(expected, mail.outbox[-1].body)

    def test_utilise_le_francais_si_la_langue_est_inconnue(self):
        self.assertEqual(preferred_language(self.user("de")), "fr")
