export const popularLocations = [
  { city: "Bruxelles", label: "Bruxelles, Belgique", country_code: "BE" },
  { city: "Anvers", label: "Anvers, Belgique", country_code: "BE" },
  { city: "Gand", label: "Gand, Belgique", country_code: "BE" },
  { city: "Liège", label: "Liège, Belgique", country_code: "BE" },
  { city: "Charleroi", label: "Charleroi, Belgique", country_code: "BE" },
  { city: "Namur", label: "Namur, Belgique", country_code: "BE" },
  { city: "Paris", label: "Paris, France", country_code: "FR" },
  { city: "Amsterdam", label: "Amsterdam, Pays-Bas", country_code: "NL" },
  { city: "Londres", label: "Londres, Royaume-Uni", country_code: "GB" },
  { city: "New York", label: "New York, États-Unis", country_code: "US" },
];

export const normalizeLocationResults = (payload) => (
  Array.isArray(payload?.results)
    ? payload.results.filter((item) => item && typeof item.city === "string" && typeof item.label === "string")
    : []
);
