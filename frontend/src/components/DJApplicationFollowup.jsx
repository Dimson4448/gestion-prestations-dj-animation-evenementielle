import { useTranslation } from "react-i18next";

const formatDate = (value, language) => {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? "" : date.toLocaleDateString(language);
};

export default function DJApplicationFollowup({ application, message }) {
  const { i18n, t } = useTranslation();
  const status = application?.status || "loading";

  return (
    <section className={`dj-application-followup ${status}`} aria-labelledby="dj-application-status-title">
      <h3 id="dj-application-status-title">{t("djApplication.statusTitle")}</h3>
      {message && <p role="status">{message}</p>}
      {application && (
        <>
          <div className="dj-application-followup-heading">
            <strong>{application.stage_name}</strong>
            <span>{t(`djApplication.status.${application.status}`)}</span>
          </div>
          <p>{t(`djApplication.statusText.${application.status}`)}</p>
          <small>
            {t("djApplication.submittedAt")} {formatDate(application.submitted_at, i18n.language)}
          </small>
          {application.reviewed_at && (
            <small>
              {t("djApplication.reviewedAt")} {formatDate(application.reviewed_at, i18n.language)}
            </small>
          )}
          {application.review_message && (
            <p><strong>{t("djApplication.adminResponse")}</strong> {application.review_message}</p>
          )}
        </>
      )}
    </section>
  );
}
