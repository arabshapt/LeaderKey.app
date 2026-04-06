import assert from "node:assert/strict";
import test from "node:test";

import { formStateToActionNode, validateActionNode } from "../src/action-form.js";
import { emptyFormState, itemToFormState } from "../src/form-utils.js";

test("new macro form state starts with zero steps", () => {
  const state = emptyFormState("macro");
  assert.equal(state.type, "macro");
  assert.deepEqual(state.macroSteps, []);
});

test("macro form state round-trips nested steps without losing structure", () => {
  const macroItem = {
    key: "m",
    macroSteps: [
      {
        action: {
          key: undefined,
          type: "url" as const,
          activates: true,
          value: "raycast://confetti",
        },
        delay: 0.25,
        enabled: true,
      },
      {
        action: {
          key: undefined,
          type: "menu" as const,
          value: "Codex > File > Open Recent",
        },
        delay: 0,
        enabled: true,
      },
      {
        action: {
          key: undefined,
          type: "keystroke" as const,
          value: "Google Chrome > [focus] > Cy",
        },
        delay: 1,
        enabled: false,
      },
      {
        action: {
          key: undefined,
          macroSteps: [
            {
              action: {
                key: undefined,
                type: "toggleStickyMode" as const,
                value: "",
              },
              delay: 0,
              enabled: true,
            },
          ],
          type: "macro" as const,
          value: "",
        },
        delay: 2,
        enabled: true,
      },
    ],
    type: "macro" as const,
    value: "",
  };

  const state = itemToFormState(macroItem);
  const roundTrip = formStateToActionNode(state, { preserveAction: macroItem });

  assert.equal(state.type, "macro");
  assert.deepEqual(roundTrip.macroSteps, macroItem.macroSteps);
});

test("edited macro steps serialize reorder, delay, enabled, and nested changes", () => {
  const originalMacro = {
    key: "m",
    macroSteps: [
      {
        action: {
          key: undefined,
          type: "shortcut" as const,
          value: "Cy",
        },
        delay: 0,
        enabled: true,
      },
      {
        action: {
          key: undefined,
          type: "macro" as const,
          value: "",
          macroSteps: [],
        },
        delay: 0,
        enabled: true,
      },
    ],
    type: "macro" as const,
    value: "",
  };

  const state = itemToFormState(originalMacro);
  state.macroSteps = [
    {
      action: {
        key: undefined,
        type: "macro",
        value: "",
        macroSteps: [
          {
            action: {
              key: undefined,
              type: "text",
              value: "hello",
            },
            delay: 0.5,
            enabled: true,
          },
        ],
      },
      delay: 1.25,
      enabled: false,
    },
    {
      action: {
        key: undefined,
        type: "shortcut",
        value: "Cy",
      },
      delay: 0,
      enabled: true,
    },
  ];

  const nextMacro = formStateToActionNode(state, { preserveAction: originalMacro });
  assert.deepEqual(nextMacro.macroSteps, state.macroSteps);
});

test("macro validation rejects invalid nested step delay", () => {
  const invalidMacro = {
    key: "m",
    macroSteps: [
      {
        action: {
          key: undefined,
          type: "shortcut" as const,
          value: "Cy",
        },
        delay: -1,
        enabled: true,
      },
    ],
    type: "macro" as const,
    value: "",
  };

  assert.equal(validateActionNode(invalidMacro), "Step 1: Delay must be a non-negative number.");
});

test("menu actions serialize fallback paths and intellij actions preserve delay encoding", () => {
  const menuState = emptyFormState("menu");
  menuState.menuValue = "Codex > View > Show Sidebar";
  menuState.menuFallbackPaths = ["View > Hide Sidebar", "Window > Toggle Sidebar"];

  const menuAction = formStateToActionNode(menuState);
  assert.deepEqual(menuAction.menuFallbackPaths, ["View > Hide Sidebar", "Window > Toggle Sidebar"]);
  assert.equal(menuAction.value, "Codex > View > Show Sidebar");

  const intellijState = emptyFormState("intellij");
  intellijState.intellijValue = "SaveAll,ReformatCode|150";

  const intellijAction = formStateToActionNode(intellijState);
  assert.equal(intellijAction.value, "SaveAll,ReformatCode|150");
});

test("menu actions normalize in-progress draft spacing on save", () => {
  const menuState = emptyFormState("menu");
  menuState.menuValue = "Codex > file > open";

  const menuAction = formStateToActionNode(menuState);
  assert.equal(menuAction.value, "Codex > file > open");
});
