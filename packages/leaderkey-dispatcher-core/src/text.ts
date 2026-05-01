export function normalizeText(value: string): string {
  return value
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[’']/g, "")
    .replace(/[^a-z0-9+#[\]\s-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function tokenize(value: string): string[] {
  return normalizeText(value)
    .split(/\s+/)
    .map((token) => token.trim())
    .filter((token) => token.length > 0);
}

export function uniqueTokens(value: string): string[] {
  return Array.from(new Set(tokenize(value)));
}

export function splitTranscript(transcript: string): string[] {
  return normalizeText(transcript)
    .split(/\s+(?:and then|after that|then|and)\s+|[,;]+/g)
    .map((clause) => clause.trim())
    .filter(Boolean);
}

export function slugify(value: string): string {
  return normalizeText(value)
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 72) || "action";
}

export function stableHash(value: string): string {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193);
  }
  return (hash >>> 0).toString(36).padStart(6, "0");
}

export function bigramSimilarity(left: string, right: string): number {
  const a = normalizeText(left).replace(/\s+/g, "");
  const b = normalizeText(right).replace(/\s+/g, "");
  if (!a || !b) {
    return 0;
  }
  if (a === b) {
    return 1;
  }
  if (a.length < 2 || b.length < 2) {
    return a === b ? 1 : 0;
  }

  const grams = new Map<string, number>();
  for (let index = 0; index < a.length - 1; index += 1) {
    const gram = a.slice(index, index + 2);
    grams.set(gram, (grams.get(gram) ?? 0) + 1);
  }

  let overlap = 0;
  for (let index = 0; index < b.length - 1; index += 1) {
    const gram = b.slice(index, index + 2);
    const count = grams.get(gram) ?? 0;
    if (count > 0) {
      overlap += 1;
      grams.set(gram, count - 1);
    }
  }

  return (2 * overlap) / (a.length + b.length - 2);
}
