from rest_framework import permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.generics import ListAPIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

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

from .serializers import (
    BookingSerializer,
    ContractSerializer,
    DJAvailabilitySerializer,
    DJProfileSerializer,
    EquipmentSerializer,
    EventTypeSerializer,
    InvoiceSerializer,
    MusicStyleSerializer,
    PackageSerializer,
    PaymentSerializer,
    PlaylistSerializer,
    PlaylistSongSerializer,
    PreparatoryAppointmentSerializer,
    QuoteCalculationRequestSerializer,
    QuoteCalculationResponseSerializer,
    QuoteSerializer,
    ReviewSerializer,
    ServiceOptionSerializer,
    VenueSerializer,
)


class PublicReadOnlyViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.AllowAny]


class ProtectedModelViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]


class PackageViewSet(PublicReadOnlyViewSet):
    queryset = Package.objects.filter(is_active=True).order_by("base_price")
    serializer_class = PackageSerializer
    search_fields = ["name", "description"]
    ordering_fields = ["base_price", "included_hours", "name"]


class ServiceOptionViewSet(PublicReadOnlyViewSet):
    queryset = ServiceOption.objects.filter(is_active=True).order_by("name")
    serializer_class = ServiceOptionSerializer


class EquipmentViewSet(PublicReadOnlyViewSet):
    queryset = Equipment.objects.filter(status=Equipment.AVAILABLE).order_by("category", "name")
    serializer_class = EquipmentSerializer
    filterset_fields = ["category", "status"]
    search_fields = ["name", "serial_number", "category"]


class EventTypeViewSet(PublicReadOnlyViewSet):
    queryset = EventType.objects.order_by("name")
    serializer_class = EventTypeSerializer


class MusicStyleViewSet(PublicReadOnlyViewSet):
    queryset = MusicStyle.objects.order_by("name")
    serializer_class = MusicStyleSerializer


class DJProfileViewSet(PublicReadOnlyViewSet):
    queryset = DJProfile.objects.filter(is_available=True).prefetch_related("music_styles").order_by("stage_name")
    serializer_class = DJProfileSerializer
    search_fields = ["stage_name", "bio"]


class AvailabilityListView(ListAPIView):
    serializer_class = DJAvailabilitySerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = DJAvailability.objects.select_related("dj").filter(status=DJAvailability.AVAILABLE)
        dj_id = self.request.query_params.get("dj")
        date = self.request.query_params.get("date")
        if dj_id:
            queryset = queryset.filter(dj_id=dj_id)
        if date:
            queryset = queryset.filter(available_date=date)
        return queryset.order_by("available_date", "start_time")


class VenueViewSet(ProtectedModelViewSet):
    queryset = Venue.objects.select_related("client").all()
    serializer_class = VenueSerializer
    search_fields = ["name", "city", "postal_code"]


class QuoteViewSet(ProtectedModelViewSet):
    queryset = Quote.objects.select_related("client", "event_type", "package", "venue").all()
    serializer_class = QuoteSerializer
    filterset_fields = ["status", "event_type", "package"]
    search_fields = ["venue__name", "client__user__email"]


class BookingViewSet(ProtectedModelViewSet):
    queryset = Booking.objects.select_related("client", "dj", "event_type", "package", "venue").prefetch_related("equipment").all()
    serializer_class = BookingSerializer
    filterset_fields = ["status", "event_type", "package", "deposit_paid"]
    search_fields = ["client__user__email", "dj__stage_name", "venue__name"]


class PreparatoryAppointmentViewSet(ProtectedModelViewSet):
    queryset = PreparatoryAppointment.objects.select_related("booking").all()
    serializer_class = PreparatoryAppointmentSerializer
    filterset_fields = ["mode", "status"]


class ContractViewSet(ProtectedModelViewSet):
    queryset = Contract.objects.select_related("booking").all()
    serializer_class = ContractSerializer
    filterset_fields = ["status"]
    search_fields = ["contract_number"]


class InvoiceViewSet(ProtectedModelViewSet):
    queryset = Invoice.objects.select_related("booking").all()
    serializer_class = InvoiceSerializer
    filterset_fields = ["invoice_type", "status"]
    search_fields = ["invoice_number"]


class PaymentViewSet(ProtectedModelViewSet):
    queryset = Payment.objects.select_related("booking", "invoice").all()
    serializer_class = PaymentSerializer
    filterset_fields = ["status", "currency"]


class PlaylistViewSet(ProtectedModelViewSet):
    queryset = Playlist.objects.select_related("booking", "main_style").all()
    serializer_class = PlaylistSerializer


class PlaylistSongViewSet(ProtectedModelViewSet):
    queryset = PlaylistSong.objects.select_related("playlist").all()
    serializer_class = PlaylistSongSerializer
    filterset_fields = ["preference_level", "status"]
    search_fields = ["title", "artist"]


class ReviewViewSet(ProtectedModelViewSet):
    queryset = Review.objects.select_related("booking", "client", "dj").all()
    serializer_class = ReviewSerializer
    filterset_fields = ["rating", "status"]
    search_fields = ["comment", "dj__stage_name"]


@extend_schema(
    request=QuoteCalculationRequestSerializer,
    responses={200: QuoteCalculationResponseSerializer},
    summary="Calculer un devis informatif",
    description="Calcule un devis indicatif à partir du package, de la durée et de la distance de déplacement.",
)
@api_view(["POST"])
@permission_classes([permissions.AllowAny])
def calculate_quote(request):
    package_id = request.data.get("package_id")
    duration_hours = float(request.data.get("duration_hours", 0))
    distance_km = float(request.data.get("distance_km", 0))

    package = Package.objects.get(pk=package_id)
    extra_hours = max(duration_hours - float(package.included_hours), 0)
    subtotal = float(package.base_price) + extra_hours * 95
    travel_fee = distance_km * 0.65
    total = subtotal + travel_fee

    return Response(
        {
            "subtotal": round(subtotal, 2),
            "travel_fee": round(travel_fee, 2),
            "total_amount": round(total, 2),
            "deposit_amount": round(total * 0.30, 2),
        }
    )
