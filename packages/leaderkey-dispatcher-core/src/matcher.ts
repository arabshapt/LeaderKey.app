import type { ActionCandidate, ActionCatalog, ActionEntry, DispatchPlan } from "./types.js";
import { retrieveActions } from "./retriever.js";
import { normalizeText, splitTranscript, tokenize } from "./text.js";

interface AliasSpec {
  aliases: string[];
  reason: string;
  predicate: (entry: ActionEntry) => boolean;
  tieBreaker?: (entry: ActionEntry) => number;
}

function compact(value: string): string {
  return normalizeText(value).replace(/[^a-z0-9]+/g, "");
}

function shortcutValue(entry: ActionEntry): string {
  return compact(entry.value)
    .replace(/^command/, "c")
    .replace(/^cmd/, "c");
}

function hasAllWords(value: string, words: string[]): boolean {
  const tokens = new Set(tokenize(value));
  return words.every((word) => tokens.has(word));
}

const ALIASES: AliasSpec[] = [
  {
    aliases: [
      "new tab",
      "tab new",
      "open new tab",
      "open a new tab",
      "open your tab",
      "open in your tab",
      "open another tab",
      "another tab",
      "make a new browser tab",
      "open new tabs",
      "open two new tabs",
    ],
    predicate: (entry) => entry.type === "shortcut" && (shortcutValue(entry) === "ct" || hasAllWords(entry.searchText, ["new", "tab"])),
    reason: "alias:new_tab",
  },
  {
    aliases: ["close tab", "kill tab", "close this tab", "kill this tab", "shut this tab", "shut tab"],
    predicate: (entry) => entry.type === "shortcut" && (shortcutValue(entry) === "cw" || hasAllWords(entry.searchText, ["close", "tab"])),
    reason: "alias:close_tab",
  },
  {
    aliases: ["duplicate tab", "duplicate page", "clone tab", "make copy of this tab", "copy of this tab"],
    predicate: (entry) => hasAllWords(entry.searchText, ["duplicate", "tab"]) || hasAllWords(entry.searchText, ["clone", "tab"]),
    reason: "alias:duplicate_tab",
  },
  {
    aliases: ["copy current url", "copy url", "copy link", "yank url", "yank current url", "copy address bar", "yank current link"],
    predicate: (entry) =>
      (hasAllWords(entry.searchText, ["url"]) || hasAllWords(entry.searchText, ["link"])) &&
      (hasAllWords(entry.searchText, ["copy"]) || hasAllWords(entry.searchText, ["yank"])),
    reason: "alias:copy_url",
  },
  {
    aliases: ["go back", "previous page", "back", "go to previous website", "return to prior page", "prior page"],
    predicate: (entry) => shortcutValue(entry) === "copenbracket" || hasAllWords(entry.searchText, ["back"]),
    reason: "alias:back",
  },
  {
    aliases: ["go forward", "next page", "forward", "advance to next website"],
    predicate: (entry) => shortcutValue(entry) === "cclosebracket" || hasAllWords(entry.searchText, ["forward"]),
    reason: "alias:forward",
  },
  {
    aliases: ["search history", "history"],
    predicate: (entry) => hasAllWords(entry.searchText, ["history"]),
    reason: "alias:history",
  },
  {
    aliases: ["select all", "highlight everything"],
    predicate: (entry) => entry.type === "shortcut" && (shortcutValue(entry) === "ca" || hasAllWords(entry.searchText, ["select", "all"])),
    reason: "alias:select_all",
  },
  {
    aliases: ["confetti", "run confetti", "celebrate in raycast", "throw confetti"],
    predicate: (entry) => hasAllWords(entry.searchText, ["confetti"]),
    reason: "alias:confetti",
  },
  {
    aliases: ["left half", "move left", "move window left", "tile left", "tile window left", "snap left", "snap window left"],
    predicate: (entry) =>
      entry.type === "url" &&
      (entry.value.includes("window-management/left-half") || hasAllWords(entry.searchText, ["left", "half"])),
    reason: "alias:window_left_half",
  },
  {
    aliases: ["right half", "move right", "move window right", "tile right", "tile window right", "snap right", "snap window right"],
    predicate: (entry) =>
      entry.type === "url" &&
      (entry.value.includes("window-management/right-half") || hasAllWords(entry.searchText, ["right", "half"])),
    reason: "alias:window_right_half",
  },
  {
    aliases: ["remove everything", "run rm rf documents", "delete all documents", "sudo cleanup", "dangerous remove command"],
    predicate: (entry) => entry.type === "command" || entry.safety !== "safe",
    reason: "alias:unsafe",
  },
];

