import { useEffect, useMemo, useState } from "react";
import { AlertTriangle, Banknote, CalendarCheck, CalendarDays, ClipboardList, Headphones, RefreshCw, X } from "lucide-react";

import { getAdminDashboardMetrics, getDashboardBarWidth, getMonthlyPaymentSeries } from "../utils/adminDashboard";
import { formatEuro } from "../utils/booking";
import LocalizedContent from "./LocalizedContent";

const scrollToSection = (id) => document.getElementById(id)?.scrollIntoView({ behavior: "smooth", block: "start" });

export default function AdminDashboardOverview({ bookings, cancellationRequests, deletionRequests, djs, i18n, onRefresh, onSectionChange, payments, quotes }) {
  const [detail, setDetail] = useState("");
  const [refreshing, setRefreshing] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(new Date());
  const metrics = getAdminDashboardMetrics({ bookings, cancellationRequests, deletionRequests, djs, payments, quotes });
  const paymentSeries = useMemo(() => getMonthlyPaymentSeries(payments), [payments]);
  const chartMaximum = Math.max(...paymentSeries.map((period) => period.paid), 1);
  const activity = [
    { label: "Devis à traiter", value: metrics.pendingQuotes, tone: "cyan" },
    { label: "Réservations confirmées", value: metrics.confirmedBookings, tone: "pink" },
    { label: "Alertes à traiter", value: metrics.alerts, tone: "yellow" },
  ];
  const activityMaximum = Math.max(...activity.map((item) => item.value), 1);

  useEffect(() => {
    onSectionChange(detail || "overview");
  }, [detail, onSectionChange]);

  const refresh = async () => {
    setRefreshing(true);
    try {
      await onRefresh();
      setLastUpdated(new Date());
    } finally {
      setRefreshing(false);
    }
  };

  const openSection = (section, targetId) => {
    setDetail(section);
    onSectionChange(section);
    if (targetId) window.setTimeout(() => scrollToSection(targetId), 0);
  };

  const closeDetails = () => {
    setDetail("");
    onSectionChange("overview");
  };

  return <LocalizedContent><div className={`admin-dashboard detail-${detail || "overview"}`}>
    <div className="admin-dashboard-heading">
      <div><p className="eyebrow dark">Tableau de bord</p><h1>Vue d’ensemble de l’activité</h1><p>Suivez les demandes, les prestations et les encaissements d’Ultimate DJ.</p><small>Dernière mise à jour : {lastUpdated.toLocaleTimeString(i18n.language, { hour: "2-digit", minute: "2-digit" })}</small></div>
      <button className="secondary-button dashboard-refresh" type="button" onClick={refresh} disabled={refreshing}><RefreshCw className={refreshing ? "spinning" : ""} /> {refreshing ? "Actualisation…" : "Actualiser"}</button>
    </div>

    <div className="dashboard-kpi-grid">
      <button className="dashboard-kpi cyan" type="button" onClick={() => openSection("quotes", "admin-quotes")}><span><ClipboardList /></span><p>Devis à traiter</p><strong>{metrics.pendingQuotes}</strong><small>Afficher les demandes en attente</small></button>
      <button className="dashboard-kpi pink" type="button" onClick={() => openSection("upcoming", "dashboard-upcoming")}><span><CalendarCheck /></span><p>Prestations à venir</p><strong>{metrics.upcomingBookings.length}</strong><small>Afficher l’agenda des prestations</small></button>
      <button className="dashboard-kpi yellow" type="button" onClick={() => detail === "djs" ? closeDetails() : openSection("djs")} aria-expanded={detail === "djs"}><span><Headphones /></span><p>DJ disponibles</p><strong>{metrics.activeDjs}</strong><small>Afficher les profils confirmés</small></button>
      <button className="dashboard-kpi navy" type="button" onClick={() => detail === "finances" ? closeDetails() : openSection("finances")} aria-expanded={detail === "finances"}><span><Banknote /></span><p>Montant net encaissé</p><strong>{formatEuro(metrics.netRevenue)}</strong><small>Afficher les transactions</small></button>
    </div>

    {["quotes", "upcoming"].includes(detail) && <div className="dashboard-selection-banner"><span>{detail === "quotes" ? "Liste des devis à traiter" : "Agenda des prestations à venir"}</span><button type="button" onClick={closeDetails}><X /> Revenir à la vue d’ensemble</button></div>}

    {detail === "djs" && <section className="dashboard-detail" aria-label="Liste des DJ disponibles"><div className="dashboard-detail-heading"><div><p className="eyebrow dark">Équipe</p><h2>DJ confirmés</h2><p>Profils actuellement publiés et disponibles pour une affectation.</p></div><button type="button" onClick={() => setDetail("")} aria-label="Fermer"><X /></button></div><div className="dashboard-dj-grid">{djs.map((dj) => <article key={dj.id}><span><Headphones /></span><div><strong>{dj.stage_name}</strong><small>{dj.music_styles?.map((style) => style.name).join(", ") || "Styles non renseignés"}</small></div><dl><div><dt>Tarif horaire</dt><dd>{formatEuro(dj.base_hourly_rate)}</dd></div><div><dt>Expérience</dt><dd>{dj.years_experience ?? 0} an(s)</dd></div></dl></article>)}{!djs.length && <p className="invoice-empty">Aucun profil DJ confirmé.</p>}</div></section>}

    {detail === "finances" && <section className="dashboard-detail finance-detail" aria-label="Détail des finances"><div className="dashboard-detail-heading"><div><p className="eyebrow dark">Finances</p><h2>Historique des transactions</h2><p>Évolution des paiements enregistrés pendant les six derniers mois.</p></div><button type="button" onClick={() => setDetail("")} aria-label="Fermer"><X /></button></div><div className="finance-detail-layout"><div className="transaction-chart" aria-label="Graphique des paiements mensuels">{paymentSeries.map((period) => <div className="transaction-month" key={period.key}><div className="transaction-column"><span className="paid" style={{ height: `${getDashboardBarWidth(period.paid, chartMaximum)}%` }} title={`Payé : ${formatEuro(period.paid)}`} />{period.refunded > 0 && <span className="refunded" style={{ height: `${getDashboardBarWidth(period.refunded, chartMaximum)}%` }} title={`Remboursé : ${formatEuro(period.refunded)}`} />}</div><strong>{new Intl.DateTimeFormat(i18n.language, { month: "short" }).format(period.date)}</strong><small>{formatEuro(period.paid - period.refunded)}</small></div>)}</div><div className="transaction-list"><h3>Dernières transactions</h3>{payments.slice(0, 8).map((payment) => <div key={payment.id}><span><strong>Paiement n°{payment.id}</strong><small>{payment.paid_at ? new Date(payment.paid_at).toLocaleDateString(i18n.language) : "En attente"}</small></span><span><strong>{formatEuro(payment.amount)}</strong><small className={`transaction-status ${payment.status}`}>{payment.status === "paid" ? "Payé" : payment.status === "refunded" ? "Remboursé" : payment.status === "pending" ? "En attente" : "Échoué"}</small></span></div>)}{!payments.length && <p className="invoice-empty">Aucune transaction enregistrée.</p>}</div></div></section>}

    {detail === "activity" && <section className="dashboard-detail activity-detail" aria-label="Détail de l'activité"><div className="dashboard-detail-heading"><div><p className="eyebrow dark">Activité</p><h2>Dossiers nécessitant un suivi</h2><p>Retrouvez les demandes et prestations classées par priorité.</p></div><button type="button" onClick={() => setDetail("")} aria-label="Fermer"><X /></button></div><div className="activity-detail-grid"><article><div className="activity-detail-title"><span className="cyan"><ClipboardList /></span><div><h3>Devis à traiter</h3><strong>{quotes.length}</strong></div></div><div className="activity-records">{quotes.slice(0, 5).map((quote) => <div key={quote.id}><span>Devis n°{quote.id}</span><strong>{formatEuro(quote.total_amount)}</strong></div>)}{!quotes.length && <small>Aucun devis en attente.</small>}</div><button className="document-button" type="button" onClick={() => scrollToSection("admin-quotes")}>Voir tous les devis</button></article><article><div className="activity-detail-title"><span className="pink"><CalendarCheck /></span><div><h3>Réservations confirmées</h3><strong>{metrics.confirmedBookings}</strong></div></div><div className="activity-records">{bookings.filter((booking) => booking.status === "confirmed").slice(0, 5).map((booking) => <div key={booking.id}><span>Réservation n°{booking.id}</span><strong>{new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language)}</strong></div>)}{!metrics.confirmedBookings && <small>Aucune réservation confirmée.</small>}</div><button className="document-button" type="button" onClick={() => scrollToSection("dashboard-upcoming")}>Voir l’agenda</button></article><article><div className="activity-detail-title"><span className="yellow"><AlertTriangle /></span><div><h3>Alertes à traiter</h3><strong>{metrics.alerts}</strong></div></div><div className="activity-records"><div><span>Demandes d’annulation</span><strong>{cancellationRequests.length}</strong></div><div><span>Suppressions de compte</span><strong>{deletionRequests.length}</strong></div>{!metrics.alerts && <small>Aucune alerte en attente.</small>}</div></article></div></section>}

    <div className="dashboard-panels">
      <button className="dashboard-panel activity-panel activity-summary-button" type="button" onClick={() => setDetail("activity")}><div className="dashboard-panel-heading"><div><p className="eyebrow dark">Activité</p><h2>État des dossiers</h2></div><ClipboardList /></div><div className="dashboard-bars">{activity.map((item) => <div className="dashboard-bar-row" key={item.label}><div><span>{item.label}</span><strong>{item.value}</strong></div><div className="dashboard-bar-track"><span className={item.tone} style={{ width: `${getDashboardBarWidth(item.value, activityMaximum)}%` }} /></div></div>)}</div><div className={`dashboard-alert${metrics.alerts ? " active" : ""}`}><AlertTriangle /><span>{metrics.alerts ? `${metrics.alerts} demande(s) sensible(s) requièrent votre attention.` : "Aucune demande sensible en attente."}</span></div><small className="activity-open-hint">Afficher le détail de l’activité</small></button>
      <button className="dashboard-panel finance-panel finance-summary-button" type="button" onClick={() => setDetail("finances")}><div className="dashboard-panel-heading"><div><p className="eyebrow dark">Finances</p><h2>Encaissements enregistrés</h2></div><Banknote /></div><div className="finance-total"><span>Montant net</span><strong>{formatEuro(metrics.netRevenue)}</strong></div><dl className="finance-breakdown"><div><dt>Montant brut payé</dt><dd>{formatEuro(metrics.grossRevenue)}</dd></div><div><dt>Remboursements</dt><dd>{formatEuro(metrics.refundedRevenue)}</dd></div><div><dt>Paiements en attente</dt><dd>{metrics.pendingPayments}</dd></div></dl><small className="finance-open-hint">Voir le graphique et les transactions</small></button>
    </div>

    <article className="dashboard-panel upcoming-panel" id="dashboard-upcoming"><div className="dashboard-panel-heading"><div><p className="eyebrow dark">Agenda</p><h2>Prochaines prestations</h2></div><CalendarDays /></div><div className="dashboard-event-list">{metrics.upcomingBookings.slice(0, 8).map((booking) => <div className="dashboard-event" key={booking.id}><time dateTime={booking.event_date}><strong>{new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language, { day: "2-digit" })}</strong><span>{new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language, { month: "short" })}</span></time><div><strong>Réservation n°{booking.id}</strong><span>{String(booking.start_time).slice(0, 5)} · {formatEuro(booking.total_amount)}</span></div><span className="quote-status accepted">Confirmée</span></div>)}{!metrics.upcomingBookings.length && <p className="invoice-empty">Aucune prestation confirmée à venir.</p>}</div></article>
  </div></LocalizedContent>;
}
