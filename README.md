# Gestion des prestations DJ et animation événementielle

Projet TFE - Application **Ultimate DJ**.

## Objectif du projet

Ce projet vise à concevoir puis développer une application web permettant de gérer des prestations DJ et d'animation événementielle.

L'application devra notamment permettre :

- la consultation des offres commerciales et des options payantes ;
- le choix d'un DJ selon ses disponibilités ;
- la création d'une demande de devis ;
- la gestion des rendez-vous préparatoires pour les gros événements ;
- la génération d'un contrat personnalisé ;
- le paiement d'un acompte via un système de paiement (Stripe) ;
- le suivi de l'événement ;
- la gestion des playlists, avis clients, langues et matériel.

## Stack technique

- Backend : Django 5 + Django REST Framework
- Frontend : React + Vite
- Base de données : MySQL/MariaDB
- Documentation API : drf-spectacular, Swagger UI et ReDoc
- Paiement : Stripe

## Structure du projet

```text
backend/     Application Django et API REST
frontend/    Interface React
api/         Fichiers OpenAPI
database/    Dump SQL MySQL/MariaDB
documents/   Livrables de conception et documents TFE
```

## Journal de bord

Le logbook du projet se trouve dans :

```text
documents/logbook/logbook-projet-ultimate-dj.md
```

Il retrace les principales décisions, productions et étapes de travail depuis la récupération des conversations de départ jusqu'au développement du backend.

## Démarrage backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
python manage.py makemigrations
python manage.py migrate
python manage.py runserver
```

## Démarrage frontend

```bash
cd frontend
npm install
copy .env.example .env.local
npm run dev
```

## URLs locales prévues

- Frontend : <http://localhost:5173/>
- Backend : <http://localhost:8000/>
- Swagger : <http://localhost:8000/api/docs/swagger/>
- ReDoc : <http://localhost:8000/api/docs/redoc/>
- Administration Django : <http://localhost:8000/admin/>

## Préparation alpha

Commandes de contrôle validées pour préparer une version alpha locale :

```bash
cd backend
.venv\Scripts\python.exe manage.py check
.venv\Scripts\python.exe manage.py makemigrations --check --dry-run
.venv\Scripts\python.exe manage.py test

cd ../frontend
npm.cmd run build
```

État vérifié le 11 juillet 2026 :

- les checks Django ne signalent aucune erreur ;
- aucune migration Django n'est en attente ;
- les tests API existants passent depuis le dossier `backend/` ;
- le build de production Vite passe côté frontend ;
- l'interface React alpha propose une navigation principale, un catalogue, une simulation de devis, un écran de connexion, un écran d'inscription et un profil client avec demande de suppression du compte.

La note de release locale se trouve dans :

```text
RELEASE_ALPHA.md
```

Le tag Git proposé pour la publication est `v0.1.0-alpha`. La release GitHub doit être créée uniquement après validation explicite.

## Préparation beta

La beta valide Stripe Checkout en mode test pour le paiement sécurisé d'un
acompte. Le périmètre, les tâches et les critères de validation sont décrits
dans [`BETA_PLAN.md`](BETA_PLAN.md). Chaque tâche beta terminée est vérifiée et
enregistrée dans un commit distinct avant la création de la Release GitHub.

Le protocole complet de configuration et de démonstration locale est disponible
dans [`STRIPE_TESTING.md`](STRIPE_TESTING.md).

La note destinée à la publication GitHub se trouve dans
[`RELEASE_BETA.md`](RELEASE_BETA.md). Le tag prévu est `v0.2.0-beta.1` et ne
sera créé qu'après fusion et validation finale.

## État du projet

Le starter kit Django/React est initialisé. La priorité actuelle est de terminer le backend Django avant de poursuivre le frontend React. Le mapping relationnel a été enrichi avec les entités métier principales : devis, réservations, contrats, factures, paiements, matériel, playlists, avis clients et rendez-vous préparatoires.
