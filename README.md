# Gestion des prestations DJ et animation événementielle

Application web **Ultimate DJ** développée avec Django et React pour gérer une prestation musicale, du devis à l'avis client.

![Django](https://img.shields.io/badge/Django-5.2-092E20?logo=django&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-11.8-003545?logo=mariadb&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-environnement%20de%20test-635BFF?logo=stripe&logoColor=white)

## Fonctionnalités principales

- consulter les formules, options et DJ disponibles ;
- créer et suivre une demande de devis ;
- affecter un DJ, générer un contrat et confirmer une réservation ;
- payer l'acompte et le solde avec Stripe Checkout en environnement de test ;
- préparer une playlist et un rendez-vous préparatoire ;
- échanger dans le dossier, publier et modérer les avis ;
- gérer disponibilités, annulations, suppressions de compte et exports ;
- utiliser l'interface en français, anglais ou néerlandais.

Les demandes de devis concernent les anniversaires enfant ou adulte, les mariages et les soirées privées.

## Stack technique

- Backend : Django 5 et Django REST Framework ;
- Frontend : React et Vite ;
- Base de données : MariaDB/MySQL ;
- Paiement : Stripe Checkout ;
- Documentation API : Swagger UI et ReDoc ;
- Internationalisation : i18next et react-i18next.

## Structure du projet

```text
backend/     Application Django et API REST
frontend/    Interface React
api/         Fichiers OpenAPI
database/    Dump SQL MariaDB/MySQL
documents/   Livrables et documentation technique
```

## Restaurer la base de données locale

Le dump de référence est `database/dumps/ultimate_dj_dump_mysql_mariadb.sql`. Il contient le schéma, les migrations Django et les données de travail nécessaires aux parcours complets.

1. créer une base MariaDB vide nommée `ultimate_dj_django` ;
2. importer le dump ;
3. recopier `backend/.env.example` vers `backend/.env` et renseigner les paramètres de connexion ;
4. lancer `python manage.py migrate` depuis `backend` ;
5. démarrer le backend et le frontend.

### Import avec HeidiSQL

1. ouvrir HeidiSQL et se connecter au serveur configuré pour l'application ;
2. créer la base `ultimate_dj_django` avec le jeu de caractères `utf8mb4` ;
3. sélectionner cette base, puis choisir **Fichier → Charger un fichier SQL** ;
4. ouvrir `database/dumps/ultimate_dj_dump_mysql_mariadb.sql` ;
5. exécuter le script avec **F9** ou le bouton d'exécution.

Le dump est actualisé après chaque évolution importante du schéma ou des données de référence. Les comptes qu'il contient sont réservés à la démonstration ; aucun fichier `.env`, aucune clé de configuration, donnée de session ou jeton JWT n'y est inclus.

## Démarrage du backend

```powershell
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements-lock.txt
Copy-Item .env.example .env
python manage.py migrate
python manage.py runserver
```

La configuration locale utilise MariaDB sur le port `3307`, avec la base `ultimate_dj_django`. Les mots de passe et clés restent dans `backend/.env`, ignoré par Git.

Avant l'émission d'un contrat ou d'une facture, compléter les coordonnées professionnelles applicables dans `backend/.env` :

```dotenv
BUSINESS_LEGAL_NAME=Ultimate DJ
BUSINESS_ADDRESS=
BUSINESS_COMPANY_NUMBER=
BUSINESS_VAT_NUMBER=
BUSINESS_EMAIL=
BUSINESS_PHONE=
BUSINESS_IBAN=
```

## Démarrage du frontend

```powershell
cd frontend
npm ci
Copy-Item .env.example .env.local
npm run dev
```

Configuration par défaut :

```dotenv
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_BACKEND_URL=http://localhost:8000
```

## Vérification rapide après installation

1. ouvrir <http://localhost:5173/> ;
2. vérifier que le catalogue et les offres se chargent ;
3. se connecter avec un compte de travail présent dans la base locale ;
4. vérifier l'accès à l'espace correspondant au rôle du compte ;
5. ouvrir la documentation API ou l'administration Django si nécessaire.

Les identifiants locaux ne sont pas publiés dans le dépôt. Ils doivent être créés, importés ou conservés dans le gestionnaire de mots de passe utilisé sur la machine de travail.

## Paiement

Les paiements sont intégrés avec Stripe Checkout en environnement de test. Aucune transaction réelle n'est effectuée avec la configuration locale fournie.

## URLs locales

- Frontend : <http://localhost:5173/>
- Backend : <http://localhost:8000/>
- Swagger : <http://localhost:8000/api/docs/swagger/>
- ReDoc : <http://localhost:8000/api/docs/redoc/>
- Administration Django : <http://localhost:8000/admin/>

## Contrôles avant une évolution ou une remise

```powershell
cd backend
.venv\Scripts\python.exe manage.py check
.venv\Scripts\python.exe manage.py makemigrations --check --dry-run
.venv\Scripts\python.exe manage.py test --settings=config.test_settings

cd ..\frontend
npm.cmd run build
```

## Documentation complémentaire

- [Journal de bord](LOGBOOK.md) ;
- [Migration de données historiques](documents/technique/migration-ancienne-base.md) ;
- [Guide Stripe en environnement de test](STRIPE_TESTING.md) ;
- [Plan et notes de versions](BETA_PLAN.md), [beta](RELEASE_BETA.md) et [alpha](RELEASE_ALPHA.md).

Les documents de versions antérieures conservent l'historique du projet. Ils ne remplacent pas les instructions d'installation et de restauration présentes dans ce README.
