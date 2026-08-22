import test from "node:test";
import assert from "node:assert/strict";

import {
  calculateQuoteEstimate,
  canCreatePlaylist,
  canPlanAppointment,
  canSubmitReview,
  formatEuro,
  hasBookingEnded,
  mapAvailableDjs,
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
  const performed = {
    id: 25,
    status: "performed",
    event_date: "2026-01-01",
    end_date: "2026-01-02",
    end_time: "02:00:00",
  };

  assert.equal(canSubmitReview(performed), true);
  assert.equal(canSubmitReview({ ...performed, event_date: "2099-01-01", end_date: "2099-01-02" }), false);
  assert.equal(canSubmitReview({ ...performed, status: "confirmed", deposit_paid: true, event_date: "2099-01-01", end_date: "2099-01-02" }, new Set(), true), true);
  assert.equal(canSubmitReview({ ...performed, status: "confirmed" }), false);
  assert.equal(canSubmitReview(performed, new Set([25])), false);
});

test("mapAvailableDjs transforme les créneaux Django sans dupliquer un DJ", () => {
  const dj = {
    id: 7,
    stage_name: "DJ Réel",
    music_styles: [{ id: 1, name: "House" }, { id: 2, name: "Disco" }],
    average_rating: 4.5,
    review_count: 8,
  };
  const records = mapAvailableDjs([
    { id: 10, dj, start_time: "18:00:00", end_time: "23:30:00" },
    { id: 11, dj, start_time: "20:00:00", end_time: "23:59:00" },
  ]);

  assert.deepEqual(records, [{
    id: 7,
    name: "DJ Réel",
    styles: "House · Disco",
    slot: "18:00–23:30",
    rating: "4,5",
    reviews: 8,
  }]);
});

test("mapAvailableDjs conserve un profil sans avis publié", () => {
  const records = mapAvailableDjs([{
    id: 12,
    dj: { id: 9, stage_name: "DJ Début", music_styles: [], average_rating: null, review_count: 0 },
    start_time: "19:00:00",
    end_time: "23:00:00",
  }]);

  assert.equal(records[0].rating, null);
  assert.equal(records[0].reviews, 0);
});

test("mapAvailableDjs ignore les créneaux incomplets et accepte une réponse invalide", () => {
  assert.deepEqual(mapAvailableDjs(null), []);
  assert.deepEqual(mapAvailableDjs([{ id: 1, dj: null }]), []);
});
