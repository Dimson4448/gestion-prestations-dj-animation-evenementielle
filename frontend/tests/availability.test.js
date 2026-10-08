import assert from "node:assert/strict";
import test from "node:test";

import { isHistoricalAvailability, validateAvailabilityTimes } from "../src/utils/availability.js";

test("un créneau terminé après son début est accepté", () => {
  assert.equal(validateAvailabilityTimes("2026-08-22", "17:00", "2026-08-22", "23:00").valid, true);
});

test("un créneau nocturne allant au lendemain est accepté", () => {
  assert.equal(validateAvailabilityTimes("2026-08-22", "17:00", "2026-08-23", "05:00").valid, true);
});

test("une date de fin antérieure est refusée", () => {
  assert.equal(validateAvailabilityTimes("2026-08-22", "17:00", "2026-08-21", "20:00").valid, false);
});

test("un créneau antérieur à demain est classé dans l'historique", () => {
  assert.equal(isHistoricalAvailability({ available_date: "2026-10-07" }, "2026-10-08"), true);
  assert.equal(isHistoricalAvailability({ available_date: "2026-10-08" }, "2026-10-08"), false);
});
