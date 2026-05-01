import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  buildActionCatalog,
  executeValidation,
  fastMatch,
  planDispatch,
  retrieveActions,
  validateDispatchPlan,
  type DispatchPlan,
  type ValidationReport,
} from "../src/index.js";

const fixturePath = path.resolve("../..", "fixtures/actions.json");

async function writeTempCatalog(value: unknown): Promise<string> {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "leaderkey-dispatcher-"));
  const filePath = path.join(dir, "actions.json");
  await fs.writeFile(filePath, JSON.stringify(value, null, 2));
  return filePath;
}

test("materializes nested terminal actions and skips empty groups", async () => {
  const catalogPath = await writeTempCatalog({
    actions: [
      {
        actions: [
          { key: "x", label: "Same Label", type: "shortcut", value: "Cx" },
          { key: "y", label: "Same Label", type: "shortcut", value: "Cy" },
          { actions: [], key: "z", label: "Empty", type: "group" },
        ],
        key: "g",
        label: "Group Label",
        type: "group",
      },
    ],
    type: "group",
  });
  const catalog = await buildActionCatalog({ catalogPath });

  assert.equal(catalog.entries.length, 2);
  assert.notEqual(catalog.entries[0]!.id, catalog.entries[1]!.id);
  assert.match(catalog.entries[0]!.searchText, /group label/);
  assert.deepEqual(catalog.entries.map((entry) => entry.keys), [["g", "x"], ["g", "y"]]);
});

test("preserves macro summaries and original values", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const macro = catalog.entries.find((entry) => entry.id === "url_copy");
  assert.ok(macro);
  assert.equal(macro.value, "");
  assert.deepEqual(macro.macroStepSummary, ["Shortcut: Cmd+L", "Shortcut: Cmd+C"]);
});

test("retrieves seeded voice commands", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });

  assert.equal(retrieveActions(catalog, "kill tab", 1)[0]?.action.id, "tab_close");
  assert.equal(retrieveActions(catalog, "copy link", 1)[0]?.action.id, "url_copy");
  assert.equal(retrieveActions(catalog, "confetti", 1)[0]?.action.id, "raycast_confetti");
  assert.equal(retrieveActions(catalog, "duplicate page", 1)[0]?.action.id, "tab_duplicate");
  assert.equal(retrieveActions(catalog, "previous page", 1)[0]?.action.id, "nav_back");
});

test("fast matcher returns ordered chained plans", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const result = fastMatch(catalog, "duplicate tab and copy current url");

  assert.equal(result.plan.mode, "fast_match");
  assert.deepEqual(result.plan.chain.map((step) => step.action_id), ["tab_duplicate", "url_copy"]);
  assert.ok(result.plan.overall_confidence >= 0.85);
});

test("fast matcher tolerates common STT drift for new tab", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });

  assert.equal(fastMatch(catalog, "I want you to open new tab").plan.chain[0]?.action_id, "tab_new");
  assert.equal(fastMatch(catalog, "open your tab").plan.chain[0]?.action_id, "tab_new");
  assert.equal(fastMatch(catalog, "open in your tab").plan.chain[0]?.action_id, "tab_new");
});

test("fast matcher refuses impossible commands", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const result = fastMatch(catalog, "turn off wifi");

  assert.deepEqual(result.plan.chain, []);
  assert.ok(result.plan.unresolved?.length);
});

test("validator rejects invented IDs, low confidence, and command actions", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const invented: DispatchPlan = {
    chain: [{ action_id: "missing", confidence: 0.99 }],
    mode: "llm_planner",
    needs_confirmation: false,
    overall_confidence: 0.99,
    reason: "test",
  };
  assert.equal(validateDispatchPlan(catalog, invented).blocked, true);

  const lowConfidence: DispatchPlan = {
    ...invented,
    chain: [{ action_id: "tab_close", confidence: 0.5 }],
    overall_confidence: 0.5,
  };
  assert.equal(validateDispatchPlan(catalog, lowConfidence).blocked, true);

  const commandPlan: DispatchPlan = {
    ...invented,
    chain: [{ action_id: "unsafe_rm", confidence: 0.99 }],
    overall_confidence: 0.99,
  };
  const validation = validateDispatchPlan(catalog, commandPlan);
  assert.equal(validation.blocked, true);
  assert.match(validation.reason, /command|blocked|voiceSafety|rm -rf/);
});

test("executeValidation gates needs_confirmation unless allowDestructive", async () => {
  const validation: ValidationReport = {
    blocked: false,
    needs_confirmation: true,
    reason: "confirmation required",
    steps: [],
    valid: true,
  };

  const dryReport = await executeValidation(validation, true, false);
  assert.equal(dryReport.executed, false);
  assert.equal(dryReport.dry_run, false);
  assert.equal(dryReport.needs_confirmation, true);

  const noExecuteReport = await executeValidation(validation, false, true);
  assert.equal(noExecuteReport.executed, false);
  assert.equal(noExecuteReport.dry_run, true);

  const blockedValidation: ValidationReport = {
    ...validation,
    blocked: true,
    reason: "blocked",
  };
  const blockedReport = await executeValidation(blockedValidation, true, true);
  assert.equal(blockedReport.executed, false);
  assert.equal(blockedReport.blocked, true);
});

test("planDispatch preserves planner_error when planner fails", async () => {
  const result = await planDispatch({
    catalogPath: fixturePath,
    transcript: "turn off wifi",
    planner: "llama",
    llamaUrl: "http://127.0.0.1:1",
  });

  assert.ok(result.plan.planner_error, "planner_error should be set when planner is unreachable");
  assert.equal(result.plan.chain.length, 0, "chain should remain empty from fast match");
  assert.ok(result.plan.unresolved?.length, "unresolved clauses should still be present");
});

test("fast matcher produces unresolved array for multi-clause with one bad clause", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const result = fastMatch(catalog, "open new tab and turn off wifi");

  assert.ok(result.plan.unresolved?.length, "should have unresolved clauses");
  assert.ok(
    result.plan.unresolved?.some((clause) => clause.includes("wifi")),
    "unresolved should contain the wifi clause",
  );
  assert.equal(result.plan.chain.length, 0, "chain should be empty when any clause is unresolved");
});
