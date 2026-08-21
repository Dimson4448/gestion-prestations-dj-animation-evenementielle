import { useTranslation } from "react-i18next";

import { formatEuro } from "../utils/booking";

const findRecord = (records, id) => records.find((entry) => String(entry.id) === String(id));

const quoteProgress = {
  draft: { step: 1, next: "clientQuotes.next.draft" },
  sent: { step: 2, next: "clientQuotes.next.sent" },
  accepted: { step: 3, next: "clientQuotes.next.accepted" },
  refused: { step: 1, next: "clientQuotes.next.refused" },
  expired: { step: 1, next: "clientQuotes.next.expired" },
};

export default function ClientQuotes({ eventTypes, packages, quotes, statusMessage, venues }) {
  const { i18n, t } = useTranslation();

  return (
    <div className="quote-list" id="client-quotes">
      <h3>{t("clientQuotes.title")}</h3>
      {statusMessage && <p className="invoice-empty" role="status">{statusMessage}</p>}

      {quotes.map((quote) => {
        const selectedPackage = findRecord(packages, quote.package);
        const venue = findRecord(venues, quote.venue);
        const eventType = findRecord(eventTypes, quote.event_type);

        const progress = quoteProgress[quote.status] || quoteProgress.draft;
        return (
          <details className="quote-row" key={quote.id}>
            <summary className="client-quote-summary">
              <span className="quote-row-heading">
                <strong>{t("clientQuotes.quote", { id: quote.id })}</strong>
                <span className={`quote-status ${quote.status}`}>
                  {t(`clientQuotes.status.${quote.status}`, { defaultValue: quote.status })}
                </span>
              </span>
              <span>
                {eventType?.name || t("clientQuotes.event")} · {new Date(`${quote.event_date}T00:00:00`).toLocaleDateString(i18n.language)}
              </span>
              <span>
                {selectedPackage?.name || t("clientQuotes.package", { id: quote.package })} · {venue
                  ? `${venue.name}, ${venue.city}`
                  : t("clientQuotes.venue", { id: quote.venue })}
              </span>
              <span className="quote-row-amounts">
                <span>{t("clientQuotes.total")}: <strong>{formatEuro(quote.total_amount)}</strong></span>
                <span>{t("clientQuotes.deposit")}: <strong>{formatEuro(quote.deposit_amount)}</strong></span>
              </span>
              <small className="client-quote-open">{t("clientQuotes.open")}</small>
            </summary>
            <div className="client-quote-progress">
              <strong>{t("clientQuotes.progress")}</strong>
              <div className="client-quote-steps" aria-label={t("clientQuotes.progress")}>
                {[1, 2, 3, 4].map((step) => <span className={step <= progress.step ? "active" : ""} key={step} />)}
              </div>
              <p>{t(progress.next)}</p>
              {quote.status === "accepted" && <a className="document-button" href="#client-contracts">{t("clientQuotes.viewContract")}</a>}
            </div>
          </details>
        );
      })}
    </div>
  );
}
