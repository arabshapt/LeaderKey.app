import assert from "node:assert/strict";
import test from "node:test";

import {
  emptyFormState,
  formatFullPath,
  menuAppPrefix,
  normalizeConfigKey,
  parseTokenizedFullPath,
  replaceMenuAppPrefix,
  recordToFormState,
} from "../src/form-utils.js";

test("emptyFormState returns blank default action fields", () => {
  const state = emptyFormState();

  assert.equal(state.type, "shortcut");
  assert.equal(state.fullPath, "");
  assert.equal(state.description, "");
  assert.equal(state.label, "");
  assert.equal(state.shortcutValue, "");
  assert.equal(state.applicationPath, "");
  assert.equal(state.keystroke.spec, "");
});

test("emptyFormState can default to group without inheriting selected item values", () => {
  const state = emptyFormState("group");

  assert.equal(state.type, "group");
  assert.equal(state.fullPath, "");
  assert.equal(state.description, "");
  assert.equal(state.label, "");
  assert.equal(state.commandValue, "");
});

test("recordToFormState still preserves edit-source data", () => {
  const state = recordToFormState({
    actionType: "command",
    activates: undefined,
    aiDescription: "Run GitHub checkout for the active PR",
    appName: undefined,
    breadcrumbDisplay: "Global -> r -> g",
    breadcrumbPath: ["Global", "r", "g"],
    childCount: undefined,
    description: "Checkout the current PR",
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
  assert.equal(state.description, "Checkout the current PR");
  assert.equal(state.aiDescription, "Run GitHub checkout for the active PR");
  assert.equal(state.fullPath, "r -> g");
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

test("parseTokenizedFullPath normalizes aliases per segment", () => {
  assert.deepEqual(parseTokenizedFullPath("a -> left -> space").keyPath, ["a", "←", " "]);
  assert.deepEqual(parseTokenizedFullPath("up → .").keyPath, ["↑", "."]);
});

test("parseTokenizedFullPath rejects multi-character literal segments", () => {
  const parsed = parseTokenizedFullPath("leftspace");
  assert.equal(parsed.error, 'Path segment "leftspace" must resolve to exactly one key.');
});

test("formatFullPath renders special keys as tokenized aliases", () => {
  assert.equal(formatFullPath(["a", "←", " "]), "a -> left -> space");
});

test("menuAppPrefix extracts the leading app name from menu values", () => {
  assert.equal(menuAppPrefix("Codex > File > Open Recent"), "Codex");
  assert.equal(menuAppPrefix(" Google Chrome > History "), "Google Chrome");
  assert.equal(menuAppPrefix("File > Open", ["Codex", "Google Chrome"]), undefined);
  assert.equal(menuAppPrefix(""), undefined);
});

test("replaceMenuAppPrefix preserves the rest of the menu path", () => {
  assert.equal(replaceMenuAppPrefix("", "Codex"), "Codex > ");
  assert.equal(replaceMenuAppPrefix("Codex > File > Open Recent", "Arc", "Codex"), "Arc > File > Open Recent");
  assert.equal(replaceMenuAppPrefix("File > Open Recent", "Codex"), "Codex > File > Open Recent");
  assert.equal(replaceMenuAppPrefix("Codex > File > Open Recent", undefined, "Codex"), "File > Open Recent");
});
