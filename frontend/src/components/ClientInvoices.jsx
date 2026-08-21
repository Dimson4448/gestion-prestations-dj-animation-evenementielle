import { CreditCard, Download } from "lucide-react";
import { useTranslation } from "react-i18next";

import { formatEuro } from "../utils/booking";

const refundLabel = (payment, t) => {
  if (payment.refund_status === "pending") return t("clientInvoices.refund.pending");
  if (payment.refund_status === "partial") return t("clientInvoices.refund.partial", { amount: formatEuro(payment.refunded_amount) });
  if (payment.refund_status === "succeeded") return t("clientInvoices.refund.succeeded", { amount: formatEuro(payment.refunded_amount) });
  return t("clientInvoices.refund.failed");
};

export default function ClientInvoices({
  checkoutPendingId,
  checkoutStatus,
  clientPayments,
  downloadDocument,
  downloadPending,
  invoices,
  invoiceStatus,
  startCheckout,
}) {
  const { i18n, t } = useTranslation();

  return (
    <div className="invoice-list" id="client-invoices">
      <h3>{t("clientInvoices.title")}</h3>
      {invoiceStatus && <p className="invoice-empty" role="status">{invoiceStatus}</p>}
      {checkoutStatus && <p className="form-message" role="alert">{checkoutStatus}</p>}

      {invoices.map((invoice) => {
        const invoicePayments = clientPayments.filter((payment) => payment.invoice === invoice.id);
        const invoiceType = t(`clientInvoices.type.${invoice.invoice_type}`, { defaultValue: t("clientInvoices.type.full") });
        const invoiceState = t(`clientInvoices.status.${invoice.status}`, { defaultValue: invoice.status });

        return (
          <article className="invoice-row" key={invoice.id}>
            <div>
              <strong>{invoice.invoice_number}</strong>
              <span>
                {invoiceType} · {t("clientInvoices.dueDate")}: {new Date(invoice.due_at).toLocaleDateString(i18n.language)}
              </span>

              {invoicePayments.map((payment) => (
                <div className="client-payment-trace" key={payment.id}>
                  <span>{t("clientInvoices.payment", { id: payment.id, amount: formatEuro(payment.amount) })}</span>
                  {payment.refund_status !== "none" && <small>{refundLabel(payment, t)}</small>}
                </div>
              ))}
            </div>

            <div className="invoice-actions">
              <strong>{formatEuro(invoice.amount)}</strong>
              <span className={`invoice-status ${invoice.status}`}>{invoiceState}</span>
              <button
                className="document-button"
                type="button"
                onClick={() => downloadDocument("invoices", invoice.id, invoice.invoice_number)}
                disabled={downloadPending === `invoices-${invoice.id}`}
              >
                <Download /> {downloadPending === `invoices-${invoice.id}` ? t("clientInvoices.preparing") : t("clientInvoices.download")}
              </button>

              {invoice.status === "sent" && (
                <button
                  className="primary-button payment-button"
                  type="button"
                  onClick={() => startCheckout(invoice)}
                  disabled={checkoutPendingId === invoice.id}
                >
                  <CreditCard /> {checkoutPendingId === invoice.id
                    ? t("clientInvoices.redirecting")
                    : t(invoice.invoice_type === "deposit" ? "clientInvoices.payDeposit" : "clientInvoices.payBalance")}
                </button>
              )}
            </div>
          </article>
        );
      })}
    </div>
  );
}
