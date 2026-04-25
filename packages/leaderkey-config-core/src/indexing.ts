import { CACHE_VERSION } from "./constants.js";
import { configFingerprint, discoverLiveConfigs, loadGroupFromFile, toConfigSummaries } from "./discovery.js";
import {
  actionValuePreview,
  generateActionLabel,
  generateGroupLabel,
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
  ScopeType,
} from "./types.js";

interface InternalSource {
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

type InternalNode = InternalActionNode | InternalGroupNode;

function createInternalNode(
  item: ConfigItem,
  source: InternalSource,
  effectiveKeyPath: string[],
  inherited: boolean,
): InternalNode {
  if (item.type === "group") {
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
      kind: "group",
      source,
    };
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
  localGroup: GroupNode,
  localSource: InternalSource,
  fallbackGroup: GroupNode | undefined,
  fallbackSource: InternalSource | undefined,
  effectiveKeyPath: string[] = [],
): InternalGroupNode {
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

    if (localItem.type === "group" && fallbackMatch?.item.type === "group" && fallbackSource) {
      children.push(
        mergeGroups(
          effectiveDescriptor,
          localItem,
          localItemSource,
          fallbackMatch.item,
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

  return {
    children,
    effectiveKeyPath,
    inherited: false,
    item: {
      actions: [],
      key: localGroup.key,
      label: localGroup.label,
      stickyMode: localGroup.stickyMode,
      type: "group",
    },
    kind: "group",
    source: localSource,
  };
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

  if (node.kind === "group") {
    const label = generateGroupLabel(node.item);
    const displayLabel = label ?? node.item.label ?? node.item.key ?? "Group";
    const childCount = node.children.length;

    return {
      actionType: "group",
    activates: undefined,
    appName: undefined,
      breadcrumbDisplay: breadcrumbPath.join(" -> "),
      breadcrumbPath,
      childCount,
      displayLabel,
      effectiveConfigDisplayName: effectiveDescriptor.displayName,
      effectiveConfigPath: effectiveDescriptor.filePath,
      effectiveKeyPath: node.effectiveKeyPath,
      effectiveScope: effectiveDescriptor.scope,
      id: stableHash([
        effectiveDescriptor.filePath,
        node.source.configPath,
        node.source.nodePath.join("."),
        node.effectiveKeyPath.join("."),
        "group",
      ]),
      inherited: node.inherited,
      key: node.item.key ?? "",
      keySequence,
      kind: "group",
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
        "group",
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase(),
      sourceConfigDisplayName: node.source.configDisplayName,
      sourceConfigPath: node.source.configPath,
      sourceNodePath: node.source.nodePath,
      sourceScope: node.source.scope,
      sourceStatus,
      stickyMode: node.item.stickyMode,
      valuePreview: `Contains ${childCount} item${childCount === 1 ? "" : "s"}`,
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
    sourceNodePath: node.source.nodePath,
    sourceScope: node.source.scope,
    sourceStatus,
    stickyMode: node.item.stickyMode,
    valuePreview,
  };
}

function flattenTree(
  node: InternalGroupNode,
  effectiveDescriptor: DiscoveredConfigFile,
  records: FlatIndexRecord[] = [],
  parentEffectiveKeyPath: string[] = [],
): FlatIndexRecord[] {
  for (const child of node.children) {
    const record = buildFlatRecord(child, effectiveDescriptor, parentEffectiveKeyPath);
    records.push(record);

    if (child.kind === "group") {
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
      configDisplayName: descriptor.displayName,
      configPath: descriptor.filePath,
      nodePath: [],
      scope: descriptor.scope,
    };

    let mergedRoot: InternalGroupNode;
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
