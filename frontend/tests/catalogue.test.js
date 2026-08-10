import test from "node:test";
import assert from "node:assert/strict";

import { decoratePackages, filterPackagesForEventType } from "../src/utils/catalogue.js";

test("decoratePackages ajoute seulement une couleur de présentation", () => {
  const records = decoratePackages([{ id: 4, name: "Formule réelle", base_price: "600.00" }]);

  assert.deepEqual(records, [{ id: 4, name: "Formule réelle", base_price: "600.00", accent: "cyan" }]);
  assert.equal(records[0].rating, undefined);
  assert.equal(records[0].event, undefined);
});

test("decoratePackages refuse une réponse API invalide", () => {
  assert.deepEqual(decoratePackages(null), []);
});

test("filterPackagesForEventType conserve uniquement les formules compatibles", () => {
  const packages = [
    { id: 1, name: "Classic", event_types: [1, 10, 11, 16] },
    { id: 2, name: "Mariage Gold", event_types: [10] },
  ];

  assert.deepEqual(filterPackagesForEventType(packages, 11), [packages[0]]);
  assert.deepEqual(filterPackagesForEventType(packages, 10), packages);
});
