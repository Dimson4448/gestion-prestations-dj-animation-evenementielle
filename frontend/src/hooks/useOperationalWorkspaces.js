import { useCallback, useEffect } from "react";

import { apiClient, getAccountDeletionRequests } from "../api";
import { hasBookingEnded } from "../utils/booking";

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
    }).catch((error) => {
      if (active) setDjStatus(error.response?.status === 403 ? "Ce compte n’a pas accès à l’espace DJ." : "Impossible de charger vos prestations.");
    });
    return () => { active = false; };
  }, [currentUser, isAuthenticated, setDjAppointments, setDjAvailabilities, setDjBookings, setDjSongs, setDjStatus]);

  return { loadAdminDashboard };
}
