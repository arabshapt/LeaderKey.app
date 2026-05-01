import { retrieveActions } from "./retriever.js";
import { normalizeText, tokenize } from "./text.js";
import type { ActionCandidate, ActionCatalog, DispatchContext, DispatchPlan, RecentVoiceCommandContext } from "./types.js";

export interface LayoutIntentExpansion {
  candidatesByClause: ActionCandidate[][];
  plan: DispatchPlan;
}

interface SideBySideIntent {
  leftApp: string;
  rightApp: string;
  reason: "layout_side_by_side" | "layout_swap_side_by_side";
}

const LEADING_COMMAND_WORDS = /^(?:please\s+)?(?:(?:i\s+want\s+you\s+to|can\s+you|could\s+you)\s+)?(?:open|launch|start|show|tile|arrange|put|place|swap|switch)\s+/;
const APP_TRAILING_WORDS = /\s+(?:app|application|window)$/;
const SIDE_BY_SIDE_PATTERN = /\b(?:side[-\s]?by[-\s]?side|split\s+screen|next\s+to\s+each\s+other|beside\s+each\s+other)\b/;
const POSITION_WORDS = /\b(?:(?:with\s+)?(?:their\s+)?(?:window\s+)?positions?|(?:with\s+)?(?:their\s+)?position|windows?)\b/g;

