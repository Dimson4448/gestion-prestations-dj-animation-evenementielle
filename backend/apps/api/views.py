from rest_framework import generics, permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.bookings.models import Booking, Quote
from apps.catalog.models import EventType, MusicStyle, Package, ServiceOption

from .serializers import (
    BookingSerializer,
    DJAvailabilitySerializer,
    DJProfileSerializer,
    EventTypeSerializer,
    MusicStyleSerializer,
    PackageSerializer,
    QuoteSerializer,
    ServiceOptionSerializer,
)


class PublicReadOnlyViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.AllowAny]


class PackageViewSet(PublicReadOnlyViewSet):
    queryset = Package.objects.filter(is_active=True).order_by("base_price")
    serializer_class = PackageSerializer
    search_fields = ["name", "description"]
    ordering_fields = ["base_price", "included_hours", "name"]


class ServiceOptionViewSet(PublicReadOnlyViewSet):
    queryset = ServiceOption.objects.filter(is_active=True).order_by("name")
    serializer_class = ServiceOptionSerializer


class EventTypeViewSet(PublicReadOnlyViewSet):
    queryset = EventType.objects.order_by("name")
    serializer_class = EventTypeSerializer


class MusicStyleViewSet(PublicReadOnlyViewSet):
    queryset = MusicStyle.objects.order_by("name")
    serializer_class = MusicStyleSerializer


class DJProfileViewSet(PublicReadOnlyViewSet):
    queryset = DJProfile.objects.filter(is_available=True).order_by("stage_name")
    serializer_class = DJProfileSerializer
    search_fields = ["stage_name", "bio"]


class AvailabilityListView(generics.ListAPIView):
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


class QuoteViewSet(viewsets.ModelViewSet):
    queryset = Quote.objects.select_related("client", "event_type", "package", "venue").all()
    serializer_class = QuoteSerializer
    permission_classes = [permissions.IsAuthenticated]


class BookingViewSet(viewsets.ModelViewSet):
    queryset = Booking.objects.select_related("client", "dj", "event_type", "package", "venue").all()
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]


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

    return Response({
        "subtotal": round(subtotal, 2),
        "travel_fee": round(travel_fee, 2),
        "total_amount": round(total, 2),
        "deposit_amount": round(total * 0.30, 2),
    })
