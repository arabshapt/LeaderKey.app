import fs from "node:fs/promises";
import { performance } from "node:perf_hooks";
import type { BenchRow, DispatchRequest } from "./types.js";
import { planDispatch } from "./dispatch.js";

export interface BenchMetrics {
  total: number;
  exact_chain_match: number;
  contains_expected_actions: number;
  valid_plan: number;
  no_invented_action: number;
  needs_confirmation_correct: number;
  p50_ms: number;
  p95_ms: number;
  fast_path_hit_rate: number;
  planner_called_rate: number;
  by_category: Record<string, { total: number; exact_chain_match: number }>;
}

export async function readBenchRows(filePath: string): Promise<BenchRow[]> {
  const raw = await fs.readFile(filePath, "utf8");
  return raw
    .split(/\r?\n/g)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => JSON.parse(line) as BenchRow);
}

function percentile(values: number[], pct: number): number {
  if (values.length === 0) {
    return 0;
  }
  const sorted = [...values].sort((left, right) => left - right);
  const index = Math.min(sorted.length - 1, Math.floor((pct / 100) * sorted.length));
  return Number(sorted[index]!.toFixed(3));
}

function arraysEqual(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

export async function runBench(baseRequest: Omit<DispatchRequest, "transcript">, rows: BenchRow[]): Promise<BenchMetrics> {
  const latencies: number[] = [];
  let exact = 0;
  let contains = 0;
  let valid = 0;
  let noInvented = 0;
  let confirm = 0;
  let fast = 0;
  let planner = 0;
  const byCategory: BenchMetrics["by_category"] = {};

  for (const row of rows) {
    const start = performance.now();
    const result = await planDispatch({ ...baseRequest, transcript: row.transcript });
    latencies.push(performance.now() - start);

    const chain = result.plan.chain.map((step) => step.action_id);
    const catalogIds = new Set(result.catalog.entries.map((entry) => entry.id));
    const rowExact = row.expect_no_action ? chain.length === 0 : arraysEqual(chain, row.expected_action_ids);
    const rowContains = row.expect_no_action
      ? chain.length === 0
      : row.expected_action_ids.every((id) => chain.includes(id));
    exact += rowExact ? 1 : 0;
    contains += rowContains ? 1 : 0;
    valid += result.validation.valid || row.expect_no_action ? 1 : 0;
    noInvented += chain.every((id) => catalogIds.has(id)) ? 1 : 0;
    confirm += result.validation.needs_confirmation === row.expect_confirmation ? 1 : 0;
    fast += result.plan.mode === "fast_match" && chain.length > 0 ? 1 : 0;
    planner += result.plan.planner_called ? 1 : 0;

    byCategory[row.category] ??= { exact_chain_match: 0, total: 0 };
    byCategory[row.category]!.total += 1;
    byCategory[row.category]!.exact_chain_match += rowExact ? 1 : 0;
  }

  const total = rows.length || 1;
  return {
    by_category: byCategory,
    contains_expected_actions: contains / total,
    exact_chain_match: exact / total,
    fast_path_hit_rate: fast / total,
    needs_confirmation_correct: confirm / total,
    no_invented_action: noInvented / total,
    p50_ms: percentile(latencies, 50),
    p95_ms: percentile(latencies, 95),
    planner_called_rate: planner / total,
    total: rows.length,
    valid_plan: valid / total,
  };
}
