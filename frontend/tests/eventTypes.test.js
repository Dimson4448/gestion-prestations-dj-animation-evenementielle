import test from "node:test";
import assert from "node:assert/strict";

import { allowedEventTypeNames, filterAllowedEventTypes } from "../src/utils/eventTypes.js";

test("le cahier des charges contient exactement quatre prestations", () => {
  assert.deepEqual(allowedEventTypeNames, [
    "Anniversaire enfant",
    "Anniversaire adulte",
    "Mariage",
    "Soirée privée",
  ]);
});

test("les prestations hors périmètre sont exclues des réponses frontend", () => {
  const records = filterAllowedEventTypes([
    { id: 1, name: "Mariage" },
    { id: 2, name: "Soirée d’entreprise" },
    { id: 3, name: "Anniversaire enfant" },
  ]);

  assert.deepEqual(records, [
    { id: 1, name: "Mariage" },
    { id: 3, name: "Anniversaire enfant" },
  ]);
  assert.deepEqual(filterAllowedEventTypes(null), []);
});
