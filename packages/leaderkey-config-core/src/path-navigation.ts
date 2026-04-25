import { recordsForConfig } from "./indexing.js";
import type { CachePayload, ConfigSummary, FlatIndexRecord } from "./types.js";

export type PathResolutionState = "blocked" | "exact-action" | "exact-group" | "missing" | "root";

export interface PathAnalysis {
  autoCreateGroupKeys: string[];
  blockedRemainingPath: string[];
  config: ConfigSummary;
  createParentKeyPath: string[];
  deepestExistingGroupPath: string[];
  exactMatch?: FlatIndexRecord;
  finalKey?: string;
  input: string;
  missingSegments: string[];
  state: PathResolutionState;
  terminalAction?: FlatIndexRecord;
  typedPath: string[];
  visibleChildren: FlatIndexRecord[];
}

const PATH_KEY_ALIASES = new Map<string, string>([
  ["left arrow", "←"],
  ["left_arrow", "←"],
  ["leftarrow", "←"],
  ["left", "←"],
  ["right arrow", "→"],
  ["right_arrow", "→"],
  ["rightarrow", "→"],
  ["right", "→"],
  ["up arrow", "↑"],
  ["up_arrow", "↑"],
  ["uparrow", "↑"],
  ["up", "↑"],
  ["down arrow", "↓"],
  ["down_arrow", "↓"],
  ["downarrow", "↓"],
  ["down", "↓"],
  ["space bar", " "],
  ["space_bar", " "],
  ["spacebar", " "],
  ["space", " "],
]);

const SORTED_PATH_ALIAS_TOKENS = [...PATH_KEY_ALIASES.keys()].sort((left, right) => right.length - left.length);

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

function keyPathId(keyPath: string[]): string {
  return keyPath.join("\u0000");
}

function childRecords(records: FlatIndexRecord[], parentEffectiveKeyPath: string[]): FlatIndexRecord[] {
  return records.filter((record) => keyPathMatches(record.parentEffectiveKeyPath, parentEffectiveKeyPath));
}

function isContainerRecord(record: FlatIndexRecord): boolean {
  return record.kind === "group" || record.kind === "layer";
}

export function parsePathInput(input: string): string[] {
  return Array.from(input.trim());
}

function parsePathInputWithAliases(input: string): string[] {
  const trimmed = input.trim();
  if (!trimmed) {
    return [];
  }

  const normalizedInput = trimmed.toLowerCase();
  const typedPath: string[] = [];
  let index = 0;

  while (index < trimmed.length) {
    const alias = SORTED_PATH_ALIAS_TOKENS.find((token) => normalizedInput.startsWith(token, index));
    if (alias) {
      typedPath.push(PATH_KEY_ALIASES.get(alias)!);
      index += alias.length;
      continue;
    }

    typedPath.push(trimmed[index]!);
    index += 1;
  }

  return typedPath;
}

function analyzeTypedPath(
  configRecords: FlatIndexRecord[],
  config: ConfigSummary,
  input: string,
  typedPath: string[],
): PathAnalysis {
  const recordsByPath = new Map(configRecords.map((record) => [keyPathId(record.effectiveKeyPath), record] as const));

  if (typedPath.length === 0) {
    return {
      autoCreateGroupKeys: [],
      blockedRemainingPath: [],
      config,
      createParentKeyPath: [],
      deepestExistingGroupPath: [],
      exactMatch: undefined,
      finalKey: undefined,
      input,
      missingSegments: [],
      state: "root",
      terminalAction: undefined,
      typedPath,
      visibleChildren: childRecords(configRecords, []),
    };
  }

  let deepestExistingGroupPath: string[] = [];
  let exactMatch: FlatIndexRecord | undefined;
  let terminalAction: FlatIndexRecord | undefined;
  let missingSegments: string[] = [];
  let blockedRemainingPath: string[] = [];
  let state: PathResolutionState = "root";

  for (let index = 0; index < typedPath.length; index += 1) {
    const prefix = typedPath.slice(0, index + 1);
    const match = recordsByPath.get(keyPathId(prefix));

    if (!match) {
      state = "missing";
      missingSegments = typedPath.slice(index);
      break;
    }

    if (!isContainerRecord(match)) {
      if (index === typedPath.length - 1) {
        state = "exact-action";
        exactMatch = match;
        deepestExistingGroupPath = match.parentEffectiveKeyPath;
      } else {
        state = "blocked";
        terminalAction = match;
        deepestExistingGroupPath = match.parentEffectiveKeyPath;
        blockedRemainingPath = typedPath.slice(index + 1);
      }
      break;
    }

    deepestExistingGroupPath = match.effectiveKeyPath;
    if (index === typedPath.length - 1) {
      state = "exact-group";
      exactMatch = match;
    }
  }

  if (state === "root") {
    state = "missing";
    missingSegments = typedPath;
  }

  const visibleParentPath = state === "exact-group"
    ? exactMatch?.effectiveKeyPath ?? []
    : deepestExistingGroupPath;

  return {
    autoCreateGroupKeys: state === "missing" ? missingSegments.slice(0, -1) : [],
    blockedRemainingPath,
    config,
    createParentKeyPath: state === "missing" ? typedPath.slice(0, -1) : [],
    deepestExistingGroupPath,
    exactMatch,
    finalKey: typedPath.at(-1),
    input,
    missingSegments,
    state,
    terminalAction,
    typedPath,
    visibleChildren: childRecords(configRecords, visibleParentPath),
  };
}

function matchedSegmentCount(analysis: PathAnalysis): number {
  switch (analysis.state) {
    case "exact-action":
    case "exact-group":
      return analysis.typedPath.length;
    case "blocked":
      return analysis.typedPath.length - analysis.blockedRemainingPath.length;
    case "missing":
      return analysis.typedPath.length - analysis.missingSegments.length;
    case "root":
      return 0;
  }
}

function stateRank(state: PathResolutionState): number {
  switch (state) {
    case "exact-action":
    case "exact-group":
      return 3;
    case "blocked":
      return 2;
    case "missing":
      return 1;
    case "root":
      return 0;
  }
}

function pickPreferredAnalysis(candidates: PathAnalysis[]): PathAnalysis {
  return [...candidates].sort((left, right) =>
    matchedSegmentCount(right) - matchedSegmentCount(left) ||
    stateRank(right.state) - stateRank(left.state) ||
    left.typedPath.length - right.typedPath.length
  )[0]!;
}

export function analyzePathInConfig(
  payload: CachePayload,
  config: ConfigSummary,
  input: string,
): PathAnalysis {
  const configRecords = recordsForConfig(payload, config.displayName);
  const rawTypedPath = parsePathInput(input);
  const aliasTypedPath = parsePathInputWithAliases(input);
  const analyses = [analyzeTypedPath(configRecords, config, input, rawTypedPath)];

  if (!keyPathMatches(aliasTypedPath, rawTypedPath)) {
    analyses.push(analyzeTypedPath(configRecords, config, input, aliasTypedPath));
  }

  return pickPreferredAnalysis(analyses);
}
