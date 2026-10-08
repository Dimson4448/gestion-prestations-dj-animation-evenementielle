import { BellRing } from "lucide-react";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";

import { apiClient } from "../api";

const fields = ["email_enabled", "internal_enabled", "booking_enabled", "payment_enabled", "review_enabled"];

export default function NotificationPreferences() {
  const { t } = useTranslation();
  const [preferences, setPreferences] = useState(null);
  const [status, setStatus] = useState("");

  useEffect(() => {
    let active = true;
    apiClient.get("/auth/notification-preferences/")
      .then((response) => active && setPreferences(response.data))
      .catch(() => active && setStatus(t("notificationPreferences.loadError")));
    return () => { active = false; };
  }, [t]);

  const updatePreference = async (field) => {
    const nextValue = !preferences[field];
    setPreferences((current) => ({ ...current, [field]: nextValue }));
    setStatus("");
    try {
      const response = await apiClient.patch("/auth/notification-preferences/", { [field]: nextValue });
      setPreferences(response.data);
      setStatus(t("notificationPreferences.saved"));
    } catch {
      setPreferences((current) => ({ ...current, [field]: !nextValue }));
      setStatus(t("notificationPreferences.saveError"));
    }
  };

  return <section className="notification-preferences" aria-labelledby="notification-preferences-title">
    <div className="playlist-heading"><div><h2 id="notification-preferences-title">{t("notificationPreferences.title")}</h2><p>{t("notificationPreferences.intro")}</p></div><BellRing /></div>
    {!preferences && !status && <p className="invoice-empty">{t("notificationPreferences.loading")}</p>}
    {preferences && <div className="notification-preferences-list">{fields.map((field) => <label key={field}><input type="checkbox" checked={Boolean(preferences[field])} onChange={() => updatePreference(field)} /> <span>{t(`notificationPreferences.fields.${field}`)}</span></label>)}</div>}
    {status && <p className="form-message success" role="status">{status}</p>}
  </section>;
}
