import type { FlatIndexRecord } from "./types.js";

interface PreparedField {
  compact: string;
  value: string;
  weight: number;
}

interface SearchContext {
  depth: number;
  relativeBreadcrumbDisplay: string;
  relativeKeyPath: string[];
  relativeKeySequence: string;
}

const KEY_SEARCH_ALIASES = new Map<string, string[]>([
  ["←", ["left arrow", "left_arrow", "leftarrow", "left"]],
  ["→", ["right arrow", "right_arrow", "rightarrow", "right"]],
  ["↑", ["up arrow", "up_arrow", "uparrow", "up"]],
  ["↓", ["down arrow", "down_arrow", "downarrow", "down"]],
  [" ", ["space bar", "space_bar", "spacebar", "space"]],
]);

function normalizeText(value: string): string {
  return value
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .trim();
}

function compactText(value: string): string {
  return normalizeText(value).replace(/[^a-z0-9]+/g, "");
}

function compactPath(value: string): string {
  return normalizeText(value)
    .replace(/\s*(?:->|→)\s*/g, "")
    .replace(/\s+/g, "");
}

function aliasSequenceForKeyPath(keyPath: string[]): string | undefined {
  let hasAlias = false;
  const segments = keyPath
    .map((segment) => {
      const aliases = KEY_SEARCH_ALIASES.get(segment);
      if (aliases) {
        hasAlias = true;
        return aliases[0]!;
      }

      return normalizeText(segment);
    })
    .filter(Boolean);

  if (!hasAlias || segments.length === 0) {
    return undefined;
  }

  return segments.join(" -> ");
}

function aliasBagForKeyPath(keyPath: string[]): string | undefined {
  let hasAlias = false;
  const tokens = keyPath.flatMap((segment) => {
    const aliases = KEY_SEARCH_ALIASES.get(segment);
    if (aliases) {
      hasAlias = true;
      return aliases;
    }

    const normalized = normalizeText(segment);
    return normalized ? [normalized] : [];
  });

  if (!hasAlias || tokens.length === 0) {
    return undefined;
  }

  return tokens.join(" ");
}

function prepareFields(record: FlatIndexRecord, context?: SearchContext): PreparedField[] {
  const relativeAliasSequence = context?.relativeKeyPath ? aliasSequenceForKeyPath(context.relativeKeyPath) : undefined;
  const relativeAliasBag = context?.relativeKeyPath ? aliasBagForKeyPath(context.relativeKeyPath) : undefined;
  const absoluteAliasSequence = aliasSequenceForKeyPath(record.effectiveKeyPath);
  const absoluteAliasBag = aliasBagForKeyPath(record.effectiveKeyPath);
  const fields: PreparedField[] = [
    ...(context?.relativeKeySequence
      ? [{
          compact: compactPath(context.relativeKeySequence),
          value: normalizeText(context.relativeKeySequence),
          weight: 860,
        }]
      : []),
    ...(relativeAliasSequence
      ? [{
          compact: compactPath(relativeAliasSequence),
          value: normalizeText(relativeAliasSequence),
          weight: 840,
        }]
      : []),
    ...(relativeAliasBag
      ? [{
          compact: compactText(relativeAliasBag),
          value: normalizeText(relativeAliasBag),
          weight: 820,
        }]
      : []),
    ...(context?.relativeBreadcrumbDisplay
      ? [{
          compact: compactPath(context.relativeBreadcrumbDisplay),
          value: normalizeText(context.relativeBreadcrumbDisplay),
          weight: 780,
        }]
      : []),
    {
      compact: compactPath(record.keySequence),
      value: normalizeText(record.keySequence),
      weight: 700,
    },
    ...(absoluteAliasSequence
      ? [{
          compact: compactPath(absoluteAliasSequence),
          value: normalizeText(absoluteAliasSequence),
          weight: 680,
        }]
      : []),
    ...(absoluteAliasBag
      ? [{
          compact: compactText(absoluteAliasBag),
          value: normalizeText(absoluteAliasBag),
          weight: 660,
        }]
      : []),
    {
      compact: compactPath(record.breadcrumbDisplay),
      value: normalizeText(record.breadcrumbDisplay),
      weight: 640,
    },
    {
      compact: compactText(record.displayLabel),
      value: normalizeText(record.displayLabel),
      weight: 520,
    },
    {
      compact: compactText(record.description ?? ""),
      value: normalizeText(record.description ?? ""),
      weight: 500,
    },
    {
      compact: compactText(record.aiDescription ?? ""),
      value: normalizeText(record.aiDescription ?? ""),
      weight: 460,
    },
    {
      compact: compactText(record.effectiveConfigDisplayName),
      value: normalizeText(record.effectiveConfigDisplayName),
      weight: 360,
    },
    {
      compact: compactText(record.appName ?? ""),
      value: normalizeText(record.appName ?? ""),
      weight: 320,
    },
    {
      compact: compactText(record.rawValue),
      value: normalizeText(record.rawValue),
      weight: 220,
    },
  ];

  return fields.filter((field) => field.value || field.compact);
}

function substringScore(haystack: string, needle: string, weight: number): number | undefined {
  if (!needle || !haystack) {
    return undefined;
  }

  const index = haystack.indexOf(needle);
  if (index === -1) {
    return undefined;
  }

  const prefixBonus = index === 0 ? 90 : 0;
  const tightnessBonus = Math.max(0, 60 - index * 4);
  const lengthBonus = Math.max(0, 40 - Math.max(0, haystack.length - needle.length));
  return weight + prefixBonus + tightnessBonus + lengthBonus;
}

