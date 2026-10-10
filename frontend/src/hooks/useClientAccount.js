import { useEffect } from "react";

import { apiClient, clearAuthentication, getAccountDeletionRequests, getClientProfile } from "../api";
import { isUserInRole, unwrapApiList } from "../utils/apiCollections";

const getAllMusicStyles = async () => {
  let nextPage = "/music-styles/?ordering=name";
  const styles = [];

  while (nextPage) {
    const response = await apiClient.get(nextPage);
    styles.push(...unwrapApiList(response.data));
    nextPage = response.data?.next || null;
  }

  return styles;
};

export default function useClientAccount(account) {
  const {
    currentUser, isAuthenticated, setAccountDeletionRequests, setAccountDeletionStatus, setAppointmentStatus,
    setAppointments, setCancellationRequests, setClientBookings, setClientPayments, setClientProfile,
    setClientProfileStatus, setClientQuotes, setContractStatus, setContracts, setInvoiceStatus, setInvoices,
    setIsAuthenticated, setLoginStatus, setMusicStyles, setPlaylistBookingId, setPlaylistSongs,
    setPlaylistStatus, setPlaylistStyleIds, setPlaylists, setQuoteListStatus, setReviews, setReviewStatus,
    setSelectedVenueId, setSongPlaylistId, setVenues, setVenueStatus,
  } = account;

useEffect(() => {
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
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
        const invoices = unwrapApiList(invoiceResponse.data);
        const payments = unwrapApiList(paymentResponse.data);
        setInvoices(invoices);
        setClientPayments(payments);
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
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
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
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
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
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
    setReviews([]);
    return;
  }
  let mounted = true;
  setReviewStatus("Chargement de vos avis…");
  apiClient.get("/reviews/", { params: { ordering: "-created_at" } })
    .then((response) => {
      if (!mounted) return;
        const records = unwrapApiList(response.data);
      setReviews(records);
      setReviewStatus(records.length ? "" : "Aucun avis déposé.");
    })
    .catch(() => mounted && setReviewStatus("Impossible de charger vos avis."));
  return () => { mounted = false; };
}, [isAuthenticated, currentUser]);

useEffect(() => {
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
    setAppointments([]);
    return;
  }
  let mounted = true;
  setAppointmentStatus("Chargement de vos rendez-vous…");
  apiClient.get("/appointments/", { params: { ordering: "scheduled_at" } })
    .then((response) => {
      if (!mounted) return;
        const records = unwrapApiList(response.data);
      setAppointments(records);
      setAppointmentStatus(records.length ? "" : "Aucun rendez-vous préparatoire planifié.");
    })
    .catch(() => mounted && setAppointmentStatus("Impossible de charger les rendez-vous."));
  return () => { mounted = false; };
}, [isAuthenticated, currentUser]);

useEffect(() => {
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
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
    getAllMusicStyles(),
  ])
    .then(async ([bookingsResponse, playlistsResponse, songsResponse, styleRecords]) => {
      if (!mounted) return;
        const bookingRecords = unwrapApiList(bookingsResponse.data);
        const playlistRecords = unwrapApiList(playlistsResponse.data);
        const songRecords = unwrapApiList(songsResponse.data);
      setClientBookings(bookingRecords);
      const requestResponses = await Promise.all(
        bookingRecords.map((booking) => apiClient.get(`/bookings/${booking.id}/cancellation-requests/`)),
      );
      if (!mounted) return;
      setCancellationRequests(requestResponses.flatMap((response) => response.data));
      const eligible = bookingRecords.filter((item) => item.deposit_paid && ["confirmed", "performed", "paid"].includes(item.status) && !playlistRecords.some((playlist) => playlist.booking === item.id));
      const initializedPlaylists = await Promise.all(eligible.map((booking) => (
        apiClient.post("/playlists/initialize/", { booking: booking.id }).then((response) => response.data)
      )));
      if (!mounted) return;
      const allPlaylists = [...playlistRecords, ...initializedPlaylists];
      setPlaylists(allPlaylists);
      setPlaylistSongs(songRecords);
      setMusicStyles(styleRecords);
      setPlaylistBookingId("");
      setPlaylistStyleIds([]);
      setSongPlaylistId((current) => current || String(allPlaylists[0]?.id || ""));
      setPlaylistStatus(allPlaylists.length ? "" : "La playlist sera disponible après confirmation de l’acompte.");
    })
    .catch(() => mounted && setPlaylistStatus("Impossible de charger les playlists pour le moment."));
  return () => { mounted = false; };
}, [isAuthenticated, currentUser]);

useEffect(() => {
    if (!isUserInRole(isAuthenticated, currentUser, "client")) {
    setContracts([]);
    return;
  }
  let mounted = true;
  setContractStatus("Chargement de vos contrats…");
  apiClient.get("/contracts/", { params: { ordering: "-created_at" } })
    .then((response) => {
      if (!mounted) return;
        const records = unwrapApiList(response.data);
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
    if (!isUserInRole(isAuthenticated, currentUser, "client")) return;

  let mounted = true;
  setQuoteListStatus("Chargement de vos devis…");
  apiClient
    .get("/quotes/", { params: { ordering: "-created_at" } })
    .then((response) => {
      if (!mounted) return;
        const quotes = unwrapApiList(response.data);
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
    if (!isUserInRole(isAuthenticated, currentUser, "client")) return;

  let mounted = true;
  apiClient
    .get("/venues/", { params: { ordering: "city,name" } })
    .then((response) => {
      if (!mounted) return;
        setVenues(unwrapApiList(response.data));
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

}
