import { Bell, ChevronDown, CircleUserRound, Headphones, Menu, Settings, X } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { useTranslation } from "react-i18next";

import { apiClient, backendBaseUrl } from "../api";
import { unwrapApiList } from "../utils/apiCollections";

const languages = ["FR", "EN", "NL"];

export default function SiteHeader({ currentUser, language, mobileNavOpen, onLanguageChange, onNavigate, onToggleMenu, page }) {
  const { t } = useTranslation();
  const [accountMenuOpen, setAccountMenuOpen] = useState(false);
  const [notificationMenuOpen, setNotificationMenuOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const accountMenuRef = useRef(null);
  const notificationMenuRef = useRef(null);
  const hasWorkspaceMenu = Boolean(currentUser?.is_staff || currentUser?.role === "dj");

  useEffect(() => {
    const closeOnOutsideClick = (event) => {
      if (!accountMenuRef.current?.contains(event.target)) setAccountMenuOpen(false);
      if (!notificationMenuRef.current?.contains(event.target)) setNotificationMenuOpen(false);
    };
    document.addEventListener("pointerdown", closeOnOutsideClick);
    return () => document.removeEventListener("pointerdown", closeOnOutsideClick);
  }, []);

  useEffect(() => {
    let active = true;
    if (!currentUser) {
      setNotifications([]);
      return undefined;
    }
    apiClient.get("/notifications/", { params: { ordering: "-created_at" } })
      .then((response) => active && setNotifications(unwrapApiList(response.data).slice(0, 8)))
      .catch(() => active && setNotifications([]));
    return () => { active = false; };
  }, [currentUser]);

  const navigateFromAccountMenu = (target) => {
    setAccountMenuOpen(false);
    onNavigate(target);
  };

  const markNotificationRead = async (notification) => {
    if (!notification.read_at) {
      try {
        const response = await apiClient.post(`/notifications/${notification.id}/read/`);
        setNotifications((current) => current.map((item) => item.id === notification.id ? response.data : item));
      } catch {
        return;
      }
    }
    setNotificationMenuOpen(false);
    if (notification.link === "/dj") onNavigate("dj");
    else if (notification.link === "/administration") onNavigate("administration");
    else onNavigate("compte");
  };

  const unreadCount = notifications.filter((notification) => !notification.read_at).length;

  return <header className="site-header">
    <a className="skip-link" href="#main-content">{t("nav.skip")}</a>
    <button className="brand" type="button" onClick={() => onNavigate("accueil")} aria-label="Ultimate DJ, accueil"><img src="/logo-ultimate-dj.png" alt="Ultimate DJ — Réserver. Mixer. Célébrer." /></button>
    <button className="mobile-menu" type="button" onClick={onToggleMenu} aria-expanded={mobileNavOpen} aria-label={mobileNavOpen ? t("nav.closeMenu") : t("nav.openMenu")}>{mobileNavOpen ? <X /> : <Menu />}</button>
    <nav className={mobileNavOpen ? "main-nav open" : "main-nav"} aria-label={t("nav.main")}>
      <button type="button" className={page === "accueil" ? "active" : ""} aria-current={page === "accueil" ? "page" : undefined} onClick={() => onNavigate("accueil")}>{t("nav.home")}</button>
      <button type="button" className={page === "offres" || page === "detail" ? "active" : ""} aria-current={page === "offres" || page === "detail" ? "page" : undefined} onClick={() => onNavigate("offres")}>{t("nav.offers")}</button>
      <button type="button" className={page === "devis" ? "active" : ""} aria-current={page === "devis" ? "page" : undefined} onClick={() => onNavigate("devis")}>{t("nav.quote")}</button>

      {hasWorkspaceMenu ? <div className={`account-nav-menu${accountMenuOpen ? " open" : ""}`} ref={accountMenuRef}>
        <button className={page === "compte" || page === "administration" || page === "dj" ? "account-menu-trigger active" : "account-menu-trigger"} type="button" onClick={() => setAccountMenuOpen((open) => !open)} aria-expanded={accountMenuOpen} aria-haspopup="menu"><CircleUserRound /> {t("nav.account")} <ChevronDown className="account-chevron" /></button>
        <div className="account-menu-panel" role="menu">
          <button type="button" role="menuitem" onClick={() => navigateFromAccountMenu("compte")}><CircleUserRound /> {t("nav.account")}</button>
          {currentUser?.is_staff && <button type="button" role="menuitem" onClick={() => navigateFromAccountMenu("administration")}><Settings /> {t("nav.dashboard")}</button>}
          {currentUser?.role === "dj" && <button type="button" role="menuitem" onClick={() => navigateFromAccountMenu("dj")}><Headphones /> {t("nav.djSpace")}</button>}
          {currentUser?.is_staff && <a role="menuitem" href={`${backendBaseUrl}/admin/`} target="_blank" rel="noreferrer"><Settings /> {t("nav.djangoAdministration")}</a>}
        </div>
      </div> : <button type="button" className={page === "compte" ? "active" : ""} aria-current={page === "compte" ? "page" : undefined} onClick={() => onNavigate("compte")}><CircleUserRound /> {t("nav.account")}</button>}

      {currentUser && <div className={`notification-nav-menu${notificationMenuOpen ? " open" : ""}`} ref={notificationMenuRef}>
        <button className="notification-trigger" type="button" onClick={() => setNotificationMenuOpen((open) => !open)} aria-expanded={notificationMenuOpen} aria-label={t("notifications.open")}><Bell />{unreadCount > 0 && <span>{unreadCount}</span>}</button>
        <div className="notification-menu-panel" role="status"><strong>{t("notifications.title")}</strong>{notifications.map((notification) => <button className={notification.read_at ? "" : "unread"} type="button" key={notification.id} onClick={() => markNotificationRead(notification)}><b>{notification.title}</b><small>{notification.message}</small></button>)}{!notifications.length && <p>{t("notifications.empty")}</p>}</div>
      </div>}

      <div className="language-switcher" aria-label={t("language.choice")}>{languages.map((item) => <button type="button" key={item} className={language === item ? "selected" : ""} onClick={() => onLanguageChange(item)} aria-pressed={language === item}>{item}</button>)}</div>
    </nav>
  </header>;
}
