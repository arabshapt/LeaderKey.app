import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  buildActionCatalog,
  executeValidation,
  fastMatch,
  GeminiPlanner,
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

async function writeConfigFile(
  dir: string,
  fileName: string,
  value: unknown,
  metadata?: Record<string, unknown>,
): Promise<void> {
  const filePath = path.join(dir, fileName);
  await fs.writeFile(filePath, JSON.stringify(value, null, 2));
  if (metadata) {
    await fs.writeFile(filePath.replace(/\.json$/i, ".meta.json"), JSON.stringify(metadata, null, 2));
  }
}

async function writeTempAppScopeConfig(): Promise<string> {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "leaderkey-dispatcher-config-"));
  await writeConfigFile(dir, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(dir, "normal-fallback-config.json", { actions: [], type: "group" });
  await writeConfigFile(dir, "app-fallback-config.json", {
    actions: [
      {
        actions: [
          {
            key: "i",
            label: "IntelliJ IDEA",
            type: "application",
            value: "/Applications/IntelliJ IDEA.app",
          },
        ],
        key: "o",
        label: "Open",
        type: "group",
      },
    ],
    type: "group",
  });
  await writeConfigFile(dir, "app.com.jetbrains.intellij.json", {
    actions: [
      {
        actions: [
          {
            key: "t",
            label: "New Terminal",
            type: "intellij",
            value: "ActivateTerminalToolWindow",
          },
          {
            key: "s",
            label: "Settings",
            type: "menu",
            value: "IntelliJ IDEA > Settings...",
          },
        ],
        key: "g",
        label: "Go",
        type: "group",
      },
    ],
    type: "group",
  }, {
    customName: "IntelliJ IDEA",
  });
  return dir;
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

test("layout intent plans apps side-by-side deterministically", async () => {
  const result = await planDispatch({
    catalogPath: fixturePath,
    transcript: "Open Activity Monitor and Chrome side-by-side",
  });

  assert.equal(result.plan.mode, "fast_match");
  assert.equal(result.plan.reason, "layout_side_by_side");
  assert.deepEqual(result.plan.chain.map((step) => step.action_id), [
    "app_activity_monitor",
    "window_left_half",
    "app_google_chrome",
    "window_right_half",
  ]);
  assert.equal(result.validation.valid, true);
});

test("layout intent handles explicit left and right wording", async () => {
  const result = await planDispatch({
    catalogPath: fixturePath,
    transcript: "tile Activity Monitor left and Chrome right",
  });

  assert.deepEqual(result.plan.chain.map((step) => step.action_id), [
    "app_activity_monitor",
    "window_left_half",
    "app_google_chrome",
    "window_right_half",
  ]);
});

test("layout intent handles named app swap wording", async () => {
  const result = await planDispatch({
    catalogPath: fixturePath,
    transcript: "swap Chrome and Activity Monitor with their position side by side",
  });

  assert.equal(result.plan.reason, "layout_swap_side_by_side");
  assert.deepEqual(result.plan.chain.map((step) => step.action_id), [
    "app_google_chrome",
    "window_left_half",
    "app_activity_monitor",
    "window_right_half",
  ]);
});

test("layout intent resolves swap references from recent context", async () => {
  const result = await planDispatch({
    catalogPath: fixturePath,
    context: {
      currentApp: {
        bundleId: "com.google.Chrome",
        localizedName: "Google Chrome",
      },
      recentCommands: [{
        action_ids: ["app_activity_monitor", "window_left_half", "app_google_chrome", "window_right_half"],
        labels: ["Activity Monitor", "Raycast: Left Half", "Google Chrome", "Raycast: Right Half"],
        plan_reason: "layout_side_by_side",
        transcript: "Open Activity Monitor and Chrome side-by-side",
        types: ["application", "url", "application", "url"],
      }],
    },
    transcript: "swap them",
  });

  assert.equal(result.plan.reason, "layout_swap_side_by_side");
  assert.deepEqual(result.plan.chain.map((step) => step.action_id), [
    "app_google_chrome",
    "window_left_half",
    "app_activity_monitor",
    "window_right_half",
  ]);
});

test("app scoped chain resolves follow-up action against opened app config", async () => {
  const configDirectory = await writeTempAppScopeConfig();
  const result = await planDispatch({
    bundleId: "com.google.Chrome",
    configDirectory,
    transcript: "open intellij and then open a new terminal in it",
  });

  assert.equal(result.plan.reason, "app_scoped_chain");
  assert.deepEqual(result.validation.steps.map((step) => step.action.type), ["application", "intellij"]);
  assert.equal(result.validation.steps[0]?.action.label, "IntelliJ IDEA");
  assert.match(result.validation.steps[1]?.action.label ?? "", /Terminal/);
  assert.equal(result.validation.steps[1]?.action.bundleId, "com.jetbrains.intellij");
});

test("app scoped chain can infer target app from a single explicit clause", async () => {
  const configDirectory = await writeTempAppScopeConfig();
  const result = await planDispatch({
    bundleId: "com.google.Chrome",
    configDirectory,
    transcript: "go to settings in intellij",
  });

  assert.equal(result.plan.reason, "app_scoped_chain");
  assert.deepEqual(result.validation.steps.map((step) => step.action.type), ["application", "menu"]);
  assert.equal(result.validation.steps[0]?.action.label, "IntelliJ IDEA");
  assert.match(result.validation.steps[1]?.action.label ?? "", /Settings/);
  assert.equal(result.validation.steps[1]?.action.bundleId, "com.jetbrains.intellij");
});

test("retriever and matcher understand window half aliases", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });

  assert.equal(retrieveActions(catalog, "move window left", 1)[0]?.action.id, "window_left_half");
  assert.equal(retrieveActions(catalog, "move window right", 1)[0]?.action.id, "window_right_half");
  assert.equal(fastMatch(catalog, "snap window left").plan.chain[0]?.action_id, "window_left_half");
  assert.equal(fastMatch(catalog, "tile window right").plan.chain[0]?.action_id, "window_right_half");
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

