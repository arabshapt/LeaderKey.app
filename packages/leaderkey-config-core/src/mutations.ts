import fs from "node:fs/promises";

import { FALLBACK_CONFIG_DISPLAY_NAME } from "./constants.js";
import {
  scopeForConfigPath,
  validateConfigItem,
} from "./config-validation.js";
import { loadGroupFromFile, writeGroupToFile } from "./discovery.js";
import {
  generateActionLabel,
  generateGroupLabel,
  generateLayerLabel,
  resolveActionAiDescription,
  resolveActionDescription,
} from "./labels.js";
import { cloneConfigItem } from "./utils.js";
import type { ActionNode, ConfigItem, FlatIndexRecord, GroupNode, LayerNode } from "./types.js";

export type MutationMode = "edit-source" | "override-in-effective-config";

interface JsonNode {
  elements?: JsonNode[];
  kind: "array" | "literal" | "object";
  offset: number;
  properties?: Map<string, JsonNode>;
}

type ContainerNode = GroupNode | LayerNode;
type ContainerType = "group" | "layer";

function isContainerItem(item: ConfigItem): item is ContainerNode {
  return item.type === "group" || item.type === "layer";
}

function isWhitespace(char: string | undefined): boolean {
  return char === " " || char === "\n" || char === "\r" || char === "\t";
}

function parseJsonTree(text: string): JsonNode {
  let index = 0;

  function skipTrivia(): void {
    while (index < text.length) {
      const current = text[index];
      const next = text[index + 1];
      if (isWhitespace(current)) {
        index += 1;
        continue;
      }
      if (current === "/" && next === "/") {
        index += 2;
        while (index < text.length && text[index] !== "\n") {
          index += 1;
        }
        continue;
      }
      if (current === "/" && next === "*") {
        index += 2;
        while (index + 1 < text.length && !(text[index] === "*" && text[index + 1] === "/")) {
          index += 1;
        }
        index += 2;
        continue;
      }
      break;
    }
  }

  function expect(char: string): void {
    skipTrivia();
    if (text[index] !== char) {
      throw new Error(`Expected "${char}" at offset ${index}`);
    }
    index += 1;
  }

  function parseString(): string {
    skipTrivia();
    if (text[index] !== "\"") {
      throw new Error(`Expected string at offset ${index}`);
    }

    index += 1;
    let value = "";
    while (index < text.length) {
      const current = text[index];
      if (current === "\"") {
        index += 1;
        return value;
      }
      if (current === "\\") {
        const escape = text[index + 1];
        if (escape === undefined) {
          throw new Error("Unexpected end of string escape");
        }
        value += current + escape;
        index += 2;
        continue;
      }
      value += current;
      index += 1;
    }

    throw new Error("Unterminated string literal");
  }

  function parseLiteral(): JsonNode {
    skipTrivia();
    const offset = index;
    if (text[index] === "\"") {
      parseString();
      return { kind: "literal", offset };
    }

    while (index < text.length) {
      const current = text[index];
      if (current === undefined || isWhitespace(current) || current === "," || current === "}" || current === "]") {
        break;
      }
      index += 1;
    }
    return { kind: "literal", offset };
  }

  function parseArray(): JsonNode {
    skipTrivia();
    const offset = index;
    expect("[");
    const elements: JsonNode[] = [];

    skipTrivia();
    if (text[index] === "]") {
      index += 1;
      return { elements, kind: "array", offset };
    }

    while (index < text.length) {
      elements.push(parseValue());
      skipTrivia();
      if (text[index] === "]") {
        index += 1;
        return { elements, kind: "array", offset };
      }
      expect(",");
    }

    throw new Error("Unterminated array");
  }

  function parseObject(): JsonNode {
    skipTrivia();
    const offset = index;
    expect("{");
    const properties = new Map<string, JsonNode>();

    skipTrivia();
    if (text[index] === "}") {
      index += 1;
      return { kind: "object", offset, properties };
    }

    while (index < text.length) {
      const key = parseString();
      expect(":");
      properties.set(key, parseValue());
      skipTrivia();
      if (text[index] === "}") {
        index += 1;
        return { kind: "object", offset, properties };
      }
      expect(",");
    }

    throw new Error("Unterminated object");
  }

  function parseValue(): JsonNode {
    skipTrivia();
    const current = text[index];
    if (current === "{") {
      return parseObject();
    }
    if (current === "[") {
      return parseArray();
    }
    return parseLiteral();
  }

  const root = parseValue();
  skipTrivia();
  return root;
}