function cleanAppName(value: string): string {
  return normalizeText(value)
    .replace(LEADING_COMMAND_WORDS, "")
    .replace(POSITION_WORDS, "")
    .replace(APP_TRAILING_WORDS, "")
    .replace(/\b(?:on\s+the\s+)?(?:left|right)\b/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function splitTwoApps(body: string, separator: RegExp): Pick<SideBySideIntent, "leftApp" | "rightApp"> | undefined {
  const parts = body.split(separator).map(cleanAppName).filter(Boolean);
  if (parts.length < 2) {
    return undefined;
  }
  return { leftApp: parts[0]!, rightApp: parts.slice(1).join(" and ") };
}

function inferPreviousSideBySideApps(context: DispatchContext | undefined): Pick<SideBySideIntent, "leftApp" | "rightApp"> | undefined {
  const recent = [...(context?.recentCommands ?? [])].reverse();
  for (const command of recent) {
    const inferred = inferSideBySideApps(command);
    if (inferred) {
      return inferred;
    }
  }
  return undefined;
}

function inferSideBySideApps(command: RecentVoiceCommandContext): Pick<SideBySideIntent, "leftApp" | "rightApp"> | undefined {
  const types = command.types ?? [];
  const labels = command.labels;
  const leftIndex = labels.findIndex((label) => /\bleft\b.*\bhalf\b|\bleft\s+half\b/i.test(label));
  const rightIndex = labels.findIndex((label) => /\bright\b.*\bhalf\b|\bright\s+half\b/i.test(label));
  if (leftIndex < 1 || rightIndex < 1) {
    return undefined;
  }

  let leftApp = labels[leftIndex - 1];
  for (let index = leftIndex - 1; index >= 0; index -= 1) {
    if (types[index] === "application") {
      leftApp = labels[index];
      break;
    }
  }

  let rightApp = labels[rightIndex - 1];
  for (let index = rightIndex - 1; index > leftIndex; index -= 1) {
    if (types[index] === "application") {
      rightApp = labels[index];
      break;
    }
  }

  return leftApp && rightApp
    ? { leftApp: cleanAppName(leftApp), rightApp: cleanAppName(rightApp) }
    : undefined;
}

function parseSwapIntent(normalized: string, context: DispatchContext | undefined): SideBySideIntent | undefined {
  if (!/^(?:swap|switch)\b/.test(normalized)) {
    return undefined;
  }

  const body = normalized
    .replace(SIDE_BY_SIDE_PATTERN, " ")
    .replace(/^(?:swap|switch)\s+(?:(?:the\s+)?(?:window\s+)?positions?\s+of\s+)?/, "")
    .replace(POSITION_WORDS, " ")
    .replace(/\s+/g, " ")
    .trim();
  const apps = splitTwoApps(body, /\s+(?:and|with)\s+/);
  if (apps) {
    return { ...apps, reason: "layout_swap_side_by_side" };
  }

  const previous = inferPreviousSideBySideApps(context);
  return previous
    ? {
        leftApp: previous.rightApp,
        rightApp: previous.leftApp,
        reason: "layout_swap_side_by_side",
      }
    : undefined;
}

function parseSideBySideIntent(transcript: string, context: DispatchContext | undefined): SideBySideIntent | undefined {
  const normalized = normalizeText(transcript).replace(/side-by-side/g, "side by side");
  const swapIntent = parseSwapIntent(normalized, context);
  if (swapIntent) {
    return swapIntent;
  }

  const explicitSides = normalized
    .replace(LEADING_COMMAND_WORDS, "")
    .match(/^(.+?)\s+(?:on\s+the\s+)?left\s+(?:and|,)\s+(.+?)\s+(?:on\s+the\s+)?right$/);
  if (explicitSides?.[1] && explicitSides[2]) {
    const leftApp = cleanAppName(explicitSides[1]);
    const rightApp = cleanAppName(explicitSides[2]);
    return leftApp && rightApp ? { leftApp, rightApp, reason: "layout_side_by_side" } : undefined;
  }

  const nextTo = normalized
    .replace(LEADING_COMMAND_WORDS, "")
    .match(/^(.+?)\s+(?:next\s+to|beside)\s+(.+)$/);
  if (nextTo?.[1] && nextTo[2]) {
    const leftApp = cleanAppName(nextTo[1]);
    const rightApp = cleanAppName(nextTo[2]);
    return leftApp && rightApp ? { leftApp, rightApp, reason: "layout_side_by_side" } : undefined;
  }

  if (!SIDE_BY_SIDE_PATTERN.test(normalized)) {
    return undefined;
  }

  const body = normalized
    .replace(SIDE_BY_SIDE_PATTERN, " ")
    .replace(LEADING_COMMAND_WORDS, "")
    .replace(/\s+/g, " ")
    .trim();
  const apps = splitTwoApps(body, /\s+and\s+/);
  return apps ? { ...apps, reason: "layout_side_by_side" } : undefined;
}

function tokenSet(value: string): Set<string> {
  return new Set(tokenize(value));
}

function allQueryTokensInLabel(query: string, candidate: ActionCandidate): boolean {
  const queryTokens = tokenize(query).filter((token) => !["app", "application"].includes(token));
  if (queryTokens.length === 0) {
    return false;
  }
  const labels = tokenSet([
    candidate.action.label,
    candidate.action.valuePreview,
    candidate.action.value,
  ].join(" "));
  return queryTokens.every((token) => labels.has(token));
}

function preferShortestPath(left: ActionCandidate, right: ActionCandidate): number {
  return right.confidence - left.confidence
    || left.action.keys.length - right.action.keys.length
    || left.action.id.localeCompare(right.action.id);
}

function retrieveAppCandidates(catalog: ActionCatalog, appName: string): ActionCandidate[] {
  return retrieveActions(catalog, appName, 24)
    .filter((candidate) => candidate.action.type === "application")
    .map((candidate) => ({
      ...candidate,
      confidence: allQueryTokensInLabel(appName, candidate)
        ? Math.max(candidate.confidence, 0.95)
        : candidate.confidence,
      reason: `${candidate.reason}:layout_app`,
    }))
    .sort(preferShortestPath)
    .slice(0, 6);
}

function isWindowHalfCandidate(candidate: ActionCandidate, side: "left" | "right"): boolean {
  const label = normalizeText(candidate.action.label);
  const value = normalizeText(candidate.action.value);
  return candidate.action.type === "url"
    && (
      value.includes(`window-management/${side}-half`)
      || (label.includes(side) && label.includes("half"))
    );
}

function retrieveWindowHalfCandidates(catalog: ActionCatalog, side: "left" | "right"): ActionCandidate[] {
  return retrieveActions(catalog, `${side} half window`, 24)
    .filter((candidate) => isWindowHalfCandidate(candidate, side))
    .map((candidate) => ({
      ...candidate,
      confidence: Math.max(candidate.confidence, 0.95),
      reason: `${candidate.reason}:layout_${side}_half`,
    }))
    .sort(preferShortestPath)
    .slice(0, 4);
}

export function expandLayoutIntent(
  catalog: ActionCatalog,
  transcript: string,
  context?: DispatchContext,
): LayoutIntentExpansion | undefined {
  const intent = parseSideBySideIntent(transcript, context);
  if (!intent) {
    return undefined;
  }

  const candidatesByClause = [
    retrieveAppCandidates(catalog, intent.leftApp),
    retrieveWindowHalfCandidates(catalog, "left"),
    retrieveAppCandidates(catalog, intent.rightApp),
    retrieveWindowHalfCandidates(catalog, "right"),
  ];
  const chosen = candidatesByClause.map((candidates) => candidates[0]);
  const unresolved = [
    chosen[0] ? undefined : intent.leftApp,
    chosen[1] ? undefined : "left half",
    chosen[2] ? undefined : intent.rightApp,
    chosen[3] ? undefined : "right half",
  ].filter((value): value is string => Boolean(value));

  if (unresolved.length > 0 || chosen.some((candidate) => !candidate || candidate.confidence < 0.85)) {
    return {
      candidatesByClause,
      plan: {
        chain: [],
        mode: "fast_match",
        needs_confirmation: false,
        overall_confidence: 0,
        reason: "layout intent requires planner",
        unresolved,
      },
    };
  }

  const concrete = chosen as [ActionCandidate, ActionCandidate, ActionCandidate, ActionCandidate];
  const overall = Math.min(...concrete.map((candidate) => candidate.confidence));
  return {
    candidatesByClause,
    plan: {
      chain: concrete.map((candidate) => ({
        action_id: candidate.action.id,
        confidence: candidate.confidence,
      })),
      mode: "fast_match",
      needs_confirmation: concrete.some((candidate) => candidate.action.requiresConfirmation),
      overall_confidence: overall,
      reason: intent.reason,
    },
  };
}
