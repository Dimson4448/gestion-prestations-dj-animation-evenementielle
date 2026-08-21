from django.contrib import admin, messages
from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from django.utils.html import format_html

from .models import AccountDeletionRequest, ClientProfile, DJApplication, DJProfile
from .services import DJApplicationApprovalError, approve_dj_application


@admin.register(ClientProfile)
class ClientProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "preferred_language", "billing_city", "created_at")
    search_fields = ("user__email", "user__first_name", "user__last_name", "billing_city")


@admin.register(AccountDeletionRequest)
class AccountDeletionRequestAdmin(admin.ModelAdmin):
    list_display = ("id", "client", "status", "requested_at", "reviewed_at")
    list_filter = ("status", "requested_at")
    search_fields = ("client__user__username", "client__user__email", "reason")


@admin.register(DJProfile)
class DJProfileAdmin(admin.ModelAdmin):
    list_display = ("stage_name", "user", "base_hourly_rate", "years_experience", "is_available")
    search_fields = ("stage_name", "user__email")
    list_filter = ("is_available",)


@admin.register(DJApplication)
class DJApplicationAdmin(admin.ModelAdmin):
    list_display = ("stage_name", "user", "city", "years_experience", "status", "submitted_at")
    list_filter = ("status", "city", "submitted_at")
    search_fields = ("stage_name", "user__email", "user__first_name", "user__last_name", "city")
    readonly_fields = ("status", "submitted_at", "reviewed_at", "reviewed_by", "identity_download", "insurance_download")
    actions = ("approve_applications", "reject_applications")

    @admin.display(description="Pièce d'identité")
    def identity_download(self, application):
        if not application.pk:
            return "—"
        return format_html('<a href="{}">Télécharger le justificatif</a>', f"/admin/dj-applications/{application.pk}/document/identity/")

    @admin.display(description="Assurance RC")
    def insurance_download(self, application):
        if not application.pk:
            return "—"
        return format_html('<a href="{}">Télécharger le justificatif</a>', f"/admin/dj-applications/{application.pk}/document/insurance/")

    @admin.action(description="Approuver les candidatures sélectionnées")
    def approve_applications(self, request, queryset):
        approved = 0
        for application in queryset.select_related("user"):
            if application.status == DJApplication.REJECTED or not application.user.is_active:
                continue
            try:
                approve_dj_application(application, request.user)
            except DJApplicationApprovalError:
                continue
            else:
                send_mail(
                    "Ultimate DJ - candidature DJ approuvée",
                    "Votre candidature DJ a été approuvée. Vous pouvez maintenant vous connecter à votre espace DJ. Votre profil restera masqué jusqu’à l’activation de vos disponibilités.",
                    settings.DEFAULT_FROM_EMAIL,
                    [application.user.email],
                    fail_silently=True,
                )
                approved += 1
        if approved:
            self.message_user(request, f"{approved} candidature(s) approuvée(s).", messages.SUCCESS)
        else:
            self.message_user(request, "Aucune candidature approuvable : vérifiez le statut et la confirmation de l’e-mail.", messages.WARNING)

    @admin.action(description="Refuser les candidatures sélectionnées")
    def reject_applications(self, request, queryset):
        updated = 0
        for application in queryset.filter(status=DJApplication.PENDING).select_related("user"):
            application.status = DJApplication.REJECTED
            application.review_message = application.review_message or "La candidature ne répond pas encore aux critères de validation Ultimate DJ."
            application.reviewed_at = timezone.now()
            application.reviewed_by = request.user
            application.save(update_fields=["status", "review_message", "reviewed_at", "reviewed_by"])
            send_mail(
                "Ultimate DJ - candidature DJ examinée",
                f"Votre candidature DJ n’a pas été acceptée. Réponse de l’administration : {application.review_message}",
                settings.DEFAULT_FROM_EMAIL,
                [application.user.email],
                fail_silently=True,
            )
            updated += 1
        self.message_user(request, f"{updated} candidature(s) refusée(s).", messages.SUCCESS)
