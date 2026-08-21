import assert from "node:assert/strict";
import test from "node:test";

import { getAdminDashboardMetrics, getDashboardBarWidth, getMonthlyPaymentSeries } from "../src/utils/adminDashboard.js";

test("le tableau de bord calcule ses indicateurs avec les données métier", () => {
  const metrics = getAdminDashboardMetrics({
    bookings: [{ id: 1, status: "confirmed", event_date: "2026-09-10" }, { id: 2, status: "completed", event_date: "2026-07-10" }],
    cancellationRequests: [{ id: 1 }], deletionRequests: [{ id: 2 }], djs: [{ id: 1 }, { id: 2 }],
    payments: [{ status: "paid", amount: "500", refunded_amount: "100" }, { status: "pending", amount: "200", refunded_amount: "0" }],
    quotes: [{ id: 1 }, { id: 2 }, { id: 3 }],
  }, new Date("2026-08-20T12:00:00Z"));
  assert.equal(metrics.pendingQuotes, 3);
  assert.equal(metrics.upcomingBookings.length, 1);
  assert.equal(metrics.activeDjs, 2);
  assert.equal(metrics.alerts, 2);
  assert.equal(metrics.netRevenue, 400);
  assert.equal(metrics.pendingPayments, 1);
});

test("les barres restent lisibles sans dépasser leur conteneur", () => {
  assert.equal(getDashboardBarWidth(0, 10), 0);
  assert.equal(getDashboardBarWidth(1, 10), 10);
  assert.equal(getDashboardBarWidth(10, 10), 100);
});

test("les transactions sont regroupées par mois pour le graphique financier", () => {
  const series = getMonthlyPaymentSeries([
    { status: "paid", amount: "600", refunded_amount: "100", paid_at: "2026-07-12T10:00:00Z" },
    { status: "paid", amount: "300", refunded_amount: "0", paid_at: "2026-08-03T10:00:00Z" },
  ], new Date("2026-08-20T12:00:00Z"), 3);
  assert.deepEqual(series.map(({ key, paid, refunded }) => ({ key, paid, refunded })), [
    { key: "2026-06", paid: 0, refunded: 0 },
    { key: "2026-07", paid: 600, refunded: 100 },
    { key: "2026-08", paid: 300, refunded: 0 },
  ]);
});
