from rest_framework import serializers

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.bookings.models import (
    Booking,
    Contract,
    Playlist,
    PlaylistSong,
    PreparatoryAppointment,
    Quote,
    Review,
    Venue,
)
from apps.catalog.models import Equipment, EventType, MusicStyle, Package, ServiceOption
from apps.payments.models import Invoice, Payment


class EventTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = EventType
        fields = ["id", "name", "requires_preparatory_meeting"]


class MusicStyleSerializer(serializers.ModelSerializer):
    class Meta:
        model = MusicStyle
        fields = ["id", "name"]


class PackageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Package
        fields = ["id", "name", "description", "included_hours", "base_price", "is_active"]


class ServiceOptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceOption
        fields = ["id", "name", "price_type", "unit_price", "is_active"]


class EquipmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Equipment
        fields = ["id", "category", "name", "serial_number", "daily_cost", "replacement_value", "status"]


class DJProfileSerializer(serializers.ModelSerializer):
    music_styles = MusicStyleSerializer(many=True, read_only=True)

    class Meta:
        model = DJProfile
        fields = [
            "id",
            "stage_name",
            "bio",
            "music_styles",
            "base_hourly_rate",
            "travel_rate_per_km",
            "years_experience",
            "is_available",
        ]


class DJAvailabilitySerializer(serializers.ModelSerializer):
    dj = DJProfileSerializer(read_only=True)

    class Meta:
        model = DJAvailability
        fields = ["id", "dj", "available_date", "start_time", "end_time", "status", "reason"]


class VenueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Venue
        fields = "__all__"


class QuoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quote
        fields = "__all__"
        read_only_fields = ["subtotal", "travel_fee", "total_amount", "deposit_amount", "created_at"]


class BookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = "__all__"
        read_only_fields = ["created_at"]


class PreparatoryAppointmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = PreparatoryAppointment
        fields = "__all__"


class ContractSerializer(serializers.ModelSerializer):
    class Meta:
        model = Contract
        fields = "__all__"
        read_only_fields = ["created_at"]


class InvoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invoice
        fields = "__all__"
        read_only_fields = ["issued_at"]


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = "__all__"


class PlaylistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = "__all__"
        read_only_fields = ["created_at"]


class PlaylistSongSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlaylistSong
        fields = "__all__"


class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = "__all__"
        read_only_fields = ["created_at"]


class QuoteCalculationRequestSerializer(serializers.Serializer):
    package_id = serializers.IntegerField(label="Identifiant du package")
    duration_hours = serializers.DecimalField(label="Durée en heures", max_digits=4, decimal_places=1)
    distance_km = serializers.DecimalField(label="Distance en km", max_digits=6, decimal_places=2, default=0)


class QuoteCalculationResponseSerializer(serializers.Serializer):
    subtotal = serializers.DecimalField(label="Sous-total", max_digits=10, decimal_places=2)
    travel_fee = serializers.DecimalField(label="Frais de déplacement", max_digits=10, decimal_places=2)
    total_amount = serializers.DecimalField(label="Montant total", max_digits=10, decimal_places=2)
    deposit_amount = serializers.DecimalField(label="Montant de l'acompte", max_digits=10, decimal_places=2)
