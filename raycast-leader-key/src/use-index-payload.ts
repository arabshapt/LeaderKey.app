import type { CachePayload } from "@leaderkey/config-core";
import { useEffect, useRef, useState } from "react";

import { getMemoryCachedPayload, readCachedPayload, readCachedPayloadSync, refreshIndex } from "./cache.js";

const AUTO_RECOVERY_RETRY_DELAY_MS = 1200;
const AUTO_RECOVERY_RETRY_LIMIT = 2;

type InitialLoadPhase = "reading-cache" | "rebuilding-index" | "retrying";

interface UseIndexPayloadResult {
  isInitialLoading: boolean;
  isRefreshing: boolean;
  loadError?: string;
  loadingSubtitle: string;
  payload?: CachePayload;
  reload: () => void;
  setPayload: (payload: CachePayload) => void;
}

interface UseIndexPayloadOptions {
  // Targeted Raycast launches need real payload on first render or the list can
  // visually stick in an empty state even though the data arrives immediately after.
  seedFromDisk?: boolean;
  showRefreshingIndicator?: boolean;
}

function initialCachedPayload(configDirectory: string, seedFromDisk: boolean): CachePayload | undefined {
  return getMemoryCachedPayload(configDirectory) ?? (seedFromDisk ? readCachedPayloadSync(configDirectory) : undefined);
}

function loadingSubtitleForPhase(phase: InitialLoadPhase): string {
  switch (phase) {
    case "reading-cache":
      return "Reading cached index";
    case "rebuilding-index":
      return "Rebuilding index automatically";
    case "retrying":
      return "Retrying index rebuild automatically";
  }
}

function errorMessageForLoadFailure(error: unknown): string {
  if (error instanceof Error && error.message.trim()) {
    return error.message;
  }

  return "Automatic index recovery did not succeed.";
}

export function useIndexPayload(
  configDirectory: string,
  options: UseIndexPayloadOptions = {},
): UseIndexPayloadResult {
  const { seedFromDisk = false, showRefreshingIndicator = true } = options;
  const [payload, setPayloadState] = useState<CachePayload | undefined>(() => initialCachedPayload(configDirectory, seedFromDisk));
  const [isInitialLoading, setIsInitialLoading] = useState(() => initialCachedPayload(configDirectory, seedFromDisk) === undefined);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [loadError, setLoadError] = useState<string>();
  const [loadPhase, setLoadPhase] = useState<InitialLoadPhase>("reading-cache");
  const [reloadNonce, setReloadNonce] = useState(0);
  const generationRef = useRef(0);
  const retryAttemptRef = useRef(0);
  const loadKeyRef = useRef<string | undefined>(undefined);

  useEffect(() => {
    const loadKey = `${configDirectory}:${seedFromDisk ? "seed" : "async"}:${showRefreshingIndicator ? "refresh" : "quiet"}`;
    if (loadKeyRef.current !== loadKey) {
      loadKeyRef.current = loadKey;
      retryAttemptRef.current = 0;
    }

    let isMounted = true;
    let retryTimer: ReturnType<typeof setTimeout> | undefined;
    const generation = generationRef.current + 1;
    generationRef.current = generation;

    async function load(): Promise<void> {
      const attempt = retryAttemptRef.current;
      setLoadError(undefined);
      const syncCached = seedFromDisk ? readCachedPayloadSync(configDirectory) : undefined;
      const memoryCached = getMemoryCachedPayload(configDirectory) ?? syncCached;
      if (memoryCached) {
        setPayloadState(memoryCached);
        setIsInitialLoading(false);
        setIsRefreshing(showRefreshingIndicator);
      } else {
        setPayloadState(undefined);
        setIsInitialLoading(true);
        setIsRefreshing(false);
        setLoadPhase(attempt > 0 ? "retrying" : "reading-cache");
      }

      const cached = memoryCached ?? await readCachedPayload(configDirectory);
      if (!isMounted || generationRef.current !== generation) {
        return;
      }

      if (cached) {
        setPayloadState(cached);
        setIsInitialLoading(false);
        setIsRefreshing(showRefreshingIndicator);
      } else {
        setLoadPhase(attempt > 0 ? "retrying" : "rebuilding-index");
      }

      try {
        const result = await refreshIndex(configDirectory, cached);
        if (!isMounted || generationRef.current !== generation) {
          return;
        }

        if (result.refreshed || !cached) {
          setPayloadState(result.payload);
        }

        retryAttemptRef.current = 0;
        setLoadError(undefined);
        setIsInitialLoading(false);
        setIsRefreshing(false);
      } catch (error) {
        if (!isMounted || generationRef.current !== generation) {
          return;
        }

        if (!cached && attempt < AUTO_RECOVERY_RETRY_LIMIT) {
          retryAttemptRef.current = attempt + 1;
          setIsInitialLoading(true);
          setIsRefreshing(false);
          setLoadError(undefined);
          setLoadPhase("retrying");
          retryTimer = setTimeout(() => {
            if (isMounted && generationRef.current === generation) {
              setReloadNonce((value) => value + 1);
            }
          }, AUTO_RECOVERY_RETRY_DELAY_MS * (attempt + 1));
          return;
        }

        if (!cached) {
          setLoadError(errorMessageForLoadFailure(error));
        }

        retryAttemptRef.current = 0;
        setIsInitialLoading(false);
        setIsRefreshing(false);
      }
    }

    void load();
    return () => {
      isMounted = false;
      if (retryTimer) {
        clearTimeout(retryTimer);
      }
    };
  }, [configDirectory, reloadNonce, seedFromDisk, showRefreshingIndicator]);

  function reload(): void {
    retryAttemptRef.current = 0;
    setLoadError(undefined);
    setLoadPhase("reading-cache");
    setIsInitialLoading(true);
    setIsRefreshing(false);
    generationRef.current += 1;
    setReloadNonce((value) => value + 1);
  }

  function setPayload(nextPayload: CachePayload): void {
    retryAttemptRef.current = 0;
    generationRef.current += 1;
    setLoadError(undefined);
    setPayloadState(nextPayload);
    setIsInitialLoading(false);
    setIsRefreshing(false);
  }

  return {
    isInitialLoading,
    isRefreshing,
    loadError,
    loadingSubtitle: loadingSubtitleForPhase(loadPhase),
    payload,
    reload,
    setPayload,
  };
}
