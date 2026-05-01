import type { ActionCandidate, ActionCatalog, ActionEntry } from "./types.js";
import { bigramSimilarity, normalizeText, tokenize, uniqueTokens } from "./text.js";

const STOP_WORDS = new Set([
  "a",
  "an",
  "and",
  "current",
  "please",
  "run",
  "the",
  "this",
  "to",
]);

function queryTokens(value: string): string[] {
  return uniqueTokens(value).filter((token) => !STOP_WORDS.has(token));
}

function entryTokens(entry: ActionEntry): string[] {
  return tokenize(entry.searchText);
}

function documentFrequency(entries: ActionEntry[]): Map<string, number> {
  const df = new Map<string, number>();
  for (const entry of entries) {
    for (const token of new Set(entryTokens(entry))) {
      df.set(token, (df.get(token) ?? 0) + 1);
    }
  }
  return df;
}

function bm25Score(query: string, entry: ActionEntry, df: Map<string, number>, docCount: number): number {
  const tokens = queryTokens(query);
  if (tokens.length === 0) {
    return 0;
  }

  const docTokens = entryTokens(entry);
  const docLength = Math.max(1, docTokens.length);
  const frequencies = new Map<string, number>();
  for (const token of docTokens) {
    frequencies.set(token, (frequencies.get(token) ?? 0) + 1);
  }

  const avgLength = 48;
  const k1 = 1.2;
  const b = 0.75;
  let score = 0;
  for (const token of tokens) {
    const tf = frequencies.get(token) ?? 0;
    if (tf === 0) {
      continue;
    }
    const idf = Math.log(1 + (docCount - (df.get(token) ?? 0) + 0.5) / ((df.get(token) ?? 0) + 0.5));
    score += idf * ((tf * (k1 + 1)) / (tf + k1 * (1 - b + b * (docLength / avgLength))));
  }
  return score;
}

function lexicalBoost(query: string, entry: ActionEntry): number {
  const normalized = normalizeText(query);
  const search = normalizeText(entry.searchText);
  const label = normalizeText(entry.label);
  const value = normalizeText(entry.value);

  if (!normalized) {
    return 0;
  }
  if (label === normalized || value === normalized) {
    return 8;
  }
  if (label.includes(normalized) || search.includes(normalized)) {
    return 5;
  }

  const tokens = queryTokens(normalized);
  const tokenSet = new Set(tokenize(search));
  const hits = tokens.filter((token) => tokenSet.has(token)).length;
  const recall = tokens.length > 0 ? hits / tokens.length : 0;
  const fuzzy = Math.max(bigramSimilarity(normalized, label), bigramSimilarity(normalized, search.slice(0, 160)));
  return recall * 3 + fuzzy * 1.5;
}

function confidenceFromScore(score: number, topScore: number): number {
  if (score <= 0 || topScore <= 0) {
    return 0;
  }
  const absolute = Math.min(0.98, score / 9);
  const relative = Math.min(0.98, score / topScore);
  return Math.max(0.01, Math.min(0.98, absolute * 0.65 + relative * 0.35));
}

export function retrieveActions(catalog: ActionCatalog, transcript: string, k = 12): ActionCandidate[] {
  const entries = catalog.entries;
  if (entries.length === 0) {
    return [];
  }

  const df = documentFrequency(entries);
  const scored = entries
    .map((entry) => {
      const score = bm25Score(transcript, entry, df, entries.length) + lexicalBoost(transcript, entry);
      return { entry, score };
    })
    .filter((item) => item.score > 0.1)
    .sort((left, right) => right.score - left.score || left.entry.id.localeCompare(right.entry.id));

  const topScore = scored[0]?.score ?? 0;
  return scored.slice(0, k).map((item) => ({
    action: item.entry,
    confidence: confidenceFromScore(item.score, topScore),
    reason: "bm25_token_fuzzy",
    score: item.score,
  }));
}
