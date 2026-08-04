# Release beta — Ultimate DJ

## Identification

- Version : `0.2.0-beta.1`
- Tag prévu : `v0.2.0-beta.1`
- Branche de préparation : `beta/stripe-checkout`

## Objectif de la remise

Cette version répond à la consigne beta en validant l'intégration d'une solution
tierce : **Stripe Checkout**, utilisé en environnement de test pour le paiement
d'un acompte de réservation.

L'intégration repose sur la bibliothèque Python officielle Stripe, Django REST
Framework, l'authentification JWT et le frontend React/Vite.

## Fonctionnalités ajoutées depuis l'alpha

### Backend Django

- création serveur d'une session Stripe Checkout ;
- montant et devise calculés depuis la facture Django ;
- paiement limité aux factures d'acompte envoyées et non payées ;
- isolation des factures selon le client connecté ;
- refus des clés Stripe réelles pendant la beta ;
- endpoint webhook Stripe avec vérification de signature ;
- contrôle du montant, de la devise et des métadonnées ;
- traitement atomique et idempotent des événements ;
- mise à jour synchronisée du paiement, de la facture et de la réservation ;
- gestion des sessions réussies, asynchrones, expirées ou échouées ;
- API des paiements rendue non modifiable directement par les clients.

### Frontend React

- URL du backend configurable avec `VITE_API_BASE_URL` ;
- authentification réelle avec rotation des jetons JWT, renouvellement automatique et révocation à la déconnexion ;
- inscription réelle d'un client avec validation Django et création de son profil ;
- activation du compte par lien temporaire de vérification de l'adresse e-mail ;
- récupération sécurisée du mot de passe par lien temporaire envoyé par e-mail ;
- affichage des factures d'acompte du client ;
- bouton de paiement réservé aux factures envoyées ;
- redirection contrôlée vers le domaine Stripe Checkout ;
- messages de retour après succès ou annulation ;
- confirmation finale laissée au webhook, et non au navigateur ;
- identification visuelle de la version beta.

### Documentation

- plan de développement beta dans `BETA_PLAN.md` ;
- procédure de test reproductible dans `STRIPE_TESTING.md` ;
- exemples de configuration sans clé réelle dans les fichiers `.env.example`.

## Validation effectuée

- 19 tests Django réussis ;
- `manage.py check` sans erreur ;
- aucune migration Django manquante dans le code ;
- migration `payments.0003` appliquée à la base locale ;
- `pip check` sans dépendance Python cassée ;
- build de production Vite réussi ;
- audit npm sans vulnérabilité détectée ;
- aucun secret Stripe réel versionné.

Les tests automatisés simulent les réponses de Stripe et couvrent notamment :

- création d'une session Checkout et conversion du montant en centimes ;
- accès interdit à un visiteur, un autre client ou le DJ ;
- refus des factures en brouillon ou déjà payées ;
- refus d'une clé `sk_live_` ;
- signature de webhook invalide ;
- montant, devise ou métadonnées incohérents ;
- session inconnue ou expirée ;
- réception répétée du même événement.

## Limites connues de la beta

- une démonstration réelle nécessite un compte Stripe en mode test, une clé
  `sk_test_` et Stripe CLI pour transmettre le webhook local ;
- aucune clé Stripe n'est fournie dans le dépôt ;
- l'administrateur doit préparer une réservation et une facture d'acompte
  envoyée avant le test du parcours ;
- les paiements réels en mode production sont volontairement désactivés.

Ces limites sont compatibles avec l'objectif de la beta : valider le choix de
Stripe et son intégration technique avant une future mise en production.

## Procédure de démonstration

Suivre [`STRIPE_TESTING.md`](STRIPE_TESTING.md), puis présenter :

1. la facture d'acompte dans l'administration Django ;
2. la connexion du client dans React ;
3. l'ouverture de Stripe Checkout en mode test ;
4. le paiement avec une carte Stripe de test ;
5. la réception du webhook signé ;
6. la facture et la réservation mises à jour dans Django.
