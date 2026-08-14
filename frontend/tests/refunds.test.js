import test from "node:test";
import assert from "node:assert/strict";

import { validateRefundAmount } from "../src/utils/refunds.js";

test("validateRefundAmount accepte un remboursement partiel", () => {
  assert.deepEqual(validateRefundAmount("10", "428.93"), { valid: true, amount: "10.00" });
});

test("validateRefundAmount accepte la virgule décimale", () => {
  assert.deepEqual(validateRefundAmount("10,50", "428.93"), { valid: true, amount: "10.50" });
});

test("validateRefundAmount refuse un montant vide, nul ou trop élevé", () => {
  assert.equal(validateRefundAmount("", "428.93").valid, false);
  assert.equal(validateRefundAmount("0", "428.93").valid, false);
  assert.equal(validateRefundAmount("428.94", "428.93").valid, false);
});
