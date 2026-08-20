import { CalendarDays, Clock3, FileText, Music2, ShieldCheck } from "lucide-react";

import { formatEuro, hasBookingEnded } from "../utils/booking";

const todayIso = new Date().toISOString().slice(0, 10);

export default function DJWorkspacePage({ workspace }) {
  const {
    availabilityDate, availabilityEnd, availabilityPendingId, availabilityReason, availabilityStart,
    availabilityStatus, completeDjBooking, createDjAvailability, deleteDjAvailability, djAppointments,
    djAppointmentPendingId, djAvailabilities, djBookings, djPendingId, djSongPendingId, djSongs, djStatus,
    i18n, setAvailabilityDate, setAvailabilityEnd, setAvailabilityReason, setAvailabilityStart,
    setAvailabilityStatus, updateDjAppointment, updateDjAvailability, updateDjSong,
  } = workspace;
  return (
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
                    <p><CalendarDays /> {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)} · {String(booking.start_time).slice(0, 5)}–{String(booking.end_time).slice(0, 5)}</p>
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
                        <div><strong>{appointmentDate.toLocaleString(i18n.language)}</strong><span>Réservation n°{appointment.booking} · {appointment.mode === "online" ? "En ligne" : "En présentiel"}</span>{appointment.notes && <small>{appointment.notes}</small>}</div>
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
                    <div><strong>{new Date(`${availability.available_date}T00:00:00`).toLocaleDateString(i18n.language)}</strong><span>{String(availability.start_time).slice(0, 5)}–{String(availability.end_time).slice(0, 5)}</span>{availability.reason && <small>{availability.reason}</small>}</div>
                    <div className="dj-action-buttons"><span className={`availability-status ${availability.status}`}>{availability.status === "available" ? "Disponible" : availability.status === "reserved" ? "Réservé" : "Bloqué"}</span>{availability.status === "available" && <button className="document-button" type="button" onClick={() => updateDjAvailability(availability, "blocked")} disabled={availabilityPendingId === availability.id}>Bloquer</button>}{availability.status === "blocked" && <button className="document-button" type="button" onClick={() => updateDjAvailability(availability, "available")} disabled={availabilityPendingId === availability.id}>Rouvrir</button>}{availability.status !== "reserved" && <button className="document-button danger-button" type="button" onClick={() => deleteDjAvailability(availability)} disabled={availabilityPendingId === availability.id}>Supprimer</button>}</div>
                  </article>
                ))}
                {!djAvailabilities.length && <p className="invoice-empty">Aucun créneau enregistré.</p>}
              </div>
            </section>
          </section>
  );
}

