import test from "node:test";
import assert from "node:assert/strict";
import { createInstance } from "i18next";

import en from "../src/locales/en.js";
import fr from "../src/locales/fr.js";
import nl from "../src/locales/nl.js";
import { buildInterfaceTranslations, interfacePhrases } from "../src/locales/interfacePhrases.js";

const flattenKeys = (value, prefix = "") => Object.entries(value).flatMap(([key, child]) => {
  const path = prefix ? `${prefix}.${key}` : key;
  return child && typeof child === "object" && !Array.isArray(child) ? flattenKeys(child, path) : [path];
});

test("les ressources principales possèdent les mêmes clés dans les trois langues", () => {
  assert.deepEqual(flattenKeys(en).sort(), flattenKeys(fr).sort());
  assert.deepEqual(flattenKeys(nl).sort(), flattenKeys(fr).sort());
});

test("toutes les phrases d'interface ont une traduction anglaise et néerlandaise", () => {
  for (const [french, translations] of Object.entries(interfacePhrases)) {
    assert.ok(french.trim());
    assert.equal(translations.length, 2);
    assert.ok(translations[0].trim(), `Traduction anglaise manquante pour ${french}`);
    assert.ok(translations[1].trim(), `Traduction néerlandaise manquante pour ${french}`);
  }
});

test("les accents français et néerlandais sont conservés en UTF-8", () => {
  assert.match(fr.home.lead, /réunis|sécurisé/);
  assert.match(nl.eventTypes.privateParty, /é/);
  assert.equal(buildInterfaceTranslations("en")["Soirée privée"], "Private party");
  assert.equal(buildInterfaceTranslations("nl")["Soirée privée"], "Privéfeest");
});

test("i18next résout les clés imbriquées et les phrases plates", async () => {
  const instance = createInstance();
  await instance.init({
    lng: "en",
    fallbackLng: "fr",
    resources: {
      fr: { translation: fr, interface: buildInterfaceTranslations("fr") },
      en: { translation: en, interface: buildInterfaceTranslations("en") },
    },
    ns: ["translation", "interface"],
    defaultNS: "translation",
  });

  assert.equal(instance.t("error.title"), "The page could not be displayed.");
  assert.equal(instance.t("Soirée privée", { ns: "interface", keySeparator: false }), "Private party");
  assert.equal(instance.t("Votre suivi personnalisé", { ns: "interface", keySeparator: false }), "Your personalised tracking");
  assert.equal(instance.t("Consultez vos devis et contrats", { ns: "interface", keySeparator: false }), "View your quotes and contracts");
  assert.equal(instance.t("Demandes d'annulation", { ns: "interface", keySeparator: false }), "Cancellation requests");
  assert.equal(instance.t("Clôturer les prestations", { ns: "interface", keySeparator: false }), "Complete services");
  assert.equal(instance.t("Demandes musicales", { ns: "interface", keySeparator: false }), "Music requests");
  assert.equal(instance.t("À jouer absolument", { ns: "interface", keySeparator: false }), "Must play");
});
