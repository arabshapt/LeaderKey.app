import fs from "node:fs/promises";
import path from "node:path";

import {
  APP_CONFIG_PREFIX,
  FALLBACK_CONFIG_DISPLAY_NAME,
  FALLBACK_CONFIG_FILE_NAME,
  GLOBAL_CONFIG_DISPLAY_NAME,
  GLOBAL_CONFIG_FILE_NAME,
  META_FILE_SUFFIX,
  NORMAL_APP_CONFIG_PREFIX,
  NORMAL_FALLBACK_CONFIG_DISPLAY_NAME,
  NORMAL_FALLBACK_CONFIG_FILE_NAME,
  NORMAL_TAG_CONFIG_DISPLAY_PREFIX,
  NORMAL_TAG_CONFIG_PREFIX,
  TAGS_REGISTRY_FILE_NAME,
  TAG_CONFIG_DISPLAY_PREFIX,
  TAG_CONFIG_PREFIX,
  defaultConfigDirectory,
} from "./constants.js";
import { loadTagsRegistry, tagConfigPath, tagDisplayName } from "./tags.js";
import { cocoaAbsoluteTime, stringifyConfig } from "./utils.js";
import type { ConfigMetadata, ConfigSummary, DiscoveredConfigFile, GroupNode, TagAssignmentScope } from "./types.js";

function buildMetaPath(filePath: string): string {
  return filePath.replace(/\.json$/i, `${META_FILE_SUFFIX}`);
}

function emptyRoot(): GroupNode {
  return { actions: [], type: "group" };
}

export async function loadMetadata(metaPath: string): Promise<ConfigMetadata | undefined> {
  try {
    const text = await fs.readFile(metaPath, "utf8");
    return JSON.parse(text) as ConfigMetadata;
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      return undefined;
    }
    throw error;
  }
}

export async function saveMetadata(metaPath: string, patch: Partial<ConfigMetadata>): Promise<void> {
  const existing = (await loadMetadata(metaPath)) ?? {};
  const nextValue: ConfigMetadata = {
    ...existing,
    ...patch,
    createdAt: existing.createdAt ?? cocoaAbsoluteTime(),
    lastModified: patch.lastModified ?? cocoaAbsoluteTime(),
  };

  await fs.writeFile(metaPath, stringifyConfig(nextValue));
}

export async function touchMetadataForConfig(configFilePath: string): Promise<void> {
  await saveMetadata(buildMetaPath(configFilePath), { lastModified: cocoaAbsoluteTime() });
}

export async function loadGroupFromFile(filePath: string): Promise<GroupNode> {
  try {
    const rawText = await fs.readFile(filePath, "utf8");
    const parsed = JSON.parse(rawText) as GroupNode;
    return parsed.type === "group" ? parsed : emptyRoot();
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      return emptyRoot();
    }
    throw error;
  }
}

export async function writeGroupToFile(filePath: string, group: GroupNode): Promise<void> {
  await fs.writeFile(filePath, stringifyConfig(group));
  await touchMetadataForConfig(filePath);
}

