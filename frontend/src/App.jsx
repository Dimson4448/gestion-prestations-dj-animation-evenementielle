import { useEffect, useMemo, useState } from "react";
import {
  CalendarDays,
  Check,
  ChevronRight,
  CircleUserRound,
  Clock3,
  CreditCard,
  FileText,
  Headphones,
  MapPin,
  Menu,
  Music2,
  Settings,
  Search,
  ShieldCheck,
  Sparkles,
  Star,
  UsersRound,
  X,
} from "lucide-react";

import { apiClient, authenticate, clearAuthentication, getStoredAccessToken } from "./api";

const fallbackPackages = [
  {
    id: "essentielle",
    name: "Formule Essentielle",
    description: "Une sélection musicale sur mesure pour vos soirées privées et anniversaires.",
    included_hours: "4.0",
    base_price: "450.00",
    event: "Soirée privée",
    rating: "4,7",
    accent: "cyan",
  },
  {
    id: "premium",
    name: "Formule Premium",
    description: "DJ, sonorisation et éclairage pour une expérience complète et mémorable.",
    included_hours: "6.0",
    base_price: "790.00",
    event: "Événement d’entreprise",
    rating: "4,8",
    accent: "magenta",
  },
  {
    id: "mariage",
    name: "Package Mariage Premium",
    description: "Accompagnement dédié, rendez-vous préparatoire et coordination de votre soirée.",
    included_hours: "8.0",
    base_price: "1190.00",
    event: "Mariage",
    rating: "4,9",
    accent: "gold",
  },
];

const djProfiles = [
  { id: 1, name: "DJ Nova", styles: "Pop · House · Disco", slot: "18:00–02:00", rating: "4,9", reviews: 46 },
  { id: 2, name: "DJ Pulse", styles: "Hip-hop · R&B · Afro", slot: "19:00–03:00", rating: "4,8", reviews: 38 },
  { id: 3, name: "DJ Éclipse", styles: "Rock · Années 80 · Généraliste", slot: "17:00–01:00", rating: "4,7", reviews: 31 },
];

const eventTypes = [
  "Mariage",
  "Anniversaire adulte",
  "Anniversaire enfant",
  "Soirée privée",
  "Événement d’entreprise",
];

const formatEuro = (value) =>
  new Intl.NumberFormat("fr-BE", { style: "currency", currency: "EUR", maximumFractionDigits: 0 }).format(
    Number(value || 0),
  );

