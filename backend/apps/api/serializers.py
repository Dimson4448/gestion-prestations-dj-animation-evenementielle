from datetime import date, datetime, timedelta
from decimal import Decimal

from rest_framework import serializers
from rest_framework.reverse import reverse
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.tokens import default_token_generator
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import transaction
from django.utils import timezone
from django.utils.encoding import force_str
from django.utils.http import urlsafe_base64_decode
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import extend_schema_field
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import AccountDeletionRequest, ClientProfile, DJApplication, DJProfile, validate_adult
from apps.availability.models import DJAvailability
from apps.bookings.models import (
    Booking,
    CancellationRequest,
    Contract,
    Playlist,
    PlaylistSong,
    PreparatoryAppointment,
    Quote,
    Review,
    Venue,
)
from apps.catalog.models import Equipment, EventType, MusicStyle, Package, ServiceOption
from apps.payments.models import Invoice, Payment, Refund


class CurrentUserSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    username = serializers.CharField(read_only=True)
    email = serializers.EmailField(read_only=True)
    first_name = serializers.CharField(read_only=True)
    last_name = serializers.CharField(read_only=True)
    is_staff = serializers.BooleanField(read_only=True)
    role = serializers.SerializerMethodField()

    @extend_schema_field(OpenApiTypes.STR)
    def get_role(self, user):
        if user.is_staff:
            return "admin"
        if hasattr(user, "dj_profile"):
            return "dj"
        if hasattr(user, "dj_application"):
            return "dj_candidate"
        if hasattr(user, "client_profile"):
            return "client"
        return "user"


class ClientProfileUpdateSerializer(serializers.Serializer):
    first_name = serializers.CharField(max_length=150)
    last_name = serializers.CharField(max_length=150)
    email = serializers.EmailField(read_only=True)
    date_of_birth = serializers.DateField()
    phone = serializers.CharField(max_length=30)
    billing_address = serializers.CharField(max_length=255)
    billing_city = serializers.CharField(max_length=80)
    billing_postal_code = serializers.CharField(max_length=20)
    preferred_language = serializers.ChoiceField(choices=ClientProfile._meta.get_field("preferred_language").choices)

    def validate_date_of_birth(self, value):
        try:
            validate_adult(value)
        except DjangoValidationError as exc:
            raise serializers.ValidationError(list(exc.messages)) from exc
        return value

    def to_representation(self, user):
        profile = user.client_profile
        return {
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "date_of_birth": profile.date_of_birth,
            "phone": profile.phone,
            "billing_address": profile.billing_address,
            "billing_city": profile.billing_city,
            "billing_postal_code": profile.billing_postal_code,
            "preferred_language": profile.preferred_language,
        }

    @transaction.atomic
    def update(self, user, validated_data):
        user_fields = []
        for field in ("first_name", "last_name"):
            if field in validated_data:
                setattr(user, field, validated_data.pop(field))
                user_fields.append(field)
        if user_fields:
            user.save(update_fields=user_fields)

        profile = user.client_profile
        profile_fields = []
        for field, value in validated_data.items():
            setattr(profile, field, value)
            profile_fields.append(field)
        if profile_fields:
            profile.save(update_fields=profile_fields)
        return user


class AccountDeletionRequestSerializer(serializers.ModelSerializer):
    client_email = serializers.EmailField(source="client.user.email", read_only=True)
    client_name = serializers.SerializerMethodField()

    class Meta:
        model = AccountDeletionRequest
        fields = ["id", "client_email", "client_name", "reason", "status", "review_message", "requested_at", "reviewed_at"]
        read_only_fields = ["id", "client_email", "client_name", "status", "review_message", "requested_at", "reviewed_at"]

    @extend_schema_field(OpenApiTypes.STR)
    def get_client_name(self, obj):
        return obj.client.user.get_full_name() or obj.client.user.username

    def validate_reason(self, value):
        value = value.strip()
        if len(value) < 10:
            raise serializers.ValidationError("Expliquez votre demande en au moins 10 caractères.")
        return value


