from urllib.parse import urlencode

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import default_token_generator
from django.core.mail import send_mail
from django.shortcuts import get_object_or_404
from django.http import HttpResponse
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.reverse import reverse
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiResponse, extend_schema
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

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
from apps.bookings.services import BookingCancellationError, BookingCompletionError, CancellationRequestError, ContractSigningError, QuoteAcceptanceError, accept_quote, cancel_booking, complete_booking, reject_booking_cancellation, request_booking_cancellation, sign_contract
from apps.bookings.documents import build_contract_pdf, build_invoice_pdf
from apps.catalog.models import Equipment, EventType, MusicStyle, Package, ServiceOption
from apps.payments.models import Invoice, Payment
from apps.payments.services import StripeCheckoutError, StripeConfigurationError, StripeRefundError, create_invoice_checkout, create_payment_refund

from .permissions import AdministrationOuProprietaire, DJOuAdministration, LecturePubliqueEcritureAdmin, UtilisateurAuthentifie
from .serializers import (
    BookingSerializer,
    BookingCancellationSerializer,
    CancellationRequestSerializer,
    CancellationRequestReviewSerializer,
    ClientRegistrationSerializer,
    ContractSerializer,
    CurrentUserSerializer,
    DJAvailabilitySerializer,
    DJProfileSerializer,
    EquipmentSerializer,
    EventTypeSerializer,
    EmailVerificationSerializer,
    InvoiceSerializer,
    LogoutSerializer,
    PasswordResetConfirmSerializer,
    PasswordResetRequestSerializer,
    MusicStyleSerializer,
    PackageSerializer,
    PaymentSerializer,
    RefundRequestSerializer,
    RefundSerializer,
    PlaylistSerializer,
    PlaylistSongSerializer,
    PreparatoryAppointmentSerializer,
    QuoteCalculationRequestSerializer,
    QuoteCalculationResponseSerializer,
    QuoteAcceptanceSerializer,
    QuoteSerializer,
    ReviewSerializer,
    ServiceOptionSerializer,
    VenueSerializer,
    calculate_quote_amounts,
)


class PublicReadOnlyViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [permissions.AllowAny]


class AdminWritePublicReadViewSet(viewsets.ModelViewSet):
    permission_classes = [LecturePubliqueEcritureAdmin]


class ProtectedModelViewSet(viewsets.ModelViewSet):
    permission_classes = [UtilisateurAuthentifie, AdministrationOuProprietaire]


class AdminManagedProtectedViewSet(ProtectedModelViewSet):
    """Ressource consultable par son propriétaire, mais écrite via les parcours métier ou l'administration."""

    admin_only_actions = {"create", "update", "partial_update", "destroy"}

    def get_permissions(self):
        if self.action in self.admin_only_actions:
            return [permissions.IsAdminUser()]
        return super().get_permissions()


def client_connecte(user):
    return getattr(user, "client_profile", None)


def dj_connecte(user):
    return getattr(user, "dj_profile", None)


def filtrer_par_reservation(queryset, user, prefix=""):
    if user.is_staff:
        return queryset

    client = client_connecte(user)
    dj = dj_connecte(user)
    if client:
        return queryset.filter(**{f"{prefix}booking__client": client})
    if dj:
        return queryset.filter(**{f"{prefix}booking__dj": dj})
    return queryset.none()


@extend_schema(responses={200: CurrentUserSerializer}, summary="Afficher l'utilisateur connecté")
@api_view(["GET"])
@permission_classes([permissions.IsAuthenticated])
def current_user(request):
    return Response(CurrentUserSerializer(request.user).data)


