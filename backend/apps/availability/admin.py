from django.contrib import admin

from .models import DJAvailability


@admin.register(DJAvailability)
class DJAvailabilityAdmin(admin.ModelAdmin):
    list_display = ("dj", "available_date", "start_time", "end_time", "status")
    list_filter = ("status", "available_date")
