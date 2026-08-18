from django.urls import path
from rest_framework.routers import DefaultRouter

from apps.payments.views import stripe_webhook

from .views import (
    AvailabilityViewSet,
    account_deletion_requests,
    cancel_account_deletion_request,
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
    change_password,
    client_profile,
    current_user,
    logout_user,
    location_search,
    confirm_password_reset,
    register_client,
    register_dj_application,
    dj_application_status,
    resend_verification_email,
    review_account_deletion_request,
    request_password_reset,
    verify_email,
)


router = DefaultRouter()
router.register("packages", PackageViewSet, basename="package")
router.register("service-options", ServiceOptionViewSet, basename="service-option")
router.register("equipment", EquipmentViewSet, basename="equipment")
router.register("event-types", EventTypeViewSet, basename="event-type")
router.register("music-styles", MusicStyleViewSet, basename="music-style")
router.register("djs", DJProfileViewSet, basename="dj")
router.register("availability", AvailabilityViewSet, basename="availability")
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
    path("auth/register/", register_client, name="register-client"),
    path("auth/register-dj/", register_dj_application, name="register-dj-application"),
    path("auth/dj-application/", dj_application_status, name="dj-application-status"),
    path("auth/verify-email/", verify_email, name="verify-email"),
    path("auth/verify-email/resend/", resend_verification_email, name="resend-verification-email"),
    path("auth/password-reset/", request_password_reset, name="request-password-reset"),
    path("auth/password-reset/confirm/", confirm_password_reset, name="confirm-password-reset"),
    path("auth/me/", current_user, name="current-user"),
    path("auth/profile/", client_profile, name="client-profile"),
    path("auth/deletion-requests/", account_deletion_requests, name="account-deletion-requests"),
    path("auth/deletion-requests/<int:pk>/cancel/", cancel_account_deletion_request, name="cancel-account-deletion-request"),
    path("auth/deletion-requests/<int:pk>/review/", review_account_deletion_request, name="review-account-deletion-request"),
    path("auth/password-change/", change_password, name="change-password"),
    path("auth/logout/", logout_user, name="logout-user"),
    path("locations/search/", location_search, name="location-search"),
    path("quotes/calculate/", calculate_quote, name="quote-calculate"),
    path("payments/webhook/", stripe_webhook, name="stripe-webhook"),
]

urlpatterns += router.urls
