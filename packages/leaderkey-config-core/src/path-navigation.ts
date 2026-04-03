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

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

function keyPathId(keyPath: string[]): string {
  return keyPath.join("\u0000");
}

function childRecords(records: FlatIndexRecord[], parentEffectiveKeyPath: string[]): FlatIndexRecord[] {
  return records.filter((record) => keyPathMatches(record.parentEffectiveKeyPath, parentEffectiveKeyPath));
}

export function parsePathInput(input: string): string[] {
  return Array.from(input.trim());
}

export function analyzePathInConfig(
  payload: CachePayload,
  config: ConfigSummary,
  input: string,
): PathAnalysis {
  const typedPath = parsePathInput(input);
  const configRecords = recordsForConfig(payload, config.displayName);
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

    if (match.kind === "action") {
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
