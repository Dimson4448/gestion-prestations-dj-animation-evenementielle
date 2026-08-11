from .settings import *  # noqa: F403


# Les tests sont isolés de MariaDB : aucun droit CREATE DATABASE n'est requis
# et aucune donnée locale de développement ne peut être modifiée.
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}
