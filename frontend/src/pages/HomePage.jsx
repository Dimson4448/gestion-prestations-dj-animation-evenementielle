import { CalendarDays, Check, ChevronRight, Clock3, Headphones, Music2, Search, ShieldCheck, Star } from "lucide-react";
import { useTranslation } from "react-i18next";

import { formatEuro } from "../utils/booking";
import CityAutocomplete from "../components/CityAutocomplete";

const eventTypeTranslationKeys = {
  "Anniversaire enfant": "eventTypes.childBirthday",
  "Anniversaire adulte": "eventTypes.adultBirthday",
  Mariage: "eventTypes.wedding",
  "Soirée privée": "eventTypes.privateParty",
};

export default function HomePage({
  availableEventTypes,
  catalogueStatus,
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
  const { t, i18n } = useTranslation();
  const journeySteps = t("home.steps", { returnObjects: true });
  return (
    <>
      <section className="hero">
        <div className="hero-content">
          <p className="eyebrow">{t("home.eyebrow")}</p>
          <h1>{t("home.title")}</h1>
          <p className="hero-lead">{t("home.lead")}</p>
          <form className="quick-search" onSubmit={(event) => { event.preventDefault(); onNavigate("offres"); }}>
            <label><span>{t("home.event")}</span><select value={eventType} onChange={(event) => onEventTypeChange(event.target.value)} required><option value="" disabled>{t("eventPrompt")}</option>{availableEventTypes.map((type) => <option key={type}>{t(eventTypeTranslationKeys[type], { defaultValue: type })}</option>)}</select></label>
            <label><span>{t("home.date")}</span><input type="date" value={eventDate} min={new Date().toISOString().slice(0, 10)} onChange={(event) => onEventDateChange(event.target.value)} /></label>
            <CityAutocomplete label={t("home.venue")} value={location} onChange={onLocationChange} required />
            <button className="primary-button" type="submit"><Search aria-hidden="true" /> {t("home.findDj")}</button>
          </form>
          <p className="search-note"><Check aria-hidden="true" /> {t("home.availabilityChecked")}</p>
        </div>
      </section>

      <section className="trust-strip" aria-label={t("home.guarantees")}>
        <article><CalendarDays /><div><strong>{t("home.verifiedSlots")}</strong><span>{t("home.verifiedSlotsText")}</span></div></article>
        <article><ShieldCheck /><div><strong>{t("home.secureDeposit")}</strong><span>{t("home.secureDepositText")}</span></div></article>
        <article><Music2 /><div><strong>{t("home.clientPlaylist")}</strong><span>{t("home.clientPlaylistText")}</span></div></article>
      </section>

      <section className="section-wrap">
        <div className="section-title"><div><p className="eyebrow dark">{t("home.adaptedOffers")}</p><h2>{t("home.choosePackage")}</h2></div><button className="text-link" type="button" onClick={() => onNavigate("offres")}>{t("home.allOffers")} <ChevronRight /></button></div>
        <div className="package-grid">
          {packages.slice(0, 3).map((item) => (
            <article className={`package-card ${item.accent || "cyan"}`} key={item.id}>
              <div className="card-icon"><Headphones /></div><p className="card-kicker">{item.event || t("home.djService")}</p><h3>{item.name}</h3><p>{item.description}</p>
              <div className="card-meta"><span><Clock3 /> {Number(item.included_hours).toLocaleString(i18n.language)} h</span>{item.rating ? <span><Star /> {item.rating}</span> : <span><ShieldCheck /> {t("home.verifiedPrice")}</span>}</div>
              <div className="card-footer"><div><small>{t("home.from")}</small><strong>{formatEuro(item.base_price)}</strong></div><button type="button" onClick={() => onOpenDetail(item)}>{t("home.discover")} <ChevronRight /></button></div>
            </article>
          ))}
        </div>
        {!packages.length && <p className="invoice-empty" role="status">{catalogueStatus}</p>}
      </section>

      <section className="journey-section">
        <p className="eyebrow">{t("home.guidedJourney")}</p><h2>{t("home.journeyTitle")}</h2>
        <ol className="journey-list">{journeySteps.map((step, index) => <li key={step}><span>{index + 1}</span><strong>{step}</strong></li>)}</ol>
      </section>
    </>
  );
}
