from django.conf import settings
from django.db import models
from django.utils import timezone

from apps.accounts.models import ClientProfile, DJProfile
from apps.catalog.models import Equipment, EventType, MusicStyle, Package, ServiceOption


class Venue(models.Model):
    client = models.ForeignKey(ClientProfile, on_delete=models.CASCADE, related_name="venues", verbose_name="client")
    name = models.CharField("nom", max_length=120)
    street = models.CharField("rue", max_length=160)
    postal_code = models.CharField("code postal", max_length=20)
    city = models.CharField("ville", max_length=80)
    country = models.CharField("pays", max_length=80, default="Belgique")
    has_parking = models.BooleanField("parking disponible", default=False)
    distance_km_from_base = models.DecimalField("distance depuis la base (km)", max_digits=6, decimal_places=2)

    class Meta:
        db_table = "venues"
        verbose_name = "lieu"
        verbose_name_plural = "lieux"
        indexes = [
            models.Index(fields=["city"], name="idx_venue_city"),
        ]
        constraints = [
            models.CheckConstraint(check=models.Q(distance_km_from_base__gte=0), name="venue_distance_positive"),
        ]

    def __str__(self):
        return f"{self.name} - {self.city}"


class Quote(models.Model):
    DRAFT = "draft"
    SENT = "sent"
    ACCEPTED = "accepted"
    REFUSED = "refused"
    EXPIRED = "expired"
    STATUS_CHOICES = [
        (DRAFT, "Brouillon"),
        (SENT, "Envoyé"),
        (ACCEPTED, "Accepté"),
        (REFUSED, "Refusé"),
        (EXPIRED, "Expiré"),
    ]

    client = models.ForeignKey(ClientProfile, on_delete=models.PROTECT, related_name="quotes", verbose_name="client")
    event_type = models.ForeignKey(EventType, on_delete=models.PROTECT, verbose_name="type d'événement")
    package = models.ForeignKey(Package, on_delete=models.PROTECT, verbose_name="package")
    venue = models.ForeignKey(Venue, on_delete=models.PROTECT, verbose_name="lieu")
    event_date = models.DateField("date de l'événement")
    start_time = models.TimeField("heure de début")
    duration_hours = models.DecimalField("durée en heures", max_digits=4, decimal_places=1)
    guest_count = models.PositiveSmallIntegerField("nombre d'invités")
    distance_km = models.DecimalField("distance en km", max_digits=6, decimal_places=2, default=0)
    parking_available = models.BooleanField("parking disponible", default=False)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=DRAFT)
    subtotal = models.DecimalField("sous-total", max_digits=10, decimal_places=2, default=0)
    travel_fee = models.DecimalField("frais de déplacement", max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField("montant total", max_digits=10, decimal_places=2, default=0)
    deposit_amount = models.DecimalField("montant de l'acompte", max_digits=10, decimal_places=2, default=0)
    music_preferences = models.TextField("préférences musicales", blank=True)
    created_at = models.DateTimeField("créé le", auto_now_add=True)

    class Meta:
        db_table = "quotes"
        verbose_name = "devis"
        verbose_name_plural = "devis"
        indexes = [
            models.Index(fields=["event_date"], name="idx_quote_event_date"),
            models.Index(fields=["status"], name="idx_quote_status"),
        ]
        constraints = [
            models.CheckConstraint(check=models.Q(total_amount__gte=0), name="quote_total_positive"),
            models.CheckConstraint(check=models.Q(deposit_amount__gte=0), name="quote_deposit_positive"),
        ]

    def __str__(self):
        return f"Devis #{self.pk} - {self.client}"


class QuoteOption(models.Model):
    quote = models.ForeignKey(Quote, on_delete=models.CASCADE, related_name="options", verbose_name="devis")
    service_option = models.ForeignKey(ServiceOption, on_delete=models.PROTECT, related_name="quote_options", verbose_name="option")
    quantity = models.PositiveSmallIntegerField("quantité", default=1)
    unit_price = models.DecimalField("prix unitaire", max_digits=10, decimal_places=2)

    class Meta:
        db_table = "quote_options"
        verbose_name = "option de devis"
        verbose_name_plural = "options de devis"
        constraints = [
            models.UniqueConstraint(fields=["quote", "service_option"], name="unique_quote_service_option"),
            models.CheckConstraint(check=models.Q(quantity__gt=0), name="quote_option_quantity_positive"),
            models.CheckConstraint(check=models.Q(unit_price__gte=0), name="quote_option_unit_price_positive"),
        ]

    def __str__(self):
        return f"{self.service_option} x {self.quantity}"


class Booking(models.Model):
    PREPARATORY_MEETING = "preparatory_meeting"
    CONFIRMED = "confirmed"
    PERFORMED = "performed"
    PAID = "paid"
    CANCELLED = "cancelled"
    STATUS_CHOICES = [
        (PREPARATORY_MEETING, "Rendez-vous préparatoire"),
        (CONFIRMED, "Confirmé"),
        (PERFORMED, "Presté"),
        (PAID, "Payé"),
        (CANCELLED, "Annulé"),
    ]

    quote = models.OneToOneField(Quote, on_delete=models.PROTECT, related_name="booking", verbose_name="devis")
    client = models.ForeignKey(ClientProfile, on_delete=models.PROTECT, related_name="bookings", verbose_name="client")
    dj = models.ForeignKey(DJProfile, on_delete=models.PROTECT, related_name="bookings", verbose_name="DJ")
    event_type = models.ForeignKey(EventType, on_delete=models.PROTECT, verbose_name="type d'événement")
    package = models.ForeignKey(Package, on_delete=models.PROTECT, verbose_name="package")
    venue = models.ForeignKey(Venue, on_delete=models.PROTECT, verbose_name="lieu")
    equipment = models.ManyToManyField(Equipment, through="BookingEquipment", blank=True, related_name="bookings", verbose_name="matériel")
    event_date = models.DateField("date de l'événement")
    start_time = models.TimeField("heure de début")
    end_time = models.TimeField("heure de fin")
    status = models.CharField("statut", max_length=30, choices=STATUS_CHOICES, default=PREPARATORY_MEETING)
    total_amount = models.DecimalField("montant total", max_digits=10, decimal_places=2)
    deposit_required = models.DecimalField("acompte requis", max_digits=10, decimal_places=2)
    deposit_paid = models.BooleanField("acompte payé", default=False)
    cancellation_reason = models.CharField("motif d'annulation", max_length=255, blank=True)
    created_at = models.DateTimeField("créé le", auto_now_add=True)

    class Meta:
        db_table = "bookings"
        verbose_name = "réservation"
        verbose_name_plural = "réservations"
        constraints = [
            models.UniqueConstraint(fields=["dj", "event_date", "start_time"], name="unique_confirmed_dj_slot"),
            models.CheckConstraint(check=models.Q(end_time__gt=models.F("start_time")), name="booking_end_after_start"),
            models.CheckConstraint(check=models.Q(total_amount__gte=0), name="booking_total_positive"),
            models.CheckConstraint(check=models.Q(deposit_required__gte=0), name="booking_deposit_positive"),
        ]

    def __str__(self):
        return f"Réservation #{self.pk} - {self.event_date}"


class BookingEquipment(models.Model):
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, verbose_name="réservation")
    equipment = models.ForeignKey(Equipment, on_delete=models.PROTECT, verbose_name="matériel")
    quantity = models.PositiveSmallIntegerField("quantité", default=1)

    class Meta:
        db_table = "booking_equipment"
        verbose_name = "matériel de réservation"
        verbose_name_plural = "matériel de réservation"
        constraints = [
            models.UniqueConstraint(fields=["booking", "equipment"], name="unique_booking_equipment"),
            models.CheckConstraint(check=models.Q(quantity__gt=0), name="booking_equipment_quantity_positive"),
        ]


