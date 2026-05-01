import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  buildActionCatalog,
  fastMatch,
  retrieveActions,
  validateDispatchPlan,
  type DispatchPlan,
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
