import fs from "node:fs/promises";
import path from "node:path";
import {
  actionValuePreview,
  buildCachePayload,
  defaultConfigDirectory,
  generateActionLabel,
  generateGroupLabel,
  generateLayerLabel,
  macroStepSummary,
  resolveActionAiDescription,
  resolveActionDescription,
  type ActionNode,
  type CachePayload,
  type ConfigItem,
  type FlatIndexRecord,
  type GroupNode,
  type LayerNode,
  type ScopeType,
} from "@leaderkey/config-core";
import { deriveActionSafety } from "./safety.js";
import { slugify, stableHash } from "./text.js";
import type { ActionCatalog, ActionEntry, DispatchScope } from "./types.js";

export interface BuildCatalogOptions {
  catalogPath?: string;
  configDirectory?: string;
  scope?: DispatchScope;
  bundleId?: string;
  includeGlobal?: boolean;
}

function isContainer(item: ConfigItem): item is GroupNode | LayerNode {
  return item.type === "group" || item.type === "layer";
}

function actionIdFor(input: {
  explicit?: string;
  scope: string;
  bundleId?: string;
  path: string[];
  type: string;
  label: string;
  value: string;
  sourceNodePath?: number[];
}): string {
  const explicit = input.explicit?.trim();
  if (explicit) {
    return explicit;
  }
  const base = slugify([input.scope, input.bundleId, ...input.path, input.label].filter(Boolean).join(" "));
  const hash = stableHash(JSON.stringify({
    bundleId: input.bundleId,
    path: input.path,
    scope: input.scope,
    sourceNodePath: input.sourceNodePath,
    type: input.type,
    value: input.value,
  }));
  return `${base}-${hash}`;
}