function getMutableItemAtPath(group: GroupNode, nodePath: number[]): ConfigItem {
  let currentGroup: ContainerNode = group;

  for (let index = 0; index < nodePath.length; index += 1) {
    const item: ConfigItem | undefined = currentGroup.actions[nodePath[index]!];
    if (!item) {
      throw new Error(`Invalid node path: ${nodePath.join(".")}`);
    }

    if (index === nodePath.length - 1) {
      return item;
    }

    if (!isContainerItem(item)) {
      throw new Error(`Path ${nodePath.join(".")} does not point to a container`);
    }

    currentGroup = item;
  }

  return currentGroup;
}

function getMutableContainerAtPath(group: GroupNode, nodePath: number[]): ContainerNode {
  if (nodePath.length === 0) {
    return group;
  }

  const item = getMutableItemAtPath(group, nodePath);
  if (!isContainerItem(item)) {
    throw new Error(`Path ${nodePath.join(".")} is not a container`);
  }
  return item;
}

function getMutableContainerContextAtPath(group: GroupNode, nodePath: number[]): {
  container: ContainerNode;
  insideLayer: boolean;
} {
  let current: ContainerNode = group;
  let insideLayer = false;

  for (const pathIndex of nodePath) {
    const item: ConfigItem | undefined = current.actions[pathIndex];
    if (!item) {
      throw new Error(`Invalid node path: ${nodePath.join(".")}`);
    }
    if (!isContainerItem(item)) {
      throw new Error(`Path ${nodePath.join(".")} is not a container`);
    }
    if (item.type === "layer") {
      insideLayer = true;
    }
    current = item;
  }

  return {
    container: current,
    insideLayer,
  };
}

function getMutableParentContainer(group: GroupNode, nodePath: number[]): ContainerNode {
  return getMutableContainerAtPath(group, nodePath.slice(0, -1));
}

function getMutableParentContainerContext(group: GroupNode, nodePath: number[]): {
  container: ContainerNode;
  insideLayer: boolean;
} {
  return getMutableContainerContextAtPath(group, nodePath.slice(0, -1));
}

function nextGroupLabel(group: GroupNode): string | undefined {
  return generateGroupLabel(group);
}

function nextLayerLabel(layer: LayerNode): string | undefined {
  return generateLayerLabel(layer);
}

function nextActionLabel(action: ActionNode): string {
  return generateActionLabel(action, {
    breadcrumbPath: [],
    configDisplayName: "",
    inherited: false,
  });
}

function nextActionDescription(action: ActionNode): string | undefined {
  return resolveActionDescription(action, {
    breadcrumbPath: [],
    configDisplayName: "",
    inherited: false,
  });
}

function normalizeItemBeforeSave(item: ConfigItem): ConfigItem {
  if (item.type === "group") {
    return {
      ...item,
      actions: item.actions.map((child) => normalizeItemBeforeSave(child)),
      label: nextGroupLabel(item) ?? item.label,
    };
  }

  if (item.type === "layer") {
    return {
      ...item,
      actions: item.actions.map((child) => normalizeItemBeforeSave(child)),
      label: nextLayerLabel(item) ?? item.label,
      tapAction: item.tapAction
        ? (normalizeItemBeforeSave(item.tapAction) as ActionNode)
        : undefined,
    };
  }

  return {
    ...item,
    aiDescription: resolveActionAiDescription(item),
    description: nextActionDescription(item),
    label: nextActionLabel(item),
  };
}

function containerTypesAtPath(root: GroupNode, nodePath: number[]): ContainerType[] {
  let current: ContainerNode = root;
  const types: ContainerType[] = [];

  for (const pathIndex of nodePath) {
    const item: ConfigItem | undefined = current.actions[pathIndex];
    if (!item) {
      throw new Error(`Invalid node path: ${nodePath.join(".")}`);
    }
    if (!isContainerItem(item)) {
      throw new Error(`Path ${nodePath.join(".")} does not point to a container`);
    }
    types.push(item.type);
    current = item;
  }

  return types;
}

