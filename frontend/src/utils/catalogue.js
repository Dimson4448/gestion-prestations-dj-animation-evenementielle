const packageAccents = ["cyan", "magenta", "gold"];

export const decoratePackages = (records) => {
  if (!Array.isArray(records)) return [];

  return records.map((item, index) => ({
    ...item,
    accent: packageAccents[index % packageAccents.length],
  }));
};
