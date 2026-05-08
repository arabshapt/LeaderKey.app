import assert from "node:assert/strict";
import test from "node:test";

import { affectedConfigNamesForOverride, overrideWarningText } from "../src/conflict-formatting.js";

function makeRecord(overrides: Record<string, unknown> = {}) {
  return {
    actionType: "shortcut",
    activates: undefined,
    appName: "Chrome",
    breadcrumbDisplay: "Chrome -> w -> d",
    breadcrumbPath: ["Chrome", "w", "d"],
    childCount: undefined,
    description: undefined,
    displayLabel: "Shortcut: Cmd+D",
    effectiveBundleId: "com.google.Chrome",
    effectiveConfigDisplayName: "Chrome",
    effectiveConfigPath: "/tmp/app.com.google.Chrome.json",
    effectiveKeyPath: ["w", "d"],
    effectiveScope: "app",
    id: "chrome-record",
    inherited: true,
    key: "d",
    keySequence: "w -> d",
    kind: "action",
    label: undefined,
    macroStepSummary: undefined,
    parentEffectiveKeyPath: ["w"],
    rawValue: "Cd",
    searchText: "record",
    sourceConfigDisplayName: "Tag: Browser",
    sourceConfigPath: "/tmp/tag.browser.json",
    sourceNodePath: [0, 0],
    sourceScope: "tag",
    sourceStatus: "tag",
    sourceTagId: "browser",
    stickyMode: undefined,
    valuePreview: "Cmd+D",
    ...overrides,
  };
}

test("affectedConfigNamesForOverride groups every effective app using the same source node", () => {
  const chromeRecord = makeRecord();
  const arcRecord = makeRecord({
    appName: "Arc",
    effectiveBundleId: "company.thebrowser.Browser",
    effectiveConfigDisplayName: "Arc",
    effectiveConfigPath: "/tmp/app.company.thebrowser.Browser.json",
    id: "arc-record",
  });
  const unrelatedRecord = makeRecord({
    appName: "Safari",
    effectiveConfigDisplayName: "Safari",
    id: "safari-record",
    sourceNodePath: [0, 1],
  });

  const payload = {
    configDirectory: "/tmp",
    configs: [],
    diagnostics: [],
    fingerprint: "fingerprint",
    generatedAt: "2026-05-08T00:00:00.000Z",
    records: [arcRecord, unrelatedRecord, chromeRecord],
    tagsRegistry: { assignments: { app: {}, normalApp: {} }, tags: [], version: 1 },
    version: 1,
  };

  assert.deepEqual(affectedConfigNamesForOverride(payload, chromeRecord), ["Arc", "Chrome"]);
  assert.equal(
    overrideWarningText(chromeRecord, payload),
    "This will override Tag: Browser at w -> d for Arc, Chrome.",
  );
});

