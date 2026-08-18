export const getAdultBirthDateMax = (referenceDate = new Date()) => {
  const cutoff = new Date(referenceDate);
  cutoff.setFullYear(cutoff.getFullYear() - 18);
  const year = cutoff.getFullYear();
  const month = String(cutoff.getMonth() + 1).padStart(2, "0");
  const day = String(cutoff.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};
