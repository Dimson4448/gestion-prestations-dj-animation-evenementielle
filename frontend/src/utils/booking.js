export const formatEuro = (value) =>
  new Intl.NumberFormat("fr-BE", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format(Number(value || 0));

export const hasBookingEnded = (booking, now = new Date()) => {
  if (!booking?.event_date) return false;

  const end = new Date(`${booking.event_date}T${booking.end_time || "23:59:59"}`);
  return !Number.isNaN(end.getTime()) && end <= now;
};
