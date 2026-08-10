# Gestion des prestations DJ et animation événementielle

Projet TFE - Application **Ultimate DJ**.

## Objectif du projet

Ce projet vise à concevoir puis développer une application web permettant de gérer des prestations DJ et d'animation événementielle.

Le périmètre du cahier des charges est strictement limité aux quatre types de
prestations suivants :

- anniversaire enfant ;
- anniversaire adulte ;
- mariage ;
- soirée privée.

Les autres types éventuellement présents dans un historique importé ne sont
jamais proposés pour une nouvelle demande de devis.

L'application devra notamment permettre :

- la consultation des offres commerciales et des options payantes ;
- le choix d'un DJ selon ses disponibilités ;
- la création d'une demande de devis ;
- la gestion des rendez-vous préparatoires pour les gros événements ;
- la génération d'un contrat personnalisé ;
- le paiement sécurisé de l'acompte et du solde via Stripe ;
- le suivi de l'événement ;
- la gestion des playlists, avis clients, langues et matériel.

## Stack technique

- Backend : Django 5 + Django REST Framework
- Frontend : React + Vite
- Internationalisation : i18next + react-i18next (français, anglais, néerlandais)
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

Pour reproduire exactement les versions Python validées par la CI, installer
`requirements-lock.txt`. Le fichier `requirements.txt` conserve les plages de
compatibilité des dépendances directes pour les futures mises à niveau
contrôlées.

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements-lock.txt
copy .env.example .env
python manage.py migrate
python manage.py runserver
```

La configuration locale de référence utilise MariaDB 10.5 ou supérieur sur
le port `3307`, avec la base `ultimate_dj_django` et un utilisateur applicatif
dédié. Le mot de passe doit être renseigné uniquement dans `backend/.env`, qui
est ignoré par Git. Le port peut être adapté si l'instance MariaDB compatible
écoute ailleurs.

Avant d'émettre un contrat ou une facture réelle, compléter également dans
`backend/.env` l'identité légale du prestataire :

```dotenv
BUSINESS_LEGAL_NAME=Ultimate DJ
BUSINESS_ADDRESS=
BUSINESS_COMPANY_NUMBER=
BUSINESS_VAT_NUMBER=
BUSINESS_EMAIL=
BUSINESS_PHONE=
BUSINESS_IBAN=
```

Les champs renseignés apparaissent automatiquement dans les contrats et
factures PDF. Les valeurs vides ne sont pas imprimées et aucune coordonnée
fictive n'est ajoutée par l'application.

L'ancienne base XAMPP sur le port `3306` constitue une source de migration et
une sauvegarde historique. Elle ne doit pas être utilisée directement par
Django 5.2 lorsqu'elle fonctionne encore sous MariaDB 10.4.

Le catalogue historique peut être vérifié puis importé de façon idempotente :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_catalog --dry-run
.venv\Scripts\python.exe manage.py import_legacy_catalog
```

La commande lit uniquement les paramètres `LEGACY_DB_*`, transforme le type
historique `Anniversaire` en `Anniversaire adulte` et conserve également le
type `Anniversaire enfant` créé par les migrations Django.

Les utilisateurs et leurs profils peuvent ensuite être simulés puis importés :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_accounts --dry-run
.venv\Scripts\python.exe manage.py import_legacy_accounts
```

Cet import convertit les rôles historiques en droits Django, conserve les
empreintes de mots de passe PBKDF2 compatibles et reconstruit les profils
clients, les profils DJ et leurs associations de styles musicaux.

Les lieux des clients et les disponibilités des DJ sont importés après les
comptes :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_locations_availability --dry-run
.venv\Scripts\python.exe manage.py import_legacy_locations_availability
```

Cette commande associe chaque lieu et créneau à son profil Django par le
compte historique correspondant. Elle peut être rejouée sans créer de doublon.

Les devis et leurs options sont transférés après les lieux :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_quotes --dry-run
.venv\Scripts\python.exe manage.py import_legacy_quotes
```

Les identifiants historiques des devis sont conservés pour les réservations
associées. Les prix unitaires enregistrés sur les devis restent figés à leur
valeur historique, même lorsque le tarif actuel du catalogue a changé.

Les réservations et leur matériel sont ensuite transférés :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_bookings --dry-run
.venv\Scripts\python.exe manage.py import_legacy_bookings
```

Les identifiants des réservations sont conservés afin de maintenir les liens
avec les contrats, playlists, avis, factures et paiements importés ensuite.

