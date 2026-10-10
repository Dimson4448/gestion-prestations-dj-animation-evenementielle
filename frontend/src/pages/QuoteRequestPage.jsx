import { CalendarDays, Check, ChevronRight, FileText, MapPin, ShieldCheck, UsersRound } from "lucide-react";
import { useState } from "react";
import { formatEuro } from "../utils/booking";
import LocalizedContent from "../components/LocalizedContent";

const todayIso = new Date().toISOString().slice(0, 10);
const DJ_FREE_MUSIC_CHOICE = "Carte blanche au DJ";
const normalizeMusicStyle = (value) => value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase();

export default function QuoteRequestPage({ form }) {
  const [musicStyleQuery, setMusicStyleQuery] = useState("");
  const [musicStyleMenuOpen, setMusicStyleMenuOpen] = useState(false);
  const {
    availableEventTypes, availableSlots, compatiblePackages, createdQuote, distanceKm, durationHours,
    eventDate, eventType, guestCount, location, musicPreferences, musicStyles, navigate, parking, quote,
    quotePending, quoteStatus, quoteSubmitted, selectVenue, selectedPackage, selectedPackageId,
    selectedVenueId, setDistanceKm, setDurationHours, setEventDate, setEventType, setGuestCount,
    setLocation, setMusicPreferences, setParking, setSelectedPackageId, setStartTime, setVenueCountry,
    setVenueName, setVenuePostalCode, setVenueStreet, startTime, submitQuote, venueCountry, venueName,
    venuePostalCode, venues, venueStatus, venueStreet, isQuoteSimulator,
  } = form;
  const selectedMusicStyleNames = musicPreferences.split(",").map((value) => value.trim()).filter(Boolean);
  const isDjFreeToChooseMusic = musicPreferences.trim() === DJ_FREE_MUSIC_CHOICE;
  const isMusicStyleSelected = (styleName) => selectedMusicStyleNames.some((value) => value.toLocaleLowerCase() === styleName.toLocaleLowerCase());
  const toggleMusicStyle = (styleName) => {
    if (!styleName) return;
    setMusicPreferences((isMusicStyleSelected(styleName)
      ? selectedMusicStyleNames.filter((value) => value.toLocaleLowerCase() !== styleName.toLocaleLowerCase())
      : [...selectedMusicStyleNames, styleName]).join(", "));
  };
  const availableMusicStyles = musicStyles.filter((style) => !isMusicStyleSelected(style.name));
  const filteredMusicStyles = availableMusicStyles.filter((style) => (
    !musicStyleQuery || normalizeMusicStyle(style.name).startsWith(normalizeMusicStyle(musicStyleQuery))
  ));
  const availableDjSlots = availableSlots.filter((slot) => slot.status === "available" && slot.available_date === eventDate);

  return <LocalizedContent>
    <section className="section-wrap quote-page">
      <div className="page-heading"><p className="eyebrow dark">{isQuoteSimulator ? "Simulateur de devis" : "Demande de devis"}</p><h1>{isQuoteSimulator ? "Estimez votre événement en toute liberté" : "Parlez-nous de votre événement"}</h1>{isQuoteSimulator && <p>Modifiez vos choix : l'estimation se met à jour immédiatement, sans compte ni envoi de demande.</p>}</div>
      {!quoteSubmitted ? <div className="quote-layout"><form className="quote-form" onSubmit={(event) => { if (isQuoteSimulator) event.preventDefault(); else submitQuote(event); }}>
        <fieldset><legend><span>1</span> Votre événement</legend><div className="form-grid">
          <label>Type d’événement<select value={eventType} onChange={(event) => setEventType(event.target.value)} required>{availableEventTypes.map((type) => <option key={type}>{type}</option>)}</select></label>
          <label>Date<input type="date" value={eventDate} min={todayIso} onChange={(event) => setEventDate(event.target.value)} required /></label>
          <label>Heure de début<input type="time" value={startTime} onChange={(event) => setStartTime(event.target.value)} required /></label>
          <p className="full-field quote-carried-data"><Check /> Informations reprises depuis votre recherche : <strong>{eventType}</strong>, le <strong>{eventDate.split("-").reverse().join("/")}</strong>{location ? <> à <strong>{location}</strong></> : null}. Vous pouvez les modifier si nécessaire.</p>
          {!isQuoteSimulator && <label className="full-field">Lieu enregistré<select value={selectedVenueId} onChange={(event) => selectVenue(event.target.value)}><option value="new">Utiliser une nouvelle adresse</option>{venues.map((venue) => <option value={venue.id} key={venue.id}>{venue.name} — {venue.city}</option>)}</select></label>}
          {(isQuoteSimulator || selectedVenueId === "new") && <><p className="full-field venue-completion-note">Complétez uniquement l’adresse précise du lieu. Elle est nécessaire pour préparer la prestation et calculer le déplacement ; elle sera enregistrée automatiquement à l’envoi de la demande.</p><label>Nom du lieu<input value={venueName} onChange={(event) => setVenueName(event.target.value)} required={!isQuoteSimulator} /></label><label>Rue et numéro<input value={venueStreet} onChange={(event) => setVenueStreet(event.target.value)} required={!isQuoteSimulator} /></label><label>Code postal<input value={venuePostalCode} onChange={(event) => setVenuePostalCode(event.target.value)} required={!isQuoteSimulator} /></label><label>Ville<input value={location} onChange={(event) => setLocation(event.target.value)} required={!isQuoteSimulator} /></label><label>Pays<input value={venueCountry} onChange={(event) => setVenueCountry(event.target.value)} required={!isQuoteSimulator} /></label></>}
          {venueStatus && <p className={`venue-message full-field ${venueStatus.startsWith("Lieu enregistré") ? "success" : ""}`} role="status">{venueStatus}</p>}
          <label>Nombre d’invités<input type="number" min="1" value={guestCount} onChange={(event) => setGuestCount(event.target.value)} required /></label><label>Durée prévue (heures)<input type="number" min="1" step="0.5" value={durationHours} onChange={(event) => setDurationHours(event.target.value)} required /></label><label>Parking disponible ?<select value={parking} onChange={(event) => setParking(event.target.value)}><option value="oui">Oui</option><option value="non">Non</option><option value="inconnu">À vérifier</option></select></label>
        </div></fieldset>
        <fieldset><legend><span>2</span> Offre et préférences</legend><div className="form-grid">
          <label>Formule<select value={selectedPackageId} onChange={(event) => setSelectedPackageId(event.target.value)}>{compatiblePackages.map((item) => <option value={item.id} key={item.id}>{item.name}</option>)}</select></label><label>Distance estimée (km)<input type="number" min="0" value={distanceKm} onChange={(event) => setDistanceKm(event.target.value)} /></label>
          <div className="full-field dj-free-music-choice"><div><strong>Laissez le DJ choisir l’ambiance</strong><p>Choisissez cette option si vous ne souhaitez imposer aucun style musical.</p></div><button className={isDjFreeToChooseMusic ? "selected" : "secondary-button"} type="button" onClick={() => { setMusicPreferences(isDjFreeToChooseMusic ? "" : DJ_FREE_MUSIC_CHOICE); setMusicStyleQuery(""); setMusicStyleMenuOpen(false); }}>{isDjFreeToChooseMusic ? "Carte blanche au DJ ✓" : "Carte blanche au DJ"}</button></div>
          {!isDjFreeToChooseMusic && <div className="full-field music-style-picker"><label>Sélectionnez un ou plusieurs styles<input value={musicStyleQuery} onFocus={() => setMusicStyleMenuOpen(true)} onChange={(event) => { setMusicStyleQuery(event.target.value); setMusicStyleMenuOpen(true); }} onKeyDown={(event) => event.key === "Escape" && setMusicStyleMenuOpen(false)} placeholder="Ajouter un style musical…" aria-controls="music-style-suggestions" aria-expanded={musicStyleMenuOpen} /></label>{musicStyleMenuOpen && <div className="music-style-suggestions" id="music-style-suggestions">{filteredMusicStyles.map((style) => <button type="button" key={style.id} onMouseDown={(event) => event.preventDefault()} onClick={() => { toggleMusicStyle(style.name); setMusicStyleQuery(""); setMusicStyleMenuOpen(false); }}>{style.name}</button>)}{!filteredMusicStyles.length && <p>Aucun style trouvé.</p>}</div>}{selectedMusicStyleNames.length > 0 && <div className="selected-music-styles">{selectedMusicStyleNames.map((styleName) => <button className="selected" type="button" key={styleName} onClick={() => toggleMusicStyle(styleName)} title={`Retirer ${styleName}`}>{styleName} ×</button>)}</div>}</div>}
          <label className="full-field">Préférences musicales<textarea rows="4" value={musicPreferences} onChange={(event) => setMusicPreferences(event.target.value)} placeholder="Styles, chansons souhaitées ou à éviter…" /></label>
        </div></fieldset>
        <section className="quote-dj-availability" aria-labelledby="quote-dj-availability-title"><div><p className="eyebrow dark">Disponibilités</p><h2 id="quote-dj-availability-title">DJs disponibles le {eventDate.split("-").reverse().join("/")}</h2><p>Ces créneaux sont déclarés par les DJs et seront confirmés lors du traitement du devis.</p></div>{availableDjSlots.length ? <div className="quote-dj-slots">{availableDjSlots.map((slot) => <article key={slot.id}><strong>{slot.dj.stage_name}</strong><span>{String(slot.start_time).slice(0, 5)} – {String(slot.end_time).slice(0, 5)}</span><small>{slot.dj.music_styles?.map((style) => style.name).join(" · ") || "Styles à préciser"}</small></article>)}</div> : <p className="invoice-empty">Aucun créneau déclaré disponible à cette date pour le moment.</p>}</section>
        {quoteStatus && !isQuoteSimulator && <p className="form-message" role="alert">{quoteStatus}</p>}{isQuoteSimulator ? <p className="quote-simulator-note"><Check /> Simulation instantanée : aucun devis n'est enregistré ni envoyé.</p> : <button className="primary-button submit-quote" type="submit" disabled={quotePending}>{quotePending ? "Enregistrement…" : "Soumettre la demande"} <ChevronRight /></button>}
      </form><aside className="quote-summary"><p className="eyebrow dark">Estimation</p><h2>{selectedPackage?.name}</h2><dl><div><dt>Prestation</dt><dd>{formatEuro(quote.subtotal)}</dd></div><div><dt>Déplacement estimé</dt><dd>{formatEuro(quote.travel)}</dd></div><div className="quote-total"><dt>Total indicatif</dt><dd>{formatEuro(quote.total)}</dd></div><div><dt>Acompte proposé (30 %)</dt><dd>{formatEuro(quote.deposit)}</dd></div></dl><p><ShieldCheck /> {isQuoteSimulator ? "Ce calcul indicatif varie immédiatement selon la formule, la durée, le type d'événement et la distance choisis." : "Cette estimation sera vérifiée par l’administrateur/DJ avant l’envoi du devis."}</p></aside></div> : <div className="confirmation-card"><div className="confirmation-icon"><Check /></div><p className="eyebrow dark">Demande enregistrée</p><h2>Votre devis n°{createdQuote?.id} a bien été créé.</h2><p>Statut : <strong>Brouillon — vérification administrative en attente</strong>. Les montants ci-dessous ont été calculés et enregistrés par Django.</p><div className="confirmation-details"><span><CalendarDays /> {eventDate.split("-").reverse().join("/")}</span><span><MapPin /> {location}</span><span><UsersRound /> {guestCount} invités</span><span><FileText /> {formatEuro(createdQuote?.total_amount)}</span></div><button className="secondary-button" onClick={() => navigate("compte")}>Voir mon espace client</button></div>}
    </section>
  </LocalizedContent>;
}
