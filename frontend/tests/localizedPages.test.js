import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const localizedPages = [
  "OffersPage.jsx",
  "PackageDetailPage.jsx",
  "QuoteRequestPage.jsx",
  "AdminWorkspacePage.jsx",
  "DJWorkspacePage.jsx",
];

test("chaque page métier extraite applique les traductions d’interface", async () => {
  for (const page of localizedPages) {
    const source = await readFile(new URL(`../src/pages/${page}`, import.meta.url), "utf8");
    assert.match(source, /import LocalizedContent from/);
    assert.match(source, /<LocalizedContent>/);
  }
});
