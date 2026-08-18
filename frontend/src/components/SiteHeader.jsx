import { CircleUserRound, Headphones, Menu, Settings, X } from "lucide-react";
import { useTranslation } from "react-i18next";

import { backendBaseUrl } from "../api";
import { canSeeAdministrationLink } from "../utils/access";

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
  const { t } = useTranslation();
  return (
    <header className="site-header">
      <a className="skip-link" href="#main-content">{t("nav.skip")}</a>
      <button className="brand" type="button" onClick={() => onNavigate("accueil")} aria-label="Ultimate DJ, accueil">
        <img src="/logo-ultimate-dj.png" alt="Ultimate DJ — Réserver. Mixer. Célébrer." />
      </button>
      <button
        className="mobile-menu"
        type="button"
        onClick={onToggleMenu}
        aria-expanded={mobileNavOpen}
        aria-label={mobileNavOpen ? t("nav.closeMenu") : t("nav.openMenu")}
      >
        {mobileNavOpen ? <X /> : <Menu />}
      </button>
      <nav className={mobileNavOpen ? "main-nav open" : "main-nav"} aria-label={t("nav.main")}>
        <button type="button" className={page === "accueil" ? "active" : ""} aria-current={page === "accueil" ? "page" : undefined} onClick={() => onNavigate("accueil")}>{t("nav.home")}</button>
        <button type="button" className={page === "offres" || page === "detail" ? "active" : ""} aria-current={page === "offres" || page === "detail" ? "page" : undefined} onClick={() => onNavigate("offres")}>{t("nav.offers")}</button>
        <button type="button" className={page === "devis" ? "active" : ""} aria-current={page === "devis" ? "page" : undefined} onClick={() => onNavigate("devis")}>{t("nav.quote")}</button>
        <button type="button" className={page === "compte" ? "active" : ""} aria-current={page === "compte" ? "page" : undefined} onClick={() => onNavigate("compte")}>
          <CircleUserRound aria-hidden="true" /> {t("nav.account")}
        </button>
        {currentUser?.is_staff && (
          <button type="button" className={page === "administration" ? "active" : ""} aria-current={page === "administration" ? "page" : undefined} onClick={() => onNavigate("administration")}>
            <Settings aria-hidden="true" /> {t("nav.adminSpace")}
          </button>
        )}
        {currentUser?.role === "dj" && (
          <button type="button" className={page === "dj" ? "active" : ""} aria-current={page === "dj" ? "page" : undefined} onClick={() => onNavigate("dj")}>
            <Headphones aria-hidden="true" /> {t("nav.djSpace")}
          </button>
        )}
        {canSeeAdministrationLink(currentUser) && (
          <a className="admin-link" href={`${backendBaseUrl}/admin/`} target="_blank" rel="noreferrer">
            {t("nav.administration")}
          </a>
        )}
        <div className="language-switcher" aria-label={t("language.choice")}>
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
