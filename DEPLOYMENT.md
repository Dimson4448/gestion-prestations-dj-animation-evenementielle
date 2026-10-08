# Mise en production — Ultimate DJ

Les secrets ne doivent jamais être ajoutés à Git : ils sont renseignés dans les variables d'environnement de l'hébergeur.

## HTTPS et domaine

1. Placer Django et le frontend derrière un proxy HTTPS avec certificat valide.
2. Définir `DJANGO_DEBUG=False`, une `SECRET_KEY` aléatoire et les domaines réels dans `ALLOWED_HOSTS`.
3. Remplacer les origines locales dans `CORS_ALLOWED_ORIGINS`, `CSRF_TRUSTED_ORIGINS`, `FRONTEND_URL` et les URL Stripe par des URL `https://`.
4. Après validation : activer `SECURE_SSL_REDIRECT=True`, les cookies sécurisés, `USE_X_FORWARDED_PROTO=True` et HSTS (`31536000`).

## Paiements et e-mails

1. Utiliser les clés Stripe de production et enregistrer le webhook `https://votre-domaine/api/v1/payments/webhook/`.
2. Surveiller les journaux `apps.payments` : chaque webhook reçu, rejeté ou inconnu y est tracé.
3. Configurer les variables `EMAIL_*` dans l'environnement de production et envoyer un e-mail de test après tout changement de fournisseur.

## Sauvegardes

1. Réaliser une sauvegarde MariaDB chiffrée chaque jour, conservée hors du serveur principal.
2. Garder au moins sept sauvegardes quotidiennes et une sauvegarde mensuelle.
3. Tester chaque mois une restauration dans une base isolée.
4. Inclure les documents privés et les médias dans la stratégie de sauvegarde.

## Exploitation

1. Utiliser des comptes administrateurs nominatifs et ne jamais partager un compte superutilisateur.
2. Mettre en place une alerte sur les réponses HTTP 5xx, les erreurs Stripe et l'échec d'une sauvegarde.
3. Avant chaque déploiement : `python manage.py check --deploy`, migrations et suite de tests en préproduction.

## Tâches planifiées

Planifier chaque matin la commande suivante avec le planificateur de l'hébergeur ou Windows Task Scheduler :

`python manage.py send_payment_reminders --days 3`

Tester d'abord avec `--dry-run`. La tâche doit utiliser les mêmes variables d'environnement sécurisées que Django et ses sorties doivent être envoyées vers la journalisation de production.
