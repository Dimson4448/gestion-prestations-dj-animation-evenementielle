export const allowedEventTypeNames = [
  "Anniversaire enfant",
  "Anniversaire adulte",
  "Mariage",
  "Soirée privée",
];

export const filterAllowedEventTypes = (records) => {
  if (!Array.isArray(records)) return [];
  return records.filter((item) => allowedEventTypeNames.includes(item?.name));
};
