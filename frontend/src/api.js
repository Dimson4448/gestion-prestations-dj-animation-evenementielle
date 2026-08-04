import axios from "axios";

const defaultApiBaseUrl = "http://localhost:8000/api/v1";

export const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL || defaultApiBaseUrl).replace(/\/$/, "");

export const apiClient = axios.create({
  baseURL: apiBaseUrl,
  headers: {
    "Content-Type": "application/json",
  },
});
const refreshClient = axios.create({ baseURL: apiBaseUrl, headers: { "Content-Type": "application/json" } });

const accessTokenKey = "ultimate_dj_access_token";
const refreshTokenKey = "ultimate_dj_refresh_token";

export const getStoredAccessToken = () => window.localStorage.getItem(accessTokenKey);
export const getStoredRefreshToken = () => window.localStorage.getItem(refreshTokenKey);
export const sessionExpiredEvent = "ultimate-dj:session-expired";

const storeTokens = ({ access, refresh }) => {
  if (access) window.localStorage.setItem(accessTokenKey, access);
  if (refresh) window.localStorage.setItem(refreshTokenKey, refresh);
  if (access) apiClient.defaults.headers.common.Authorization = `Bearer ${access}`;
};

export const authenticate = async (username, password) => {
  const response = await apiClient.post("/auth/token/", { username, password });
  storeTokens(response.data);
  return getCurrentUser();
};

export const getCurrentUser = async () => (await apiClient.get("/auth/me/")).data;

export const clearAuthentication = () => {
  window.localStorage.removeItem(accessTokenKey);
  window.localStorage.removeItem(refreshTokenKey);
  delete apiClient.defaults.headers.common.Authorization;
};

export const registerClient = async (payload) => (await apiClient.post("/auth/register/", payload)).data;

export const logout = async () => {
  const refresh = getStoredRefreshToken();
  try {
    if (refresh) await apiClient.post("/auth/logout/", { refresh });
  } finally {
    clearAuthentication();
  }
};

const storedAccessToken = getStoredAccessToken();
if (storedAccessToken) {
  apiClient.defaults.headers.common.Authorization = `Bearer ${storedAccessToken}`;
}

let refreshPromise = null;

apiClient.interceptors.request.use((config) => {
  const access = getStoredAccessToken();
  if (access) config.headers.Authorization = `Bearer ${access}`;
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    const isAuthenticationRequest = originalRequest?.url?.includes("/auth/token/");
    if (error.response?.status !== 401 || originalRequest?._retry || isAuthenticationRequest) {
      return Promise.reject(error);
    }

    const refresh = getStoredRefreshToken();
    if (!refresh) {
      clearAuthentication();
      window.dispatchEvent(new CustomEvent(sessionExpiredEvent));
      return Promise.reject(error);
    }

    originalRequest._retry = true;
    if (!refreshPromise) {
      refreshPromise = refreshClient
        .post("/auth/token/refresh/", { refresh })
        .then((response) => {
          storeTokens(response.data);
          return response.data.access;
        })
        .finally(() => {
          refreshPromise = null;
        });
    }

    try {
      const access = await refreshPromise;
      originalRequest.headers.Authorization = `Bearer ${access}`;
      return apiClient(originalRequest);
    } catch (refreshError) {
      clearAuthentication();
      window.dispatchEvent(new CustomEvent(sessionExpiredEvent));
      return Promise.reject(refreshError);
    }
  },
);
