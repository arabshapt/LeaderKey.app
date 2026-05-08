import fs from "node:fs/promises";
import path from "node:path";

import {
  NORMAL_TAG_CONFIG_PREFIX,
  TAGS_REGISTRY_FILE_NAME,
  TAG_CONFIG_PREFIX,
  defaultConfigDirectory,
} from "./constants.js";
import { humanizeSlug, stringifyConfig } from "./utils.js";
import type { TagAssignmentScope, TagDefinition, TagsRegistry } from "./types.js";

export interface TagsRegistryLoadResult {
  filePath: string;
  mtimeMs?: number;
  registry: TagsRegistry;
}

export interface CreateTagOptions {
  createRegularConfig?: boolean;
  name: string;
}

export interface DeleteTagOptions {
  removeAssignments?: boolean;
}

export interface TagReference {
  bundleId: string;
  index: number;
  scope: TagAssignmentScope;
  tagId: string;
}

function emptyAssignments(): TagsRegistry["assignments"] {
  return {
    app: {},
    normalApp: {},
  };
}

export function emptyTagsRegistry(): TagsRegistry {
  return {
    assignments: emptyAssignments(),
    tags: [],
    version: 1,
  };
}

export function tagsRegistryPath(configDirectory = defaultConfigDirectory()): string {
  return path.join(configDirectory, TAGS_REGISTRY_FILE_NAME);
}

function normalizeTagId(value: unknown): string | undefined {
  if (typeof value !== "string") {
    return undefined;
  }

  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

function normalizeTagIds(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  const seen = new Set<string>();
  const result: string[] = [];
  for (const entry of value) {
    const tagId = normalizeTagId(entry);
    if (!tagId || seen.has(tagId)) {
      continue;
    }
    seen.add(tagId);
    result.push(tagId);
  }
  return result;
}

function normalizeTagDefinitions(value: unknown): TagDefinition[] {
  if (!Array.isArray(value)) {
    return [];
  }

  const seen = new Set<string>();
  const tags: TagDefinition[] = [];
  for (const entry of value) {
    if (!entry || typeof entry !== "object") {
      continue;
    }

    const raw = entry as Partial<TagDefinition>;
    const id = normalizeTagId(raw.id);
    if (!id || seen.has(id)) {
      continue;
    }

    seen.add(id);
    tags.push({
      createdAt: typeof raw.createdAt === "number" ? raw.createdAt : undefined,
      id,
      lastModified: typeof raw.lastModified === "number" ? raw.lastModified : undefined,
      name: typeof raw.name === "string" && raw.name.trim() ? raw.name.trim() : humanizeSlug(id),
    });
  }

  return tags;
}

function normalizeAssignmentMap(value: unknown): Record<string, string[]> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }

  const result: Record<string, string[]> = {};
  for (const [bundleId, tagIds] of Object.entries(value as Record<string, unknown>)) {
    const normalizedBundleId = bundleId.trim();
    if (!normalizedBundleId) {
      continue;
    }

    const normalizedTagIds = normalizeTagIds(tagIds);
    if (normalizedTagIds.length > 0) {
      result[normalizedBundleId] = normalizedTagIds;
    }
  }

  return result;
}

export function normalizeTagsRegistry(value: unknown): TagsRegistry {
  if (!value || typeof value !== "object") {
    return emptyTagsRegistry();
  }

  const raw = value as {
    assignments?: Partial<Record<TagAssignmentScope, unknown>>;
    tags?: unknown;
  };

  return {
    assignments: {
      app: normalizeAssignmentMap(raw.assignments?.app),
      normalApp: normalizeAssignmentMap(raw.assignments?.normalApp),
    },
    tags: normalizeTagDefinitions(raw.tags),
    version: 1,
  };
}

export async function loadTagsRegistry(
  configDirectory = defaultConfigDirectory(),
): Promise<TagsRegistryLoadResult> {
  const filePath = tagsRegistryPath(configDirectory);

  try {
    const [rawText, stat] = await Promise.all([
      fs.readFile(filePath, "utf8"),
      fs.stat(filePath),
    ]);

    return {
      filePath,
      mtimeMs: stat.mtimeMs,
      registry: normalizeTagsRegistry(JSON.parse(rawText)),
    };
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      return {
        filePath,
        registry: emptyTagsRegistry(),
      };
    }
    throw error;
  }
}