export async function discoverLiveConfigs(
  configDirectory = defaultConfigDirectory(),
): Promise<DiscoveredConfigFile[]> {
  const registryResult = await loadTagsRegistry(configDirectory);
  const registry = registryResult.registry;
  const entries = await fs.readdir(configDirectory, { withFileTypes: true });
  const discovered: DiscoveredConfigFile[] = [];

  const globalFilePath = path.join(configDirectory, GLOBAL_CONFIG_FILE_NAME);
  const fallbackFilePath = path.join(configDirectory, FALLBACK_CONFIG_FILE_NAME);
  const normalFallbackFilePath = path.join(configDirectory, NORMAL_FALLBACK_CONFIG_FILE_NAME);
  const files = entries.filter((entry) =>
    entry.isFile() &&
    entry.name.endsWith(".json") &&
    !entry.name.endsWith(META_FILE_SUFFIX) &&
    entry.name !== TAGS_REGISTRY_FILE_NAME
  );

  for (const entry of files) {
    const filePath = path.join(configDirectory, entry.name);
    const fileStat = await fs.stat(filePath);
    const metaPath = buildMetaPath(filePath);
    const metadata = await loadMetadata(metaPath);
    const metaStat = await fs.stat(metaPath).catch(() => undefined);

    let scope: DiscoveredConfigFile["scope"] | undefined;
    let defaultDisplayName: string | undefined;
    let bundleId: string | undefined;
    let tagId: string | undefined;

    if (filePath === globalFilePath) {
      scope = "global";
      defaultDisplayName = GLOBAL_CONFIG_DISPLAY_NAME;
    } else if (filePath === fallbackFilePath) {
      scope = "fallback";
      defaultDisplayName = FALLBACK_CONFIG_DISPLAY_NAME;
    } else if (filePath === normalFallbackFilePath) {
      scope = "normalFallback";
      defaultDisplayName = NORMAL_FALLBACK_CONFIG_DISPLAY_NAME;
    } else if (entry.name.startsWith(NORMAL_APP_CONFIG_PREFIX)) {
      scope = "normalApp";
      bundleId = entry.name.slice(NORMAL_APP_CONFIG_PREFIX.length, -".json".length);
      defaultDisplayName = `Normal: ${bundleId}`;
    } else if (entry.name.startsWith(NORMAL_TAG_CONFIG_PREFIX)) {
      scope = "normalTag";
      tagId = entry.name.slice(NORMAL_TAG_CONFIG_PREFIX.length, -".json".length);
      defaultDisplayName = `${NORMAL_TAG_CONFIG_DISPLAY_PREFIX}${tagDisplayName(registry, tagId)}`;
    } else if (entry.name.startsWith(APP_CONFIG_PREFIX)) {
      scope = "app";
      bundleId = entry.name.slice(APP_CONFIG_PREFIX.length, -".json".length);
      defaultDisplayName = `App: ${bundleId}`;
    } else if (entry.name.startsWith(TAG_CONFIG_PREFIX)) {
      scope = "tag";
      tagId = entry.name.slice(TAG_CONFIG_PREFIX.length, -".json".length);
      defaultDisplayName = `${TAG_CONFIG_DISPLAY_PREFIX}${tagDisplayName(registry, tagId)}`;
    }

    if (!scope || !defaultDisplayName) {
      continue;
    }

    discovered.push({
      bundleId,
      customName: metadata?.customName,
      defaultDisplayName,
      displayName: metadata?.customName?.trim() || defaultDisplayName,
      fileMtimeMs: fileStat.mtimeMs,
      fileName: entry.name,
      filePath,
      metaMtimeMs: metaStat?.mtimeMs,
      metaPath,
      scope,
      tagId,
    });
  }

  const discoveredPaths = new Set(discovered.map((config) => config.filePath));

  async function appendVirtualAssignedAppConfig(scope: TagAssignmentScope, bundleId: string): Promise<void> {
    const normalMode = scope === "normalApp";
    const fileName = `${normalMode ? NORMAL_APP_CONFIG_PREFIX : APP_CONFIG_PREFIX}${bundleId}.json`;
    const filePath = path.join(configDirectory, fileName);
    if (discoveredPaths.has(filePath)) {
      return;
    }

    const metaPath = buildMetaPath(filePath);
    const metadata = await loadMetadata(metaPath);
    const metaStat = await fs.stat(metaPath).catch(() => undefined);
    const defaultDisplayName = normalMode ? `Normal: ${bundleId}` : `App: ${bundleId}`;

    discovered.push({
      bundleId,
      customName: metadata?.customName,
      defaultDisplayName,
      displayName: metadata?.customName?.trim() || defaultDisplayName,
      fileMtimeMs: 0,
      fileName,
      filePath,
      metaMtimeMs: metaStat?.mtimeMs,
      metaPath,
      scope,
      virtual: true,
    });
    discoveredPaths.add(filePath);
  }

  for (const [bundleId, tagIds] of Object.entries(registry.assignments.app)) {
    if (tagIds.length > 0) {
      await appendVirtualAssignedAppConfig("app", bundleId);
    }
  }
  for (const [bundleId, tagIds] of Object.entries(registry.assignments.normalApp)) {
    if (tagIds.length > 0) {
      await appendVirtualAssignedAppConfig("normalApp", bundleId);
    }
  }

  const virtualTagRequests: Array<{ normalMode: boolean; tagId: string }> = [
    ...Object.values(registry.assignments.app).flat().map((tagId) => ({ normalMode: false, tagId })),
    ...Object.values(registry.assignments.normalApp).flat().map((tagId) => ({ normalMode: true, tagId })),
  ];
  for (const { normalMode, tagId } of virtualTagRequests) {
    const scope: DiscoveredConfigFile["scope"] = normalMode ? "normalTag" : "tag";
    const filePath = tagConfigPath(configDirectory, tagId, normalMode);
    if (discoveredPaths.has(filePath)) {
      continue;
    }

    const fileName = path.basename(filePath);
    const defaultDisplayName =
      `${normalMode ? NORMAL_TAG_CONFIG_DISPLAY_PREFIX : TAG_CONFIG_DISPLAY_PREFIX}${tagDisplayName(registry, tagId)}`;
    discovered.push({
      defaultDisplayName,
      displayName: defaultDisplayName,
      fileMtimeMs: 0,
      fileName,
      filePath,
      metaPath: buildMetaPath(filePath),
      scope,
      tagId,
      virtual: true,
    });
    discoveredPaths.add(filePath);
  }

  const scopeRank: Record<DiscoveredConfigFile["scope"], number> = {
    global: 0,
    fallback: 1,
    tag: 2,
    normalFallback: 3,
    normalTag: 4,
    app: 5,
    normalApp: 6,
  };

  return discovered.sort((left, right) => {
    const rankDelta = scopeRank[left.scope] - scopeRank[right.scope];
    if (rankDelta !== 0) {
      return rankDelta;
    }
    return left.displayName.localeCompare(right.displayName);
  });
}

export function configFingerprint(configs: DiscoveredConfigFile[], registryMtimeMs?: number): string {
  return [
    `registry:${registryMtimeMs?.toFixed(0) ?? 0}`,
    ...configs
      .map((config) =>
        [
          config.filePath,
          config.fileMtimeMs.toFixed(0),
          (config.metaMtimeMs ?? 0).toFixed(0),
          config.displayName,
          config.virtual ? "virtual" : "file",
        ].join(":"),
      ),
  ].join("|");
}

export function toConfigSummaries(configs: DiscoveredConfigFile[]): ConfigSummary[] {
  return configs.map((config) => ({
    bundleId: config.bundleId,
    displayName: config.displayName,
    filePath: config.filePath,
    scope: config.scope,
    tagId: config.tagId,
    virtual: config.virtual,
  }));
}
