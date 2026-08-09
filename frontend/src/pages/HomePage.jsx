import { CalendarDays, Check, ChevronRight, Clock3, Headphones, Music2, Search, ShieldCheck, Star } from "lucide-react";

import { formatEuro } from "../utils/booking";

const journeySteps = [
  "Décrivez votre événement",
  "Choisissez l’offre et le DJ",
  "Validez devis et contrat",
  "Payez l’acompte",
  "Préparez votre playlist",
];

export default function HomePage({
  availableEventTypes,
  eventDate,
  eventType,
  location,
  onEventDateChange,
  onEventTypeChange,
  onLocationChange,
  onNavigate,
  onOpenDetail,
  packages,
}) {
  return (
    <>
      <section className="hero">
        <div className="hero-content">
          <p className="eyebrow">Votre événement, votre ambiance</p>
          <h1>Réservez le DJ parfait.</h1>
          <p className="hero-lead">Devis, contrat, acompte et playlist réunis dans un parcours simple et sécurisé.</p>
          <form className="quick-search" onSubmit={(event) => { event.preventDefault(); onNavigate("offres"); }}>
            <label><span>Événement</span><select value={eventType} onChange={(event) => onEventTypeChange(event.target.value)}>{availableEventTypes.map((type) => <option key={type}>{type}</option>)}</select></label>
            <label><span>Date</span><input type="date" value={eventDate} min={new Date().toISOString().slice(0, 10)} onChange={(event) => onEventDateChange(event.target.value)} /></label>
            <label><span>Lieu</span><input value={location} onChange={(event) => onLocationChange(event.target.value)} /></label>
            <button className="primary-button" type="submit"><Search aria-hidden="true" /> Trouver un DJ</button>
          </form>
          <p className="search-note"><Check aria-hidden="true" /> Disponibilités vérifiées avant confirmation</p>
        </div>
      </section>

      <section className="trust-strip" aria-label="Nos garanties">
        <article><CalendarDays /><div><strong>Créneaux vérifiés</strong><span>Une disponibilité claire, sans mauvaise surprise.</span></div></article>
        <article><ShieldCheck /><div><strong>Acompte sécurisé</strong><span>Le paiement confirme et bloque votre créneau.</span></div></article>
        <article><Music2 /><div><strong>Playlist client</strong><span>Vos styles et chansons réunis avec le DJ.</span></div></article>
      </section>

      <section className="section-wrap">
        <div className="section-title"><div><p className="eyebrow dark">Des offres adaptées</p><h2>Choisissez votre formule</h2></div><button className="text-link" type="button" onClick={() => onNavigate("offres")}>Voir toutes les offres <ChevronRight /></button></div>
        <div className="package-grid">
          {packages.slice(0, 3).map((item) => (
            <article className={`package-card ${item.accent || "cyan"}`} key={item.id}>
              <div className="card-icon"><Headphones /></div><p className="card-kicker">{item.event || "Prestation DJ"}</p><h3>{item.name}</h3><p>{item.description}</p>
              <div className="card-meta"><span><Clock3 /> {Number(item.included_hours).toLocaleString("fr-BE")} h</span><span><Star /> {item.rating || "4,8"}</span></div>
              <div className="card-footer"><div><small>À partir de</small><strong>{formatEuro(item.base_price)}</strong></div><button type="button" onClick={() => onOpenDetail(item)}>Découvrir <ChevronRight /></button></div>
            </article>
          ))}
        </div>
      </section>

      <section className="journey-section">
        <p className="eyebrow">Un parcours guidé</p><h2>De votre idée à la piste de danse</h2>
        <ol className="journey-list">{journeySteps.map((step, index) => <li key={step}><span>{index + 1}</span><strong>{step}</strong></li>)}</ol>
      </section>
    </>
  );
}
