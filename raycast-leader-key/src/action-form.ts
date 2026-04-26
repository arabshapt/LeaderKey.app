import {
  encodeMenuActionValue,
  parseIntellijActionValue,
  parseMenuActionValue,
  type ActionNode,
  type ConfigItem,
  type MacroStep,
} from "@leaderkey/config-core";

import { encodeKeystrokeRawValue, menuPathValue, type ItemFormState } from "./form-utils.js";

export type MacroStepActionType = ActionNode["type"];

export function isModeControlActionType(type: ConfigItem["type"]): boolean {
  return type === "toggleStickyMode"
    || type === "toggleHintOverlay"
    || type === "normalModeDisable"
    || type === "normalModeEnable"
    || type === "normalModeInput";
}

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
  menuAppName?: string;
  preserveAction?: ActionNode;
  preserveHiddenMetadata?: boolean;
}

export function formStateToActionNode(
  state: ItemFormState,
  options: ActionFromFormStateOptions = {},
): ActionNode {
  if (state.type === "group" || state.type === "layer") {
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
    normalModeAfter: preserveHiddenMetadata || isModeControlActionType(state.type)
      ? preservedAction?.normalModeAfter
      : state.normalModeAfter === "normal"
        ? undefined
        : state.normalModeAfter,
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
      return {
        ...baseAction,
        value: state.intellijValue.trim(),
      };
    case "keystroke":
      return { ...baseAction, value: encodeKeystrokeRawValue(state.keystroke) };
    case "macro":
      return {
        ...baseAction,
        macroSteps: cloneMacroSteps(state.macroSteps),
        value: preservedAction?.type === "macro" ? preservedAction.value : "",
      };
    case "menu":
      {
        const parsedMenu = parseMenuActionValue(state.menuValue);
        const appName = options.menuAppName?.trim() || parsedMenu.appName;
        const path = options.menuAppName
          ? menuPathValue(state.menuValue, options.menuAppName)
          : parsedMenu.path;
      return {
        ...baseAction,
        menuFallbackPaths: state.menuFallbackPaths.map((path) => path.trim()).filter(Boolean),
        value: encodeMenuActionValue({
          appName,
          path,
        }),
      };
      }
    case "shortcut":
      return { ...baseAction, value: state.shortcutValue.trim() };
    case "text":
      return { ...baseAction, value: state.textValue };
    case "normalModeDisable":
    case "normalModeEnable":
    case "normalModeInput":
    case "toggleHintOverlay":
      return { ...baseAction, value: "" };
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

  if (isModeControlActionType(action.type)) {
    return undefined;
  }

  if (action.type === "menu") {
    const parsed = parseMenuActionValue(action.value);
    if (!parsed.appName?.trim()) {
      return "A target app is required for menu actions.";
    }
    if (!parsed.path.trim()) {
      return "A primary menu path is required.";
    }
    return undefined;
  }

  if (action.type === "intellij") {
    const parsed = parseIntellijActionValue(action.value);
    if (parsed.actionIds.length === 0) {
      return "At least one IntelliJ action ID is required.";
    }
    const delayPart = action.value.split("|")[1]?.trim();
    if (delayPart && parsed.delayMs === undefined) {
      return "Delay must be a whole number of milliseconds.";
    }
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
