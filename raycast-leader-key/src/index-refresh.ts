import type { CachePayload } from "@leaderkey/config-core";

export function shouldRefreshIndex(
  cached: Pick<CachePayload, "fingerprint"> | undefined,
  fingerprint: string,
  forceRefresh = false,
): boolean {
  return forceRefresh || !cached || cached.fingerprint !== fingerprint;
}
