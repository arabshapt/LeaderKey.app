import { retrieveActions } from "./retriever.js";
import { normalizeText, splitTranscript, tokenize } from "./text.js";
import type { ActionCandidate, ActionCatalog, ActionEntry, DispatchPlan } from "./types.js";

export interface AppScopedIntentExpansion {
  candidatesByClause: ActionCandidate[][];
  plan: DispatchPlan;
}

const APP_OPEN_PATTERN = /^(?:please\s+)?(?:(?:open|launch|start|show|activate|switch\s+to)\s+)(.+?)(?:\s+(?:app|application))?$/;
const EXPLICIT_TARGET_PATTERN = /\b(?:in|inside|within|for)\s+(.+?)\s*$/;
const TARGET_REFERENCE_PATTERN = /\b(?:in|inside|within|for)\s+(?:it|there|that\s+app|this\s+app)\b/;
const ACTION_LEADING_WORDS = /^(?:please\s+)?(?:(?:open|show|go\s+to|navigate\s+to|bring\s+up|create|start)\s+)(?:a\s+|an\s+|the\s+)?/;

export function looksLikeAppScopedTranscript(transcript: string): boolean {
  const normalized = normalizeText(transcript);
  const clauses = splitTranscript(normalized);
  return clauses.length > 1 && APP_OPEN_PATTERN.test(clauses[0] ?? "")
    || TARGET_REFERENCE_PATTERN.test(normalized)
    || /\b(?:in|inside|within|for)\s+[a-z0-9][a-z0-9\s-]{1,40}$/.test(normalized);
}

function appNameFromOpenClause(clause: string): string | undefined {
  const match = normalizeText(clause).match(APP_OPEN_PATTERN);
  return match?.[1]?.trim() || undefined;
}

function basename(value: string): string {
  return value
    .split("/")
    .at(-1)
    ?.replace(/\.app$/i, "")
    .trim() ?? "";
}

function allQueryTokensInEntry(query: string, entry: ActionEntry): boolean {
  const queryTokens = tokenize(query).filter((token) => !["app", "application"].includes(token));
  if (queryTokens.length === 0) {
    return false;
  }
  const entryTokens = new Set(tokenize([
    entry.label,
    entry.valuePreview,
    entry.value,
    basename(entry.value),
  ].join(" ")));
  return queryTokens.every((token) => entryTokens.has(token));
}

function applicationOnlyCatalog(catalog: ActionCatalog): ActionCatalog {
  return {
    ...catalog,
    entries: catalog.entries.filter((entry) => entry.type === "application"),
  };
}

function appCandidateCatalog(baseCatalog: ActionCatalog, allCatalog: ActionCatalog): ActionCatalog {
  const entriesById = new Map<string, ActionEntry>();
  for (const entry of [...baseCatalog.entries, ...allCatalog.entries]) {
    if (entry.type === "application") {
      entriesById.set(entry.id, entry);
    }
  }
  return {
    ...baseCatalog,
    entries: [...entriesById.values()],
  };
}

function retrieveAppCandidates(
  baseCatalog: ActionCatalog,
  allCatalog: ActionCatalog,
  appName: string,
): ActionCandidate[] {
  const baseCandidates = retrieveActions(applicationOnlyCatalog(baseCatalog), appName, 12)
    .filter((candidate) => candidate.action.type === "application");
  const sourceCandidates = baseCandidates.length > 0
    ? baseCandidates
    : retrieveActions(appCandidateCatalog(baseCatalog, allCatalog), appName, 12)
      .filter((candidate) => candidate.action.type === "application");

  return sourceCandidates
    .map((candidate) => ({
      ...candidate,
      confidence: allQueryTokensInEntry(appName, candidate.action)
        ? Math.max(candidate.confidence, 0.94)
        : candidate.confidence,
      reason: `${candidate.reason}:app_scope_open`,
    }))
    .sort((left, right) =>
      right.confidence - left.confidence
      || left.action.keys.length - right.action.keys.length
      || left.action.id.localeCompare(right.action.id))
    .slice(0, 6);
}

function targetBundleScore(appName: string, appAction: ActionEntry, entry: ActionEntry): number {
  const haystack = normalizeText([
    entry.bundleId,
    entry.effectiveConfigDisplayName,
    entry.effectiveConfigPath,
  ].join(" "));
  const compactHaystack = haystack.replace(/[^a-z0-9]+/g, "");
  const needles = [
    appName,
    appAction.label,
    appAction.valuePreview,
    basename(appAction.value),
  ].flatMap(tokenize).filter((token) => token.length > 2);
  const uniqueNeedles = [...new Set(needles)];
  let score = 0;
  for (const token of uniqueNeedles) {
    if (haystack.includes(token) || compactHaystack.includes(token)) {
      score += 1;
    }
  }
  if (entry.effectiveScope === "app") {
    score += 0.25;
  }
  return score;
}

function resolveTargetBundleId(
  allCatalog: ActionCatalog,
  appName: string,
  appAction: ActionEntry,
): string | undefined {
  const scores = new Map<string, number>();
  for (const entry of allCatalog.entries) {
    if (!entry.bundleId || !["app", "normalApp"].includes(entry.effectiveScope)) {
      continue;
    }
    scores.set(
      entry.bundleId,
      Math.max(scores.get(entry.bundleId) ?? 0, targetBundleScore(appName, appAction, entry)),
    );
  }

  return [...scores.entries()]
    .filter(([, score]) => score > 0)
    .sort((left, right) => right[1] - left[1] || left[0].localeCompare(right[0]))
    .at(0)?.[0];
}

