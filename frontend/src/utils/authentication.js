const knownRoles = new Set(["client", "dj", "dj_candidate"]);

export const getInterfaceRole = (user) => {
  if (user?.is_staff) return "admin";
  return knownRoles.has(user?.role) ? user.role : "client";
};

export const getLoginSuccessKey = (user) => `authentication.loginSuccess.${getInterfaceRole(user)}`;

export const getAccountSummaryKey = (user) => `authentication.accountSummary.${getInterfaceRole(user)}`;

export const getPostLoginPage = (user) => {
  const role = getInterfaceRole(user);
  if (role === "admin") return "administration";
  if (role === "dj") return "dj";
  return "compte";
};