export async function writeTagsRegistry(
  configDirectory: string,
  registry: TagsRegistry,
): Promise<void> {
  await fs.mkdir(configDirectory, { recursive: true });
  await fs.writeFile(tagsRegistryPath(configDirectory), stringifyConfig(normalizeTagsRegistry(registry)));
}

export function tagDefinitionById(registry: TagsRegistry): Map<string, TagDefinition> {
  return new Map(registry.tags.map((tag) => [tag.id, tag]));
}

export function tagDisplayName(registry: TagsRegistry, tagId: string): string {
  return tagDefinitionById(registry).get(tagId)?.name ?? humanizeSlug(tagId);
}

export function tagConfigFileName(tagId: string, normalMode = false): string {
  return `${normalMode ? NORMAL_TAG_CONFIG_PREFIX : TAG_CONFIG_PREFIX}${tagId}.json`;
}

export function tagConfigPath(configDirectory: string, tagId: string, normalMode = false): string {
  return path.join(configDirectory, tagConfigFileName(tagId, normalMode));
}

export function assignedTagIds(
  registry: TagsRegistry,
  scope: TagAssignmentScope,
  bundleId: string | undefined,
): string[] {
  if (!bundleId) {
    return [];
  }
  return registry.assignments[scope][bundleId] ?? [];
}

function normalizeTagName(name: string): string {
  const trimmed = name.trim();
  if (!trimmed) {
    throw new Error("Tag name cannot be empty.");
  }
  return trimmed;
}

function metaPathForConfigPath(configPath: string): string {
  return configPath.replace(/\.json$/i, ".meta.json");
}

function normalizeSlug(value: string): string {
  const slug = value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return slug || "tag";
}

export function generateTagId(name: string, registry: TagsRegistry): string {
  const base = normalizeSlug(normalizeTagName(name));
  const existing = new Set(registry.tags.map((tag) => tag.id));
  if (!existing.has(base)) {
    return base;
  }

  for (let suffix = 2; ; suffix += 1) {
    const candidate = `${base}-${suffix}`;
    if (!existing.has(candidate)) {
      return candidate;
    }
  }
}

function tagExists(registry: TagsRegistry, tagId: string): boolean {
  return registry.tags.some((tag) => tag.id === tagId);
}

function assertKnownTagIds(registry: TagsRegistry, tagIds: string[]): void {
  const known = new Set(registry.tags.map((tag) => tag.id));
  const missing = tagIds.find((tagId) => !known.has(tagId));
  if (missing) {
    throw new Error(`Unknown tag '${missing}'.`);
  }
}

function normalizedAssignmentTagIds(tagIds: string[]): string[] {
  const seen = new Set<string>();
  const result: string[] = [];
  for (const rawTagId of tagIds) {
    const tagId = rawTagId.trim();
    if (!tagId || seen.has(tagId)) {
      continue;
    }
    seen.add(tagId);
    result.push(tagId);
  }
  return result;
}

async function removeFileIfPresent(filePath: string): Promise<void> {
  try {
    await fs.unlink(filePath);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== "ENOENT") {
      throw error;
    }
  }
}

export async function ensureTagConfigFile(
  configDirectory: string,
  tagId: string,
  normalMode = false,
): Promise<string> {
  const filePath = tagConfigPath(configDirectory, tagId, normalMode);
  try {
    await fs.access(filePath);
    return filePath;
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== "ENOENT") {
      throw error;
    }
  }

  await fs.mkdir(configDirectory, { recursive: true });
  await fs.writeFile(filePath, stringifyConfig({ actions: [], type: "group" }));
  return filePath;
}

export function tagReferences(registry: TagsRegistry, tagId: string): TagReference[] {
  const references: TagReference[] = [];
  for (const scope of ["app", "normalApp"] as const) {
    for (const [bundleId, tagIds] of Object.entries(registry.assignments[scope])) {
      tagIds.forEach((assignedTagId, index) => {
        if (assignedTagId === tagId) {
          references.push({ bundleId, index, scope, tagId });
        }
      });
    }
  }
  return references.sort((left, right) =>
    left.scope.localeCompare(right.scope) ||
    left.bundleId.localeCompare(right.bundleId) ||
    left.index - right.index
  );
}

