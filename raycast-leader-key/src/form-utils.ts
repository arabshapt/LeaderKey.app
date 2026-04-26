import {
  parseMenuActionValue,
  resolveActionAiDescription,
  resolveActionDescription,
  type ConfigItem,
  type FlatIndexRecord,
  type MacroStep,
  type NormalModeAfter,
  type ActionNode,
} from "@leaderkey/config-core";

const KEY_ALIASES = new Map<string, string>([
  ["left", "←"],
  ["left arrow", "←"],
  ["left_arrow", "←"],
  ["leftarrow", "←"],
  ["right", "→"],
  ["right arrow", "→"],
  ["right_arrow", "→"],
  ["rightarrow", "→"],
  ["up", "↑"],
  ["up arrow", "↑"],
  ["up_arrow", "↑"],
  ["uparrow", "↑"],
  ["down", "↓"],
  ["down arrow", "↓"],
  ["down_arrow", "↓"],
  ["downarrow", "↓"],
  ["space", " "],
  ["space bar", " "],
  ["space_bar", " "],
  ["spacebar", " "],
]);

const DISPLAY_KEY_NAMES = new Map<string, string>([
  ["←", "left"],
  ["→", "right"],
  ["↑", "up"],
  ["↓", "down"],
  [" ", "space"],
]);

function cloneMacroActionSteps(macroSteps?: MacroStep[]): MacroStep[] {
  return (macroSteps ?? []).map((step) => ({
    action: {
      ...step.action,
      ...(step.action.macroSteps ? { macroSteps: cloneMacroActionSteps(step.action.macroSteps) } : {}),
    },
    delay: step.delay,
    enabled: step.enabled,
  }));
}

export interface KeystrokeFields {
  app?: string;
  focusTargetApp: boolean;
  spec: string;
}

export interface ItemFormState {
  activates: boolean;
  aiDescription: string;
  applicationPath: string;
  commandValue: string;
  description: string;
  fullPath: string;
  folderPath: string;
  intellijValue: string;
  keystroke: KeystrokeFields;
  label: string;
  macroSteps: MacroStep[];
  menuFallbackPaths: string[];
  menuValue: string;
  normalModeAfter: NormalModeAfter;
  shortcutValue: string;
  stickyMode: boolean;
  tapAction?: ActionNode;
  textValue: string;
  type: ConfigItem["type"];
  urlValue: string;
}

export function normalizeConfigKey(value: string): string {
  const trimmed = value.trim();
  if (!trimmed) {
    return "";
  }

  return KEY_ALIASES.get(trimmed.toLowerCase()) ?? trimmed;
}

export function emptyFormState(type: ConfigItem["type"] = "shortcut"): ItemFormState {
  return {
    activates: false,
    aiDescription: "",
    applicationPath: "",
    commandValue: "",
    description: "",
    fullPath: "",
    folderPath: "",
    intellijValue: "",
    keystroke: { focusTargetApp: false, spec: "" },
    label: "",
    macroSteps: [],
    menuFallbackPaths: [],
    menuValue: "",
    normalModeAfter: "normal",
    shortcutValue: "",
    stickyMode: false,
    tapAction: undefined,
    textValue: "",
    type,
    urlValue: "",
  };
}

export interface ParsedTokenizedPath {
  error?: string;
  keyPath: string[];
}

export function formatFullPath(keyPath: string[]): string {
  return keyPath.map((segment) => DISPLAY_KEY_NAMES.get(segment) ?? segment).join(" -> ");
}

export function parseTokenizedFullPath(value: string): ParsedTokenizedPath {
  const trimmed = value.trim();
  if (!trimmed) {
    return {
      error: "A full path is required.",
      keyPath: [],
    };
  }

  const segments = trimmed.split(/\s*(?:->|→)\s*/g).map((segment) => segment.trim());
  if (segments.some((segment) => segment.length === 0)) {
    return {
      error: "Each path segment must contain one key.",
      keyPath: [],
    };
  }

  const keyPath: string[] = [];
  for (const segment of segments) {
    const normalized = normalizeConfigKey(segment);
    if (Array.from(normalized).length !== 1) {
      return {
        error: `Path segment "${segment}" must resolve to exactly one key.`,
        keyPath: [],
      };
    }
    keyPath.push(normalized);
  }

  return { keyPath };
}

export function menuAppPrefix(value: string, candidateAppNames?: Iterable<string>): string | undefined {
  const prefix = parseMenuActionValue(value).appName?.trim();
  if (!prefix) {
    return undefined;
  }

  if (!candidateAppNames) {
    return prefix;
  }

  return Array.from(candidateAppNames).some((candidate) => candidate === prefix) ? prefix : undefined;
}

export function composeMenuDraftValue(path: string, appName?: string): string {
  const nextAppName = appName?.trim();
  if (!nextAppName) {
    return path;
  }

  return path.length > 0 ? `${nextAppName} > ${path}` : `${nextAppName} > `;
}

export function replaceMenuAppPrefix(value: string, appName: string | undefined, currentAppName?: string): string {
  const path = menuPathValue(value, currentAppName);
  return composeMenuDraftValue(path, appName);
}

