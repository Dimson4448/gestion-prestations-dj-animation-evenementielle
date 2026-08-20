import { useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import {
  CircleUserRound,
  FileText,
  Music2,
  ShieldCheck,
  UsersRound,
} from "lucide-react";

import { apiClient, authenticate, cancelAccountDeletionRequest, changePassword, clearAuthentication, confirmPasswordReset, createAccountDeletionRequest, getCurrentUser, getDJApplicationStatus, getStoredAccessToken, logout, registerClient, requestPasswordReset, resendVerificationEmail, reviewAccountDeletionRequest, sessionExpiredEvent, updateClientProfile, verifyEmail } from "./api";
import { validateRefundAmount } from "./utils/refunds";
import SiteFooter from "./components/SiteFooter";
import SiteHeader from "./components/SiteHeader";
import LocalizedContent from "./components/LocalizedContent";
import DJApplicationForm from "./components/DJApplicationForm";
import ConnectedAccountSession from "./components/ConnectedAccountSession";
import AccountBenefits from "./components/AccountBenefits";
import ClientInvoices from "./components/ClientInvoices";
import ClientContracts from "./components/ClientContracts";
import ClientAppointments from "./components/ClientAppointments";
import ClientReviews from "./components/ClientReviews";
import ClientAccountDeletion from "./components/ClientAccountDeletion";
import ClientQuotes from "./components/ClientQuotes";
import HomePage from "./pages/HomePage";
import OffersPage from "./pages/OffersPage";
import DJWorkspacePage from "./pages/DJWorkspacePage";
import AdminWorkspacePage from "./pages/AdminWorkspacePage";
import QuoteRequestPage from "./pages/QuoteRequestPage";
import PackageDetailPage from "./pages/PackageDetailPage";
import { calculateQuoteEstimate, canCreatePlaylist, canPlanAppointment, canSubmitReview, formatEuro } from "./utils/booking";
import { filterPackagesForEventType } from "./utils/catalogue";
import { allowedEventTypeNames } from "./utils/eventTypes";
import useCatalogue from "./hooks/useCatalogue";
import useClientAccount from "./hooks/useClientAccount";
import useOperationalWorkspaces from "./hooks/useOperationalWorkspaces";
import { getAdultBirthDateMax } from "./utils/registration";
import { getLoginSuccessKey } from "./utils/authentication";
import { getPageFromHash, getPageHash } from "./utils/navigation";

const unassignedDj = {
  id: null,
  name: "DJ à confirmer",
  styles: "Sélectionnez un créneau disponible",
  slot: "À confirmer avec l’administration",
  rating: null,
  reviews: 0,
};

const todayIso = new Date().toISOString().slice(0, 10);
const adultBirthDateMax = getAdultBirthDateMax();
const getPageFromHistory = () => {
  return getPageFromHash(window.location.hash);
};

const quoteStatusLabels = {
  draft: "Brouillon",
  sent: "Envoyé",
  accepted: "Accepté",
  refused: "Refusé",
  expired: "Expiré",
};

export default function App() {
  const { i18n, t } = useTranslation();
  const [page, setPage] = useState(getPageFromHistory);
  const language = (i18n.resolvedLanguage || i18n.language || "fr").toUpperCase();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [eventDate, setEventDate] = useState("2026-09-12");
  const {
    availableDjs,
    catalogueReady,
    catalogueStatus,
    eventTypeRecords,
    packages,
    publicAvailabilityStatus,
  } = useCatalogue(eventDate);
  const [selectedPackageId, setSelectedPackageId] = useState("mariage");
  const [selectedDj, setSelectedDj] = useState(unassignedDj);
  const [eventType, setEventType] = useState("");
  const [startTime, setStartTime] = useState("18:00");
  const [location, setLocation] = useState("");
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
  const [djApplicationOpen, setDjApplicationOpen] = useState(false);
  const [djApplicationStatus, setDjApplicationStatus] = useState(null);
  const [djApplicationStatusMessage, setDjApplicationStatusMessage] = useState("");
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

  useEffect(() => {
    if (!packages.length) return;
    setSelectedPackageId((current) => packages.some((item) => String(item.id) === String(current)) ? current : packages[0].id);
  }, [packages]);

  useEffect(() => {
    if (!eventTypeRecords.length) return;
    setEventType((current) => eventTypeRecords.some((item) => item.name === current) ? current : "");
  }, [eventTypeRecords]);
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
  const [refundAmounts, setRefundAmounts] = useState({});
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

  useClientAccount({
    currentUser, isAuthenticated, setAccountDeletionRequests, setAccountDeletionStatus, setAppointmentStatus,
    setAppointments, setCancellationRequests, setClientBookings, setClientPayments, setClientProfile,
    setClientProfileStatus, setClientQuotes, setContractStatus, setContracts, setInvoiceStatus, setInvoices,
    setIsAuthenticated, setLoginStatus, setMusicStyles, setPlaylistBookingId, setPlaylistSongs,
    setPlaylistStatus, setPlaylistStyleId, setPlaylists, setQuoteListStatus, setReviews, setReviewStatus,
    setSelectedVenueId, setSongPlaylistId, setVenues, setVenueStatus,
  });

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
    if (!isAuthenticated || currentUser?.role !== "dj_candidate") {
      setDjApplicationStatus(null);
      setDjApplicationStatusMessage("");
      return;
    }
    let mounted = true;
    setDjApplicationStatusMessage(t("djApplication.loadingStatus"));
    getDJApplicationStatus()
      .then((application) => {
        if (!mounted) return;
        setDjApplicationStatus(application);
        setDjApplicationStatusMessage("");
      })
      .catch(() => {
        if (mounted) setDjApplicationStatusMessage(t("djApplication.unavailableStatus"));
      });
    return () => { mounted = false; };
  }, [currentUser?.role, isAuthenticated, t]);

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

  const { loadAdminDashboard } = useOperationalWorkspaces({
    currentUser, isAuthenticated, setAdminBookings, setAdminCancellationRequests,
    setAdminDeletionRequests, setAdminDjs, setAdminPayments, setAdminQuotes, setAdminStatus,
    setDjAppointments, setDjAvailabilities, setDjBookings, setDjSongs, setDjStatus,
  });

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

  useEffect(() => {
    const handleHistoryNavigation = () => {
      setPage(getPageFromHistory());
      setMobileNavOpen(false);
      setQuoteSubmitted(false);
      window.scrollTo({ top: 0, behavior: "auto" });
    };
    window.addEventListener("popstate", handleHistoryNavigation);
    return () => window.removeEventListener("popstate", handleHistoryNavigation);
  }, []);

  const quote = useMemo(() => {
    return calculateQuoteEstimate({
      basePrice: selectedPackage?.base_price,
      includedHours: selectedPackage?.included_hours,
      durationHours,
      distanceKm,
    });
  }, [distanceKm, durationHours, selectedPackage]);

  const navigate = (target) => {
    const targetHash = getPageHash(target);
    if (window.location.hash !== targetHash) {
      window.history.pushState({ page: target }, "", targetHash);
    }
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
      setLoginStatus(t(getLoginSuccessKey(profile)));
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
    const validation = validateRefundAmount(refundAmounts[payment.id], payment.refundable_amount);
    if (!validation.valid) {
      setAdminStatus(validation.error);
      return;
    }
    setRefundPendingId(payment.id);
    setAdminStatus("");
    try {
      const response = await apiClient.post(`/payments/${payment.id}/refund/`, {
        amount: validation.amount,
        reason: "requested_by_customer",
        internal_reason: `Demande d'annulation n°${request.id} : ${request.reason}`.slice(0, 255),
      });
      setRefundAmounts((current) => ({ ...current, [payment.id]: "" }));
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
      setDjStatus(`Le créneau du ${new Date(`${availability.available_date}T00:00:00`).toLocaleDateString(i18n.language)} est maintenant ${status === "available" ? "disponible" : "bloqué"}.`);
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

  const changeInterfaceLanguage = (nextLanguage) => {
    i18n.changeLanguage(nextLanguage.toLowerCase());
  };

  return (
    <div className="site-shell">
      <SiteHeader
        currentUser={currentUser}
        language={language}
        mobileNavOpen={mobileNavOpen}
        onLanguageChange={changeInterfaceLanguage}
        onNavigate={navigate}
        onToggleMenu={() => setMobileNavOpen((open) => !open)}
        page={page}
      />

      <main id="main-content" tabIndex="-1">
        <LocalizedContent>
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

        {page === "offres" && <OffersPage
          availableDjs={availableDjs}
          availableEventTypes={availableEventTypes}
          compatiblePackages={compatiblePackages}
          eventDate={eventDate}
          eventType={eventType}
          location={location}
          onDateChange={setEventDate}
          onEventTypeChange={setEventType}
          onLocationChange={setLocation}
          onOpenDetail={openDetail}
          onReset={() => { setEventType(""); setLocation(""); }}
          publicAvailabilityStatus={publicAvailabilityStatus}
        />}

        {page === "detail" && selectedPackage && <PackageDetailPage detail={{
          eventDate, location, navigate, selectedDj, selectedPackage, setEventDate, setLocation, startQuote,
        }} />}
        {page === "devis" && <QuoteRequestPage form={{
          availableEventTypes, compatiblePackages, createVenue, createdQuote, distanceKm, durationHours,
          eventDate, eventType, guestCount, location, musicPreferences, navigate, parking, quote,
          quotePending, quoteStatus, quoteSubmitted, selectVenue, selectedPackage, selectedPackageId,
          selectedVenueId, setDistanceKm, setDurationHours, setEventDate, setEventType, setGuestCount,
          setLocation, setMusicPreferences, setParking, setSelectedPackageId, setStartTime, setVenueCountry,
          setVenueName, setVenuePostalCode, setVenueStreet, startTime, submitQuote, venueCountry, venueName,
          venuePending, venuePostalCode, venues, venueStatus, venueStreet,
        }} />}
        {page === "administration" && currentUser?.is_staff && <AdminWorkspacePage workspace={{
          acceptAdminQuote, adminBookings, adminCancellationMessages, adminCancellationPendingId,
          adminCancellationRequests, adminDeletionMessages, adminDeletionPendingId, adminDeletionRequests,
          adminDjs, adminDjSelection, adminPayments, adminPendingId, adminQuotes, adminStatus,
          approveCancellation, completeAdminBooking, completionPendingId, eventTypeRecords, i18n,
          loadAdminDashboard, packages, quoteStatusLabels, refundAmounts, refundCancellationPayment,
          refundPendingId, rejectCancellation, reviewAccountDeletion, sendQuote, setAdminCancellationMessages,
          setAdminDeletionMessages, setAdminDjSelection, setRefundAmounts,
        }} />}
        {page === "dj" && currentUser?.role === "dj" && <DJWorkspacePage workspace={{
          availabilityDate, availabilityEnd, availabilityPendingId, availabilityReason, availabilityStart,
          availabilityStatus, completeDjBooking, createDjAvailability, deleteDjAvailability, djAppointments,
          djAppointmentPendingId, djAvailabilities, djBookings, djPendingId, djSongPendingId, djSongs, djStatus,
          i18n, setAvailabilityDate, setAvailabilityEnd, setAvailabilityReason, setAvailabilityStart,
          setAvailabilityStatus, updateDjAppointment, updateDjAvailability, updateDjSong,
        }} />}
        {page === "compte" && (
          <section className="section-wrap account-page">
            <div className="page-heading"><p className="eyebrow dark">Espace client</p><h1>Retrouvez votre événement au même endroit</h1><p>Connectez-vous pour suivre vos devis, contrats, paiements et playlists.</p></div>
            {paymentReturnStatus && <p className="payment-return-message" role="status"><ShieldCheck /> {paymentReturnStatus}</p>}
            <div className="account-grid">
              {!isAuthenticated ? (
                <>
                  <form className="account-card" onSubmit={handleLogin}>
                    <CircleUserRound /><h2>Connexion</h2>
                    <label>Identifiant<input value={username} onChange={(event) => setUsername(event.target.value)} autoComplete="username" required /></label>
                    <label>Mot de passe<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="current-password" required /></label>
                    {loginStatus && <p className="form-message" role="status">{loginStatus}</p>}
                    <button className="primary-button" type="submit" disabled={loginPending}>{loginPending ? "Connexion…" : "Se connecter"}</button>
                    <button className="secondary-button" type="button" onClick={() => setRegistrationOpen((open) => !open)}>{registrationOpen ? "Fermer l’inscription" : "Créer un compte client"}</button>
                    <button className="secondary-button" type="button" onClick={() => setDjApplicationOpen((open) => !open)}>{djApplicationOpen ? t("djApplication.close") : t("djApplication.open")}</button>
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
                      <label>Date de naissance<input type="date" max={adultBirthDateMax} value={registration.date_of_birth} onChange={(event) => updateRegistration("date_of_birth", event.target.value)} required /></label>
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
                  {djApplicationOpen && <DJApplicationForm onCompleted={() => setVerificationResendOpen(false)} />}
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
                <ConnectedAccountSession
                  currentUser={currentUser}
                  djApplicationStatus={djApplicationStatus}
                  djApplicationStatusMessage={djApplicationStatusMessage}
                  loginStatus={loginStatus}
                  onLogout={handleLogout}
                  onNavigate={navigate}
                >
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
                      <label>Date de naissance<input type="date" max={adultBirthDateMax} value={clientProfile.date_of_birth} onChange={(event) => changeClientProfile("date_of_birth", event.target.value)} required /></label>
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
                  <ClientAccountDeletion
                    cancelRequest={cancelAccountDeletion}
                    onReasonChange={setAccountDeletionReason}
                    onSubmit={handleAccountDeletionRequest}
                    pending={accountDeletionPending}
                    reason={accountDeletionReason}
                    requests={accountDeletionRequests}
                    statusMessage={accountDeletionStatus}
                  />
                  <ClientQuotes
                    eventTypes={eventTypeRecords}
                    packages={packages}
                    quotes={clientQuotes}
                    statusMessage={quoteListStatus}
                    venues={venues}
                  />
                  <div className="cancellation-panel client-cancellation-panel">
                    <div className="playlist-heading"><div><h3>Mes demandes d'annulation</h3><p>Une demande n'annule pas automatiquement la prestation et ne déclenche aucun remboursement.</p></div><FileText /></div>
                    {cancellationStatus && <p className={cancellationStatus.includes("transmise") ? "form-message success" : "form-message"} role="status">{cancellationStatus}</p>}
                    <div className="cancellation-list">
                      {clientBookings.filter((booking) => ["preparatory_meeting", "confirmed", "paid"].includes(booking.status)).map((booking) => {
                        const bookingRequests = cancellationRequests.filter((request) => request.booking === booking.id);
                        const pendingRequest = bookingRequests.find((request) => request.status === "pending");
                        return (
                          <article key={booking.id}>
                            <div className="quote-row-heading"><strong>Réservation n°{booking.id}</strong><span>{new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)}</span></div>
                            {bookingRequests.map((request) => <div className="cancellation-history" key={request.id}><span className={`cancellation-request-status ${request.status}`}>{request.status === "pending" ? "En attente" : request.status === "approved" ? "Acceptée" : "Refusée"}</span><p>{request.reason}</p>{request.review_message && <small>Réponse : {request.review_message}</small>}</div>)}
                            {!pendingRequest && <div className="cancellation-form"><label>Motif<textarea rows="3" maxLength="255" value={cancellationReasons[booking.id] || ""} onChange={(event) => setCancellationReasons((current) => ({ ...current, [booking.id]: event.target.value }))} placeholder="Expliquez la raison de votre demande…" /></label><button className="document-button danger-button" type="button" onClick={() => requestCancellation(booking.id)} disabled={cancellationPendingId === booking.id}>{cancellationPendingId === booking.id ? "Envoi…" : "Demander l'annulation"}</button></div>}
                          </article>
                        );
                      })}
                      {!clientBookings.some((booking) => ["preparatory_meeting", "confirmed", "paid"].includes(booking.status)) && <p className="invoice-empty">Aucune réservation ne peut actuellement faire l'objet d'une demande.</p>}
                    </div>
                  </div>
                  <ClientContracts
                    contracts={contracts}
                    contractPendingId={contractPendingId}
                    contractStatus={contractStatus}
                    downloadDocument={downloadDocument}
                    downloadPending={downloadPending}
                    signContract={signClientContract}
                  />
                  <ClientInvoices
                    checkoutPendingId={checkoutPendingId}
                    checkoutStatus={checkoutStatus}
                    clientPayments={clientPayments}
                    downloadDocument={downloadDocument}
                    downloadPending={downloadPending}
                    invoices={invoices}
                    invoiceStatus={invoiceStatus}
                    startCheckout={startInvoiceCheckout}
                  />
                  <ClientAppointments
                    appointmentBookingId={appointmentBookingId}
                    appointmentDateTime={appointmentDateTime}
                    appointmentMode={appointmentMode}
                    appointmentNotes={appointmentNotes}
                    appointments={appointments}
                    appointmentPending={appointmentPending}
                    appointmentStatus={appointmentStatus}
                    eligibleBookings={eligibleAppointmentBookings}
                    onBookingChange={setAppointmentBookingId}
                    onDateTimeChange={setAppointmentDateTime}
                    onModeChange={setAppointmentMode}
                    onNotesChange={setAppointmentNotes}
                    onSubmit={createPreparatoryAppointment}
                  />
                  <div className="playlist-panel">
                    <div className="playlist-heading"><div><h3>Ma playlist</h3><p>Proposez vos morceaux au DJ et indiquez vos priorités.</p></div><Music2 /></div>
                    {playlistStatus && <p className={playlistStatus.includes("créée") || playlistStatus.includes("ajoutée") ? "form-message success" : "invoice-empty"} role="status">{playlistStatus}</p>}
                    {eligiblePlaylistBookings.length > 0 && (
                      <form className="playlist-form" onSubmit={createClientPlaylist}>
                        <h4>Créer une playlist</h4>
                        <label>Réservation confirmée<select value={playlistBookingId} onChange={(event) => setPlaylistBookingId(event.target.value)} required><option value="">Sélectionner</option>{eligiblePlaylistBookings.map((booking) => <option value={booking.id} key={booking.id}>Réservation n°{booking.id} · {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)}</option>)}</select></label>
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
                  <ClientReviews
                    comment={reviewComment}
                    eligibleBookings={eligibleReviewBookings}
                    onBookingChange={setReviewBookingId}
                    onCommentChange={setReviewComment}
                    onRatingChange={setReviewRating}
                    onSubmit={createClientReview}
                    pending={reviewPending}
                    rating={reviewRating}
                    reviewBookingId={reviewBookingId}
                    reviews={reviews}
                    statusMessage={reviewStatus}
                  />
                  </>}
                </ConnectedAccountSession>
              )}
              <AccountBenefits />
            </div>
          </section>
        )}
        </LocalizedContent>
      </main>

      <SiteFooter currentUser={currentUser} onNavigate={navigate} />
    </div>
  );
}
