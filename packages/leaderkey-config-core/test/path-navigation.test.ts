import assert from "node:assert/strict";
import test from "node:test";

import { analyzePathInConfig, buildCachePayload, parsePathInput, type GroupNode } from "../src/index.js";
import { createTempConfigDirectory, expectRecord, writeConfigFile } from "./helpers.js";

test("parsePathInput treats every typed character as a path segment", () => {
  assert.deepEqual(parsePathInput("ab.c"), ["a", "b", ".", "c"]);
});

test("analyzePathInConfig treats layers as containers", async () => {
  const configDirectory = await createTempConfigDirectory();

  const globalRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "b",
            type: "shortcut",
            value: "Cb",
          },
        ],
        key: "f",
        label: "Find",
        type: "layer",
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

  const exactLayer = analyzePathInConfig(payload, globalConfig, "f");
  assert.equal(exactLayer.state, "exact-group");
  assert.equal(exactLayer.exactMatch?.kind, "layer");
  assert.deepEqual(exactLayer.visibleChildren.map((record) => record.key), ["b"]);

  const layerChild = analyzePathInConfig(payload, globalConfig, "fb");
  assert.equal(layerChild.state, "exact-action");
  assert.deepEqual(layerChild.exactMatch?.effectiveKeyPath, ["f", "b"]);
});

test("analyzePathInConfig resolves arrow and space aliases in path input", async () => {
  const configDirectory = await createTempConfigDirectory();

  const globalRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: " ",
            type: "toggleStickyMode",
            value: "",
          },
        ],
        key: "←",
        type: "group",
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

  const leftAlias = analyzePathInConfig(payload, globalConfig, "left");
  assert.equal(leftAlias.state, "exact-group");
  assert.deepEqual(leftAlias.typedPath, ["←"]);
  assert.equal(leftAlias.exactMatch?.key, "←");

  const leftSpaceAlias = analyzePathInConfig(payload, globalConfig, "leftspace");
  assert.equal(leftSpaceAlias.state, "exact-action");
  assert.deepEqual(leftSpaceAlias.typedPath, ["←", " "]);
  assert.deepEqual(leftSpaceAlias.exactMatch?.effectiveKeyPath, ["←", " "]);
});

test("analyzePathInConfig still prefers literal character paths when they match more deeply", async () => {
  const configDirectory = await createTempConfigDirectory();

  const globalRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "e",
            type: "shortcut",
            value: "Ce",
          },
        ],
        key: "l",
        type: "group",
      },
      {
        actions: [],
        key: "←",
        type: "group",
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

  const literalPath = analyzePathInConfig(payload, globalConfig, "le");
  assert.equal(literalPath.state, "exact-action");
  assert.deepEqual(literalPath.typedPath, ["l", "e"]);
  assert.equal(literalPath.exactMatch?.keySequence, "l -> e");
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
