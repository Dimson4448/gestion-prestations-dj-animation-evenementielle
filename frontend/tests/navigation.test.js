import assert from "node:assert/strict";
import test from "node:test";

import { getPageFromHash, getPageHash } from "../src/utils/navigation.js";

test("les pages internes possèdent une adresse dans l'historique", () => {
  assert.equal(getPageHash("accueil"), "#/accueil");
  assert.equal(getPageHash("offres"), "#/offres");
  assert.equal(getPageFromHash("#/accueil"), "accueil");
  assert.equal(getPageFromHash("#/offres"), "offres");
});

test("une adresse inconnue revient à l'accueil", () => {
  assert.equal(getPageFromHash(""), "accueil");
  assert.equal(getPageFromHash("#/page-inconnue"), "accueil");
  assert.equal(getPageHash("page-inconnue"), "#/accueil");
});