class CancellationRequest(models.Model):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    STATUS_CHOICES = [(PENDING, "En attente"), (APPROVED, "Acceptée"), (REJECTED, "Refusée")]

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name="cancellation_requests", verbose_name="réservation")
    reason = models.CharField("motif", max_length=255)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=PENDING)
    requested_at = models.DateTimeField("demandée le", default=timezone.now)
    reviewed_at = models.DateTimeField("traitée le", null=True, blank=True)
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="reviewed_cancellation_requests",
        verbose_name="traitée par",
        null=True,
        blank=True,
    )

    class Meta:
        db_table = "cancellation_requests"
        verbose_name = "demande d'annulation"
        verbose_name_plural = "demandes d'annulation"
        ordering = ["-requested_at"]
        indexes = [models.Index(fields=["status", "requested_at"], name="idx_cancel_request_status")]

    def __str__(self):
        return f"Demande d'annulation #{self.pk} - réservation #{self.booking_id}"


class PreparatoryAppointment(models.Model):
    ONLINE = "online"
    IN_PERSON = "in_person"
    MODE_CHOICES = [
        (ONLINE, "En ligne"),
        (IN_PERSON, "En présentiel"),
    ]
    PLANNED = "planned"
    DONE = "done"
    CANCELLED = "cancelled"
    STATUS_CHOICES = [
        (PLANNED, "Planifié"),
        (DONE, "Réalisé"),
        (CANCELLED, "Annulé"),
    ]

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name="appointments", verbose_name="réservation")
    scheduled_at = models.DateTimeField("date et heure du rendez-vous")
    mode = models.CharField("mode", max_length=20, choices=MODE_CHOICES, default=ONLINE)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=PLANNED)
    notes = models.TextField("notes", blank=True)

    class Meta:
        db_table = "preparatory_appointments"
        verbose_name = "rendez-vous préparatoire"
        verbose_name_plural = "rendez-vous préparatoires"

    def __str__(self):
        return f"Rendez-vous #{self.pk} - {self.scheduled_at:%d/%m/%Y}"


