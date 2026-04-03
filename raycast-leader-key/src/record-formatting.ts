import type { FlatIndexRecord } from "@leaderkey/config-core";

export function compactSequenceText(sequence: string): string {
  return sequence.replaceAll(" -> ", " → ");
}

export function keyPathText(keyPath: string[]): string {
  return compactSequenceText(keyPath.join(" -> "));
}

export function canonicalSequenceText(record: Pick<FlatIndexRecord, "key" | "keySequence">): string {
  return compactSequenceText(record.keySequence || record.key || "—");
}

export function fullPathText(record: Pick<FlatIndexRecord, "breadcrumbDisplay" | "key" | "keySequence">): string {
  return compactSequenceText(record.breadcrumbDisplay || record.keySequence || record.key || "—");
}

export function truncateText(value: string, maxLength = 52): string {
  if (value.length <= maxLength) {
    return value;
  }

  return `${value.slice(0, maxLength - 1)}…`;
}
