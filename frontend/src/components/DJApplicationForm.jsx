import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Headphones, ShieldCheck } from "lucide-react";

import { registerDJApplication } from "../api";
import { getAdultBirthDateMax } from "../utils/registration";

const initialApplication = {
  first_name: "", last_name: "", username: "", email: "", password: "", stage_name: "",
  date_of_birth: "", phone: "", city: "", preferred_language: "fr", bio: "", music_styles: "",
  base_hourly_rate: "", years_experience: "1", identity_document: null, insurance_document: null,
};
const adultBirthDateMax = getAdultBirthDateMax();

export default function DJApplicationForm({ onCompleted }) {
  const { t } = useTranslation();
  const [application, setApplication] = useState(initialApplication);
  const [pending, setPending] = useState(false);
  const [status, setStatus] = useState("");
  const [success, setSuccess] = useState(false);

  const update = (field, value) => setApplication((current) => ({ ...current, [field]: value }));

  const submit = async (event) => {
    event.preventDefault();
    const form = event.currentTarget;
    setPending(true);
    setStatus("");
    setSuccess(false);
    const payload = new FormData();
    Object.entries(application).forEach(([key, value]) => payload.append(key, value));
    try {
      const response = await registerDJApplication(payload);
      setStatus(t("djApplication.success"));
      setSuccess(true);
      setApplication(initialApplication);
      form.reset();
      onCompleted?.(response);
    } catch (error) {
      setStatus(t("djApplication.error"));
    } finally {
      setPending(false);
    }
  };

  return (
    <form className="account-card registration-card dj-application-card" onSubmit={submit}>
      <Headphones aria-hidden="true" />
      <h2>{t("djApplication.title")}</h2>
      <p>{t("djApplication.intro")}</p>
      <div className="registration-grid">
        <label>{t("djApplication.firstName")}<input value={application.first_name} onChange={(event) => update("first_name", event.target.value)} autoComplete="given-name" required /></label>
        <label>{t("djApplication.lastName")}<input value={application.last_name} onChange={(event) => update("last_name", event.target.value)} autoComplete="family-name" required /></label>
        <label>{t("djApplication.username")}<input value={application.username} onChange={(event) => update("username", event.target.value)} autoComplete="username" required /></label>
        <label>{t("djApplication.email")}<input type="email" value={application.email} onChange={(event) => update("email", event.target.value)} autoComplete="email" required /></label>
        <label className="full-field">{t("djApplication.password")}<input type="password" minLength="8" value={application.password} onChange={(event) => update("password", event.target.value)} autoComplete="new-password" required /></label>
        <label>{t("djApplication.stageName")}<input value={application.stage_name} onChange={(event) => update("stage_name", event.target.value)} required /></label>
        <label>{t("djApplication.birthDate")}<input type="date" max={adultBirthDateMax} value={application.date_of_birth} onChange={(event) => update("date_of_birth", event.target.value)} required /></label>
        <label>{t("djApplication.phone")}<input type="tel" value={application.phone} onChange={(event) => update("phone", event.target.value)} autoComplete="tel" required /></label>
        <label>{t("djApplication.city")}<input value={application.city} onChange={(event) => update("city", event.target.value)} autoComplete="address-level2" required /></label>
        <label>{t("djApplication.language")}<select value={application.preferred_language} onChange={(event) => update("preferred_language", event.target.value)}><option value="fr">Français</option><option value="en">English</option><option value="nl">Nederlands</option></select></label>
        <label>{t("djApplication.experience")}<input type="number" min="0" max="70" value={application.years_experience} onChange={(event) => update("years_experience", event.target.value)} required /></label>
        <label>{t("djApplication.rate")}<input type="number" min="0" step="0.01" value={application.base_hourly_rate} onChange={(event) => update("base_hourly_rate", event.target.value)} required /></label>
        <label className="full-field">{t("djApplication.styles")}<input value={application.music_styles} onChange={(event) => update("music_styles", event.target.value)} placeholder={t("djApplication.stylesPlaceholder")} required /></label>
        <label className="full-field">{t("djApplication.bio")}<textarea rows="4" minLength="30" value={application.bio} onChange={(event) => update("bio", event.target.value)} required /></label>
        <label>{t("djApplication.identity")}<input type="file" accept=".pdf,.jpg,.jpeg,.png" onChange={(event) => update("identity_document", event.target.files[0])} required /></label>
        <label>{t("djApplication.insurance")}<input type="file" accept=".pdf,.jpg,.jpeg,.png" onChange={(event) => update("insurance_document", event.target.files[0])} required /></label>
      </div>
      <p className="secure-note"><ShieldCheck aria-hidden="true" /> {t("djApplication.security")}</p>
      {status && <p className={`form-message${success ? " success" : ""}`} role="status">{status}</p>}
      <button className="primary-button" type="submit" disabled={pending}>{pending ? t("djApplication.sending") : t("djApplication.submit")}</button>
    </form>
  );
}
