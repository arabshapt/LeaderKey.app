import { environment } from "@raycast/api";
import {
  buildCachePayload,
  configFingerprint,
  discoverLiveConfigs,
  type CachePayload,
} from "@leaderkey/config-core";
import fsSync from "node:fs";
import fs from "node:fs/promises";
import path from "node:path";

import { shouldRefreshIndex } from "./index-refresh.js";

const CACHE_FILE_NAME = "leaderkey-index-cache.json";
const memoryCachedPayloads = new Map<string, CachePayload>();

function cacheFilePath(): string {
  return path.join(environment.supportPath, CACHE_FILE_NAME);
}

async function ensureSupportDirectory(): Promise<void> {
  await fs.mkdir(environment.supportPath, { recursive: true });
}

export function getMemoryCachedPayload(configDirectory: string): CachePayload | undefined {
  return memoryCachedPayloads.get(configDirectory);
}

function setMemoryCachedPayload(payload: CachePayload): void {
  memoryCachedPayloads.set(payload.configDirectory, payload);
}

export function readCachedPayloadSync(configDirectory: string): CachePayload | undefined {
  try {
    const rawText = fsSync.readFileSync(cacheFilePath(), "utf8");
    const payload = JSON.parse(rawText) as CachePayload;
    if (payload.configDirectory !== configDirectory) {
      return undefined;
    }
    setMemoryCachedPayload(payload);
    return payload;
  } catch {
    return undefined;
  }
}

export async function readCachedPayload(configDirectory: string): Promise<CachePayload | undefined> {
  try {
    const rawText = await fs.readFile(cacheFilePath(), "utf8");
    const payload = JSON.parse(rawText) as CachePayload;
    if (payload.configDirectory !== configDirectory) {
      return undefined;
    }
    setMemoryCachedPayload(payload);
    return payload;
  } catch {
    return undefined;
  }
}

export async function writeCachedPayload(payload: CachePayload): Promise<void> {
  await ensureSupportDirectory();
  await fs.writeFile(cacheFilePath(), `${JSON.stringify(payload, null, 2)}\n`);
  setMemoryCachedPayload(payload);
}

export async function refreshIndex(
  configDirectory: string,
  cached?: CachePayload,
  forceRefresh = false,
): Promise<{ payload: CachePayload; refreshed: boolean }> {
  const configs = await discoverLiveConfigs(configDirectory);
  const fingerprint = configFingerprint(configs);
  const needsRefresh = shouldRefreshIndex(cached, fingerprint, forceRefresh);

  if (!needsRefresh && cached) {
    return { payload: cached, refreshed: false };
  }

  const fresh = await buildCachePayload(configDirectory);
  await writeCachedPayload(fresh);
  return { payload: fresh, refreshed: true };
}

export async function loadIndex(
  configDirectory: string,
  forceRefresh = false,
): Promise<{ cached?: CachePayload; fresh?: CachePayload; needsRefresh: boolean }> {
  const cached = forceRefresh ? undefined : await readCachedPayload(configDirectory);
  const result = await refreshIndex(configDirectory, cached, forceRefresh);

  if (!result.refreshed) {
    return { cached: result.payload, needsRefresh: false };
  }

  return { cached, fresh: result.payload, needsRefresh: true };
}

export async function rebuildIndex(configDirectory: string): Promise<CachePayload> {
  const payload = await buildCachePayload(configDirectory);
  await writeCachedPayload(payload);
  return payload;
}
