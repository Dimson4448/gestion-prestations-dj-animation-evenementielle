import assert from "node:assert/strict";
import test from "node:test";

import { canSeeAdministrationLink } from "../src/utils/access.js";

test("l’administration est masquée aux visiteurs, clients et candidats DJ", () => {
  assert.equal(canSeeAdministrationLink(null), false);
  assert.equal(canSeeAdministrationLink({ role: "client", is_staff: false }), false);
  assert.equal(canSeeAdministrationLink({ role: "dj_candidate", is_staff: false }), false);
});

test("l’administration est visible aux administrateurs et DJ confirmés", () => {
  assert.equal(canSeeAdministrationLink({ role: "admin", is_staff: true }), true);
  assert.equal(canSeeAdministrationLink({ role: "dj", is_staff: false }), true);
});
