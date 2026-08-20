import { ChevronRight, Clock3, Headphones, Star } from "lucide-react";

import { formatEuro } from "../utils/booking";

export default function OffersPage({
  availableDjs,
  availableEventTypes,
  compatiblePackages,
  eventDate,
  eventType,
  location,
  onDateChange,
  onEventTypeChange,
  onLocationChange,
  onOpenDetail,
  onReset,
  publicAvailabilityStatus,
}) {
  return (
    <section className="section-wrap catalogue-page">
      <div className="page-heading">
        <p className="eyebrow dark">Offres & DJs</p>
        <h1>Trouvez la prestation qui vous ressemble</h1>
        <p>{eventType} · {eventDate.split("-").reverse().join("/")} · {location}</p>
      </div>
      <div className="catalogue-layout">
        <aside className="filters">
          <div className="filter-heading"><h2>Filtres</h2><button type="button" onClick={onReset}>Réinitialiser</button></div>
          <label>Type d’événement<select value={eventType} onChange={(event) => onEventTypeChange(event.target.value)}><option value="">Toutes les prestations</option>{availableEventTypes.map((type) => <option key={type}>{type}</option>)}</select></label>
          <label>Date<input type="date" value={eventDate} onChange={(event) => onDateChange(event.target.value)} /></label>
          <label>Lieu<input value={location} onChange={(event) => onLocationChange(event.target.value)} /></label>
          <label>Budget<select defaultValue="1500"><option value="700">Moins de 700 €</option><option value="1500">700 € – 1 500 €</option><option value="more">Plus de 1 500 €</option></select></label>
          <fieldset><legend>Services</legend><label className="check-row"><input type="checkbox" defaultChecked /> Sonorisation</label><label className="check-row"><input type="checkbox" defaultChecked /> Éclairage</label><label className="check-row"><input type="checkbox" /> Animation micro</label></fieldset>
        </aside>
        <div className="results">
          <div className="results-heading"><div><h2>DJs disponibles à {location}</h2><p>{availableDjs.length} résultat{availableDjs.length > 1 ? "s" : ""} · {publicAvailabilityStatus}</p></div></div>
          {compatiblePackages.length > 0 && availableDjs.map((dj, index) => {
            const item = compatiblePackages[index % compatiblePackages.length];
            return <article className="dj-card" key={dj.id}><div className={`dj-avatar avatar-${index + 1}`}><Headphones /></div><div className="dj-copy"><div className="dj-title"><h3>{dj.name}</h3><span><Star /> {dj.rating ? `${dj.rating} (${dj.reviews} avis)` : "Profil vérifié"}</span></div><p>{dj.styles}</p><p className="availability"><Clock3 /> Disponible {dj.slot}</p><strong>À partir de {formatEuro(item.base_price)}</strong></div><button className="primary-button" type="button" onClick={() => onOpenDetail(item, dj)}>Voir le détail <ChevronRight /></button></article>;
          })}
          {(!availableDjs.length || !compatiblePackages.length) && <p className="invoice-empty">{!compatiblePackages.length ? "Aucune formule compatible avec cette prestation." : "Modifiez la date pour rechercher un autre créneau."}</p>}
        </div>
      </div>
    </section>
  );
}
