import assert from "node:assert/strict";
import test from "node:test";

import { emptyFormState, normalizeConfigKey, recordToFormState } from "../src/form-utils.js";

test("emptyFormState returns blank default action fields", () => {
  const state = emptyFormState();

  assert.equal(state.type, "shortcut");
  assert.equal(state.key, "");
  assert.equal(state.label, "");
  assert.equal(state.shortcutValue, "");
  assert.equal(state.applicationPath, "");
  assert.equal(state.keystroke.spec, "");
});

test("emptyFormState can default to group without inheriting selected item values", () => {
  const state = emptyFormState("group");

  assert.equal(state.type, "group");
  assert.equal(state.key, "");
  assert.equal(state.label, "");
  assert.equal(state.commandValue, "");
});

test("recordToFormState still preserves edit-source data", () => {
  const state = recordToFormState({
    actionType: "command",
    activates: undefined,
    appName: undefined,
    breadcrumbDisplay: "Global -> r -> g",
    breadcrumbPath: ["Global", "r", "g"],
    childCount: undefined,
    displayLabel: "Run gh",
    effectiveConfigDisplayName: "Global",
    effectiveConfigPath: "/tmp/global-config.json",
    effectiveKeyPath: ["r", "g"],
    effectiveScope: "global",
    id: "record",
    inherited: false,
    key: "g",
    keySequence: "r -> g",
    kind: "action",
    label: undefined,
    macroStepSummary: undefined,
    parentEffectiveKeyPath: ["r"],
    rawValue: "gh pr checkout 123",
    searchText: "gh pr checkout 123",
    sourceConfigDisplayName: "Global",
    sourceConfigPath: "/tmp/global-config.json",
    sourceNodePath: [0, 0],
    sourceScope: "global",
    sourceStatus: "local",
    stickyMode: false,
    valuePreview: "gh pr checkout 123",
  });

  assert.equal(state.type, "command");
  assert.equal(state.commandValue, "gh pr checkout 123");
  assert.equal(state.key, "g");
});

test("normalizeConfigKey maps arrow aliases to their canonical glyphs", () => {
  assert.equal(normalizeConfigKey("left"), "←");
  assert.equal(normalizeConfigKey("left arrow"), "←");
  assert.equal(normalizeConfigKey("left_arrow"), "←");
  assert.equal(normalizeConfigKey("uparrow"), "↑");
  assert.equal(normalizeConfigKey(" down "), "↓");
  assert.equal(normalizeConfigKey("space"), " ");
  assert.equal(normalizeConfigKey("space bar"), " ");
  assert.equal(normalizeConfigKey("spacebar"), " ");
  assert.equal(normalizeConfigKey("→"), "→");
  assert.equal(normalizeConfigKey("g"), "g");
});
