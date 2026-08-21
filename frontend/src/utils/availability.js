export function validateAvailabilityTimes(startDate, startTime, endDate, endTime) {
  if (!startTime || !endTime) {
    return { valid: false, error: "Indiquez une heure de début et une heure de fin." };
  }
  if (!startDate || !endDate || endDate < startDate) {
    return { valid: false, error: "La date de fin ne peut pas précéder la date de début." };
  }
  if (endDate === startDate && endTime <= startTime) {
    return {
      valid: false,
      error: "Sur une même date, l’heure de fin doit être postérieure à l’heure de début.",
    };
  }
  return { valid: true, error: "" };
}
