import assert from "node:assert/strict";
import test from "node:test";

import { analyzePathInConfig, buildCachePayload, parsePathInput, type GroupNode } from "../src/index.js";
import { createTempConfigDirectory, expectRecord, writeConfigFile } from "./helpers.js";

test("parsePathInput treats every typed character as a path segment", () => {
  assert.deepEqual(parsePathInput("ab.c"), ["a", "b", ".", "c"]);
});

test("analyzePathInConfig resolves exact groups, exact actions, missing tails, and terminal action collisions", async () => {
  const configDirectory = await createTempConfigDirectory();

  const globalRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            actions: [
              {
                key: "c",
                type: "shortcut",
                value: "Ct",
              },
            ],
            key: ".",
            type: "group",
          },
        ],
        key: "a",
        type: "group",
      },
      {
        key: "x",
        type: "shortcut",
        value: "Cx",
      },
    ],
    type: "group",
  };

  await writeConfigFile(configDirectory, "global-config.json", globalRoot);
  const payload = await buildCachePayload(configDirectory);
  const globalConfig = expectRecord(
    payload.configs.find((config) => config.scope === "global"),
    "expected global config summary",
  );

  const rootAnalysis = analyzePathInConfig(payload, globalConfig, "");
  assert.equal(rootAnalysis.state, "root");
  assert.deepEqual(rootAnalysis.visibleChildren.map((record) => record.key), ["a", "x"]);

  const exactGroup = analyzePathInConfig(payload, globalConfig, "a");
  assert.equal(exactGroup.state, "exact-group");
  assert.equal(exactGroup.exactMatch?.kind, "group");
  assert.deepEqual(exactGroup.visibleChildren.map((record) => record.key), ["."]);

  const exactAction = analyzePathInConfig(payload, globalConfig, "x");
  assert.equal(exactAction.state, "exact-action");
  assert.equal(exactAction.exactMatch?.kind, "action");
  assert.deepEqual(exactAction.deepestExistingGroupPath, []);

  const missingTail = analyzePathInConfig(payload, globalConfig, "ab.c");
  assert.equal(missingTail.state, "missing");
  assert.deepEqual(missingTail.deepestExistingGroupPath, ["a"]);
  assert.deepEqual(missingTail.missingSegments, ["b", ".", "c"]);
  assert.deepEqual(missingTail.autoCreateGroupKeys, ["b", "."]);
  assert.deepEqual(missingTail.createParentKeyPath, ["a", "b", "."]);

  const blocked = analyzePathInConfig(payload, globalConfig, "xy");
  assert.equal(blocked.state, "blocked");
  assert.equal(blocked.terminalAction?.keySequence, "x");
  assert.deepEqual(blocked.blockedRemainingPath, ["y"]);
  assert.deepEqual(blocked.visibleChildren.map((record) => record.key), ["a", "x"]);
});
