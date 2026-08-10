const packageAccents = ["cyan", "magenta", "gold"];

export const decoratePackages = (records) => {
  if (!Array.isArray(records)) return [];

  return records.map((item, index) => ({
    ...item,
    accent: packageAccents[index % packageAccents.length],
  }));
};

export const filterPackagesForEventType = (packages, eventTypeId) => {
  if (!Array.isArray(packages)) return [];
  if (!eventTypeId) return packages;

  return packages.filter((item) => (
    Array.isArray(item.event_types)
    && item.event_types.some((id) => String(id) === String(eventTypeId))
  ));
};
