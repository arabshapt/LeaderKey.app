import assert from "node:assert/strict";
import test from "node:test";

import { buildLeaderKeyReloadCommand, defaultConfigDirectory } from "../src/index.js";

test("builds the background Leader Key reload URL command", () => {
  assert.deepEqual(buildLeaderKeyReloadCommand(), {
    command: "open",
    args: ["-g", "leaderkey://reload-config"],
  });
});

test("uses the default config directory shape expected by the reload trigger", () => {
  assert.match(defaultConfigDirectory(), /Leader Key$/);
});
