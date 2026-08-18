# Logbook du projet Ultimate DJ

Projet : Gestion des prestations DJ et animation événementielle  
Étudiant : Tchamako Vianney Dimitri  
Dépôt GitHub : https://github.com/Dimson4448/gestion-prestations-dj-animation-evenementielle

Dernière mise à jour : 18 août 2026

## Objectif du logbook

Ce logbook retrace les principales décisions, productions et étapes de travail du projet TFE. Il sert à garder une mémoire claire de l'évolution du projet, depuis la récupération des conversations de travail jusqu'à la consolidation actuelle de l'application Django/React. Il couvre le développement des versions alpha et beta ainsi que les parcours client, DJ et administration.

## Historique des étapes

### 2026-06-10 - Récupération des conversations de travail

- Export des conversations ChatGPT contenant les travaux en attente.
- Organisation des conversations récupérées afin de pouvoir poursuivre le projet dans Codex.
- Reprise de la conversation liée à la gestion des prestations DJ et animation événementielle.

### 2026-06-10 à 2026-06-30 - Analyse et modélisation UML

- Vérification de la cohérence des diagrammes de contexte et de cas d'utilisation avec le cahier des charges.
- Ajout du système de paiement dans les diagrammes, avec la mention "système de paiement (Stripe)".
- Élaboration du diagramme de classes selon la logique de Pascal Roques.
- Justification du choix de la généralisation `Utilisateur`.
- Mise à jour progressive des diagrammes pour intégrer devis, contrats, factures, acompte, disponibilité des DJ, rendez-vous préparatoire, suivi de l'événement, matériel, déplacement, playlist, avis clients et langues.

### 2026-07-01 - Diagrammes dynamiques

- Rédaction d'un scénario métier principal orienté réservation d'une prestation DJ.
- Production des diagrammes dynamiques demandés : navigation, activité, séquence système et état-transition.
- Ajout du scénario nominal, des variantes et des cas d'erreurs.
- Justification des choix de design patterns et des décisions de conception.

### 2026-07-02 - Schéma relationnel et dictionnaire de données

- Création du schéma de base de données adapté à l'application Ultimate DJ.
- Production du code DBML compatible avec dbdiagram.io.
- Ajout des cardinalités et des relations principales.
- Création du dictionnaire de données avec tables, champs, types, contraintes, règles de validation, règles de domaine et règles applicatives.
- Ajout des besoins complémentaires : langues, avis clients, styles musicaux, chansons demandées dans la playlist et créneaux de disponibilité des DJ.

### 2026-07-02 - Rapport de conception graphique

- Création du rapport de conception graphique.
- Choix du nom de l'application : Ultimate DJ.
- Proposition et sélection d'un logo en version bannière sur fond sombre.
- Définition des couleurs, polices, logo, icônes, boutons, structure du site, trames et maquettes.

### 2026-07-04 - Rapport écrit version 1

- Préparation du rapport écrit version 1 selon les consignes de l'école.
- Respect de la page de garde fournie.
- Structuration du rapport : introduction, chapitres, conclusion, bibliographie et annexes.
- Intégration des règles de bibliographie ISO 690.
- Conservation d'une version validée du rapport écrit sans modification ultérieure non autorisée.

### 2026-07-04 - Prototype navigable

- Création du prototype navigable PowerPoint.
- Mise en place de plusieurs écrans simulant la navigation de l'application.
- Ajout de liens internes entre les diapositives pour simuler les parcours métier.

### 2026-07-04 - Création du dépôt GitHub

- Création du projet local dans `C:\Users\Tchamako\projets\gestion-prestations-dj-animation-evenementielle`.
- Initialisation du dépôt GitHub : https://github.com/Dimson4448/gestion-prestations-dj-animation-evenementielle
- Ajout des premiers documents de conception dans le dépôt.

### 2026-07-04 - Recherche de progiciels et solutions techniques

