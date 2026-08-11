import test from "node:test";
import assert from "node:assert/strict";

import { normalizeLocationResults, popularLocations } from "../src/utils/locations.js";

test("les suggestions initiales privilégient les villes belges", () => {
  assert.equal(popularLocations[0].city, "Bruxelles");
  assert.equal(popularLocations[0].country_code, "BE");
  assert.ok(popularLocations.some((item) => item.country_code !== "BE"));
});

test("les résultats géographiques incomplets sont ignorés", () => {
  const results = normalizeLocationResults({ results: [
    { city: "Namur", label: "Namur, Belgique" },
    { city: "Ville sans libellé" },
    null,
  ] });

  assert.deepEqual(results, [{ city: "Namur", label: "Namur, Belgique" }]);
  assert.deepEqual(normalizeLocationResults(null), []);
});
