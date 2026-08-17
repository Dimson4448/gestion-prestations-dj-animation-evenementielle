export const canSeeAdministrationLink = (user) => Boolean(
  user?.is_staff || user?.role === "dj",
);
