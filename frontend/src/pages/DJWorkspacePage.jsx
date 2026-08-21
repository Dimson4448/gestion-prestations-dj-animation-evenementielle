import { useEffect, useState } from "react";
import { CalendarDays, ChevronDown, Clock3, FileText, Music2, ShieldCheck } from "lucide-react";
import { useTranslation } from "react-i18next";

import { formatEuro, hasBookingEnded } from "../utils/booking";
import LocalizedContent from "../components/LocalizedContent";
import { apiClient } from "../api";
import { unwrapApiList } from "../utils/apiCollections";

const todayIso = new Date().toISOString().slice(0, 10);

export default function DJWorkspacePage({ workspace }) {
  const { t } = useTranslation();
  const [openPanel, setOpenPanel] = useState(null);
  const [quoteRequests, setQuoteRequests] = useState([]);
  const [quoteRequestStatus, setQuoteRequestStatus] = useState(t("djRequests.loading"));
  const [quotePendingId, setQuotePendingId] = useState(null);
  const [appointmentDrafts, setAppointmentDrafts] = useState({});
  const {
    availabilityDate, availabilityEnd, availabilityEndDate, availabilityMessage, availabilityPendingId, availabilityReason, availabilityStart,
    availabilityStatus, completeDjBooking, createDjAvailability, deleteDjAvailability, djAppointments,
    djAppointmentPendingId, djAvailabilities, djBookings, djPendingId, djSongPendingId, djSongs, djStatus,
    i18n, setAvailabilityDate, setAvailabilityEnd, setAvailabilityEndDate, setAvailabilityReason, setAvailabilityStart, setDjBookings,
    setAvailabilityStatus, updateDjAppointment, updateDjAvailability, updateDjSong,
  } = workspace;

  useEffect(() => {
    let active = true;
    apiClient.get("/quotes/", { params: { ordering: "event_date" } })
      .then((response) => {
        if (!active) return;
        const records = unwrapApiList(response.data);
        setQuoteRequests(records);
        setQuoteRequestStatus(records.length ? "" : t("djRequests.empty"));
      })
      .catch(() => active && setQuoteRequestStatus(t("djRequests.loadError")));
    return () => { active = false; };
  }, []);

  const decideQuote = async (quote, decision) => {
    setQuotePendingId(quote.id);
    setQuoteRequestStatus("");
    try {
      const response = await apiClient.post(`/quotes/${quote.id}/dj-decision/`, { decision });
      const updatedQuote = response.data.quote || response.data;
      setQuoteRequests((current) => current.map((item) => item.id === quote.id ? updatedQuote : item));
      if (response.data.booking) {
        setDjBookings((current) => [response.data.booking, ...current.filter((item) => item.id !== response.data.booking.id)]);
      }
      setQuoteRequestStatus(t(decision === "accepted" ? "djRequests.acceptedMessage" : "djRequests.refusedMessage", { id: quote.id }));
    } catch (error) {
      setQuoteRequestStatus(error.response?.data?.detail || t("djRequests.decisionError"));
    } finally {
      setQuotePendingId(null);
    }
  };

  const updateAppointmentDraft = (appointmentId, field, value) => {
    setAppointmentDrafts((current) => ({
      ...current,
      [appointmentId]: { mode: "online", ...current[appointmentId], [field]: value },
    }));
  };

  const decideAppointment = async (appointment, status) => {
    const draft = appointmentDrafts[appointment.id] || {};
    const extra = {};
    if (status === "refused") extra.response_message = draft.responseMessage || "";
    if (status === "counter_proposed") {
      extra.response_message = draft.responseMessage || "";
      extra.mode = draft.mode || appointment.mode;
      if (draft.scheduledAt) extra.scheduled_at = new Date(draft.scheduledAt).toISOString();
    }
    const succeeded = await updateDjAppointment(appointment.id, status, extra);
    if (succeeded !== false) {
      setAppointmentDrafts((current) => {
        const next = { ...current };
        delete next[appointment.id];
        return next;
      });
    }
  };
  return <LocalizedContent>
          <section className="section-wrap admin-page">
            <div className="page-heading"><p className="eyebrow dark">Espace DJ</p><h1>Mes prestations</h1><p>Consultez les événements qui vous sont affectés et clôturez une prestation lorsque celle-ci est terminée.</p></div>
            <section className="dj-quote-requests">
              <div className="playlist-heading"><div><h2>{t("djRequests.title")}</h2><p>{t("djRequests.intro")}</p></div><FileText /></div>
              {quoteRequestStatus && <p className={quoteRequestStatus.includes("acceptée") || quoteRequestStatus.includes("refusée") ? "form-message success" : "invoice-empty"} role="status">{quoteRequestStatus}</p>}
              <div className="admin-quote-grid">
                {quoteRequests.map((quote) => (
                  <article className="admin-quote-card" key={quote.id}>
                    <div className="quote-row-heading"><h3>{t("djRequests.request", { id: quote.id })}</h3><span className={`quote-status ${quote.dj_decision === "accepted" ? "accepted" : quote.dj_decision === "refused" ? "refused" : "sent"}`}>{t(`djRequests.${quote.dj_decision === "pending" ? "pending" : quote.dj_decision}`)}</span></div>
                    <p><CalendarDays /> {quote.event_type_name} · {new Date(`${quote.event_date}T00:00:00`).toLocaleDateString(i18n.language)} à {String(quote.start_time).slice(0, 5)} ({quote.duration_hours} h)</p>
                    <p><FileText /> {quote.package_name} · <strong>{formatEuro(quote.total_amount)}</strong> · {t("djRequests.deposit", { amount: formatEuro(quote.deposit_amount) })}</p>
                    {quote.client_details && <div className="dj-client-details"><strong>{quote.client_details.first_name} {quote.client_details.last_name}</strong><span>{quote.client_details.phone}</span><a href={`mailto:${quote.client_details.email}`}>{quote.client_details.email}</a></div>}
                    {quote.venue_details && <p>{t("djRequests.location")} : {quote.venue_details.name}, {quote.venue_details.street}, {quote.venue_details.postal_code} {quote.venue_details.city}</p>}
                    {quote.music_preferences && <p>{t("djRequests.preferences")} : {quote.music_preferences}</p>}
                    {quote.dj_decision === "pending" && <div className="dj-action-buttons"><button className="primary-button" type="button" onClick={() => decideQuote(quote, "accepted")} disabled={quotePendingId === quote.id}>{t("djRequests.accept")}</button><button className="document-button danger-button" type="button" onClick={() => decideQuote(quote, "refused")} disabled={quotePendingId === quote.id}>{t("djRequests.refuse")}</button></div>}
                  </article>
                ))}
              </div>
            </section>
            <div className="admin-toolbar"><div><strong>{djBookings.length}</strong><span> prestations affectées</span></div></div>
            {djStatus && <p className={djStatus.includes("clôturée") || djStatus.includes("marqué") || djStatus.includes("annulé") || djStatus.includes("acceptée") || djStatus.includes("refusée") || djStatus.includes("enregistré") || djStatus.includes("maintenant") || djStatus.includes("supprimé") ? "form-message success" : "form-message"} role="status">{djStatus}</p>}
            <div className="admin-quote-grid">
              {djBookings.map((booking) => {
                const canComplete = booking.status === "confirmed" && booking.deposit_paid && hasBookingEnded(booking);
                const statusLabel = booking.status === "confirmed" ? "Confirmée" : booking.status === "performed" ? "Réalisée" : booking.status === "paid" ? "Payée" : booking.status;
                return (
                  <article className="admin-quote-card" key={booking.id}>
                    <div className="quote-row-heading"><h2>Réservation n°{booking.id}</h2><span className={`quote-status ${booking.status === "paid" || booking.status === "performed" ? "accepted" : "sent"}`}>{statusLabel}</span></div>
                    <p><CalendarDays /> {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)} {String(booking.start_time).slice(0, 5)} → {new Date(`${booking.end_date || booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)} {String(booking.end_time).slice(0, 5)}</p>
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
                <button className="dj-panel-trigger" type="button" aria-expanded={openPanel === "appointments"} aria-controls="dj-appointments-panel" onClick={() => setOpenPanel((panel) => panel === "appointments" ? null : "appointments")}>
                  <span><CalendarDays /><span><strong>Rendez-vous préparatoires</strong><small>Confirmez le suivi effectué avec vos clients.</small></span></span>
                  <span className="dj-panel-count">{djAppointments.length}</span><ChevronDown className={openPanel === "appointments" ? "open" : ""} />
                </button>
                {openPanel === "appointments" && <div className="appointment-list dj-panel-content" id="dj-appointments-panel">
                  {djAppointments.map((appointment) => {
                    const appointmentDate = new Date(appointment.scheduled_at);
                    const draft = appointmentDrafts[appointment.id] || {};
                    const statusLabels = { proposed: "Proposé par le client", counter_proposed: "Contre-proposition envoyée", accepted: "Accepté", refused: "Refusé", done: "Réalisé", cancelled: "Annulé" };
                    return (
                      <article key={appointment.id}>
                        <div className="appointment-main"><strong>{appointmentDate.toLocaleString(i18n.language)}</strong><span>Réservation n°{appointment.booking} · {appointment.mode === "online" ? "En ligne" : "En présentiel"}</span>{appointment.notes && <small>{appointment.notes}</small>}{appointment.response_message && <small className="appointment-response">Échange : {appointment.response_message}</small>}</div>
                        <div className="appointment-decision">
                          <span className={`appointment-status ${appointment.status}`}>{statusLabels[appointment.status] || appointment.status}</span>
                          {appointment.status === "proposed" && <>
                            <p className="appointment-decision-help">Confirmez cette proposition, refusez-la avec un motif ou proposez un autre créneau.</p>
                            <label>Motif ou message<textarea rows="2" value={draft.responseMessage || ""} onChange={(event) => updateAppointmentDraft(appointment.id, "responseMessage", event.target.value)} placeholder="Expliquez le refus ou votre contre-proposition" /></label>
                            <div className="appointment-counter-grid"><label>Nouvelle date et heure<input type="datetime-local" value={draft.scheduledAt || ""} onChange={(event) => updateAppointmentDraft(appointment.id, "scheduledAt", event.target.value)} /></label><label>Mode<select value={draft.mode || appointment.mode} onChange={(event) => updateAppointmentDraft(appointment.id, "mode", event.target.value)}><option value="online">En ligne</option><option value="in_person">En présentiel</option></select></label></div>
                            <div className="dj-action-buttons"><button className="document-button" type="button" onClick={() => decideAppointment(appointment, "accepted")} disabled={djAppointmentPendingId === appointment.id}>Accepter</button><button className="document-button danger-button" type="button" onClick={() => decideAppointment(appointment, "refused")} disabled={djAppointmentPendingId === appointment.id || (draft.responseMessage || "").trim().length < 5}>Refuser</button><button className="primary-button" type="button" onClick={() => decideAppointment(appointment, "counter_proposed")} disabled={djAppointmentPendingId === appointment.id || !draft.scheduledAt || (draft.responseMessage || "").trim().length < 5}>Envoyer la contre-proposition</button></div>
                          </>}
                          {appointment.status === "counter_proposed" && <p className="appointment-decision-help">En attente de la réponse du client.</p>}
                          {appointment.status === "accepted" && appointmentDate <= new Date() && <button className="document-button" type="button" onClick={() => updateDjAppointment(appointment.id, "done")} disabled={djAppointmentPendingId === appointment.id}>Marquer réalisé</button>}
                          {appointment.status === "accepted" && <button className="document-button danger-button" type="button" onClick={() => updateDjAppointment(appointment.id, "cancelled")} disabled={djAppointmentPendingId === appointment.id}>Annuler</button>}
                        </div>
                      </article>
                    );
                  })}
                  {!djAppointments.length && <div className="dj-empty-detail"><CalendarDays /><div><strong>Aucun rendez-vous préparatoire planifié</strong><p>Les rendez-vous créés par les clients apparaîtront ici dès qu’une réservation vous sera affectée.</p></div></div>}
                </div>}
              </section>
              <section className="dj-action-panel">
                <button className="dj-panel-trigger" type="button" aria-expanded={openPanel === "songs"} aria-controls="dj-songs-panel" onClick={() => setOpenPanel((panel) => panel === "songs" ? null : "songs")}>
                  <span><Music2 /><span><strong>Demandes musicales</strong><small>Acceptez ou refusez les propositions des clients.</small></span></span>
                  <span className="dj-panel-count">{djSongs.length}</span><ChevronDown className={openPanel === "songs" ? "open" : ""} />
                </button>
                {openPanel === "songs" && <div className="playlist-songs dj-panel-content" id="dj-songs-panel">
                  {djSongs.map((song) => (
                    <article key={song.id}>
                      <div><strong>{song.title}</strong><span>{song.artist} · Playlist n°{song.playlist}</span></div>
                      <div className="dj-action-buttons"><small className={`song-status ${song.status}`}>{song.status === "approved" ? "Acceptée" : song.status === "rejected" ? "Refusée" : "Demandée"}</small>{song.status === "requested" && <><button className="document-button" type="button" onClick={() => updateDjSong(song.id, "approved")} disabled={djSongPendingId === song.id}>Accepter</button><button className="document-button danger-button" type="button" onClick={() => updateDjSong(song.id, "rejected")} disabled={djSongPendingId === song.id}>Refuser</button></>}</div>
                    </article>
                  ))}
                  {!djSongs.length && <div className="dj-empty-detail"><Music2 /><div><strong>Aucune demande musicale reçue</strong><p>Les morceaux proposés par les clients apparaîtront ici avec les actions Accepter et Refuser.</p></div></div>}
                </div>}
              </section>
            </div>
            <section className="availability-panel">
              <div className="playlist-heading"><div><h2>Mes disponibilités</h2><p>Ouvrez les créneaux pendant lesquels l’administration peut vous affecter une prestation.</p></div><Clock3 /></div>
              <form className="availability-form" onSubmit={createDjAvailability}>
                <label>Date de début<input type="date" min={todayIso} value={availabilityDate} onChange={(event) => { setAvailabilityDate(event.target.value); if (availabilityEndDate < event.target.value) setAvailabilityEndDate(event.target.value); }} required /></label>
                <label>Début<input type="time" value={availabilityStart} onChange={(event) => setAvailabilityStart(event.target.value)} required /></label>
                <label>Date de fin<input type="date" min={availabilityDate} value={availabilityEndDate} onChange={(event) => setAvailabilityEndDate(event.target.value)} required /></label>
                <label>Fin<input type="time" min={availabilityEndDate === availabilityDate ? availabilityStart : undefined} value={availabilityEnd} onChange={(event) => setAvailabilityEnd(event.target.value)} aria-describedby="availability-message" required /></label>
                <label>État<select value={availabilityStatus} onChange={(event) => setAvailabilityStatus(event.target.value)}><option value="available">Disponible</option><option value="blocked">Bloqué</option></select></label>
                {availabilityStatus === "blocked" && <label className="availability-reason">Motif<input value={availabilityReason} onChange={(event) => setAvailabilityReason(event.target.value)} placeholder="Indisponibilité personnelle" required /></label>}
                <button className="primary-button" type="submit" disabled={availabilityPendingId === "create"}>{availabilityPendingId === "create" ? "Enregistrement…" : "Ajouter le créneau"}</button>
              </form>
              {availabilityMessage && <p id="availability-message" className={`availability-message ${availabilityMessage.includes("enregistré et") ? "success" : "error"}`} role="status">{availabilityMessage}</p>}
              <div className="availability-list">
                {djAvailabilities.map((availability) => (
                  <article key={availability.id}>
                    <div><strong>{new Date(`${availability.available_date}T00:00:00`).toLocaleDateString(i18n.language)} · {String(availability.start_time).slice(0, 5)}</strong><span>jusqu’au {new Date(`${availability.end_date || availability.available_date}T00:00:00`).toLocaleDateString(i18n.language)} · {String(availability.end_time).slice(0, 5)}</span>{availability.reason && <small>{availability.reason}</small>}</div>
                    <div className="dj-action-buttons"><span className={`availability-status ${availability.status}`}>{availability.status === "available" ? "Disponible" : availability.status === "reserved" ? "Réservé — acompte en attente" : availability.status === "occupied" ? "Occupé — acompte payé" : "Bloqué"}</span>{availability.status === "available" && <button className="document-button" type="button" onClick={() => updateDjAvailability(availability, "blocked")} disabled={availabilityPendingId === availability.id}>Bloquer</button>}{availability.status === "blocked" && <button className="document-button" type="button" onClick={() => updateDjAvailability(availability, "available")} disabled={availabilityPendingId === availability.id}>Rouvrir</button>}{!['reserved', 'occupied'].includes(availability.status) && <button className="document-button danger-button" type="button" onClick={() => deleteDjAvailability(availability)} disabled={availabilityPendingId === availability.id}>Supprimer</button>}</div>
                  </article>
                ))}
                {!djAvailabilities.length && <p className="invoice-empty">Aucun créneau enregistré.</p>}
              </div>
            </section>
          </section>
  </LocalizedContent>;
}

