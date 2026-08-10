import { backendBaseUrl } from "../api";
import { useTranslation } from "react-i18next";

export default function SiteFooter({ onNavigate }) {
  const { t } = useTranslation();
  return (
    <footer>
      <img src="/logo-ultimate-dj.png" alt="Ultimate DJ" />
      <p>{t("footer.tagline")}</p>
      <nav aria-label={t("nav.footer")}>
        <button type="button" onClick={() => onNavigate("offres")}>{t("footer.offers")}</button>
        <button type="button" onClick={() => onNavigate("devis")}>{t("footer.quote")}</button>
        <button type="button" onClick={() => onNavigate("compte")}>{t("footer.account")}</button>
        <a href={`${backendBaseUrl}/admin/`} target="_blank" rel="noreferrer">{t("footer.admin")}</a>
      </nav>
      <small>{t("footer.version")}</small>
    </footer>
  );
}
