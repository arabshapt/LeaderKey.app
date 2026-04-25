import assert from "node:assert/strict";
import test from "node:test";

import {
  generateActionLabel,
  generateGroupLabel,
  type ActionNode,
  type GroupNode,
} from "../src/index.js";

const context = {
  breadcrumbPath: [],
  configDisplayName: "Global",
  inherited: false,
};

function labelFor(action: ActionNode): string {
  return generateActionLabel(action, context);
}

test("generates deterministic human labels for dominant action patterns", () => {
  assert.equal(
    labelFor({ key: "a", type: "application", value: "/Applications/Arc.app" }),
    "Arc",
  );
  assert.equal(
    labelFor({ key: "k", type: "shortcut", value: "Ct" }),
    "Shortcut: Cmd+T",
  );
  assert.equal(
    labelFor({ key: "u", type: "url", value: "raycast://extensions/raycast/raycast/search-quicklinks" }),
    "Raycast: Search Quicklinks",
  );
  assert.equal(
    labelFor({ key: "u", type: "url", value: "shortcuts://run-shortcut?name=Low%20Power%20on" }),
    "Shortcut: Low Power On",
  );
  assert.equal(
    labelFor({ key: "u", type: "url", value: "kmtrigger://macro=Toggle%20Music" }),
    "Keyboard Maestro: Toggle Music",
  );
  assert.equal(
    labelFor({ key: "m", type: "menu", value: "Google Chrome > Tab > Duplicate Tab" }),
    "Tab → Duplicate Tab",
  );
  assert.equal(
    labelFor({ key: "i", type: "intellij", value: "SaveAll,ReformatCode|100" }),
    "IntelliJ: Save All, Reformat Code (100ms)",
  );
  assert.equal(
    labelFor({ key: "d", type: "keystroke", value: "Google Chrome > Ct" }),
    "Google Chrome: Cmd+T",
  );
  assert.equal(
    labelFor({
      key: "c",
      type: "command",
      value: "osascript -e 'tell application \"System Events\" to keystroke \"v\" using {command down, shift down}'",
    }),
    "AppleScript: Cmd+Shift+V",
  );
  assert.equal(
    labelFor({ key: " ", type: "toggleStickyMode", value: "" }),
    "Toggle Sticky Mode",
  );
  assert.equal(
    labelFor({ key: "n", type: "normalModeEnable", value: "" }),
    "Normal Mode Enable",
  );
  assert.equal(
    labelFor({ key: "i", type: "normalModeInput", value: "" }),
    "Normal Mode Input",
  );
  assert.equal(
    labelFor({ key: "d", type: "normalModeDisable", value: "" }),
    "Normal Mode Disable",
  );
});

test("fills common group labels only when the current label is placeholder-like", () => {
  const group: GroupNode = { actions: [], key: "o", type: "group" };
  assert.equal(generateGroupLabel(group), "Open");
  assert.equal(generateGroupLabel({ ...group, label: "Open Browser" }), "Open Browser");
});
