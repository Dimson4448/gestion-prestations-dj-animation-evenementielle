import { useEffect, useId, useMemo, useRef, useState } from "react";
import { LoaderCircle, MapPin } from "lucide-react";
import { useTranslation } from "react-i18next";

import { searchLocations } from "../api";
import { getPopularLocations, normalizeLocationResults, translatePopularLocation } from "../utils/locations";

export default function CityAutocomplete({ label, value, onChange, required = false }) {
  const { t, i18n } = useTranslation();
  const popularLocations = useMemo(() => getPopularLocations(i18n.language), [i18n.language]);
  const inputId = useId();
  const listboxId = useId();
  const requestId = useRef(0);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [hasTyped, setHasTyped] = useState(false);
  const [results, setResults] = useState(popularLocations);
  const [status, setStatus] = useState("");

  useEffect(() => {
    const translatedValue = translatePopularLocation(value, i18n.language);
    if (!hasTyped && translatedValue !== value) onChange(translatedValue);
  }, [hasTyped, i18n.language, onChange, value]);

  useEffect(() => {
    const query = value.trim();
    if (!isOpen || !hasTyped || query.length < 2) {
      setResults(popularLocations);
      setStatus("");
      setIsLoading(false);
      return undefined;
    }

    const currentRequest = ++requestId.current;
    const timer = window.setTimeout(async () => {
      setIsLoading(true);
      setStatus("");
      try {
        const payload = await searchLocations(query);
        if (currentRequest !== requestId.current) return;
        const nextResults = normalizeLocationResults(payload);
        setResults(nextResults);
        setStatus(nextResults.length ? "" : t("home.locationNoResults"));
      } catch {
        if (currentRequest !== requestId.current) return;
        setResults([]);
        setStatus(t("home.locationUnavailable"));
      } finally {
        if (currentRequest === requestId.current) setIsLoading(false);
      }
    }, 400);

    return () => window.clearTimeout(timer);
  }, [hasTyped, isOpen, popularLocations, t, value]);

  const selectLocation = (item) => {
    onChange(item.city);
    setHasTyped(false);
    setIsOpen(false);
  };

  return (
    <div className="location-field">
      <label htmlFor={inputId}>{label}</label>
      <div className="city-autocomplete">
        <input
        id={inputId}
        value={value}
        onChange={(event) => { onChange(event.target.value); setHasTyped(true); setIsOpen(true); }}
        onFocus={() => setIsOpen(true)}
        onBlur={() => window.setTimeout(() => setIsOpen(false), 150)}
        onKeyDown={(event) => { if (event.key === "Escape") setIsOpen(false); }}
        placeholder={t("home.locationPlaceholder")}
        role="combobox"
        aria-autocomplete="list"
        aria-expanded={isOpen}
        aria-controls={listboxId}
        autoComplete="off"
        required={required}
      />
        {isLoading && <LoaderCircle className="location-loader" aria-label={t("home.locationLoading")} />}
        {isOpen && (
          <div className="location-suggestions" id={listboxId} role="listbox">
          {!value.trim() && <p>{t("home.locationPopular")}</p>}
          {results.map((item) => (
            <button type="button" role="option" aria-selected={item.city === value} key={`${item.label}-${item.country_code}`} onMouseDown={(event) => event.preventDefault()} onClick={() => selectLocation(item)}>
              <MapPin aria-hidden="true" />
              <span><strong>{item.city}</strong><small>{item.label}</small></span>
              {item.country_code === "BE" && <em>{t("home.locationBelgium")}</em>}
            </button>
          ))}
          {status && <p role="status">{status}</p>}
          <footer>{t("home.locationAttribution")}</footer>
          </div>
        )}
      </div>
    </div>
  );
}
