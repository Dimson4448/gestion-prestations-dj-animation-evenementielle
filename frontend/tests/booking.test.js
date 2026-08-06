import test from "node:test";
import assert from "node:assert/strict";

import { formatEuro, hasBookingEnded } from "../src/utils/booking.js";

test("formatEuro formate un montant en euros sans décimales", () => {
  const formatted = formatEuro("1190.00").replaceAll("\u00a0", " ").replaceAll("\u202f", " ");

  assert.equal(formatted, "1 190 €");
});

test("formatEuro remplace une valeur absente par zéro", () => {
  assert.match(formatEuro(null), /0/);
});

test("hasBookingEnded accepte une prestation dont l'heure de fin est passée", () => {
  const booking = { event_date: "2026-08-06", end_time: "22:00:00" };

  assert.equal(hasBookingEnded(booking, new Date("2026-08-06T22:00:01")), true);
});

test("hasBookingEnded refuse une prestation encore en cours", () => {
  const booking = { event_date: "2026-08-06", end_time: "22:00:00" };

  assert.equal(hasBookingEnded(booking, new Date("2026-08-06T21:59:59")), false);
});

test("hasBookingEnded refuse une réservation sans date valide", () => {
  assert.equal(hasBookingEnded({}, new Date("2026-08-06T22:00:01")), false);
  assert.equal(hasBookingEnded({ event_date: "date-invalide" }), false);
});
