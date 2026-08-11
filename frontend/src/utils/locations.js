const popularLocationNames = {
  fr: [
    ["Bruxelles", "Belgique", "BE"], ["Anvers", "Belgique", "BE"], ["Gand", "Belgique", "BE"], ["Liège", "Belgique", "BE"], ["Charleroi", "Belgique", "BE"], ["Namur", "Belgique", "BE"],
    ["Paris", "France", "FR"], ["Amsterdam", "Pays-Bas", "NL"], ["Londres", "Royaume-Uni", "GB"], ["New York", "États-Unis", "US"],
  ],
  en: [
    ["Brussels", "Belgium", "BE"], ["Antwerp", "Belgium", "BE"], ["Ghent", "Belgium", "BE"], ["Liège", "Belgium", "BE"], ["Charleroi", "Belgium", "BE"], ["Namur", "Belgium", "BE"],
    ["Paris", "France", "FR"], ["Amsterdam", "Netherlands", "NL"], ["London", "United Kingdom", "GB"], ["New York", "United States", "US"],
  ],
  nl: [
    ["Brussel", "België", "BE"], ["Antwerpen", "België", "BE"], ["Gent", "België", "BE"], ["Luik", "België", "BE"], ["Charleroi", "België", "BE"], ["Namen", "België", "BE"],
    ["Parijs", "Frankrijk", "FR"], ["Amsterdam", "Nederland", "NL"], ["Londen", "Verenigd Koninkrijk", "GB"], ["New York", "Verenigde Staten", "US"],
  ],
};

export const getPopularLocations = (language = "fr") => (
  popularLocationNames[language] || popularLocationNames.fr
).map(([city, country, country_code]) => ({ city, label: `${city}, ${country}`, country_code }));

export const translatePopularLocation = (value, language = "fr") => {
  const locationIndex = Object.values(popularLocationNames).reduce((foundIndex, locations) => {
    if (foundIndex >= 0) return foundIndex;
    return locations.findIndex(([city]) => city.localeCompare(value, undefined, { sensitivity: "base" }) === 0);
  }, -1);
  if (locationIndex < 0) return value;
  const targetLocations = popularLocationNames[language] || popularLocationNames.fr;
  return targetLocations[locationIndex]?.[0] || value;
};

export const normalizeLocationResults = (payload) => (
  Array.isArray(payload?.results)
    ? payload.results.filter((item) => item && typeof item.city === "string" && typeof item.label === "string")
    : []
);