function materializedSearchText(input: {
  configName: string;
  path: string[];
  groupLabels: string[];
  action: ActionNode;
  label: string;
  description?: string;
  aiDescription?: string;
  valuePreview: string;
  menuFallbackPaths?: string[];
  macroSummary?: string[];
}): string {
  return [
    `Config: ${input.configName}.`,
    `Path: ${input.path.join(" > ")}.`,
    input.groupLabels.length > 0 ? `Group: ${input.groupLabels.join(" > ")}.` : undefined,
    `Key: ${input.path.at(-1) ?? ""}.`,
    `Label: ${input.label}.`,
    input.description ? `Description: ${input.description}.` : undefined,
    input.aiDescription ? `AI: ${input.aiDescription}.` : undefined,
    `Type: ${input.action.type}.`,
    `Value: ${input.action.value}.`,
    input.valuePreview ? `Preview: ${input.valuePreview}.` : undefined,
    input.action.voiceAliases?.length ? `Aliases: ${input.action.voiceAliases.join(", ")}.` : undefined,
    input.menuFallbackPaths?.length ? `Menu fallbacks: ${input.menuFallbackPaths.join(" > ")}.` : undefined,
    input.macroSummary?.length ? `Macro: ${input.macroSummary.join(" then ")}.` : undefined,
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
}

function entryFromAction(input: {
  action: ActionNode;
  path: string[];
  groupLabels: string[];
  configName: string;
  effectiveScope: ScopeType | "catalog";
  bundleId?: string;
  effectiveConfigPath?: string;
  sourceScope?: ScopeType;
  sourceNodePath?: number[];
  record?: FlatIndexRecord;
}): ActionEntry {
  const context = {
    breadcrumbPath: [input.configName, ...input.path],
    configDisplayName: input.configName,
    inherited: input.record?.inherited ?? false,
  };
  const label = generateActionLabel(input.action, context);
  const description = resolveActionDescription(input.action, context);
  const aiDescription = resolveActionAiDescription(input.action);
  const valuePreview = actionValuePreview(input.action);
  const macroSummary = macroStepSummary(input.action);
  const searchText = [
    input.record?.searchText,
    materializedSearchText({
      action: input.action,
      aiDescription,
      configName: input.configName,
      description,
      groupLabels: input.groupLabels,
      label,
      macroSummary,
      menuFallbackPaths: input.action.menuFallbackPaths,
      path: input.path,
      valuePreview,
    }),
  ].filter(Boolean).join(" ");
  const safety = deriveActionSafety({
    description,
    label,
    searchText,
    source: input.action,
    type: input.action.type,
    value: input.action.value,
  });
  const id = actionIdFor({
    bundleId: input.bundleId,
    explicit: input.action.voiceId,
    label,
    path: input.path,
    scope: input.effectiveScope,
    sourceNodePath: input.sourceNodePath,
    type: input.action.type,
    value: input.action.value,
  });

  return {
    aiDescription,
    bundleId: input.bundleId,
    description,
    dispatchRef: {
      actionId: id,
      actionType: input.action.type,
      bundleId: input.bundleId,
      effectiveKeyPath: input.path,
      effectiveScope: input.effectiveScope,
      requiresConfirmation: safety.safety !== "safe",
      safety: safety.safety,
    },
    effectiveConfigDisplayName: input.configName,
    effectiveConfigPath: input.effectiveConfigPath,
    effectiveScope: input.effectiveScope,
    id,
    key: input.path.at(-1) ?? input.action.key ?? "",
    keys: input.path,
    label,
    macroStepSummary: macroSummary,
    path: input.path.join(" > "),
    record: input.record,
    recordId: input.record?.id,
    requiresConfirmation: safety.safety !== "safe",
    safety: safety.safety,
    safetyReasons: safety.reasons,
    searchText,
    source: input.action,
    sourceNodePath: input.sourceNodePath,
    sourceScope: input.sourceScope,
    type: input.action.type,
    value: input.action.value,
    valuePreview,
  };
}

function flattenStandalone(
  group: GroupNode | LayerNode,
  configName: string,
  entries: ActionEntry[] = [],
  keyPath: string[] = [],
  groupLabels: string[] = [],
  nodePath: number[] = [],
): ActionEntry[] {
  group.actions.forEach((item, index) => {
    const nextPath = [...keyPath, item.key ?? `#${index}`];
    const nextNodePath = [...nodePath, index];
    if (isContainer(item)) {
      const generated = item.type === "layer" ? generateLayerLabel(item) : generateGroupLabel(item);
      const nextLabels = [...groupLabels, generated ?? item.label ?? item.key ?? ""].filter(Boolean);
      flattenStandalone(item, configName, entries, nextPath, nextLabels, nextNodePath);
      if (item.type === "layer" && item.tapAction) {
        entries.push(entryFromAction({
          action: item.tapAction,
          configName,
          effectiveScope: "catalog",
          groupLabels,
          path: nextPath,
          sourceNodePath: nextNodePath,
        }));
      }
      return;
    }

    entries.push(entryFromAction({
      action: item,
      configName,
      effectiveScope: "catalog",
      groupLabels,
      path: nextPath,
      sourceNodePath: nextNodePath,
    }));
  });
  return entries;
}

async function loadStandaloneCatalog(catalogPath: string): Promise<ActionCatalog> {
  const raw = await fs.readFile(catalogPath, "utf8");
  const root = JSON.parse(raw) as GroupNode;
  const stat = await fs.stat(catalogPath);
  const entries = root.type === "group"
    ? flattenStandalone(root, path.basename(catalogPath, path.extname(catalogPath)))
    : [];
  return {
    entries,
    fingerprint: `${catalogPath}:${stat.mtimeMs.toFixed(0)}:${entries.length}`,
    source: "catalog",
  };
}

function recordKey(record: FlatIndexRecord): string {
  return `${record.effectiveConfigDisplayName}:${record.effectiveKeyPath.join("\u0000")}`;
}

function selectedRecords(payload: CachePayload, scope: DispatchScope, bundleId?: string, includeGlobal = false): FlatIndexRecord[] {
  const actionRecords = payload.records.filter((record) => record.kind === "action" || (record.kind === "layer" && record.tapAction));
  if (scope === "all") {
    return actionRecords;
  }
  if (scope === "global") {
    return actionRecords.filter((record) => record.effectiveScope === "global");
  }

  const regularApp = bundleId
    ? actionRecords.filter((record) => record.effectiveScope === "app" && record.effectiveBundleId === bundleId)
    : [];
  const normalApp = bundleId
    ? actionRecords.filter((record) => record.effectiveScope === "normalApp" && record.effectiveBundleId === bundleId)
    : [];
  const regular = regularApp.length > 0
    ? regularApp
    : actionRecords.filter((record) => record.effectiveScope === "fallback");
  const normal = normalApp.length > 0
    ? normalApp
    : actionRecords.filter((record) => record.effectiveScope === "normalFallback");
  const global = includeGlobal
    ? actionRecords.filter((record) => record.effectiveScope === "global")
    : [];
  return [...regular, ...normal, ...global];
}

function entriesFromPayload(payload: CachePayload, scope: DispatchScope, bundleId?: string, includeGlobal = false): ActionEntry[] {
  const containerLabels = new Map<string, string>();
  for (const record of payload.records) {
    if (record.kind === "group" || record.kind === "layer") {
      containerLabels.set(recordKey(record), record.displayLabel);
    }
  }

  return selectedRecords(payload, scope, bundleId, includeGlobal)
    .map((record) => {
      const source = record.kind === "layer"
        ? record.tapAction
        : record.sourceNode && record.sourceNode.type !== "group" && record.sourceNode.type !== "layer"
          ? record.sourceNode
          : undefined;
      if (!source) {
        return undefined;
      }
      const groupLabels = record.parentEffectiveKeyPath
        .map((_, index) => record.effectiveKeyPath.slice(0, index + 1))
        .map((parentPath) => containerLabels.get(`${record.effectiveConfigDisplayName}:${parentPath.join("\u0000")}`))
        .filter((label): label is string => Boolean(label));
      return entryFromAction({
        action: source,
        bundleId: record.effectiveBundleId,
        configName: record.effectiveConfigDisplayName,
        effectiveConfigPath: record.effectiveConfigPath,
        effectiveScope: record.effectiveScope,
        groupLabels,
        path: record.effectiveKeyPath,
        record,
        sourceNodePath: record.sourceNodePath,
        sourceScope: record.sourceScope,
      });
    })
    .filter((entry): entry is ActionEntry => Boolean(entry));
}

export async function buildActionCatalog(options: BuildCatalogOptions = {}): Promise<ActionCatalog> {
  if (options.catalogPath) {
    return loadStandaloneCatalog(options.catalogPath);
  }

  const configDirectory = options.configDirectory ?? defaultConfigDirectory();
  const payload = await buildCachePayload(configDirectory);
  return {
    entries: entriesFromPayload(
      payload,
      options.scope ?? "frontmost",
      options.bundleId,
      options.includeGlobal ?? false,
    ),
    fingerprint: payload.fingerprint,
    payload,
    source: "config",
  };
}
