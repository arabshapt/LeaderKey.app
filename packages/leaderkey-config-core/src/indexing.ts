import { CACHE_VERSION } from "./constants.js";
import { configFingerprint, discoverLiveConfigs, loadGroupFromFile, toConfigSummaries } from "./discovery.js";
import {
  actionValuePreview,
  generateActionLabel,
  generateGroupLabel,
  generateLayerLabel,
  macroStepSummary,
  resolveActionAiDescription,
  resolveActionDescription,
} from "./labels.js";
import { assignedTagIds, loadTagsRegistry, tagDefinitionById } from "./tags.js";
import { stableHash } from "./utils.js";
import type {
  ActionNode,
  CachePayload,
  ConfigDiagnostic,
  ConfigItem,
  DiscoveredConfigFile,
  FlatIndexRecord,
  GroupNode,
  LayerNode,
  SourceSummary,
  ScopeType,
  TagAssignmentScope,
  TagsRegistry,
} from "./types.js";

interface InternalSource {
  bundleId?: string;
  configDisplayName: string;
  configPath: string;
  nodePath: number[];
  priority: number;
  scope: ScopeType;
  sourceStatus: "fallback" | "local" | "tag";
  tagId?: string;
}

interface InternalNodeBase {
  effectiveKeyPath: string[];
  hiddenSources: SourceSummary[];
  inherited: boolean;
  source: InternalSource;
}

interface InternalActionNode extends InternalNodeBase {
  item: ActionNode;
  kind: "action";
}

interface InternalGroupNode extends InternalNodeBase {
  children: InternalNode[];
  item: GroupNode;
  kind: "group";
}

interface InternalLayerNode extends InternalNodeBase {
  children: InternalNode[];
  item: LayerNode;
  kind: "layer";
}

type InternalContainerNode = InternalGroupNode | InternalLayerNode;
type InternalNode = InternalActionNode | InternalContainerNode;

function isContainerItem(item: ConfigItem): item is GroupNode | LayerNode {
  return item.type === "group" || item.type === "layer";
}

function layerMetadataMatches(localLayer: LayerNode, fallbackLayer: LayerNode): boolean {
  return localLayer.label === fallbackLayer.label
    && localLayer.iconPath === fallbackLayer.iconPath
    && JSON.stringify(localLayer.tapAction ?? null) === JSON.stringify(fallbackLayer.tapAction ?? null);
}

function containersCanMerge(localItem: ConfigItem, fallbackItem: ConfigItem): boolean {
  if (localItem.type === "group" && fallbackItem.type === "group") {
    return true;
  }

  if (localItem.type === "layer" && fallbackItem.type === "layer") {
    return layerMetadataMatches(localItem, fallbackItem);
  }

  return false;
}

function keyForItem(item: ConfigItem, index: number): string {
  return item.key ?? `#${index}`;
}

function sourceSummary(source: InternalSource, keySequence?: string): SourceSummary {
  return {
    bundleId: source.bundleId,
    configDisplayName: source.configDisplayName,
    configPath: source.configPath,
    keySequence,
    priority: source.priority,
    scope: source.scope,
    sourceStatus: source.sourceStatus,
    tagId: source.tagId,
  };
}

function createInternalNode(
  item: ConfigItem,
  source: InternalSource,
  effectiveKeyPath: string[],
  inherited: boolean,
  hiddenSources: SourceSummary[] = [],
): InternalNode {
  if (isContainerItem(item)) {
    return {
      children: item.actions.map((child, index) =>
        createInternalNode(
          child,
          { ...source, nodePath: [...source.nodePath, index] },
          [...effectiveKeyPath, keyForItem(child, index)],
          inherited,
        )),
      effectiveKeyPath,
      hiddenSources,
      inherited,
      item,
      kind: item.type,
      source,
    } as InternalContainerNode;
  }

  return {
    effectiveKeyPath,
    hiddenSources,
    inherited,
    item,
    kind: "action",
    source,
  };
}

interface SourceContainer {
  group: GroupNode | LayerNode;
  inherited: boolean;
  source: InternalSource;
}

interface SourceItemEntry {
  index: number;
  inherited: boolean;
  item: ConfigItem;
  source: InternalSource;
}

function sourceForChild(entry: SourceItemEntry): InternalSource {
  return {
    ...entry.source,
    nodePath: [...entry.source.nodePath, entry.index],
  };
}

