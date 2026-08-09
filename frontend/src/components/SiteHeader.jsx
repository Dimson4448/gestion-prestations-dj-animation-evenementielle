import { CircleUserRound, Headphones, Menu, Settings, X } from "lucide-react";

const languages = ["FR", "EN", "NL"];

export default function SiteHeader({
  currentUser,
  language,
  mobileNavOpen,
  onLanguageChange,
  onNavigate,
  onToggleMenu,
  page,
}) {
  return (
    <header className="site-header">
      <a className="skip-link" href="#main-content">Aller au contenu principal</a>
      <button className="brand" type="button" onClick={() => onNavigate("accueil")} aria-label="Ultimate DJ, accueil">
        <img src="/logo-ultimate-dj.png" alt="Ultimate DJ — Réserver. Mixer. Célébrer." />
      </button>
      <button
        className="mobile-menu"
        type="button"
        onClick={onToggleMenu}
        aria-expanded={mobileNavOpen}
        aria-label={mobileNavOpen ? "Fermer le menu" : "Ouvrir le menu"}
      >
        {mobileNavOpen ? <X /> : <Menu />}
      </button>
      <nav className={mobileNavOpen ? "main-nav open" : "main-nav"} aria-label="Navigation principale">
        <button type="button" className={page === "accueil" ? "active" : ""} aria-current={page === "accueil" ? "page" : undefined} onClick={() => onNavigate("accueil")}>Accueil</button>
        <button type="button" className={page === "offres" || page === "detail" ? "active" : ""} aria-current={page === "offres" || page === "detail" ? "page" : undefined} onClick={() => onNavigate("offres")}>Offres & DJs</button>
        <button type="button" className={page === "devis" ? "active" : ""} aria-current={page === "devis" ? "page" : undefined} onClick={() => onNavigate("devis")}>Demander un devis</button>
        <button type="button" className={page === "compte" ? "active" : ""} aria-current={page === "compte" ? "page" : undefined} onClick={() => onNavigate("compte")}>
          <CircleUserRound aria-hidden="true" /> Mon compte
        </button>
        {currentUser?.is_staff && (
          <button type="button" className={page === "administration" ? "active" : ""} aria-current={page === "administration" ? "page" : undefined} onClick={() => onNavigate("administration")}>
            <Settings aria-hidden="true" /> Espace administrateur
          </button>
        )}
        {currentUser?.role === "dj" && (
          <button type="button" className={page === "dj" ? "active" : ""} aria-current={page === "dj" ? "page" : undefined} onClick={() => onNavigate("dj")}>
            <Headphones aria-hidden="true" /> Espace DJ
          </button>
        )}
        <a className="admin-link" href="http://127.0.0.1:8000/admin/" target="_blank" rel="noreferrer">
          Django Admin
        </a>
        <div className="language-switcher" aria-label="Choix de la langue">
          {languages.map((item) => (
            <button
              type="button"
              key={item}
              className={language === item ? "selected" : ""}
              onClick={() => onLanguageChange(item)}
              aria-pressed={language === item}
            >
              {item}
            </button>
          ))}
        </div>
      </nav>
    </header>
  );
}
