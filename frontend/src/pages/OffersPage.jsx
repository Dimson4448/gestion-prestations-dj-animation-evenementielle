import { ChevronRight, Clock3, Headphones, ListMusic, MessageSquareQuote, Star } from "lucide-react";

import { formatEuro } from "../utils/booking";
import LocalizedContent from "../components/LocalizedContent";

export default function OffersPage({
  availableDjs,
  catalogueDjs,
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
  publicPlaylists,
  publicReviews,
}) {
  const availableById = new Map(availableDjs.map((dj) => [dj.id, dj]));

  return <LocalizedContent>
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
          {compatiblePackages.length > 0 && catalogueDjs.map((profile, index) => {
            const availableDj = availableById.get(profile.id);
            const dj = availableDj || {
              id: profile.id,
              name: profile.stage_name,
              rating: profile.average_rating,
              reviews: profile.review_count,
              slot: "Consultez ses prochaines disponibilités",
              styles: profile.music_styles?.map((style) => style.name).join(" · ") || "Styles à préciser",
            };
            const item = compatiblePackages[index % compatiblePackages.length];
            return <article className="dj-card" key={dj.id}><div className={`dj-avatar avatar-${(index % 3) + 1}`}><Headphones /></div><div className="dj-copy"><div className="dj-title"><h3>{dj.name}</h3><span><Star /> {dj.rating ? `${Number(dj.rating).toFixed(1)} (${dj.reviews} avis)` : "Profil vérifié"}</span></div><p>{dj.styles}</p><p className="availability"><Clock3 /> {availableDj ? `Disponible ${dj.slot}` : dj.slot}</p><strong>À partir de {formatEuro(item.base_price)}</strong></div><button className="primary-button" type="button" onClick={() => onOpenDetail(item, dj)}>Voir le détail <ChevronRight /></button></article>;
          })}
          {(!catalogueDjs.length || !compatiblePackages.length) && <p className="invoice-empty">{!compatiblePackages.length ? "Aucune formule compatible avec cette prestation." : "Aucun DJ n’est actuellement publié dans le catalogue."}</p>}
        </div>
      </div>
      <section className="public-showcase" aria-labelledby="playlist-showcase-title">
        <div className="showcase-heading"><div><p className="eyebrow dark">Ambiances musicales</p><h2 id="playlist-showcase-title">Playlists de nos événements</h2></div><ListMusic /></div>
        <div className="public-card-grid">
          {publicPlaylists.map((playlist) => <article className="public-playlist-card" key={playlist.id}><span className="public-card-icon"><ListMusic /></span><p className="eyebrow dark">Playlist de {playlist.dj_stage_name}</p><h3>{playlist.styles.map((style) => style.name).join(" · ") || "Ambiance personnalisée"}</h3>{playlist.songs.length ? <ul>{playlist.songs.slice(0, 5).map((song) => <li key={`${playlist.id}-${song.title}-${song.artist}`}><strong>{song.title}</strong><span>{song.artist}</span></li>)}</ul> : <p>La sélection musicale est en préparation.</p>}</article>)}
          {!publicPlaylists.length && <p className="invoice-empty">Les premières playlists publiques apparaîtront ici.</p>}
        </div>
      </section>
      <section className="public-showcase reviews-showcase" aria-labelledby="reviews-showcase-title">
        <div className="showcase-heading"><div><p className="eyebrow dark">Avis clients</p><h2 id="reviews-showcase-title">Leurs expériences avec Ultimate DJ</h2></div><MessageSquareQuote /></div>
        <div className="public-card-grid">
          {publicReviews.map((review) => <article className="public-review-card" key={review.id}><div className="review-stars" aria-label={`${review.rating} étoiles`}>{"★".repeat(review.rating)}{"☆".repeat(5 - review.rating)}</div><blockquote>“{review.comment}”</blockquote><p><strong>{review.client_first_name}</strong><span>avec {review.dj_stage_name}</span></p></article>)}
          {!publicReviews.length && <p className="invoice-empty">Aucun avis public pour le moment.</p>}
        </div>
      </section>
    </section>
  </LocalizedContent>;
}
