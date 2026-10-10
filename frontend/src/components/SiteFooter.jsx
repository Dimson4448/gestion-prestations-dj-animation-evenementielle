import { backendBaseUrl } from "../api";
import { useTranslation } from "react-i18next";
import { canSeeAdministrationLink } from "../utils/access";
import usePublicBusiness from "../hooks/usePublicBusiness";

export default function SiteFooter({ currentUser, onNavigate }) {
  const { t } = useTranslation();
  const business = usePublicBusiness();
  return (
    <footer>
      <div className="footer-brand"><img src="/logo-ultimate-dj.png" alt="Ultimate DJ" /><p>{t("footer.tagline")}</p></div>
      <section className="footer-section footer-contact" aria-label={t("footer.contact")}>
        <strong>{t("footer.contact")}</strong>
        <div>
          {business.email && <a href={`mailto:${business.email}`}>{t("footer.email")}: {business.email}</a>}
          {business.phone && <a href={`tel:${business.phone.replace(/\s/g, "")}`}>{t("footer.phone")}: {business.phone}</a>}
        </div>
      </section>
      <section className="footer-section footer-links">
        <nav className="footer-nav" aria-label={t("nav.footer")}>
          <button type="button" onClick={() => onNavigate("offres")}>{t("footer.offers")}</button>
          <button type="button" onClick={() => onNavigate("devis")}>{t("footer.quote")}</button>
          <button type="button" onClick={() => onNavigate("compte")}>{t("footer.account")}</button>
          <span className="footer-legal-links">
            <button type="button" onClick={() => onNavigate("legal")}>{t("footer.legal")}</button>
            <button type="button" onClick={() => onNavigate("privacy")}>{t("footer.privacy")}</button>
          </span>
          {canSeeAdministrationLink(currentUser) && <a href={`${backendBaseUrl}/admin/`} target="_blank" rel="noreferrer">{t("footer.admin")}</a>}
        </nav>
      </section>
      <div className="footer-meta"><small>{t("footer.version")}</small></div>
    </footer>
  );
}