function subsequenceScore(haystack: string, needle: string, weight: number): number | undefined {
  if (!needle || !haystack) {
    return undefined;
  }

  let position = -1;
  let score = weight;
  let consecutive = 0;

  for (let index = 0; index < needle.length; index += 1) {
    const char = needle[index]!;
    const nextPosition = haystack.indexOf(char, position + 1);
    if (nextPosition === -1) {
      return undefined;
    }

    const gap = nextPosition - position - 1;
    if (gap === 0) {
      consecutive += 1;
      score += 16 + Math.min(consecutive * 6, 30);
    } else {
      consecutive = 0;
      score += Math.max(2, 12 - gap);
    }

    if (nextPosition === 0) {
      score += 18;
    }

    position = nextPosition;
  }

  score += Math.max(0, 30 - (haystack.length - needle.length));
  return score;
}

function scoreRecord(
  record: FlatIndexRecord,
  normalizedQuery: string,
  compactQuery: string,
  context?: SearchContext,
): number | undefined {
  const fields = prepareFields(record, context);
  let bestFieldScore = Number.NEGATIVE_INFINITY;

  for (const field of fields) {
    const exactCompactScore = substringScore(field.compact, compactQuery, field.weight + 300);
    if (exactCompactScore !== undefined) {
      bestFieldScore = Math.max(bestFieldScore, exactCompactScore);
    }

    const exactTextScore = substringScore(field.value, normalizedQuery, field.weight);
    if (exactTextScore !== undefined) {
      bestFieldScore = Math.max(bestFieldScore, exactTextScore);
    }

    if (compactQuery.length >= 2) {
      const fuzzyCompactScore = subsequenceScore(field.compact, compactQuery, Math.max(80, field.weight - 140));
      if (fuzzyCompactScore !== undefined) {
        bestFieldScore = Math.max(bestFieldScore, fuzzyCompactScore);
      }

      const fuzzyTextScore = subsequenceScore(
        field.value.replace(/[^a-z0-9]+/g, ""),
        compactQuery,
        Math.max(40, field.weight - 220),
      );
      if (fuzzyTextScore !== undefined) {
        bestFieldScore = Math.max(bestFieldScore, fuzzyTextScore);
      }
    }
  }

  if (!Number.isFinite(bestFieldScore)) {
    return undefined;
  }

  const depthBonus = context ? Math.max(0, 24 - Math.max(0, context.depth - 1) * 6) : 0;
  return bestFieldScore + depthBonus;
}

function searchWithContext(
  records: FlatIndexRecord[],
  query: string,
  contextForRecord?: (record: FlatIndexRecord) => SearchContext | undefined,
): FlatIndexRecord[] {
  const trimmedQuery = query.trim();
  if (!trimmedQuery) {
    return [...records].sort((left, right) => left.breadcrumbDisplay.localeCompare(right.breadcrumbDisplay));
  }

  const normalizedQuery = normalizeText(trimmedQuery);
  const compactQuery = compactPath(trimmedQuery);

  return records
    .map((record) => {
      const score = scoreRecord(record, normalizedQuery, compactQuery, contextForRecord?.(record));
      if (score === undefined) {
        return undefined;
      }

      return { record, score };
    })
    .filter((entry): entry is { record: FlatIndexRecord; score: number } => Boolean(entry))
    .sort((left, right) => right.score - left.score || left.record.breadcrumbDisplay.localeCompare(right.record.breadcrumbDisplay))
    .map((entry) => entry.record);
}

function isDescendantOf(record: FlatIndexRecord, parentEffectiveKeyPath: string[]): boolean {
  return (
    record.effectiveKeyPath.length > parentEffectiveKeyPath.length &&
    parentEffectiveKeyPath.every((segment, index) => record.effectiveKeyPath[index] === segment)
  );
}

function relativePathText(record: FlatIndexRecord, parentEffectiveKeyPath: string[]): string {
  return record.effectiveKeyPath.slice(parentEffectiveKeyPath.length).join(" -> ");
}

function relativeBreadcrumbText(record: FlatIndexRecord, parentEffectiveKeyPath: string[]): string {
  const relativeBreadcrumb = record.breadcrumbPath.slice(1 + parentEffectiveKeyPath.length);
  return relativeBreadcrumb.join(" -> ");
}

export function searchRecords(records: FlatIndexRecord[], query: string): FlatIndexRecord[] {
  return searchWithContext(records, query);
}

export function searchRecordsInSubtree(
  records: FlatIndexRecord[],
  query: string,
  parentEffectiveKeyPath: string[],
): FlatIndexRecord[] {
  const descendants = records.filter((record) => isDescendantOf(record, parentEffectiveKeyPath));

  return searchWithContext(descendants, query, (record) => ({
    depth: Math.max(1, record.effectiveKeyPath.length - parentEffectiveKeyPath.length),
    relativeBreadcrumbDisplay: relativeBreadcrumbText(record, parentEffectiveKeyPath),
    relativeKeyPath: record.effectiveKeyPath.slice(parentEffectiveKeyPath.length),
    relativeKeySequence: relativePathText(record, parentEffectiveKeyPath),
  }));
}
