import { environment } from "@raycast/api";
import {
  buildCachePayload,
  configFingerprint,
  discoverLiveConfigs,
  type CachePayload,
} from "@leaderkey/config-core";
import fs from "node:fs/promises";
import path from "node:path";

const CACHE_FILE_NAME = "leaderkey-index-cache.json";

function cacheFilePath(): string {
  return path.join(environment.supportPath, CACHE_FILE_NAME);
}

async function ensureSupportDirectory(): Promise<void> {
  await fs.mkdir(environment.supportPath, { recursive: true });
}

export async function readCachedPayload(configDirectory: string): Promise<CachePayload | undefined> {
  try {
    const rawText = await fs.readFile(cacheFilePath(), "utf8");
    const payload = JSON.parse(rawText) as CachePayload;
    if (payload.configDirectory !== configDirectory) {
      return undefined;
    }
    return payload;
  } catch {
    return undefined;
  }
}

export async function writeCachedPayload(payload: CachePayload): Promise<void> {
  await ensureSupportDirectory();
  await fs.writeFile(cacheFilePath(), `${JSON.stringify(payload, null, 2)}\n`);
}

export async function loadIndex(
  configDirectory: string,
  forceRefresh = false,
): Promise<{ cached?: CachePayload; fresh?: CachePayload; needsRefresh: boolean }> {
  const cached = forceRefresh ? undefined : await readCachedPayload(configDirectory);
  const configs = await discoverLiveConfigs(configDirectory);
  const fingerprint = configFingerprint(configs);
  const needsRefresh = forceRefresh || !cached || cached.fingerprint !== fingerprint;

  if (!needsRefresh) {
    return { cached, needsRefresh: false };
  }

  const fresh = await buildCachePayload(configDirectory);
  await writeCachedPayload(fresh);
  return { cached, fresh, needsRefresh: true };
}

export async function rebuildIndex(configDirectory: string): Promise<CachePayload> {
  const payload = await buildCachePayload(configDirectory);
  await writeCachedPayload(payload);
  return payload;
}

