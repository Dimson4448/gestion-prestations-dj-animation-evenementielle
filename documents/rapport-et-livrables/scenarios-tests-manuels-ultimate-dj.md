# Scénarios de tests manuels — Ultimate DJ

Ce document permet de rejouer les contrôles fonctionnels avant une démonstration ou une mise en ligne. Les données utilisées doivent être fictives ou anonymisées.

## Préparation

- ouvrir l'application dans deux navigateurs distincts ;
- préparer un compte **client**, un compte **DJ confirmé** disposant d'un créneau, et un compte **administrateur** ;
- vérifier que le backend Django et le frontend React sont démarrés ;
- utiliser les cartes de test Stripe uniquement lorsque les clés Stripe de test sont configurées.

## Parcours métier principal

| Étape | Action | Résultat attendu |
| --- | --- | --- |
| 1 | Le client crée une demande de devis avec une date, un lieu et une formule. | La demande est enregistrée et visible dans son espace. |
| 2 | L'administrateur consulte le devis et sélectionne un DJ disponible. | Seuls les DJ couvrant entièrement le créneau peuvent être proposés. |
| 3 | Le DJ accepte la demande depuis son espace. | La réservation, le contrat et la facture d'acompte sont créés. |
| 4 | Le client signe le contrat et accepte explicitement la politique de confidentialité avant le paiement. | Le consentement est requis ; sa date et la version de la politique sont conservées avec le paiement. |
| 5 | Le client paie l'acompte en environnement Stripe de test. | Le paiement est confirmé uniquement après le webhook Stripe signé ; la réservation poursuit son cycle. |

## Conflits de disponibilité

| Cas | Action | Résultat attendu |
| --- | --- | --- |
| DJ déjà réservé | Tenter de faire accepter à un DJ une seconde réservation qui chevauche son créneau confirmé. | Refus côté API et interface : le DJ ne peut pas être affecté deux fois. |
| Client déjà engagé | Tenter de conclure une autre réservation qui chevauche une réservation active du même client. | Refus : le client ne peut pas avoir deux contrats actifs sur le même créneau. |
| Annulation | Annuler officiellement le contrat existant, puis rejouer la demande. | Le créneau peut être réutilisé selon les règles de statut. |
| Créneau partiel | Déclarer un créneau DJ insuffisant pour couvrir la durée de la prestation. | Le DJ n'est pas éligible à l'affectation. |

## Paiement, annulation et remboursement

- vérifier qu'aucun bouton de paiement n'est disponible tant que la case de confidentialité n'est pas cochée ;
- vérifier qu'un retour navigateur sans webhook ne valide pas artificiellement un paiement ;
- déclencher un remboursement depuis l'administration pour un paiement payé ;
- vérifier le montant remboursable, le statut du remboursement et sa trace dans le dossier ;
- en cas de clé Stripe absente, vérifier que l'erreur est explicite et qu'aucun paiement n'est marqué comme payé.

## Communication et documents

- envoyer un message client vers le DJ, puis une réponse DJ vers le client ;
- vérifier que chaque message affiche son auteur, son rôle et sa date ;
- télécharger le dossier associé à une réservation et vérifier son contenu ;
- télécharger le fichier `.ics`, l'ouvrir dans un calendrier et contrôler date, heure et durée ;
- déposer un avis uniquement après une prestation éligible, puis vérifier la modération et la réponse du DJ.

## Sécurité et accès

| Vérification | Résultat attendu |
| --- | --- |
| Visiteur non connecté | Accès aux offres, aux pages légales et à la confidentialité ; aucun accès aux dossiers, paiements ou administration. |
| Client connecté | Accès uniquement à ses devis, réservations, documents, messages et factures. |
| DJ connecté | Accès uniquement à ses demandes, disponibilités, dossiers attribués et avis reçus. |
| Administrateur | Accès aux outils de gestion, export, modération, annulation et remboursement. |
| URL d'une ressource d'autrui | Réponse refusée par l'API, même avec un jeton valide d'un autre rôle. |
| Jeton expiré ou absent | Demande refusée ; l'utilisateur doit se reconnecter. |

## Multilingue et accessibilité de base

- passer de FR à EN puis NL sur l'accueil, le compte et les pages légales ;
- vérifier que le changement ne déconnecte pas l'utilisateur ;
- parcourir les formulaires au clavier avec `Tab`, `Shift+Tab`, `Entrée` et `Espace` ;
- contrôler l'affichage sur une largeur de téléphone et sur ordinateur ;
- vérifier que les erreurs de formulaire sont compréhensibles et qu'elles n'effacent pas les valeurs saisies.

## Contrôles API pour la démonstration

Avec Swagger ou Postman, montrer :

1. `POST /api/v1/auth/token/` : un identifiant et un mot de passe valides produisent un JWT limité dans le temps ;
2. `GET /api/v1/quotes/` : le contenu retourné dépend de l'utilisateur et de son rôle ;
3. `POST /api/v1/booking-messages/` : un message ne peut être créé que dans un dossier auquel l'utilisateur a accès ;
4. une tentative non autorisée ou avec un jeton absent : réponse de refus.

## Traçabilité

Après chaque campagne, consigner la date, l'environnement, les comptes fictifs utilisés, les résultats et les anomalies éventuelles. Les tests automatisés de Django et le build React sont également exécutés par GitHub Actions à chaque envoi sur `main`.
