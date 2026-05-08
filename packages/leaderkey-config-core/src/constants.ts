import os from "node:os";
import path from "node:path";

export const GLOBAL_CONFIG_DISPLAY_NAME = "Global";
export const FALLBACK_CONFIG_DISPLAY_NAME = "Fallback App Config";
export const NORMAL_FALLBACK_CONFIG_DISPLAY_NAME = "Normal Fallback Config";
export const TAG_CONFIG_DISPLAY_PREFIX = "Tag: ";
export const NORMAL_TAG_CONFIG_DISPLAY_PREFIX = "Normal Tag: ";
export const GLOBAL_CONFIG_FILE_NAME = "global-config.json";
export const FALLBACK_CONFIG_FILE_NAME = "app-fallback-config.json";
export const NORMAL_FALLBACK_CONFIG_FILE_NAME = "normal-fallback-config.json";
export const TAGS_REGISTRY_FILE_NAME = "tags-registry.json";
export const APP_CONFIG_PREFIX = "app.";
export const NORMAL_APP_CONFIG_PREFIX = "normal-app.";
export const TAG_CONFIG_PREFIX = "tag.";
export const NORMAL_TAG_CONFIG_PREFIX = "normal-tag.";
export const META_FILE_SUFFIX = ".meta.json";
export const CACHE_VERSION = 2;

export function defaultConfigDirectory(): string {
  return path.join(os.homedir(), "Library", "Application Support", "Leader Key");
}
