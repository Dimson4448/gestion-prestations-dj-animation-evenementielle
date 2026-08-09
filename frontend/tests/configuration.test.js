import test from "node:test";
import assert from "node:assert/strict";

import { resolveBackendBaseUrl } from "../src/utils/configuration.js";

test("une URL backend explicite est prioritaire et normalisée", () => {
  assert.equal(
    resolveBackendBaseUrl("https://api.example.test/api/v1", "https://django.example.test///", "https://site.example.test"),
    "https://django.example.test",
  );
});

test("le backend est dérivé de l'origine d'une API absolue", () => {
  assert.equal(
    resolveBackendBaseUrl("https://api.example.test/api/v1", "", "https://site.example.test"),
    "https://api.example.test",
  );
});

test("une API relative utilise l'origine du frontend", () => {
  assert.equal(
    resolveBackendBaseUrl("/api/v1", "", "https://ultimate-dj.example.test"),
    "https://ultimate-dj.example.test",
  );
});
