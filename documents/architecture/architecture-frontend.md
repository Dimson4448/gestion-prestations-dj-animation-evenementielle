# Architecture du frontend Ultimate DJ

## Objectif

Le frontend est une application React construite avec Vite. Son rôle est de présenter les quatre prestations prévues par le cahier des charges, de guider le visiteur vers une demande de devis et de proposer des espaces distincts aux clients, aux DJ confirmés et aux administrateurs.

Le découpage actuel évite de concentrer toute l'interface et tous les chargements API dans `App.jsx`. Ce fichier conserve principalement la navigation générale, l'authentification et l'orchestration des domaines.

## Organisation des responsabilités

### Pages

- `HomePage` : accueil, recherche initiale et présentation des ambiances.
- `OffersPage` : filtres, disponibilités publiques et résultats DJ.
- `PackageDetailPage` : détail d'une formule et démarrage d'une demande de devis.
- `QuoteRequestPage` : formulaire du devis, choix du lieu et estimation.
- `DJWorkspacePage` : prestations affectées, rendez-vous, demandes musicales et disponibilités.
- `AdminWorkspacePage` : traitement des devis, affectation des DJ, annulations, remboursements et suppressions de compte.

Les pages secondaires sont chargées à la demande avec `React.lazy` et `Suspense`. L'accueil ne télécharge donc pas immédiatement le code des tableaux de bord ou du formulaire de devis. Vite produit un fichier JavaScript distinct pour chaque page métier.

### Hooks métier

- `useCatalogue()` charge les formules, les types d'événements autorisés et les disponibilités publiques.
- `useClientAccount()` charge les données privées du client et remet les collections à zéro lorsque la session n'est plus valide.
- `useOperationalWorkspaces()` charge les tableaux de bord DJ et Administration en respectant le rôle du compte connecté.

### Composants fonctionnels

Les sections importantes de l'espace client sont séparées en composants : devis, contrats, factures, rendez-vous, avis et demandes de suppression. L'en-tête, le pied de page, le formulaire de candidature DJ et le résumé de session sont également indépendants.

## Patterns employés

### Composants de présentation

Les pages reçoivent les données et actions nécessaires par propriétés. Elles restent concentrées sur le rendu et ne connaissent pas les détails de stockage du jeton ou de configuration d'Axios.

### Hooks de domaine

Les effets React et les appels de chargement sont regroupés par domaine. Cette organisation correspond à une séparation de type *Container/Presentational Components* : les hooks préparent les données, tandis que les pages les affichent.

### Couche d'accès API

Le client Axios centralisé applique l'adresse de l'API, l'authentification JWT et la gestion des sessions expirées. `unwrapApiList()` adapte de façon uniforme les réponses directes et les réponses paginées de Django REST Framework.

### Contrôle d'accès par rôle

La navigation et les chargements privés vérifient le rôle réel renvoyé par le backend. Un client ne reçoit pas les données DJ ou administratives. Un DJ confirmé accède à son espace métier, tandis que Django Admin reste réservé aux comptes administrateurs.

## Flux principaux

1. Le visiteur choisit une prestation, une date et un lieu.
2. Le catalogue et les disponibilités proviennent de l'API Django.
3. Le visiteur consulte une formule puis complète une demande de devis.
4. L'administration contrôle la demande, affecte un DJ disponible et prépare le dossier.
5. Le client suit ensuite ses contrats, factures, paiements, rendez-vous et playlists.
6. Le DJ consulte uniquement les prestations qui lui sont affectées et met à jour leur préparation.

## Validation technique

Les fonctions sans dépendance visuelle sont couvertes par les tests Node du frontend : calcul du devis, règles de réservation, prestations autorisées, traductions, navigation, remboursements, rôles et normalisation des réponses API. Le build Vite constitue un second contrôle avant chaque livraison.

Les secrets Stripe, le mot de passe MariaDB et les paramètres locaux restent dans `backend/.env`, qui est exclu de Git.