@extend_schema(request=ClientRegistrationSerializer, responses={201: OpenApiResponse(description="Compte créé, vérification requise")}, summary="Créer un compte client")
@api_view(["POST"])
@permission_classes([permissions.AllowAny])
def register_client(request):
    serializer = ClientRegistrationSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.save()
    parameters = urlencode(
        {
            "verify_uid": urlsafe_base64_encode(force_bytes(user.pk)),
            "verify_token": default_token_generator.make_token(user),
        }
    )
    verification_url = f"{settings.FRONTEND_URL.rstrip('/')}?{parameters}"
    send_mail(
        "Ultimate DJ - confirmez votre adresse e-mail",
        f"Bienvenue chez Ultimate DJ. Confirmez votre adresse e-mail avec ce lien :\n\n{verification_url}\n\nCe lien ne peut être utilisé qu'une fois.",
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        fail_silently=True,
    )
    return Response(
        {"detail": "Votre compte a été créé. Consultez votre e-mail pour l'activer avant de vous connecter."},
        status=status.HTTP_201_CREATED,
    )


@extend_schema(request=EmailVerificationSerializer, responses={204: None}, summary="Confirmer une adresse e-mail")
@api_view(["POST"])
@permission_classes([permissions.AllowAny])
def verify_email(request):
    serializer = EmailVerificationSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response(status=status.HTTP_204_NO_CONTENT)


@extend_schema(request=PasswordResetRequestSerializer, responses={200: OpenApiResponse(description="Demande traitée")}, summary="Demander un nouveau mot de passe")
@api_view(["POST"])
@permission_classes([permissions.AllowAny])
def request_password_reset(request):
    serializer = PasswordResetRequestSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = get_user_model().objects.filter(email__iexact=serializer.validated_data["email"], is_active=True).first()
    if user:
        parameters = urlencode(
            {
                "reset_uid": urlsafe_base64_encode(force_bytes(user.pk)),
                "reset_token": default_token_generator.make_token(user),
            }
        )
        reset_url = f"{settings.FRONTEND_URL.rstrip('/')}?{parameters}"
        send_mail(
            "Ultimate DJ - réinitialisation du mot de passe",
            f"Utilisez ce lien pour choisir un nouveau mot de passe :\n\n{reset_url}\n\nIgnorez ce message si vous n'êtes pas à l'origine de cette demande.",
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=True,
        )
    return Response({"detail": "Si cette adresse correspond à un compte actif, un lien vient d'être envoyé."})


@extend_schema(request=PasswordResetConfirmSerializer, responses={204: None}, summary="Confirmer un nouveau mot de passe")
@api_view(["POST"])
@permission_classes([permissions.AllowAny])
def confirm_password_reset(request):
    serializer = PasswordResetConfirmSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response(status=status.HTTP_204_NO_CONTENT)


@extend_schema(request=LogoutSerializer, responses={204: None}, summary="Révoquer la session JWT")
@api_view(["POST"])
@permission_classes([permissions.IsAuthenticated])
def logout_user(request):
    serializer = LogoutSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    try:
        RefreshToken(serializer.validated_data["refresh"]).blacklist()
    except TokenError:
        return Response({"detail": "Le jeton de renouvellement est invalide ou déjà révoqué."}, status=status.HTTP_400_BAD_REQUEST)
    return Response(status=status.HTTP_204_NO_CONTENT)


class PackageViewSet(AdminWritePublicReadViewSet):
    queryset = Package.objects.filter(is_active=True).order_by("base_price")
    serializer_class = PackageSerializer
    search_fields = ["name", "description"]
    ordering_fields = ["base_price", "included_hours", "name"]


class ServiceOptionViewSet(AdminWritePublicReadViewSet):
    queryset = ServiceOption.objects.filter(is_active=True).order_by("name")
    serializer_class = ServiceOptionSerializer
    search_fields = ["name"]
    ordering_fields = ["name", "unit_price"]


class EquipmentViewSet(AdminWritePublicReadViewSet):
    queryset = Equipment.objects.filter(status=Equipment.AVAILABLE).order_by("category", "name")
    serializer_class = EquipmentSerializer
    filterset_fields = ["category", "status"]
    search_fields = ["name", "serial_number", "category"]
    ordering_fields = ["category", "name", "daily_cost"]


class EventTypeViewSet(AdminWritePublicReadViewSet):
    queryset = EventType.objects.order_by("name")
    serializer_class = EventTypeSerializer
    search_fields = ["name"]
    ordering_fields = ["name"]


