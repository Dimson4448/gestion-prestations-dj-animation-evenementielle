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

const safeNumber = (value) => {
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
};

export const calculateQuoteEstimate = ({ basePrice, includedHours, durationHours, distanceKm }) => {
  const base = Math.max(safeNumber(basePrice), 0);
  const duration = Math.max(safeNumber(durationHours), 0);
  const included = Math.max(safeNumber(includedHours), 0);
  const distance = Math.max(safeNumber(distanceKm), 0);
  const extraHours = Math.max(duration - included, 0);
  const subtotal = base + extraHours * 95;
  const travel = distance * 0.65;
  const total = subtotal + travel;

  return { subtotal, travel, total, deposit: total * 0.3 };
};

const preparedBookingStatuses = new Set(["confirmed", "performed", "paid"]);
const completedBookingStatuses = new Set(["performed", "paid"]);

export const canCreatePlaylist = (booking, existingBookingIds = new Set()) =>
  Boolean(
    booking?.deposit_paid
      && preparedBookingStatuses.has(booking.status)
      && !existingBookingIds.has(booking.id),
  );

export const canPlanAppointment = (booking, eventType, plannedBookingIds = new Set()) =>
  Boolean(
    booking?.deposit_paid
      && preparedBookingStatuses.has(booking.status)
      && eventType?.requires_preparatory_meeting
      && !plannedBookingIds.has(booking.id),
  );

export const canSubmitReview = (booking, reviewedBookingIds = new Set()) =>
  Boolean(
    completedBookingStatuses.has(booking?.status)
      && !reviewedBookingIds.has(booking.id),
  );

export const mapAvailableDjs = (slots) => {
  if (!Array.isArray(slots)) return [];

  const djsById = new Map();
  slots.forEach((slot) => {
    if (!slot?.dj || djsById.has(slot.dj.id)) return;
    djsById.set(slot.dj.id, {
      id: slot.dj.id,
      name: slot.dj.stage_name,
      styles: slot.dj.music_styles?.map((style) => style.name).join(" · ") || "Généraliste",
      slot: `${String(slot.start_time).slice(0, 5)}–${String(slot.end_time).slice(0, 5)}`,
      rating: slot.dj.average_rating == null
        ? null
        : Number(slot.dj.average_rating).toLocaleString("fr-BE", { maximumFractionDigits: 1 }),
      reviews: Number(slot.dj.review_count) || 0,
    });
  });

  return Array.from(djsById.values());
};
