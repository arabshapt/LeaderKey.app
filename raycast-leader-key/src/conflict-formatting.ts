import type { CachePayload, ConfigDiagnostic, FlatIndexRecord, SourceSummary } from "@leaderkey/config-core";

function sameStringArray(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

function sameNodePath(left: number[], right: number[]): boolean {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

function uniqueSorted(values: string[]): string[] {
  return Array.from(new Set(values.filter((value) => value.trim().length > 0))).sort((left, right) =>
    left.localeCompare(right)
  );
}

function matchingRecordsForSource(payload: CachePayload, sourceRecord: FlatIndexRecord): FlatIndexRecord[] {
  return payload.records.filter((record) =>
    record.sourceConfigPath === sourceRecord.sourceConfigPath &&
    record.sourceStatus === sourceRecord.sourceStatus &&
    record.sourceTagId === sourceRecord.sourceTagId &&
    sameNodePath(record.sourceNodePath, sourceRecord.sourceNodePath) &&
    sameStringArray(record.effectiveKeyPath, sourceRecord.effectiveKeyPath)
  );
}

export function affectedConfigNamesForOverride(payload: CachePayload | undefined, sourceRecord: FlatIndexRecord): string[] {
  if (!payload) {
    return sourceRecord.effectiveConfigDisplayName ? [sourceRecord.effectiveConfigDisplayName] : [];
  }

  return uniqueSorted(
    matchingRecordsForSource(payload, sourceRecord).map((record) =>
      record.appName?.trim() || record.effectiveConfigDisplayName
    ),
  );
}

export function sourceDisplayText(source: Pick<SourceSummary, "configDisplayName" | "keySequence" | "sourceStatus">): string {
  const keyText = source.keySequence ? ` at ${source.keySequence}` : "";
  return `${source.configDisplayName}${keyText}`;
}

export function overrideWarningText(
  sourceRecord: FlatIndexRecord,
  payload?: CachePayload,
  diagnostics: ConfigDiagnostic[] = payload?.diagnostics ?? [],
): string {
  const diagnostic = diagnostics.find((candidate) =>
    candidate.kind === "shadowedSource" &&
    candidate.hiddenSource?.configPath === sourceRecord.sourceConfigPath &&
    candidate.hiddenSource?.keySequence === sourceRecord.keySequence
  );
  const affectedNames = diagnostic?.affectedBundleIds?.length
    ? diagnostic.affectedBundleIds
    : affectedConfigNamesForOverride(payload, sourceRecord);
  const affectedText = affectedNames.length > 0 ? ` for ${affectedNames.join(", ")}` : "";

  return `This will override ${sourceRecord.sourceConfigDisplayName} at ${sourceRecord.keySequence}${affectedText}.`;
}

