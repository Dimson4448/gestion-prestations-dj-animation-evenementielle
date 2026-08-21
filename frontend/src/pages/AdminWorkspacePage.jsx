import { CalendarDays, Check, CircleUserRound, Clock3, FileText } from "lucide-react";
import { useCallback, useState } from "react";

import { formatEuro, hasBookingEnded } from "../utils/booking";
import LocalizedContent from "../components/LocalizedContent";
import AdminDashboardOverview from "../components/AdminDashboardOverview";

export default function AdminWorkspacePage({ workspace }) {
  const [selectedSection, setSelectedSection] = useState("overview");
  const selectSection = useCallback((section) => setSelectedSection(section), []);
  const {
    acceptAdminQuote, adminBookings, adminCancellationMessages, adminCancellationPendingId,
    adminCancellationRequests, adminDeletionMessages, adminDeletionPendingId, adminDeletionRequests,
    adminDjs, adminDjSelection, adminPayments, adminPendingId, adminQuotes, adminStatus,
    approveCancellation, completeAdminBooking, completionPendingId, eventTypeRecords, i18n,
    loadAdminDashboard, packages, quoteStatusLabels, refundAmounts, refundCancellationPayment,
    refundPendingId, rejectCancellation, reviewAccountDeletion, sendQuote, setAdminCancellationMessages,
    setAdminDeletionMessages, setAdminDjSelection, setRefundAmounts,
  } = workspace;
  const bookingsToComplete = adminBookings.filter((item) => item.status === "confirmed" && item.deposit_paid && hasBookingEnded(item));
  return <LocalizedContent>
          <section className={`section-wrap admin-page admin-view-${selectedSection}`}>
            <AdminDashboardOverview bookings={adminBookings} cancellationRequests={adminCancellationRequests} deletionRequests={adminDeletionRequests} djs={adminDjs} i18n={i18n} onRefresh={loadAdminDashboard} onSectionChange={selectSection} payments={adminPayments} quotes={adminQuotes} />
            <div className="page-heading" id="admin-quotes"><p className="eyebrow dark">Espace administrateur</p><h1>Traiter les demandes de devis</h1><p>Envoyez le devis au client, choisissez un DJ réellement disponible, puis créez automatiquement la réservation, le contrat et la facture d’acompte.</p></div>
            <div className="admin-toolbar"><div><strong>{adminQuotes.length}</strong><span> devis à traiter</span></div><button className="secondary-button" type="button" onClick={loadAdminDashboard}>Actualiser</button></div>
            {adminStatus && <p className={adminStatus.includes("créés") || adminStatus.includes("prêt") || adminStatus.includes("clôturée") || adminStatus.includes("refusée") || adminStatus.includes("remboursé") || adminStatus.includes("annulée") ? "form-message success" : "form-message"} role="status">{adminStatus}</p>}
            <div className="admin-quote-grid">
              {adminQuotes.map((item) => {
                const itemPackage = packages.find((entry) => String(entry.id) === String(item.package));
                const itemEventType = eventTypeRecords.find((entry) => String(entry.id) === String(item.event_type));
                return (
                  <article className="admin-quote-card" key={item.id}>
                    <div className="quote-row-heading"><h2>Devis n°{item.id}</h2><span className={`quote-status ${item.status}`}>{quoteStatusLabels[item.status]}</span></div>
                    <p><CalendarDays /> {itemEventType?.name || "Événement"} · {new Date(`${item.event_date}T00:00:00`).toLocaleDateString(i18n.language)} à {String(item.start_time).slice(0, 5)}</p>
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
                      <small>Demandée le {new Date(request.requested_at).toLocaleString(i18n.language)}</small>
                      <div className="cancellation-payments">
                        <strong>Paiements liés</strong>
                        {requestPayments.map((payment) => <div key={payment.id}><span>Paiement n°{payment.id} · {formatEuro(payment.amount)}<small>Remboursé : {formatEuro(payment.refunded_amount)} · Restant : {formatEuro(payment.refundable_amount)}</small></span><span className={`invoice-status ${payment.refund_status === "pending" ? "pending" : payment.status}`}>{payment.refund_status === "pending" ? "Remboursement en cours" : payment.refund_status === "partial" ? "Partiellement remboursé" : payment.refund_status === "failed" ? "Remboursement échoué" : payment.status === "paid" ? "Payé" : payment.status === "refunded" ? "Remboursé" : payment.status === "pending" ? "En attente" : "Échoué"}</span>{payment.status === "paid" && payment.refund_status !== "pending" && Number(payment.refundable_amount) > 0 && <div className="partial-refund-controls"><label>Montant à rembourser<input type="number" min="0.01" max={payment.refundable_amount} step="0.01" inputMode="decimal" value={refundAmounts[payment.id] || ""} onChange={(event) => setRefundAmounts((current) => ({ ...current, [payment.id]: event.target.value }))} placeholder={`Maximum ${formatEuro(payment.refundable_amount)}`} /></label><button className="document-button" type="button" onClick={() => refundCancellationPayment(payment, request)} disabled={refundPendingId === payment.id}>{refundPendingId === payment.id ? "Remboursement…" : "Rembourser ce montant"}</button></div>}</div>)}
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
                {adminDeletionRequests.map((request) => <article className="admin-quote-card" key={request.id}><div className="quote-row-heading"><h2>{request.client_name}</h2><span className="quote-status sent">En attente</span></div><p>{request.client_email}</p><p>{request.reason}</p><small>Demandée le {new Date(request.requested_at).toLocaleString(i18n.language)}</small><label className="cancellation-message">Réponse au client<textarea rows="3" value={adminDeletionMessages[request.id] || ""} onChange={(event) => setAdminDeletionMessages((current) => ({ ...current, [request.id]: event.target.value }))} placeholder="Décision motivée…" required /></label><div className="cancellation-admin-actions"><button className="primary-button" type="button" onClick={() => reviewAccountDeletion(request, "approved")} disabled={adminDeletionPendingId === request.id}>{adminDeletionPendingId === request.id ? "Traitement…" : "Approuver et désactiver"}</button><button className="document-button danger-button" type="button" onClick={() => reviewAccountDeletion(request, "rejected")} disabled={adminDeletionPendingId === request.id}>Refuser</button></div></article>)}
                {!adminDeletionRequests.length && <p className="invoice-empty">Aucune demande de suppression en attente.</p>}
              </div>
            </div>
            <div className="admin-booking-panel">
              <div className="playlist-heading"><div><h2>Clôturer les prestations</h2><p>Une clôture confirme la prestation réalisée et émet automatiquement la facture de solde.</p></div><Check /></div>
              <div className="admin-quote-grid">
                {bookingsToComplete.map((booking) => (
                  <article className="admin-quote-card" key={booking.id}>
                    <div className="quote-row-heading"><h2>Réservation n°{booking.id}</h2><span className="quote-status accepted">Confirmée</span></div>
                    <p><CalendarDays /> {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)} · {String(booking.start_time).slice(0, 5)}</p>
                    <p><FileText /> Montant total : <strong>{formatEuro(booking.total_amount)}</strong></p>
                    <button className="primary-button" type="button" onClick={() => completeAdminBooking(booking.id)} disabled={completionPendingId === booking.id}>{completionPendingId === booking.id ? "Clôture…" : "Marquer comme réalisée"}</button>
                  </article>
                ))}
                {!bookingsToComplete.length && <p className="invoice-empty">Aucune prestation confirmée à clôturer.</p>}
              </div>
            </div>
          </section>
  </LocalizedContent>;
}

