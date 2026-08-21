import { ChevronDown, X } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function ClientAccountDeletion({
  cancelRequest,
  onReasonChange,
  onSubmit,
  pending,
  reason,
  requests,
  statusMessage,
}) {
  const { t } = useTranslation();
  const hasPendingRequest = requests.some((request) => request.status === "pending");

  return (
    <details className="account-deletion-panel">
      <summary className="account-deletion-summary">
        <div><h3>{t("accountDeletion.title")}</h3><p>{t("accountDeletion.intro")}</p></div>
        <span><X /><ChevronDown className="deletion-chevron" /></span>
      </summary>

      <div className="account-deletion-content">

      {requests.map((request) => (
        <article className="deletion-request-row" key={request.id}>
          <div>
            <strong>{t("accountDeletion.request", { id: request.id })}</strong>
            <span>{request.reason}</span>
            {request.review_message && <small>{t("accountDeletion.response", { message: request.review_message })}</small>}
          </div>
          <div>
            <span className={`deletion-status ${request.status}`}>
              {t(`accountDeletion.status.${request.status}`, { defaultValue: t("accountDeletion.status.rejected") })}
            </span>
            {request.status === "pending" && (
              <button className="document-button" type="button" onClick={() => cancelRequest(request.id)} disabled={pending}>
                {t("accountDeletion.cancel")}
              </button>
            )}
          </div>
        </article>
      ))}

      {!hasPendingRequest && (
        <form className="password-change-form" onSubmit={onSubmit}>
          <label>
            {t("accountDeletion.reason")}
            <textarea rows="3" minLength="10" value={reason} onChange={(event) => onReasonChange(event.target.value)} required />
          </label>
          <button className="document-button danger-button" type="submit" disabled={pending}>
            {pending ? t("accountDeletion.saving") : t("accountDeletion.submit")}
          </button>
        </form>
      )}

      {statusMessage && (
        <p className={statusMessage.includes("enregistrée") || statusMessage.includes("annulée") ? "form-message success" : "form-message"} role="status">
          {statusMessage}
        </p>
      )}
      </div>
    </details>
  );
}