test("validator blocks catalog IDs outside retrieved candidates", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const candidate = retrieveActions(catalog, "new tab", 1)[0]!;
  const plan: DispatchPlan = {
    chain: [{ action_id: "tab_close", confidence: 0.99 }],
    mode: "llm_planner",
    needs_confirmation: false,
    overall_confidence: 0.99,
    reason: "outside candidates",
  };

  const validation = validateDispatchPlan(catalog, plan, {
    candidatesByClause: [[candidate]],
  });

  assert.equal(validation.blocked, true);
  assert.match(validation.reason, /not in retrieved candidates/);
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

test("Gemini planner uses OpenAI-compatible endpoint and candidate-only prompt", async () => {
  const catalog = await buildActionCatalog({ catalogPath: fixturePath });
  const candidate = retrieveActions(catalog, "new tab", 1)[0]!;
  const originalFetch = globalThis.fetch;
  let requestBody: Record<string, unknown> | undefined;
  let requestUrl = "";
  let authorization = "";

  globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
    requestUrl = String(input);
    requestBody = JSON.parse(String(init?.body ?? "{}")) as Record<string, unknown>;
    authorization = new Headers(init?.headers).get("authorization") ?? "";
    return new Response(JSON.stringify({
      choices: [{
        message: {
          content: JSON.stringify({
            chain: [{ action_id: candidate.action.id, confidence: 0.96 }],
            mode: "llm_planner",
            needs_confirmation: false,
            overall_confidence: 0.96,
            reason: "gemini test",
          }),
        },
      }],
    }), { status: 200 });
  }) as typeof fetch;

  try {
    const planner = new GeminiPlanner({ apiKey: "test-key", model: "gemini-2.5-flash" });
    const plan = await planner.plan("open a new tab", [[candidate]]);

    assert.equal(requestUrl, "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions");
    assert.equal(authorization, "Bearer test-key");
    assert.equal(requestBody?.model, "gemini-2.5-flash");
    assert.equal(plan.chain[0]?.action_id, candidate.action.id);
    const messages = requestBody?.messages as Array<{ content: string }>;
    assert.match(messages[1]?.content ?? "", new RegExp(candidate.action.id));
    assert.doesNotMatch(messages[1]?.content ?? "", /tab_close/);
  } finally {
    globalThis.fetch = originalFetch;
  }
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
