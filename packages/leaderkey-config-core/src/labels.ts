import { URL } from "node:url";

import { parseIntellijActionValue, parseMenuActionValue } from "./action-values.js";
import { humanizeShortcutSequence, humanizeSlug, snippet } from "./utils.js";
import type { ActionNode, GroupNode, ItemContext, LayerNode, MacroStep } from "./types.js";

interface ParsedKeystrokeValue {
  app?: string;
  focusTargetApp: boolean;
  spec: string;
}

const GROUP_LABELS = new Map<string, string>([
  ["a", "Actions"],
  ["g", "Go"],
  ["i", "Input"],
  ["l", "Links"],
  ["m", "Media"],
  ["n", "Navigation"],
  ["o", "Open"],
  ["q", "Quit"],
  ["r", "Run"],
  ["s", "Search"],
  ["t", "Tabs"],
  ["u", "Utilities"],
  ["w", "Window"],
  ["y", "Yank"],
]);

const PLACEHOLDER_GROUP_LABEL = /^(\.+|group|\s*)$/i;
const MODEL_PREFIX = /^(?:\d+(?:-\d+)*|g|o|mini|nano|sonnet|haiku)$/i;

function parseKeystrokeValue(rawValue: string): ParsedKeystrokeValue {
  const parts = rawValue.split(" > ").map((part) => part.trim()).filter(Boolean);
  if (parts.length === 0) {
    return { focusTargetApp: false, spec: "" };
  }

  const spec = parts.at(-1)!;
  const focusTargetApp = parts.length > 2 && parts.at(-2) === "[focus]";
  const app = parts.length > 1 ? parts[0] : undefined;
  return { app, focusTargetApp, spec };
}

function humanizedIntellijActions(rawValue: string): { actions: string[]; delayMs?: number } {
  const parsed = parseIntellijActionValue(rawValue);
  return {
    actions: parsed.actionIds.map((action) => action.replace(/([a-z0-9])([A-Z])/g, "$1 $2")),
    delayMs: parsed.delayMs,
  };
}

