import test from "node:test";
import assert from "node:assert/strict";

import { decoratePackages } from "../src/utils/catalogue.js";

test("decoratePackages ajoute seulement une couleur de présentation", () => {
  const records = decoratePackages([{ id: 4, name: "Formule réelle", base_price: "600.00" }]);

  assert.deepEqual(records, [{ id: 4, name: "Formule réelle", base_price: "600.00", accent: "cyan" }]);
  assert.equal(records[0].rating, undefined);
  assert.equal(records[0].event, undefined);
});

test("decoratePackages refuse une réponse API invalide", () => {
  assert.deepEqual(decoratePackages(null), []);
});
