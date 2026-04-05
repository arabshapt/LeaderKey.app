import { type ConfigItem, type FlatIndexRecord } from "@leaderkey/config-core";

const KEY_ALIASES = new Map<string, string>([
  ["left", "←"],
  ["left_arrow", "←"],
  ["leftarrow", "←"],
  ["right", "→"],
  ["right_arrow", "→"],
  ["rightarrow", "→"],
  ["up", "↑"],
  ["up_arrow", "↑"],
  ["uparrow", "↑"],
  ["down", "↓"],
  ["down_arrow", "↓"],
  ["downarrow", "↓"],
]);

export interface KeystrokeFields {
  app?: string;
  focusTargetApp: boolean;
  spec: string;
}

export interface ItemFormState {
  activates: boolean;
  applicationPath: string;
  commandValue: string;
  folderPath: string;
  intellijValue: string;
  key: string;
  keystroke: KeystrokeFields;
  label: string;
  menuValue: string;
  shortcutValue: string;
  stickyMode: boolean;
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
    applicationPath: "",
    commandValue: "",
    folderPath: "",
    intellijValue: "",
    key: "",
    keystroke: { focusTargetApp: false, spec: "" },
    label: "",
    menuValue: "",
    shortcutValue: "",
    stickyMode: false,
    textValue: "",
    type,
    urlValue: "",
  };
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
    applicationPath: record.actionType === "application" ? record.rawValue : "",
    commandValue: record.actionType === "command" ? record.rawValue : "",
    folderPath: record.actionType === "folder" ? record.rawValue : "",
    intellijValue: record.actionType === "intellij" ? record.rawValue : "",
    key: record.key ?? "",
    keystroke,
    label: record.label ?? record.displayLabel ?? "",
    menuValue: record.actionType === "menu" ? record.rawValue : "",
    shortcutValue: record.actionType === "shortcut" ? record.rawValue : "",
    stickyMode: record.stickyMode ?? false,
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
      key: item.key ?? "",
      label: item.label ?? "",
      stickyMode: item.stickyMode ?? false,
      type: "group",
    };
  }

  const baseState: ItemFormState = {
    ...emptyFormState(item.type),
    activates: item.activates ?? false,
    key: item.key ?? "",
    label: item.label ?? "",
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
    case "toggleStickyMode":
      return baseState;
    case "url":
      return { ...baseState, urlValue: item.value };
  }
}
