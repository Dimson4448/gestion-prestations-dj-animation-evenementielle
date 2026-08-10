import { useEffect, useMemo, useState } from "react";
import {
  CalendarDays,
  Check,
  ChevronRight,
  CircleUserRound,
  Clock3,
  CreditCard,
  Download,
  FileText,
  Headphones,
  MapPin,
  Music2,
  Settings,
  ShieldCheck,
  Sparkles,
  Star,
  UsersRound,
  X,
} from "lucide-react";

import { apiClient, authenticate, cancelAccountDeletionRequest, changePassword, clearAuthentication, confirmPasswordReset, createAccountDeletionRequest, getAccountDeletionRequests, getClientProfile, getCurrentUser, getStoredAccessToken, logout, registerClient, requestPasswordReset, resendVerificationEmail, reviewAccountDeletionRequest, sessionExpiredEvent, updateClientProfile, verifyEmail } from "./api";
import SiteFooter from "./components/SiteFooter";
import SiteHeader from "./components/SiteHeader";
import HomePage from "./pages/HomePage";
import { calculateQuoteEstimate, canCreatePlaylist, canPlanAppointment, canSubmitReview, formatEuro, hasBookingEnded, mapAvailableDjs } from "./utils/booking";
import { decoratePackages, filterPackagesForEventType } from "./utils/catalogue";
import { allowedEventTypeNames, filterAllowedEventTypes } from "./utils/eventTypes";

const unassignedDj = {
  id: null,
  name: "DJ à confirmer",
  styles: "Sélectionnez un créneau disponible",
  slot: "À confirmer avec l’administration",
  rating: null,
  reviews: 0,
};

const todayIso = new Date().toISOString().slice(0, 10);

const quoteStatusLabels = {
  draft: "Brouillon",
  sent: "Envoyé",
  accepted: "Accepté",
  refused: "Refusé",
  expired: "Expiré",
};

const contractStatusLabels = {
  draft: "Brouillon",
  sent: "À signer",
  signed: "Signé",
  cancelled: "Annulé",
};

