from django.db import models

from apps.accounts.models import ClientProfile, DJProfile
from apps.catalog.models import EventType, MusicStyle, Package, ServiceOption


class Venue(models.Model):
    client = models.ForeignKey(ClientProfile, on_delete=models.CASCADE, related_name="venues")
    name = models.CharField(max_length=120)
    street = models.CharField(max_length=160)
    postal_code = models.CharField(max_length=20)
    city = models.CharField(max_length=80)
    country = models.CharField(max_length=80, default="Belgique")
    has_parking = models.BooleanField(default=False)
    distance_km_from_base = models.DecimalField(max_digits=6, decimal_places=2)

    class Meta:
        db_table = "venues"

    def __str__(self):
        return f"{self.name} - {self.city}"


class Quote(models.Model):
    DRAFT = "draft"
    SENT = "sent"
    ACCEPTED = "accepted"
    REFUSED = "refused"
    STATUS_CHOICES = [(DRAFT, "Brouillon"), (SENT, "Envoyé"), (ACCEPTED, "Accepté"), (REFUSED, "Refusé")]

    client = models.ForeignKey(ClientProfile, on_delete=models.PROTECT, related_name="quotes")
    event_type = models.ForeignKey(EventType, on_delete=models.PROTECT)
    package = models.ForeignKey(Package, on_delete=models.PROTECT)
    venue = models.ForeignKey(Venue, on_delete=models.PROTECT)
    event_date = models.DateField()
    start_time = models.TimeField()
    duration_hours = models.DecimalField(max_digits=4, decimal_places=1)
    guest_count = models.PositiveSmallIntegerField()
    selected_options = models.ManyToManyField(ServiceOption, blank=True, related_name="quotes")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=DRAFT)
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    travel_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    deposit_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "quotes"

    def __str__(self):
        return f"Devis #{self.pk} - {self.client}"


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

    quote = models.OneToOneField(Quote, on_delete=models.PROTECT, related_name="booking")
    client = models.ForeignKey(ClientProfile, on_delete=models.PROTECT, related_name="bookings")
    dj = models.ForeignKey(DJProfile, on_delete=models.PROTECT, related_name="bookings")
    event_type = models.ForeignKey(EventType, on_delete=models.PROTECT)
    package = models.ForeignKey(Package, on_delete=models.PROTECT)
    venue = models.ForeignKey(Venue, on_delete=models.PROTECT)
    event_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default=PREPARATORY_MEETING)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    deposit_required = models.DecimalField(max_digits=10, decimal_places=2)
    deposit_paid = models.BooleanField(default=False)
    cancellation_reason = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "bookings"
        constraints = [
            models.UniqueConstraint(fields=["dj", "event_date", "start_time"], name="unique_confirmed_dj_slot"),
            models.CheckConstraint(check=models.Q(end_time__gt=models.F("start_time")), name="booking_end_after_start"),
        ]

    def __str__(self):
        return f"Réservation #{self.pk} - {self.event_date}"


class Playlist(models.Model):
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name="playlist")
    main_style = models.ForeignKey(MusicStyle, on_delete=models.PROTECT)
    notes = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "playlists"


class PlaylistSong(models.Model):
    MUST_PLAY = "must_play"
    PLAY_IF_POSSIBLE = "play_if_possible"
    DO_NOT_PLAY = "do_not_play"
    PREFERENCE_CHOICES = [
        (MUST_PLAY, "À jouer absolument"),
        (PLAY_IF_POSSIBLE, "À jouer si possible"),
        (DO_NOT_PLAY, "À ne pas jouer"),
    ]

    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name="songs")
    title = models.CharField(max_length=160)
    artist = models.CharField(max_length=120)
    preference_level = models.CharField(max_length=30, choices=PREFERENCE_CHOICES, default=PLAY_IF_POSSIBLE)

    class Meta:
        db_table = "playlist_songs"
