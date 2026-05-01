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
import { stableHash } from "./utils.js";
import type {
  ActionNode,
  CachePayload,
  ConfigItem,
  DiscoveredConfigFile,
  FlatIndexRecord,
  GroupNode,
  LayerNode,
  ScopeType,
} from "./types.js";

interface InternalSource {
  bundleId?: string;
  configDisplayName: string;
  configPath: string;
  nodePath: number[];
  scope: ScopeType;
}

interface InternalNodeBase {
  effectiveKeyPath: string[];
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

function createInternalNode(
  item: ConfigItem,
  source: InternalSource,
  effectiveKeyPath: string[],
  inherited: boolean,
): InternalNode {
  if (isContainerItem(item)) {
    return {
      children: item.actions.map((child, index) =>
        createInternalNode(
          child,
          { ...source, nodePath: [...source.nodePath, index] },
          [...effectiveKeyPath, child.key ?? `#${index}`],
          inherited,
        )),
      effectiveKeyPath,
      inherited,
      item,
      kind: item.type,
      source,
    } as InternalContainerNode;
  }

  return {
    effectiveKeyPath,
    inherited,
    item,
    kind: "action",
    source,
  };
}

function mergeGroups(
  effectiveDescriptor: DiscoveredConfigFile,
  localGroup: GroupNode | LayerNode,
  localSource: InternalSource,
  fallbackGroup: GroupNode | LayerNode | undefined,
  fallbackSource: InternalSource | undefined,
  effectiveKeyPath: string[] = [],
): InternalContainerNode {
  const children: InternalNode[] = [];
  const fallbackChildrenByKey = new Map<string, { index: number; item: ConfigItem }>();

  if (fallbackGroup) {
    fallbackGroup.actions.forEach((item, index) => {
      fallbackChildrenByKey.set(item.key ?? `#${index}`, { index, item });
    });
  }

  localGroup.actions.forEach((localItem, index) => {
    const localKey = localItem.key ?? `#${index}`;
    const localItemSource: InternalSource = {
      ...localSource,
      nodePath: [...localSource.nodePath, index],
    };
    const mergedKeyPath = [...effectiveKeyPath, localKey];
    const fallbackMatch = fallbackChildrenByKey.get(localKey);

    if (fallbackMatch && fallbackSource && containersCanMerge(localItem, fallbackMatch.item)) {
      children.push(
        mergeGroups(
          effectiveDescriptor,
          localItem as GroupNode | LayerNode,
          localItemSource,
          fallbackMatch.item as GroupNode | LayerNode,
          {
            ...fallbackSource,
            nodePath: [...fallbackSource.nodePath, fallbackMatch.index],
          },
          mergedKeyPath,
        ),
      );
      fallbackChildrenByKey.delete(localKey);
      return;
    }

    children.push(createInternalNode(localItem, localItemSource, mergedKeyPath, false));
    fallbackChildrenByKey.delete(localKey);
  });

  if (fallbackGroup && fallbackSource) {
    for (const [fallbackKey, fallbackEntry] of fallbackChildrenByKey.entries()) {
      const fallbackItemSource: InternalSource = {
        ...fallbackSource,
        nodePath: [...fallbackSource.nodePath, fallbackEntry.index],
      };

      const fallbackNode = createInternalNode(
        fallbackEntry.item,
        fallbackItemSource,
        [...effectiveKeyPath, fallbackKey],
        true,
      );
      children.push(fallbackNode);
    }
  }

  const mergedItem = localGroup.type === "layer"
    ? {
        actions: [],
        iconPath: localGroup.iconPath,
        key: localGroup.key,
        label: localGroup.label,
        tapAction: localGroup.tapAction,
        type: "layer" as const,
      }
    : {
        actions: [],
        key: localGroup.key,
        label: localGroup.label,
        stickyMode: localGroup.stickyMode,
        type: "group" as const,
      };

  return {
    children,
    effectiveKeyPath,
    inherited: false,
    item: mergedItem,
    kind: localGroup.type,
    source: localSource,
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
  const sourceStatus = node.inherited ? "fallback" : "local";

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
      sourceScope: node.source.scope,
      sourceStatus,
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
    sourceScope: node.source.scope,
    sourceStatus,
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

export async function buildCachePayload(configDirectory: string): Promise<CachePayload> {
  const configs = await discoverLiveConfigs(configDirectory);
  const fingerprint = configFingerprint(configs);
  const fallbackDescriptor = configs.find((config) => config.scope === "fallback");
  const fallbackGroup = fallbackDescriptor ? await loadGroupFromFile(fallbackDescriptor.filePath) : undefined;
  const normalFallbackDescriptor = configs.find((config) => config.scope === "normalFallback");
  const normalFallbackGroup = normalFallbackDescriptor
    ? await loadGroupFromFile(normalFallbackDescriptor.filePath)
    : undefined;
  const records: FlatIndexRecord[] = [];

  for (const descriptor of configs) {
    const sourceGroup = await loadGroupFromFile(descriptor.filePath);
    const localSource: InternalSource = {
      bundleId: descriptor.bundleId,
      configDisplayName: descriptor.displayName,
      configPath: descriptor.filePath,
      nodePath: [],
      scope: descriptor.scope,
    };

    let mergedRoot: InternalContainerNode;
    const inheritedDescriptor = descriptor.scope === "app"
      ? fallbackDescriptor
      : descriptor.scope === "normalApp"
        ? normalFallbackDescriptor
        : undefined;
    const inheritedGroup = descriptor.scope === "app"
      ? fallbackGroup
      : descriptor.scope === "normalApp"
        ? normalFallbackGroup
        : undefined;

    if ((descriptor.scope === "app" || descriptor.scope === "normalApp") && inheritedGroup && inheritedDescriptor) {
      const fallbackSource: InternalSource = {
        bundleId: inheritedDescriptor.bundleId,
        configDisplayName: inheritedDescriptor.displayName,
        configPath: inheritedDescriptor.filePath,
        nodePath: [],
        scope: inheritedDescriptor.scope,
      };
      mergedRoot = mergeGroups(descriptor, sourceGroup, localSource, inheritedGroup, fallbackSource);
    } else {
      mergedRoot = createInternalNode(sourceGroup, localSource, [], false) as InternalGroupNode;
    }

    flattenTree(mergedRoot, descriptor, records, []);
  }

  return {
    configDirectory,
    configs: toConfigSummaries(configs),
    fingerprint,
    generatedAt: new Date().toISOString(),
    records,
    version: CACHE_VERSION,
  };
}

export function recordsForConfig(payload: CachePayload, configDisplayName: string): FlatIndexRecord[] {
  return payload.records.filter((record) => record.effectiveConfigDisplayName === configDisplayName);
}
