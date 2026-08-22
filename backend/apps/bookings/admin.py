from django.contrib import admin

from .models import (
    Booking,
    BookingEquipment,
    CancellationRequest,
    Contract,
    Playlist,
    PlaylistSong,
    PreparatoryAppointment,
    Quote,
    QuoteOption,
    Review,
    Venue,
)


class QuoteOptionInline(admin.TabularInline):
    model = QuoteOption
    extra = 0


class BookingEquipmentInline(admin.TabularInline):
    model = BookingEquipment
    extra = 0


@admin.register(Venue)
class VenueAdmin(admin.ModelAdmin):
    list_display = ("name", "city", "postal_code", "has_parking", "distance_km_from_base")
    search_fields = ("name", "city", "postal_code")
    list_filter = ("has_parking", "city")


@admin.register(Quote)
class QuoteAdmin(admin.ModelAdmin):
    list_display = (
        "id", "client", "requested_dj", "event_type", "package", "event_date",
        "dj_decision", "status", "total_amount", "deposit_amount",
    )
    list_filter = ("dj_decision", "status", "event_type", "package", "requested_dj")
    search_fields = ("client__user__email", "client__phone", "requested_dj__stage_name", "venue__name")
    list_select_related = ("client__user", "requested_dj", "event_type", "package")
    inlines = [QuoteOptionInline]


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ("id", "client", "dj", "event_date", "start_time", "status", "total_amount", "deposit_paid")
    list_filter = ("status", "event_type", "deposit_paid")
    search_fields = ("client__user__email", "dj__stage_name", "venue__name")
    inlines = [BookingEquipmentInline]


@admin.register(PreparatoryAppointment)
class PreparatoryAppointmentAdmin(admin.ModelAdmin):
    list_display = ("booking", "scheduled_at", "mode", "status", "response_message")
    list_filter = ("mode", "status")


@admin.register(CancellationRequest)
class CancellationRequestAdmin(admin.ModelAdmin):
    list_display = ("id", "booking", "status", "requested_at", "reviewed_by", "reviewed_at")
    list_filter = ("status", "requested_at")
    search_fields = ("booking__client__user__email", "reason")
    readonly_fields = ("booking", "reason", "requested_at", "reviewed_by", "reviewed_at", "review_message")


@admin.register(Contract)
class ContractAdmin(admin.ModelAdmin):
    list_display = ("contract_number", "booking", "status", "signed_by_client_at", "created_at")
    search_fields = ("contract_number",)
    list_filter = ("status",)


@admin.register(Playlist)
class PlaylistAdmin(admin.ModelAdmin):
    list_display = ("booking", "main_style", "is_public", "created_at")
    list_filter = ("is_public", "main_style")
    search_fields = ("booking__client__user__email",)
    filter_horizontal = ("styles",)


@admin.register(PlaylistSong)
class PlaylistSongAdmin(admin.ModelAdmin):
    list_display = ("title", "artist", "playlist", "preference_level", "status")
    search_fields = ("title", "artist")
    list_filter = ("preference_level", "status")


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ("booking", "client", "dj", "rating", "status", "created_at")
    list_filter = ("rating", "status")
    search_fields = ("comment", "client__user__email", "dj__stage_name")