export default function App() {
  const [page, setPage] = useState("accueil");
  const [language, setLanguage] = useState("FR");
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [packages, setPackages] = useState([]);
  const [catalogueStatus, setCatalogueStatus] = useState("Chargement du catalogue Django…");
  const [catalogueReady, setCatalogueReady] = useState(false);
  const [availableDjs, setAvailableDjs] = useState([]);
  const [publicAvailabilityStatus, setPublicAvailabilityStatus] = useState("Recherche des créneaux Django…");
  const [eventTypeRecords, setEventTypeRecords] = useState([]);
  const [selectedPackageId, setSelectedPackageId] = useState("mariage");
  const [selectedDj, setSelectedDj] = useState(unassignedDj);
  const [eventType, setEventType] = useState("Mariage");
  const [eventDate, setEventDate] = useState("2026-09-12");
  const [startTime, setStartTime] = useState("18:00");
  const [location, setLocation] = useState("Bruxelles");
  const [venueName, setVenueName] = useState("Lieu de l’événement");
  const [venueStreet, setVenueStreet] = useState("");
  const [venuePostalCode, setVenuePostalCode] = useState("");
  const [venueCountry, setVenueCountry] = useState("Belgique");
  const [venues, setVenues] = useState([]);
  const [selectedVenueId, setSelectedVenueId] = useState("new");
  const [venueStatus, setVenueStatus] = useState("");
  const [venuePending, setVenuePending] = useState(false);
  const [durationHours, setDurationHours] = useState(8);
  const [distanceKm, setDistanceKm] = useState(20);
  const [guestCount, setGuestCount] = useState(80);
  const [parking, setParking] = useState("oui");
  const [musicPreferences, setMusicPreferences] = useState("Pop, disco et classiques des années 90");
  const [quoteSubmitted, setQuoteSubmitted] = useState(false);
  const [quotePending, setQuotePending] = useState(false);
  const [quoteStatus, setQuoteStatus] = useState("");
  const [createdQuote, setCreatedQuote] = useState(null);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [isAuthenticated, setIsAuthenticated] = useState(Boolean(getStoredAccessToken()));
  const [currentUser, setCurrentUser] = useState(null);
  const [loginStatus, setLoginStatus] = useState("");
  const [loginPending, setLoginPending] = useState(false);
  const [registrationOpen, setRegistrationOpen] = useState(false);
  const [registrationPending, setRegistrationPending] = useState(false);
  const [registrationStatus, setRegistrationStatus] = useState("");
  const [registration, setRegistration] = useState({
    username: "",
    email: "",
    password: "",
    first_name: "",
    last_name: "",
    date_of_birth: "",
    phone: "",
    billing_address: "",
    billing_city: "",
    billing_postal_code: "",
    preferred_language: "fr",
  });
  const [passwordResetOpen, setPasswordResetOpen] = useState(false);
  const [passwordResetEmail, setPasswordResetEmail] = useState("");
  const [passwordResetCredentials, setPasswordResetCredentials] = useState({ uid: "", token: "" });
  const [newPassword, setNewPassword] = useState("");
  const [passwordResetPending, setPasswordResetPending] = useState(false);
  const [passwordResetStatus, setPasswordResetStatus] = useState("");
  const [verificationResendOpen, setVerificationResendOpen] = useState(false);
  const [verificationResendEmail, setVerificationResendEmail] = useState("");
  const [verificationResendPending, setVerificationResendPending] = useState(false);
  const [verificationResendStatus, setVerificationResendStatus] = useState("");
  const [clientProfile, setClientProfile] = useState(null);
  const [clientProfileOpen, setClientProfileOpen] = useState(false);
  const [clientProfilePending, setClientProfilePending] = useState(false);
  const [clientProfileStatus, setClientProfileStatus] = useState("");
  const [passwordChangeOpen, setPasswordChangeOpen] = useState(false);
  const [currentPassword, setCurrentPassword] = useState("");
  const [changedPassword, setChangedPassword] = useState("");
  const [passwordChangePending, setPasswordChangePending] = useState(false);
  const [passwordChangeStatus, setPasswordChangeStatus] = useState("");
  const [accountDeletionRequests, setAccountDeletionRequests] = useState([]);
  const [accountDeletionReason, setAccountDeletionReason] = useState("");
  const [accountDeletionPending, setAccountDeletionPending] = useState(false);
  const [accountDeletionStatus, setAccountDeletionStatus] = useState("");
  const [adminDeletionRequests, setAdminDeletionRequests] = useState([]);
  const [adminDeletionMessages, setAdminDeletionMessages] = useState({});
  const [adminDeletionPendingId, setAdminDeletionPendingId] = useState(null);
  const [invoices, setInvoices] = useState([]);
  const [clientPayments, setClientPayments] = useState([]);
  const [contracts, setContracts] = useState([]);
  const [contractStatus, setContractStatus] = useState("");
  const [contractPendingId, setContractPendingId] = useState(null);
  const [downloadPending, setDownloadPending] = useState("");
  const [invoiceStatus, setInvoiceStatus] = useState("");
  const [clientQuotes, setClientQuotes] = useState([]);
  const [quoteListStatus, setQuoteListStatus] = useState("");
  const [checkoutPendingId, setCheckoutPendingId] = useState(null);
  const [checkoutStatus, setCheckoutStatus] = useState("");
  const [paymentReturnStatus, setPaymentReturnStatus] = useState("");
  const [adminQuotes, setAdminQuotes] = useState([]);
  const [adminDjs, setAdminDjs] = useState([]);
  const [adminDjSelection, setAdminDjSelection] = useState({});
  const [adminStatus, setAdminStatus] = useState("");
  const [adminPendingId, setAdminPendingId] = useState(null);
  const [adminBookings, setAdminBookings] = useState([]);
  const [completionPendingId, setCompletionPendingId] = useState(null);
  const [djBookings, setDjBookings] = useState([]);
  const [djAppointments, setDjAppointments] = useState([]);
  const [djSongs, setDjSongs] = useState([]);
  const [djAvailabilities, setDjAvailabilities] = useState([]);
  const [djStatus, setDjStatus] = useState("");
  const [djPendingId, setDjPendingId] = useState(null);
  const [djAppointmentPendingId, setDjAppointmentPendingId] = useState(null);
  const [djSongPendingId, setDjSongPendingId] = useState(null);
  const [availabilityPendingId, setAvailabilityPendingId] = useState(null);
  const [availabilityDate, setAvailabilityDate] = useState(todayIso);
  const [availabilityStart, setAvailabilityStart] = useState("18:00");
  const [availabilityEnd, setAvailabilityEnd] = useState("23:59");
  const [availabilityStatus, setAvailabilityStatus] = useState("available");
  const [availabilityReason, setAvailabilityReason] = useState("");
  const [clientBookings, setClientBookings] = useState([]);
  const [cancellationRequests, setCancellationRequests] = useState([]);
  const [cancellationReasons, setCancellationReasons] = useState({});
  const [cancellationPendingId, setCancellationPendingId] = useState(null);
  const [cancellationStatus, setCancellationStatus] = useState("");
  const [adminCancellationRequests, setAdminCancellationRequests] = useState([]);
  const [adminCancellationMessages, setAdminCancellationMessages] = useState({});
  const [adminCancellationPendingId, setAdminCancellationPendingId] = useState(null);
  const [adminPayments, setAdminPayments] = useState([]);
  const [refundPendingId, setRefundPendingId] = useState(null);
  const [playlists, setPlaylists] = useState([]);
  const [playlistSongs, setPlaylistSongs] = useState([]);
  const [musicStyles, setMusicStyles] = useState([]);
  const [playlistStatus, setPlaylistStatus] = useState("");
  const [playlistPending, setPlaylistPending] = useState(false);
  const [playlistBookingId, setPlaylistBookingId] = useState("");
  const [playlistStyleId, setPlaylistStyleId] = useState("");
  const [playlistNotes, setPlaylistNotes] = useState("");
  const [songPlaylistId, setSongPlaylistId] = useState("");
  const [songTitle, setSongTitle] = useState("");
  const [songArtist, setSongArtist] = useState("");
  const [songPreference, setSongPreference] = useState("play_if_possible");
  const [appointments, setAppointments] = useState([]);
  const [appointmentStatus, setAppointmentStatus] = useState("");
  const [appointmentPending, setAppointmentPending] = useState(false);
  const [appointmentBookingId, setAppointmentBookingId] = useState("");
  const [appointmentDateTime, setAppointmentDateTime] = useState("");
  const [appointmentMode, setAppointmentMode] = useState("online");
  const [appointmentNotes, setAppointmentNotes] = useState("");
  const [reviews, setReviews] = useState([]);
  const [reviewStatus, setReviewStatus] = useState("");
  const [reviewPending, setReviewPending] = useState(false);
  const [reviewBookingId, setReviewBookingId] = useState("");
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewComment, setReviewComment] = useState("");

  useEffect(() => {
    const handleSessionExpired = () => {
      setIsAuthenticated(false);
      setCurrentUser(null);
      setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
    };
    window.addEventListener(sessionExpiredEvent, handleSessionExpired);
    return () => window.removeEventListener(sessionExpiredEvent, handleSessionExpired);
  }, []);

  useEffect(() => {
    if (!isAuthenticated) {
      setCurrentUser(null);
      return;
    }
    let mounted = true;
    getCurrentUser()
      .then((profile) => mounted && setCurrentUser(profile))
      .catch(() => {
        if (!mounted) return;
        clearAuthentication();
        setIsAuthenticated(false);
        setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
      });
    return () => { mounted = false; };
  }, [isAuthenticated]);

  useEffect(() => {
    const parameters = new URLSearchParams(window.location.search);
    const verificationUid = parameters.get("verify_uid");
    const verificationToken = parameters.get("verify_token");
    if (verificationUid && verificationToken) {
      setPage("compte");
      setLoginStatus("Vérification de votre adresse e-mail…");
      window.history.replaceState({}, document.title, window.location.pathname);
      verifyEmail(verificationUid, verificationToken)
        .then(() => setLoginStatus("Votre adresse e-mail est confirmée. Vous pouvez maintenant vous connecter."))
        .catch((error) => {
          const details = error.response?.data;
          const firstError = details && Object.values(details).flat()[0];
          setLoginStatus(firstError || "Ce lien de vérification est invalide ou a expiré.");
        });
      return;
    }
    const resetUid = parameters.get("reset_uid");
    const resetToken = parameters.get("reset_token");
    if (resetUid && resetToken) {
      setPage("compte");
      setPasswordResetOpen(true);
      setPasswordResetCredentials({ uid: resetUid, token: resetToken });
      setPasswordResetStatus("Choisissez maintenant votre nouveau mot de passe.");
      return;
    }
    const paymentResult = parameters.get("payment");
    if (!paymentResult) return;

    setPage("compte");
    if (paymentResult === "success") {
      setPaymentReturnStatus(
        "Paiement transmis à Stripe. La confirmation définitive apparaîtra après validation sécurisée du webhook.",
      );
    } else if (paymentResult === "cancelled") {
      setPaymentReturnStatus("Paiement annulé : aucun acompte n’a été confirmé. Vous pourrez réessayer.");
    }
    window.history.replaceState({}, document.title, window.location.pathname);
  }, []);

  useEffect(() => {
    let mounted = true;
    apiClient
      .get("/packages/")
      .then((response) => {
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        if (mounted && Array.isArray(data) && data.length) {
          const mappedPackages = decoratePackages(data);
          setPackages(mappedPackages);
          setSelectedPackageId((current) => mappedPackages.some((item) => String(item.id) === String(current)) ? current : mappedPackages[0].id);
          setCatalogueReady(true);
          setCatalogueStatus("Catalogue synchronisé avec l’API locale");
        } else if (mounted) {
          setPackages([]);
          setCatalogueReady(false);
          setCatalogueStatus("Aucune offre active dans le catalogue Django");
        }
      })
      .catch(() => {
        if (mounted) {
          setPackages([]);
          setCatalogueReady(false);
          setCatalogueStatus("Catalogue indisponible · vérifiez la connexion au backend Django");
        }
      });
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!eventDate) return undefined;

    let mounted = true;
    setPublicAvailabilityStatus("Recherche des créneaux disponibles…");
    apiClient
      .get("/availability/", { params: { date: eventDate } })
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        const slots = Array.isArray(data) ? data : [];
        const records = mapAvailableDjs(slots);
        setAvailableDjs(records);
        setPublicAvailabilityStatus(
          records.length
            ? "Disponibilités synchronisées avec Django"
            : "Aucun DJ disponible à cette date",
        );
      })
      .catch(() => {
        if (!mounted) return;
        setAvailableDjs([]);
        setPublicAvailabilityStatus("Disponibilités indisponibles · vérifiez la connexion au backend Django");
      });

    return () => {
      mounted = false;
    };
  }, [eventDate]);

  useEffect(() => {
    let mounted = true;
    apiClient
      .get("/event-types/")
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        if (Array.isArray(data) && data.length) {
          const supportedRecords = filterAllowedEventTypes(data);
          setEventTypeRecords(supportedRecords);
          if (supportedRecords.length) {
            setEventType((current) => supportedRecords.some((item) => item.name === current) ? current : supportedRecords[0].name);
          }
        }
      })
      .catch(() => mounted && setEventTypeRecords([]));
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") {
      setInvoices([]);
      setClientPayments([]);
      setClientQuotes([]);
      setVenues([]);
      setSelectedVenueId("new");
      return;
    }

    let mounted = true;
    setInvoiceStatus("Chargement de vos factures…");
    Promise.all([
      apiClient.get("/invoices/", { params: { ordering: "-issued_at" } }),
      apiClient.get("/payments/", { params: { ordering: "-paid_at" } }),
    ])
      .then(([invoiceResponse, paymentResponse]) => {
        if (!mounted) return;
        const invoices = Array.isArray(invoiceResponse.data?.results) ? invoiceResponse.data.results : invoiceResponse.data;
        const payments = Array.isArray(paymentResponse.data?.results) ? paymentResponse.data.results : paymentResponse.data;
        setInvoices(Array.isArray(invoices) ? invoices : []);
        setClientPayments(Array.isArray(payments) ? payments : []);
        setInvoiceStatus(invoices?.length ? "" : "Aucune facture disponible.");
      })
      .catch((error) => {
        if (!mounted) return;
        if (error.response?.status === 401) {
          clearAuthentication();
          setIsAuthenticated(false);
          setInvoiceStatus("");
          setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
        } else {
          setInvoiceStatus("Impossible de charger les factures pour le moment.");
        }
      });
    return () => {
      mounted = false;
    };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || currentUser?.role !== "client") {
      setAccountDeletionRequests([]);
      return;
    }
    let mounted = true;
    getAccountDeletionRequests()
      .then((requests) => mounted && setAccountDeletionRequests(requests))
      .catch(() => mounted && setAccountDeletionStatus("Impossible de charger vos demandes de suppression."));
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || currentUser?.role !== "client") {
      setClientProfile(null);
      return;
    }
    let mounted = true;
    getClientProfile()
      .then((profile) => mounted && setClientProfile(profile))
      .catch(() => mounted && setClientProfileStatus("Impossible de charger vos coordonnées."));
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") {
      setReviews([]);
      return;
    }
    let mounted = true;
    setReviewStatus("Chargement de vos avis…");
    apiClient.get("/reviews/", { params: { ordering: "-created_at" } })
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        const records = Array.isArray(data) ? data : [];
        setReviews(records);
        setReviewStatus(records.length ? "" : "Aucun avis déposé.");
      })
      .catch(() => mounted && setReviewStatus("Impossible de charger vos avis."));
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") {
      setAppointments([]);
      return;
    }
    let mounted = true;
    setAppointmentStatus("Chargement de vos rendez-vous…");
    apiClient.get("/appointments/", { params: { ordering: "scheduled_at" } })
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        const records = Array.isArray(data) ? data : [];
        setAppointments(records);
        setAppointmentStatus(records.length ? "" : "Aucun rendez-vous préparatoire planifié.");
      })
      .catch(() => mounted && setAppointmentStatus("Impossible de charger les rendez-vous."));
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") {
      setClientBookings([]);
      setCancellationRequests([]);
      setPlaylists([]);
      setPlaylistSongs([]);
      return;
    }
    let mounted = true;
    setPlaylistStatus("Chargement de vos playlists…");
    Promise.all([
      apiClient.get("/bookings/", { params: { ordering: "-event_date" } }),
      apiClient.get("/playlists/"),
      apiClient.get("/playlist-songs/", { params: { ordering: "title" } }),
      apiClient.get("/music-styles/", { params: { ordering: "name" } }),
    ])
      .then(async ([bookingsResponse, playlistsResponse, songsResponse, stylesResponse]) => {
        if (!mounted) return;
        const records = (response) => Array.isArray(response.data?.results) ? response.data.results : (Array.isArray(response.data) ? response.data : []);
        const bookingRecords = records(bookingsResponse);
        const playlistRecords = records(playlistsResponse);
        const songRecords = records(songsResponse);
        const styleRecords = records(stylesResponse);
        setClientBookings(bookingRecords);
        const requestResponses = await Promise.all(
          bookingRecords.map((booking) => apiClient.get(`/bookings/${booking.id}/cancellation-requests/`)),
        );
        if (!mounted) return;
        setCancellationRequests(requestResponses.flatMap((response) => response.data));
        setPlaylists(playlistRecords);
        setPlaylistSongs(songRecords);
        setMusicStyles(styleRecords);
        const eligible = bookingRecords.filter((item) => item.deposit_paid && ["confirmed", "performed", "paid"].includes(item.status) && !playlistRecords.some((playlist) => playlist.booking === item.id));
        setPlaylistBookingId((current) => current || String(eligible[0]?.id || ""));
        setPlaylistStyleId((current) => current || String(styleRecords[0]?.id || ""));
        setSongPlaylistId((current) => current || String(playlistRecords[0]?.id || ""));
        setPlaylistStatus(playlistRecords.length || eligible.length ? "" : "La playlist sera disponible après confirmation de l’acompte.");
      })
      .catch(() => mounted && setPlaylistStatus("Impossible de charger les playlists pour le moment."));
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") {
      setContracts([]);
      return;
    }
    let mounted = true;
    setContractStatus("Chargement de vos contrats…");
    apiClient.get("/contracts/", { params: { ordering: "-created_at" } })
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        const records = Array.isArray(data) ? data : [];
        setContracts(records);
        setContractStatus(records.length ? "" : "Aucun contrat disponible.");
      })
      .catch((error) => {
        if (!mounted) return;
        setContractStatus(error.response?.status === 401 ? "Votre session a expiré." : "Impossible de charger vos contrats.");
      });
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") return;

    let mounted = true;
    setQuoteListStatus("Chargement de vos devis…");
    apiClient
      .get("/quotes/", { params: { ordering: "-created_at" } })
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        const quotes = Array.isArray(data) ? data : [];
        setClientQuotes(quotes);
        setQuoteListStatus(quotes.length ? "" : "Aucun devis enregistré.");
      })
      .catch((error) => {
        if (!mounted) return;
        if (error.response?.status === 401) {
          clearAuthentication();
          setIsAuthenticated(false);
          setQuoteListStatus("");
          setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
        } else {
          setQuoteListStatus("Impossible de charger vos devis pour le moment.");
        }
      });
    return () => {
      mounted = false;
    };
  }, [isAuthenticated, currentUser]);

  useEffect(() => {
    if (!isAuthenticated || !currentUser || currentUser.role !== "client") return;

    let mounted = true;
    apiClient
      .get("/venues/", { params: { ordering: "city,name" } })
      .then((response) => {
        if (!mounted) return;
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        setVenues(Array.isArray(data) ? data : []);
      })
      .catch((error) => {
        if (mounted && error.response?.status !== 401) {
          setVenueStatus("Impossible de charger vos lieux enregistrés.");
        }
      });
    return () => {
      mounted = false;
    };
  }, [isAuthenticated, currentUser]);

  const loadAdminDashboard = async () => {
    setAdminStatus("Chargement des devis, réservations et DJs…");
    try {
      const [quotesResponse, djsResponse, bookingsResponse, paymentsResponse, deletionResponse] = await Promise.all([
        apiClient.get("/quotes/", { params: { ordering: "-created_at" } }),
        apiClient.get("/djs/", { params: { ordering: "stage_name" } }),
        apiClient.get("/bookings/", { params: { ordering: "-event_date" } }),
        apiClient.get("/payments/", { params: { ordering: "-paid_at" } }),
        getAccountDeletionRequests(),
      ]);
      const quotes = Array.isArray(quotesResponse.data?.results) ? quotesResponse.data.results : quotesResponse.data;
      const djs = Array.isArray(djsResponse.data?.results) ? djsResponse.data.results : djsResponse.data;
      const bookings = Array.isArray(bookingsResponse.data?.results) ? bookingsResponse.data.results : bookingsResponse.data;
      const payments = Array.isArray(paymentsResponse.data?.results) ? paymentsResponse.data.results : paymentsResponse.data;
      const bookingRecords = Array.isArray(bookings) ? bookings : [];
      const requestResponses = await Promise.all(
        bookingRecords.map((booking) => apiClient.get(`/bookings/${booking.id}/cancellation-requests/`)),
      );
      setAdminQuotes((Array.isArray(quotes) ? quotes : []).filter((item) => ["draft", "sent"].includes(item.status)));
      setAdminDjs(Array.isArray(djs) ? djs : []);
      setAdminPayments(Array.isArray(payments) ? payments : []);
      setAdminDeletionRequests((Array.isArray(deletionResponse) ? deletionResponse : []).filter((item) => item.status === "pending"));
      setAdminBookings(
        bookingRecords.filter(
          (item) => item.status === "confirmed" && item.deposit_paid && hasBookingEnded(item),
        ),
      );
      setAdminCancellationRequests(
        requestResponses.flatMap((response) => response.data).filter((item) => item.status === "pending"),
      );
      setAdminStatus("");
    } catch (error) {
      setAdminStatus(error.response?.status === 403 ? "Ce compte n’a pas les droits administrateur." : "Impossible de charger l’espace administrateur.");
    }
  };

  useEffect(() => {
    if (currentUser?.is_staff) loadAdminDashboard();
  }, [currentUser]);

  useEffect(() => {
    if (!isAuthenticated || currentUser?.role !== "dj") {
      setDjBookings([]);
      setDjAppointments([]);
      setDjSongs([]);
      setDjAvailabilities([]);
      return;
    }
    let mounted = true;
    setDjStatus("Chargement de votre espace DJ…");
    Promise.all([
      apiClient.get("/bookings/", { params: { ordering: "event_date" } }),
      apiClient.get("/appointments/", { params: { ordering: "scheduled_at" } }),
      apiClient.get("/playlist-songs/", { params: { ordering: "title" } }),
      apiClient.get("/availability/"),
    ])
      .then(([bookingsResponse, appointmentsResponse, songsResponse, availabilitiesResponse]) => {
        if (!mounted) return;
        const records = (response) => Array.isArray(response.data?.results) ? response.data.results : (Array.isArray(response.data) ? response.data : []);
        const bookings = records(bookingsResponse);
        const appointments = records(appointmentsResponse);
        const songs = records(songsResponse);
        const availabilities = records(availabilitiesResponse);
        setDjBookings(bookings);
        setDjAppointments(appointments);
        setDjSongs(songs);
        setDjAvailabilities(availabilities);
        setDjStatus(bookings.length || appointments.length || songs.length || availabilities.length ? "" : "Aucun dossier ne vous est affecté.");
      })
      .catch((error) => {
        if (mounted) setDjStatus(error.response?.status === 403 ? "Ce compte n’a pas accès à l’espace DJ." : "Impossible de charger vos prestations.");
      });
    return () => { mounted = false; };
  }, [isAuthenticated, currentUser]);

  const availableEventTypes = eventTypeRecords.length ? eventTypeRecords.map((item) => item.name) : allowedEventTypeNames;
  const selectedEventTypeRecord = eventTypeRecords.find((item) => item.name === eventType);
  const compatiblePackages = useMemo(
    () => filterPackagesForEventType(packages, selectedEventTypeRecord?.id),
    [packages, selectedEventTypeRecord?.id],
  );
  const selectedPackage = useMemo(
    () => compatiblePackages.find((item) => String(item.id) === String(selectedPackageId)) || compatiblePackages[0],
    [compatiblePackages, selectedPackageId],
  );

  useEffect(() => {
    if (selectedPackage && String(selectedPackage.id) !== String(selectedPackageId)) {
      setSelectedPackageId(selectedPackage.id);
    }
  }, [selectedPackage, selectedPackageId]);
  const playlistBookingIds = new Set(playlists.map((item) => item.booking));
  const eligiblePlaylistBookings = clientBookings.filter((item) => canCreatePlaylist(item, playlistBookingIds));
  const plannedAppointmentBookingIds = new Set(
    appointments.filter((item) => item.status === "planned").map((item) => item.booking),
  );
  const eligibleAppointmentBookings = clientBookings.filter((item) => {
    const type = eventTypeRecords.find((record) => record.id === item.event_type);
    return canPlanAppointment(item, type, plannedAppointmentBookingIds);
  });
  const reviewedBookingIds = new Set(reviews.map((item) => item.booking));
  const eligibleReviewBookings = clientBookings.filter((item) => canSubmitReview(item, reviewedBookingIds));

  const quote = useMemo(() => {
    return calculateQuoteEstimate({
      basePrice: selectedPackage?.base_price,
      includedHours: selectedPackage?.included_hours,
      durationHours,
      distanceKm,
    });
  }, [distanceKm, durationHours, selectedPackage]);

  const navigate = (target) => {
    setPage(target);
    setMobileNavOpen(false);
    setQuoteSubmitted(false);
    window.scrollTo({ top: 0, behavior: "smooth" });
    window.requestAnimationFrame(() => {
      document.getElementById("main-content")?.focus({ preventScroll: true });
    });
  };

  const openDetail = (item, dj = selectedDj) => {
    setSelectedPackageId(item.id);
    setSelectedDj(dj);
    navigate("detail");
  };

  const startQuote = () => navigate("devis");

  const selectVenue = (venueId) => {
    setSelectedVenueId(venueId);
    setVenueStatus("");
    if (venueId === "new") return;
    const venue = venues.find((item) => String(item.id) === String(venueId));
    if (!venue) return;
    setVenueName(venue.name);
    setVenueStreet(venue.street);
    setVenuePostalCode(venue.postal_code);
    setLocation(venue.city);
    setVenueCountry(venue.country);
    setParking(venue.has_parking ? "oui" : "non");
    setDistanceKm(venue.distance_km_from_base);
  };

  const createVenue = async () => {
    if (!isAuthenticated) {
      setVenueStatus("Connectez-vous dans Mon compte avant d’enregistrer un lieu.");
      return;
    }
    if (!venueName.trim() || !venueStreet.trim() || !venuePostalCode.trim() || !location.trim()) {
      setVenueStatus("Complétez le nom, la rue, le code postal et la ville du lieu.");
      return;
    }

    setVenuePending(true);
    setVenueStatus("");
    try {
      const response = await apiClient.post("/venues/", {
        name: venueName.trim(),
        street: venueStreet.trim(),
        postal_code: venuePostalCode.trim(),
        city: location.trim(),
        country: venueCountry.trim() || "Belgique",
        has_parking: parking === "oui",
        distance_km_from_base: Number(distanceKm || 0).toFixed(2),
      });
      setVenues((current) => [...current, response.data]);
      setSelectedVenueId(String(response.data.id));
      setVenueStatus("Lieu enregistré. Il sera utilisé pour cette demande de devis.");
    } catch (error) {
      if (error.response?.status === 401) {
        clearAuthentication();
        setIsAuthenticated(false);
        setVenueStatus("Votre session a expiré. Reconnectez-vous avant de continuer.");
      } else {
        const details = error.response?.data;
        const firstError = details && Object.values(details).flat()[0];
        setVenueStatus(firstError || "Le lieu n’a pas pu être enregistré.");
      }
    } finally {
      setVenuePending(false);
    }
  };

  const submitQuote = async (event) => {
    event.preventDefault();
    setQuoteStatus("");
    if (!isAuthenticated) {
      setQuoteStatus("Connectez-vous dans Mon compte avant d’envoyer votre demande.");
      return;
    }
    if (!catalogueReady || !eventTypeRecords.length) {
      setQuoteStatus("Le catalogue Django doit être disponible pour enregistrer un devis réel.");
      return;
    }
    if (selectedVenueId === "new") {
      setQuoteStatus("Enregistrez d’abord le nouveau lieu ou sélectionnez un lieu existant.");
      return;
    }

    const selectedEventType = eventTypeRecords.find((item) => item.name === eventType);
    if (!selectedEventType || !selectedPackage?.id) {
      setQuoteStatus("Le type d’événement ou la formule sélectionnée est indisponible.");
      return;
    }

    setQuotePending(true);
    try {
      const response = await apiClient.post("/quotes/", {
        event_type: selectedEventType.id,
        package: selectedPackage.id,
        venue: Number(selectedVenueId),
        event_date: eventDate,
        start_time: startTime,
        duration_hours: Number(durationHours).toFixed(1),
        guest_count: Number(guestCount),
        distance_km: Number(distanceKm || 0).toFixed(2),
        parking_available: parking === "oui",
        music_preferences: musicPreferences.trim(),
      });
      setCreatedQuote(response.data);
      setClientQuotes((current) => [response.data, ...current.filter((item) => item.id !== response.data.id)]);
      setQuoteListStatus("");
      setQuoteSubmitted(true);
    } catch (error) {
      if (error.response?.status === 401) {
        clearAuthentication();
        setIsAuthenticated(false);
        setQuoteStatus("Votre session a expiré. Reconnectez-vous avant de continuer.");
      } else {
        const details = error.response?.data;
        const firstError = details && Object.values(details).flat()[0];
        setQuoteStatus(firstError || "La demande de devis n’a pas pu être enregistrée.");
      }
    } finally {
      setQuotePending(false);
    }
  };

  const handleLogin = async (event) => {
    event.preventDefault();
    setLoginPending(true);
    setLoginStatus("");
    try {
      const profile = await authenticate(username, password);
      setIsAuthenticated(true);
      setCurrentUser(profile);
      setPassword("");
      setLoginStatus(
        profile.is_staff
          ? "Connexion réussie. L’espace administrateur est accessible."
          : profile.role === "dj"
            ? "Connexion réussie. Votre espace DJ est maintenant accessible."
            : "Connexion réussie. Votre espace client est maintenant accessible.",
      );
    } catch (error) {
      setLoginStatus(
        error.response?.status === 429
          ? "Trop de tentatives. Patientez une minute avant de réessayer."
          : error.response?.status === 401
          ? "Identifiant ou mot de passe incorrect."
          : "Connexion impossible. Vérifiez que le backend Django est démarré.",
      );
    } finally {
      setLoginPending(false);
    }
  };

  const handleLogout = async () => {
    await logout().catch(() => {});
    setIsAuthenticated(false);
    setCurrentUser(null);
    setAdminQuotes([]);
    setDjBookings([]);
    setDjAppointments([]);
    setDjSongs([]);
    setDjAvailabilities([]);
    setLoginStatus("Vous êtes déconnecté.");
  };

  const sendQuote = async (quoteId) => {
    setAdminPendingId(quoteId);
    setAdminStatus("");
    try {
      const response = await apiClient.patch(`/quotes/${quoteId}/`, { status: "sent" });
      setAdminQuotes((current) => current.map((item) => item.id === quoteId ? response.data : item));
      setAdminStatus(`Le devis n°${quoteId} est maintenant envoyé et prêt à être accepté.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "Le devis n’a pas pu être envoyé.");
    } finally {
      setAdminPendingId(null);
    }
  };

  const acceptAdminQuote = async (quoteId) => {
    const djId = adminDjSelection[quoteId];
    if (!djId) {
      setAdminStatus("Sélectionnez un DJ avant d’accepter le devis.");
      return;
    }
    setAdminPendingId(quoteId);
    setAdminStatus("");
    try {
      const response = await apiClient.post(`/quotes/${quoteId}/accept/`, { dj: Number(djId) });
      setAdminQuotes((current) => current.filter((item) => item.id !== quoteId));
      setAdminStatus(`Devis n°${quoteId} accepté : réservation n°${response.data.booking.id}, contrat et facture d’acompte créés.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "Le devis n’a pas pu être accepté.");
    } finally {
      setAdminPendingId(null);
    }
  };

  const completeAdminBooking = async (bookingId) => {
    setCompletionPendingId(bookingId);
    setAdminStatus("");
    try {
      const response = await apiClient.post(`/bookings/${bookingId}/complete/`);
      setAdminBookings((current) => current.filter((item) => item.id !== bookingId));
      setAdminStatus(`Réservation n°${bookingId} clôturée : la facture de solde ${response.data.balance_invoice.invoice_number} a été créée.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "La prestation n’a pas pu être clôturée.");
    } finally {
      setCompletionPendingId(null);
    }
  };

  const updateRegistration = (field, value) => {
    setRegistration((current) => ({ ...current, [field]: value }));
  };

  const handleRegistration = async (event) => {
    event.preventDefault();
    setRegistrationPending(true);
    setRegistrationStatus("");
    try {
      const response = await registerClient(registration);
      setUsername(registration.username);
      setPassword("");
      setRegistrationOpen(false);
      setLoginStatus(response.detail);
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setRegistrationStatus(firstError || "L’inscription est impossible pour le moment.");
    } finally {
      setRegistrationPending(false);
    }
  };

  const handlePasswordResetRequest = async (event) => {
    event.preventDefault();
    setPasswordResetPending(true);
    setPasswordResetStatus("");
    try {
      const response = await requestPasswordReset(passwordResetEmail);
      setPasswordResetStatus(response.detail);
    } catch (error) {
      setPasswordResetStatus(error.response?.status === 429 ? "Trop de demandes. Patientez une minute avant de réessayer." : "La demande n’a pas pu être envoyée. Vérifiez que Django est démarré.");
    } finally {
      setPasswordResetPending(false);
    }
  };

  const handleVerificationResend = async (event) => {
    event.preventDefault();
    setVerificationResendPending(true);
    setVerificationResendStatus("");
    try {
      const response = await resendVerificationEmail(verificationResendEmail);
      setVerificationResendStatus(response.detail);
    } catch (error) {
      setVerificationResendStatus(error.response?.status === 429 ? "Trop de demandes. Patientez une minute avant de réessayer." : "La demande n’a pas pu être envoyée. Vérifiez que Django est démarré.");
    } finally {
      setVerificationResendPending(false);
    }
  };

  const changeClientProfile = (field, value) => {
    setClientProfile((current) => ({ ...current, [field]: value }));
  };

  const handleClientProfileUpdate = async (event) => {
    event.preventDefault();
    setClientProfilePending(true);
    setClientProfileStatus("");
    try {
      const profile = await updateClientProfile(clientProfile);
      setClientProfile(profile);
      setCurrentUser((current) => ({ ...current, first_name: profile.first_name, last_name: profile.last_name }));
      setClientProfileStatus("Vos coordonnées ont été mises à jour.");
      setClientProfileOpen(false);
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setClientProfileStatus(firstError || "Vos coordonnées n’ont pas pu être modifiées.");
    } finally {
      setClientProfilePending(false);
    }
  };

  const handlePasswordChange = async (event) => {
    event.preventDefault();
    setPasswordChangePending(true);
    setPasswordChangeStatus("");
    try {
      await changePassword(currentPassword, changedPassword);
      clearAuthentication();
      setIsAuthenticated(false);
      setCurrentUser(null);
      setClientProfile(null);
      setCurrentPassword("");
      setChangedPassword("");
      setLoginStatus("Votre mot de passe a été modifié et votre ancienne session révoquée. Reconnectez-vous.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setPasswordChangeStatus(firstError || "Le mot de passe n’a pas pu être modifié.");
    } finally {
      setPasswordChangePending(false);
    }
  };

  const handleAccountDeletionRequest = async (event) => {
    event.preventDefault();
    setAccountDeletionPending(true);
    setAccountDeletionStatus("");
    try {
      const request = await createAccountDeletionRequest(accountDeletionReason);
      setAccountDeletionRequests((current) => [request, ...current]);
      setAccountDeletionReason("");
      setAccountDeletionStatus("Votre demande de suppression a été enregistrée pour traitement administratif.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setAccountDeletionStatus(firstError || "La demande n’a pas pu être enregistrée.");
    } finally {
      setAccountDeletionPending(false);
    }
  };

  const cancelAccountDeletion = async (requestId) => {
    setAccountDeletionPending(true);
    setAccountDeletionStatus("");
    try {
      const request = await cancelAccountDeletionRequest(requestId);
      setAccountDeletionRequests((current) => current.map((item) => item.id === request.id ? request : item));
      setAccountDeletionStatus("Votre demande de suppression a été annulée.");
    } catch (error) {
      setAccountDeletionStatus(error.response?.data?.detail || "La demande ne peut plus être annulée.");
    } finally {
      setAccountDeletionPending(false);
    }
  };

  const reviewAccountDeletion = async (request, decision) => {
    const message = (adminDeletionMessages[request.id] || "").trim();
    if (message.length < 10) {
      setAdminStatus("Expliquez la décision au client en au moins 10 caractères.");
      return;
    }
    setAdminDeletionPendingId(request.id);
    setAdminStatus("");
    try {
      const reviewed = await reviewAccountDeletionRequest(request.id, decision, message);
      setAdminDeletionRequests((current) => current.filter((item) => item.id !== reviewed.id));
      setAdminStatus(decision === "approved" ? `Le compte de ${request.client_email} a été désactivé et ses sessions révoquées.` : `La demande de ${request.client_email} a été refusée.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "La demande de suppression n’a pas pu être traitée.");
    } finally {
      setAdminDeletionPendingId(null);
    }
  };

  const handlePasswordResetConfirm = async (event) => {
    event.preventDefault();
    setPasswordResetPending(true);
    setPasswordResetStatus("");
    try {
      await confirmPasswordReset(passwordResetCredentials.uid, passwordResetCredentials.token, newPassword);
      setNewPassword("");
      setPasswordResetCredentials({ uid: "", token: "" });
      setPasswordResetOpen(false);
      setLoginStatus("Votre mot de passe a été modifié. Vous pouvez maintenant vous connecter.");
      window.history.replaceState({}, document.title, window.location.pathname);
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setPasswordResetStatus(firstError || "Ce lien est invalide ou a expiré.");
    } finally {
      setPasswordResetPending(false);
    }
  };

  const requestCancellation = async (bookingId) => {
    const reason = (cancellationReasons[bookingId] || "").trim();
    if (reason.length < 5) {
      setCancellationStatus("Expliquez le motif de votre demande en au moins 5 caractères.");
      return;
    }
    setCancellationPendingId(bookingId);
    setCancellationStatus("");
    try {
      const response = await apiClient.post(`/bookings/${bookingId}/request-cancellation/`, { reason });
      setCancellationRequests((current) => [response.data, ...current]);
      setCancellationReasons((current) => ({ ...current, [bookingId]: "" }));
      setCancellationStatus(`Votre demande pour la réservation n°${bookingId} a été transmise à l'administration.`);
    } catch (error) {
      setCancellationStatus(error.response?.data?.detail || "La demande d'annulation n'a pas pu être envoyée.");
    } finally {
      setCancellationPendingId(null);
    }
  };

  const rejectCancellation = async (request) => {
    const message = (adminCancellationMessages[request.id] || "").trim();
    if (message.length < 5) {
      setAdminStatus("Rédigez une réponse au client en au moins 5 caractères.");
      return;
    }
    setAdminCancellationPendingId(request.id);
    setAdminStatus("");
    try {
      await apiClient.post(`/bookings/${request.booking}/reject-cancellation/`, { message });
      setAdminCancellationRequests((current) => current.filter((item) => item.id !== request.id));
      setAdminStatus(`La demande d'annulation n°${request.id} a été refusée et la réponse est disponible pour le client.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "La demande d'annulation n'a pas pu être traitée.");
    } finally {
      setAdminCancellationPendingId(null);
    }
  };

  const refundCancellationPayment = async (payment, request) => {
    setRefundPendingId(payment.id);
    setAdminStatus("");
    try {
      const response = await apiClient.post(`/payments/${payment.id}/refund/`, {
        reason: "requested_by_customer",
        internal_reason: `Demande d'annulation n°${request.id} : ${request.reason}`.slice(0, 255),
      });
      await loadAdminDashboard();
      setAdminStatus(response.data.status === "succeeded" ? `Le paiement n°${payment.id} a été remboursé par Stripe.` : `Le remboursement Stripe n°${response.data.id} est en cours de traitement.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "Le remboursement Stripe n'a pas pu être effectué.");
    } finally {
      setRefundPendingId(null);
    }
  };

  const approveCancellation = async (request) => {
    setAdminCancellationPendingId(request.id);
    setAdminStatus("");
    try {
      await apiClient.post(`/bookings/${request.booking}/cancel/`, {
        reason: `Demande client acceptée : ${request.reason}`.slice(0, 255),
      });
      setAdminCancellationRequests((current) => current.filter((item) => item.id !== request.id));
      setAdminPayments((current) => current.filter((payment) => payment.booking !== request.booking));
      setAdminStatus(`La réservation n°${request.booking} a été annulée et le créneau du DJ a été libéré.`);
    } catch (error) {
      setAdminStatus(error.response?.data?.detail || "L'annulation n'a pas pu être confirmée.");
    } finally {
      setAdminCancellationPendingId(null);
    }
  };

  const completeDjBooking = async (bookingId) => {
    setDjPendingId(bookingId);
    setDjStatus("");
    try {
      const response = await apiClient.post(`/bookings/${bookingId}/complete/`);
      setDjBookings((current) => current.map((item) => item.id === bookingId ? response.data.booking : item));
      setDjStatus(`Prestation n°${bookingId} clôturée. La facture de solde ${response.data.balance_invoice.invoice_number} est disponible pour le client.`);
    } catch (error) {
      setDjStatus(error.response?.data?.detail || "La prestation n’a pas pu être clôturée.");
    } finally {
      setDjPendingId(null);
    }
  };

  const updateDjAppointment = async (appointmentId, status) => {
    setDjAppointmentPendingId(appointmentId);
    setDjStatus("");
    try {
      const response = await apiClient.patch(`/appointments/${appointmentId}/`, { status });
      setDjAppointments((current) => current.map((item) => item.id === appointmentId ? response.data : item));
      setDjStatus(`Rendez-vous n°${appointmentId} ${status === "done" ? "marqué comme réalisé" : "annulé"}.`);
    } catch (error) {
      setDjStatus(error.response?.data?.detail || "Le rendez-vous n’a pas pu être mis à jour.");
    } finally {
      setDjAppointmentPendingId(null);
    }
  };

  const updateDjSong = async (songId, status) => {
    setDjSongPendingId(songId);
    setDjStatus("");
    try {
      const response = await apiClient.patch(`/playlist-songs/${songId}/`, { status });
      setDjSongs((current) => current.map((item) => item.id === songId ? response.data : item));
      setDjStatus(`La demande « ${response.data.title} » a été ${status === "approved" ? "acceptée" : "refusée"}.`);
    } catch (error) {
      setDjStatus(error.response?.data?.detail || "La chanson n’a pas pu être mise à jour.");
    } finally {
      setDjSongPendingId(null);
    }
  };

  const createDjAvailability = async (event) => {
    event.preventDefault();
    setAvailabilityPendingId("create");
    setDjStatus("");
    try {
      const response = await apiClient.post("/availability/", {
        available_date: availabilityDate,
        start_time: availabilityStart,
        end_time: availabilityEnd,
        status: availabilityStatus,
        reason: availabilityStatus === "blocked" ? availabilityReason.trim() : "",
      });
      setDjAvailabilities((current) => [...current, response.data].sort((a, b) => `${a.available_date}${a.start_time}`.localeCompare(`${b.available_date}${b.start_time}`)));
      setAvailabilityReason("");
      setDjStatus("Le nouveau créneau a été enregistré.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setDjStatus(firstError || "Le créneau n’a pas pu être enregistré.");
    } finally {
      setAvailabilityPendingId(null);
    }
  };

  const updateDjAvailability = async (availability, status) => {
    setAvailabilityPendingId(availability.id);
    setDjStatus("");
    try {
      const response = await apiClient.patch(`/availability/${availability.id}/`, {
        status,
        reason: status === "blocked" ? "Indisponibilité déclarée par le DJ" : "",
      });
      setDjAvailabilities((current) => current.map((item) => item.id === availability.id ? response.data : item));
      setDjStatus(`Le créneau du ${new Date(`${availability.available_date}T00:00:00`).toLocaleDateString("fr-BE")} est maintenant ${status === "available" ? "disponible" : "bloqué"}.`);
    } catch (error) {
      setDjStatus(error.response?.data?.detail || "Le créneau n’a pas pu être modifié.");
    } finally {
      setAvailabilityPendingId(null);
    }
  };

  const deleteDjAvailability = async (availability) => {
    setAvailabilityPendingId(availability.id);
    setDjStatus("");
    try {
      await apiClient.delete(`/availability/${availability.id}/`);
      setDjAvailabilities((current) => current.filter((item) => item.id !== availability.id));
      setDjStatus("Le créneau a été supprimé.");
    } catch (error) {
      setDjStatus(error.response?.data?.detail || "Le créneau n’a pas pu être supprimé.");
    } finally {
      setAvailabilityPendingId(null);
    }
  };

  const signClientContract = async (contractId) => {
    setContractPendingId(contractId);
    setContractStatus("");
    try {
      const response = await apiClient.post(`/contracts/${contractId}/sign/`);
      setContracts((current) => current.map((item) => item.id === contractId ? response.data : item));
      setContractStatus(`Le contrat ${response.data.contract_number} est signé et horodaté.`);
    } catch (error) {
      setContractStatus(error.response?.data?.detail || "Le contrat n’a pas pu être signé.");
    } finally {
      setContractPendingId(null);
    }
  };

  const downloadDocument = async (resource, id, filename) => {
    const downloadKey = `${resource}-${id}`;
    setDownloadPending(downloadKey);
    try {
      const response = await apiClient.get(`/${resource}/${id}/pdf/`, { responseType: "blob" });
      const url = URL.createObjectURL(new Blob([response.data], { type: "application/pdf" }));
      const link = document.createElement("a");
      link.href = url;
      link.download = `${filename}.pdf`;
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(url);
    } catch {
      if (resource === "contracts") setContractStatus("Le contrat PDF n’a pas pu être téléchargé.");
      else setCheckoutStatus("La facture PDF n’a pas pu être téléchargée.");
    } finally {
      setDownloadPending("");
    }
  };

  const createClientPlaylist = async (event) => {
    event.preventDefault();
    if (!playlistBookingId || !playlistStyleId) {
      setPlaylistStatus("Sélectionnez une réservation confirmée et un style musical.");
      return;
    }
    setPlaylistPending(true);
    setPlaylistStatus("");
    try {
      const response = await apiClient.post("/playlists/", {
        booking: Number(playlistBookingId),
        main_style: Number(playlistStyleId),
        notes: playlistNotes.trim(),
      });
      setPlaylists((current) => [...current, response.data]);
      setSongPlaylistId(String(response.data.id));
      setPlaylistBookingId("");
      setPlaylistNotes("");
      setPlaylistStatus("Playlist créée. Vous pouvez maintenant ajouter vos chansons.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setPlaylistStatus(firstError || "La playlist n’a pas pu être créée.");
    } finally {
      setPlaylistPending(false);
    }
  };

  const addPlaylistSong = async (event) => {
    event.preventDefault();
    if (!songPlaylistId || !songTitle.trim() || !songArtist.trim()) return;
    setPlaylistPending(true);
    setPlaylistStatus("");
    try {
      const response = await apiClient.post("/playlist-songs/", {
        playlist: Number(songPlaylistId),
        title: songTitle.trim(),
        artist: songArtist.trim(),
        preference_level: songPreference,
      });
      setPlaylistSongs((current) => [...current, response.data]);
      setSongTitle("");
      setSongArtist("");
      setPlaylistStatus("Chanson ajoutée et transmise au DJ.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setPlaylistStatus(firstError || "La chanson n’a pas pu être ajoutée.");
    } finally {
      setPlaylistPending(false);
    }
  };

  const createPreparatoryAppointment = async (event) => {
    event.preventDefault();
    if (!appointmentBookingId || !appointmentDateTime) {
      setAppointmentStatus("Sélectionnez une réservation et une date de rendez-vous.");
      return;
    }
    setAppointmentPending(true);
    setAppointmentStatus("");
    try {
      const response = await apiClient.post("/appointments/", {
        booking: Number(appointmentBookingId),
        scheduled_at: new Date(appointmentDateTime).toISOString(),
        mode: appointmentMode,
        notes: appointmentNotes.trim(),
      });
      setAppointments((current) => [...current, response.data]);
      setAppointmentBookingId("");
      setAppointmentDateTime("");
      setAppointmentNotes("");
      setAppointmentStatus("Rendez-vous préparatoire planifié et transmis au DJ.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setAppointmentStatus(firstError || "Le rendez-vous n’a pas pu être planifié.");
    } finally {
      setAppointmentPending(false);
    }
  };

  const createClientReview = async (event) => {
    event.preventDefault();
    if (!reviewBookingId || !reviewComment.trim()) {
      setReviewStatus("Sélectionnez une réservation et rédigez votre commentaire.");
      return;
    }
    setReviewPending(true);
    setReviewStatus("");
    try {
      const response = await apiClient.post("/reviews/", {
        booking: Number(reviewBookingId),
        rating: Number(reviewRating),
        comment: reviewComment.trim(),
      });
      setReviews((current) => [response.data, ...current]);
      setReviewBookingId("");
      setReviewRating(5);
      setReviewComment("");
      setReviewStatus("Merci ! Votre avis est enregistré et attend sa modération.");
    } catch (error) {
      const details = error.response?.data;
      const firstError = details && Object.values(details).flat()[0];
      setReviewStatus(firstError || "Votre avis n’a pas pu être enregistré.");
    } finally {
      setReviewPending(false);
    }
  };

  const startInvoiceCheckout = async (invoice) => {
    setCheckoutPendingId(invoice.id);
    setCheckoutStatus("");
    try {
      const response = await apiClient.post(`/invoices/${invoice.id}/checkout/`);
      const checkoutUrl = new URL(response.data.checkout_url);
      if (checkoutUrl.protocol !== "https:" || checkoutUrl.hostname !== "checkout.stripe.com") {
        throw new Error("URL Stripe inattendue");
      }
      window.location.assign(checkoutUrl.toString());
    } catch (error) {
      if (error.response?.status === 401) {
        clearAuthentication();
        setIsAuthenticated(false);
        setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
      } else {
        setCheckoutStatus(error.response?.data?.detail || "Le paiement ne peut pas être démarré pour le moment.");
      }
      setCheckoutPendingId(null);
    }
  };

  return (
    <div className="site-shell">
      <SiteHeader
        currentUser={currentUser}
        language={language}
        mobileNavOpen={mobileNavOpen}
        onLanguageChange={setLanguage}
        onNavigate={navigate}
        onToggleMenu={() => setMobileNavOpen((open) => !open)}
        page={page}
      />

      <main id="main-content" tabIndex="-1">
        {page === "accueil" && (
          <HomePage
            availableEventTypes={availableEventTypes}
            catalogueStatus={catalogueStatus}
            eventDate={eventDate}
            eventType={eventType}
            location={location}
            onEventDateChange={setEventDate}
            onEventTypeChange={setEventType}
            onLocationChange={setLocation}
            onNavigate={navigate}
            onOpenDetail={openDetail}
            packages={compatiblePackages}
          />
        )}

        {page === "offres" && (
          <section className="section-wrap catalogue-page">
            <div className="page-heading"><p className="eyebrow dark">Offres & DJs</p><h1>Trouvez la prestation qui vous ressemble</h1><p>{eventType} · {eventDate.split("-").reverse().join("/")} · {location}</p></div>
            <div className="catalogue-layout">
              <aside className="filters"><div className="filter-heading"><h2>Filtres</h2><button onClick={() => { setEventType("Mariage"); setLocation("Bruxelles"); }}>Réinitialiser</button></div>
                <label>Type d’événement<select value={eventType} onChange={(event) => setEventType(event.target.value)}>{availableEventTypes.map((type) => <option key={type}>{type}</option>)}</select></label>
                <label>Date<input type="date" value={eventDate} onChange={(event) => setEventDate(event.target.value)} /></label>
                <label>Lieu<input value={location} onChange={(event) => setLocation(event.target.value)} /></label>
                <label>Budget<select defaultValue="1500"><option value="700">Moins de 700 €</option><option value="1500">700 € – 1 500 €</option><option value="more">Plus de 1 500 €</option></select></label>
                <fieldset><legend>Services</legend><label className="check-row"><input type="checkbox" defaultChecked /> Sonorisation</label><label className="check-row"><input type="checkbox" defaultChecked /> Éclairage</label><label className="check-row"><input type="checkbox" /> Animation micro</label></fieldset>
              </aside>
              <div className="results"><div className="results-heading"><div><h2>DJs disponibles à {location}</h2><p>{availableDjs.length} résultat{availableDjs.length > 1 ? "s" : ""} · {publicAvailabilityStatus}</p></div><span className="status-pill"><span /> {catalogueStatus}</span></div>
                {compatiblePackages.length > 0 && availableDjs.map((dj, index) => { const item = compatiblePackages[index % compatiblePackages.length]; return <article className="dj-card" key={dj.id}><div className={`dj-avatar avatar-${index + 1}`}><Headphones /></div><div className="dj-copy"><div className="dj-title"><h3>{dj.name}</h3><span><Star /> {dj.rating ? `${dj.rating} (${dj.reviews} avis)` : "Profil vérifié"}</span></div><p>{dj.styles}</p><p className="availability"><Clock3 /> Disponible {dj.slot}</p><strong>À partir de {formatEuro(item.base_price)}</strong></div><button className="primary-button" type="button" onClick={() => openDetail(item, dj)}>Voir le détail <ChevronRight /></button></article>; })}
                {(!availableDjs.length || !compatiblePackages.length) && <p className="invoice-empty">{!compatiblePackages.length ? "Aucune formule compatible avec cette prestation." : "Modifiez la date pour rechercher un autre créneau."}</p>}
              </div>
            </div>
          </section>
        )}

        {page === "detail" && selectedPackage && (
          <>
            <section className="detail-hero"><div className="breadcrumb"><button onClick={() => navigate("accueil")}>Accueil</button><span>/</span><button onClick={() => navigate("offres")}>Offres & DJs</button><span>/</span><span>{selectedPackage.name}</span></div><div className="detail-heading"><div><p className="eyebrow">{selectedPackage.event || "Prestation événementielle"}</p><h1>{selectedPackage.name}</h1><p>{selectedPackage.description}</p><div className="detail-badges"><span>{selectedDj.rating ? <><Star /> {selectedDj.rating} · {selectedDj.reviews} avis vérifiés</> : <><ShieldCheck /> Profil DJ vérifié</>}</span><span><Clock3 /> {Number(selectedPackage.included_hours)} heures incluses</span></div></div><div className="dj-signature"><div className="dj-avatar"><Headphones /></div><div><small>Votre DJ</small><strong>{selectedDj.name}</strong><span>{selectedDj.styles}</span></div></div></div></section>
            <section className="detail-layout section-wrap"><div className="detail-content"><article><h2>Ce qui est inclus</h2><ul className="feature-list"><li><Check /> Préparation musicale personnalisée</li><li><Check /> Sonorisation professionnelle</li><li><Check /> Éclairage adapté à la salle</li><li><Check /> Coordination avec le lieu de réception</li></ul></article><article><h2>Options & matériel</h2><p>Ajoutez une animation micro, un éclairage architectural ou du matériel supplémentaire. Chaque option apparaît clairement dans le devis.</p></article><article><h2>Playlist et styles</h2><p>Indiquez vos styles favoris, les chansons incontournables et celles à éviter. La playlist reste modifiable pendant la préparation.</p></article><article><h2>Conditions d’acompte</h2><p>Un acompte indicatif de 30 % confirme la réservation. Le créneau est bloqué uniquement après validation du contrat et paiement accepté.</p></article></div><aside className="booking-card"><p className="eyebrow dark">Réserver ce package</p><h2>À partir de {formatEuro(selectedPackage.base_price)}</h2><label>Date<input type="date" value={eventDate} onChange={(event) => setEventDate(event.target.value)} /></label><label>Créneau<select defaultValue={selectedDj.slot}><option>{selectedDj.slot}</option><option>À confirmer avec le DJ</option></select></label><label>Lieu<input value={location} onChange={(event) => setLocation(event.target.value)} /></label><button className="primary-button" onClick={startQuote}>Demander un devis <ChevronRight /></button><p className="secure-note"><ShieldCheck /> Aucun paiement à cette étape</p></aside></section>
          </>
        )}

        {page === "devis" && (
          <section className="section-wrap quote-page"><div className="page-heading"><p className="eyebrow dark">Demande de devis</p><h1>Parlez-nous de votre événement</h1><p>Les informations obligatoires suivent le scénario de demande validé dans les diagrammes.</p></div>
            {!quoteSubmitted ? <div className="quote-layout"><form className="quote-form" onSubmit={submitQuote}><fieldset><legend><span>1</span> Votre événement</legend><div className="form-grid"><label>Type d’événement<select value={eventType} onChange={(event) => setEventType(event.target.value)} required>{availableEventTypes.map((type) => <option key={type}>{type}</option>)}</select></label><label>Date<input type="date" value={eventDate} min={todayIso} onChange={(event) => setEventDate(event.target.value)} required /></label><label>Heure de début<input type="time" value={startTime} onChange={(event) => setStartTime(event.target.value)} required /></label><label className="full-field">Lieu enregistré<select value={selectedVenueId} onChange={(event) => selectVenue(event.target.value)}><option value="new">Créer un nouveau lieu</option>{venues.map((venue) => <option value={venue.id} key={venue.id}>{venue.name} — {venue.city}</option>)}</select></label>{selectedVenueId === "new" && <><label>Nom du lieu<input value={venueName} onChange={(event) => setVenueName(event.target.value)} required /></label><label>Rue et numéro<input value={venueStreet} onChange={(event) => setVenueStreet(event.target.value)} required /></label><label>Code postal<input value={venuePostalCode} onChange={(event) => setVenuePostalCode(event.target.value)} required /></label><label>Ville<input value={location} onChange={(event) => setLocation(event.target.value)} required /></label><label>Pays<input value={venueCountry} onChange={(event) => setVenueCountry(event.target.value)} required /></label><div className="venue-actions"><button className="secondary-button" type="button" onClick={createVenue} disabled={venuePending}>{venuePending ? "Enregistrement…" : "Enregistrer ce lieu"}</button></div></>}{venueStatus && <p className={`venue-message full-field ${venueStatus.startsWith("Lieu enregistré") ? "success" : ""}`} role="status">{venueStatus}</p>}<label>Nombre d’invités<input type="number" min="1" value={guestCount} onChange={(event) => setGuestCount(event.target.value)} required /></label><label>Durée prévue (heures)<input type="number" min="1" step="0.5" value={durationHours} onChange={(event) => setDurationHours(event.target.value)} required /></label><label>Parking disponible ?<select value={parking} onChange={(event) => setParking(event.target.value)}><option value="oui">Oui</option><option value="non">Non</option><option value="inconnu">À vérifier</option></select></label></div></fieldset><fieldset><legend><span>2</span> Offre et préférences</legend><div className="form-grid"><label>Formule<select value={selectedPackageId} onChange={(event) => setSelectedPackageId(event.target.value)}>{compatiblePackages.map((item) => <option value={item.id} key={item.id}>{item.name}</option>)}</select></label><label>Distance estimée (km)<input type="number" min="0" value={distanceKm} onChange={(event) => setDistanceKm(event.target.value)} /></label><label className="full-field">Préférences musicales<textarea rows="4" value={musicPreferences} onChange={(event) => setMusicPreferences(event.target.value)} placeholder="Styles, chansons souhaitées ou à éviter…" /></label></div></fieldset>{quoteStatus && <p className="form-message" role="alert">{quoteStatus}</p>}<button className="primary-button submit-quote" type="submit" disabled={quotePending}>{quotePending ? "Enregistrement…" : "Soumettre la demande"} <ChevronRight /></button></form><aside className="quote-summary"><p className="eyebrow dark">Estimation</p><h2>{selectedPackage?.name}</h2><dl><div><dt>Prestation</dt><dd>{formatEuro(quote.subtotal)}</dd></div><div><dt>Déplacement estimé</dt><dd>{formatEuro(quote.travel)}</dd></div><div className="quote-total"><dt>Total indicatif</dt><dd>{formatEuro(quote.total)}</dd></div><div><dt>Acompte proposé (30 %)</dt><dd>{formatEuro(quote.deposit)}</dd></div></dl><p><ShieldCheck /> Cette estimation sera vérifiée par l’administrateur/DJ avant l’envoi du devis.</p></aside></div> : <div className="confirmation-card"><div className="confirmation-icon"><Check /></div><p className="eyebrow dark">Demande enregistrée</p><h2>Votre devis n°{createdQuote?.id} a bien été créé.</h2><p>Statut : <strong>Brouillon — vérification administrative en attente</strong>. Les montants ci-dessous ont été calculés et enregistrés par Django.</p><div className="confirmation-details"><span><CalendarDays /> {eventDate.split("-").reverse().join("/")}</span><span><MapPin /> {location}</span><span><UsersRound /> {guestCount} invités</span><span><FileText /> {formatEuro(createdQuote?.total_amount)}</span></div><button className="secondary-button" onClick={() => navigate("compte")}>Voir mon espace client</button></div>}
          </section>
        )}

        {page === "administration" && currentUser?.is_staff && (
          <section className="section-wrap admin-page">
            <div className="page-heading"><p className="eyebrow dark">Espace administrateur</p><h1>Traiter les demandes de devis</h1><p>Envoyez le devis au client, choisissez un DJ réellement disponible, puis créez automatiquement la réservation, le contrat et la facture d’acompte.</p></div>
            <div className="admin-toolbar"><div><strong>{adminQuotes.length}</strong><span> devis à traiter</span></div><button className="secondary-button" type="button" onClick={loadAdminDashboard}>Actualiser</button></div>
            {adminStatus && <p className={adminStatus.includes("créés") || adminStatus.includes("prêt") || adminStatus.includes("clôturée") || adminStatus.includes("refusée") || adminStatus.includes("remboursé") || adminStatus.includes("annulée") ? "form-message success" : "form-message"} role="status">{adminStatus}</p>}
            <div className="admin-quote-grid">
              {adminQuotes.map((item) => {
                const itemPackage = packages.find((entry) => String(entry.id) === String(item.package));
                const itemEventType = eventTypeRecords.find((entry) => String(entry.id) === String(item.event_type));
                return (
                  <article className="admin-quote-card" key={item.id}>
                    <div className="quote-row-heading"><h2>Devis n°{item.id}</h2><span className={`quote-status ${item.status}`}>{quoteStatusLabels[item.status]}</span></div>
                    <p><CalendarDays /> {itemEventType?.name || "Événement"} · {new Date(`${item.event_date}T00:00:00`).toLocaleDateString("fr-BE")} à {String(item.start_time).slice(0, 5)}</p>
                    <p><Clock3 /> {item.duration_hours} heures · {item.guest_count} invités</p>
                    <p><FileText /> {itemPackage?.name || `Formule n°${item.package}`} · <strong>{formatEuro(item.total_amount)}</strong></p>
                    {item.status === "draft" ? (
                      <button className="primary-button" type="button" onClick={() => sendQuote(item.id)} disabled={adminPendingId === item.id}>{adminPendingId === item.id ? "Traitement…" : "Envoyer le devis"}</button>
                    ) : (
                      <div className="admin-acceptance">
                        <label>DJ à affecter<select value={adminDjSelection[item.id] || ""} onChange={(event) => setAdminDjSelection((current) => ({ ...current, [item.id]: event.target.value }))}><option value="">Sélectionner un DJ</option>{adminDjs.map((dj) => <option value={dj.id} key={dj.id}>{dj.stage_name}</option>)}</select></label>
                        <button className="primary-button" type="button" onClick={() => acceptAdminQuote(item.id)} disabled={adminPendingId === item.id}>{adminPendingId === item.id ? "Création…" : "Accepter et créer le dossier"}</button>
                      </div>
                    )}
                  </article>
                );
              })}
              {!adminStatus && !adminQuotes.length && <p className="invoice-empty">Aucun devis en attente de traitement.</p>}
            </div>
            <div className="admin-booking-panel cancellation-panel">
              <div className="playlist-heading"><div><h2>Demandes d'annulation</h2><p>Consultez le motif du client et répondez avant toute opération de remboursement ou d'annulation.</p></div><FileText /></div>
              <div className="admin-quote-grid">
                {adminCancellationRequests.map((request) => {
                  const requestPayments = adminPayments.filter((payment) => payment.booking === request.booking);
                  const blockingPayments = requestPayments.filter((payment) => ["paid", "pending"].includes(payment.status));
                  return (
                    <article className="admin-quote-card" key={request.id}>
                      <div className="quote-row-heading"><h2>Réservation n°{request.booking}</h2><span className="quote-status sent">En attente</span></div>
                      <p>{request.reason}</p>
                      <small>Demandée le {new Date(request.requested_at).toLocaleString("fr-BE")}</small>
                      <div className="cancellation-payments">
                        <strong>Paiements liés</strong>
                        {requestPayments.map((payment) => <div key={payment.id}><span>Paiement n°{payment.id} · {formatEuro(payment.amount)}<small>Remboursé : {formatEuro(payment.refunded_amount)} · Restant : {formatEuro(payment.refundable_amount)}</small></span><span className={`invoice-status ${payment.refund_status === "pending" ? "pending" : payment.status}`}>{payment.refund_status === "pending" ? "Remboursement en cours" : payment.refund_status === "partial" ? "Partiellement remboursé" : payment.refund_status === "failed" ? "Remboursement échoué" : payment.status === "paid" ? "Payé" : payment.status === "refunded" ? "Remboursé" : payment.status === "pending" ? "En attente" : "Échoué"}</span>{payment.status === "paid" && payment.refund_status !== "pending" && Number(payment.refundable_amount) > 0 && <button className="document-button" type="button" onClick={() => refundCancellationPayment(payment, request)} disabled={refundPendingId === payment.id}>{refundPendingId === payment.id ? "Remboursement…" : `Rembourser ${formatEuro(payment.refundable_amount)}`}</button>}</div>)}
                        {!requestPayments.length && <small>Aucun paiement encaissé pour cette réservation.</small>}
                      </div>
                      <div className="cancellation-admin-actions"><button className="primary-button" type="button" onClick={() => approveCancellation(request)} disabled={adminCancellationPendingId === request.id || blockingPayments.length > 0}>{adminCancellationPendingId === request.id ? "Annulation…" : blockingPayments.length ? "Remboursement requis" : "Accepter et annuler"}</button></div>
                      <label className="cancellation-message">Réponse en cas de refus<textarea rows="3" maxLength="255" value={adminCancellationMessages[request.id] || ""} onChange={(event) => setAdminCancellationMessages((current) => ({ ...current, [request.id]: event.target.value }))} placeholder="Expliquez clairement le refus…" /></label>
                      <button className="document-button danger-button" type="button" onClick={() => rejectCancellation(request)} disabled={adminCancellationPendingId === request.id}>{adminCancellationPendingId === request.id ? "Traitement…" : "Refuser la demande"}</button>
                    </article>
                  );
                })}
                {!adminCancellationRequests.length && <p className="invoice-empty">Aucune demande d'annulation en attente.</p>}
              </div>
            </div>
            <div className="admin-booking-panel account-deletion-panel">
              <div className="playlist-heading"><div><h2>Suppressions de compte</h2><p>Vérifiez les obligations de conservation avant de désactiver un compte et de révoquer ses sessions.</p></div><CircleUserRound /></div>
              <div className="admin-quote-grid">
                {adminDeletionRequests.map((request) => <article className="admin-quote-card" key={request.id}><div className="quote-row-heading"><h2>{request.client_name}</h2><span className="quote-status sent">En attente</span></div><p>{request.client_email}</p><p>{request.reason}</p><small>Demandée le {new Date(request.requested_at).toLocaleString("fr-BE")}</small><label className="cancellation-message">Réponse au client<textarea rows="3" value={adminDeletionMessages[request.id] || ""} onChange={(event) => setAdminDeletionMessages((current) => ({ ...current, [request.id]: event.target.value }))} placeholder="Décision motivée…" required /></label><div className="cancellation-admin-actions"><button className="primary-button" type="button" onClick={() => reviewAccountDeletion(request, "approved")} disabled={adminDeletionPendingId === request.id}>{adminDeletionPendingId === request.id ? "Traitement…" : "Approuver et désactiver"}</button><button className="document-button danger-button" type="button" onClick={() => reviewAccountDeletion(request, "rejected")} disabled={adminDeletionPendingId === request.id}>Refuser</button></div></article>)}
                {!adminDeletionRequests.length && <p className="invoice-empty">Aucune demande de suppression en attente.</p>}
              </div>
            </div>
            <div className="admin-booking-panel">
              <div className="playlist-heading"><div><h2>Clôturer les prestations</h2><p>Une clôture confirme la prestation réalisée et émet automatiquement la facture de solde.</p></div><Check /></div>
              <div className="admin-quote-grid">
                {adminBookings.map((booking) => (
                  <article className="admin-quote-card" key={booking.id}>
                    <div className="quote-row-heading"><h2>Réservation n°{booking.id}</h2><span className="quote-status accepted">Confirmée</span></div>
                    <p><CalendarDays /> {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString("fr-BE")} · {String(booking.start_time).slice(0, 5)}</p>
                    <p><FileText /> Montant total : <strong>{formatEuro(booking.total_amount)}</strong></p>
                    <button className="primary-button" type="button" onClick={() => completeAdminBooking(booking.id)} disabled={completionPendingId === booking.id}>{completionPendingId === booking.id ? "Clôture…" : "Marquer comme réalisée"}</button>
                  </article>
                ))}
                {!adminBookings.length && <p className="invoice-empty">Aucune prestation confirmée à clôturer.</p>}
              </div>
            </div>
          </section>
        )}

        {page === "dj" && currentUser?.role === "dj" && (
          <section className="section-wrap admin-page">
            <div className="page-heading"><p className="eyebrow dark">Espace DJ</p><h1>Mes prestations</h1><p>Consultez les événements qui vous sont affectés et clôturez une prestation lorsque celle-ci est terminée.</p></div>
            <div className="admin-toolbar"><div><strong>{djBookings.length}</strong><span> prestations affectées</span></div></div>
            {djStatus && <p className={djStatus.includes("clôturée") || djStatus.includes("marqué") || djStatus.includes("annulé") || djStatus.includes("acceptée") || djStatus.includes("refusée") || djStatus.includes("enregistré") || djStatus.includes("maintenant") || djStatus.includes("supprimé") ? "form-message success" : "form-message"} role="status">{djStatus}</p>}
            <div className="admin-quote-grid">
              {djBookings.map((booking) => {
                const canComplete = booking.status === "confirmed" && booking.deposit_paid && hasBookingEnded(booking);
                const statusLabel = booking.status === "confirmed" ? "Confirmée" : booking.status === "performed" ? "Réalisée" : booking.status === "paid" ? "Payée" : booking.status;
                return (
                  <article className="admin-quote-card" key={booking.id}>
                    <div className="quote-row-heading"><h2>Réservation n°{booking.id}</h2><span className={`quote-status ${booking.status === "paid" || booking.status === "performed" ? "accepted" : "sent"}`}>{statusLabel}</span></div>
                    <p><CalendarDays /> {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString("fr-BE")} · {String(booking.start_time).slice(0, 5)}–{String(booking.end_time).slice(0, 5)}</p>
                    <p><FileText /> Montant : <strong>{formatEuro(booking.total_amount)}</strong></p>
                    <p><ShieldCheck /> Acompte {booking.deposit_paid ? "payé" : "en attente"}</p>
                    {canComplete && <button className="primary-button" type="button" onClick={() => completeDjBooking(booking.id)} disabled={djPendingId === booking.id}>{djPendingId === booking.id ? "Clôture…" : "Marquer comme réalisée"}</button>}
                  </article>
                );
              })}
              {!djStatus && !djBookings.length && <p className="invoice-empty">Aucune prestation ne vous est affectée.</p>}
            </div>
            <div className="dj-workflow-grid">
              <section className="dj-action-panel">
                <div className="playlist-heading"><div><h2>Rendez-vous préparatoires</h2><p>Confirmez le suivi effectué avec vos clients.</p></div><CalendarDays /></div>
                <div className="appointment-list">
                  {djAppointments.map((appointment) => {
                    const appointmentDate = new Date(appointment.scheduled_at);
                    return (
                      <article key={appointment.id}>
                        <div><strong>{appointmentDate.toLocaleString("fr-BE")}</strong><span>Réservation n°{appointment.booking} · {appointment.mode === "online" ? "En ligne" : "En présentiel"}</span>{appointment.notes && <small>{appointment.notes}</small>}</div>
                        <div className="dj-action-buttons">
                          <span className={`appointment-status ${appointment.status}`}>{appointment.status === "done" ? "Réalisé" : appointment.status === "cancelled" ? "Annulé" : "Planifié"}</span>
                          {appointment.status === "planned" && appointmentDate <= new Date() && <button className="document-button" type="button" onClick={() => updateDjAppointment(appointment.id, "done")} disabled={djAppointmentPendingId === appointment.id}>Marquer réalisé</button>}
                          {appointment.status === "planned" && <button className="document-button danger-button" type="button" onClick={() => updateDjAppointment(appointment.id, "cancelled")} disabled={djAppointmentPendingId === appointment.id}>Annuler</button>}
                        </div>
                      </article>
                    );
                  })}
                  {!djAppointments.length && <p className="invoice-empty">Aucun rendez-vous préparatoire.</p>}
                </div>
              </section>
              <section className="dj-action-panel">
                <div className="playlist-heading"><div><h2>Demandes musicales</h2><p>Acceptez ou refusez les propositions des clients.</p></div><Music2 /></div>
                <div className="playlist-songs">
                  {djSongs.map((song) => (
                    <article key={song.id}>
                      <div><strong>{song.title}</strong><span>{song.artist} · Playlist n°{song.playlist}</span></div>
                      <div className="dj-action-buttons"><small className={`song-status ${song.status}`}>{song.status === "approved" ? "Acceptée" : song.status === "rejected" ? "Refusée" : "Demandée"}</small>{song.status === "requested" && <><button className="document-button" type="button" onClick={() => updateDjSong(song.id, "approved")} disabled={djSongPendingId === song.id}>Accepter</button><button className="document-button danger-button" type="button" onClick={() => updateDjSong(song.id, "rejected")} disabled={djSongPendingId === song.id}>Refuser</button></>}</div>
                    </article>
                  ))}
                  {!djSongs.length && <p className="invoice-empty">Aucune demande musicale.</p>}
                </div>
              </section>
            </div>
            <section className="availability-panel">
              <div className="playlist-heading"><div><h2>Mes disponibilités</h2><p>Ouvrez les créneaux pendant lesquels l’administration peut vous affecter une prestation.</p></div><Clock3 /></div>
              <form className="availability-form" onSubmit={createDjAvailability}>
                <label>Date<input type="date" min={todayIso} value={availabilityDate} onChange={(event) => setAvailabilityDate(event.target.value)} required /></label>
                <label>Début<input type="time" value={availabilityStart} onChange={(event) => setAvailabilityStart(event.target.value)} required /></label>
                <label>Fin<input type="time" value={availabilityEnd} onChange={(event) => setAvailabilityEnd(event.target.value)} required /></label>
                <label>État<select value={availabilityStatus} onChange={(event) => setAvailabilityStatus(event.target.value)}><option value="available">Disponible</option><option value="blocked">Bloqué</option></select></label>
                {availabilityStatus === "blocked" && <label className="availability-reason">Motif<input value={availabilityReason} onChange={(event) => setAvailabilityReason(event.target.value)} placeholder="Indisponibilité personnelle" required /></label>}
                <button className="primary-button" type="submit" disabled={availabilityPendingId === "create"}>{availabilityPendingId === "create" ? "Enregistrement…" : "Ajouter le créneau"}</button>
              </form>
              <div className="availability-list">
                {djAvailabilities.map((availability) => (
                  <article key={availability.id}>
                    <div><strong>{new Date(`${availability.available_date}T00:00:00`).toLocaleDateString("fr-BE")}</strong><span>{String(availability.start_time).slice(0, 5)}–{String(availability.end_time).slice(0, 5)}</span>{availability.reason && <small>{availability.reason}</small>}</div>
                    <div className="dj-action-buttons"><span className={`availability-status ${availability.status}`}>{availability.status === "available" ? "Disponible" : availability.status === "reserved" ? "Réservé" : "Bloqué"}</span>{availability.status === "available" && <button className="document-button" type="button" onClick={() => updateDjAvailability(availability, "blocked")} disabled={availabilityPendingId === availability.id}>Bloquer</button>}{availability.status === "blocked" && <button className="document-button" type="button" onClick={() => updateDjAvailability(availability, "available")} disabled={availabilityPendingId === availability.id}>Rouvrir</button>}{availability.status !== "reserved" && <button className="document-button danger-button" type="button" onClick={() => deleteDjAvailability(availability)} disabled={availabilityPendingId === availability.id}>Supprimer</button>}</div>
                  </article>
                ))}
                {!djAvailabilities.length && <p className="invoice-empty">Aucun créneau enregistré.</p>}
              </div>
            </section>
          </section>
        )}

        {page === "compte" && (
          <section className="section-wrap account-page">
            <div className="page-heading"><p className="eyebrow dark">Espace client</p><h1>Retrouvez votre événement au même endroit</h1><p>Connectez-vous pour suivre vos devis, contrats, paiements et playlists.</p></div>
            {paymentReturnStatus && <p className="payment-return-message" role="status"><ShieldCheck /> {paymentReturnStatus}</p>}
            <div className="account-grid">
              {!isAuthenticated ? (
                <>
                  <form className="account-card" onSubmit={handleLogin}>
                    <CircleUserRound /><h2>Connexion</h2>
                    <label>Identifiant Django<input value={username} onChange={(event) => setUsername(event.target.value)} autoComplete="username" required /></label>
                    <label>Mot de passe<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="current-password" required /></label>
                    {loginStatus && <p className="form-message" role="status">{loginStatus}</p>}
                    <button className="primary-button" type="submit" disabled={loginPending}>{loginPending ? "Connexion…" : "Se connecter"}</button>
                    <button className="secondary-button" type="button" onClick={() => setRegistrationOpen((open) => !open)}>{registrationOpen ? "Fermer l’inscription" : "Créer un compte client"}</button>
                    <button className="text-button" type="button" onClick={() => setVerificationResendOpen((open) => !open)}>Renvoyer l’e-mail d’activation</button>
                    <button className="text-button" type="button" onClick={() => setPasswordResetOpen((open) => !open)}>Mot de passe oublié ?</button>
                  </form>
                  {registrationOpen && <form className="account-card registration-card" onSubmit={handleRegistration}>
                    <UsersRound /><h2>Créer mon compte</h2>
                    <div className="registration-grid">
                      <label>Prénom<input value={registration.first_name} onChange={(event) => updateRegistration("first_name", event.target.value)} autoComplete="given-name" required /></label>
                      <label>Nom<input value={registration.last_name} onChange={(event) => updateRegistration("last_name", event.target.value)} autoComplete="family-name" required /></label>
                      <label>Identifiant<input value={registration.username} onChange={(event) => updateRegistration("username", event.target.value)} autoComplete="username" required /></label>
                      <label>E-mail<input type="email" value={registration.email} onChange={(event) => updateRegistration("email", event.target.value)} autoComplete="email" required /></label>
                      <label className="full-field">Mot de passe<input type="password" minLength="8" value={registration.password} onChange={(event) => updateRegistration("password", event.target.value)} autoComplete="new-password" required /></label>
                      <label>Date de naissance<input type="date" max={todayIso} value={registration.date_of_birth} onChange={(event) => updateRegistration("date_of_birth", event.target.value)} required /></label>
                      <label>Téléphone<input type="tel" value={registration.phone} onChange={(event) => updateRegistration("phone", event.target.value)} autoComplete="tel" required /></label>
                      <label className="full-field">Adresse de facturation<input value={registration.billing_address} onChange={(event) => updateRegistration("billing_address", event.target.value)} autoComplete="street-address" required /></label>
                      <label>Code postal<input value={registration.billing_postal_code} onChange={(event) => updateRegistration("billing_postal_code", event.target.value)} autoComplete="postal-code" required /></label>
                      <label>Ville<input value={registration.billing_city} onChange={(event) => updateRegistration("billing_city", event.target.value)} autoComplete="address-level2" required /></label>
                      <label>Langue<select value={registration.preferred_language} onChange={(event) => updateRegistration("preferred_language", event.target.value)}><option value="fr">Français</option><option value="en">Anglais</option><option value="nl">Néerlandais</option></select></label>
                    </div>
                    <p className="secure-note"><ShieldCheck /> Le client doit être majeur et le mot de passe respecte les règles Django.</p>
                    {registrationStatus && <p className="form-message" role="alert">{registrationStatus}</p>}
                    <button className="primary-button" type="submit" disabled={registrationPending}>{registrationPending ? "Création…" : "Créer mon compte"}</button>
                  </form>}
                  {passwordResetOpen && <form className="account-card password-reset-card" onSubmit={passwordResetCredentials.token ? handlePasswordResetConfirm : handlePasswordResetRequest}>
                    <ShieldCheck /><h2>{passwordResetCredentials.token ? "Nouveau mot de passe" : "Réinitialiser le mot de passe"}</h2>
                    {passwordResetCredentials.token
                      ? <label>Nouveau mot de passe<input type="password" minLength="8" value={newPassword} onChange={(event) => setNewPassword(event.target.value)} autoComplete="new-password" required /></label>
                      : <label>Adresse e-mail du compte<input type="email" value={passwordResetEmail} onChange={(event) => setPasswordResetEmail(event.target.value)} autoComplete="email" required /></label>}
                    {passwordResetStatus && <p className="form-message" role="status">{passwordResetStatus}</p>}
                    <button className="primary-button" type="submit" disabled={passwordResetPending}>{passwordResetPending ? "Traitement…" : passwordResetCredentials.token ? "Enregistrer le mot de passe" : "Envoyer le lien"}</button>
                  </form>}
                  {verificationResendOpen && <form className="account-card password-reset-card" onSubmit={handleVerificationResend}>
                    <ShieldCheck /><h2>Renvoyer le lien d’activation</h2>
                    <label>Adresse e-mail du compte<input type="email" value={verificationResendEmail} onChange={(event) => setVerificationResendEmail(event.target.value)} autoComplete="email" required /></label>
                    {verificationResendStatus && <p className="form-message" role="status">{verificationResendStatus}</p>}
                    <button className="primary-button" type="submit" disabled={verificationResendPending}>{verificationResendPending ? "Envoi…" : "Renvoyer le lien"}</button>
                  </form>}
                </>
              ) : (
                <div className="account-card connected-card">
                  <div className="confirmation-icon"><Check /></div><h2>Session active</h2>
                  <p>{currentUser?.is_staff ? "Vous êtes connecté avec un compte administrateur." : currentUser?.role === "dj" ? "Vous êtes connecté avec un compte DJ." : "Vous pouvez maintenant suivre vos devis, vos factures et vos paiements sécurisés."}</p>
                  {loginStatus && <p className="form-message success" role="status">{loginStatus}</p>}
                  {currentUser?.is_staff && <button className="primary-button" type="button" onClick={() => navigate("administration")}><Settings /> Ouvrir l’espace administrateur</button>}
                  {currentUser?.role === "dj" && <button className="primary-button" type="button" onClick={() => navigate("dj")}><Headphones /> Ouvrir l’espace DJ</button>}
                  {currentUser?.role === "client" && <>
                  <div className="profile-panel">
                    <div className="playlist-heading"><div><h3>Mes coordonnées</h3><p>{clientProfile ? `${clientProfile.first_name} ${clientProfile.last_name} · ${clientProfile.email} · ${clientProfile.billing_city}` : "Chargement de vos coordonnées…"}</p></div><CircleUserRound /></div>
                    <button className="document-button" type="button" onClick={() => setClientProfileOpen((open) => !open)} disabled={!clientProfile}>{clientProfileOpen ? "Fermer" : "Modifier mes coordonnées"}</button>
                    <button className="document-button" type="button" onClick={() => setPasswordChangeOpen((open) => !open)}>{passwordChangeOpen ? "Fermer le mot de passe" : "Changer mon mot de passe"}</button>
                    {clientProfileStatus && <p className={clientProfileStatus.includes("mises à jour") ? "form-message success" : "form-message"} role="status">{clientProfileStatus}</p>}
                    {clientProfileOpen && clientProfile && <form className="registration-grid profile-form" onSubmit={handleClientProfileUpdate}>
                      <label>Prénom<input value={clientProfile.first_name} onChange={(event) => changeClientProfile("first_name", event.target.value)} required /></label>
                      <label>Nom<input value={clientProfile.last_name} onChange={(event) => changeClientProfile("last_name", event.target.value)} required /></label>
                      <label className="full-field">E-mail vérifié<input type="email" value={clientProfile.email} readOnly /></label>
                      <label>Date de naissance<input type="date" max={todayIso} value={clientProfile.date_of_birth} onChange={(event) => changeClientProfile("date_of_birth", event.target.value)} required /></label>
                      <label>Téléphone<input type="tel" value={clientProfile.phone} onChange={(event) => changeClientProfile("phone", event.target.value)} required /></label>
                      <label className="full-field">Adresse de facturation<input value={clientProfile.billing_address} onChange={(event) => changeClientProfile("billing_address", event.target.value)} required /></label>
                      <label>Code postal<input value={clientProfile.billing_postal_code} onChange={(event) => changeClientProfile("billing_postal_code", event.target.value)} required /></label>
                      <label>Ville<input value={clientProfile.billing_city} onChange={(event) => changeClientProfile("billing_city", event.target.value)} required /></label>
                      <label>Langue<select value={clientProfile.preferred_language} onChange={(event) => changeClientProfile("preferred_language", event.target.value)}><option value="fr">Français</option><option value="en">Anglais</option><option value="nl">Néerlandais</option></select></label>
                      <button className="primary-button" type="submit" disabled={clientProfilePending}>{clientProfilePending ? "Enregistrement…" : "Enregistrer"}</button>
                    </form>}
                    {passwordChangeOpen && <form className="password-change-form" onSubmit={handlePasswordChange}>
                      <label>Mot de passe actuel<input type="password" value={currentPassword} onChange={(event) => setCurrentPassword(event.target.value)} autoComplete="current-password" required /></label>
                      <label>Nouveau mot de passe<input type="password" minLength="8" value={changedPassword} onChange={(event) => setChangedPassword(event.target.value)} autoComplete="new-password" required /></label>
                      {passwordChangeStatus && <p className="form-message" role="alert">{passwordChangeStatus}</p>}
                      <button className="primary-button" type="submit" disabled={passwordChangePending}>{passwordChangePending ? "Modification…" : "Modifier et me déconnecter"}</button>
                    </form>}
                  </div>
                  <div className="account-deletion-panel">
                    <div className="playlist-heading"><div><h3>Suppression du compte</h3><p>La demande est examinée avant toute suppression afin de préserver les documents comptables et contractuels obligatoires.</p></div><X /></div>
                    {accountDeletionRequests.map((request) => <article className="deletion-request-row" key={request.id}><div><strong>Demande n°{request.id}</strong><span>{request.reason}</span>{request.review_message && <small>Réponse : {request.review_message}</small>}</div><div><span className={`deletion-status ${request.status}`}>{request.status === "pending" ? "En attente" : request.status === "cancelled" ? "Annulée" : request.status === "approved" ? "Approuvée" : "Refusée"}</span>{request.status === "pending" && <button className="document-button" type="button" onClick={() => cancelAccountDeletion(request.id)} disabled={accountDeletionPending}>Annuler la demande</button>}</div></article>)}
                    {!accountDeletionRequests.some((request) => request.status === "pending") && <form className="password-change-form" onSubmit={handleAccountDeletionRequest}><label>Motif de la demande<textarea rows="3" minLength="10" value={accountDeletionReason} onChange={(event) => setAccountDeletionReason(event.target.value)} required /></label><button className="document-button danger-button" type="submit" disabled={accountDeletionPending}>{accountDeletionPending ? "Enregistrement…" : "Demander la suppression"}</button></form>}
                    {accountDeletionStatus && <p className={accountDeletionStatus.includes("enregistrée") || accountDeletionStatus.includes("annulée") ? "form-message success" : "form-message"} role="status">{accountDeletionStatus}</p>}
                  </div>
                  <div className="quote-list">
                    <h3>Mes demandes de devis</h3>
                    {quoteListStatus && <p className="invoice-empty" role="status">{quoteListStatus}</p>}
                    {clientQuotes.map((item) => {
                      const itemPackage = packages.find((entry) => String(entry.id) === String(item.package));
                      const itemVenue = venues.find((entry) => String(entry.id) === String(item.venue));
                      const itemEventType = eventTypeRecords.find((entry) => String(entry.id) === String(item.event_type));
                      return (
                        <article className="quote-row" key={item.id}>
                          <div className="quote-row-heading"><strong>Devis n°{item.id}</strong><span className={`quote-status ${item.status}`}>{quoteStatusLabels[item.status] || item.status}</span></div>
                          <span>{itemEventType?.name || "Événement"} · {new Date(`${item.event_date}T00:00:00`).toLocaleDateString("fr-BE")}</span>
                          <span>{itemPackage?.name || `Formule n°${item.package}`} · {itemVenue ? `${itemVenue.name}, ${itemVenue.city}` : `Lieu n°${item.venue}`}</span>
                          <div className="quote-row-amounts"><span>Total : <strong>{formatEuro(item.total_amount)}</strong></span><span>Acompte : <strong>{formatEuro(item.deposit_amount)}</strong></span></div>
                        </article>
                      );
                    })}
                  </div>
                  <div className="cancellation-panel client-cancellation-panel">
                    <div className="playlist-heading"><div><h3>Mes demandes d'annulation</h3><p>Une demande n'annule pas automatiquement la prestation et ne déclenche aucun remboursement.</p></div><FileText /></div>
                    {cancellationStatus && <p className={cancellationStatus.includes("transmise") ? "form-message success" : "form-message"} role="status">{cancellationStatus}</p>}
                    <div className="cancellation-list">
                      {clientBookings.filter((booking) => ["preparatory_meeting", "confirmed", "paid"].includes(booking.status)).map((booking) => {
                        const bookingRequests = cancellationRequests.filter((request) => request.booking === booking.id);
                        const pendingRequest = bookingRequests.find((request) => request.status === "pending");
                        return (
                          <article key={booking.id}>
                            <div className="quote-row-heading"><strong>Réservation n°{booking.id}</strong><span>{new Date(`${booking.event_date}T00:00:00`).toLocaleDateString("fr-BE")}</span></div>
                            {bookingRequests.map((request) => <div className="cancellation-history" key={request.id}><span className={`cancellation-request-status ${request.status}`}>{request.status === "pending" ? "En attente" : request.status === "approved" ? "Acceptée" : "Refusée"}</span><p>{request.reason}</p>{request.review_message && <small>Réponse : {request.review_message}</small>}</div>)}
                            {!pendingRequest && <div className="cancellation-form"><label>Motif<textarea rows="3" maxLength="255" value={cancellationReasons[booking.id] || ""} onChange={(event) => setCancellationReasons((current) => ({ ...current, [booking.id]: event.target.value }))} placeholder="Expliquez la raison de votre demande…" /></label><button className="document-button danger-button" type="button" onClick={() => requestCancellation(booking.id)} disabled={cancellationPendingId === booking.id}>{cancellationPendingId === booking.id ? "Envoi…" : "Demander l'annulation"}</button></div>}
                          </article>
                        );
                      })}
                      {!clientBookings.some((booking) => ["preparatory_meeting", "confirmed", "paid"].includes(booking.status)) && <p className="invoice-empty">Aucune réservation ne peut actuellement faire l'objet d'une demande.</p>}
                    </div>
                  </div>
                  <div className="contract-list">
                    <h3>Mes contrats</h3>
                    {contractStatus && <p className={contractStatus.includes("signé") ? "form-message success" : "invoice-empty"} role="status">{contractStatus}</p>}
                    {contracts.map((contract) => (
                      <article className="contract-row" key={contract.id}>
                        <div><strong>{contract.contract_number}</strong><span>Réservation n°{contract.booking}</span><span>{contract.refund_policy}</span></div>
                        <div className="contract-actions">
                          <span className={`contract-status ${contract.status}`}>{contractStatusLabels[contract.status] || contract.status}</span>
                          <button className="document-button" type="button" onClick={() => downloadDocument("contracts", contract.id, contract.contract_number)} disabled={downloadPending === `contracts-${contract.id}`}><Download /> {downloadPending === `contracts-${contract.id}` ? "Préparation…" : "Télécharger le PDF"}</button>
                          {contract.status === "sent" && <button className="primary-button payment-button" type="button" onClick={() => signClientContract(contract.id)} disabled={contractPendingId === contract.id}><FileText /> {contractPendingId === contract.id ? "Signature…" : "Signer le contrat"}</button>}
                          {contract.signed_by_client_at && <small>Signé le {new Date(contract.signed_by_client_at).toLocaleString("fr-BE")}</small>}
                        </div>
                      </article>
                    ))}
                  </div>
                  <div className="invoice-list">
                    <h3>Mes factures</h3>
                    {invoiceStatus && <p className="invoice-empty" role="status">{invoiceStatus}</p>}
                    {checkoutStatus && <p className="form-message" role="alert">{checkoutStatus}</p>}
                    {invoices.map((invoice) => {
                      const invoicePayments = clientPayments.filter((payment) => payment.invoice === invoice.id);
                      return (
                        <article className="invoice-row" key={invoice.id}>
                          <div><strong>{invoice.invoice_number}</strong><span>{invoice.invoice_type === "deposit" ? "Acompte" : invoice.invoice_type === "balance" ? "Solde" : "Facture complète"} · Échéance : {new Date(invoice.due_at).toLocaleDateString("fr-BE")}</span>{invoicePayments.map((payment) => <div className="client-payment-trace" key={payment.id}><span>Paiement n°{payment.id} · {formatEuro(payment.amount)}</span>{payment.refund_status !== "none" && <small>{payment.refund_status === "pending" ? "Remboursement en cours chez Stripe" : payment.refund_status === "partial" ? `Remboursé partiellement : ${formatEuro(payment.refunded_amount)}` : payment.refund_status === "succeeded" ? `Remboursé : ${formatEuro(payment.refunded_amount)}` : "Le remboursement a échoué — l'administration doit le relancer."}</small>}</div>)}</div>
                          <div className="invoice-actions">
                            <strong>{formatEuro(invoice.amount)}</strong>
                            <span className={`invoice-status ${invoice.status}`}>{invoice.status === "paid" ? "Payée" : invoice.status === "sent" ? "À payer" : invoice.status === "cancelled" ? "Annulée" : invoice.status}</span>
                            <button className="document-button" type="button" onClick={() => downloadDocument("invoices", invoice.id, invoice.invoice_number)} disabled={downloadPending === `invoices-${invoice.id}`}><Download /> {downloadPending === `invoices-${invoice.id}` ? "Préparation…" : "Télécharger le PDF"}</button>
                            {invoice.status === "sent" && (
                              <button className="primary-button payment-button" type="button" onClick={() => startInvoiceCheckout(invoice)} disabled={checkoutPendingId === invoice.id}>
                                <CreditCard /> {checkoutPendingId === invoice.id ? "Redirection…" : invoice.invoice_type === "deposit" ? "Payer l’acompte" : "Payer le solde"}
                              </button>
                            )}
                          </div>
                        </article>
                      );
                    })}
                  </div>
                  <div className="appointment-panel">
                    <div className="playlist-heading"><div><h3>Rendez-vous préparatoire</h3><p>Planifiez la préparation avec votre DJ avant le jour de l’événement.</p></div><CalendarDays /></div>
                    {appointmentStatus && <p className={appointmentStatus.includes("planifié") ? "form-message success" : "invoice-empty"} role="status">{appointmentStatus}</p>}
                    {eligibleAppointmentBookings.length > 0 && (
                      <form className="playlist-form" onSubmit={createPreparatoryAppointment}>
                        <label>Réservation<select value={appointmentBookingId} onChange={(event) => setAppointmentBookingId(event.target.value)} required><option value="">Sélectionner</option>{eligibleAppointmentBookings.map((booking) => <option value={booking.id} key={booking.id}>Réservation n°{booking.id} · {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString("fr-BE")}</option>)}</select></label>
                        <label>Date et heure<input type="datetime-local" value={appointmentDateTime} onChange={(event) => setAppointmentDateTime(event.target.value)} required /></label>
                        <label>Mode<select value={appointmentMode} onChange={(event) => setAppointmentMode(event.target.value)}><option value="online">En ligne</option><option value="in_person">En présentiel</option></select></label>
                        <label>Notes<textarea rows="2" value={appointmentNotes} onChange={(event) => setAppointmentNotes(event.target.value)} placeholder="Sujets à préparer, disponibilité particulière…" /></label>
                        <button className="primary-button" type="submit" disabled={appointmentPending}>{appointmentPending ? "Planification…" : "Planifier le rendez-vous"}</button>
                      </form>
                    )}
                    <div className="appointment-list">
                      {appointments.map((appointment) => <article key={appointment.id}><div><strong>{new Date(appointment.scheduled_at).toLocaleString("fr-BE")}</strong><span>Réservation n°{appointment.booking} · {appointment.mode === "online" ? "En ligne" : "En présentiel"}</span>{appointment.notes && <small>{appointment.notes}</small>}</div><span className={`appointment-status ${appointment.status}`}>{appointment.status === "done" ? "Réalisé" : appointment.status === "cancelled" ? "Annulé" : "Planifié"}</span></article>)}
                    </div>
                  </div>
                  <div className="playlist-panel">
                    <div className="playlist-heading"><div><h3>Ma playlist</h3><p>Proposez vos morceaux au DJ et indiquez vos priorités.</p></div><Music2 /></div>
                    {playlistStatus && <p className={playlistStatus.includes("créée") || playlistStatus.includes("ajoutée") ? "form-message success" : "invoice-empty"} role="status">{playlistStatus}</p>}
                    {eligiblePlaylistBookings.length > 0 && (
                      <form className="playlist-form" onSubmit={createClientPlaylist}>
                        <h4>Créer une playlist</h4>
                        <label>Réservation confirmée<select value={playlistBookingId} onChange={(event) => setPlaylistBookingId(event.target.value)} required><option value="">Sélectionner</option>{eligiblePlaylistBookings.map((booking) => <option value={booking.id} key={booking.id}>Réservation n°{booking.id} · {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString("fr-BE")}</option>)}</select></label>
                        <label>Style principal<select value={playlistStyleId} onChange={(event) => setPlaylistStyleId(event.target.value)} required><option value="">Sélectionner</option>{musicStyles.map((style) => <option value={style.id} key={style.id}>{style.name}</option>)}</select></label>
                        <label>Notes<textarea rows="2" value={playlistNotes} onChange={(event) => setPlaylistNotes(event.target.value)} placeholder="Ambiance souhaitée, moments importants…" /></label>
                        <button className="primary-button" type="submit" disabled={playlistPending}>{playlistPending ? "Création…" : "Créer la playlist"}</button>
                      </form>
                    )}
                    {playlists.length > 0 && <>
                      <form className="playlist-form" onSubmit={addPlaylistSong}>
                        <h4>Ajouter une chanson</h4>
                        <label>Playlist<select value={songPlaylistId} onChange={(event) => setSongPlaylistId(event.target.value)} required>{playlists.map((playlist) => { const style = musicStyles.find((item) => item.id === playlist.main_style); return <option value={playlist.id} key={playlist.id}>Réservation n°{playlist.booking} · {style?.name || "Playlist"}</option>; })}</select></label>
                        <div className="playlist-song-fields"><label>Titre<input value={songTitle} onChange={(event) => setSongTitle(event.target.value)} required /></label><label>Artiste<input value={songArtist} onChange={(event) => setSongArtist(event.target.value)} required /></label></div>
                        <label>Préférence<select value={songPreference} onChange={(event) => setSongPreference(event.target.value)}><option value="must_play">À jouer absolument</option><option value="play_if_possible">À jouer si possible</option><option value="do_not_play">À ne pas jouer</option></select></label>
                        <button className="primary-button" type="submit" disabled={playlistPending}>{playlistPending ? "Ajout…" : "Ajouter la chanson"}</button>
                      </form>
                      <div className="playlist-songs">
                        {playlistSongs.map((song) => <article key={song.id}><div><strong>{song.title}</strong><span>{song.artist}</span></div><div><span>{song.preference_level === "must_play" ? "Incontournable" : song.preference_level === "do_not_play" ? "À éviter" : "Si possible"}</span><small className={`song-status ${song.status}`}>{song.status === "approved" ? "Approuvée" : song.status === "rejected" ? "Refusée" : "Demandée"}</small></div></article>)}
                        {!playlistSongs.length && <p className="invoice-empty">Aucune chanson ajoutée.</p>}
                      </div>
                    </>}
                  </div>
                  <div className="review-panel">
                    <div className="playlist-heading"><div><h3>Mon avis</h3><p>Partagez votre expérience après la prestation.</p></div><Star /></div>
                    {reviewStatus && <p className={reviewStatus.includes("Merci") ? "form-message success" : "invoice-empty"} role="status">{reviewStatus}</p>}
                    {eligibleReviewBookings.length > 0 && (
                      <form className="playlist-form" onSubmit={createClientReview}>
                        <label>Prestation réalisée<select value={reviewBookingId} onChange={(event) => setReviewBookingId(event.target.value)} required><option value="">Sélectionner</option>{eligibleReviewBookings.map((booking) => <option value={booking.id} key={booking.id}>Réservation n°{booking.id} · {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString("fr-BE")}</option>)}</select></label>
                        <label>Note<select value={reviewRating} onChange={(event) => setReviewRating(event.target.value)}>{[5, 4, 3, 2, 1].map((rating) => <option value={rating} key={rating}>{rating} / 5</option>)}</select></label>
                        <label>Commentaire<textarea rows="3" maxLength="255" value={reviewComment} onChange={(event) => setReviewComment(event.target.value)} placeholder="Décrivez la qualité de la prestation…" required /></label>
                        <small>{reviewComment.length}/255 caractères</small>
                        <button className="primary-button" type="submit" disabled={reviewPending}>{reviewPending ? "Envoi…" : "Envoyer mon avis"}</button>
                      </form>
                    )}
                    <div className="review-list">
                      {reviews.map((review) => <article key={review.id}><div className="review-stars" aria-label={`${review.rating} étoiles`}>{[1, 2, 3, 4, 5].map((value) => <Star key={value} className={value <= review.rating ? "filled" : ""} />)}</div><p>{review.comment}</p><span className={`review-status ${review.status}`}>{review.status === "published" ? "Publié" : review.status === "rejected" ? "Rejeté" : "En modération"}</span></article>)}
                    </div>
                  </div>
                  </>}
                  <button className="secondary-button" type="button" onClick={handleLogout}>Se déconnecter</button>
                </div>
              )}
              <aside className="account-benefits"><p className="eyebrow">Votre suivi personnalisé</p><h2>Un parcours clair, étape par étape</h2>{[{ icon: FileText, text: "Consultez vos devis et contrats" }, { icon: CreditCard, text: "Suivez l’acompte et les factures" }, { icon: Music2, text: "Préparez votre playlist" }, { icon: Sparkles, text: "Laissez un avis après la prestation" }].map(({ icon: Icon, text }) => <div key={text}><Icon /><span>{text}</span></div>)}</aside>
            </div>
          </section>
        )}
      </main>

      <SiteFooter onNavigate={navigate} />
    </div>
  );
}
