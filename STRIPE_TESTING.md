# Tester Stripe Checkout en local

Ce guide valide l'intégration tierce de la version beta sans effectuer de
paiement réel. Les clés et cartes utilisées doivent appartenir au mode test
Stripe.

## 1. Préparer les applications

Depuis PowerShell :

```powershell
cd backend
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
```

Copier `backend/.env.example` vers `backend/.env` si ce fichier local n'existe
pas encore. Ne jamais ajouter `backend/.env` à Git.

## 2. Configurer la clé Stripe de test

Dans le tableau de bord Stripe en environnement de test, récupérer la clé
secrète commençant par `sk_test_`, puis renseigner uniquement le fichier local
`backend/.env` :

```dotenv
STRIPE_SECRET_KEY=sk_test_votre_cle_locale
```

Le backend beta refuse volontairement les clés `sk_live_`.

## 3. Écouter le webhook local

Installer Stripe CLI, s'y connecter, puis conserver ce terminal ouvert :

```powershell
stripe login
stripe listen --events checkout.session.completed,checkout.session.async_payment_succeeded,checkout.session.async_payment_failed,checkout.session.expired --forward-to http://127.0.0.1:8000/api/v1/payments/webhook/
```

La commande affiche un secret commençant par `whsec_`. Le recopier dans
`backend/.env` :

```dotenv
STRIPE_WEBHOOK_SECRET=whsec_secret_affiche_par_stripe_cli
```

Redémarrer Django après toute modification de `.env`.

## 4. Préparer une facture payable

1. Démarrer Django avec `python manage.py runserver`.
2. Ouvrir <http://127.0.0.1:8000/admin/>.
3. Créer ou réutiliser un utilisateur possédant un profil client.
4. Vérifier qu'une réservation appartient à ce client.
5. Créer une facture liée à cette réservation avec :
   - type : `Acompte` ;
   - statut : `Envoyée` ;
   - montant strictement supérieur à zéro ;
   - échéance future.

Une facture en brouillon, annulée ou déjà payée ne peut pas démarrer Checkout.

## 5. Tester depuis React

Dans un second terminal :

```powershell
cd frontend
npm install
copy .env.example .env.local
npm run dev
```

1. Ouvrir <http://127.0.0.1:5173/> puis `Mon compte`.
2. Se connecter avec l'identifiant Django du client et son mot de passe.
3. Repérer la facture d'acompte envoyée.
4. Cliquer sur `Payer l'acompte`.
5. Dans Checkout, utiliser uniquement une carte Stripe de test :
   - numéro : `4242 4242 4242 4242` ;
   - date : une date future, par exemple `12/34` ;
   - CVC : trois chiffres quelconques ;
   - autres champs : valeurs de test.

Après le retour vers React, le message indique que Stripe a transmis le
paiement. Seul le webhook signé confirme définitivement l'acompte.

## 6. Résultat attendu

Dans l'administration Django :

- le paiement passe de `En attente` à `Payé` ;
- l'identifiant de PaymentIntent Stripe est enregistré ;
- la facture passe à `Payée` ;
- `acompte payé` est activé sur la réservation ;
- une réservation au stade préparatoire passe à `Confirmée`.

Relancer les validations automatisées avec :

```powershell
cd backend
.venv\Scripts\python.exe manage.py test
.venv\Scripts\python.exe manage.py check

cd ..\frontend
npm.cmd run build
npm.cmd audit --omit=dev
```

## Sécurité vérifiée

- le montant et la devise proviennent de Django, jamais du navigateur ;
- les factures d'un autre client ne sont pas accessibles ;
- les paiements ne peuvent pas être créés directement par l'API publique ;
- le corps brut et la signature du webhook sont vérifiés ;
- les montants, devises et métadonnées incohérents sont rejetés ;
- un même événement peut être reçu plusieurs fois sans doubler le paiement ;
- aucune clé secrète n'est stockée dans le frontend ou versionnée dans Git.
