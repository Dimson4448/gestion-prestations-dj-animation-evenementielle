from django.contrib import admin

from .models import Equipment, EventType, MusicStyle, Package, ServiceOption


@admin.register(EventType)
class EventTypeAdmin(admin.ModelAdmin):
    list_display = ("name", "requires_preparatory_meeting")
    search_fields = ("name",)
    list_filter = ("requires_preparatory_meeting",)


@admin.register(MusicStyle)
class MusicStyleAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)


@admin.register(Package)
class PackageAdmin(admin.ModelAdmin):
    list_display = ("name", "included_hours", "base_price", "is_active")
    search_fields = ("name", "description")
    list_filter = ("is_active",)
    filter_horizontal = ("event_types",)


@admin.register(ServiceOption)
class ServiceOptionAdmin(admin.ModelAdmin):
    list_display = ("name", "price_type", "unit_price", "is_active")
    search_fields = ("name",)
    list_filter = ("price_type", "is_active")


@admin.register(Equipment)
class EquipmentAdmin(admin.ModelAdmin):
    list_display = ("name", "category", "serial_number", "daily_cost", "status")
    search_fields = ("name", "serial_number", "category")
    list_filter = ("category", "status")
