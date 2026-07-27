from datetime import date
from decimal import Decimal

from rest_framework import serializers
from rest_framework.reverse import reverse
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import extend_schema_field

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


class LiensHypermediaMixin(serializers.Serializer):
    liens = serializers.SerializerMethodField(label="Liens")
    route_basename = None

    @extend_schema_field(OpenApiTypes.OBJECT)
    def get_liens(self, obj):
        request = self.context.get("request")
        if not request or not self.route_basename or not getattr(obj, "pk", None):
            return {}

        detail = reverse(f"{self.route_basename}-detail", kwargs={"pk": obj.pk}, request=request)
        return {
            "ressource": detail,
            "liste": reverse(f"{self.route_basename}-list", request=request),
            "modifier": detail,
            "supprimer": detail,
        }


class EventTypeSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "event-type"

    class Meta:
        model = EventType
        fields = ["id", "name", "requires_preparatory_meeting", "liens"]


class MusicStyleSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "music-style"

    class Meta:
        model = MusicStyle
        fields = ["id", "name", "liens"]


class PackageSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "package"

    @extend_schema_field(OpenApiTypes.OBJECT)
    def get_liens(self, obj):
        liens = super().get_liens(obj)
        request = self.context.get("request")
        if request:
            liens["calculer_devis"] = reverse("quote-calculate", request=request)
        return liens

    class Meta:
        model = Package
        fields = ["id", "name", "description", "included_hours", "base_price", "is_active", "liens"]


class ServiceOptionSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "service-option"

    class Meta:
        model = ServiceOption
        fields = ["id", "name", "price_type", "unit_price", "is_active", "liens"]


class EquipmentSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "equipment"

    class Meta:
        model = Equipment
        fields = ["id", "category", "name", "serial_number", "daily_cost", "replacement_value", "status", "liens"]


class DJProfileSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "dj"
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
            "liens",
        ]


class DJAvailabilitySerializer(serializers.ModelSerializer):
    dj = DJProfileSerializer(read_only=True)
    liens = serializers.SerializerMethodField(label="Liens")

    class Meta:
        model = DJAvailability
        fields = ["id", "dj", "available_date", "start_time", "end_time", "status", "reason", "liens"]

    @extend_schema_field(OpenApiTypes.OBJECT)
    def get_liens(self, obj):
        request = self.context.get("request")
        if not request:
            return {}
        return {
            "liste": reverse("availability-list", request=request),
            "dj": reverse("dj-detail", kwargs={"pk": obj.dj_id}, request=request),
        }


class VenueSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "venue"

    class Meta:
        model = Venue
        fields = [
            "id",
            "client",
            "name",
            "street",
            "postal_code",
            "city",
            "country",
            "has_parking",
            "distance_km_from_base",
            "liens",
        ]
        extra_kwargs = {"client": {"required": False}}


class QuoteSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "quote"

    class Meta:
        model = Quote
        fields = [
            "id",
            "client",
            "event_type",
            "package",
            "venue",
            "event_date",
            "start_time",
            "duration_hours",
            "guest_count",
            "distance_km",
            "parking_available",
            "status",
            "subtotal",
            "travel_fee",
            "total_amount",
            "deposit_amount",
            "music_preferences",
            "created_at",
            "liens",
        ]
        read_only_fields = ["subtotal", "travel_fee", "total_amount", "deposit_amount", "created_at"]
        extra_kwargs = {"client": {"required": False}}

    def validate_event_date(self, value):
        if value < date.today():
            raise serializers.ValidationError("La date de l'événement ne peut pas être passée.")
        return value

    def validate_duration_hours(self, value):
        if value <= 0:
            raise serializers.ValidationError("La durée doit être supérieure à 0 heure.")
        return value

    def validate_distance_km(self, value):
        if value < 0:
            raise serializers.ValidationError("La distance ne peut pas être négative.")
        return value

    def validate(self, attrs):
        attrs = super().validate(attrs)
        request = self.context.get("request")
        if not request or request.user.is_staff:
            return attrs

        client = getattr(request.user, "client_profile", None)
        if not client:
            raise serializers.ValidationError("Un profil client est requis pour demander un devis.")

        venue = attrs.get("venue") or getattr(self.instance, "venue", None)
        if venue and venue.client_id != client.id:
            raise serializers.ValidationError({"venue": "Ce lieu n'appartient pas au client connecté."})

        package = attrs.get("package") or getattr(self.instance, "package", None)
        if package and not package.is_active:
            raise serializers.ValidationError({"package": "Ce package n'est plus disponible."})

        if "status" in self.initial_data:
            raise serializers.ValidationError({"status": "Le statut du devis est géré par l'administration."})
        return attrs


