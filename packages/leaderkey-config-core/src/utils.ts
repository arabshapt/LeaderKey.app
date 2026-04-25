import crypto from "node:crypto";
import path from "node:path";

import type { ActionNode, ConfigItem, GroupNode, LayerNode } from "./types.js";

const SHORTCUT_KEY_NAMES = new Map<string, string>([
  ["backspace", "Backspace"],
  ["caps_lock", "Caps Lock"],
  ["capslock", "Caps Lock"],
  ["delete", "Delete"],
  ["down_arrow", "Down Arrow"],
  ["downarrow", "Down Arrow"],
  ["end", "End"],
  ["escape", "Escape"],
  ["esc", "Escape"],
  ["forward_delete", "Forward Delete"],
  ["home", "Home"],
  ["left_arrow", "Left Arrow"],
  ["leftarrow", "Left Arrow"],
  ["page_down", "Page Down"],
  ["page_up", "Page Up"],
  ["return", "Return"],
  ["right_arrow", "Right Arrow"],
  ["rightarrow", "Right Arrow"],
  ["space", "Space"],
  ["spacebar", "Space"],
  ["tab", "Tab"],
  ["up_arrow", "Up Arrow"],
  ["uparrow", "Up Arrow"],
]);

const MODIFIER_NAMES = new Map<string, string>([
  ["C", "Cmd"],
  ["F", "Fn"],
  ["O", "Opt"],
  ["S", "Shift"],
  ["T", "Ctrl"],
]);

export function basenameWithoutApp(filePath: string): string {
  const baseName = path.basename(filePath);
  return baseName.replace(/\.app$/i, "");
}

export function stableHash(parts: Array<string | number | boolean | undefined>): string {
  const value = parts.map((part) => String(part ?? "")).join("\u0000");
  return crypto.createHash("sha1").update(value).digest("hex");
}

export function cloneConfigItem<T extends ConfigItem>(item: T): T {
  return structuredClone(item);
}

export function isGroup(item: ConfigItem): item is GroupNode {
  return item.type === "group";
}

export function isLayer(item: ConfigItem): item is LayerNode {
  return item.type === "layer";
}

export function isContainer(item: ConfigItem): item is GroupNode | LayerNode {
  return item.type === "group" || item.type === "layer";
}

export function isAction(item: ConfigItem): item is ActionNode {
  return item.type !== "group" && item.type !== "layer";
}

export function sortObjectKeys<T>(value: T): T {
  if (Array.isArray(value)) {
    return value.map((entry) => sortObjectKeys(entry)) as T;
  }

  if (value && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([, entryValue]) => entryValue !== undefined)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([key, entryValue]) => [key, sortObjectKeys(entryValue)]);

    return Object.fromEntries(entries) as T;
  }

  return value;
}

export function stringifyConfig(value: unknown): string {
  return `${JSON.stringify(sortObjectKeys(value), null, 2)}\n`;
}

export function cocoaAbsoluteTime(date = new Date()): number {
  const cocoaEpochMillis = Date.UTC(2001, 0, 1);
  return (date.getTime() - cocoaEpochMillis) / 1000;
}

export function humanizeSlug(value: string): string {
  const normalized = value
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/[_-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/\b\w/g, (char) => char.toUpperCase());

  return normalized
    .replace(/\bAi\b/g, "AI")
    .replace(/\bApi\b/g, "API")
    .replace(/\bCli\b/g, "CLI")
    .replace(/\bKm\b/g, "KM")
    .replace(/\bPdf\b/g, "PDF")
    .replace(/\bPwa\b/g, "PWA")
    .replace(/\bUrl\b/g, "URL")
    .replace(/\bVs\b/g, "VS");
}

export function humanizeShortcutSequence(spec: string): string {
  return spec
    .split(/\s+/)
    .filter(Boolean)
    .map((token) => humanizeShortcutToken(token))
    .join(" then ");
}

export function humanizeShortcutToken(token: string): string {
  if (!token.trim()) {
    return "";
  }

  const modifiers: string[] = [];
  let index = 0;

  while (index < token.length && MODIFIER_NAMES.has(token[index]!)) {
    const modifier = MODIFIER_NAMES.get(token[index]!)!;
    if (!modifiers.includes(modifier)) {
      modifiers.push(modifier);
    }
    index += 1;
  }

  const rawKey = token.slice(index);
  if (!rawKey) {
    return modifiers.join("+");
  }

  let keyName = SHORTCUT_KEY_NAMES.get(rawKey.toLowerCase()) ?? rawKey;
  if (/^f\d+$/i.test(rawKey)) {
    keyName = rawKey.toUpperCase();
  } else if (keyName === rawKey) {
    keyName = rawKey.length === 1 ? rawKey.toUpperCase() : humanizeSlug(rawKey);
  }

  return modifiers.length > 0 ? `${modifiers.join("+")}+${keyName}` : keyName;
}

export function snippet(value: string, maxLength = 40): string {
  if (value.length <= maxLength) {
    return value;
  }

  return `${value.slice(0, maxLength - 1)}…`;
}

export function uniqueBy<T>(values: T[], selector: (value: T) => string): T[] {
  const seen = new Set<string>();
  const result: T[] = [];

  for (const value of values) {
    const key = selector(value);
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    result.push(value);
  }

  return result;
}
