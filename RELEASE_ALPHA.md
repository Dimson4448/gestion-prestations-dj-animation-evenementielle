# Release alpha - Ultimate DJ

## Version proposée

- Tag Git proposé : `v0.1.0-alpha`
- Date de préparation : 11 juillet 2026
- Statut : prête pour vérification locale avant création de la release GitHub

## Produit Minimum Viable

Cette version alpha fournit un parcours minimum fonctionnel pour l'application Web dynamique Ultimate DJ :

- navigation principale entre Catalogue, Devis, Connexion et Profil ;
- affichage du catalogue principal des formules DJ ;
- synchronisation du catalogue avec l'API locale `/api/v1/packages/` quand le backend est disponible ;
- catalogue de démonstration si l'API locale est indisponible ;
- simulation de devis avec durée, distance, nombre d'invités et acompte prévisionnel ;
- écran de connexion relié au parcours JWT prévu par `/api/v1/auth/token/` ;
- écran d'inscription sous forme de demande alpha ;
- affichage d'un profil client de démonstration ;
- demande de suppression du compte avec retour visuel ;
- liens backend disponibles vers Swagger, ReDoc et l'administration Django dans la documentation projet.

## Vérifications effectuées

Commandes exécutées avec succès :

```bash
cd backend
.venv\Scripts\python.exe manage.py check
.venv\Scripts\python.exe manage.py test

cd ../frontend
npm.cmd run build
```

Contrôles navigateur effectués sur `http://127.0.0.1:5173/` :

- titre du navigateur : `Ultimate DJ - Version alpha` ;
- titre principal en français avec accents corrects ;
- navigation Catalogue, Devis, Connexion et Profil opérationnelle ;
- trois cartes de catalogue visibles en mode démonstration ;
- calcul de devis affiché correctement ;
- demande de suppression du compte confirmée visuellement ;


## Limites assumées de l'alpha

- L'inscription complète côté API n'est pas encore finalisée.
- Le paiement Stripe reste représenté comme parcours prévu, sans transaction réelle.
- Le profil affiché côté frontend utilise encore des données de démonstration.
