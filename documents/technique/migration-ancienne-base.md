# Migration de données historiques

Ce guide concerne uniquement la reprise de données provenant d'une ancienne base. L'application courante utilise MariaDB sur le port `3307` et n'en dépend pas.

Configurer les variables `LEGACY_DB_*` dans `backend/.env`. Commencer systématiquement par `--dry-run` afin de contrôler le résultat sans modifier la base actuelle.

## Ordre d'importation

Depuis le dossier `backend`, exécuter les commandes suivantes dans cet ordre :

```powershell
.venv\Scripts\python.exe manage.py import_legacy_catalog --dry-run
.venv\Scripts\python.exe manage.py import_legacy_catalog
.venv\Scripts\python.exe manage.py import_legacy_accounts --dry-run
.venv\Scripts\python.exe manage.py import_legacy_accounts
.venv\Scripts\python.exe manage.py import_legacy_locations_availability --dry-run
.venv\Scripts\python.exe manage.py import_legacy_locations_availability
.venv\Scripts\python.exe manage.py import_legacy_quotes --dry-run
.venv\Scripts\python.exe manage.py import_legacy_quotes
.venv\Scripts\python.exe manage.py import_legacy_bookings --dry-run
.venv\Scripts\python.exe manage.py import_legacy_bookings
.venv\Scripts\python.exe manage.py import_legacy_service_records --dry-run
.venv\Scripts\python.exe manage.py import_legacy_service_records
.venv\Scripts\python.exe manage.py import_legacy_finances --dry-run
.venv\Scripts\python.exe manage.py import_legacy_finances
```

Les commandes sont idempotentes : elles importent successivement le catalogue, les comptes, les lieux, les disponibilités, les devis, les réservations, les contrats, les playlists, les avis, les factures et les paiements sans créer de doublons.

Les mots de passe ne sont jamais affichés ni convertis en clair. Les comptes historiques conservent uniquement leurs empreintes compatibles avec Django.
