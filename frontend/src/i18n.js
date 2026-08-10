import i18n from "i18next";
import { initReactI18next } from "react-i18next";

import en from "./locales/en.js";
import fr from "./locales/fr.js";
import nl from "./locales/nl.js";
import { buildInterfaceTranslations } from "./locales/interfacePhrases.js";

const supportedLanguages = ["fr", "en", "nl"];
const savedLanguage = window.localStorage.getItem("ultimate-dj-language");
const browserLanguage = window.navigator.language?.split("-")[0];
const initialLanguage = supportedLanguages.includes(savedLanguage)
  ? savedLanguage
  : supportedLanguages.includes(browserLanguage) ? browserLanguage : "fr";

i18n.use(initReactI18next).init({
  resources: {
    fr: { translation: fr, interface: buildInterfaceTranslations("fr") },
    en: { translation: en, interface: buildInterfaceTranslations("en") },
    nl: { translation: nl, interface: buildInterfaceTranslations("nl") },
  },
  lng: initialLanguage,
  fallbackLng: "fr",
  supportedLngs: supportedLanguages,
  ns: ["translation", "interface"],
  defaultNS: "translation",
  interpolation: { escapeValue: false },
  returnNull: false,
});

i18n.on("languageChanged", (language) => {
  window.localStorage.setItem("ultimate-dj-language", language);
  document.documentElement.lang = language;
});
document.documentElement.lang = initialLanguage;

export default i18n;
export { supportedLanguages };
