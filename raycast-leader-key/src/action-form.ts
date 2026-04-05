import type { ActionNode, ConfigItem, MacroStep } from "@leaderkey/config-core";

import { encodeKeystrokeRawValue, type ItemFormState } from "./form-utils.js";

export type MacroStepActionType = Exclude<ConfigItem["type"], "group">;

function trimOptionalText(value: string): string | undefined {
  const trimmed = value.trim();
  return trimmed ? trimmed : undefined;
}

function cloneActionNode(action: ActionNode): ActionNode {
  return {
    ...action,
    ...(action.macroSteps ? { macroSteps: cloneMacroSteps(action.macroSteps) } : {}),
  };
}

export function cloneMacroSteps(macroSteps?: MacroStep[]): MacroStep[] {
  return (macroSteps ?? []).map((step) => ({
    action: cloneActionNode(step.action),
    delay: step.delay,
    enabled: step.enabled,
  }));
}

export function createEmptyMacroStep(type: MacroStepActionType = "shortcut"): MacroStep {
  return {
    action: {
      type,
      value: "",
      ...(type === "macro" ? { macroSteps: [] } : {}),
    },
    delay: 0,
    enabled: true,
  };
}

interface ActionFromFormStateOptions {
  preserveAction?: ActionNode;
  preserveHiddenMetadata?: boolean;
}

export function formStateToActionNode(
  state: ItemFormState,
  options: ActionFromFormStateOptions = {},
): ActionNode {
  if (state.type === "group") {
    throw new Error("formStateToActionNode requires an action type.");
  }

  const preservedAction = options.preserveAction?.type === state.type ? options.preserveAction : undefined;
  const preserveHiddenMetadata = options.preserveHiddenMetadata ?? false;

  const baseAction = {
    activates: state.type === "url" ? state.activates : undefined,
    aiDescription: preserveHiddenMetadata ? preservedAction?.aiDescription : trimOptionalText(state.aiDescription),
    description: preserveHiddenMetadata ? preservedAction?.description : trimOptionalText(state.description),
    iconPath: preservedAction?.iconPath,
    key: preservedAction?.key,
    label: preservedAction?.label,
    stickyMode: preserveHiddenMetadata ? preservedAction?.stickyMode : state.stickyMode || undefined,
    type: state.type,
  } as const;

  switch (state.type) {
    case "application":
      return { ...baseAction, value: state.applicationPath.trim() };
    case "command":
      return { ...baseAction, value: state.commandValue.trim() };
    case "folder":
      return { ...baseAction, value: state.folderPath.trim() };
    case "intellij":
      return { ...baseAction, value: state.intellijValue.trim() };
    case "keystroke":
      return { ...baseAction, value: encodeKeystrokeRawValue(state.keystroke) };
    case "macro":
      return {
        ...baseAction,
        macroSteps: cloneMacroSteps(state.macroSteps),
        value: preservedAction?.type === "macro" ? preservedAction.value : "",
      };
    case "menu":
      return { ...baseAction, value: state.menuValue.trim() };
    case "shortcut":
      return { ...baseAction, value: state.shortcutValue.trim() };
    case "text":
      return { ...baseAction, value: state.textValue };
    case "toggleStickyMode":
      return { ...baseAction, value: "" };
    case "url":
      return { ...baseAction, value: state.urlValue.trim() };
  }
}

export function validateActionNode(action: ActionNode): string | undefined {
  if (action.type === "macro") {
    return validateMacroSteps(action.macroSteps);
  }

  if (action.type === "toggleStickyMode") {
    return undefined;
  }

  if (!action.value.trim()) {
    return "A value is required for this action type.";
  }

  return undefined;
}

export function validateMacroSteps(macroSteps?: MacroStep[]): string | undefined {
  for (const [index, step] of (macroSteps ?? []).entries()) {
    if (!Number.isFinite(step.delay) || step.delay < 0) {
      return `Step ${index + 1}: Delay must be a non-negative number.`;
    }

    const actionError = validateActionNode(step.action);
    if (actionError) {
      return `Step ${index + 1}: ${actionError}`;
    }
  }

  return undefined;
}