export async function createTag(
  configDirectory: string,
  options: CreateTagOptions,
): Promise<TagDefinition> {
  const { registry } = await loadTagsRegistry(configDirectory);
  const name = normalizeTagName(options.name);
  const now = Date.now();
  const tag: TagDefinition = {
    createdAt: now,
    id: generateTagId(name, registry),
    lastModified: now,
    name,
  };

  registry.tags.push(tag);
  await writeTagsRegistry(configDirectory, registry);
  if (options.createRegularConfig !== false) {
    await ensureTagConfigFile(configDirectory, tag.id, false);
  }
  return tag;
}

export async function renameTag(
  configDirectory: string,
  tagId: string,
  name: string,
): Promise<TagDefinition> {
  const { registry } = await loadTagsRegistry(configDirectory);
  const tag = registry.tags.find((candidate) => candidate.id === tagId);
  if (!tag) {
    throw new Error(`Unknown tag '${tagId}'.`);
  }

  tag.name = normalizeTagName(name);
  tag.lastModified = Date.now();
  await writeTagsRegistry(configDirectory, registry);
  return tag;
}

export async function updateTagAssignments(
  configDirectory: string,
  scope: TagAssignmentScope,
  bundleId: string,
  tagIds: string[],
): Promise<TagsRegistry> {
  const normalizedBundleId = bundleId.trim();
  if (!normalizedBundleId) {
    throw new Error("Bundle identifier cannot be empty.");
  }

  const { registry } = await loadTagsRegistry(configDirectory);
  const normalizedTagIds = normalizedAssignmentTagIds(tagIds);
  assertKnownTagIds(registry, normalizedTagIds);

  if (normalizedTagIds.length === 0) {
    delete registry.assignments[scope][normalizedBundleId];
  } else {
    registry.assignments[scope][normalizedBundleId] = normalizedTagIds;
  }

  await writeTagsRegistry(configDirectory, registry);
  return registry;
}

export async function moveAssignedTag(
  configDirectory: string,
  scope: TagAssignmentScope,
  bundleId: string,
  tagId: string,
  direction: -1 | 1,
): Promise<TagsRegistry> {
  const { registry } = await loadTagsRegistry(configDirectory);
  const normalizedBundleId = bundleId.trim();
  const tagIds = registry.assignments[scope][normalizedBundleId] ?? [];
  const index = tagIds.indexOf(tagId);
  if (index < 0) {
    throw new Error(`Tag '${tagId}' is not assigned to '${normalizedBundleId}'.`);
  }

  const nextIndex = index + direction;
  if (nextIndex < 0 || nextIndex >= tagIds.length) {
    return registry;
  }

  const nextTagIds = [...tagIds];
  [nextTagIds[index], nextTagIds[nextIndex]] = [nextTagIds[nextIndex]!, nextTagIds[index]!];
  return updateTagAssignments(configDirectory, scope, normalizedBundleId, nextTagIds);
}

export async function deleteTag(
  configDirectory: string,
  tagId: string,
  options: DeleteTagOptions = {},
): Promise<void> {
  const { registry } = await loadTagsRegistry(configDirectory);
  if (!tagExists(registry, tagId)) {
    throw new Error(`Unknown tag '${tagId}'.`);
  }

  const references = tagReferences(registry, tagId);
  if (references.length > 0 && !options.removeAssignments) {
    throw new Error(`Tag '${tagId}' is assigned to ${references.length} config${references.length === 1 ? "" : "s"}.`);
  }

  registry.tags = registry.tags.filter((tag) => tag.id !== tagId);
  if (options.removeAssignments) {
    for (const scope of ["app", "normalApp"] as const) {
      for (const [bundleId, tagIds] of Object.entries(registry.assignments[scope])) {
        const nextTagIds = tagIds.filter((assignedTagId) => assignedTagId !== tagId);
        if (nextTagIds.length === 0) {
          delete registry.assignments[scope][bundleId];
        } else {
          registry.assignments[scope][bundleId] = nextTagIds;
        }
      }
    }
  }

  await writeTagsRegistry(configDirectory, registry);
  for (const normalMode of [false, true]) {
    const configPath = tagConfigPath(configDirectory, tagId, normalMode);
    await removeFileIfPresent(configPath);
    await removeFileIfPresent(metaPathForConfigPath(configPath));
  }
}
