from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    AvailabilityListView,
    BookingViewSet,
    ContractViewSet,
    DJProfileViewSet,
    EquipmentViewSet,
    EventTypeViewSet,
    InvoiceViewSet,
    MusicStyleViewSet,
    PackageViewSet,
    PaymentViewSet,
    PlaylistSongViewSet,
    PlaylistViewSet,
    PreparatoryAppointmentViewSet,
    QuoteViewSet,
    ReviewViewSet,
    ServiceOptionViewSet,
    VenueViewSet,
    calculate_quote,
)


router = DefaultRouter()
router.register("packages", PackageViewSet, basename="package")
router.register("service-options", ServiceOptionViewSet, basename="service-option")
router.register("equipment", EquipmentViewSet, basename="equipment")
router.register("event-types", EventTypeViewSet, basename="event-type")
router.register("music-styles", MusicStyleViewSet, basename="music-style")
router.register("djs", DJProfileViewSet, basename="dj")
router.register("venues", VenueViewSet, basename="venue")
router.register("quotes", QuoteViewSet, basename="quote")
router.register("bookings", BookingViewSet, basename="booking")
router.register("appointments", PreparatoryAppointmentViewSet, basename="appointment")
router.register("contracts", ContractViewSet, basename="contract")
router.register("invoices", InvoiceViewSet, basename="invoice")
router.register("payments", PaymentViewSet, basename="payment")
router.register("playlists", PlaylistViewSet, basename="playlist")
router.register("playlist-songs", PlaylistSongViewSet, basename="playlist-song")
router.register("reviews", ReviewViewSet, basename="review")

urlpatterns = [
    path("availability/", AvailabilityListView.as_view(), name="availability-list"),
    path("quotes/calculate/", calculate_quote, name="quote-calculate"),
]

urlpatterns += router.urls
