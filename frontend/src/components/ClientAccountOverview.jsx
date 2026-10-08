import { CalendarDays, CreditCard, FileText, ReceiptText } from "lucide-react";
import { useTranslation } from "react-i18next";

const summaryItems = [
  { key: "quotes", icon: FileText, target: "client-quotes", accent: "cyan" },
  { key: "contracts", icon: ReceiptText, target: "client-contracts", accent: "pink" },
  { key: "invoices", icon: CreditCard, target: "client-invoices", accent: "yellow" },
  { key: "appointments", icon: CalendarDays, target: "client-appointments", accent: "navy" },
];

export default function ClientAccountOverview({ appointments, contracts, invoices, profile, quotes }) {
  const { t } = useTranslation();
  const displayName = profile?.first_name || t("clientOverview.client");
  const values = {
    quotes: quotes.length,
    contracts: contracts.filter((contract) => contract.status === "sent").length,
    invoices: invoices.filter((invoice) => invoice.status === "sent").length,
    appointments: appointments.filter((appointment) => ["proposed", "counter_proposed", "accepted"].includes(appointment.status)).length,
  };

  const openSection = (target) => {
    const section = document.getElementById(target);
    if (!section) return;

    section.scrollIntoView({ behavior: "smooth", block: "start" });
    section.classList.remove("client-section-highlight");
    window.requestAnimationFrame(() => section.classList.add("client-section-highlight"));
    window.setTimeout(() => section.classList.remove("client-section-highlight"), 1800);
  };

  const nextAction = contracts.some((contract) => contract.status === "sent")
    ? { target: "client-contracts", label: t("clientOverview.next.contract") }
    : invoices.some((invoice) => invoice.status === "sent")
      ? { target: "client-invoices", label: t("clientOverview.next.invoice") }
      : appointments.some((appointment) => ["proposed", "counter_proposed"].includes(appointment.status))
        ? { target: "client-appointments", label: t("clientOverview.next.appointment") }
        : quotes.some((quote) => quote.status === "sent")
          ? { target: "client-quotes", label: t("clientOverview.next.quote") }
          : { target: "client-quotes", label: t("clientOverview.next.complete") };

  return (
    <section className="client-overview" aria-labelledby="client-overview-title">
      <div className="client-overview-heading">
        <div>
          <p className="eyebrow">{t("clientOverview.eyebrow")}</p>
          <h2 id="client-overview-title">{t("clientOverview.welcome", { name: displayName })}</h2>
          <p>{t("clientOverview.intro")}</p>
        </div>
        <span className="client-overview-status">{t("clientOverview.secure")}</span>
      </div>

      <div className="client-overview-grid">
        {summaryItems.map(({ accent, icon: Icon, key, target }) => (
          <button className={`client-overview-item ${accent}`} type="button" onClick={() => openSection(target)} key={key}>
            <span><Icon /></span>
            <strong>{values[key]}</strong>
            <small>{t(`clientOverview.${key}`)}</small>
            <em>{t("clientOverview.open")}</em>
          </button>
        ))}
      </div>

      <div className="client-next-action">
        <div><strong>{t("clientOverview.next.title")}</strong><span>{nextAction.label}</span></div>
        <button className="document-button" type="button" onClick={() => openSection(nextAction.target)}>{t("clientOverview.open")}</button>
      </div>
    </section>
  );
}
