import { useCallback, useEffect } from "react";

import { apiClient, getAccountDeletionRequests } from "../api";
import { hasBookingEnded } from "../utils/booking";
import { unwrapApiList } from "../utils/apiCollections";

export default function useOperationalWorkspaces(workspaces) {
  const {
    currentUser, isAuthenticated, setAdminBookings, setAdminCancellationRequests,
    setAdminDeletionRequests, setAdminDjs, setAdminPayments, setAdminQuotes, setAdminStatus,
    setDjAppointments, setDjAvailabilities, setDjBookings, setDjSongs, setDjStatus,
  } = workspaces;

  const loadAdminDashboard = useCallback(async () => {
    setAdminStatus("Chargement des devis, réservations et DJs…");
    try {
      const [quotesResponse, djsResponse, bookingsResponse, paymentsResponse, deletionResponse] = await Promise.all([
        apiClient.get("/quotes/", { params: { ordering: "-created_at" } }),
        apiClient.get("/djs/", { params: { ordering: "stage_name" } }),
        apiClient.get("/bookings/", { params: { ordering: "-event_date" } }),
        apiClient.get("/payments/", { params: { ordering: "-paid_at" } }),
        getAccountDeletionRequests(),
      ]);
      const quotes = unwrapApiList(quotesResponse.data);
      const djs = unwrapApiList(djsResponse.data);
      const bookingRecords = unwrapApiList(bookingsResponse.data);
      const payments = unwrapApiList(paymentsResponse.data);
      const requestResponses = await Promise.all(
        bookingRecords.map((booking) => apiClient.get(`/bookings/${booking.id}/cancellation-requests/`)),
      );
      setAdminQuotes(quotes.filter((item) => ["draft", "sent"].includes(item.status)));
      setAdminDjs(djs);
      setAdminPayments(payments);
      setAdminDeletionRequests((Array.isArray(deletionResponse) ? deletionResponse : []).filter((item) => item.status === "pending"));
      setAdminBookings(bookingRecords.filter((item) => item.status === "confirmed" && item.deposit_paid && hasBookingEnded(item)));
      setAdminCancellationRequests(requestResponses.flatMap((response) => response.data).filter((item) => item.status === "pending"));
      setAdminStatus("");
    } catch (error) {
      setAdminStatus(error.response?.status === 403 ? "Ce compte n’a pas les droits administrateur." : "Impossible de charger l’espace administrateur.");
    }
  }, [setAdminBookings, setAdminCancellationRequests, setAdminDeletionRequests, setAdminDjs, setAdminPayments, setAdminQuotes, setAdminStatus]);

  useEffect(() => {
    if (currentUser?.is_staff) loadAdminDashboard();
  }, [currentUser, loadAdminDashboard]);

  useEffect(() => {
    if (!isAuthenticated || currentUser?.role !== "dj") {
      setDjBookings([]);
      setDjAppointments([]);
      setDjSongs([]);
      setDjAvailabilities([]);
      return undefined;
    }
    let active = true;
    setDjStatus("Chargement de votre espace DJ…");
    Promise.all([
      apiClient.get("/bookings/", { params: { ordering: "event_date" } }),
      apiClient.get("/appointments/", { params: { ordering: "scheduled_at" } }),
      apiClient.get("/playlist-songs/", { params: { ordering: "title" } }),
      apiClient.get("/availability/"),
    ]).then(([bookingsResponse, appointmentsResponse, songsResponse, availabilitiesResponse]) => {
      if (!active) return;
      const bookings = unwrapApiList(bookingsResponse.data);
      const appointments = unwrapApiList(appointmentsResponse.data);
      const songs = unwrapApiList(songsResponse.data);
      const availabilities = unwrapApiList(availabilitiesResponse.data);
      setDjBookings(bookings);
      setDjAppointments(appointments);
      setDjSongs(songs);
      setDjAvailabilities(availabilities);
      setDjStatus(bookings.length || appointments.length || songs.length || availabilities.length ? "" : "Aucun dossier ne vous est affecté.");
    }).catch((error) => {
      if (active) setDjStatus(error.response?.status === 403 ? "Ce compte n’a pas accès à l’espace DJ." : "Impossible de charger vos prestations.");
    });
    return () => { active = false; };
  }, [currentUser, isAuthenticated, setDjAppointments, setDjAvailabilities, setDjBookings, setDjSongs, setDjStatus]);

  return { loadAdminDashboard };
}
