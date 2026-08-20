import assert from "node:assert/strict";
import test from "node:test";

import { isUserInRole, unwrapApiList } from "../src/utils/apiCollections.js";

test("unwrapApiList accepte une réponse Django REST paginée", () => {
  assert.deepEqual(unwrapApiList({ count: 2, results: [{ id: 1 }, { id: 2 }] }), [{ id: 1 }, { id: 2 }]);
});

test("unwrapApiList accepte aussi un tableau direct", () => {
  assert.deepEqual(unwrapApiList([{ id: 3 }]), [{ id: 3 }]);
});

test("unwrapApiList neutralise une réponse API inattendue", () => {
  assert.deepEqual(unwrapApiList(null), []);
  assert.deepEqual(unwrapApiList({ detail: "Erreur" }), []);
});

test("isUserInRole exige une session et le rôle attendu", () => {
  assert.equal(isUserInRole(true, { role: "client" }, "client"), true);
  assert.equal(isUserInRole(false, { role: "client" }, "client"), false);
  assert.equal(isUserInRole(true, { role: "dj" }, "client"), false);
});
