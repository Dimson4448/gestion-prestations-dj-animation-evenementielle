from django.contrib import admin

from .models import ClientProfile, DJProfile


@admin.register(ClientProfile)
class ClientProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "preferred_language", "billing_city", "created_at")
    search_fields = ("user__email", "user__first_name", "user__last_name", "billing_city")


@admin.register(DJProfile)
class DJProfileAdmin(admin.ModelAdmin):
    list_display = ("stage_name", "user", "base_hourly_rate", "years_experience", "is_available")
    search_fields = ("stage_name", "user__email")
    list_filter = ("is_available",)
