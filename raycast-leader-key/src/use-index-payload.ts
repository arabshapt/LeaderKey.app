import type { CachePayload } from "@leaderkey/config-core";
import { useEffect, useRef, useState } from "react";

import { getMemoryCachedPayload, readCachedPayload, readCachedPayloadSync, refreshIndex } from "./cache.js";

interface UseIndexPayloadResult {
  isInitialLoading: boolean;
  isRefreshing: boolean;
  payload?: CachePayload;
  setPayload: (payload: CachePayload) => void;
}

interface UseIndexPayloadOptions {
  seedFromDisk?: boolean;
}

function initialCachedPayload(configDirectory: string, seedFromDisk: boolean): CachePayload | undefined {
  return getMemoryCachedPayload(configDirectory) ?? (seedFromDisk ? readCachedPayloadSync(configDirectory) : undefined);
}

export function useIndexPayload(
  configDirectory: string,
  options: UseIndexPayloadOptions = {},
): UseIndexPayloadResult {
  const { seedFromDisk = false } = options;
  const [payload, setPayloadState] = useState<CachePayload | undefined>(() => initialCachedPayload(configDirectory, seedFromDisk));
  const [isInitialLoading, setIsInitialLoading] = useState(() => initialCachedPayload(configDirectory, seedFromDisk) === undefined);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const generationRef = useRef(0);

  useEffect(() => {
    let isMounted = true;
    const generation = generationRef.current + 1;
    generationRef.current = generation;

    async function load(): Promise<void> {
      const syncCached = seedFromDisk ? readCachedPayloadSync(configDirectory) : undefined;
      const memoryCached = getMemoryCachedPayload(configDirectory) ?? syncCached;
      if (memoryCached) {
        setPayloadState(memoryCached);
        setIsInitialLoading(false);
        setIsRefreshing(true);
      } else {
        setPayloadState(undefined);
        setIsInitialLoading(true);
        setIsRefreshing(false);
      }

      const cached = memoryCached ?? await readCachedPayload(configDirectory);
      if (!isMounted || generationRef.current !== generation) {
        return;
      }

      if (cached) {
        setPayloadState(cached);
        setIsInitialLoading(false);
        setIsRefreshing(true);
      }

      try {
        const result = await refreshIndex(configDirectory, cached);
        if (!isMounted || generationRef.current !== generation) {
          return;
        }

        if (result.refreshed || !cached) {
          setPayloadState(result.payload);
        }

        setIsInitialLoading(false);
        setIsRefreshing(false);
      } catch {
        if (!isMounted || generationRef.current !== generation) {
          return;
        }
        setIsInitialLoading(false);
        setIsRefreshing(false);
      }
    }

    void load();
    return () => {
      isMounted = false;
    };
  }, [configDirectory, seedFromDisk]);

  function setPayload(nextPayload: CachePayload): void {
    generationRef.current += 1;
    setPayloadState(nextPayload);
    setIsInitialLoading(false);
    setIsRefreshing(false);
  }

  return {
    isInitialLoading,
    isRefreshing,
    payload,
    setPayload,
  };
}
