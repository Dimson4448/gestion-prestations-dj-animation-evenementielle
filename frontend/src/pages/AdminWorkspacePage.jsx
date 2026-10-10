import { CalendarDays, Check, ChevronDown, CircleUserRound, Clock3, FileText } from "lucide-react";
import { useCallback, useState } from "react";
import { useTranslation } from "react-i18next";

import { formatEuro, hasBookingEnded } from "../utils/booking";
import { toLocalIsoDate } from "../utils/dates";
import LocalizedContent from "../components/LocalizedContent";
import AdminDashboardOverview from "../components/AdminDashboardOverview";
import BookingMessages from "../components/BookingMessages";
import { apiClient } from "../api";

export default function AdminWorkspacePage({ workspace }) {
  const { t } = useTranslation();
  const [selectedSection, setSelectedSection] = useState("overview");
  const [quoteHistoryOpen, setQuoteHistoryOpen] = useState(false);
  const [exportStatus, setExportStatus] = useState("");
  const [exportPending, setExportPending] = useState("");
  const [reviewModerationStatus, setReviewModerationStatus] = useState("");
  const [reviewModerationPendingId, setReviewModerationPendingId] = useState(null);
  const selectSection = useCallback((section) => setSelectedSection(section), []);
  const {
    acceptAdminQuote, adminBookings, adminCancellationMessages, adminCancellationPendingId,
    adminCancellationRequests, adminDeletionMessages, adminDeletionPendingId, adminDeletionRequests,
    adminAllQuotes, adminDjs, adminDjSelection, adminPayments, adminPendingId, adminQuotes, adminReviews, adminStatus,
    approveCancellation, completeAdminBooking, completionPendingId, eventTypeRecords, i18n,
    loadAdminDashboard, packages, quoteStatusLabels, refundAmounts, refundCancellationPayment,
    refundPendingId, rejectCancellation, reviewAccountDeletion, sendQuote, setAdminCancellationMessages,
    setAdminDeletionMessages, setAdminDjSelection, setRefundAmounts,
  } = workspace;
  const todayIso = toLocalIsoDate(new Date());
  const activeAdminQuotes = adminQuotes.filter((quote) => quote.event_date >= todayIso);
  const historicalAdminQuotes = adminQuotes.filter((quote) => quote.event_date < todayIso);
  const bookingsToComplete = adminBookings.filter((item) => item.status === "confirmed" && item.deposit_paid);
  const reportedReviews = adminReviews.filter((review) => review.reported_at && review.status === "pending");
  const downloadExport = async (resource) => {
    setExportPending(resource);
    setExportStatus("");
    try {
      const response = await apiClient.get(`/administration/exports/${resource}.csv`, { responseType: "blob" });
      const url = URL.createObjectURL(response.data);
      const link = document.createElement("a");
      link.href = url;
      link.download = `ultimate-dj-${resource}.csv`;
      link.click();
      URL.revokeObjectURL(url);
      setExportStatus(t("adminExports.success"));
    } catch {
      setExportStatus(t("adminExports.error"));
    } finally {
      setExportPending("");
    }
  };
  const moderateReview = async (reviewId, status) => {
    setReviewModerationPendingId(reviewId);
    setReviewModerationStatus("");
    try {
      await apiClient.patch(`/reviews/${reviewId}/`, { status });
      await loadAdminDashboard();
      setReviewModerationStatus(t("reviewModeration.success"));
    } catch {
      setReviewModerationStatus(t("reviewModeration.error"));
    } finally {
      setReviewModerationPendingId(null);
    }
  };
  return <LocalizedContent>
          <section className={`section-wrap admin-page admin-view-${selectedSection}`}>
            <AdminDashboardOverview allQuotes={adminAllQuotes} bookings={adminBookings} cancellationRequests={adminCancellationRequests} deletionRequests={adminDeletionRequests} djs={adminDjs} i18n={i18n} onRefresh={loadAdminDashboard} onSectionChange={selectSection} payments={adminPayments} quotes={activeAdminQuotes} reviews={adminReviews} />
            <div className="admin-booking-panel completion-panel">
              <div className="playlist-heading"><div><h2>Clôturer les prestations</h2><p>La clôture crée automatiquement la facture de solde. Pour une démonstration, l’administrateur peut exceptionnellement clôturer avant la date prévue.</p></div><Check /></div>
              <div className="admin-quote-grid">
                {bookingsToComplete.map((booking) => (
                  <article className="admin-quote-card" key={booking.id}>
                    <div className="quote-row-heading"><h2>Réservation n°{booking.id}</h2><span className="quote-status accepted">Confirmée</span></div>
                    <p><CalendarDays /> {new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)} · {String(booking.start_time).slice(0, 5)}</p>
                    <p><FileText /> Montant total : <strong>{formatEuro(booking.total_amount)}</strong></p>
                    <button className="primary-button" type="button" onClick={() => completeAdminBooking(booking.id, !hasBookingEnded(booking))} disabled={completionPendingId === booking.id}>{completionPendingId === booking.id ? "Clôture…" : hasBookingEnded(booking) ? "Marquer comme réalisée" : "Clôturer (démo)"}</button>
                  </article>
                ))}
                {!bookingsToComplete.length && <p className="invoice-empty">Aucune prestation confirmée à clôturer.</p>}
              </div>
            </div>
            <div className="page-heading" id="admin-quotes"><p className="eyebrow dark">Espace administrateur</p><h1>Traiter les demandes de devis</h1><p>Envoyez le devis au client, choisissez un DJ réellement disponible, puis créez automatiquement la réservation, le contrat et la facture d’acompte.</p></div>
            <div className="admin-toolbar"><div><strong>{activeAdminQuotes.length}</strong><span> devis à traiter</span></div><button className="secondary-button" type="button" onClick={loadAdminDashboard}>Actualiser</button></div>
            <section className="admin-exports" aria-labelledby="admin-exports-title"><div><h2 id="admin-exports-title">{t("adminExports.title")}</h2><p>{t("adminExports.intro")}</p></div><div>{["quotes", "bookings", "payments", "reviews"].map((resource) => <button className="document-button" type="button" key={resource} onClick={() => downloadExport(resource)} disabled={exportPending === resource}>{exportPending === resource ? t("adminExports.preparing") : t(`adminExports.${resource}`)}</button>)}</div>{exportStatus && <p className="form-message success" role="status">{exportStatus}</p>}</section>
            <section className="review-moderation" aria-labelledby="review-moderation-title"><div className="playlist-heading"><div><h2 id="review-moderation-title">{t("reviewModeration.title")}</h2><p>{t("reviewModeration.intro")}</p></div><FileText /></div>{reviewModerationStatus && <p className="form-message success" role="status">{reviewModerationStatus}</p>}<div className="admin-quote-grid">{reportedReviews.map((review) => <article className="admin-quote-card" key={review.id}><div className="quote-row-heading"><h2>{t("reviewModeration.review", { id: review.id })}</h2><span className="quote-status sent">{t("reviewModeration.reported")}</span></div><p>{"★".repeat(review.rating)}{"☆".repeat(5 - review.rating)} — {review.comment}</p><small><strong>{t("reviewModeration.reason")}</strong> {review.report_reason}</small><div className="cancellation-admin-actions"><button className="primary-button" type="button" disabled={reviewModerationPendingId === review.id} onClick={() => moderateReview(review.id, "published")}>{t("reviewModeration.publish")}</button><button className="document-button danger-button" type="button" disabled={reviewModerationPendingId === review.id} onClick={() => moderateReview(review.id, "rejected")}>{t("reviewModeration.remove")}</button></div></article>)}{!reportedReviews.length && <p className="invoice-empty">{t("reviewModeration.empty")}</p>}</div></section>
            {adminStatus && <p className={adminStatus.includes("créés") || adminStatus.includes("prêt") || adminStatus.includes("clôturée") || adminStatus.includes("refusée") || adminStatus.includes("remboursé") || adminStatus.includes("annulée") ? "form-message success" : "form-message"} role="status">{adminStatus}</p>}
            <div className="admin-quote-grid">
              {activeAdminQuotes.map((item) => {
                const itemPackage = packages.find((entry) => String(entry.id) === String(item.package));
                const itemEventType = eventTypeRecords.find((entry) => String(entry.id) === String(item.event_type));
                return (
                  <article className="admin-quote-card" key={item.id}>
                    <div className="quote-row-heading"><h2>Devis n°{item.id}</h2><span className={`quote-status ${item.status}`}>{quoteStatusLabels[item.status]}</span></div>
                    <p><CalendarDays /> {itemEventType?.name || "Événement"} · {new Date(`${item.event_date}T00:00:00`).toLocaleDateString(i18n.language)} à {String(item.start_time).slice(0, 5)}</p>
                    <p><Clock3 /> {item.duration_hours} heures · {item.guest_count} invités</p>
                    <p><FileText /> {itemPackage?.name || `Formule n°${item.package}`} · <strong>{formatEuro(item.total_amount)}</strong></p>
                    {item.client_details && <div className="dj-client-details"><strong>{item.client_details.first_name} {item.client_details.last_name}</strong><a href={`tel:${item.client_details.phone.replace(/\s/g, "")}`}>{item.client_details.phone}</a><a href={`mailto:${item.client_details.email}`}>{item.client_details.email}</a></div>}
                    {item.status === "draft" ? (
                      <div className="admin-acceptance">
                        {item.requested_dj && item.dj_decision !== "refused" ? <p className="admin-dj-request">DJ demandé par le client : <strong>{adminDjs.find((dj) => String(dj.id) === String(item.requested_dj))?.stage_name || "DJ sélectionné"}</strong></p> : <label>DJ à proposer<select value={adminDjSelection[item.id] || ""} onChange={(event) => setAdminDjSelection((current) => ({ ...current, [item.id]: event.target.value }))}><option value="">Sélectionner un DJ</option>{adminDjs.map((dj) => <option value={dj.id} key={dj.id}>{dj.stage_name}</option>)}</select></label>}
                        {item.dj_decision === "refused" && <p className="admin-dj-request warning">Le DJ initial a refusé : choisissez un autre DJ avant de transmettre à nouveau la demande.</p>}
                        <button className="primary-button" type="button" onClick={() => sendQuote(item.id, item.dj_decision === "refused" ? adminDjSelection[item.id] : (item.requested_dj || adminDjSelection[item.id]))} disabled={adminPendingId === item.id}>{adminPendingId === item.id ? "Traitement…" : "Valider et transmettre au DJ"}</button>
                      </div>
                    ) : (
                      <p className="admin-dj-request">Transmis à <strong>{adminDjs.find((dj) => String(dj.id) === String(item.requested_dj))?.stage_name || "le DJ sélectionné"}</strong> : en attente de sa réponse.</p>
                    )}
                  </article>
                );
              })}
              {!adminStatus && !activeAdminQuotes.length && <p className="invoice-empty">Aucun devis en attente de traitement.</p>}
            </div>
            {!!historicalAdminQuotes.length && <section className="admin-quote-history">
              <button className="dj-panel-trigger" type="button" aria-expanded={quoteHistoryOpen} aria-controls="admin-quote-history" onClick={() => setQuoteHistoryOpen((current) => !current)}>
                <span><Clock3 /><span><strong>Historique des devis</strong><small>Les événements passés sont conservés pour consultation et ne peuvent plus être traités.</small></span></span>
                <span className="dj-panel-count">{historicalAdminQuotes.length}</span><ChevronDown className={quoteHistoryOpen ? "open" : ""} />
              </button>
              {quoteHistoryOpen && <div className="admin-quote-grid" id="admin-quote-history">
                {historicalAdminQuotes.map((item) => {
                  const itemPackage = packages.find((entry) => String(entry.id) === String(item.package));
                  const itemEventType = eventTypeRecords.find((entry) => String(entry.id) === String(item.event_type));
                  return <article className="admin-quote-card history-card" key={item.id}>
                    <div className="quote-row-heading"><h2>Devis n°{item.id}</h2><span className="quote-status expired">Archivé</span></div>
                    <p><CalendarDays /> {itemEventType?.name || "Événement"} · {new Date(`${item.event_date}T00:00:00`).toLocaleDateString(i18n.language)} à {String(item.start_time).slice(0, 5)}</p>
                    <p><Clock3 /> {item.duration_hours} heures · {item.guest_count} invités</p>
                    <p><FileText /> {itemPackage?.name || `Formule n°${item.package}`} · <strong>{formatEuro(item.total_amount)}</strong></p>
                    <small>Ce devis est archivé car la date de l’événement est passée.</small>
                  </article>;
                })}
              </div>}
            </section>}
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
                {adminDeletionRequests.map((request) => {
                  const reviewMessage = adminDeletionMessages[request.id] || "";
                  const canReview = Boolean(reviewMessage.trim());
                  const isPending = adminDeletionPendingId === request.id;
                  return <article className="admin-quote-card" key={request.id}><div className="quote-row-heading"><h2>{request.client_name}</h2><span className="quote-status sent">En attente</span></div><p>{request.client_email}</p><p>{request.reason}</p><small>Demandée le {new Date(request.requested_at).toLocaleString(i18n.language)}</small><label className="cancellation-message">Réponse au client<textarea rows="3" value={reviewMessage} onChange={(event) => setAdminDeletionMessages((current) => ({ ...current, [request.id]: event.target.value }))} placeholder="Décision motivée…" required /></label><small>Une courte réponse est requise.</small><div className="cancellation-admin-actions"><button className="primary-button" type="button" onClick={() => reviewAccountDeletion(request, "approved")} disabled={isPending || !canReview}>{isPending ? "Traitement…" : "Approuver et désactiver"}</button><button className="document-button danger-button" type="button" onClick={() => reviewAccountDeletion(request, "rejected")} disabled={isPending || !canReview}>Refuser</button></div></article>;
                })}
                {!adminDeletionRequests.length && <p className="invoice-empty">Aucune demande de suppression en attente.</p>}
              </div>
            </div>
            <BookingMessages bookings={adminBookings} allowEmail />
          </section>
  </LocalizedContent>;
}