function makeContainerForKey(key: string, type: ContainerType): ContainerNode {
  if (type === "layer") {
    return {
      actions: [],
      key,
      label: undefined,
      type: "layer",
    };
  }

  return {
    actions: [],
    key,
    label: undefined,
    type: "group",
  };
}

function ensureContainerPathByKeys(root: GroupNode, keyPath: string[], containerTypes: ContainerType[] = []): {
  container: ContainerNode;
  insideLayer: boolean;
} {
  let current: ContainerNode = root;
  let insideLayer = false;

  for (const [index, key] of keyPath.entries()) {
    const blockingAction = current.actions.find(
      (item) => !isContainerItem(item) && (item.key ?? "") === key,
    );
    if (blockingAction) {
      throw new Error(`Cannot create subgroup '${key}' because an action with that key already exists.`);
    }

    const existingGroup: ContainerNode | undefined = current.actions.find(
      (item): item is ContainerNode => isContainerItem(item) && (item.key ?? "") === key,
    );

    if (existingGroup) {
      if (existingGroup.type === "layer") {
        insideLayer = true;
      }
      current = existingGroup;
      continue;
    }

    const newContainer = makeContainerForKey(key, containerTypes[index] ?? "group");
    current.actions.push(newContainer);
    if (newContainer.type === "layer") {
      insideLayer = true;
    }
    current = newContainer;
  }

  return {
    container: current,
    insideLayer,
  };
}

function assertCanAddChild(
  group: ContainerNode,
  item: ConfigItem,
  options: {
    ignoredIndex?: number;
    parentInsideLayer: boolean;
    scopePath: string;
  },
): ConfigItem {
  const normalizedItem = normalizeItemBeforeSave(item);
  const key = normalizedItem.key;

  if (key === undefined || key.length === 0) {
    throw new Error("A key is required.");
  }

  const existingIndex = group.actions.findIndex((candidate, index) =>
    index !== options.ignoredIndex && (candidate.key ?? "") === key
  );
  if (existingIndex >= 0) {
    throw new Error(`An item with key '${key}' already exists at this path.`);
  }

  const validationError = validateConfigItem(normalizedItem, {
    parentInsideLayer: options.parentInsideLayer,
    scope: scopeForConfigPath(options.scopePath),
  });
  if (validationError) {
    throw new Error(validationError);
  }

  return {
    ...normalizedItem,
    key,
  };
}

function replaceOrAppendByKey(group: ContainerNode, item: ConfigItem): void {
  const key = item.key ?? "";
  const existingIndex = group.actions.findIndex((candidate) => (candidate.key ?? "") === key);
  if (existingIndex >= 0) {
    group.actions.splice(existingIndex, 1, item);
    return;
  }

  group.actions.push(item);
}

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

export async function updateRecord(
  record: FlatIndexRecord,
  nextItem: ConfigItem,
  mode: MutationMode = "edit-source",
): Promise<string> {
  if (record.inherited && mode === "override-in-effective-config") {
    const effectiveRoot = await loadGroupFromFile(record.effectiveConfigPath);
    const sourceRoot = await loadGroupFromFile(record.sourceConfigPath);
    const sourceParentTypes = containerTypesAtPath(sourceRoot, record.sourceNodePath.slice(0, -1));
    const localParent = ensureContainerPathByKeys(
      effectiveRoot,
      record.parentEffectiveKeyPath,
      sourceParentTypes,
    );
    const normalizedItem = assertCanAddChild(localParent.container, nextItem, {
      parentInsideLayer: localParent.insideLayer,
      scopePath: record.effectiveConfigPath,
    });
    replaceOrAppendByKey(localParent.container, normalizedItem);
    await writeGroupToFile(record.effectiveConfigPath, effectiveRoot);
    return record.effectiveConfigPath;
  }

  const targetPath = record.sourceConfigPath;
  const root = await loadGroupFromFile(targetPath);
  const parentContext = getMutableParentContainerContext(root, record.sourceNodePath);
  const itemIndex = record.sourceNodePath.at(-1)!;
  const normalizedItem = assertCanAddChild(parentContext.container, nextItem, {
    ignoredIndex: itemIndex,
    parentInsideLayer: parentContext.insideLayer,
    scopePath: targetPath,
  });
  parentContext.container.actions.splice(itemIndex, 1, normalizedItem);
  await writeGroupToFile(targetPath, root);
  return targetPath;
}

