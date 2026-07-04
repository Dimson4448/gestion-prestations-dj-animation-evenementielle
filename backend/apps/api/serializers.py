from rest_framework import serializers

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.bookings.models import Booking, Quote
from apps.catalog.models import EventType, MusicStyle, Package, ServiceOption


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


class DJProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = DJProfile
        fields = ["id", "stage_name", "bio", "base_hourly_rate", "years_experience", "is_available"]


class DJAvailabilitySerializer(serializers.ModelSerializer):
    dj = DJProfileSerializer(read_only=True)

    class Meta:
        model = DJAvailability
        fields = ["id", "dj", "available_date", "start_time", "end_time", "status"]


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