class QuoteAcceptanceSerializer(serializers.Serializer):
    dj = serializers.PrimaryKeyRelatedField(
        queryset=DJProfile.objects.filter(is_available=True),
        label="DJ sélectionné",
    )


class BookingSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "booking"

    class Meta:
        model = Booking
        fields = [
            "id",
            "quote",
            "client",
            "dj",
            "event_type",
            "package",
            "venue",
            "equipment",
            "event_date",
            "start_time",
            "end_time",
            "status",
            "total_amount",
            "deposit_required",
            "deposit_paid",
            "cancellation_reason",
            "created_at",
            "liens",
        ]
        read_only_fields = ["created_at"]
        extra_kwargs = {"client": {"required": False}}


class PreparatoryAppointmentSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "appointment"

    class Meta:
        model = PreparatoryAppointment
        fields = ["id", "booking", "scheduled_at", "mode", "status", "notes", "liens"]


class ContractSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "contract"

    class Meta:
        model = Contract
        fields = [
            "id",
            "booking",
            "contract_number",
            "status",
            "refund_policy",
            "signed_by_client_at",
            "created_at",
            "liens",
        ]
        read_only_fields = ["created_at"]


class InvoiceSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "invoice"

    class Meta:
        model = Invoice
        fields = ["id", "booking", "invoice_number", "invoice_type", "amount", "status", "issued_at", "due_at", "liens"]
        read_only_fields = ["issued_at"]


class PaymentSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "payment"

    class Meta:
        model = Payment
        fields = [
            "id",
            "booking",
            "invoice",
            "stripe_session_id",
            "stripe_payment_intent_id",
            "amount",
            "currency",
            "status",
            "paid_at",
            "liens",
        ]
        read_only_fields = fields


class PlaylistSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "playlist"

    class Meta:
        model = Playlist
        fields = ["id", "booking", "main_style", "notes", "created_at", "liens"]
        read_only_fields = ["created_at"]


class PlaylistSongSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "playlist-song"

    class Meta:
        model = PlaylistSong
        fields = ["id", "playlist", "title", "artist", "preference_level", "status", "liens"]


class ReviewSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "review"

    class Meta:
        model = Review
        fields = ["id", "booking", "client", "dj", "rating", "comment", "status", "created_at", "liens"]
        read_only_fields = ["created_at"]
        extra_kwargs = {"client": {"required": False}, "dj": {"required": False}}


class QuoteCalculationRequestSerializer(serializers.Serializer):
    package_id = serializers.IntegerField(label="Identifiant du package")
    duration_hours = serializers.DecimalField(label="Durée en heures", max_digits=4, decimal_places=1)
    distance_km = serializers.DecimalField(label="Distance en km", max_digits=6, decimal_places=2, default=0)

    def validate_duration_hours(self, value):
        if value <= 0:
            raise serializers.ValidationError("La durée doit être supérieure à 0 heure.")
        return value

    def validate_distance_km(self, value):
        if value < 0:
            raise serializers.ValidationError("La distance ne peut pas être négative.")
        return value

    def validate_package_id(self, value):
        if not Package.objects.filter(is_active=True, pk=value).exists():
            raise serializers.ValidationError("Le package demandé est introuvable ou inactif.")
        return value


class QuoteCalculationResponseSerializer(serializers.Serializer):
    subtotal = serializers.DecimalField(label="Sous-total", max_digits=10, decimal_places=2)
    travel_fee = serializers.DecimalField(label="Frais de déplacement", max_digits=10, decimal_places=2)
    total_amount = serializers.DecimalField(label="Montant total", max_digits=10, decimal_places=2)
    deposit_amount = serializers.DecimalField(label="Montant de l'acompte", max_digits=10, decimal_places=2)
    currency = serializers.CharField(label="Devise")
    liens = serializers.DictField(label="Liens")


def calculate_quote_amounts(package, duration_hours, distance_km):
    duration_hours = Decimal(duration_hours)
    distance_km = Decimal(distance_km)
    extra_hours = max(duration_hours - package.included_hours, Decimal("0"))
    subtotal = package.base_price + extra_hours * Decimal("95.00")
    travel_fee = distance_km * Decimal("0.65")
    total_amount = subtotal + travel_fee
    return {
        "subtotal": subtotal.quantize(Decimal("0.01")),
        "travel_fee": travel_fee.quantize(Decimal("0.01")),
        "total_amount": total_amount.quantize(Decimal("0.01")),
        "deposit_amount": (total_amount * Decimal("0.30")).quantize(Decimal("0.01")),
    }
