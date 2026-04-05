import assert from "node:assert/strict";
import test from "node:test";

import { shouldRefreshIndex } from "../src/index-refresh.js";

test("shouldRefreshIndex requests a refresh when there is no cached payload", () => {
  assert.equal(shouldRefreshIndex(undefined, "fingerprint"), true);
});

test("shouldRefreshIndex skips refresh when fingerprints match", () => {
  assert.equal(shouldRefreshIndex({ fingerprint: "fingerprint" }, "fingerprint"), false);
});

test("shouldRefreshIndex refreshes when fingerprints differ", () => {
  assert.equal(shouldRefreshIndex({ fingerprint: "stale" }, "fresh"), true);
});

test("shouldRefreshIndex honors forceRefresh even when fingerprints match", () => {
  assert.equal(shouldRefreshIndex({ fingerprint: "fingerprint" }, "fingerprint", true), true);
});