- Choix de Django pour le backend.
- Choix de React pour le frontend.
- Choix de MySQL/MariaDB pour la base de données.
- Choix de Django REST Framework pour l'API.
- Choix de drf-spectacular, Swagger UI et ReDoc pour la documentation API.
- Choix de Stripe pour le paiement.
- Choix de FullCalendar pour la gestion visuelle des disponibilités.
- Rédaction du document de recherche de progiciels et solutions techniques avec justification des choix.
- Correction de la bibliographie selon la convention ISO 690 fournie.

### 2026-07-04 - Dump SQL de la base de données

- Création d'un dump SQL MySQL/MariaDB complet pour la base `ultimate_dj`.
- Le dump contient structure, clés primaires, clés étrangères, index, contraintes et données réalistes de test.
- Import du dump dans phpMyAdmin confirmé comme fonctionnel.

### 2026-07-04 - Documentation API et Open Data

- Rédaction du document de documentation API et Open Data.
- Création du fichier OpenAPI `openapi-ultimate-dj-v1.yaml`.
- Définition des endpoints publics, protégés et Open Data.
- Intégration de l'authentification JWT et du versioning `/api/v1/`.

### 2026-07-04 - Déploiement et données de connexion

- Rédaction du document de déploiement.
- Ajout des URL locales prévues : frontend React, backend Django, Swagger, ReDoc et administration Django.
- Ajout des comptes de test par rôle : client, DJ, gestionnaire et administrateur.
- Ajout du dépôt GitHub comme adresse de versioning du projet.

### 2026-07-04 - Starter kit Django/React

- Création du dossier `backend`.
- Création du projet Django avec configuration MySQL/MariaDB, mode SQLite temporaire, Django REST Framework, JWT, Swagger/ReDoc, CORS et premières applications métier.
- Création des apps Django : `accounts`, `catalog`, `availability`, `bookings`, `payments` et `api`.
- Création du dossier `frontend`.
- Création d'une première interface React/Vite.
- Installation des dépendances frontend.
- Lancement du frontend sur `http://localhost:5173/`.
- Installation des dépendances backend.
- Lancement du backend en SQLite local sur `http://localhost:8000/`.
- Création d'un compte administrateur de test : `admin`.

### 2026-07-04 - Premier push GitHub du code

- Création du commit `27d5e9a Initialiser le starter kit Ultimate DJ`.
- Push vers la branche `main` du dépôt GitHub.

### 2026-07-08 - Reprise du backend et mapping relationnel

- Décision de terminer le backend avant de poursuivre le frontend.
- Rappel de la règle : tous les titres et libellés visibles doivent être en français avec accents.
- Enrichissement du mapping relationnel Django :
  - profils client et DJ ;
  - langues ;
  - styles musicaux du DJ ;
  - types d'événements ;
  - packages ;
  - options de service ;
  - matériel ;
  - disponibilités DJ ;
  - lieux ;
  - devis ;
  - options de devis ;
  - réservations ;
  - matériel lié aux réservations ;
  - rendez-vous préparatoires ;
  - contrats ;
  - playlists ;
  - chansons de playlist ;
  - avis clients ;
  - factures ;
  - paiements.
- Ajout des libellés français dans les modèles et l'administration Django.

### 2026-07-08 - Stratégie de sécurité

- Mise en pause temporaire du code pour produire le livrable documentaire demandé.
- Rédaction du document `strategie-securite-ultimate-dj_TCHAMAKO.docx`.
- Prise en compte de l'approche Security by Design.
- Utilisation de l'OWASP Top 10 2025 comme grille de lecture des risques Web.
- Adaptation de la stratégie au projet Ultimate DJ : authentification, autorisation, accès aux ressources, protection des données personnelles, IDS, plan de reprise d'activité, sauvegardes, déploiement et maintenance préventive.
- Ajout d'une bibliographie au format ISO 690.

### 2026-07-09 - Stratégie de référencement SEO / SEA

- Mise en pause du code pour produire le livrable documentaire de référencement.
- Rédaction du document `strategie-referencement-seo-sea-ultimate-dj_TCHAMAKO.docx`.
- Prise en compte de la logique SEM = SEO + SEA + SMO.
- Adaptation de la stratégie au projet Ultimate DJ : SEO technique, contenus, référencement local, multilingue français/anglais/néerlandais, données structurées, Google Ads, SMO, indicateurs de suivi et plan d'action.
- Utilisation des recommandations Google Search Central et d'une bibliographie au format ISO 690.

