import { Download, FileText } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function ClientContracts({
  contracts,
  contractPendingId,
  contractStatus,
  downloadDocument,
  downloadPending,
  signContract,
}) {
  const { i18n, t } = useTranslation();

  return (
    <div className="contract-list">
      <h3>{t("clientContracts.title")}</h3>
      {contractStatus && (
        <p className={contractStatus.includes("signé") ? "form-message success" : "invoice-empty"} role="status">
          {contractStatus}
        </p>
      )}

      {contracts.map((contract) => (
        <article className="contract-row" key={contract.id}>
          <div>
            <strong>{contract.contract_number}</strong>
            <span>{t("clientContracts.booking", { id: contract.booking })}</span>
            <span>{contract.refund_policy}</span>
          </div>

          <div className="contract-actions">
            <span className={`contract-status ${contract.status}`}>
              {t(`clientContracts.status.${contract.status}`, { defaultValue: contract.status })}
            </span>
            <button
              className="document-button"
              type="button"
              onClick={() => downloadDocument("contracts", contract.id, contract.contract_number)}
              disabled={downloadPending === `contracts-${contract.id}`}
            >
              <Download /> {downloadPending === `contracts-${contract.id}` ? t("clientContracts.preparing") : t("clientContracts.download")}
            </button>

            {contract.status === "sent" && (
              <button
                className="primary-button payment-button"
                type="button"
                onClick={() => signContract(contract.id)}
                disabled={contractPendingId === contract.id}
              >
                <FileText /> {contractPendingId === contract.id ? t("clientContracts.signing") : t("clientContracts.sign")}
              </button>
            )}

            {contract.signed_by_client_at && (
              <small>{t("clientContracts.signedAt", { date: new Date(contract.signed_by_client_at).toLocaleString(i18n.language) })}</small>
            )}
          </div>
        </article>
      ))}
    </div>
  );
}