export function menuPathValue(value: string, currentAppName?: string): string {
  const currentPrefix = currentAppName?.trim();
  if (!currentPrefix) {
    return value;
  }

  const currentPrefixPattern = new RegExp(`^\\s*${currentPrefix.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\s*>\\s*(.*)$`);
  const match = value.match(currentPrefixPattern);
  return match ? match[1] ?? "" : value;
}

export function parseKeystrokeRawValue(rawValue: string): KeystrokeFields {
  const parts = rawValue.split(" > ").map((part) => part.trim()).filter(Boolean);
  if (parts.length === 0) {
    return { focusTargetApp: false, spec: "" };
  }

  if (parts.length === 1) {
    return { focusTargetApp: false, spec: parts[0]! };
  }

  const spec = parts.at(-1)!;
  const focusTargetApp = parts.at(-2) === "[focus]";
  return {
    app: parts[0],
    focusTargetApp,
    spec,
  };
}

export function encodeKeystrokeRawValue(value: KeystrokeFields): string {
  const segments = [];
  if (value.app?.trim()) {
    segments.push(value.app.trim());
  }
  if (value.app?.trim() && value.focusTargetApp) {
    segments.push("[focus]");
  }
  segments.push(value.spec.trim());
  return segments.filter(Boolean).join(" > ");
}

export function recordToFormState(record?: FlatIndexRecord): ItemFormState {
  if (!record) {
    return emptyFormState();
  }

  const keystroke = record.actionType === "keystroke"
    ? parseKeystrokeRawValue(record.rawValue)
    : { focusTargetApp: false, spec: "" };

  return {
    activates: record.activates ?? false,
    aiDescription: record.kind === "group" || record.kind === "layer" ? "" : record.aiDescription ?? "",
    applicationPath: record.actionType === "application" ? record.rawValue : "",
    commandValue: record.actionType === "command" ? record.rawValue : "",
    description: record.kind === "group" || record.kind === "layer" ? "" : record.description ?? "",
    fullPath: formatFullPath(record.effectiveKeyPath),
    folderPath: record.actionType === "folder" ? record.rawValue : "",
    intellijValue: record.actionType === "intellij" ? record.rawValue : "",
    keystroke,
    label: record.kind === "group" || record.kind === "layer" ? record.label ?? record.displayLabel ?? "" : "",
    macroSteps: [],
    menuFallbackPaths: record.actionType === "menu" ? record.menuFallbackPaths ?? [] : [],
    menuValue: record.actionType === "menu" ? record.rawValue : "",
    normalModeAfter: record.normalModeAfter ?? "normal",
    shortcutValue: record.actionType === "shortcut" ? record.rawValue : "",
    stickyMode: record.stickyMode ?? false,
    tapAction: record.tapAction,
    textValue: record.actionType === "text" ? record.rawValue : "",
    type: record.actionType ?? "shortcut",
    urlValue: record.actionType === "url" ? record.rawValue : "",
  };
}

export function itemToFormState(item?: ConfigItem): ItemFormState {
  if (!item) {
    return emptyFormState();
  }

  if (item.type === "group") {
    return {
      ...emptyFormState("group"),
      fullPath: item.key ? formatFullPath([item.key]) : "",
      label: item.label ?? "",
      stickyMode: item.stickyMode ?? false,
      type: "group",
    };
  }

  if (item.type === "layer") {
    return {
      ...emptyFormState("layer"),
      fullPath: item.key ? formatFullPath([item.key]) : "",
      label: item.label ?? "",
      tapAction: item.tapAction,
      type: "layer",
    };
  }

  const baseState: ItemFormState = {
    ...emptyFormState(item.type),
    activates: item.activates ?? false,
    aiDescription: resolveActionAiDescription(item) ?? "",
    description: resolveActionDescription(item, { breadcrumbPath: [], configDisplayName: "", inherited: false }) ?? "",
    fullPath: item.key ? formatFullPath([item.key]) : "",
    label: "",
    macroSteps: item.type === "macro" ? cloneMacroActionSteps(item.macroSteps) : [],
    menuFallbackPaths: item.type === "menu" ? [...(item.menuFallbackPaths ?? [])] : [],
    normalModeAfter: item.normalModeAfter ?? "normal",
    stickyMode: item.stickyMode ?? false,
    type: item.type,
  };

  switch (item.type) {
    case "application":
      return { ...baseState, applicationPath: item.value };
    case "command":
      return { ...baseState, commandValue: item.value };
    case "folder":
      return { ...baseState, folderPath: item.value };
    case "intellij":
      return { ...baseState, intellijValue: item.value };
    case "keystroke":
      return { ...baseState, keystroke: parseKeystrokeRawValue(item.value) };
    case "macro":
      return baseState;
    case "menu":
      return { ...baseState, menuValue: item.value };
    case "shortcut":
      return { ...baseState, shortcutValue: item.value };
    case "text":
      return { ...baseState, textValue: item.value };
    case "normalModeDisable":
    case "normalModeEnable":
    case "normalModeInput":
    case "toggleHintOverlay":
      return baseState;
    case "toggleStickyMode":
      return baseState;
    case "url":
      return { ...baseState, urlValue: item.value };
  }
}