const GENERIC_SINGLE_TOKEN_QUERIES = new Set([
  "browser",
  "copy",
  "current",
  "go",
  "navigation",
  "open",
  "page",
  "tab",
]);

function stem(word: string): string {
  if (word.length > 3 && word.endsWith("s") && !word.endsWith("ss")) {
    return word.slice(0, -1);
  }
  return word;
}

function aliasMatches(clause: string, alias: string): boolean {
  const clauseTokens = new Set(
    tokenize(clause)
      .filter((token) => token !== "this" && token !== "current")
      .flatMap((token) => [token, stem(token)]),
  );
  const aliasTokens = tokenize(alias).filter((token) => token !== "this" && token !== "current");
  return aliasTokens.length > 0 && aliasTokens.every((token) => clauseTokens.has(token) || clauseTokens.has(stem(token)));
}

function aliasScore(entry: ActionEntry, spec: AliasSpec): number {
  const search = normalizeText(entry.searchText);
  const aliasHit = spec.aliases.some((alias) => search.includes(normalizeText(alias))) ? 2 : 0;
  const typeBoost = entry.type === "shortcut" ? 0.5 : 0;
  return aliasHit + typeBoost + (spec.tieBreaker?.(entry) ?? 0);
}

function matchAlias(catalog: ActionCatalog, clause: string): ActionCandidate | undefined {
  const spec = ALIASES.find((candidate) => candidate.aliases.some((alias) => aliasMatches(clause, alias)));
  if (!spec) {
    return undefined;
  }

  const matches = catalog.entries
    .filter(spec.predicate)
    .sort((left, right) => aliasScore(right, spec) - aliasScore(left, spec) || left.id.localeCompare(right.id));
  const action = matches[0];
  if (!action) {
    return undefined;
  }
  return {
    action,
    confidence: 0.95,
    reason: spec.reason,
    score: 100,
  };
}

export interface FastMatchResult {
  plan: DispatchPlan;
  candidatesByClause: ActionCandidate[][];
}

function matchClause(catalog: ActionCatalog, clause: string): { candidate?: ActionCandidate; candidates: ActionCandidate[]; ambiguous: boolean } {
  const aliasCandidate = matchAlias(catalog, clause);
  if (!aliasCandidate && GENERIC_SINGLE_TOKEN_QUERIES.has(normalizeText(clause))) {
    return { ambiguous: true, candidates: [], candidate: undefined };
  }
  const retrieved = retrieveActions(catalog, clause, 12);
  const candidates = aliasCandidate
    ? [aliasCandidate, ...retrieved.filter((candidate) => candidate.action.id !== aliasCandidate.action.id)]
    : retrieved;
  const best = candidates[0];
  const second = candidates[1];
  const bestIsAlias = aliasCandidate && best === aliasCandidate;
  const ambiguous = Boolean(
    !bestIsAlias &&
    best &&
    second &&
    best.confidence >= 0.75 &&
    second.confidence >= 0.75 &&
    best.confidence - second.confidence < 0.05,
  );
  return { ambiguous, candidate: best, candidates };
}

export function fastMatch(catalog: ActionCatalog, transcript: string): FastMatchResult {
  const clauses = splitTranscript(transcript);
  const matches = clauses.map((clause) => matchClause(catalog, clause));
  const candidatesByClause = matches.map((match) => match.candidates);
  const unresolved = clauses.filter((_, index) => {
    const match = matches[index]!;
    const minimum = clauses.length === 1 ? 0.92 : 0.85;
    const second = match.candidates[1];
    const marginOk = clauses.length === 1 || !second || match.candidate!.confidence - second.confidence >= 0.08;
    return !match.candidate || match.candidate.confidence < minimum || !marginOk || match.ambiguous;
  });

  if (clauses.length === 0 || unresolved.length > 0) {
    return {
      candidatesByClause,
      plan: {
        chain: [],
        mode: "fast_match",
        needs_confirmation: false,
        overall_confidence: 0,
        reason: unresolved.length > 0 ? "unresolved clauses require planner" : "empty transcript",
        unresolved,
      },
    };
  }

  const chosen = matches.map((match) => match.candidate!);
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
      reason: chosen.map((candidate) => candidate.reason).join(", "),
    },
  };
}
