export interface IntelliJActionExplain {
  actionId: string;
  category?: string;
  className?: string;
  description?: string;
  exists?: boolean;
  group?: string;
  name?: string;
  pluginId?: string;
  pluginName?: string;
  presentation?: {
    description?: string;
    text?: string;
  };
  requirements?: {
    needsBuildSystem?: boolean;
    needsEditor?: boolean;
    needsFile?: boolean;
    needsGit?: boolean;
    needsProject?: boolean;
  };
  metadataRoundTripMs?: number;
  shortcuts?: string[];
  smartDelay?: number;
  text?: string;
  [key: string]: unknown;
}

export interface IntelliJActionStats {
  actionId?: string;
  averageTimeMs?: number;
  commonlyChainedWith?: Record<string, number>;
  error?: string;
  executionCount?: number;
  failureCount?: number;
  lastUsed?: string;
  successCount?: number;
}

const INTELLIJ_ACTIONS_BASE_URL = "http://localhost:63343/api/intellij-actions";
const MAX_SEARCH_RESULTS = 80;
let allIntelliJActionIdsPromise: Promise<string[]> | undefined;

async function fetchIntelliJJson<T>(path: string, timeoutMs = 1500): Promise<T> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(`${INTELLIJ_ACTIONS_BASE_URL}${path}`, {
      signal: controller.signal,
    });
    const text = await response.text();

    if (!response.ok) {
      throw new Error(text || `HTTP ${response.status}`);
    }

    return JSON.parse(text) as T;
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new Error("Timed out while querying the IntelliJ custom server.");
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

export async function searchIntelliJActions(query: string): Promise<string[]> {
  const trimmed = query.trim();
  if (!trimmed) {
    return [];
  }

  const searchQueries = intellijActionSearchQueries(trimmed);
  const responses = await Promise.allSettled([
    fetchAllIntelliJActionIds().then((response) => ({
      exactQueryMatch: false,
      response,
      searchQuery: "__all__",
    })),
    ...searchQueries.map(async (searchQuery) => ({
      exactQueryMatch: searchQuery === trimmed,
      response: await fetchIntelliJJson<IntelliJActionsResponse>(`/search?q=${encodeURIComponent(searchQuery)}`),
      searchQuery,
    })),
  ]);

  const actionsById = new Map<string, { actionId: string; exactQueryMatch: boolean }>();
  let firstError: unknown;
  let fulfilledResponseCount = 0;
  for (const result of responses) {
    if (result.status === "rejected") {
      firstError ??= result.reason;
      continue;
    }

    fulfilledResponseCount += 1;
    for (const actionId of actionIdsFromResponse(result.value.response)) {
      if (typeof actionId !== "string" || !actionId.trim()) {
        continue;
      }

      const existing = actionsById.get(actionId);
      actionsById.set(actionId, {
        actionId,
        exactQueryMatch: existing?.exactQueryMatch === true || result.value.exactQueryMatch,
      });
    }
  }

  if (fulfilledResponseCount === 0 && firstError) {
    throw firstError;
  }

  return rankIntelliJActionMatches(trimmed, Array.from(actionsById.values()));
}

async function fetchAllIntelliJActionIds(): Promise<IntelliJActionsResponse> {
  allIntelliJActionIdsPromise ??= fetchIntelliJJson<IntelliJActionsResponse>("/list", 3500)
    .then((response) => actionIdsFromResponse(response))
    .catch((error: unknown) => {
      allIntelliJActionIdsPromise = undefined;
      throw error;
    });

  return { actions: await allIntelliJActionIdsPromise };
}

interface IntelliJActionsResponse {
  actions?: Array<string | { action?: string; actionId?: string; id?: string; name?: string }>;
}

function actionIdsFromResponse(response: IntelliJActionsResponse): string[] {
  return (response.actions ?? [])
    .map((action) => {
      if (typeof action === "string") {
        return action;
      }
      return action.actionId ?? action.id ?? action.action ?? action.name;
    })
    .filter((actionId): actionId is string => typeof actionId === "string" && actionId.trim().length > 0);
}

function rankIntelliJActionMatches(
  query: string,
  actions: Array<{ actionId: string; exactQueryMatch: boolean }>,
): string[] {
  return actions
    .map((result) => ({
      ...result,
      score: scoreIntelliJActionMatch(query, result.actionId),
    }))
    .filter((result) => result.exactQueryMatch || result.score !== undefined)
    .sort((left, right) => {
      const leftScore = left.score ?? 10_000;
      const rightScore = right.score ?? 10_000;
      return leftScore - rightScore || left.actionId.localeCompare(right.actionId);
    })
    .slice(0, MAX_SEARCH_RESULTS)
    .map((result) => result.actionId);
}