function makeMergedContainerShell(sourceGroup: GroupNode | LayerNode): GroupNode | LayerNode {
  return sourceGroup.type === "layer"
    ? {
        actions: [],
        iconPath: sourceGroup.iconPath,
        key: sourceGroup.key,
        label: sourceGroup.label,
        tapAction: sourceGroup.tapAction,
        type: "layer",
      }
    : {
        actions: [],
        iconPath: sourceGroup.iconPath,
        key: sourceGroup.key,
        label: sourceGroup.label,
        stickyMode: sourceGroup.stickyMode,
        type: "group",
      };
}

function mergeSourceContainers(
  containers: SourceContainer[],
  effectiveKeyPath: string[] = [],
): InternalContainerNode {
  const winnerContainer = containers[0]!;
  const children: InternalNode[] = [];

  const entriesByKey = new Map<string, SourceItemEntry[]>();
  const orderedKeys: string[] = [];

  for (const container of containers) {
    container.group.actions.forEach((item, index) => {
      const key = keyForItem(item, index);
      if (!entriesByKey.has(key)) {
        entriesByKey.set(key, []);
        orderedKeys.push(key);
      }
      entriesByKey.get(key)!.push({
        index,
        inherited: container.inherited,
        item,
        source: container.source,
      });
    });
  }

  for (const key of orderedKeys) {
    const entries = entriesByKey.get(key)!;
    const winnerEntry = entries[0]!;
    const winnerSource = sourceForChild(winnerEntry);
    const mergedKeyPath = [...effectiveKeyPath, key];

    if (isContainerItem(winnerEntry.item)) {
      const mergeableEntries: SourceItemEntry[] = [winnerEntry];
      const hiddenSources: SourceSummary[] = [];

      for (const lowerEntry of entries.slice(1)) {
        if (containersCanMerge(winnerEntry.item, lowerEntry.item)) {
          mergeableEntries.push(lowerEntry);
        } else {
          hiddenSources.push(sourceSummary(sourceForChild(lowerEntry), mergedKeyPath.join(" -> ")));
        }
      }

      const mergedContainer = mergeSourceContainers(
        mergeableEntries.map((entry) => ({
          group: entry.item as GroupNode | LayerNode,
          inherited: entry.inherited,
          source: sourceForChild(entry),
        })),
        mergedKeyPath,
      );
      if (hiddenSources.length > 0) {
        mergedContainer.hiddenSources.push(...hiddenSources);
      }
      children.push(mergedContainer);
      continue;
    }

    const hiddenSources = entries
      .slice(1)
      .map((entry) => sourceSummary(sourceForChild(entry), mergedKeyPath.join(" -> ")));
    children.push(createInternalNode(
      winnerEntry.item,
      winnerSource,
      mergedKeyPath,
      winnerEntry.inherited,
      hiddenSources,
    ));
  }

  return {
    children,
    effectiveKeyPath,
    hiddenSources: [],
    inherited: winnerContainer.inherited,
    item: makeMergedContainerShell(winnerContainer.group),
    kind: winnerContainer.group.type,
    source: winnerContainer.source,
  } as InternalContainerNode;
}

function buildBreadcrumb(configDisplayName: string, keyPath: string[]): string[] {
  return [configDisplayName, ...keyPath.filter(Boolean)];
}

