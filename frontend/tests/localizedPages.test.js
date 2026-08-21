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

test("la fiche d'une offre importe toutes les icônes utilisées par ses actions", async () => {
  const source = await readFile(new URL("../src/pages/PackageDetailPage.jsx", import.meta.url), "utf8");
  assert.match(source, /import \{[^}]*ChevronRight[^}]*\} from "lucide-react"/);
  assert.match(source, /Demander un devis <ChevronRight \/>/);
});

test("l'espace DJ ouvre les rendez-vous et les demandes musicales à la demande", async () => {
  const source = await readFile(new URL("../src/pages/DJWorkspacePage.jsx", import.meta.url), "utf8");
  assert.match(source, /aria-controls="dj-appointments-panel"/);
  assert.match(source, /aria-controls="dj-songs-panel"/);
  assert.match(source, /aria-expanded=\{openPanel === "appointments"\}/);
  assert.match(source, /aria-expanded=\{openPanel === "songs"\}/);
});
