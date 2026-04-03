import type { FlatIndexRecord } from "./types.js";

interface PreparedField {
  compact: string;
  value: string;
  weight: number;
}

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

function prepareFields(record: FlatIndexRecord): PreparedField[] {
  return [
    {
      compact: compactPath(record.keySequence),
      value: normalizeText(record.keySequence),
      weight: 700,
    },
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
  ].filter((field) => field.value || field.compact);
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

export function searchRecords(records: FlatIndexRecord[], query: string): FlatIndexRecord[] {
  const trimmedQuery = query.trim();
  if (!trimmedQuery) {
    return [...records].sort((left, right) => left.breadcrumbDisplay.localeCompare(right.breadcrumbDisplay));
  }

  const normalizedQuery = normalizeText(trimmedQuery);
  const compactQuery = compactPath(trimmedQuery);

  return records
    .map((record) => {
      const fields = prepareFields(record);
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

      return { record, score: bestFieldScore };
    })
    .filter((entry): entry is { record: FlatIndexRecord; score: number } => Boolean(entry))
    .sort((left, right) => right.score - left.score || left.record.breadcrumbDisplay.localeCompare(right.record.breadcrumbDisplay))
    .map((entry) => entry.record);
}