function buildFlatRecord(
  node: InternalNode,
  effectiveDescriptor: DiscoveredConfigFile,
  parentEffectiveKeyPath: string[],
): FlatIndexRecord {
  const breadcrumbPath = buildBreadcrumb(effectiveDescriptor.displayName, node.effectiveKeyPath);
  const keySequence = node.effectiveKeyPath.join(" -> ");
  const sourceStatus = node.source.sourceStatus;

  if (node.kind === "group" || node.kind === "layer") {
    const label = node.kind === "layer" ? generateLayerLabel(node.item) : generateGroupLabel(node.item);
    const fallbackLabel = node.kind === "layer" ? "Layer" : "Group";
    const displayLabel = label ?? node.item.label ?? node.item.key ?? fallbackLabel;
    const childCount = node.children.length;
    const actionType = node.kind;

    return {
      actionType,
      activates: undefined,
      appName: undefined,
      breadcrumbDisplay: breadcrumbPath.join(" -> "),
      breadcrumbPath,
      childCount,
      displayLabel,
      effectiveConfigDisplayName: effectiveDescriptor.displayName,
      effectiveConfigPath: effectiveDescriptor.filePath,
      effectiveBundleId: effectiveDescriptor.bundleId,
      effectiveKeyPath: node.effectiveKeyPath,
      effectiveScope: effectiveDescriptor.scope,
      id: stableHash([
        effectiveDescriptor.filePath,
        node.source.configPath,
        node.source.nodePath.join("."),
        node.effectiveKeyPath.join("."),
        node.kind,
      ]),
      hiddenSources: node.hiddenSources,
      inherited: node.inherited,
      key: node.item.key ?? "",
      keySequence,
      kind: node.kind,
      label,
      macroStepSummary: undefined,
      menuFallbackPaths: undefined,
      normalModeAfter: undefined,
      parentEffectiveKeyPath,
      rawValue: "",
      searchText: [
        effectiveDescriptor.displayName,
        breadcrumbPath.join(" "),
        displayLabel,
        label,
        node.kind,
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase(),
      sourceConfigDisplayName: node.source.configDisplayName,
      sourceConfigPath: node.source.configPath,
      sourceBundleId: node.source.bundleId,
      sourceNodePath: node.source.nodePath,
      sourcePriority: node.source.priority,
      sourceScope: node.source.scope,
      sourceStatus,
      sourceTagId: node.source.tagId,
      stickyMode: node.kind === "group" ? node.item.stickyMode : undefined,
      tapAction: node.kind === "layer" ? node.item.tapAction : undefined,
      valuePreview: node.kind === "layer"
        ? `Layer with ${childCount} item${childCount === 1 ? "" : "s"}`
        : `Contains ${childCount} item${childCount === 1 ? "" : "s"}`,
    };
  }

  const itemContext = {
    breadcrumbPath,
    configDisplayName: effectiveDescriptor.displayName,
    inherited: node.inherited,
  };
  const actionLabel = generateActionLabel(node.item, {
    ...itemContext,
  });
  const description = resolveActionDescription(node.item, itemContext);
  const aiDescription = resolveActionAiDescription(node.item);
  const displayLabel = actionLabel || node.item.key || node.item.type || "Action";
  const valuePreview = actionValuePreview(node.item) || node.item.value || "";
  const appName = node.item.type === "application"
    ? valuePreview
    : node.item.type === "keystroke"
      ? valuePreview.split(" • ")[0]
      : undefined;

  return {
    actionType: node.item.type,
    activates: node.item.activates,
    appName,
    breadcrumbDisplay: breadcrumbPath.join(" -> "),
    breadcrumbPath,
    childCount: undefined,
    description,
      displayLabel,
      effectiveConfigDisplayName: effectiveDescriptor.displayName,
      effectiveConfigPath: effectiveDescriptor.filePath,
      effectiveBundleId: effectiveDescriptor.bundleId,
      effectiveKeyPath: node.effectiveKeyPath,
      effectiveScope: effectiveDescriptor.scope,
      id: stableHash([
        effectiveDescriptor.filePath,
        node.source.configPath,
        node.source.nodePath.join("."),
        node.effectiveKeyPath.join("."),
        node.item.type,
      ]),
    hiddenSources: node.hiddenSources,
    inherited: node.inherited,
    key: node.item.key ?? "",
    keySequence,
    kind: "action",
    aiDescription,
    label: node.item.label,
    macroStepSummary: macroStepSummary(node.item),
    menuFallbackPaths: node.item.menuFallbackPaths,
    normalModeAfter: node.item.normalModeAfter,
    parentEffectiveKeyPath,
    rawValue: node.item.value,
    searchText: [
      effectiveDescriptor.displayName,
      breadcrumbPath.join(" "),
      displayLabel,
      description,
      aiDescription,
      node.item.label,
      node.item.voiceAliases?.join(" "),
      node.item.type,
      node.item.value,
      node.item.menuFallbackPaths?.join(" "),
      valuePreview,
      appName,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase(),
    sourceConfigDisplayName: node.source.configDisplayName,
    sourceConfigPath: node.source.configPath,
    sourceBundleId: node.source.bundleId,
    sourceNode: node.item,
    sourceNodePath: node.source.nodePath,
    sourcePriority: node.source.priority,
    sourceScope: node.source.scope,
    sourceStatus,
    sourceTagId: node.source.tagId,
    stickyMode: node.item.stickyMode,
    voiceAliases: node.item.voiceAliases,
    voiceId: node.item.voiceId,
    voiceSafety: node.item.voiceSafety,
    valuePreview,
  };
}

function flattenTree(
  node: InternalContainerNode,
  effectiveDescriptor: DiscoveredConfigFile,
  records: FlatIndexRecord[] = [],
  parentEffectiveKeyPath: string[] = [],
): FlatIndexRecord[] {
  for (const child of node.children) {
    const record = buildFlatRecord(child, effectiveDescriptor, parentEffectiveKeyPath);
    records.push(record);

    if (child.kind === "group" || child.kind === "layer") {
      flattenTree(child, effectiveDescriptor, records, child.effectiveKeyPath);
    }
  }

  return records;
}

function sourceForDescriptor(
  descriptor: DiscoveredConfigFile,
  priority: number,
  sourceStatus: InternalSource["sourceStatus"],
): InternalSource {
  return {
    bundleId: descriptor.bundleId,
    configDisplayName: descriptor.displayName,
    configPath: descriptor.filePath,
    nodePath: [],
    priority,
    scope: descriptor.scope,
    sourceStatus,
    tagId: descriptor.tagId,
  };
}

function descriptorMapByScopeAndTag(
  configs: DiscoveredConfigFile[],
  scope: "normalTag" | "tag",
): Map<string, DiscoveredConfigFile> {
  const result = new Map<string, DiscoveredConfigFile>();
  for (const config of configs) {
    if (config.scope === scope && config.tagId) {
      result.set(config.tagId, config);
    }
  }
  return result;
}

function shadowDiagnostics(records: FlatIndexRecord[]): ConfigDiagnostic[] {
  const grouped = new Map<string, {
    affectedBundleIds: Set<string>;
    hiddenSource: SourceSummary;
    keySequence: string;
    winnerSource: SourceSummary;
  }>();

  for (const record of records) {
    for (const hiddenSource of record.hiddenSources ?? []) {
      const winnerSource: SourceSummary = {
        bundleId: record.sourceBundleId,
        configDisplayName: record.sourceConfigDisplayName,
        configPath: record.sourceConfigPath,
        keySequence: record.keySequence,
        priority: record.sourcePriority,
        scope: record.sourceScope,
        sourceStatus: record.sourceStatus,
        tagId: record.sourceTagId,
      };
      const key = [
        record.effectiveScope,
        record.keySequence,
        winnerSource.configPath,
        hiddenSource.configPath,
      ].join("\u0000");
      const existing = grouped.get(key);
      if (existing) {
        if (record.effectiveBundleId) {
          existing.affectedBundleIds.add(record.effectiveBundleId);
        }
        continue;
      }

      grouped.set(key, {
        affectedBundleIds: new Set(record.effectiveBundleId ? [record.effectiveBundleId] : []),
        hiddenSource,
        keySequence: record.keySequence,
        winnerSource,
      });
    }
  }

  return Array.from(grouped.values()).map((entry) => {
    const affectedBundleIds = Array.from(entry.affectedBundleIds).sort();
    const affectedText = affectedBundleIds.length > 0
      ? ` for ${affectedBundleIds.join(", ")}`
      : "";
    return {
      affectedBundleIds,
      hiddenSource: entry.hiddenSource,
      id: stableHash([
        "shadowedSource",
        entry.keySequence,
        entry.winnerSource.configPath,
        entry.hiddenSource.configPath,
        affectedBundleIds.join("|"),
      ]),
      keySequence: entry.keySequence,
      kind: "shadowedSource",
      message: `${entry.winnerSource.configDisplayName} overrides ${entry.hiddenSource.configDisplayName} at ${entry.keySequence}${affectedText}.`,
      severity: "warning",
      tagId: entry.hiddenSource.tagId ?? entry.winnerSource.tagId,
      winnerSource: entry.winnerSource,
    };
  });
}

export async function buildCachePayload(configDirectory: string): Promise<CachePayload> {
  const registryResult = await loadTagsRegistry(configDirectory);
  const registry = registryResult.registry;
  const registryTags = tagDefinitionById(registry);
  const configs = await discoverLiveConfigs(configDirectory);
  const fingerprint = configFingerprint(configs, registryResult.mtimeMs);
  const fallbackDescriptor = configs.find((config) => config.scope === "fallback");
  const fallbackGroup = fallbackDescriptor ? await loadGroupFromFile(fallbackDescriptor.filePath) : undefined;
  const normalFallbackDescriptor = configs.find((config) => config.scope === "normalFallback");
  const normalFallbackGroup = normalFallbackDescriptor
    ? await loadGroupFromFile(normalFallbackDescriptor.filePath)
    : undefined;
  const tagDescriptors = descriptorMapByScopeAndTag(configs, "tag");
  const normalTagDescriptors = descriptorMapByScopeAndTag(configs, "normalTag");
  const groupCache = new Map<string, Promise<GroupNode>>();
  const diagnostics: ConfigDiagnostic[] = [];
  const records: FlatIndexRecord[] = [];

  function loadGroupCached(filePath: string): Promise<GroupNode> {
    let cached = groupCache.get(filePath);
    if (!cached) {
      cached = loadGroupFromFile(filePath);
      groupCache.set(filePath, cached);
    }
    return cached;
  }

  async function sourceContainersForApp(
    descriptor: DiscoveredConfigFile,
    sourceGroup: GroupNode,
  ): Promise<SourceContainer[]> {
    const assignmentScope: TagAssignmentScope = descriptor.scope === "normalApp" ? "normalApp" : "app";
    const tagScope = descriptor.scope === "normalApp" ? "normalTag" : "tag";
    const activeTagDescriptors = descriptor.scope === "normalApp" ? normalTagDescriptors : tagDescriptors;
    const tagIds = assignedTagIds(registry, assignmentScope, descriptor.bundleId);

    const sources: SourceContainer[] = [{
      group: sourceGroup,
      inherited: false,
      source: sourceForDescriptor(descriptor, 0, "local"),
    }];

    for (const [index, tagId] of tagIds.entries()) {
      if (!registryTags.has(tagId)) {
        diagnostics.push({
          id: stableHash(["missingTagDefinition", assignmentScope, descriptor.bundleId, tagId]),
          kind: "missingTagDefinition",
          message: `${descriptor.displayName} references missing tag '${tagId}'.`,
          severity: "warning",
          tagId,
        });
      }

      const tagDescriptor = activeTagDescriptors.get(tagId);
      if (!tagDescriptor || tagDescriptor.virtual) {
        diagnostics.push({
          id: stableHash(["missingTagConfig", assignmentScope, descriptor.bundleId, tagId, tagScope]),
          kind: "missingTagConfig",
          message: `${descriptor.displayName} references ${tagScope === "normalTag" ? "normal " : ""}tag '${tagId}', but its config file is missing.`,
          severity: "warning",
          tagId,
        });
        continue;
      }

      sources.push({
        group: await loadGroupCached(tagDescriptor.filePath),
        inherited: true,
        source: sourceForDescriptor(tagDescriptor, index + 1, "tag"),
      });
    }

    const fallbackPriority = tagIds.length + 1;
    if (descriptor.scope === "normalApp") {
      if (normalFallbackDescriptor && normalFallbackGroup) {
        sources.push({
          group: normalFallbackGroup,
          inherited: true,
          source: sourceForDescriptor(normalFallbackDescriptor, fallbackPriority, "fallback"),
        });
      }
    } else if (fallbackDescriptor && fallbackGroup) {
      sources.push({
        group: fallbackGroup,
        inherited: true,
        source: sourceForDescriptor(fallbackDescriptor, fallbackPriority, "fallback"),
      });
    }

    return sources;
  }

  for (const descriptor of configs) {
    const sourceGroup = await loadGroupCached(descriptor.filePath);
    const localSource: InternalSource = {
      bundleId: descriptor.bundleId,
      configDisplayName: descriptor.displayName,
      configPath: descriptor.filePath,
      nodePath: [],
      priority: 0,
      scope: descriptor.scope,
      sourceStatus: "local",
      tagId: descriptor.tagId,
    };

    let mergedRoot: InternalContainerNode;
    if (descriptor.scope === "app" || descriptor.scope === "normalApp") {
      mergedRoot = mergeSourceContainers(await sourceContainersForApp(descriptor, sourceGroup));
    } else {
      mergedRoot = createInternalNode(sourceGroup, localSource, [], false) as InternalGroupNode;
    }

    flattenTree(mergedRoot, descriptor, records, []);
  }

  return {
    configDirectory,
    configs: toConfigSummaries(configs),
    diagnostics: [...diagnostics, ...shadowDiagnostics(records)],
    fingerprint,
    generatedAt: new Date().toISOString(),
    records,
    tagsRegistry: registry,
    version: CACHE_VERSION,
  };
}

export function recordsForConfig(payload: CachePayload, configDisplayName: string): FlatIndexRecord[] {
  return payload.records.filter((record) => record.effectiveConfigDisplayName === configDisplayName);
}
