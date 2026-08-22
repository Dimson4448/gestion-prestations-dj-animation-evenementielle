import assert from "node:assert/strict";
import test from "node:test";

import { getPageFromLocation, getPageFromPath, getPagePath } from "../src/utils/navigation.js";

test("les pages internes possèdent une adresse lisible dans l'historique", () => {
  assert.equal(getPagePath("accueil"), "/");
  assert.equal(getPagePath("offres"), "/offres");
  assert.equal(getPageFromPath("/"), "accueil");
  assert.equal(getPageFromPath("/offres"), "offres");
  assert.equal(getPageFromPath("/compte/"), "compte");
});

test("les anciennes adresses avec dièse sont converties sans perdre la page", () => {
  assert.equal(getPageFromLocation("/", "#/compte"), "compte");
  assert.equal(getPageFromLocation("/", "#/administration"), "administration");
});

test("une adresse inconnue revient à l'accueil", () => {
  assert.equal(getPageFromPath(""), "accueil");
  assert.equal(getPageFromPath("/page-inconnue"), "accueil");
  assert.equal(getPagePath("page-inconnue"), "/");
});