export async function updateRecordAtPath(
  record: FlatIndexRecord,
  nextItem: ConfigItem,
  destinationKeyPath: string[],
  mode: MutationMode = "edit-source",
): Promise<string> {
  const destinationKey = destinationKeyPath.at(-1);
  if (destinationKey === undefined || destinationKey.length === 0) {
    throw new Error("A full path is required.");
  }

  if (mode === "override-in-effective-config") {
    if (!keyPathMatches(record.effectiveKeyPath, destinationKeyPath)) {
      throw new Error("Override edits cannot move the path.");
    }

    return updateRecord(record, { ...nextItem, key: destinationKey }, mode);
  }

  if (keyPathMatches(record.effectiveKeyPath, destinationKeyPath)) {
    return updateRecord(record, { ...nextItem, key: destinationKey }, mode);
  }

  const targetPath = record.sourceConfigPath;
  const root = await loadGroupFromFile(targetPath);
  const parentGroup = getMutableParentContainer(root, record.sourceNodePath);
  const itemIndex = record.sourceNodePath.at(-1)!;
  parentGroup.actions.splice(itemIndex, 1);

  const destinationParent = ensureContainerPathByKeys(root, destinationKeyPath.slice(0, -1));
  const normalizedItem = assertCanAddChild(destinationParent.container, {
    ...nextItem,
    key: destinationKey,
  }, {
    parentInsideLayer: destinationParent.insideLayer,
    scopePath: targetPath,
  });

  destinationParent.container.actions.push(normalizedItem);
  await writeGroupToFile(targetPath, root);
  return targetPath;
}

export async function deleteRecord(record: FlatIndexRecord): Promise<string> {
  if (record.inherited) {
    throw new Error("Inherited items cannot be deleted directly. Edit the fallback source instead.");
  }

  const root = await loadGroupFromFile(record.sourceConfigPath);
  const parentGroup = getMutableParentContainer(root, record.sourceNodePath);
  parentGroup.actions.splice(record.sourceNodePath.at(-1)!, 1);
  await writeGroupToFile(record.sourceConfigPath, root);
  return record.sourceConfigPath;
}

export async function insertSiblingAfter(record: FlatIndexRecord, item: ConfigItem): Promise<string> {
  if (record.inherited) {
    const effectiveRoot = await loadGroupFromFile(record.effectiveConfigPath);
    const sourceRoot = await loadGroupFromFile(record.sourceConfigPath);
    const sourceParentTypes = containerTypesAtPath(sourceRoot, record.sourceNodePath.slice(0, -1));
    const group = ensureContainerPathByKeys(
      effectiveRoot,
      record.parentEffectiveKeyPath,
      sourceParentTypes,
    );
    group.container.actions.push(assertCanAddChild(group.container, item, {
      parentInsideLayer: group.insideLayer,
      scopePath: record.effectiveConfigPath,
    }));
    await writeGroupToFile(record.effectiveConfigPath, effectiveRoot);
    return record.effectiveConfigPath;
  }

  const root = await loadGroupFromFile(record.sourceConfigPath);
  const parentContext = getMutableParentContainerContext(root, record.sourceNodePath);
  const index = record.sourceNodePath.at(-1)! + 1;
  parentContext.container.actions.splice(index, 0, assertCanAddChild(parentContext.container, item, {
    parentInsideLayer: parentContext.insideLayer,
    scopePath: record.sourceConfigPath,
  }));
  await writeGroupToFile(record.sourceConfigPath, root);
  return record.sourceConfigPath;
}

