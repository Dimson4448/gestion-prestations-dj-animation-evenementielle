# Énoncé des relations entre les tables

Ce document complète le schéma relationnel de la base de données d'Ultimate DJ. Les cardinalités sont indiquées selon les notations `1-1`, `1-0..1`, `1-0..*` et `0..*-0..*`.

## Comptes et profils

- Un utilisateur possède au plus un profil client ; un profil client appartient à un seul utilisateur `[1-0..1]`.
- Un utilisateur possède au plus un profil DJ ; un profil DJ appartient à un seul utilisateur `[1-0..1]`.
- Un utilisateur possède au plus une candidature DJ ; une candidature DJ appartient à un seul utilisateur `[1-0..1]`.
- Un utilisateur ayant le rôle administrateur peut traiter zéro, une ou plusieurs candidatures DJ ; une candidature DJ est traitée par zéro ou un administrateur `[1-0..*]`.
- Un client formule zéro, une ou plusieurs demandes de suppression de compte ; une demande de suppression concerne un seul client `[1-0..*]`.
- Un administrateur peut traiter plusieurs demandes de suppression ; une demande est traitée par zéro ou un administrateur `[1-0..*]`.
- Un utilisateur reçoit zéro, une ou plusieurs notifications ; une notification appartient à un seul utilisateur `[1-0..*]`.
- Un utilisateur possède au plus une préférence de notification ; une préférence de notification appartient à un seul utilisateur `[1-0..1]`.
- Un DJ possède zéro, un ou plusieurs créneaux de disponibilité ; un créneau appartient à un seul DJ `[1-0..*]`.

## Catalogue

- Une formule est compatible avec zéro, un ou plusieurs types d'événement ; un type d'événement peut être compatible avec zéro, une ou plusieurs formules `[0..*-0..*]`. Django crée une table d'association automatique pour cette relation.
- Un DJ pratique zéro, un ou plusieurs styles musicaux ; un style musical peut être associé à zéro, un ou plusieurs DJs `[0..*-0..*]`. Django crée une table d'association automatique pour cette relation.
- Une option de service peut être ajoutée à zéro, un ou plusieurs devis ; un devis peut contenir zéro, une ou plusieurs options de service `[0..*-0..*]`. Cette relation est matérialisée par la table `Options de devis`.
- Un matériel peut être utilisé dans zéro, une ou plusieurs réservations ; une réservation peut nécessiter zéro, un ou plusieurs matériels `[0..*-0..*]`. Cette relation est matérialisée par la table `Matériels de réservation`.

## Devis et réservation

- Un client enregistre zéro, un ou plusieurs lieux ; un lieu appartient à un seul client `[1-0..*]`.
- Un client demande zéro, un ou plusieurs devis ; un devis appartient à un seul client `[1-0..*]`.
- Un DJ peut être demandé dans zéro, un ou plusieurs devis ; un devis désigne zéro ou un DJ demandé `[0..1-0..*]`.
- Un type d'événement apparaît dans zéro, un ou plusieurs devis ; un devis concerne un seul type d'événement `[1-0..*]`.
- Une formule apparaît dans zéro, un ou plusieurs devis ; un devis concerne une seule formule `[1-0..*]`.
- Un lieu peut être utilisé dans zéro, un ou plusieurs devis ; un devis concerne un seul lieu `[1-0..*]`.
- Un devis contient zéro, une ou plusieurs options de devis ; une option de devis appartient à un seul devis `[1-0..*]`.
- Un devis donne lieu à zéro ou une réservation ; une réservation provient d'un seul devis `[1-0..1]`.
- Un client possède zéro, une ou plusieurs réservations ; une réservation concerne un seul client `[1-0..*]`.
- Un DJ réalise zéro, une ou plusieurs réservations ; une réservation est affectée à un seul DJ `[1-0..*]`.
- Un type d'événement apparaît dans zéro, une ou plusieurs réservations ; une réservation concerne un seul type d'événement `[1-0..*]`.
- Une formule apparaît dans zéro, une ou plusieurs réservations ; une réservation concerne une seule formule `[1-0..*]`.
- Un lieu peut être utilisé dans zéro, une ou plusieurs réservations ; une réservation concerne un seul lieu `[1-0..*]`.

## Préparation et suivi du dossier

- Une réservation peut posséder zéro ou un contrat ; un contrat concerne une seule réservation `[1-0..1]`.
- Une réservation possède zéro, un ou plusieurs rendez-vous préparatoires ; un rendez-vous préparatoire concerne une seule réservation `[1-0..*]`.
- Une réservation possède au plus une playlist ; une playlist concerne une seule réservation `[1-0..1]`.
- Une playlist contient zéro, un ou plusieurs morceaux ; un morceau appartient à une seule playlist `[1-0..*]`.
- Une playlist peut utiliser zéro, un ou plusieurs styles musicaux ; un style musical peut être associé à zéro, une ou plusieurs playlists `[0..*-0..*]`. Django crée une table d'association automatique pour cette relation.
- Une réservation contient zéro, un ou plusieurs messages ; un message appartient à une seule réservation `[1-0..*]`.
- Un utilisateur envoie zéro, un ou plusieurs messages de dossier ; un message possède un seul expéditeur `[1-0..*]`.
- Une réservation peut faire l'objet de zéro, une ou plusieurs demandes d'annulation ; une demande d'annulation concerne une seule réservation `[1-0..*]`.
- Un administrateur peut traiter plusieurs demandes d'annulation ; une demande est traitée par zéro ou un administrateur `[1-0..*]`.
- Une réservation peut recevoir zéro, un ou plusieurs avis ; un avis concerne une seule réservation `[1-0..*]`.
- Un client peut publier zéro, un ou plusieurs avis ; un avis est publié par un seul client `[1-0..*]`.
- Un DJ peut recevoir zéro, un ou plusieurs avis ; un avis concerne un seul DJ `[1-0..*]`.

## Facturation et paiements

- Une réservation possède zéro, une ou plusieurs factures ; une facture concerne une seule réservation `[1-0..*]`.
- Une réservation peut recevoir zéro, un ou plusieurs paiements ; un paiement concerne une seule réservation `[1-0..*]`.
- Une facture peut être réglée par zéro, un ou plusieurs paiements ; un paiement règle une seule facture `[1-0..*]`.
- Un paiement peut donner lieu à zéro, un ou plusieurs remboursements ; un remboursement concerne un seul paiement `[1-0..*]`.

## Contraintes importantes

- Les relations plusieurs-à-plusieurs entre DJ et styles musicaux, playlists et styles musicaux, ainsi qu'entre formules et types d'événement sont gérées par des tables d'association créées automatiquement par Django. Elles contiennent les deux clés étrangères nécessaires à chaque relation.
- Un devis n'est associé qu'à une seule réservation grâce à la contrainte d'unicité sur la référence du devis dans la table Réservations (`bookings`).
- Un contrat et une playlist ne peuvent être associés qu'à une seule réservation grâce à leurs références uniques vers la table Réservations (`bookings`).
- Une même option ne peut être ajoutée qu'une seule fois dans un même devis ; une même pièce de matériel ne peut être ajoutée qu'une seule fois dans une même réservation.
- Les références Stripe de session et d'intention de paiement sont uniques lorsqu'elles sont renseignées.