class Contract(models.Model):
    DRAFT = "draft"
    SENT = "sent"
    SIGNED = "signed"
    CANCELLED = "cancelled"
    STATUS_CHOICES = [
        (DRAFT, "Brouillon"),
        (SENT, "Envoyé"),
        (SIGNED, "Signé"),
        (CANCELLED, "Annulé"),
    ]

    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name="contract", verbose_name="réservation")
    contract_number = models.CharField("numéro de contrat", max_length=40, unique=True)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=DRAFT)
    refund_policy = models.CharField("modalités de remboursement", max_length=255)
    signed_by_client_at = models.DateTimeField("signé par le client le", null=True, blank=True)
    created_at = models.DateTimeField("créé le", auto_now_add=True)

    class Meta:
        db_table = "contracts"
        verbose_name = "contrat"
        verbose_name_plural = "contrats"

    def __str__(self):
        return self.contract_number


class Playlist(models.Model):
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name="playlist", verbose_name="réservation")
    main_style = models.ForeignKey(MusicStyle, on_delete=models.PROTECT, verbose_name="style principal")
    notes = models.CharField("notes", max_length=255, blank=True)
    created_at = models.DateTimeField("créé le", auto_now_add=True)

    class Meta:
        db_table = "playlists"
        verbose_name = "playlist"
        verbose_name_plural = "playlists"

    def __str__(self):
        return f"Playlist - {self.booking}"


class PlaylistSong(models.Model):
    MUST_PLAY = "must_play"
    PLAY_IF_POSSIBLE = "play_if_possible"
    DO_NOT_PLAY = "do_not_play"
    PREFERENCE_CHOICES = [
        (MUST_PLAY, "À jouer absolument"),
        (PLAY_IF_POSSIBLE, "À jouer si possible"),
        (DO_NOT_PLAY, "À ne pas jouer"),
    ]

    REQUESTED = "requested"
    APPROVED = "approved"
    REJECTED = "rejected"
    STATUS_CHOICES = [
        (REQUESTED, "Demandée"),
        (APPROVED, "Acceptée"),
        (REJECTED, "Refusée"),
    ]

    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name="songs", verbose_name="playlist")
    title = models.CharField("titre", max_length=160)
    artist = models.CharField("artiste", max_length=120)
    preference_level = models.CharField("préférence", max_length=30, choices=PREFERENCE_CHOICES, default=PLAY_IF_POSSIBLE)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=REQUESTED)

    class Meta:
        db_table = "playlist_songs"
        verbose_name = "chanson de playlist"
        verbose_name_plural = "chansons de playlist"


class Review(models.Model):
    PENDING = "pending"
    PUBLISHED = "published"
    REJECTED = "rejected"
    STATUS_CHOICES = [
        (PENDING, "En attente"),
        (PUBLISHED, "Publié"),
        (REJECTED, "Rejeté"),
    ]

    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name="review", verbose_name="réservation")
    client = models.ForeignKey(ClientProfile, on_delete=models.PROTECT, related_name="reviews", verbose_name="client")
    dj = models.ForeignKey(DJProfile, on_delete=models.PROTECT, related_name="reviews", verbose_name="DJ")
    rating = models.PositiveSmallIntegerField("note")
    comment = models.CharField("commentaire", max_length=255)
    status = models.CharField("statut", max_length=20, choices=STATUS_CHOICES, default=PENDING)
    created_at = models.DateTimeField("créé le", auto_now_add=True)

    class Meta:
        db_table = "reviews"
        verbose_name = "avis client"
        verbose_name_plural = "avis clients"
        constraints = [
            models.CheckConstraint(check=models.Q(rating__gte=1) & models.Q(rating__lte=5), name="review_rating_between_1_and_5"),
        ]

    def __str__(self):
        return f"{self.rating}/5 - {self.booking}"
