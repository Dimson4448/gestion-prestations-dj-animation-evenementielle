import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const appSource = readFileSync(new URL("../src/App.jsx", import.meta.url), "utf-8");

test("l'accueil ne présélectionne ni un mariage ni Bruxelles", () => {
  assert.match(appSource, /\[eventType, setEventType\] = useState\(""\)/);
  assert.match(appSource, /\[location, setLocation\] = useState\(""\)/);
  assert.doesNotMatch(appSource, /\[eventType, setEventType\] = useState\("Mariage"\)/);
  assert.doesNotMatch(appSource, /\[location, setLocation\] = useState\("Bruxelles"\)/);
});