export async function appendChildToGroup(record: FlatIndexRecord, item: ConfigItem): Promise<string> {
  if (record.kind !== "group" && record.kind !== "layer") {
    throw new Error("appendChildToGroup requires a container record");
  }

  if (record.inherited) {
    const effectiveRoot = await loadGroupFromFile(record.effectiveConfigPath);
    const sourceRoot = await loadGroupFromFile(record.sourceConfigPath);
    const sourceContainerTypes = containerTypesAtPath(sourceRoot, record.sourceNodePath);
    const localGroup = ensureContainerPathByKeys(
      effectiveRoot,
      record.effectiveKeyPath,
      sourceContainerTypes,
    );
    localGroup.container.actions.push(assertCanAddChild(localGroup.container, item, {
      parentInsideLayer: localGroup.insideLayer,
      scopePath: record.effectiveConfigPath,
    }));
    await writeGroupToFile(record.effectiveConfigPath, effectiveRoot);
    return record.effectiveConfigPath;
  }

  const root = await loadGroupFromFile(record.sourceConfigPath);
  const group = getMutableContainerContextAtPath(root, record.sourceNodePath);
  group.container.actions.push(assertCanAddChild(group.container, item, {
    parentInsideLayer: group.insideLayer,
    scopePath: record.sourceConfigPath,
  }));
  await writeGroupToFile(record.sourceConfigPath, root);
  return record.sourceConfigPath;
}

export async function createItemAtPath(
  configFilePath: string,
  parentKeyPath: string[],
  item: ConfigItem,
): Promise<string> {
  const root = await loadGroupFromFile(configFilePath);
  const group = ensureContainerPathByKeys(root, parentKeyPath);
  const normalizedItem = assertCanAddChild(group.container, item, {
    parentInsideLayer: group.insideLayer,
    scopePath: configFilePath,
  });

  group.container.actions.push(normalizedItem);
  await writeGroupToFile(configFilePath, root);
  return configFilePath;
}

export async function materializeRecordToConfigItem(record: FlatIndexRecord): Promise<ConfigItem> {
  const root = await loadGroupFromFile(record.sourceConfigPath);
  const item = getMutableItemAtPath(root, record.sourceNodePath);
  return cloneConfigItem(item);
}

export function cloneRecordToConfigItem(record: FlatIndexRecord): ConfigItem {
  if (record.kind === "group") {
    return {
      actions: [],
      key: record.key,
      label: record.label,
      stickyMode: record.stickyMode,
      type: "group",
    };
  }

  if (record.kind === "layer") {
    return {
      actions: [],
      iconPath: undefined,
      key: record.key,
      label: record.label,
      tapAction: record.tapAction,
      type: "layer",
    };
  }

  return {
    activates: record.activates,
    aiDescription: record.aiDescription,
    description: record.description,
    key: record.key,
    label: record.label,
    menuFallbackPaths: record.menuFallbackPaths,
    normalModeAfter: record.normalModeAfter,
    stickyMode: record.stickyMode,
    type: record.actionType as ActionNode["type"],
    value: record.rawValue,
  };
}

export async function openConfigLocation(record: FlatIndexRecord): Promise<string> {
  return record.inherited && record.sourceConfigDisplayName === FALLBACK_CONFIG_DISPLAY_NAME
    ? record.sourceConfigPath
    : record.sourceConfigPath;
}

export async function locateNodeInFile(
  filePath: string,
  nodePath: number[],
): Promise<{ column: number; line: number }> {
  const text = await fs.readFile(filePath, "utf8");
  const tree = parseJsonTree(text);
  if (tree.kind !== "object") {
    throw new Error(`Expected root object in ${filePath}`);
  }

  let current = tree;
  for (const index of nodePath) {
    const actionsArray = current.properties?.get("actions");
    if (!actionsArray || actionsArray.kind !== "array") {
      throw new Error(`Unable to locate actions array for path ${nodePath.join(".")} in ${filePath}`);
    }
    const nextNode = actionsArray.elements?.[index];
    if (!nextNode) {
      throw new Error(`Unable to locate node path ${nodePath.join(".")} in ${filePath}`);
    }
    if (nextNode.kind !== "object") {
      throw new Error(`Expected object node at path ${nodePath.join(".")} in ${filePath}`);
    }
    current = nextNode;
  }

  const prefix = text.slice(0, current.offset);
  const lines = prefix.split("\n");
  return {
    column: (lines.at(-1)?.length ?? 0) + 1,
    line: lines.length,
  };
}