class MusicStyleViewSet(AdminWritePublicReadViewSet):
    queryset = MusicStyle.objects.order_by("name")
    serializer_class = MusicStyleSerializer
    search_fields = ["name"]
    ordering_fields = ["name"]


class DJProfileViewSet(PublicReadOnlyViewSet):
    queryset = DJProfile.objects.filter(is_available=True).prefetch_related("music_styles").order_by("stage_name")
    serializer_class = DJProfileSerializer
    search_fields = ["stage_name", "bio", "music_styles__name"]
    ordering_fields = ["stage_name", "years_experience", "base_hourly_rate"]


class AvailabilityViewSet(viewsets.ModelViewSet):
    serializer_class = DJAvailabilitySerializer

    def get_permissions(self):
        if self.action in {"list", "retrieve"}:
            return [permissions.AllowAny()]
        return [DJOuAdministration(), AdministrationOuProprietaire()]

    def get_queryset(self):
        queryset = DJAvailability.objects.select_related("dj", "dj__user")
        user = self.request.user
        if user.is_authenticated and user.is_staff:
            pass
        elif user.is_authenticated and dj_connecte(user):
            queryset = queryset.filter(dj=dj_connecte(user))
        else:
            queryset = queryset.filter(status=DJAvailability.AVAILABLE)
        dj_id = self.request.query_params.get("dj")
        date = self.request.query_params.get("date")
        if dj_id:
            queryset = queryset.filter(dj_id=dj_id)
        if date:
            queryset = queryset.filter(available_date=date)
        return queryset.order_by("available_date", "start_time")

    def perform_create(self, serializer):
        if self.request.user.is_staff:
            serializer.save()
        else:
            serializer.save(dj=dj_connecte(self.request.user))

    def perform_destroy(self, instance):
        if not self.request.user.is_staff and instance.status == DJAvailability.RESERVED:
            raise ValidationError({"status": "Un créneau réservé ne peut être supprimé par le DJ."})
        instance.delete()


class VenueViewSet(ProtectedModelViewSet):
    serializer_class = VenueSerializer
    search_fields = ["name", "city", "postal_code"]
    ordering_fields = ["city", "name", "distance_km_from_base"]

    def get_queryset(self):
        queryset = Venue.objects.select_related("client").all()
        if self.request.user.is_staff:
            return queryset
        client = client_connecte(self.request.user)
        if client:
            return queryset.filter(client=client)
        return queryset.none()

    def perform_create(self, serializer):
        if self.request.user.is_staff:
            serializer.save()
        else:
            serializer.save(client=client_connecte(self.request.user))


class QuoteViewSet(ProtectedModelViewSet):
    serializer_class = QuoteSerializer
    filterset_fields = ["status", "event_type", "package"]
    search_fields = ["venue__name", "client__user__email"]
    ordering_fields = ["event_date", "created_at", "total_amount"]

    def get_permissions(self):
        if self.action in {"update", "partial_update", "destroy", "accept"}:
            return [permissions.IsAdminUser()]
        return super().get_permissions()

    def get_queryset(self):
        queryset = Quote.objects.select_related("client", "event_type", "package", "venue").order_by("-created_at")
        if self.request.user.is_staff:
            return queryset
        client = client_connecte(self.request.user)
        if client:
            return queryset.filter(client=client)
        return queryset.none()

    def perform_create(self, serializer):
        package = serializer.validated_data["package"]
        duration_hours = serializer.validated_data["duration_hours"]
        distance_km = serializer.validated_data.get("distance_km", 0)
        amounts = calculate_quote_amounts(package, duration_hours, distance_km)
        client = serializer.validated_data.get("client")
        if not self.request.user.is_staff:
            client = client_connecte(self.request.user)
        serializer.save(client=client, status=Quote.DRAFT, **amounts)

    @extend_schema(
        request=QuoteAcceptanceSerializer,
        responses={201: BookingSerializer},
        summary="Accepter un devis et créer le dossier de réservation",
    )
    @action(detail=True, methods=["post"], url_path="accept")
    def accept(self, request, pk=None):
        quote = self.get_object()
        serializer = QuoteAcceptanceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            booking, contract, invoice = accept_quote(quote.pk, serializer.validated_data["dj"].pk)
        except QuoteAcceptanceError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(
            {
                "booking": BookingSerializer(booking, context={"request": request}).data,
                "contract": ContractSerializer(contract, context={"request": request}).data,
                "deposit_invoice": InvoiceSerializer(invoice, context={"request": request}).data,
            },
            status=status.HTTP_201_CREATED,
        )


