import assert from "node:assert/strict";
import test from "node:test";

import { buildRecordDetailPresentation } from "../src/detail-presentation.js";

function makeRecord(overrides: Record<string, unknown> = {}) {
  return {
    actionType: "shortcut",
    activates: undefined,
    aiDescription: undefined,
    appName: undefined,
    breadcrumbDisplay: "Global -> o -> a",
    breadcrumbPath: ["Global", "o", "a"],
    childCount: undefined,
    description: undefined,
    displayLabel: "Shortcut: Cmd+T",
    effectiveConfigDisplayName: "Global",
    effectiveConfigPath: "/tmp/global-config.json",
    effectiveKeyPath: ["o", "a"],
    effectiveScope: "global",
    id: "record",
    inherited: false,
    key: "a",
    keySequence: "o -> a",
    kind: "action",
    label: undefined,
    macroStepSummary: undefined,
    parentEffectiveKeyPath: ["o"],
    rawValue: "Ct",
    searchText: "record",
    sourceConfigDisplayName: "Global",
    sourceConfigPath: "/tmp/global-config.json",
    sourceNodePath: [0, 0],
    sourceScope: "global",
    sourceStatus: "local",
    stickyMode: undefined,
    valuePreview: "Cmd+T",
    ...overrides,
  };
}

test("buildRecordDetailPresentation shows shortcut preview, raw value, and canonical path", () => {
  const presentation = buildRecordDetailPresentation(makeRecord());

  assert.equal(presentation.title, "Send Cmd+T");
  assert.match(presentation.markdown, /`Global → o → a`/);
  assert.match(presentation.markdown, /\*\*What It Does\*\*/);
  assert.match(presentation.markdown, /Sends Cmd\+T to the frontmost app\./);
  assert.match(presentation.markdown, /Raw: `Ct`/);
  assert.equal(presentation.metadata[0]?.title, "Type");
});

test("buildRecordDetailPresentation renders descriptions when present", () => {
  const presentation = buildRecordDetailPresentation(makeRecord({
    aiDescription: "Open the history pane in Google Chrome",
    description: "Go to history",
    displayLabel: "Shortcut: Cmd+Y",
    rawValue: "Cy",
    valuePreview: "Cmd+Y",
  }));

  assert.match(presentation.markdown, /\*\*Description\*\*/);
  assert.match(presentation.markdown, /Go to history/);
  assert.match(presentation.markdown, /\*\*AI Description\*\*/);
  assert.match(presentation.markdown, /Open the history pane in Google Chrome/);
});

test("buildRecordDetailPresentation shows keystroke target and focus semantics", () => {
  const presentation = buildRecordDetailPresentation(makeRecord({
    actionType: "keystroke",
    appName: "Google Chrome",
    displayLabel: "Google Chrome: Cmd+T (focus)",
    rawValue: "Google Chrome > [focus] > Ct",
    valuePreview: "Google Chrome • Cmd+T",
  }));

  assert.equal(presentation.title, "Send Cmd+T to Google Chrome");
  assert.match(presentation.markdown, /Sends Cmd\+T directly to Google Chrome\./);
  assert.match(presentation.markdown, /Focus After Send: `Yes`/);
  assert.match(presentation.markdown, /Raw: `Google Chrome > \[focus\] > Ct`/);
});

test("buildRecordDetailPresentation renders commands and raw shell value clearly", () => {
  const presentation = buildRecordDetailPresentation(makeRecord({
    actionType: "command",
    displayLabel: "Run gh",
    rawValue: "gh pr checkout 123",
    valuePreview: "gh pr checkout 123",
  }));

  assert.equal(presentation.title, "Run gh");
  assert.match(presentation.markdown, /Runs this shell command\./);
  assert.match(presentation.markdown, /```sh/);
  assert.match(presentation.markdown, /gh pr checkout 123/);
});

test("buildRecordDetailPresentation renders url, application, group, and macro previews", () => {
  const urlPresentation = buildRecordDetailPresentation(makeRecord({
    actionType: "url",
    displayLabel: "Open raycast.com",
    rawValue: "https://raycast.com",
    valuePreview: "Open raycast.com",
  }));
  assert.match(urlPresentation.markdown, /Opens this URL\./);
  assert.match(urlPresentation.markdown, /https:\/\/raycast\.com/);

  const applicationPresentation = buildRecordDetailPresentation(makeRecord({
    actionType: "application",
    displayLabel: "Arc",
    rawValue: "/Applications/Arc.app",
    valuePreview: "Arc",
  }));
  assert.equal(applicationPresentation.title, "Open Arc");
  assert.match(applicationPresentation.markdown, /Opens the Arc application\./);

  const groupPresentation = buildRecordDetailPresentation(makeRecord({
    actionType: "group",
    childCount: 4,
    displayLabel: "Open",
    kind: "group",
    rawValue: "",
    valuePreview: "Contains 4 items",
  }));
  assert.equal(groupPresentation.title, "Open Group");
  assert.match(groupPresentation.markdown, /This group contains 4 child items\./);

  const macroPresentation = buildRecordDetailPresentation(makeRecord({
    actionType: "macro",
    displayLabel: "Macro: Open Arc → Cmd\\+T",
    macroStepSummary: ["Open Arc", "Shortcut: Cmd+T"],
    rawValue: "",
    valuePreview: "Open Arc • Shortcut: Cmd+T",
  }));
  assert.equal(macroPresentation.title, "Run Macro");
  assert.match(macroPresentation.markdown, /\*\*Steps\*\*/);
  assert.match(macroPresentation.markdown, /- Open Arc/);
});

test("buildRecordDetailPresentation shows fallback menu paths for menu actions", () => {
  const presentation = buildRecordDetailPresentation(makeRecord({
    actionType: "menu",
    displayLabel: "View → Show Sidebar",
    menuFallbackPaths: ["View > Hide Sidebar", "Window > Toggle Sidebar"],
    rawValue: "Codex > View > Show Sidebar",
    valuePreview: "Codex > View > Show Sidebar",
  }));

  assert.match(presentation.markdown, /Primary: `View > Show Sidebar`/);
  assert.match(presentation.markdown, /Fallbacks:/);
  assert.match(presentation.markdown, /View > Hide Sidebar/);
  assert.equal(
    presentation.metadata.find((row) => row.title === "Fallback Menu Paths")?.text,
    "View > Hide Sidebar | Window > Toggle Sidebar",
  );
});