class AccountDeletionReviewSerializer(serializers.Serializer):
    decision = serializers.ChoiceField(choices=[AccountDeletionRequest.APPROVED, AccountDeletionRequest.REJECTED])
    review_message = serializers.CharField(min_length=10)


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField(write_only=True, trim_whitespace=False)


class PasswordChangeSerializer(serializers.Serializer):
    current_password = serializers.CharField(write_only=True, trim_whitespace=False)
    new_password = serializers.CharField(write_only=True, trim_whitespace=False)
    refresh = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate(self, attrs):
        user = self.context["request"].user
        if not user.check_password(attrs["current_password"]):
            raise serializers.ValidationError({"current_password": "Le mot de passe actuel est incorrect."})
        try:
            validate_password(attrs["new_password"], user=user)
        except DjangoValidationError as exc:
            raise serializers.ValidationError({"new_password": list(exc.messages)}) from exc
        try:
            refresh = RefreshToken(attrs["refresh"])
        except TokenError as exc:
            raise serializers.ValidationError({"refresh": "Le jeton de renouvellement est invalide ou révoqué."}) from exc
        if str(refresh.get("user_id")) != str(user.pk):
            raise serializers.ValidationError({"refresh": "Ce jeton n'appartient pas à la session connectée."})
        attrs["refresh_token"] = refresh
        return attrs

    @transaction.atomic
    def save(self):
        user = self.context["request"].user
        self.validated_data["refresh_token"].blacklist()
        user.set_password(self.validated_data["new_password"])
        user.save(update_fields=["password"])
        return user


class ClientRegistrationSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, trim_whitespace=False)
    first_name = serializers.CharField(max_length=150)
    last_name = serializers.CharField(max_length=150)
    date_of_birth = serializers.DateField()
    phone = serializers.CharField(max_length=30)
    billing_address = serializers.CharField(max_length=255)
    billing_city = serializers.CharField(max_length=80)
    billing_postal_code = serializers.CharField(max_length=20)
    preferred_language = serializers.ChoiceField(choices=ClientProfile._meta.get_field("preferred_language").choices, default="fr")

    def validate_username(self, value):
        if get_user_model().objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError("Cet identifiant est déjà utilisé.")
        return value

    def validate_email(self, value):
        value = get_user_model().objects.normalize_email(value)
        if get_user_model().objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("Cette adresse e-mail est déjà utilisée.")
        return value

    def validate_date_of_birth(self, value):
        try:
            validate_adult(value)
        except DjangoValidationError as exc:
            raise serializers.ValidationError(list(exc.messages)) from exc
        return value

    def validate(self, attrs):
        candidate = get_user_model()(
            username=attrs["username"],
            email=attrs["email"],
            first_name=attrs["first_name"],
            last_name=attrs["last_name"],
        )
        try:
            validate_password(attrs["password"], user=candidate)
        except DjangoValidationError as exc:
            raise serializers.ValidationError({"password": list(exc.messages)}) from exc
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        profile_fields = {
            key: validated_data.pop(key)
            for key in (
                "date_of_birth",
                "phone",
                "billing_address",
                "billing_city",
                "billing_postal_code",
                "preferred_language",
            )
        }
        password = validated_data.pop("password")
        user = get_user_model().objects.create_user(password=password, is_active=False, **validated_data)
        ClientProfile.objects.create(user=user, **profile_fields)
        return user