class BookingViewSet(AdminManagedProtectedViewSet):
    admin_only_actions = {"create", "update", "partial_update", "destroy", "cancel", "reject_cancellation"}
    serializer_class = BookingSerializer
    filterset_fields = ["status", "event_type", "package", "deposit_paid"]
    search_fields = ["client__user__email", "dj__stage_name", "venue__name"]
    ordering_fields = ["event_date", "created_at", "total_amount"]

    def get_queryset(self):
        queryset = Booking.objects.select_related("client", "dj", "event_type", "package", "venue").prefetch_related("equipment")
        if self.request.user.is_staff:
            return queryset.all()
        client = client_connecte(self.request.user)
        if client:
            return queryset.filter(client=client)
        dj = dj_connecte(self.request.user)
        if dj:
            return queryset.filter(dj=dj)
        return queryset.none()

    @extend_schema(responses={201: InvoiceSerializer}, summary="Clôturer la prestation et émettre la facture de solde")
    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        booking = self.get_object()
        if not request.user.is_staff and dj_connecte(request.user) != booking.dj:
            return Response(
                {"detail": "Seul le DJ affecté ou l'administration peut clôturer cette prestation."},
                status=status.HTTP_403_FORBIDDEN,
            )
        try:
            booking, invoice = complete_booking(booking.pk, request.user)
        except BookingCompletionError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(
            {
                "booking": BookingSerializer(booking, context={"request": request}).data,
                "balance_invoice": InvoiceSerializer(invoice, context={"request": request}).data,
            },
            status=status.HTTP_201_CREATED,
        )

    @extend_schema(
        request=BookingCancellationSerializer,
        responses={200: BookingSerializer},
        summary="Annuler une réservation remboursée et libérer le créneau DJ",
    )
    @action(detail=True, methods=["post"], url_path="cancel")
    def cancel(self, request, pk=None):
        booking = self.get_object()
        serializer = BookingCancellationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            booking = cancel_booking(booking.pk, request.user, serializer.validated_data["reason"])
        except BookingCancellationError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(BookingSerializer(booking, context={"request": request}).data)

    @extend_schema(
        request=BookingCancellationSerializer,
        responses={201: CancellationRequestSerializer},
        summary="Demander l'annulation d'une réservation en tant que client",
    )
    @action(detail=True, methods=["post"], url_path="request-cancellation")
    def request_cancellation(self, request, pk=None):
        booking = self.get_object()
        serializer = BookingCancellationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            cancellation_request = request_booking_cancellation(
                booking.pk, request.user, serializer.validated_data["reason"]
            )
        except CancellationRequestError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(CancellationRequestSerializer(cancellation_request).data, status=status.HTTP_201_CREATED)

    @extend_schema(
        responses={200: CancellationRequestSerializer(many=True)},
        summary="Consulter les demandes d'annulation d'une réservation",
    )
    @action(detail=True, methods=["get"], url_path="cancellation-requests")
    def cancellation_requests(self, request, pk=None):
        booking = self.get_object()
        if not request.user.is_staff and booking.client.user_id != request.user.pk:
            return Response({"detail": "Accès réservé au client concerné et à l'administration."}, status=status.HTTP_403_FORBIDDEN)
        requests = booking.cancellation_requests.select_related("reviewed_by").all()
        return Response(CancellationRequestSerializer(requests, many=True).data)

    @extend_schema(
        request=CancellationRequestReviewSerializer,
        responses={200: CancellationRequestSerializer},
        summary="Refuser une demande d'annulation en attente",
    )
    @action(detail=True, methods=["post"], url_path="reject-cancellation")
    def reject_cancellation(self, request, pk=None):
        booking = self.get_object()
        serializer = CancellationRequestReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            cancellation_request = reject_booking_cancellation(
                booking.pk, request.user, serializer.validated_data["message"]
            )
        except CancellationRequestError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(CancellationRequestSerializer(cancellation_request).data)

