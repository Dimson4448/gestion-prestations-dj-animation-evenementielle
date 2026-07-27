import axios from "axios";

const defaultApiBaseUrl = "http://localhost:8000/api/v1";

export const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL || defaultApiBaseUrl).replace(/\/$/, "");

export const apiClient = axios.create({
  baseURL: apiBaseUrl,
  headers: {
    "Content-Type": "application/json",
  },
});

const accessTokenKey = "ultimate_dj_access_token";
const refreshTokenKey = "ultimate_dj_refresh_token";

export const getStoredAccessToken = () => window.localStorage.getItem(accessTokenKey);

export const authenticate = async (username, password) => {
  const response = await apiClient.post("/auth/token/", { username, password });
  window.localStorage.setItem(accessTokenKey, response.data.access);
  window.localStorage.setItem(refreshTokenKey, response.data.refresh);
  apiClient.defaults.headers.common.Authorization = `Bearer ${response.data.access}`;
  return getCurrentUser();
};

export const getCurrentUser = async () => (await apiClient.get("/auth/me/")).data;

export const clearAuthentication = () => {
  window.localStorage.removeItem(accessTokenKey);
  window.localStorage.removeItem(refreshTokenKey);
  delete apiClient.defaults.headers.common.Authorization;
};

const storedAccessToken = getStoredAccessToken();
if (storedAccessToken) {
  apiClient.defaults.headers.common.Authorization = `Bearer ${storedAccessToken}`;
}