class DJApplicationRegistrationSerializer(serializers.ModelSerializer):
    username = serializers.CharField(max_length=150, write_only=True)
    email = serializers.EmailField(write_only=True)
    password = serializers.CharField(write_only=True, trim_whitespace=False)
    first_name = serializers.CharField(max_length=150, write_only=True)
    last_name = serializers.CharField(max_length=150, write_only=True)

    class Meta:
        model = DJApplication
        fields = [
            "username", "email", "password", "first_name", "last_name", "stage_name",
            "date_of_birth", "phone", "city", "preferred_language", "bio", "music_styles",
            "base_hourly_rate", "years_experience", "identity_document", "insurance_document",
        ]

    def validate_username(self, value):
        if get_user_model().objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError("Cet identifiant est déjà utilisé.")
        return value

    def validate_email(self, value):
        value = get_user_model().objects.normalize_email(value)
        if get_user_model().objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("Cette adresse e-mail est déjà utilisée.")
        return value

    def validate_stage_name(self, value):
        if DJProfile.objects.filter(stage_name__iexact=value).exists() or DJApplication.objects.filter(stage_name__iexact=value).exists():
            raise serializers.ValidationError("Ce nom de scène est déjà utilisé.")
        return value

    def validate(self, attrs):
        candidate = get_user_model()(
            username=attrs["username"], email=attrs["email"],
            first_name=attrs["first_name"], last_name=attrs["last_name"],
        )
        try:
            validate_password(attrs["password"], user=candidate)
        except DjangoValidationError as exc:
            raise serializers.ValidationError({"password": list(exc.messages)}) from exc
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user_fields = {key: validated_data.pop(key) for key in ("username", "email", "first_name", "last_name")}
        password = validated_data.pop("password")
        user = get_user_model().objects.create_user(password=password, is_active=False, **user_fields)
        return DJApplication.objects.create(user=user, **validated_data)


class DJApplicationStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = DJApplication
        fields = ["stage_name", "status", "review_message", "submitted_at", "reviewed_at"]
        read_only_fields = fields


class EmailVerificationSerializer(serializers.Serializer):
    uid = serializers.CharField()
    token = serializers.CharField()

    def validate(self, attrs):
        try:
            user_id = force_str(urlsafe_base64_decode(attrs["uid"]))
            user = get_user_model().objects.get(pk=user_id)
        except (ValueError, TypeError, OverflowError, get_user_model().DoesNotExist) as exc:
            raise serializers.ValidationError({"token": "Ce lien de vérification est invalide ou expiré."}) from exc
        if user.is_active or not default_token_generator.check_token(user, attrs["token"]):
            raise serializers.ValidationError({"token": "Ce lien de vérification est invalide ou expiré."})
        attrs["user"] = user
        return attrs

    def save(self):
        user = self.validated_data["user"]
        user.is_active = True
        user.save(update_fields=["is_active"])
        return user


class EmailVerificationResendSerializer(serializers.Serializer):
    email = serializers.EmailField()


class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class PasswordResetConfirmSerializer(serializers.Serializer):
    uid = serializers.CharField()
    token = serializers.CharField()
    password = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate(self, attrs):
        try:
            user_id = force_str(urlsafe_base64_decode(attrs["uid"]))
            user = get_user_model().objects.get(pk=user_id, is_active=True)
        except (ValueError, TypeError, OverflowError, get_user_model().DoesNotExist) as exc:
            raise serializers.ValidationError({"token": "Ce lien de réinitialisation est invalide ou expiré."}) from exc
        if not default_token_generator.check_token(user, attrs["token"]):
            raise serializers.ValidationError({"token": "Ce lien de réinitialisation est invalide ou expiré."})
        try:
            validate_password(attrs["password"], user=user)
        except DjangoValidationError as exc:
            raise serializers.ValidationError({"password": list(exc.messages)}) from exc
        attrs["user"] = user
        return attrs

    def save(self):
        user = self.validated_data["user"]
        user.set_password(self.validated_data["password"])
        user.save(update_fields=["password"])
        return user


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

    def validate_name(self, value):
        if value not in EventType.ALLOWED_NAMES:
            raise serializers.ValidationError("Ce type de prestation ne fait pas partie du cahier des charges.")
        return value


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
        fields = ["id", "name", "description", "included_hours", "base_price", "is_active", "event_types", "liens"]


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
    average_rating = serializers.FloatField(read_only=True)
    review_count = serializers.IntegerField(read_only=True)

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
            "average_rating",
            "review_count",
            "liens",
        ]


