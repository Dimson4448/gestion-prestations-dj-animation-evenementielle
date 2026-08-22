import test from "node:test";
import assert from "node:assert/strict";

import { getTomorrowIsoDate, toLocalIsoDate } from "../src/utils/dates.js";

test("formate une date selon le calendrier local", () => {
  assert.equal(toLocalIsoDate(new Date(2026, 7, 22, 23, 30)), "2026-08-22");
});

test("propose le lendemain comme date de recherche", () => {
  assert.equal(getTomorrowIsoDate(new Date(2026, 7, 22, 23, 30)), "2026-08-23");
});

test("gère les changements de mois et d'année", () => {
  assert.equal(getTomorrowIsoDate(new Date(2026, 7, 31, 12)), "2026-09-01");
  assert.equal(getTomorrowIsoDate(new Date(2026, 11, 31, 12)), "2027-01-01");
});
