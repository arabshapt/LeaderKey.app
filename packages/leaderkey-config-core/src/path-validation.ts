import type { CachePayload, FlatIndexRecord } from "./types.js";

export interface RecordPathValidationResult {
  autoCreateGroupKeys: string[];
  destinationKeyPath: string[];
  error?: string;
  overrideRecord?: FlatIndexRecord;
}

export interface ValidateRecordPathOptions {
  configFilePath: string;
  currentRecord?: FlatIndexRecord;
  destinationKeyPath: string[];
}

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

function isKeyPathPrefix(prefix: string[], fullPath: string[]): boolean {
  return prefix.length < fullPath.length && prefix.every((segment, index) => segment === fullPath[index]);
}

function localRecordsForConfigFile(payload: CachePayload, configFilePath: string): FlatIndexRecord[] {
  return payload.records.filter((record) => !record.inherited && record.sourceConfigPath === configFilePath);
}

function effectiveRecordsForConfigFile(payload: CachePayload, configFilePath: string): FlatIndexRecord[] {
  return payload.records.filter((record) => record.effectiveConfigPath === configFilePath);
}

function isSameEditableRecord(currentRecord: FlatIndexRecord | undefined, candidate: FlatIndexRecord): boolean {
  return Boolean(currentRecord && candidate.id === currentRecord.id);
}

function overrideRecordForDestination(
  payload: CachePayload,
  configFilePath: string,
  destinationKeyPath: string[],
): FlatIndexRecord | undefined {
  const effectiveRecords = effectiveRecordsForConfigFile(payload, configFilePath);

  return effectiveRecords.find((record) =>
    record.inherited &&
    (
      keyPathMatches(record.effectiveKeyPath, destinationKeyPath) ||
      (record.kind === "action" && isKeyPathPrefix(record.effectiveKeyPath, destinationKeyPath))
    ),
  );
}

export function validateRecordPath(
  payload: CachePayload,
  options: ValidateRecordPathOptions,
): RecordPathValidationResult {
  const { configFilePath, currentRecord, destinationKeyPath } = options;

  if (destinationKeyPath.length === 0) {
    return {
      autoCreateGroupKeys: [],
      destinationKeyPath,
      error: "A full path is required.",
    };
  }

  if (currentRecord?.kind === "group" && isKeyPathPrefix(currentRecord.effectiveKeyPath, destinationKeyPath)) {
    return {
      autoCreateGroupKeys: [],
      destinationKeyPath,
      error: "A group cannot be moved into its own descendant path.",
    };
  }

  const localRecords = localRecordsForConfigFile(payload, configFilePath);
  const exactCollision = localRecords.find((record) =>
    !isSameEditableRecord(currentRecord, record) &&
    keyPathMatches(record.effectiveKeyPath, destinationKeyPath),
  );

  if (exactCollision) {
    return {
      autoCreateGroupKeys: [],
      destinationKeyPath,
      error: `An item already exists at ${destinationKeyPath.join(" -> ")}.`,
    };
  }

  const blockingAction = localRecords.find((record) =>
    !isSameEditableRecord(currentRecord, record) &&
    record.kind === "action" &&
    isKeyPathPrefix(record.effectiveKeyPath, destinationKeyPath),
  );

  if (blockingAction) {
    return {
      autoCreateGroupKeys: [],
      destinationKeyPath,
      error: `Action ${blockingAction.displayLabel} blocks descendants under ${blockingAction.effectiveKeyPath.join(" -> ")}.`,
    };
  }

  const autoCreateGroupKeys: string[] = [];
  for (let index = 0; index < destinationKeyPath.length - 1; index += 1) {
    const prefix = destinationKeyPath.slice(0, index + 1);
    const localGroup = localRecords.find((record) =>
      !isSameEditableRecord(currentRecord, record) &&
      record.kind === "group" &&
      keyPathMatches(record.effectiveKeyPath, prefix),
    );

    if (localGroup) {
      continue;
    }

    autoCreateGroupKeys.push(destinationKeyPath[index]!);
  }

  return {
    autoCreateGroupKeys,
    destinationKeyPath,
    overrideRecord: overrideRecordForDestination(payload, configFilePath, destinationKeyPath),
  };
}
