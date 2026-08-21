import assert from "node:assert/strict";
import test from "node:test";

import { getInterfaceRole, getPostLoginPage } from "../src/utils/authentication.js";

test("un membre de l'administration est reconnu avant son rôle métier", () => {
  assert.equal(getInterfaceRole({ is_staff: true, role: "client" }), "admin");
});

test("la connexion ouvre l'espace adapté au compte", () => {
  assert.equal(getPostLoginPage({ is_staff: true, role: "admin" }), "administration");
  assert.equal(getPostLoginPage({ is_staff: false, role: "dj" }), "dj");
  assert.equal(getPostLoginPage({ is_staff: false, role: "client" }), "compte");
});
