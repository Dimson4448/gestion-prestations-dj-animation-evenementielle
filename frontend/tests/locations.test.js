import test from "node:test";
import assert from "node:assert/strict";

import { getPopularLocations, normalizeLocationResults, translatePopularLocation } from "../src/utils/locations.js";

test("les suggestions initiales privilégient les villes belges", () => {
  const popularLocations = getPopularLocations("fr");
  assert.equal(popularLocations[0].city, "Bruxelles");
  assert.equal(popularLocations[0].country_code, "BE");
  assert.ok(popularLocations.some((item) => item.country_code !== "BE"));
});

test("les villes populaires sont traduites en anglais et en néerlandais", () => {
  assert.equal(getPopularLocations("en")[0].label, "Brussels, Belgium");
  assert.equal(getPopularLocations("nl")[0].label, "Brussel, België");
  assert.equal(getPopularLocations("nl")[1].city, "Antwerpen");
  assert.equal(translatePopularLocation("Bruxelles", "en"), "Brussels");
  assert.equal(translatePopularLocation("Antwerp", "nl"), "Antwerpen");
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
