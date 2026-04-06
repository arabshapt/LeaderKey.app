import assert from "node:assert/strict";
import test from "node:test";

import { encodeIntellijActionValue, encodeMenuActionValue, parseIntellijActionValue, parseMenuActionValue } from "../src/index.js";

test("parse and encode menu action values keep app prefix and path separate", () => {
  assert.deepEqual(parseMenuActionValue("Google Chrome > View > Show Tab Bar"), {
    appName: "Google Chrome",
    path: "View > Show Tab Bar",
    pathSegments: ["View", "Show Tab Bar"],
  });

  assert.deepEqual(parseMenuActionValue("Google Chrome > "), {
    appName: "Google Chrome",
    path: "",
    pathSegments: [],
  });

  assert.equal(
    encodeMenuActionValue({ appName: "Google Chrome", path: "View > Show Tab Bar" }),
    "Google Chrome > View > Show Tab Bar",
  );
});

test("parse and encode intellij action values preserve ordered action IDs and delay", () => {
  assert.deepEqual(parseIntellijActionValue("SaveAll,ReformatCode|150"), {
    actionIds: ["SaveAll", "ReformatCode"],
    delayMs: 150,
  });

  assert.equal(
    encodeIntellijActionValue({ actionIds: ["SaveAll", "ReformatCode"], delayMs: 150 }),
    "SaveAll,ReformatCode|150",
  );
  assert.equal(
    encodeIntellijActionValue({ actionIds: ["SaveAll", "ReformatCode"] }),
    "SaveAll,ReformatCode",
  );
});