class DJAvailabilitySerializer(serializers.ModelSerializer):
    dj = DJProfileSerializer(read_only=True)
    dj_id = serializers.PrimaryKeyRelatedField(
        source="dj",
        queryset=DJProfile.objects.all(),
        write_only=True,
        required=False,
    )
    liens = serializers.SerializerMethodField(label="Liens")

    class Meta:
        model = DJAvailability
        fields = ["id", "dj", "dj_id", "available_date", "end_date", "start_time", "end_time", "status", "reason", "liens"]
        validators = []

    def validate(self, attrs):
        attrs = super().validate(attrs)
        request = self.context.get("request")
        available_date = attrs.get("available_date", getattr(self.instance, "available_date", None))
        start_time = attrs.get("start_time", getattr(self.instance, "start_time", None))
        end_time = attrs.get("end_time", getattr(self.instance, "end_time", None))
        end_date = attrs.get("end_date", getattr(self.instance, "end_date", None)) or available_date
        attrs["end_date"] = end_date
        target_status = attrs.get("status", getattr(self.instance, "status", DJAvailability.AVAILABLE))

        if available_date and available_date < date.today():
            raise serializers.ValidationError({"available_date": "Un créneau ne peut pas être placé dans le passé."})
        if available_date and end_date and end_date < available_date:
            raise serializers.ValidationError({"end_date": "La date de fin ne peut pas précéder la date de début."})
        if available_date == end_date and start_time and end_time and end_time <= start_time:
            raise serializers.ValidationError({"end_time": "Sur une même date, l'heure de fin doit être postérieure à l'heure de début."})
        if self.instance is None and request and request.user.is_staff and "dj" not in attrs:
            raise serializers.ValidationError({"dj_id": "Sélectionnez le DJ concerné."})
        if request and not request.user.is_staff:
            if self.instance and self.instance.status in {DJAvailability.RESERVED, DJAvailability.OCCUPIED}:
                raise serializers.ValidationError({"status": "Un créneau réservé ou occupé ne peut être modifié par le DJ."})
            if target_status in {DJAvailability.RESERVED, DJAvailability.OCCUPIED}:
                raise serializers.ValidationError({"status": "Les statuts réservé et occupé sont gérés automatiquement."})
            attrs.pop("dj", None)

        dj = attrs.get("dj") or getattr(self.instance, "dj", None)
        if dj is None and request:
            dj = getattr(request.user, "dj_profile", None)
        if dj and available_date and start_time:
            duplicate = DJAvailability.objects.filter(
                dj=dj,
                available_date=available_date,
                start_time=start_time,
            )
            if self.instance:
                duplicate = duplicate.exclude(pk=self.instance.pk)
            if duplicate.exists():
                raise serializers.ValidationError({"start_time": "Ce créneau existe déjà pour cette date."})
        return attrs

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
    client_details = serializers.SerializerMethodField()
    venue_details = serializers.SerializerMethodField()
    event_type_name = serializers.CharField(source="event_type.name", read_only=True)
    package_name = serializers.CharField(source="package.name", read_only=True)

    def _can_view_private_details(self, obj):
        request = self.context.get("request")
        if not request or not request.user.is_authenticated:
            return False
        if request.user.is_staff:
            return True
        dj = getattr(request.user, "dj_profile", None)
        return bool(dj and obj.requested_dj_id == dj.id)

    @extend_schema_field(OpenApiTypes.OBJECT)
    def get_client_details(self, obj):
        if not self._can_view_private_details(obj):
            return None
        user = obj.client.user
        return {
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "phone": obj.client.phone,
        }

    @extend_schema_field(OpenApiTypes.OBJECT)
    def get_venue_details(self, obj):
        if not self._can_view_private_details(obj):
            return None
        return {
            "name": obj.venue.name,
            "street": obj.venue.street,
            "postal_code": obj.venue.postal_code,
            "city": obj.venue.city,
            "country": obj.venue.country,
        }

    class Meta:
        model = Quote
        fields = [
            "id",
            "client",
            "client_details",
            "requested_dj",
            "dj_decision",
            "dj_decided_at",
            "event_type",
            "event_type_name",
            "package",
            "package_name",
            "venue",
            "venue_details",
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
        read_only_fields = ["client_details", "venue_details", "dj_decision", "dj_decided_at", "subtotal", "travel_fee", "total_amount", "deposit_amount", "created_at"]
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
        event_type = attrs.get("event_type") or getattr(self.instance, "event_type", None)
        if event_type and event_type.name not in EventType.ALLOWED_NAMES:
            raise serializers.ValidationError({"event_type": "Ce type de prestation n'est plus proposé."})

        package = attrs.get("package") or getattr(self.instance, "package", None)
        if package and not package.is_active:
            raise serializers.ValidationError({"package": "Ce package n'est plus disponible."})
        if package and event_type and not package.event_types.filter(pk=event_type.pk).exists():
            raise serializers.ValidationError({"package": "Cette formule n'est pas compatible avec la prestation choisie."})

        request = self.context.get("request")
        if not request or request.user.is_staff:
            return attrs

        client = getattr(request.user, "client_profile", None)
        if not client:
            raise serializers.ValidationError("Un profil client est requis pour demander un devis.")

        venue = attrs.get("venue") or getattr(self.instance, "venue", None)
        if venue and venue.client_id != client.id:
            raise serializers.ValidationError({"venue": "Ce lieu n'appartient pas au client connecté."})

        requested_dj = attrs.get("requested_dj") or getattr(self.instance, "requested_dj", None)
        if requested_dj and not requested_dj.is_available:
            raise serializers.ValidationError({"requested_dj": "Ce DJ n'est plus disponible."})
        event_date = attrs.get("event_date") or getattr(self.instance, "event_date", None)
        start_time = attrs.get("start_time") or getattr(self.instance, "start_time", None)
        duration = attrs.get("duration_hours") or getattr(self.instance, "duration_hours", None)
        if requested_dj and event_date and start_time and duration:
            event_start = datetime.combine(event_date, start_time)
            event_end = event_start + timedelta(seconds=int(duration * 3600))
            slots = DJAvailability.objects.filter(
                dj=requested_dj,
                available_date__lte=event_date,
                status=DJAvailability.AVAILABLE,
            )
            covers_event = any(
                datetime.combine(slot.available_date, slot.start_time) <= event_start
                and datetime.combine(slot.end_date or slot.available_date, slot.end_time) >= event_end
                for slot in slots
            )
            if not covers_event:
                raise serializers.ValidationError({"requested_dj": "Le créneau de ce DJ ne couvre pas toute la prestation."})
        if "status" in self.initial_data:
            raise serializers.ValidationError({"status": "Le statut du devis est géré par l'administration."})
        return attrs


class QuoteAcceptanceSerializer(serializers.Serializer):
    dj = serializers.PrimaryKeyRelatedField(
        queryset=DJProfile.objects.filter(is_available=True),
        label="DJ sélectionné",
    )


class QuoteDJDecisionSerializer(serializers.Serializer):
    decision = serializers.ChoiceField(choices=[Quote.DJ_ACCEPTED, Quote.DJ_REFUSED])


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
            "end_date",
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


class BookingCancellationSerializer(serializers.Serializer):
    reason = serializers.CharField(max_length=255, min_length=5)


class CancellationRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = CancellationRequest
        fields = ["id", "booking", "reason", "status", "requested_at", "reviewed_at", "reviewed_by", "review_message"]
        read_only_fields = fields


class CancellationRequestReviewSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=255, min_length=5)


class PreparatoryAppointmentSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "appointment"

    class Meta:
        model = PreparatoryAppointment
        fields = ["id", "booking", "scheduled_at", "mode", "status", "notes", "response_message", "liens"]

    def validate(self, attrs):
        attrs = super().validate(attrs)
        request = self.context.get("request")
        booking = attrs.get("booking") or getattr(self.instance, "booking", None)
        scheduled_at = attrs.get("scheduled_at") or getattr(self.instance, "scheduled_at", None)
        if booking is None or scheduled_at is None:
            return attrs

        schedule_is_created_or_changed = self.instance is None or "scheduled_at" in attrs
        if schedule_is_created_or_changed:
            if scheduled_at <= timezone.now():
                raise serializers.ValidationError({"scheduled_at": "Le rendez-vous doit être planifié dans le futur."})
            event_start = timezone.make_aware(datetime.combine(booking.event_date, booking.start_time))
            latest_appointment = event_start - timedelta(hours=24)
            if scheduled_at > latest_appointment:
                raise serializers.ValidationError({"scheduled_at": "Le rendez-vous doit avoir lieu au plus tard 24 heures avant le début de l'événement."})
        if not booking.event_type.requires_preparatory_meeting:
            raise serializers.ValidationError({"booking": "Ce type d'événement ne nécessite pas de rendez-vous préparatoire."})
        if not booking.deposit_paid or booking.status not in {Booking.CONFIRMED, Booking.PERFORMED, Booking.PAID}:
            raise serializers.ValidationError({"booking": "La réservation doit être confirmée par le paiement de l'acompte."})

        target_status = attrs.get("status", getattr(self.instance, "status", PreparatoryAppointment.PROPOSED))
        if self.instance and target_status == PreparatoryAppointment.DONE and scheduled_at > timezone.now():
            raise serializers.ValidationError({"status": "Le rendez-vous ne peut pas être réalisé avant l'heure prévue."})
        active_statuses = [PreparatoryAppointment.PROPOSED, PreparatoryAppointment.COUNTER_PROPOSED, PreparatoryAppointment.ACCEPTED]
        if target_status in active_statuses:
            duplicate = PreparatoryAppointment.objects.filter(booking=booking, status__in=active_statuses)
            if self.instance:
                duplicate = duplicate.exclude(pk=self.instance.pk)
            if duplicate.exists():
                raise serializers.ValidationError({"booking": "Un rendez-vous préparatoire est déjà planifié pour cette réservation."})

        if not request or request.user.is_staff:
            return attrs
        client = getattr(request.user, "client_profile", None)
        dj = getattr(request.user, "dj_profile", None)
        if not ((client and booking.client_id == client.pk) or (dj and booking.dj_id == dj.pk)):
            raise serializers.ValidationError({"booking": "Cette réservation ne vous appartient pas."})
        if self.instance and "booking" in attrs and attrs["booking"].pk != self.instance.booking_id:
            raise serializers.ValidationError({"booking": "La réservation du rendez-vous ne peut pas être modifiée."})
        response_message = attrs.get("response_message", getattr(self.instance, "response_message", "")).strip()
        if client:
            if self.instance is None and "status" in self.initial_data:
                raise serializers.ValidationError({"status": "Une nouvelle demande est automatiquement transmise au DJ."})
            if self.instance:
                if self.instance.status != PreparatoryAppointment.COUNTER_PROPOSED or target_status not in {PreparatoryAppointment.ACCEPTED, PreparatoryAppointment.REFUSED}:
                    raise serializers.ValidationError({"status": "Le client peut uniquement accepter ou refuser une contre-proposition du DJ."})
                if any(field in attrs for field in ("booking", "scheduled_at", "mode", "notes")):
                    raise serializers.ValidationError("La date et le mode d'une contre-proposition ne peuvent être modifiés que par le DJ.")
        if dj and self.instance is None:
            raise serializers.ValidationError({"booking": "La première proposition de rendez-vous doit être envoyée par le client."})
        if dj and self.instance:
            allowed = {PreparatoryAppointment.ACCEPTED, PreparatoryAppointment.REFUSED, PreparatoryAppointment.COUNTER_PROPOSED}
            if self.instance.status == PreparatoryAppointment.ACCEPTED:
                allowed = {PreparatoryAppointment.DONE, PreparatoryAppointment.CANCELLED}
            if target_status not in allowed:
                raise serializers.ValidationError({"status": "Cette décision n'est pas autorisée pour ce rendez-vous."})
            if target_status == PreparatoryAppointment.COUNTER_PROPOSED and "scheduled_at" not in attrs:
                raise serializers.ValidationError({"scheduled_at": "Indiquez une nouvelle date et heure pour la contre-proposition."})
        response_required = target_status == PreparatoryAppointment.COUNTER_PROPOSED or (dj and target_status == PreparatoryAppointment.REFUSED)
        if response_required and len(response_message) < 5:
            raise serializers.ValidationError({"response_message": "Expliquez le refus ou la contre-proposition en au moins 5 caractères."})
        return attrs

    def create(self, validated_data):
        request = self.context.get("request")
        if request and getattr(request.user, "client_profile", None):
            validated_data["status"] = PreparatoryAppointment.PROPOSED
            validated_data["response_message"] = ""
        return super().create(validated_data)


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
    refunded_amount = serializers.SerializerMethodField()
    refundable_amount = serializers.SerializerMethodField()
    refund_status = serializers.SerializerMethodField()

    @staticmethod
    def _refunds(payment):
        return list(payment.refunds.all())

    @extend_schema_field(serializers.DecimalField(max_digits=10, decimal_places=2))
    def get_refunded_amount(self, payment):
        total = sum((refund.amount for refund in self._refunds(payment) if refund.status == Refund.SUCCEEDED), Decimal("0.00"))
        return f"{total:.2f}"

    @extend_schema_field(serializers.DecimalField(max_digits=10, decimal_places=2))
    def get_refundable_amount(self, payment):
        reserved = sum(
            (refund.amount for refund in self._refunds(payment) if refund.status not in {Refund.FAILED, Refund.CANCELLED}),
            Decimal("0.00"),
        )
        return f"{max(payment.amount - reserved, Decimal('0.00')):.2f}"

    @extend_schema_field(OpenApiTypes.STR)
    def get_refund_status(self, payment):
        refunds = self._refunds(payment)
        if any(refund.status == Refund.PENDING for refund in refunds):
            return "pending"
        if payment.status == Payment.REFUNDED:
            return "succeeded"
        if any(refund.status == Refund.SUCCEEDED for refund in refunds):
            return "partial"
        if any(refund.status == Refund.FAILED for refund in refunds):
            return "failed"
        return "none"

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
            "refund_status",
            "refunded_amount",
            "refundable_amount",
            "paid_at",
            "liens",
        ]
        read_only_fields = fields


class RefundRequestSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=Decimal("0.01"), required=False)
    reason = serializers.ChoiceField(choices=Refund.REASON_CHOICES, default=Refund.REQUESTED_BY_CUSTOMER)
    internal_reason = serializers.CharField(max_length=255, min_length=5)


class RefundSerializer(serializers.ModelSerializer):
    class Meta:
        model = Refund
        fields = [
            "id",
            "payment",
            "stripe_refund_id",
            "amount",
            "currency",
            "reason",
            "internal_reason",
            "status",
            "created_at",
            "processed_at",
        ]
        read_only_fields = fields


class PlaylistSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "playlist"

    class Meta:
        model = Playlist
        fields = ["id", "booking", "main_style", "notes", "created_at", "liens"]
        read_only_fields = ["created_at"]

    def validate(self, attrs):
        attrs = super().validate(attrs)
        request = self.context.get("request")
        booking = attrs.get("booking") or getattr(self.instance, "booking", None)
        if not request or request.user.is_staff or booking is None:
            return attrs

        client = getattr(request.user, "client_profile", None)
        dj = getattr(request.user, "dj_profile", None)
        if not ((client and booking.client_id == client.pk) or (dj and booking.dj_id == dj.pk)):
            raise serializers.ValidationError({"booking": "Cette réservation ne vous appartient pas."})
        if not booking.deposit_paid or booking.status not in {Booking.CONFIRMED, Booking.PERFORMED, Booking.PAID}:
            raise serializers.ValidationError({"booking": "La réservation doit être confirmée par le paiement de l'acompte."})
        if self.instance and "booking" in attrs and attrs["booking"].pk != self.instance.booking_id:
            raise serializers.ValidationError({"booking": "La réservation d'une playlist ne peut pas être modifiée."})
        return attrs


class PlaylistSongSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "playlist-song"

    class Meta:
        model = PlaylistSong
        fields = ["id", "playlist", "title", "artist", "preference_level", "status", "liens"]

    def validate(self, attrs):
        attrs = super().validate(attrs)
        request = self.context.get("request")
        playlist = attrs.get("playlist") or getattr(self.instance, "playlist", None)
        if not request or request.user.is_staff or playlist is None:
            return attrs

        booking = playlist.booking
        client = getattr(request.user, "client_profile", None)
        dj = getattr(request.user, "dj_profile", None)
        if not ((client and booking.client_id == client.pk) or (dj and booking.dj_id == dj.pk)):
            raise serializers.ValidationError({"playlist": "Cette playlist ne vous appartient pas."})
        if self.instance and "playlist" in attrs and attrs["playlist"].pk != self.instance.playlist_id:
            raise serializers.ValidationError({"playlist": "La playlist d'une chanson ne peut pas être modifiée."})
        if client and "status" in self.initial_data:
            raise serializers.ValidationError({"status": "Le statut d'une chanson est géré par le DJ ou l'administration."})
        return attrs

    def create(self, validated_data):
        request = self.context.get("request")
        if request and getattr(request.user, "client_profile", None):
            validated_data["status"] = PlaylistSong.REQUESTED
        return super().create(validated_data)