class PreparatoryAppointmentViewSet(AdminManagedProtectedViewSet):
    admin_only_actions = {"destroy"}
    serializer_class = PreparatoryAppointmentSerializer
    filterset_fields = ["mode", "status"]
    ordering_fields = ["scheduled_at", "status"]

    def get_queryset(self):
        queryset = PreparatoryAppointment.objects.select_related("booking", "booking__client", "booking__dj").all()
        return filtrer_par_reservation(queryset, self.request.user)


class ContractViewSet(AdminManagedProtectedViewSet):
    serializer_class = ContractSerializer
    filterset_fields = ["status"]
    search_fields = ["contract_number"]
    ordering_fields = ["created_at", "contract_number"]

    def get_queryset(self):
        queryset = Contract.objects.select_related("booking", "booking__client", "booking__dj").all()
        return filtrer_par_reservation(queryset, self.request.user)

    @extend_schema(responses={200: ContractSerializer}, summary="Signer le contrat en tant que client")
    @action(detail=True, methods=["post"], url_path="sign")
    def sign(self, request, pk=None):
        contract = self.get_object()
        try:
            contract = sign_contract(contract.pk, client_connecte(request.user))
        except ContractSigningError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(ContractSerializer(contract, context={"request": request}).data)

    @extend_schema(
        responses={(200, "application/pdf"): OpenApiResponse(response=OpenApiTypes.BINARY, description="Contrat PDF")},
        summary="Télécharger le contrat au format PDF",
    )
    @action(detail=True, methods=["get"], url_path="pdf")
    def pdf(self, request, pk=None):
        contract = self.get_object()
        response = HttpResponse(build_contract_pdf(contract), content_type="application/pdf")
        response["Content-Disposition"] = f'attachment; filename="{contract.contract_number}.pdf"'
        return response


class InvoiceViewSet(AdminManagedProtectedViewSet):
    serializer_class = InvoiceSerializer
    filterset_fields = ["invoice_type", "status"]
    search_fields = ["invoice_number"]
    ordering_fields = ["issued_at", "due_at", "amount"]

    def get_queryset(self):
        queryset = Invoice.objects.select_related("booking", "booking__client", "booking__dj").all()
        return filtrer_par_reservation(queryset, self.request.user)

    @extend_schema(
        responses={(200, "application/pdf"): OpenApiResponse(response=OpenApiTypes.BINARY, description="Facture PDF")},
        summary="Télécharger la facture au format PDF",
    )
    @action(detail=True, methods=["get"], url_path="pdf")
    def pdf(self, request, pk=None):
        invoice = self.get_object()
        response = HttpResponse(build_invoice_pdf(invoice), content_type="application/pdf")
        response["Content-Disposition"] = f'attachment; filename="{invoice.invoice_number}.pdf"'
        return response

    @action(detail=True, methods=["post"], url_path="checkout")
    def checkout(self, request, pk=None):
        invoice = self.get_object()
        if not request.user.is_staff and client_connecte(request.user) != invoice.booking.client:
            return Response(
                {"detail": "Seul le client de la réservation peut démarrer ce paiement."},
                status=status.HTTP_403_FORBIDDEN,
            )
        try:
            payment, checkout_url = create_invoice_checkout(invoice)
        except (ValueError, StripeConfigurationError) as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        except StripeCheckoutError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        return Response(
            {
                "payment_id": payment.pk,
                "session_id": payment.stripe_session_id,
                "checkout_url": checkout_url,
            },
            status=status.HTTP_201_CREATED,
        )


class PaymentViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [UtilisateurAuthentifie, AdministrationOuProprietaire]
    serializer_class = PaymentSerializer
    filterset_fields = ["status", "currency"]
    ordering_fields = ["paid_at", "amount"]

    def get_permissions(self):
        if self.action == "refund":
            return [permissions.IsAdminUser()]
        return super().get_permissions()

    def get_queryset(self):
        queryset = Payment.objects.select_related("booking", "booking__client", "booking__dj", "invoice").prefetch_related("refunds").all()
        return filtrer_par_reservation(queryset, self.request.user)

    @extend_schema(
        request=RefundRequestSerializer,
        responses={201: RefundSerializer},
        summary="Rembourser totalement ou partiellement un paiement Stripe",
    )
    @action(detail=True, methods=["post"], url_path="refund")
    def refund(self, request, pk=None):
        payment = self.get_object()
        serializer = RefundRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            refund = create_payment_refund(
                payment.pk,
                serializer.validated_data.get("amount"),
                serializer.validated_data["reason"],
                serializer.validated_data["internal_reason"],
            )
        except (ValueError, StripeConfigurationError) as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_400_BAD_REQUEST)
        except StripeRefundError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_502_BAD_GATEWAY)
        return Response(RefundSerializer(refund).data, status=status.HTTP_201_CREATED)


class PlaylistViewSet(ProtectedModelViewSet):
    serializer_class = PlaylistSerializer
    filterset_fields = ["main_style"]

    def get_queryset(self):
        queryset = Playlist.objects.select_related("booking", "booking__client", "booking__dj", "main_style").all()
        return filtrer_par_reservation(queryset, self.request.user)


class PlaylistSongViewSet(ProtectedModelViewSet):
    serializer_class = PlaylistSongSerializer
    filterset_fields = ["preference_level", "status"]
    search_fields = ["title", "artist"]
    ordering_fields = ["title", "artist", "status"]

    def get_queryset(self):
        queryset = PlaylistSong.objects.select_related("playlist", "playlist__booking", "playlist__booking__client", "playlist__booking__dj").all()
        return filtrer_par_reservation(queryset, self.request.user, prefix="playlist__")


class ReviewViewSet(AdminManagedProtectedViewSet):
    admin_only_actions = {"destroy"}
    serializer_class = ReviewSerializer
    filterset_fields = ["rating", "status"]
    search_fields = ["comment", "dj__stage_name"]
    ordering_fields = ["created_at", "rating"]

    def get_queryset(self):
        queryset = Review.objects.select_related("booking", "client", "dj").all()
        if self.request.user.is_staff:
            return queryset
        client = client_connecte(self.request.user)
        if client:
            return queryset.filter(client=client)
        dj = dj_connecte(self.request.user)
        if dj:
            return queryset.filter(dj=dj)
        return queryset.none()

    def perform_create(self, serializer):
        booking = serializer.validated_data["booking"]
        if self.request.user.is_staff:
            serializer.save(client=booking.client, dj=booking.dj)
        else:
            serializer.save(client=booking.client, dj=booking.dj, status=Review.PENDING)


@extend_schema(
    request=QuoteCalculationRequestSerializer,
    responses={200: QuoteCalculationResponseSerializer},
    summary="Calculer un devis informatif",
    description="Calcule un devis indicatif à partir du package, de la durée et de la distance de déplacement.",
)
@api_view(["POST"])
@permission_classes([permissions.AllowAny])
def calculate_quote(request):
    serializer = QuoteCalculationRequestSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    package = get_object_or_404(Package.objects.filter(is_active=True), pk=serializer.validated_data["package_id"])
    amounts = calculate_quote_amounts(
        package,
        serializer.validated_data["duration_hours"],
        serializer.validated_data["distance_km"],
    )
    response = {
        **amounts,
        "currency": "EUR",
        "liens": {
            "packages": reverse("package-list", request=request),
            "creer_devis": reverse("quote-list", request=request),
        },
    }
    return Response(QuoteCalculationResponseSerializer(response).data)
