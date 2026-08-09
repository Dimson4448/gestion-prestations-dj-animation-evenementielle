const trimTrailingSlashes = (value) => String(value || "").trim().replace(/\/+$/, "");

export const resolveBackendBaseUrl = (apiUrl, configuredBackendUrl, currentOrigin) => {
  const configured = trimTrailingSlashes(configuredBackendUrl);
  if (configured) return configured;

  try {
    return new URL(apiUrl, currentOrigin).origin;
  } catch {
    return trimTrailingSlashes(currentOrigin);
  }
};