### 2026-07-09 - Évolution de l'API REST backend

- Enrichissement des serializers Django REST Framework.
- Ajout de liens hypermédia `liens` dans les réponses API pour faciliter la navigation entre les ressources.
- Ajout de permissions API dédiées pour distinguer lecture publique, écriture administrateur et accès aux ressources personnelles.
- Filtrage des ressources métier selon l'utilisateur connecté : client, DJ ou administrateur.
- Amélioration de l'endpoint de calcul de devis informatif.
- Ajout de tests automatisés pour le catalogue public, le calcul de devis, la protection des lieux et la création de lieu par un client connecté.
- Validation de la documentation Swagger/OpenAPI.

### 2026-07-10 - Aspects juridiques et cadre légal

- Mise en pause du code pour produire le livrable documentaire juridique.
- Rédaction du document `aspects-juridiques-cadre-legal-ultimate-dj_TCHAMAKO.docx`.
- Analyse des aspects liés au droit d'Internet, aux informations légales, à la protection des données personnelles, aux cookies, à l'e-commerce, au droit d'auteur, à la responsabilité, aux avis clients, à la vie privée et au droit à l'image.
- Adaptation des obligations au projet Ultimate DJ : devis, contrats, acompte Stripe, facturation, playlists, photos/vidéos d'événements, avis clients et gestion des droits RGPD.
- Ajout d'une bibliographie au format ISO 690.

### 2026-07-11 - Préparation de la version alpha

- Transformation du frontend React en MVP alpha avec navigation principale, catalogue, simulation de devis, connexion, inscription et profil client.
- Ajout d'une demande de suppression du compte dans l'écran Profil.
- Vérification des titres et libellés visibles en français avec accents corrects.
- Ajout d'une note de release locale `RELEASE_ALPHA.md` avec le tag proposé `v0.1.0-alpha`.
- Validation locale du backend Django, des tests API et du build frontend.

### 2026-07-19 - Finalisation et publication de la version alpha

- Finalisation de l'interface alpha React et de la page d'accueil Ultimate DJ.
- Intégration du logo officiel, des couleurs du rapport graphique et du favicon Vite demandé.
- Ajout d'une page d'accueil Django sur `http://127.0.0.1:8000/` avec un accès à l'administration.
- Prise en compte des quatre prestations du cahier des charges : anniversaire enfant, anniversaire adulte, mariage et soirée privée.
- Vérification du frontend, du backend et de la documentation de remise alpha.
- Fusion de la Pull Request alpha dans `main` et création de la première version GitHub.

### 2026-07-20 au 2026-07-21 - Développement de la version beta Stripe

- Découpage du travail beta en tâches courtes et versionnées.
- Intégration de Stripe Checkout en environnement de test pour les acomptes.
- Création sécurisée des sessions de paiement côté Django.
- Ajout du webhook Stripe signé, idempotent et contrôlé par montant, devise et métadonnées.
- Connexion de l'espace client React à l'API avec authentification JWT.
- Affichage des factures réelles et limitation du paiement aux factures envoyées et impayées.
- Gestion des retours de succès et d'annulation de Stripe Checkout.
- Ajout de tests d'autorisation, de cas d'erreur et d'une procédure de démonstration locale.
- Rédaction de `BETA_PLAN.md`, `STRIPE_TESTING.md` et `RELEASE_BETA.md`.
- Fusion de la version beta Stripe Checkout dans `main`.

### 2026-07-23 au 2026-07-27 - Parcours réel de devis et synchronisation MariaDB

- Sécurisation de la création des devis par les clients connectés.
- Gestion des lieux, calcul des estimations et enregistrement réel des demandes de devis.
- Affichage des devis réels dans l'espace client et ajout du suivi administratif.
- Configuration du backend Django sur la base MariaDB `ultimate_dj_django`.
- Import des données historiques : catalogue, comptes, lieux, disponibilités, devis, réservations, prestations et finances.
- Mise à jour du dump SQL selon les migrations Django appliquées.
- Automatisation de l'acceptation des devis et création de la réservation correspondante.
- Ajout de l'espace administrateur React, de la signature des contrats et de la génération des contrats et factures PDF.
- Sécurisation des ressources propres à chaque client.
- Développement des playlists et des rendez-vous préparatoires dans Django et React.

