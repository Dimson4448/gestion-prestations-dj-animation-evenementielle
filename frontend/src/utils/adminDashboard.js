const numberValue = (value) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
};

export const getAdminDashboardMetrics = ({
  allQuotes = [], bookings = [], cancellationRequests = [], deletionRequests = [], djs = [], payments = [], quotes = [], reviews = [],
}, today = new Date()) => {
  const todayIso = today.toISOString().slice(0, 10);
  const paidPayments = payments.filter((payment) => ["paid", "refunded"].includes(payment.status));
  const grossRevenue = paidPayments.reduce((total, payment) => total + numberValue(payment.amount), 0);
  const refundedRevenue = payments.reduce((total, payment) => total + numberValue(payment.refunded_amount), 0);
  const confirmedBookings = bookings.filter((booking) => booking.status === "confirmed");
  const completedBookings = bookings.filter((booking) => ["performed", "paid"].includes(booking.status));
  const upcomingBookings = confirmedBookings
    .filter((booking) => booking.event_date >= todayIso)
    .sort((left, right) => left.event_date.localeCompare(right.event_date));

  return {
    activeDjs: djs.length,
    alerts: cancellationRequests.length + deletionRequests.length,
    confirmedBookings: confirmedBookings.length,
    completedBookings: completedBookings.length,
    quoteConversionRate: allQuotes.length ? Math.round((bookings.length / allQuotes.length) * 100) : 0,
    reviewAverage: reviews.length ? (reviews.reduce((total, review) => total + numberValue(review.rating), 0) / reviews.length).toFixed(1) : null,
    reviewsByDj: djs.map((dj) => {
      const djReviews = reviews.filter((review) => Number(review.dj) === Number(dj.id));
      return { id: dj.id, name: dj.stage_name, count: djReviews.length, average: djReviews.length ? (djReviews.reduce((total, review) => total + numberValue(review.rating), 0) / djReviews.length).toFixed(1) : null };
    }).sort((left, right) => Number(right.average || 0) - Number(left.average || 0)),
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
