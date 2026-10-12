# Release de remise académique — Ultimate DJ

## Identification

- Version : `0.3.0-tfe.1`
- Tag Git : `v0.3.0-tfe.1`
- Branche : `main`
- Statut : livraison académique prête à déployer

## Contenu de la release

- application Django et React couvrant les parcours visiteur, client, DJ et administrateur ;
- gestion des devis, affectations, contrats, réservations, disponibilités, rendez-vous, playlists, messages, avis, factures, paiements et remboursements ;
- paiements Stripe Checkout en environnement de test, avec webhook et contrôles d'idempotence ;
- interface disponible en français, anglais et néerlandais ;
- pages de mentions légales et de confidentialité cohérentes avec le fonctionnement de l'application ;
- dump MariaDB contenant le schéma, les migrations appliquées et les données de démonstration, sans jetons de session ;
- diagrammes UML, schéma relationnel, dictionnaire de données, cahier des charges, rapport final et captures du manuel utilisateur.

## Vérifications avant release

- `python manage.py check` sans erreur ;
- migrations Django appliquées ;
- build React de production validé ;
- README, logbook et dump MariaDB actualisés ;
- absence de fichiers `.env`, de clés Stripe et de jetons de session dans le dépôt.

## Limites connues

- Stripe reste configuré exclusivement en environnement de test ;
- le déploiement HTTPS et la configuration de production restent des étapes séparées de cette release académique ;
- les données du dump sont destinées à la démonstration et ne constituent pas des données de production.
