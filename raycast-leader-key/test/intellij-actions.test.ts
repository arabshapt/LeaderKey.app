import assert from "node:assert/strict";
import test from "node:test";

import {
  clearIntelliJActionListCacheForTests,
  estimateIntelliJChainDelayMs,
  humanizeIntelliJActionId,
  intellijActionClassName,
  intellijActionSearchQueries,
  searchIntelliJActions,
  scoreIntelliJActionMatch,
} from "../src/intellij-actions.js";

test("IntelliJ action search uses compact fallback queries", () => {
  assert.deepEqual(intellijActionSearchQueries("nxanything"), ["nxanything", "nx"]);
});

test("IntelliJ action fuzzy matching handles compact CamelCase gaps", () => {
  assert.notEqual(
    scoreIntelliJActionMatch("nxanything", "dev.nx.console.run.actions.NxRunAnythingAction"),
    undefined,
  );
});

test("IntelliJ action display derives readable names from action IDs", () => {
  assert.equal(intellijActionClassName("dev.nx.console.run.actions.NxRunAnythingAction"), "NxRunAnythingAction");
  assert.equal(humanizeIntelliJActionId("dev.nx.console.run.actions.NxRunAnythingAction"), "Nx Run Anything");
});

test("IntelliJ timing estimates distinguish last-action delay from chain delay", () => {
  assert.equal(estimateIntelliJChainDelayMs({ category: "async", smartDelay: 0 }), 500);
  assert.equal(estimateIntelliJChainDelayMs({ category: "instant", smartDelay: 0 }), 0);
});

test("IntelliJ action search fuzzes against the full action list", async () => {
  clearIntelliJActionListCacheForTests();
  const originalFetch = globalThis.fetch;
  const requests: string[] = [];

  globalThis.fetch = async (input) => {
    const url = String(input);
    requests.push(url);

    if (url.endsWith("/list")) {
      return new Response(JSON.stringify({
        actions: [
          "SaveAll",
          "dev.nx.console.run.actions.NxRunAnythingAction",
        ],
      }));
    }

    return new Response(JSON.stringify({ actions: [] }));
  };

  try {
    assert.deepEqual(await searchIntelliJActions("nxanything"), [
      "dev.nx.console.run.actions.NxRunAnythingAction",
    ]);
    assert.ok(requests.some((url) => url.endsWith("/list")));
  } finally {
    globalThis.fetch = originalFetch;
    clearIntelliJActionListCacheForTests();
  }
});
