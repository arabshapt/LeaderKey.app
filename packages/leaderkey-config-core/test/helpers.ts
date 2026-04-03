import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

import type { ConfigMetadata, GroupNode } from "../src/index.js";

export async function createTempConfigDirectory(): Promise<string> {
  return fs.mkdtemp(path.join(os.tmpdir(), "leaderkey-config-core-"));
}

export async function writeConfigFile(
  directory: string,
  fileName: string,
  group: GroupNode,
  metadata?: ConfigMetadata,
): Promise<string> {
  const filePath = path.join(directory, fileName);
  await fs.writeFile(filePath, `${JSON.stringify(group, null, 2)}\n`);
  if (metadata) {
    const metaPath = filePath.replace(/\.json$/i, ".meta.json");
    await fs.writeFile(metaPath, `${JSON.stringify(metadata, null, 2)}\n`);
  }
  return filePath;
}

export async function readJsonFile<T>(filePath: string): Promise<T> {
  const rawText = await fs.readFile(filePath, "utf8");
  return JSON.parse(rawText) as T;
}

export function expectRecord<T>(value: T | undefined, message: string): T {
  assert.ok(value, message);
  return value;
}

