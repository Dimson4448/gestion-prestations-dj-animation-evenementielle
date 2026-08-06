import test from "node:test";
import assert from "node:assert/strict";

import {
  calculateQuoteEstimate,
  canCreatePlaylist,
  canPlanAppointment,
  canSubmitReview,
  formatEuro,
  hasBookingEnded,
} from "../src/utils/booking.js";

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

test("calculateQuoteEstimate calcule les heures, le déplacement et l'acompte", () => {
  const estimate = calculateQuoteEstimate({
    basePrice: "790.00",
    includedHours: "6.0",
    durationHours: 8,
    distanceKm: 20,
  });

  assert.deepEqual(estimate, {
    subtotal: 980,
    travel: 13,
    total: 993,
    deposit: 297.9,
  });
});

test("calculateQuoteEstimate ne facture pas d'heure incluse", () => {
  const estimate = calculateQuoteEstimate({
    basePrice: 450,
    includedHours: 4,
    durationHours: 3,
    distanceKm: 0,
  });

  assert.equal(estimate.subtotal, 450);
  assert.equal(estimate.total, 450);
  assert.equal(estimate.deposit, 135);
});

test("calculateQuoteEstimate neutralise les valeurs invalides ou négatives", () => {
  const estimate = calculateQuoteEstimate({
    basePrice: "invalide",
    includedHours: -2,
    durationHours: -4,
    distanceKm: -10,
  });

  assert.deepEqual(estimate, { subtotal: 0, travel: 0, total: 0, deposit: 0 });
});

test("canCreatePlaylist exige un acompte et évite les doublons", () => {
  const booking = { id: 12, status: "confirmed", deposit_paid: true };

  assert.equal(canCreatePlaylist(booking), true);
  assert.equal(canCreatePlaylist({ ...booking, deposit_paid: false }), false);
  assert.equal(canCreatePlaylist(booking, new Set([12])), false);
});

test("canPlanAppointment respecte le type d'événement et les rendez-vous existants", () => {
  const booking = { id: 18, status: "confirmed", deposit_paid: true };
  const requiredType = { requires_preparatory_meeting: true };

  assert.equal(canPlanAppointment(booking, requiredType), true);
  assert.equal(canPlanAppointment(booking, { requires_preparatory_meeting: false }), false);
  assert.equal(canPlanAppointment(booking, requiredType, new Set([18])), false);
});

test("canSubmitReview attend la réalisation et évite un second avis", () => {
  const performed = { id: 25, status: "performed" };

  assert.equal(canSubmitReview(performed), true);
  assert.equal(canSubmitReview({ ...performed, status: "confirmed" }), false);
  assert.equal(canSubmitReview(performed, new Set([25])), false);
});
