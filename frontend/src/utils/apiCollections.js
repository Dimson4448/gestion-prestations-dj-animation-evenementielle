export function unwrapApiList(payload) {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.results)) return payload.results;
  return [];
}

export function isUserInRole(isAuthenticated, user, role) {
  return Boolean(isAuthenticated && user?.role === role);
}