export default function App() {
  const [page, setPage] = useState("accueil");
  const [language, setLanguage] = useState("FR");
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [packages, setPackages] = useState(fallbackPackages);
  const [catalogueStatus, setCatalogueStatus] = useState("Catalogue de démonstration affiché");
  const [selectedPackageId, setSelectedPackageId] = useState("mariage");
  const [selectedDj, setSelectedDj] = useState(djProfiles[0]);
  const [eventType, setEventType] = useState("Mariage");
  const [eventDate, setEventDate] = useState("2026-09-12");
  const [location, setLocation] = useState("Bruxelles");
  const [durationHours, setDurationHours] = useState(8);
  const [distanceKm, setDistanceKm] = useState(20);
  const [guestCount, setGuestCount] = useState(80);
  const [parking, setParking] = useState("oui");
  const [musicPreferences, setMusicPreferences] = useState("Pop, disco et classiques des années 90");
  const [quoteSubmitted, setQuoteSubmitted] = useState(false);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [isAuthenticated, setIsAuthenticated] = useState(Boolean(getStoredAccessToken()));
  const [loginStatus, setLoginStatus] = useState("");
  const [loginPending, setLoginPending] = useState(false);
  const [depositInvoices, setDepositInvoices] = useState([]);
  const [invoiceStatus, setInvoiceStatus] = useState("");
  const [checkoutPendingId, setCheckoutPendingId] = useState(null);
  const [checkoutStatus, setCheckoutStatus] = useState("");

  useEffect(() => {
    let mounted = true;
    apiClient
      .get("/packages/")
      .then((response) => {
        const data = Array.isArray(response.data?.results) ? response.data.results : response.data;
        if (mounted && Array.isArray(data) && data.length) {
          setPackages(data.map((item, index) => ({ ...fallbackPackages[index % fallbackPackages.length], ...item })));
          setCatalogueStatus("Catalogue synchronisé avec l’API locale");
        }
      })
      .catch(() => mounted && setCatalogueStatus("Catalogue de démonstration · API locale hors ligne"));
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!isAuthenticated) {
      setDepositInvoices([]);
      return;
    }

    let mounted = true;
    setInvoiceStatus("Chargement de vos factures…");
    apiClient
      .get("/invoices/", { params: { invoice_type: "deposit", ordering: "-issued_at" } })
      .then((response) => {
        if (!mounted) return;
        const invoices = Array.isArray(response.data?.results) ? response.data.results : response.data;
        setDepositInvoices(Array.isArray(invoices) ? invoices : []);
        setInvoiceStatus(invoices?.length ? "" : "Aucune facture d’acompte disponible.");
      })
      .catch((error) => {
        if (!mounted) return;
        if (error.response?.status === 401) {
          clearAuthentication();
          setIsAuthenticated(false);
          setInvoiceStatus("");
          setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
        } else {
          setInvoiceStatus("Impossible de charger les factures pour le moment.");
        }
      });
    return () => {
      mounted = false;
    };
  }, [isAuthenticated]);

  const selectedPackage = useMemo(
    () => packages.find((item) => String(item.id) === String(selectedPackageId)) || packages[0],
    [packages, selectedPackageId],
  );

  const quote = useMemo(() => {
    const base = Number(selectedPackage?.base_price || 0);
    const extraHours = Math.max(Number(durationHours) - Number(selectedPackage?.included_hours || 0), 0);
    const subtotal = base + extraHours * 95;
    const travel = Number(distanceKm) * 0.65;
    return { subtotal, travel, total: subtotal + travel, deposit: (subtotal + travel) * 0.3 };
  }, [distanceKm, durationHours, selectedPackage]);

  const navigate = (target) => {
    setPage(target);
    setMobileNavOpen(false);
    setQuoteSubmitted(false);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const openDetail = (item, dj = selectedDj) => {
    setSelectedPackageId(item.id);
    setSelectedDj(dj);
    navigate("detail");
  };

  const startQuote = () => navigate("devis");

  const handleLogin = async (event) => {
    event.preventDefault();
    setLoginPending(true);
    setLoginStatus("");
    try {
      await authenticate(username, password);
      setIsAuthenticated(true);
      setPassword("");
      setLoginStatus("Connexion réussie. Votre espace client est maintenant accessible.");
    } catch (error) {
      setLoginStatus(
        error.response?.status === 401
          ? "Identifiant ou mot de passe incorrect."
          : "Connexion impossible. Vérifiez que le backend Django est démarré.",
      );
    } finally {
      setLoginPending(false);
    }
  };

  const handleLogout = () => {
    clearAuthentication();
    setIsAuthenticated(false);
    setLoginStatus("Vous êtes déconnecté.");
  };

  const startDepositCheckout = async (invoice) => {
    setCheckoutPendingId(invoice.id);
    setCheckoutStatus("");
    try {
      const response = await apiClient.post(`/invoices/${invoice.id}/checkout/`);
      const checkoutUrl = new URL(response.data.checkout_url);
      if (checkoutUrl.protocol !== "https:" || checkoutUrl.hostname !== "checkout.stripe.com") {
        throw new Error("URL Stripe inattendue");
      }
      window.location.assign(checkoutUrl.toString());
    } catch (error) {
      if (error.response?.status === 401) {
        clearAuthentication();
        setIsAuthenticated(false);
        setLoginStatus("Votre session a expiré. Veuillez vous reconnecter.");
      } else {
        setCheckoutStatus(error.response?.data?.detail || "Le paiement ne peut pas être démarré pour le moment.");
      }
      setCheckoutPendingId(null);
    }
  };

  return (
    <div className="site-shell">
      <header className="site-header">
        <button className="brand" type="button" onClick={() => navigate("accueil")} aria-label="Ultimate DJ, accueil">
          <img src="/logo-ultimate-dj.png" alt="Ultimate DJ — Réserver. Mixer. Célébrer." />
        </button>
        <button
          className="mobile-menu"
          type="button"
          onClick={() => setMobileNavOpen((open) => !open)}
          aria-expanded={mobileNavOpen}
          aria-label="Ouvrir le menu"
        >
          {mobileNavOpen ? <X /> : <Menu />}
        </button>
        <nav className={mobileNavOpen ? "main-nav open" : "main-nav"} aria-label="Navigation principale">
          <button className={page === "accueil" ? "active" : ""} onClick={() => navigate("accueil")}>Accueil</button>
          <button className={page === "offres" || page === "detail" ? "active" : ""} onClick={() => navigate("offres")}>Offres & DJs</button>
          <button className={page === "devis" ? "active" : ""} onClick={() => navigate("devis")}>Demander un devis</button>
          <button className={page === "compte" ? "active" : ""} onClick={() => navigate("compte")}>
            <CircleUserRound aria-hidden="true" /> Mon compte
          </button>
          <a className="admin-link" href="http://127.0.0.1:8000/admin/" target="_blank" rel="noreferrer">
            <Settings aria-hidden="true" /> Administration
          </a>
          <div className="language-switcher" aria-label="Choix de la langue">
            {["FR", "EN", "NL"].map((lang) => (
              <button key={lang} className={language === lang ? "selected" : ""} onClick={() => setLanguage(lang)} aria-pressed={language === lang}>
                {lang}
              </button>
            ))}
          </div>
        </nav>
      </header>

      <main>
        {page === "accueil" && (
          <>
            <section className="hero">
              <div className="hero-content">
                <p className="eyebrow">Votre événement, votre ambiance</p>
                <h1>Réservez le DJ parfait.</h1>
                <p className="hero-lead">Devis, contrat, acompte et playlist réunis dans un parcours simple et sécurisé.</p>
                <form className="quick-search" onSubmit={(event) => { event.preventDefault(); navigate("offres"); }}>
                  <label><span>Événement</span><select value={eventType} onChange={(event) => setEventType(event.target.value)}>{eventTypes.map((type) => <option key={type}>{type}</option>)}</select></label>
                  <label><span>Date</span><input type="date" value={eventDate} min="2026-07-19" onChange={(event) => setEventDate(event.target.value)} /></label>
                  <label><span>Lieu</span><input value={location} onChange={(event) => setLocation(event.target.value)} /></label>
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
              <div className="section-title"><div><p className="eyebrow dark">Des offres adaptées</p><h2>Choisissez votre formule</h2></div><button className="text-link" onClick={() => navigate("offres")}>Voir toutes les offres <ChevronRight /></button></div>
              <div className="package-grid">
                {packages.slice(0, 3).map((item) => (
                  <article className={`package-card ${item.accent || "cyan"}`} key={item.id}>
                    <div className="card-icon"><Headphones /></div><p className="card-kicker">{item.event || "Prestation DJ"}</p><h3>{item.name}</h3><p>{item.description}</p>
                    <div className="card-meta"><span><Clock3 /> {Number(item.included_hours).toLocaleString("fr-BE")} h</span><span><Star /> {item.rating || "4,8"}</span></div>
                    <div className="card-footer"><div><small>À partir de</small><strong>{formatEuro(item.base_price)}</strong></div><button onClick={() => openDetail(item)}>Découvrir <ChevronRight /></button></div>
                  </article>
                ))}
              </div>
            </section>

            <section className="journey-section">
              <p className="eyebrow">Un parcours guidé</p><h2>De votre idée à la piste de danse</h2>
              <ol className="journey-list">{["Décrivez votre événement", "Choisissez l’offre et le DJ", "Validez devis et contrat", "Payez l’acompte", "Préparez votre playlist"].map((step, index) => <li key={step}><span>{index + 1}</span><strong>{step}</strong></li>)}</ol>
            </section>
          </>
        )}

        {page === "offres" && (
          <section className="section-wrap catalogue-page">
            <div className="page-heading"><p className="eyebrow dark">Offres & DJs</p><h1>Trouvez la prestation qui vous ressemble</h1><p>{eventType} · {eventDate.split("-").reverse().join("/")} · {location}</p></div>
            <div className="catalogue-layout">
              <aside className="filters"><div className="filter-heading"><h2>Filtres</h2><button onClick={() => { setEventType("Mariage"); setLocation("Bruxelles"); }}>Réinitialiser</button></div>
                <label>Type d’événement<select value={eventType} onChange={(event) => setEventType(event.target.value)}>{eventTypes.map((type) => <option key={type}>{type}</option>)}</select></label>
                <label>Date<input type="date" value={eventDate} onChange={(event) => setEventDate(event.target.value)} /></label>
                <label>Lieu<input value={location} onChange={(event) => setLocation(event.target.value)} /></label>
                <label>Budget<select defaultValue="1500"><option value="700">Moins de 700 €</option><option value="1500">700 € – 1 500 €</option><option value="more">Plus de 1 500 €</option></select></label>
                <fieldset><legend>Services</legend><label className="check-row"><input type="checkbox" defaultChecked /> Sonorisation</label><label className="check-row"><input type="checkbox" defaultChecked /> Éclairage</label><label className="check-row"><input type="checkbox" /> Animation micro</label></fieldset>
              </aside>
              <div className="results"><div className="results-heading"><div><h2>DJs disponibles à {location}</h2><p>{djProfiles.length} résultats · {catalogueStatus}</p></div><span className="status-pill"><span /> Créneaux disponibles</span></div>
                {djProfiles.map((dj, index) => { const item = packages[index % packages.length]; return <article className="dj-card" key={dj.id}><div className={`dj-avatar avatar-${index + 1}`}><Headphones /></div><div className="dj-copy"><div className="dj-title"><h3>{dj.name}</h3><span><Star /> {dj.rating} ({dj.reviews} avis)</span></div><p>{dj.styles}</p><p className="availability"><Clock3 /> Disponible {dj.slot}</p><strong>À partir de {formatEuro(item.base_price)}</strong></div><button className="primary-button" onClick={() => openDetail(item, dj)}>Voir le détail <ChevronRight /></button></article>; })}
              </div>
            </div>
          </section>
        )}

        {page === "detail" && selectedPackage && (
          <>
            <section className="detail-hero"><div className="breadcrumb"><button onClick={() => navigate("accueil")}>Accueil</button><span>/</span><button onClick={() => navigate("offres")}>Offres & DJs</button><span>/</span><span>{selectedPackage.name}</span></div><div className="detail-heading"><div><p className="eyebrow">{selectedPackage.event || "Prestation événementielle"}</p><h1>{selectedPackage.name}</h1><p>{selectedPackage.description}</p><div className="detail-badges"><span><Star /> {selectedPackage.rating || selectedDj.rating} · avis vérifiés</span><span><Clock3 /> {Number(selectedPackage.included_hours)} heures incluses</span></div></div><div className="dj-signature"><div className="dj-avatar"><Headphones /></div><div><small>Votre DJ</small><strong>{selectedDj.name}</strong><span>{selectedDj.styles}</span></div></div></div></section>
            <section className="detail-layout section-wrap"><div className="detail-content"><article><h2>Ce qui est inclus</h2><ul className="feature-list"><li><Check /> Préparation musicale personnalisée</li><li><Check /> Sonorisation professionnelle</li><li><Check /> Éclairage adapté à la salle</li><li><Check /> Coordination avec le lieu de réception</li></ul></article><article><h2>Options & matériel</h2><p>Ajoutez une animation micro, un éclairage architectural ou du matériel supplémentaire. Chaque option apparaît clairement dans le devis.</p></article><article><h2>Playlist et styles</h2><p>Indiquez vos styles favoris, les chansons incontournables et celles à éviter. La playlist reste modifiable pendant la préparation.</p></article><article><h2>Conditions d’acompte</h2><p>Un acompte indicatif de 30 % confirme la réservation. Le créneau est bloqué uniquement après validation du contrat et paiement accepté.</p></article></div><aside className="booking-card"><p className="eyebrow dark">Réserver ce package</p><h2>À partir de {formatEuro(selectedPackage.base_price)}</h2><label>Date<input type="date" value={eventDate} onChange={(event) => setEventDate(event.target.value)} /></label><label>Créneau<select defaultValue={selectedDj.slot}><option>{selectedDj.slot}</option><option>À confirmer avec le DJ</option></select></label><label>Lieu<input value={location} onChange={(event) => setLocation(event.target.value)} /></label><button className="primary-button" onClick={startQuote}>Demander un devis <ChevronRight /></button><p className="secure-note"><ShieldCheck /> Aucun paiement à cette étape</p></aside></section>
          </>
        )}

        {page === "devis" && (
          <section className="section-wrap quote-page"><div className="page-heading"><p className="eyebrow dark">Demande de devis</p><h1>Parlez-nous de votre événement</h1><p>Les informations obligatoires suivent le scénario de demande validé dans les diagrammes.</p></div>
            {!quoteSubmitted ? <div className="quote-layout"><form className="quote-form" onSubmit={(event) => { event.preventDefault(); setQuoteSubmitted(true); }}><fieldset><legend><span>1</span> Votre événement</legend><div className="form-grid"><label>Type d’événement<select value={eventType} onChange={(event) => setEventType(event.target.value)} required>{eventTypes.map((type) => <option key={type}>{type}</option>)}</select></label><label>Date<input type="date" value={eventDate} min="2026-07-19" onChange={(event) => setEventDate(event.target.value)} required /></label><label>Lieu<input value={location} onChange={(event) => setLocation(event.target.value)} required /></label><label>Nombre d’invités<input type="number" min="1" value={guestCount} onChange={(event) => setGuestCount(event.target.value)} required /></label><label>Durée prévue (heures)<input type="number" min="1" step="0.5" value={durationHours} onChange={(event) => setDurationHours(event.target.value)} required /></label><label>Parking disponible ?<select value={parking} onChange={(event) => setParking(event.target.value)}><option value="oui">Oui</option><option value="non">Non</option><option value="inconnu">À vérifier</option></select></label></div></fieldset><fieldset><legend><span>2</span> Offre et préférences</legend><div className="form-grid"><label>Formule<select value={selectedPackageId} onChange={(event) => setSelectedPackageId(event.target.value)}>{packages.map((item) => <option value={item.id} key={item.id}>{item.name}</option>)}</select></label><label>Distance estimée (km)<input type="number" min="0" value={distanceKm} onChange={(event) => setDistanceKm(event.target.value)} /></label><label className="full-field">Préférences musicales<textarea rows="4" value={musicPreferences} onChange={(event) => setMusicPreferences(event.target.value)} placeholder="Styles, chansons souhaitées ou à éviter…" /></label></div></fieldset><button className="primary-button submit-quote" type="submit">Soumettre la demande <ChevronRight /></button></form><aside className="quote-summary"><p className="eyebrow dark">Estimation</p><h2>{selectedPackage?.name}</h2><dl><div><dt>Prestation</dt><dd>{formatEuro(quote.subtotal)}</dd></div><div><dt>Déplacement estimé</dt><dd>{formatEuro(quote.travel)}</dd></div><div className="quote-total"><dt>Total indicatif</dt><dd>{formatEuro(quote.total)}</dd></div><div><dt>Acompte proposé (30 %)</dt><dd>{formatEuro(quote.deposit)}</dd></div></dl><p><ShieldCheck /> Cette estimation sera vérifiée par l’administrateur/DJ avant l’envoi du devis.</p></aside></div> : <div className="confirmation-card"><div className="confirmation-icon"><Check /></div><p className="eyebrow dark">Demande soumise</p><h2>Votre demande a bien été enregistrée.</h2><p>Statut : <strong>Soumise — disponibilité à vérifier</strong>. L’administrateur/DJ analysera les informations avant de générer le devis.</p><div className="confirmation-details"><span><CalendarDays /> {eventDate.split("-").reverse().join("/")}</span><span><MapPin /> {location}</span><span><UsersRound /> {guestCount} invités</span></div><button className="secondary-button" onClick={() => navigate("accueil")}>Revenir à l’accueil</button></div>}
          </section>
        )}

        {page === "compte" && (
          <section className="section-wrap account-page">
            <div className="page-heading"><p className="eyebrow dark">Espace client</p><h1>Retrouvez votre événement au même endroit</h1><p>Connectez-vous pour suivre vos devis, contrats, paiements et playlists.</p></div>
            <div className="account-grid">
              {!isAuthenticated ? (
                <form className="account-card" onSubmit={handleLogin}>
                  <CircleUserRound /><h2>Connexion</h2>
                  <label>Identifiant Django<input value={username} onChange={(event) => setUsername(event.target.value)} autoComplete="username" required /></label>
                  <label>Mot de passe<input type="password" value={password} onChange={(event) => setPassword(event.target.value)} autoComplete="current-password" required /></label>
                  {loginStatus && <p className="form-message" role="status">{loginStatus}</p>}
                  <button className="primary-button" type="submit" disabled={loginPending}>{loginPending ? "Connexion…" : "Se connecter"}</button>
                </form>
              ) : (
                <div className="account-card connected-card">
                  <div className="confirmation-icon"><Check /></div><h2>Session client active</h2>
                  <p>Vous pouvez maintenant consulter vos factures et démarrer un paiement sécurisé.</p>
                  {loginStatus && <p className="form-message success" role="status">{loginStatus}</p>}
                  <div className="invoice-list">
                    <h3>Factures d’acompte</h3>
                    {invoiceStatus && <p className="invoice-empty" role="status">{invoiceStatus}</p>}
                    {checkoutStatus && <p className="form-message" role="alert">{checkoutStatus}</p>}
                    {depositInvoices.map((invoice) => (
                      <article className="invoice-row" key={invoice.id}>
                        <div><strong>{invoice.invoice_number}</strong><span>Échéance : {new Date(invoice.due_at).toLocaleDateString("fr-BE")}</span></div>
                        <div className="invoice-actions">
                          <strong>{formatEuro(invoice.amount)}</strong>
                          <span className={`invoice-status ${invoice.status}`}>{invoice.status === "paid" ? "Payée" : invoice.status === "sent" ? "À payer" : invoice.status}</span>
                          {invoice.status === "sent" && (
                            <button className="primary-button payment-button" type="button" onClick={() => startDepositCheckout(invoice)} disabled={checkoutPendingId === invoice.id}>
                              <CreditCard /> {checkoutPendingId === invoice.id ? "Redirection…" : "Payer l’acompte"}
                            </button>
                          )}
                        </div>
                      </article>
                    ))}
                  </div>
                  <button className="secondary-button" type="button" onClick={handleLogout}>Se déconnecter</button>
                </div>
              )}
              <aside className="account-benefits"><p className="eyebrow">Votre suivi personnalisé</p><h2>Un parcours clair, étape par étape</h2>{[{ icon: FileText, text: "Consultez vos devis et contrats" }, { icon: CreditCard, text: "Suivez l’acompte et les factures" }, { icon: Music2, text: "Préparez votre playlist" }, { icon: Sparkles, text: "Laissez un avis après la prestation" }].map(({ icon: Icon, text }) => <div key={text}><Icon /><span>{text}</span></div>)}</aside>
            </div>
          </section>
        )}
      </main>

      <footer><img src="/logo-ultimate-dj.png" alt="Ultimate DJ" /><p>Réserver. Mixer. Célébrer.</p><nav aria-label="Navigation de pied de page"><button onClick={() => navigate("offres")}>Offres</button><button onClick={() => navigate("devis")}>Devis</button><button onClick={() => navigate("compte")}>Mon compte</button><a href="http://127.0.0.1:8000/admin/" target="_blank" rel="noreferrer">Administration</a></nav><small>© 2026 Ultimate DJ · Version alpha</small></footer>
    </div>
  );
}
