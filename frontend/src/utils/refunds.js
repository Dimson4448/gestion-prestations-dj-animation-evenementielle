export function validateRefundAmount(rawAmount, refundableAmount) {
  const normalizedAmount = String(rawAmount ?? "").trim().replace(",", ".");
  const amount = Number(normalizedAmount);
  const maximum = Number(refundableAmount);

  if (!normalizedAmount || !Number.isFinite(amount)) {
    return { valid: false, error: "Saisissez un montant de remboursement valide." };
  }
  if (amount < 0.01) {
    return { valid: false, error: "Le remboursement doit être d’au moins 0,01 €." };
  }
  if (!Number.isFinite(maximum) || maximum < 0.01 || amount > maximum) {
    return { valid: false, error: "Le montant dépasse le solde remboursable." };
  }

  return { valid: true, amount: amount.toFixed(2) };
}
