import fs from "node:fs/promises";

import { FALLBACK_CONFIG_DISPLAY_NAME } from "./constants.js";
import { loadGroupFromFile, writeGroupToFile } from "./discovery.js";
import { generateActionLabel, generateGroupLabel, resolveActionAiDescription, resolveActionDescription } from "./labels.js";
import { cloneConfigItem } from "./utils.js";
import type { ActionNode, ConfigItem, FlatIndexRecord, GroupNode } from "./types.js";

export type MutationMode = "edit-source" | "override-in-effective-config";

interface JsonNode {
  elements?: JsonNode[];
  kind: "array" | "literal" | "object";
  offset: number;
  properties?: Map<string, JsonNode>;
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
  let currentGroup = group;

  for (let index = 0; index < nodePath.length; index += 1) {
    const item = currentGroup.actions[nodePath[index]!];
    if (!item) {
      throw new Error(`Invalid node path: ${nodePath.join(".")}`);
    }

    if (index === nodePath.length - 1) {
      return item;
    }

    if (item.type !== "group") {
      throw new Error(`Path ${nodePath.join(".")} does not point to a group`);
    }

    currentGroup = item;
  }

  return currentGroup;
}

function getMutableGroupAtPath(group: GroupNode, nodePath: number[]): GroupNode {
  if (nodePath.length === 0) {
    return group;
  }

  const item = getMutableItemAtPath(group, nodePath);
  if (item.type !== "group") {
    throw new Error(`Path ${nodePath.join(".")} is not a group`);
  }
  return item;
}

function getMutableParentGroup(group: GroupNode, nodePath: number[]): GroupNode {
  return getMutableGroupAtPath(group, nodePath.slice(0, -1));
}

function nextGroupLabel(group: GroupNode): string | undefined {
  return generateGroupLabel(group);
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

  return {
    ...item,
    aiDescription: resolveActionAiDescription(item),
    description: nextActionDescription(item),
    label: nextActionLabel(item),
  };
}

function ensureGroupPathByKeys(root: GroupNode, keyPath: string[]): GroupNode {
  let current = root;
  for (const key of keyPath) {
    const blockingAction = current.actions.find(
      (item) => item.type !== "group" && (item.key ?? "") === key,
    );
    if (blockingAction) {
      throw new Error(`Cannot create subgroup '${key}' because an action with that key already exists.`);
    }

    const existingGroup = current.actions.find(
      (item): item is GroupNode => item.type === "group" && (item.key ?? "") === key,
    );

    if (existingGroup) {
      current = existingGroup;
      continue;
    }

    const newGroup: GroupNode = {
      actions: [],
      key,
      label: undefined,
      type: "group",
    };
    current.actions.push(newGroup);
    current = newGroup;
  }

  return current;
}

function replaceOrAppendByKey(group: GroupNode, item: ConfigItem): void {
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
    const localParent = ensureGroupPathByKeys(effectiveRoot, record.parentEffectiveKeyPath);
    replaceOrAppendByKey(localParent, normalizeItemBeforeSave(nextItem));
    await writeGroupToFile(record.effectiveConfigPath, effectiveRoot);
    return record.effectiveConfigPath;
  }

  const targetPath = record.sourceConfigPath;
  const root = await loadGroupFromFile(targetPath);
  const parentGroup = getMutableParentGroup(root, record.sourceNodePath);
  const itemIndex = record.sourceNodePath.at(-1)!;
  parentGroup.actions.splice(itemIndex, 1, normalizeItemBeforeSave(nextItem));
  await writeGroupToFile(targetPath, root);
  return targetPath;
}