function decodeUrlComponent(value: string | null): string | undefined {
  if (!value) {
    return undefined;
  }

  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

function humanizeRaycastUrl(url: URL): string {
  const segments = url.pathname.split("/").filter(Boolean);
  const host = url.hostname;

  if (segments.length === 0 && !host) {
    return "Raycast";
  }

  if (host === "extensions") {
    const command = segments.at(-1)!;
    if (command === "run-shortcut-sequence") {
      const sequenceName = decodeUrlComponent(url.searchParams.get("arguments"));
      if (sequenceName) {
        const match = sequenceName.match(/sequenceName"\s*:\s*"([^"]+)"/);
        if (match) {
          return `Raycast: ${humanizeSlug(match[1]!)}`;
        }
      }
    }
    return `Raycast: ${humanizeSlug(command)}`;
  }

  if (host === "ai-commands" && segments[0]) {
    const words = segments[0]
      .split("-")
      .filter((word) => !MODEL_PREFIX.test(word));
    return `Raycast: ${humanizeSlug(words.join("-"))}`;
  }

  return `Raycast: ${humanizeSlug(segments.at(-1) ?? host)}`;
}

function humanizeShortcutUrl(url: URL): string {
  const shortcutName = decodeUrlComponent(url.searchParams.get("name"));
  if (shortcutName) {
    return `Shortcut: ${humanizeSlug(shortcutName)}`;
  }
  return "Shortcut";
}

function humanizeKmTriggerUrl(url: URL): string {
  const macro = decodeUrlComponent(
    url.searchParams.get("macro") ?? (url.hostname.startsWith("macro=") ? url.hostname.slice("macro=".length) : null),
  );
  return macro ? `Keyboard Maestro: ${macro}` : "Keyboard Maestro";
}

function humanizeCleanshotUrl(url: URL): string {
  const pathLabel = url.hostname || url.pathname.replace(/^\//, "");
  return `CleanShot: ${humanizeSlug(pathLabel)}`;
}

function humanizeGenericUrl(rawValue: string): string {
  try {
    const url = new URL(rawValue);
    if (url.protocol === "raycast:") {
      return humanizeRaycastUrl(url);
    }
    if (url.protocol === "shortcuts:") {
      return humanizeShortcutUrl(url);
    }
    if (url.protocol === "kmtrigger:") {
      return humanizeKmTriggerUrl(url);
    }
    if (url.protocol === "cleanshot:") {
      return humanizeCleanshotUrl(url);
    }
    if (url.protocol === "http:" || url.protocol === "https:") {
      return `Open ${url.hostname}`;
    }
    return `${humanizeSlug(url.protocol.replace(/:$/, ""))}: ${humanizeSlug(url.hostname || url.pathname)}`;
  } catch {
    return snippet(rawValue, 48);
  }
}

function humanizeCommand(rawValue: string): string {
  const openAppMatch = rawValue.match(/open\s+-a\s+"?([^"]+?\.app|[^"\s]+)"?/i);
  if (openAppMatch) {
    const appName = openAppMatch[1]!.split("/").at(-1)!.replace(/\.app$/i, "");
    return `Open ${appName}`;
  }

  const menuClickMatch = rawValue.match(/menu click\s+([^\s]+)\s+"([^"]+)"/i);
  if (menuClickMatch) {
    const menuPath = menuClickMatch[2]!;
    const parts = menuPath.split(" > ").filter(Boolean);
    if (parts.length > 1) {
      return `${parts.at(-2)} → ${parts.at(-1)}`;
    }
    return parts[0] ?? "Menu Click";
  }

  const keystrokeMatch = rawValue.match(
    /keystroke "([^"]+)" using \{([^}]+)\}/i,
  );
  if (keystrokeMatch) {
    const key = keystrokeMatch[1]!;
    const modifiers = keystrokeMatch[2]!
      .split(",")
      .map((part) => part.trim().replace(/\s+down$/i, ""))
      .map((part) => {
        if (/command/i.test(part)) return "Cmd";
        if (/shift/i.test(part)) return "Shift";
        if (/option/i.test(part)) return "Opt";
        if (/control/i.test(part)) return "Ctrl";
        return humanizeSlug(part);
      });
    return `AppleScript: ${[...modifiers, key.toUpperCase()].join("+")}`;
  }

  const executable = rawValue.trim().split(/\s+/)[0] ?? "command";
  return `Run ${humanizeSlug(executable)}`;
}

function summarizeMacroSteps(macroSteps?: MacroStep[]): string[] {
  return (macroSteps ?? [])
    .filter((step) => step.enabled)
    .slice(0, 3)
    .map((step) => generateActionLabel(step.action, { breadcrumbPath: [], configDisplayName: "", inherited: false }));
}

function trimOptionalText(value: string | undefined): string | undefined {
  const trimmed = value?.trim();
  return trimmed ? trimmed : undefined;
}

export function generateActionLabel(action: ActionNode, context: ItemContext): string {
  switch (action.type) {
    case "application":
      return action.value ? action.value.split("/").at(-1)!.replace(/\.app$/i, "") : "Open Application";
    case "command":
      return humanizeCommand(action.value);
    case "folder":
      return action.value ? `Open ${action.value.split("/").filter(Boolean).at(-1) ?? action.value}` : "Open Folder";
    case "intellij": {
      const parsed = humanizedIntellijActions(action.value);
      const actionLabel = parsed.actions.join(", ");
      return parsed.delayMs ? `IntelliJ: ${actionLabel} (${parsed.delayMs}ms)` : `IntelliJ: ${actionLabel}`;
    }
    case "keystroke": {
      const parsed = parseKeystrokeValue(action.value);
      const shortcut = humanizeShortcutSequence(parsed.spec);
      if (parsed.app) {
        return parsed.focusTargetApp ? `${parsed.app}: ${shortcut} (focus)` : `${parsed.app}: ${shortcut}`;
      }
      return `Keystroke: ${shortcut}`;
    }
    case "macro": {
      const parts = summarizeMacroSteps(action.macroSteps);
      return parts.length > 0 ? `Macro: ${parts.join(" → ")}` : "Macro";
    }
    case "menu": {
      const parsed = parseMenuActionValue(action.value);
      if (parsed.pathSegments.length === 0) {
        return "Menu Item";
      }
      return parsed.pathSegments.length > 1
        ? `${parsed.pathSegments.at(-2)} → ${parsed.pathSegments.at(-1)}`
        : parsed.pathSegments.at(-1)!;
    }
    case "shortcut":
      return action.value ? `Shortcut: ${humanizeShortcutSequence(action.value)}` : "Shortcut";
    case "text": {
      const emailMatch = action.value.match(/^[^@\s]+@([^@\s]+)$/);
      if (emailMatch) {
        const domain = emailMatch[1]!;
        if (domain.includes("gmail.com")) {
          return "Type Gmail Address";
        }
        if (domain.includes("randstad")) {
          return "Type Randstad Email";
        }
        return `Type ${humanizeSlug(domain.split(".")[0]!) } Email`;
      }
      return `Type ${snippet(action.value, 24)}`;
    }
    case "normalModeDisable":
      return "Normal Mode Disable";
    case "normalModeEnable":
      return "Normal Mode Enable";
    case "normalModeInput":
      return "Normal Mode Input";
    case "toggleStickyMode":
      return "Toggle Sticky Mode";
    case "url":
      return humanizeGenericUrl(action.value);
  }
}

export function legacyCustomActionLabel(action: ActionNode, context: ItemContext): string | undefined {
  const currentLabel = trimOptionalText(action.label);
  if (!currentLabel) {
    return undefined;
  }

  return currentLabel === generateActionLabel(action, context) ? undefined : currentLabel;
}

export function resolveActionDescription(action: ActionNode, context: ItemContext): string | undefined {
  return trimOptionalText(action.description) ?? legacyCustomActionLabel(action, context);
}

export function resolveActionAiDescription(action: ActionNode): string | undefined {
  return trimOptionalText(action.aiDescription);
}

export function generateGroupLabel(group: GroupNode): string | undefined {
  const currentLabel = group.label?.trim() ?? "";
  if (currentLabel && !PLACEHOLDER_GROUP_LABEL.test(currentLabel) && !/^\d+$/.test(currentLabel)) {
    return currentLabel;
  }

  const key = group.key?.trim().toLowerCase() ?? "";
  return GROUP_LABELS.get(key);
}

export function generateLayerLabel(layer: LayerNode): string | undefined {
  const currentLabel = layer.label?.trim() ?? "";
  if (currentLabel && !PLACEHOLDER_GROUP_LABEL.test(currentLabel) && !/^\d+$/.test(currentLabel)) {
    return currentLabel;
  }

  const key = layer.key?.trim().toLowerCase() ?? "";
  return GROUP_LABELS.get(key);
}

export function actionValuePreview(action: ActionNode): string {
  switch (action.type) {
    case "application":
      return action.value ? action.value.split("/").at(-1)!.replace(/\.app$/i, "") : "";
    case "command":
      return snippet(action.value, 64);
    case "folder":
      return action.value;
    case "intellij": {
      const parsed = humanizedIntellijActions(action.value);
      return parsed.actions.join(", ");
    }
    case "keystroke": {
      const parsed = parseKeystrokeValue(action.value);
      const shortcut = humanizeShortcutSequence(parsed.spec);
      return parsed.app ? `${parsed.app} • ${shortcut}` : shortcut;
    }
    case "macro": {
      const summary = summarizeMacroSteps(action.macroSteps);
      return summary.join(" • ");
    }
    case "menu":
      return action.value;
    case "shortcut":
      return humanizeShortcutSequence(action.value);
    case "text":
      return snippet(action.value, 48);
    case "normalModeDisable":
      return "Disable normal mode";
    case "normalModeEnable":
      return "Enable normal mode";
    case "normalModeInput":
      return "Enter normal input mode";
    case "toggleStickyMode":
      return "Toggle sticky mode on or off";
    case "url":
      return humanizeGenericUrl(action.value);
  }
}

export function macroStepSummary(action: ActionNode): string[] {
  return summarizeMacroSteps(action.macroSteps);
}