### 2026-08-03 - Finalisation des parcours client et DJ

- Ajout du workflow des avis clients après une prestation réalisée.
- Gestion de la facture de solde et de son paiement dans l'espace client.
- Création de l'espace DJ React pour consulter les prestations affectées.
- Ajout des outils DJ : rendez-vous, validation des chansons, clôture de prestation et disponibilités.
- Protection des créneaux réservés contre la modification ou la suppression par un DJ.

### 2026-08-04 - Annulations, remboursements et comptes utilisateurs

- Traçabilité des remboursements Stripe et synchronisation par webhook.
- Ajout des demandes d'annulation client et de leur traitement administratif.
- Mise à jour des contrats et factures PDF après annulation ou remboursement.
- Envoi de notifications par e-mail pour les annulations, paiements et remboursements.
- Rotation automatique des jetons JWT et révocation à la déconnexion.
- Création réelle des comptes clients avec validation de majorité à 18 ans.
- Vérification de l'adresse e-mail, renvoi des liens d'activation et récupération sécurisée du mot de passe.
- Modification du profil, changement du mot de passe et demandes de suppression de compte.

### 2026-08-06 au 2026-08-09 - Qualité, sécurité et données réelles

- Limitation des tentatives d'authentification par adresse IP.
- Mise en place de GitHub Actions pour les tests Django, les migrations et le build React.
- Renforcement de la configuration de déploiement et séparation des secrets dans les fichiers `.env` ignorés par Git.
- Ajout des premiers tests unitaires frontend et des tests des règles métier React.
- Découpage de la navigation en composants et ajout d'une gestion globale des erreurs.
- Amélioration de l'accessibilité au clavier.
- Remplacement des données fictives par le catalogue, les disponibilités et les avis réels provenant de Django.
- Configuration centralisée des URL du backend et de l'API.

### 2026-08-10 au 2026-08-11 - Cohérence métier et internationalisation

- Verrouillage des versions des dépendances Python et JavaScript.
- Configuration de l'identité légale utilisée dans les PDF.
- Restriction définitive du catalogue aux quatre prestations prévues par le cahier des charges.
- Association des formules aux prestations compatibles.
- Internationalisation du frontend avec `i18next` en français, anglais et néerlandais.
- Traduction des espaces client, DJ et administration avec conservation des accents UTF-8.
- Ajout de la recherche mondiale des villes avec priorité aux villes et communes belges.
- Traduction des noms de lieux selon la langue active et suppression des valeurs présélectionnées.
- Restauration des styles de Django Admin et masquage des messages techniques du catalogue.

### 2026-08-14 au 2026-08-18 - Consolidation du projet TFE

- Ajout des remboursements partiels Stripe avec validation des montants.
- Renforcement de la clé JWT utilisée par les tests automatisés.
- Création et versionnement du manuel d'utilisation détaillé.
- Développement de la candidature DJ sécurisée avec justificatifs privés, validation de majorité, confirmation de l'e-mail et approbation administrative.
- Création automatique du profil DJ uniquement après validation de la candidature.
- Séparation stricte des rôles : Django Admin réservé aux administrateurs et espace React dédié aux DJ confirmés.
- Validation complète de 91 tests Django et 37 tests frontend.
- Actualisation de la note de version beta selon l'état réel du dépôt.

## État actuel et prochaines étapes

- Le backend Django, le frontend React, MariaDB, Stripe en mode test et les principaux parcours métier sont intégrés.
- Les quatre prestations prévues par le cahier des charges sont respectées.
- Les espaces client, DJ et administration disposent de contrôles d'accès distincts.
- Les prochaines étapes portent sur les tests manuels de bout en bout, la préparation d'un déploiement HTTPS et la configuration ultérieure de Stripe en production.
- Le dump MariaDB doit continuer à être actualisé lorsqu'une migration ou une modification de données de référence le nécessite.
