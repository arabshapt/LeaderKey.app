import fs from "node:fs/promises";
import path from "node:path";

import { APP_CONFIG_PREFIX, META_FILE_SUFFIX, NORMAL_APP_CONFIG_PREFIX } from "./constants.js";
import { loadGroupFromFile, saveMetadata, writeGroupToFile } from "./discovery.js";
import type { ConfigSummary, GroupNode } from "./types.js";

export const EMPTY_APP_CONFIG_TEMPLATE = "EMPTY_TEMPLATE";

export type AppConfigTemplateSource =
  | { kind: "empty" }
  | { filePath: string; kind: "config" };

export interface CreateAppConfigOptions {
  bundleId: string;
  customName?: string;
  normalMode?: boolean;
  template?: AppConfigTemplateSource;
}

function buildAppConfigFilePath(configDirectory: string, bundleId: string, normalMode = false): string {
  return path.join(configDirectory, `${normalMode ? NORMAL_APP_CONFIG_PREFIX : APP_CONFIG_PREFIX}${bundleId}.json`);
}

function buildMetaPath(filePath: string): string {
  return filePath.replace(/\.json$/i, `${META_FILE_SUFFIX}`);
}

function emptyRoot(): GroupNode {
  return { actions: [], type: "group" };
}

export async function createAppConfig(
  configDirectory: string,
  options: CreateAppConfigOptions,
): Promise<ConfigSummary> {
  const bundleId = options.bundleId.trim();
  if (!bundleId) {
    throw new Error("Bundle identifier cannot be empty.");
  }

  const normalMode = options.normalMode ?? false;
  const filePath = buildAppConfigFilePath(configDirectory, bundleId, normalMode);
  const template = options.template ?? { kind: "empty" };

  const sourceGroup = template.kind === "config"
    ? await loadGroupFromFile(template.filePath)
    : emptyRoot();

  try {
    await fs.access(filePath);
    throw new Error(`A configuration for '${bundleId}' already exists.`);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== "ENOENT") {
      if (error instanceof Error && error.message.startsWith("A configuration for")) {
        throw error;
      }
    }
  }

  await writeGroupToFile(filePath, sourceGroup);

  const customName = options.customName?.trim();
  if (customName) {
    await saveMetadata(buildMetaPath(filePath), { customName });
  }

  return {
    bundleId,
    displayName: customName || (normalMode ? `Normal: ${bundleId}` : `App: ${bundleId}`),
    filePath,
    scope: normalMode ? "normalApp" : "app",
  };
}
