import path from "node:path";

import {
  APP_CONFIG_PREFIX,
  FALLBACK_CONFIG_FILE_NAME,
  GLOBAL_CONFIG_FILE_NAME,
  NORMAL_APP_CONFIG_PREFIX,
  NORMAL_FALLBACK_CONFIG_FILE_NAME,
} from "./constants.js";
import { parseIntellijActionValue, parseMenuActionValue } from "./action-values.js";
import type { ActionNode, CachePayload, ConfigItem, FlatIndexRecord, ScopeType } from "./types.js";

const DISALLOWED_LAYER_TRIGGER_KEYS = new Set([
  "caps_lock",
  "left_command",
  "right_command",
  "left_option",
  "right_option",
  "left_control",
  "right_control",
  "left_shift",
  "right_shift",
  "fn",
  "command",
  "option",
  "control",
  "shift",
]);

export interface ConfigItemValidationOptions {
  parentInsideLayer?: boolean;
  scope?: ScopeType;
}

export interface SiblingKeyValidationOptions {
  configFilePath: string;
  currentRecord?: FlatIndexRecord;
  key: string;
  parentKeyPath: string[];
}

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

function isKeyPathPrefix(prefix: string[], fullPath: string[]): boolean {
  return prefix.length <= fullPath.length && prefix.every((segment, index) => segment === fullPath[index]);
}

function isSameEditableRecord(currentRecord: FlatIndexRecord | undefined, candidate: FlatIndexRecord): boolean {
  return Boolean(currentRecord && candidate.id === currentRecord.id);
}

export function isNormalScope(scope: ScopeType | undefined): boolean {
  return scope === "normalApp" || scope === "normalFallback";
}

export function isNormalConfigPath(filePath: string): boolean {
  const fileName = path.basename(filePath);
  return fileName === NORMAL_FALLBACK_CONFIG_FILE_NAME || fileName.startsWith(NORMAL_APP_CONFIG_PREFIX);
}

export function scopeForConfigPath(filePath: string): ScopeType | undefined {
  const fileName = path.basename(filePath);
  if (fileName === GLOBAL_CONFIG_FILE_NAME) {
    return "global";
  }
  if (fileName === FALLBACK_CONFIG_FILE_NAME) {
    return "fallback";
  }
  if (fileName === NORMAL_FALLBACK_CONFIG_FILE_NAME) {
    return "normalFallback";
  }
  if (fileName.startsWith(NORMAL_APP_CONFIG_PREFIX)) {
    return "normalApp";
  }
  if (fileName.startsWith(APP_CONFIG_PREFIX)) {
    return "app";
  }
  return undefined;
}

export function validateActionValue(action: ActionNode): string | undefined {
  const rawType = (action as { type?: string }).type;
  const rawValue = (action as { value?: string }).value ?? "";
  if (rawType === "group" || rawType === "layer") {
    return "Action must be a terminal action.";
  }

  if (
    action.type === "normalModeDisable" ||
    action.type === "normalModeEnable" ||
    action.type === "normalModeInput" ||
    action.type === "toggleStickyMode"
  ) {
    return undefined;
  }

  if (action.type === "macro") {
    for (const [index, step] of (action.macroSteps ?? []).entries()) {
      if (!Number.isFinite(step.delay) || step.delay < 0) {
        return `Step ${index + 1}: Delay must be a non-negative number.`;
      }

      const stepError = validateActionValue(step.action);
      if (stepError) {
        return `Step ${index + 1}: ${stepError}`;
      }
    }
    return undefined;
  }

  if (action.type === "menu") {
    const parsed = parseMenuActionValue(rawValue);
    if (!parsed.appName?.trim()) {
      return "A target app is required for menu actions.";
    }
    if (!parsed.path.trim()) {
      return "A primary menu path is required.";
    }
    return undefined;
  }

  if (action.type === "intellij") {
    const parsed = parseIntellijActionValue(rawValue);
    if (parsed.actionIds.length === 0) {
      return "At least one IntelliJ action ID is required.";
    }
    const delayPart = rawValue.split("|")[1]?.trim();
    if (delayPart && parsed.delayMs === undefined) {
      return "Delay must be a whole number of milliseconds.";
    }
    return undefined;
  }

  if (!rawValue.trim()) {
    return "A value is required for this action type.";
  }

  return undefined;
}

export function validateConfigItem(item: ConfigItem, options: ConfigItemValidationOptions = {}): string | undefined {
  if (item.key === undefined || item.key.length === 0) {
    return "A key is required.";
  }
  if (item.type === "layer" && DISALLOWED_LAYER_TRIGGER_KEYS.has(item.key.toLowerCase())) {
    return "Modifier keys cannot be used as normal-mode layer triggers.";
  }
  if (item.key.length !== 1) {
    return "Key must resolve to exactly one key.";
  }

  if (item.type === "group") {
    return validateConfigItems(item.actions, options);
  }

  if (item.type === "layer") {
    if (!isNormalScope(options.scope)) {
      return "Layers are only supported in normal-mode configs.";
    }
    if (options.parentInsideLayer) {
      return "Nested layers are not supported.";
    }
    if (item.tapAction) {
      const tapActionError = validateActionValue(item.tapAction);
      if (tapActionError) {
        return `Tap action: ${tapActionError}`;
      }
    }
    return validateConfigItems(item.actions, {
      parentInsideLayer: true,
      scope: options.scope,
    });
  }

  return validateActionValue(item);
}

export function validateConfigItems(items: ConfigItem[], options: ConfigItemValidationOptions = {}): string | undefined {
  const seenKeys = new Set<string>();
  for (const item of items) {
    const key = item.key ?? "";
    if (key && seenKeys.has(key)) {
      return `An item with key '${key}' already exists at this path.`;
    }
    if (key) {
      seenKeys.add(key);
    }
  }

  for (const item of items) {
    const error = validateConfigItem(item, options);
    if (error) {
      return error;
    }
  }

  return undefined;
}

export function validateSiblingKeyInPayload(
  payload: CachePayload,
  options: SiblingKeyValidationOptions,
): string | undefined {
  const { configFilePath, currentRecord, key, parentKeyPath } = options;
  if (!key) {
    return "A key is required.";
  }

  const collision = payload.records.find((record) =>
    record.effectiveConfigPath === configFilePath &&
    keyPathMatches(record.parentEffectiveKeyPath, parentKeyPath) &&
    record.key === key &&
    !isSameEditableRecord(currentRecord, record)
  );

  return collision ? `An item with key '${key}' already exists at this path.` : undefined;
}

export function parentPathIsInsideLayer(
  payload: CachePayload | undefined,
  configFilePath: string,
  parentKeyPath: string[],
): boolean {
  if (!payload) {
    return false;
  }

  return payload.records.some((record) =>
    record.effectiveConfigPath === configFilePath &&
    record.kind === "layer" &&
    isKeyPathPrefix(record.effectiveKeyPath, parentKeyPath)
  );
}
