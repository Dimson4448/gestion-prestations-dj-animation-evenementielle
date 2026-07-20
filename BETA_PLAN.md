# Plan de développement — version beta

## Objectif

La version beta valide l'intégration d'une solution tierce avec un paiement
d'acompte Stripe Checkout en **mode test**. Aucune clé réelle ne doit être
versionnée et aucun paiement réel ne doit être effectué pendant cette phase.

## Parcours retenu

1. L'administrateur dispose d'une réservation et d'une facture d'acompte.
2. Le client authentifié demande la création d'une session Stripe Checkout.
3. Django calcule le montant depuis la facture, crée la session côté serveur et
   renvoie uniquement son URL au frontend.
4. React redirige le client vers la page de paiement hébergée par Stripe.
5. Stripe appelle le webhook Django après le paiement de test.
6. Django vérifie la signature puis marque le paiement, la facture et l'acompte
   de la réservation comme payés.

## Découpage et commits prévus

- Tâche 1 : préparer la configuration Stripe test et le plan beta.
- Tâche 2 : créer le service backend et l'endpoint de session Checkout.
- Tâche 3 : traiter le webhook Stripe de façon sécurisée et idempotente.
- Tâche 4 : connecter le parcours de paiement à l'interface React.
- Tâche 5 : couvrir l'intégration, les erreurs et les permissions par des tests.
- Tâche 6 : finaliser la documentation, les contrôles et la note de release.
- Publication : créer le tag et la Release GitHub beta après validation.

Chaque tâche terminée et vérifiée fera l'objet d'un commit distinct.

## Configuration locale

Les valeurs suivantes sont documentées dans `backend/.env.example` :

- `STRIPE_SECRET_KEY` : clé secrète Stripe de test (`sk_test_...`) ;
- `STRIPE_WEBHOOK_SECRET` : secret de signature du webhook (`whsec_...`) ;
- `STRIPE_SUCCESS_URL` : retour frontend après paiement ;
- `STRIPE_CANCEL_URL` : retour frontend après annulation.

Les secrets restent uniquement dans `backend/.env`, ignoré par Git.

## Critères de validation beta

- une session Checkout test est créée uniquement pour une facture d'acompte
  autorisée et non payée ;
- le montant et la devise proviennent du backend ;
- une signature de webhook invalide est refusée ;
- les doublons de webhook ne créent pas de paiement supplémentaire ;
- l'état payé n'est confirmé qu'après un événement Stripe vérifié ;
- les tests Django et le build React réussissent ;
- aucun secret Stripe n'est présent dans l'historique Git.
