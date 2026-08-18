import assert from "node:assert/strict";
import test from "node:test";

import { getAdultBirthDateMax } from "../src/utils/registration.js";

test("la date de naissance maximale correspond exactement à 18 ans", () => {
  assert.equal(getAdultBirthDateMax(new Date(2026, 7, 17)), "2008-08-17");
});

test("une date récente comme 2026 dépasse la limite autorisée", () => {
  const maximum = getAdultBirthDateMax(new Date(2026, 7, 17));
  assert.ok("2026-01-01" > maximum);
});
