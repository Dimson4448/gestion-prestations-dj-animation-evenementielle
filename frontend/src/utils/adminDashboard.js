const numberValue = (value) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
};

export const getAdminDashboardMetrics = ({
  bookings = [], cancellationRequests = [], deletionRequests = [], djs = [], payments = [], quotes = [],
}, today = new Date()) => {
  const todayIso = today.toISOString().slice(0, 10);
  const paidPayments = payments.filter((payment) => ["paid", "refunded"].includes(payment.status));
  const grossRevenue = paidPayments.reduce((total, payment) => total + numberValue(payment.amount), 0);
  const refundedRevenue = payments.reduce((total, payment) => total + numberValue(payment.refunded_amount), 0);
  const confirmedBookings = bookings.filter((booking) => booking.status === "confirmed");
  const upcomingBookings = confirmedBookings
    .filter((booking) => booking.event_date >= todayIso)
    .sort((left, right) => left.event_date.localeCompare(right.event_date));

  return {
    activeDjs: djs.length,
    alerts: cancellationRequests.length + deletionRequests.length,
    confirmedBookings: confirmedBookings.length,
    grossRevenue,
    netRevenue: Math.max(grossRevenue - refundedRevenue, 0),
    pendingPayments: payments.filter((payment) => payment.status === "pending").length,
    pendingQuotes: quotes.length,
    refundedRevenue,
    upcomingBookings,
  };
};

export const getDashboardBarWidth = (value, maximum) => {
  if (!maximum || value <= 0) return 0;
  return Math.max(8, Math.round((value / maximum) * 100));
};

export const getMonthlyPaymentSeries = (payments = [], today = new Date(), monthCount = 6) => {
  const periods = Array.from({ length: monthCount }, (_, index) => {
    const date = new Date(today.getFullYear(), today.getMonth() - (monthCount - 1 - index), 1);
    const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
    return { key, date, paid: 0, refunded: 0 };
  });
  const byKey = new Map(periods.map((period) => [period.key, period]));
  payments.forEach((payment) => {
    if (!payment.paid_at) return;
    const period = byKey.get(String(payment.paid_at).slice(0, 7));
    if (!period) return;
    if (["paid", "refunded"].includes(payment.status)) period.paid += numberValue(payment.amount);
    period.refunded += numberValue(payment.refunded_amount);
  });
  return periods;
};
