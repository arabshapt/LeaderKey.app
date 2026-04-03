import assert from "node:assert/strict";
import test from "node:test";

import { defaultConfigDirectory } from "../src/index.js";

test("uses the default config directory shape expected by the reload trigger", () => {
  assert.match(defaultConfigDirectory(), /Leader Key$/);
});