class ReviewSerializer(LiensHypermediaMixin, serializers.ModelSerializer):
    route_basename = "review"

    class Meta:
        model = Review
        fields = ["id", "booking", "client", "dj", "rating", "comment", "status", "created_at", "liens"]
        read_only_fields = ["client", "dj", "created_at"]

    def validate_rating(self, value):
        if value < 1 or value > 5:
            raise serializers.ValidationError("La note doit être comprise entre 1 et 5.")
        return value

    def validate(self, attrs):
        attrs = super().validate(attrs)
        request = self.context.get("request")
        booking = attrs.get("booking") or getattr(self.instance, "booking", None)
        if booking is None:
            return attrs
        if self.instance and "booking" in attrs and attrs["booking"].pk != self.instance.booking_id:
            raise serializers.ValidationError({"booking": "La réservation d'un avis ne peut pas être modifiée."})
        if booking.status not in {Booking.PERFORMED, Booking.PAID}:
            raise serializers.ValidationError({"booking": "Un avis peut être déposé uniquement après la prestation."})
        if not request or request.user.is_staff:
            return attrs

        client = getattr(request.user, "client_profile", None)
        if not client or booking.client_id != client.pk:
            raise serializers.ValidationError({"booking": "Seul le client de cette réservation peut déposer un avis."})
        if "status" in self.initial_data:
            raise serializers.ValidationError({"status": "Le statut de l'avis est géré par l'administration."})
        if self.instance and self.instance.status != Review.PENDING:
            raise serializers.ValidationError("Un avis déjà modéré ne peut plus être modifié par le client.")
        return attrs


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
