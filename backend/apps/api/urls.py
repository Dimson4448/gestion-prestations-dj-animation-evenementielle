from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    AvailabilityListView,
    BookingViewSet,
    DJProfileViewSet,
    EventTypeViewSet,
    MusicStyleViewSet,
    PackageViewSet,
    QuoteViewSet,
    ServiceOptionViewSet,
    calculate_quote,
)


router = DefaultRouter()
router.register("packages", PackageViewSet, basename="package")
router.register("service-options", ServiceOptionViewSet, basename="service-option")
router.register("event-types", EventTypeViewSet, basename="event-type")
router.register("music-styles", MusicStyleViewSet, basename="music-style")
router.register("djs", DJProfileViewSet, basename="dj")
router.register("quotes", QuoteViewSet, basename="quote")
router.register("bookings", BookingViewSet, basename="booking")

urlpatterns = [
    path("availability/", AvailabilityListView.as_view(), name="availability-list"),
    path("quotes/calculate/", calculate_quote, name="quote-calculate"),
]

urlpatterns += router.urls