Les contrats, playlists, morceaux et avis sont importés après les réservations :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_service_records --dry-run
.venv\Scripts\python.exe manage.py import_legacy_service_records
```

La commande conserve les signatures et dates historiques, les préférences et
statuts des morceaux ainsi que les notes et statuts de modération des avis.

Les factures et paiements terminent le transfert historique :

```powershell
cd backend
.venv\Scripts\python.exe manage.py import_legacy_finances --dry-run
.venv\Scripts\python.exe manage.py import_legacy_finances
```

La commande conserve les numéros de facture, échéances, montants, statuts,
dates de paiement et identifiants Stripe. Ces données financières restent
exclusivement dans la base MariaDB locale.

Le dump versionné dans `database/dumps/` est volontairement anonymisé : il
contient la structure complète, l'état des migrations et les données publiques
du catalogue, mais aucune donnée d'utilisateur, de profil, de devis, de
réservation, de facture ou de paiement. Les données complètes restent
uniquement dans la base MariaDB locale et dans les sauvegardes privées.

## Démarrage frontend

Les dépendances frontend sont figées à des versions exactes dans
`package.json` et `package-lock.json`. Utiliser `npm ci` sur une nouvelle copie
du projet permet de reproduire l'environnement validé sans mise à niveau
implicite vers une future version de React ou Vite.

```bash
cd frontend
npm ci
copy .env.example .env.local
npm run dev
```

Le fichier `frontend/.env.local` permet de configurer séparément l'API REST et
les liens vers les pages Django :

```dotenv
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_BACKEND_URL=http://localhost:8000
```

Si `VITE_BACKEND_URL` est absent, React déduit automatiquement l'origine du
backend depuis `VITE_API_BASE_URL`. Aucun lien d'administration n'est donc
codé en dur dans les composants.

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

Les notifications d'annulation, de paiement confirmé et de remboursement
utilisent le système d'e-mail Django. En local,
le backend `console` affiche les messages dans le terminal sans envoyer de
courrier. Pour un déploiement réel, remplacer `EMAIL_BACKEND` par
`django.core.mail.backends.smtp.EmailBackend` et renseigner dans
`backend/.env` les paramètres `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER`,
`EMAIL_HOST_PASSWORD`, `EMAIL_USE_TLS` et `DEFAULT_FROM_EMAIL`. Ces identifiants
restent privés et ne doivent jamais être commités. La variable `SECRET_KEY`
doit également rester privée et contenir au moins 32 caractères aléatoires,
car elle signe notamment les jetons JWT Django.

Les sessions JWT utilisent une rotation du jeton de renouvellement. Chaque
ancien jeton est placé en liste noire et la déconnexion React révoque le dernier
jeton côté Django avant de supprimer les informations locales.

Les points d'entrée d'authentification sont limités par adresse IP afin de
réduire les tentatives automatisées : dix connexions par minute et cinq actions
sensibles par minute pour l'inscription, l'activation et la récupération du mot
de passe. Ces seuils sont configurables avec `AUTH_LOGIN_RATE` et
`AUTH_ACCOUNT_ACTION_RATE`.

L'espace client permet également de créer un compte réel depuis React. Django
vérifie l'unicité de l'identifiant et de l'adresse e-mail, applique ses règles
de robustesse au mot de passe, contrôle que le client est majeur, puis crée
atomiquement l'utilisateur et son profil de facturation. Une session JWT est
accessible uniquement après la confirmation de l'adresse e-mail avec le lien
temporaire envoyé par Django. Le compte reste inactif jusque-là et le lien de
confirmation ne peut être utilisé qu'une fois. Si le message est perdu ou si
le lien expire, le formulaire de connexion permet d'en demander un nouveau
sans révéler si l'adresse correspond réellement à un compte en attente.

Le lien « Mot de passe oublié » envoie une URL temporaire à l'adresse du
compte sans révéler publiquement si celle-ci existe. Après validation du lien,
Django applique les mêmes règles de robustesse au nouveau mot de passe et
invalide les jetons JWT créés avec l'ancien mot de passe. En développement, le
lien apparaît dans le terminal Django avec le backend d'e-mail `console`.

Une fois connecté, le client peut consulter et corriger ses coordonnées
personnelles et de facturation depuis React. L'API réserve cette ressource au
propriétaire du profil, conserve l'adresse e-mail vérifiée en lecture seule et
réapplique notamment le contrôle de majorité lors d'une modification.

Le client peut également changer son mot de passe depuis ce profil après avoir
confirmé le mot de passe actuel. Le jeton de renouvellement est placé en liste
noire, les anciens jetons d'accès deviennent invalides et React ferme la session
locale afin d'imposer une nouvelle authentification.

La demande de suppression du compte est désormais enregistrée dans MariaDB au
lieu d'être une simple confirmation visuelle. Le client consulte son historique,
ne peut avoir qu'une demande en attente et peut l'annuler avant traitement.
L'administration retrouve le dossier dans Django Admin afin de vérifier les
obligations contractuelles et comptables avant toute suppression effective.
Elle peut aussi le traiter depuis l'espace React : un refus conserve le compte
avec une réponse motivée, tandis qu'une approbation désactive immédiatement
l'utilisateur et place toutes ses sessions JWT en liste noire. Les écritures et
documents restent conservés pour le suivi légal, et la décision est notifiée
par e-mail.

La note destinée à la publication GitHub se trouve dans
[`RELEASE_BETA.md`](RELEASE_BETA.md). Le tag prévu est `v0.2.0-beta.1` et ne
sera créé qu'après fusion et validation finale.

## État du projet

Le backend Django et le frontend React sont connectés aux principaux parcours
métier réels. Le mapping relationnel comprend les devis, réservations,
contrats, factures, paiements, matériel, playlists, avis clients, rendez-vous
préparatoires et disponibilités des DJ.

## Parcours réel de demande de devis

Le formulaire React ne se limite plus à une simulation :

1. le client se connecte avec son compte Django ;
2. les types d'événements et les formules compatibles sont chargés depuis l'API ;
3. le client sélectionne un lieu existant ou en enregistre un nouveau ;
4. React transmet la demande à `POST /api/v1/quotes/` ;
5. Django vérifie la propriété du lieu et calcule tous les montants ;
6. le devis et les préférences musicales sont enregistrés en base ;
7. le client retrouve le devis et son statut dans son espace ;
8. l'administrateur envoie le devis et affecte un DJ réellement disponible ;
9. l'acceptation crée la réservation, le contrat et la facture d'acompte ;
10. le client signe son contrat puis règle l'acompte avec Stripe Checkout.

Les formules `Mariage Silver` et `Mariage Gold` sont proposées uniquement pour
un mariage. Les formules générales restent disponibles pour les quatre
prestations prévues par le cahier des charges. Django contrôle cette
compatibilité avant tout enregistrement de devis.

## Cycle réel de la prestation et de la facturation

Une réservation confirmée poursuit son cycle dans les espaces React :

1. le client prépare sa playlist et planifie, si nécessaire, un rendez-vous ;
2. le DJ traite les demandes musicales et clôture les rendez-vous effectués ;
3. après l'événement, le DJ ou l'administration marque la prestation réalisée ;
4. Django calcule le montant restant après les factures déjà payées ;
5. une facture de solde unique est créée et proposée dans l'espace client ;
6. Stripe Checkout encaisse le solde et le webhook marque la réservation payée ;
7. le client peut déposer un avis, ensuite modéré par l'administration.

Les contrats et factures peuvent être téléchargés en PDF. Les écritures
financières et les changements de statut sensibles sont contrôlés côté Django,
même lorsque l'action est lancée depuis React.

## Espaces utilisateurs

L'interface est disponible en français, anglais et néerlandais. Le sélecteur
`FR / EN / NL` traduit la navigation, le catalogue, les formulaires, les statuts
et les espaces Client, DJ et Administration avec `i18next` et `react-i18next`.
Le choix est conservé dans le navigateur ; la balise HTML `lang` et l'en-tête
API `Accept-Language` sont synchronisés. Les dates, montants et notes utilisent
la locale belge correspondant à la langue active. Les noms propres et contenus
libres saisis par les utilisateurs restent inchangés.

- **Client** : devis, lieux, contrat, factures, paiements, rendez-vous,
  playlist et avis ;
- **DJ** : prestations affectées, rendez-vous, validation des chansons,
  clôture de prestation et gestion de ses disponibilités ;
- **Administration** : traitement des devis, affectation du DJ, suivi des
  réservations et clôture des prestations.

Les disponibilités disponibles sont publiques. Un DJ ne peut gérer que ses
propres créneaux et ne peut ni modifier ni supprimer un créneau déjà réservé.

Après récupération de cette version, appliquer les migrations :

```powershell
cd backend
.venv\Scripts\python.exe manage.py migrate
```

Le catalogue et les disponibilités affichés par React proviennent exclusivement
de l'API Django. Si le backend est indisponible, l'interface affiche un message
explicite et ne remplace jamais les résultats par des offres ou des DJ fictifs.

## Intégration continue

Le workflow `.github/workflows/ci.yml` contrôle automatiquement les branches de
fonctionnalité et les Pull Requests vers `main`. Il exécute les tests Django avec
une base SQLite temporaire, vérifie les migrations, puis construit le frontend
React après l'exécution de `npm test`. Les secrets locaux et MariaDB ne sont pas
requis.

## Sécurité du déploiement

Le fichier `backend/.env.example` distingue le développement HTTP local d'un
déploiement HTTPS. En production, il faut remplacer les domaines locaux dans
`ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS` et `CSRF_TRUSTED_ORIGINS`, puis activer
la redirection HTTPS, les cookies sécurisés et HSTS. `USE_X_FORWARDED_PROTO` ne
doit être activé que si le proxy d'hébergement définit correctement l'en-tête
`X-Forwarded-Proto`.