export async function updateRecordAtPath(
  record: FlatIndexRecord,
  nextItem: ConfigItem,
  destinationKeyPath: string[],
  mode: MutationMode = "edit-source",
): Promise<string> {
  const destinationKey = destinationKeyPath.at(-1)?.trim();
  if (!destinationKey) {
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
  const parentGroup = getMutableParentGroup(root, record.sourceNodePath);
  const itemIndex = record.sourceNodePath.at(-1)!;
  parentGroup.actions.splice(itemIndex, 1);

  const destinationParent = ensureGroupPathByKeys(root, destinationKeyPath.slice(0, -1));
  const normalizedItem = normalizeItemBeforeSave({
    ...nextItem,
    key: destinationKey,
  });
  const existingItem = destinationParent.actions.find((candidate) => (candidate.key ?? "") === destinationKey);
  if (existingItem) {
    throw new Error(`An item with key '${destinationKey}' already exists at this path.`);
  }

  destinationParent.actions.push(normalizedItem);
  await writeGroupToFile(targetPath, root);
  return targetPath;
}

export async function deleteRecord(record: FlatIndexRecord): Promise<string> {
  if (record.inherited) {
    throw new Error("Inherited items cannot be deleted directly. Edit the fallback source instead.");
  }

  const root = await loadGroupFromFile(record.sourceConfigPath);
  const parentGroup = getMutableParentGroup(root, record.sourceNodePath);
  parentGroup.actions.splice(record.sourceNodePath.at(-1)!, 1);
  await writeGroupToFile(record.sourceConfigPath, root);
  return record.sourceConfigPath;
}

export async function insertSiblingAfter(record: FlatIndexRecord, item: ConfigItem): Promise<string> {
  if (record.inherited) {
    const effectiveRoot = await loadGroupFromFile(record.effectiveConfigPath);
    const group = ensureGroupPathByKeys(effectiveRoot, record.parentEffectiveKeyPath);
    group.actions.push(normalizeItemBeforeSave(item));
    await writeGroupToFile(record.effectiveConfigPath, effectiveRoot);
    return record.effectiveConfigPath;
  }

  const root = await loadGroupFromFile(record.sourceConfigPath);
  const parentGroup = getMutableParentGroup(root, record.sourceNodePath);
  const index = record.sourceNodePath.at(-1)! + 1;
  parentGroup.actions.splice(index, 0, normalizeItemBeforeSave(item));
  await writeGroupToFile(record.sourceConfigPath, root);
  return record.sourceConfigPath;
}

export async function appendChildToGroup(record: FlatIndexRecord, item: ConfigItem): Promise<string> {
  if (record.kind !== "group") {
    throw new Error("appendChildToGroup requires a group record");
  }

  if (record.inherited) {
    const effectiveRoot = await loadGroupFromFile(record.effectiveConfigPath);
    const localGroup = ensureGroupPathByKeys(effectiveRoot, record.effectiveKeyPath);
    localGroup.actions.push(normalizeItemBeforeSave(item));
    await writeGroupToFile(record.effectiveConfigPath, effectiveRoot);
    return record.effectiveConfigPath;
  }

  const root = await loadGroupFromFile(record.sourceConfigPath);
  const group = getMutableGroupAtPath(root, record.sourceNodePath);
  group.actions.push(normalizeItemBeforeSave(item));
  await writeGroupToFile(record.sourceConfigPath, root);
  return record.sourceConfigPath;
}

export async function createItemAtPath(
  configFilePath: string,
  parentKeyPath: string[],
  item: ConfigItem,
): Promise<string> {
  const root = await loadGroupFromFile(configFilePath);
  const group = ensureGroupPathByKeys(root, parentKeyPath);
  const normalizedItem = normalizeItemBeforeSave(item);
  const key = normalizedItem.key?.trim();

  if (!key) {
    throw new Error("A key is required.");
  }

  const existingItem = group.actions.find((candidate) => (candidate.key ?? "") === key);
  if (existingItem) {
    throw new Error(`An item with key '${key}' already exists at this path.`);
  }

  group.actions.push({
    ...normalizedItem,
    key,
  });
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

    return {
      activates: record.activates,
      aiDescription: record.aiDescription,
      description: record.description,
      key: record.key,
      label: record.label,
      menuFallbackPaths: record.menuFallbackPaths,
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
