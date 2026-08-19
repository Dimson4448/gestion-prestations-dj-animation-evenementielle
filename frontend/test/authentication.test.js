import assert from "node:assert/strict";
import test from "node:test";

import { getAccountSummaryKey, getInterfaceRole, getLoginSuccessKey } from "../src/utils/authentication.js";

test("le rôle administrateur est prioritaire sur le profil métier", () => {
  assert.equal(getInterfaceRole({ role: "client", is_staff: true }), "admin");
});

test("les rôles client, DJ et candidat DJ sont conservés", () => {
  assert.equal(getInterfaceRole({ role: "client", is_staff: false }), "client");
  assert.equal(getInterfaceRole({ role: "dj", is_staff: false }), "dj");
  assert.equal(getInterfaceRole({ role: "dj_candidate", is_staff: false }), "dj_candidate");
});

test("les clés de traduction correspondent au rôle connecté", () => {
  const candidate = { role: "dj_candidate", is_staff: false };
  assert.equal(getLoginSuccessKey(candidate), "authentication.loginSuccess.dj_candidate");
  assert.equal(getAccountSummaryKey(candidate), "authentication.accountSummary.dj_candidate");
});

test("un rôle inconnu utilise le parcours client sans ouvrir un espace privilégié", () => {
  assert.equal(getInterfaceRole({ role: "unknown", is_staff: false }), "client");
});
