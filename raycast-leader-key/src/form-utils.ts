import { type ConfigItem, type FlatIndexRecord } from "@leaderkey/config-core";

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