function targetCatalogForBundle(allCatalog: ActionCatalog, bundleId: string): ActionCatalog {
  return {
    ...allCatalog,
    entries: allCatalog.entries.filter((entry) =>
      entry.bundleId === bundleId && ["app", "normalApp"].includes(entry.effectiveScope)),
  };
}

function cleanTargetActionClause(clause: string, targetAppName?: string): string {
  let value = normalizeText(clause)
    .replace(TARGET_REFERENCE_PATTERN, "")
    .replace(/\b(?:in|inside|within|for)\s+.+?$/, "")
    .replace(ACTION_LEADING_WORDS, "")
    .replace(/\s+/g, " ")
    .trim();

  if (targetAppName) {
    const targetTokens = tokenize(targetAppName).join("\\s+");
    value = value.replace(new RegExp(`\\b${targetTokens}\\b`, "g"), "").replace(/\s+/g, " ").trim();
  }
  return value || normalizeText(clause);
}

function explicitTargetFromClause(clause: string): { actionClause: string; appName: string } | undefined {
  const normalized = normalizeText(clause);
  const match = normalized.match(EXPLICIT_TARGET_PATTERN);
  if (!match?.[1]) {
    return undefined;
  }
  const appName = match[1].trim();
  if (["it", "there", "that app", "this app"].includes(appName)) {
    return undefined;
  }
  return {
    actionClause: normalized.slice(0, match.index).trim(),
    appName,
  };
}

function retrieveTargetActionCandidates(
  targetCatalog: ActionCatalog,
  clause: string,
): ActionCandidate[] {
  return retrieveActions(targetCatalog, clause, 12)
    .filter((candidate) => candidate.action.type !== "application")
    .map((candidate) => ({
      ...candidate,
      reason: `${candidate.reason}:app_scope_target`,
    }));
}

function unresolvedPlan(
  candidatesByClause: ActionCandidate[][],
  unresolved: string[],
): AppScopedIntentExpansion {
  return {
    candidatesByClause,
    plan: {
      chain: [],
      mode: "fast_match",
      needs_confirmation: false,
      overall_confidence: 0,
      reason: "app scoped intent requires planner",
      unresolved,
    },
  };
}

export function expandAppScopedIntent(
  baseCatalog: ActionCatalog,
  allCatalog: ActionCatalog,
  transcript: string,
): AppScopedIntentExpansion | undefined {
  if (!looksLikeAppScopedTranscript(transcript)) {
    return undefined;
  }

  const clauses = splitTranscript(transcript);
  const candidatesByClause: ActionCandidate[][] = [];
  const chosen: ActionCandidate[] = [];
  const unresolved: string[] = [];
  let targetCatalog: ActionCatalog | undefined;
  let targetAppName: string | undefined;

  for (const [index, clause] of clauses.entries()) {
    const explicitTarget = explicitTargetFromClause(clause);
    const appName = (index === 0 ? appNameFromOpenClause(clause) : undefined) ?? explicitTarget?.appName;

    if (appName) {
      const appCandidates = retrieveAppCandidates(baseCatalog, allCatalog, appName);
      candidatesByClause.push(appCandidates);
      const appCandidate = appCandidates[0];
      if (!appCandidate || appCandidate.confidence < 0.85) {
        unresolved.push(appName);
        targetCatalog = undefined;
        continue;
      }

      chosen.push(appCandidate);
      targetAppName = appName;
      const bundleId = resolveTargetBundleId(allCatalog, appName, appCandidate.action);
      targetCatalog = bundleId ? targetCatalogForBundle(allCatalog, bundleId) : undefined;

      if (explicitTarget?.actionClause) {
        const actionClause = cleanTargetActionClause(explicitTarget.actionClause, targetAppName);
        const actionCandidates = targetCatalog ? retrieveTargetActionCandidates(targetCatalog, actionClause) : [];
        candidatesByClause.push(actionCandidates);
        const actionCandidate = actionCandidates[0];
        if (!actionCandidate || actionCandidate.confidence < 0.82) {
          unresolved.push(actionClause);
        } else {
          chosen.push(actionCandidate);
        }
      }
      continue;
    }

    if (!targetCatalog) {
      return undefined;
    }

    const actionClause = cleanTargetActionClause(clause, targetAppName);
    const actionCandidates = retrieveTargetActionCandidates(targetCatalog, actionClause);
    candidatesByClause.push(actionCandidates);
    const actionCandidate = actionCandidates[0];
    if (!actionCandidate || actionCandidate.confidence < 0.82) {
      unresolved.push(actionClause);
      continue;
    }
    chosen.push(actionCandidate);
  }

  if (chosen.length < 2 || unresolved.length > 0) {
    return unresolvedPlan(candidatesByClause, unresolved);
  }

  const overall = Math.min(...chosen.map((candidate) => candidate.confidence));
  return {
    candidatesByClause,
    plan: {
      chain: chosen.map((candidate) => ({
        action_id: candidate.action.id,
        confidence: candidate.confidence,
      })),
      mode: "fast_match",
      needs_confirmation: chosen.some((candidate) => candidate.action.requiresConfirmation),
      overall_confidence: overall,
      reason: "app_scoped_chain",
    },
  };
}
