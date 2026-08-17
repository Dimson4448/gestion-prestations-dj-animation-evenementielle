from .settings import *  # noqa: F403


# Clé déterministe réservée aux tests, assez longue pour signer les JWT HS256
# sans déclencher l'avertissement de sécurité PyJWT.
SECRET_KEY = "ultimate-dj-tests-only-secret-key-2026"


# Les tests sont isolés de MariaDB : aucun droit CREATE DATABASE n'est requis
# et aucune donnée locale de développement ne peut être modifiée.
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}
