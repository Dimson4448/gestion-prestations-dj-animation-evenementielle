import { Check, Headphones, Settings } from "lucide-react";
import { useTranslation } from "react-i18next";

import { getAccountSummaryKey } from "../utils/authentication";
import DJApplicationFollowup from "./DJApplicationFollowup";

export default function ConnectedAccountSession({
  children,
  currentUser,
  djApplicationStatus,
  djApplicationStatusMessage,
  loginStatus,
  onLogout,
  onNavigate,
}) {
  const { t } = useTranslation();

  return (
    <div className="account-card connected-card">
      <div className="confirmation-icon"><Check /></div>
      <h2>{t("authentication.session.title")}</h2>
      <p>{t(getAccountSummaryKey(currentUser))}</p>

      {loginStatus && <p className="form-message success" role="status">{loginStatus}</p>}

      {currentUser?.role === "dj_candidate" && (
        <DJApplicationFollowup
          application={djApplicationStatus}
          message={djApplicationStatusMessage}
        />
      )}

      {currentUser?.is_staff && (
        <button className="primary-button" type="button" onClick={() => onNavigate("administration")}>
          <Settings /> {t("authentication.session.openAdministration")}
        </button>
      )}

      {currentUser?.role === "dj" && (
        <button className="primary-button" type="button" onClick={() => onNavigate("dj")}>
          <Headphones /> {t("authentication.session.openDjArea")}
        </button>
      )}

      {children}

      <button className="secondary-button" type="button" onClick={onLogout}>
        {t("authentication.session.logout")}
      </button>
    </div>
  );
}