export async function explainIntelliJAction(actionId: string): Promise<IntelliJActionExplain> {
  return await fetchIntelliJJson<IntelliJActionExplain>(`/explain?action=${encodeURIComponent(actionId)}`);
}

export async function explainIntelliJActionWithTiming(actionId: string): Promise<IntelliJActionExplain> {
  const start = Date.now();
  const explain = await explainIntelliJAction(actionId);
  return {
    ...explain,
    metadataRoundTripMs: Math.max(0, Date.now() - start),
  };
}

export async function getIntelliJActionStats(actionId: string): Promise<IntelliJActionStats> {
  return await fetchIntelliJJson<IntelliJActionStats>(`/stats?action=${encodeURIComponent(actionId)}`);
}

export function estimateIntelliJChainDelayMs(explain: Pick<IntelliJActionExplain, "category" | "smartDelay">): number {
  if (explain.category === "dialog" || explain.category === "instant") {
    return 0;
  }

  if (explain.category === "async") {
    return 500;
  }

  if (explain.category === "tree-list") {
    return 150;
  }

  if (explain.category === "tool-window") {
    return 100;
  }

  if (explain.category === "quick-ui") {
    return 50;
  }

  return explain.smartDelay && explain.smartDelay > 0 ? explain.smartDelay : 50;
}

export function intellijActionSearchQueries(query: string): string[] {
  const trimmed = query.trim();
  const compact = compactSearchText(trimmed);
  const queries = [trimmed];

  if (compact.length > 2) {
    queries.push(compact.slice(0, 2));
  }

  const words = trimmed.split(/[\s._:-]+/).map((word) => word.trim()).filter(Boolean);
  for (const word of words) {
    if (word.length >= 2) {
      queries.push(word);
    }
  }

  return Array.from(new Set(queries));
}

export function scoreIntelliJActionMatch(query: string, actionId: string): number | undefined {
  const compactQuery = compactSearchText(query);
  if (!compactQuery) {
    return undefined;
  }

  const candidates = [
    actionId,
    intellijActionClassName(actionId),
    humanizeIntelliJActionId(actionId),
    actionId.split(".").join(" "),
  ];

  let bestScore: number | undefined;
  for (const candidate of candidates) {
    const score = scoreCompactMatch(compactQuery, compactSearchText(candidate));
    if (score !== undefined && (bestScore === undefined || score < bestScore)) {
      bestScore = score;
    }
  }

  return bestScore;
}

export function humanizeIntelliJActionId(actionId: string): string {
  const className = intellijActionClassName(actionId).replace(/Action$/i, "");
  return className
    .replace(/[_-]+/g, " ")
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/([A-Z]+)([A-Z][a-z])/g, "$1 $2")
    .replace(/\s+/g, " ")
    .trim() || actionId;
}

export function intellijActionClassName(actionId: string): string {
  return actionId.split(".").filter(Boolean).at(-1) ?? actionId;
}

export function clearIntelliJActionListCacheForTests(): void {
  allIntelliJActionIdsPromise = undefined;
}

function compactSearchText(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]/g, "");
}

function scoreCompactMatch(query: string, candidate: string): number | undefined {
  if (!candidate) {
    return undefined;
  }

  if (candidate === query) {
    return 0;
  }

  const containsIndex = candidate.indexOf(query);
  if (containsIndex >= 0) {
    return 10 + containsIndex + candidate.length - query.length;
  }

  let queryIndex = 0;
  let firstMatch = -1;
  let lastMatch = -1;
  let gaps = 0;

  for (let candidateIndex = 0; candidateIndex < candidate.length && queryIndex < query.length; candidateIndex += 1) {
    if (candidate[candidateIndex] !== query[queryIndex]) {
      continue;
    }

    if (firstMatch < 0) {
      firstMatch = candidateIndex;
    }
    if (lastMatch >= 0) {
      gaps += candidateIndex - lastMatch - 1;
    }
    lastMatch = candidateIndex;
    queryIndex += 1;
  }

  if (queryIndex !== query.length) {
    return undefined;
  }

  return 100 + firstMatch + gaps + candidate.length - query.length;
}
