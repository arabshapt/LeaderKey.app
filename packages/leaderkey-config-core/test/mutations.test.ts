import assert from "node:assert/strict";
import test from "node:test";
import path from "node:path";

import {
  appendChildToGroup,
  buildCachePayload,
  createItemAtPath,
  insertSiblingAfter,
  type GroupNode,
  type LayerNode,
  updateRecord,
  updateRecordAtPath,
  validateConfigItem,
  validateRecordPath,
  validateSiblingKeyInPayload,
} from "../src/index.js";
import { createTempConfigDirectory, expectRecord, readJsonFile, writeConfigFile } from "./helpers.js";

test("creates app overrides for inherited items and preserves insertion order for local edits", async () => {
  const configDirectory = await createTempConfigDirectory();

  const fallbackRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "d",
            type: "menu",
            value: "Google Chrome > Tab > Duplicate Tab",
          },
        ],
        key: "w",
        type: "group",
      },
    ],
    type: "group",
  };

  const chromeRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "n",
            type: "shortcut",
            value: "Ct",
          },
        ],
        key: "w",
        type: "group",
      },
    ],
    type: "group",
  };

  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "app-fallback-config.json", fallbackRoot);
  const chromePath = await writeConfigFile(configDirectory, "app.com.google.Chrome.json", chromeRoot, {
    customName: "Chrome",
  });

  let payload = await buildCachePayload(configDirectory);
  const inheritedRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome" && record.keySequence === "w -> d"),
    "expected inherited record",
  );

  await updateRecord(
    inheritedRecord,
    {
      description: "Duplicate tab here",
      key: "d",
      type: "menu",
      value: "Google Chrome > Tab > Duplicate Tab",
    },
    "override-in-effective-config",
  );

  payload = await buildCachePayload(configDirectory);
  const overriddenRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome" && record.keySequence === "w -> d"),
    "expected overridden record",
  );
  assert.equal(overriddenRecord.inherited, false);
  assert.equal(overriddenRecord.sourceConfigDisplayName, "Chrome");

  const localRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome" && record.keySequence === "w -> n"),
    "expected local record",
  );

  await insertSiblingAfter(localRecord, {
    key: "p",
    type: "shortcut",
    value: "Cp",
  });

  const groupRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome" && record.kind === "group" && record.keySequence === "w"),
    "expected local group record",
  );

  await appendChildToGroup(groupRecord, {
    key: "x",
    type: "url",
    value: "raycast://confetti",
  });

  const savedChromeRoot = await readJsonFile<GroupNode>(chromePath);
  const chromeWindowGroup = savedChromeRoot.actions[0] as GroupNode;
  assert.deepEqual(
    chromeWindowGroup.actions.map((item) => item.key),
    ["n", "p", "d", "x"],
  );
});

test("createItemAtPath auto-creates missing intermediate groups before appending the final item", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });

  await createItemAtPath(globalPath, ["a", "b", "."], {
    key: "c",
    type: "shortcut",
    value: "Ct",
  });

  const savedGlobalRoot = await readJsonFile<GroupNode>(globalPath);
  const groupA = savedGlobalRoot.actions[0] as GroupNode;
  const groupB = groupA.actions[0] as GroupNode;
  const groupDot = groupB.actions[0] as GroupNode;
  const child = groupDot.actions[0];

  assert.equal(groupA.key, "a");
  assert.equal(groupB.key, "b");
  assert.equal(groupDot.key, ".");
  assert.equal(child?.key, "c");
});

test("createItemAtPath preserves a literal spacebar key", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });

  await createItemAtPath(globalPath, ["s"], {
    key: " ",
    type: "toggleStickyMode",
    value: "",
  });

  const savedGlobalRoot = await readJsonFile<GroupNode>(globalPath);
  const groupS = savedGlobalRoot.actions[0] as GroupNode;
  const child = groupS.actions[0];

  assert.equal(groupS.key, "s");
  assert.equal(child?.key, " ");
  assert.equal(child?.type, "toggleStickyMode");
});

test("updateRecordAtPath moves an action within the same config and auto-creates destination parents", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        actions: [
          {
            key: "c",
            type: "shortcut",
            value: "Ct",
          },
        ],
        key: "a",
        type: "group",
      },
    ],
    type: "group",
  });

  let payload = await buildCachePayload(configDirectory);
  const record = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "a -> c" && candidate.kind === "action"),
    "expected source action",
  );

  await updateRecordAtPath(record, {
    key: "c",
    type: "shortcut",
    value: "Ct",
  }, ["x", "y"]);

  payload = await buildCachePayload(configDirectory);
  assert.equal(payload.records.some((candidate) => candidate.keySequence === "a -> c"), false);
  assert.equal(payload.records.some((candidate) => candidate.keySequence === "x -> y"), true);

  const savedRoot = await readJsonFile<GroupNode>(globalPath);
  assert.equal((savedRoot.actions[0] as GroupNode).key, "a");
  const groupX = savedRoot.actions[1] as GroupNode;
  assert.equal(groupX.key, "x");
  assert.equal(groupX.actions[0]?.key, "y");
});

test("updateRecordAtPath preserves a literal spacebar destination key", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        key: "s",
        type: "toggleStickyMode",
        value: "",
      },
    ],
    type: "group",
  });

  let payload = await buildCachePayload(configDirectory);
  const record = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "s" && candidate.kind === "action"),
    "expected source action",
  );

  await updateRecordAtPath(record, {
    key: "s",
    type: "toggleStickyMode",
    value: "",
  }, [" "]);

  payload = await buildCachePayload(configDirectory);
  assert.equal(payload.records.some((candidate) => candidate.keySequence === "s"), false);
  assert.equal(payload.records.some((candidate) => candidate.effectiveKeyPath[0] === " "), true);

  const savedRoot = await readJsonFile<GroupNode>(globalPath);
  assert.equal(savedRoot.actions[0]?.key, " ");
  assert.equal(savedRoot.actions[0]?.type, "toggleStickyMode");
});

test("updateRecordAtPath moves a group and preserves its children", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        actions: [
          {
            key: "b",
            type: "shortcut",
            value: "Cb",
          },
        ],
        key: "a",
        type: "group",
      },
    ],
    type: "group",
  });

  let payload = await buildCachePayload(configDirectory);
  const groupRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "a" && candidate.kind === "group"),
    "expected source group",
  );

  await updateRecordAtPath(groupRecord, {
    actions: [
      {
        key: "b",
        type: "shortcut",
        value: "Cb",
      },
    ],
    key: "a",
    type: "group",
  }, ["x", "g"]);

  payload = await buildCachePayload(configDirectory);
  assert.equal(payload.records.some((candidate) => candidate.keySequence === "a"), false);
  assert.equal(payload.records.some((candidate) => candidate.keySequence === "x -> g"), true);
  assert.equal(payload.records.some((candidate) => candidate.keySequence === "x -> g -> b"), true);
});

test("validateRecordPath rejects exact local collisions, blocked descendants, and descendant moves", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        actions: [
          {
            key: "b",
            type: "shortcut",
            value: "Cb",
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
  });

  const payload = await buildCachePayload(configDirectory);
  const groupRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "a" && candidate.kind === "group"),
    "expected source group",
  );

  const exactCollision = validateRecordPath(payload, {
    configFilePath: globalPath,
    destinationKeyPath: ["a", "b"],
  });
  assert.equal(exactCollision.error, "An item already exists at a -> b.");

  const blocked = validateRecordPath(payload, {
    configFilePath: globalPath,
    destinationKeyPath: ["x", "y"],
  });
  assert.equal(blocked.error, "Action Shortcut: Cmd+X blocks descendants under x.");

  const descendantMove = validateRecordPath(payload, {
    configFilePath: globalPath,
    currentRecord: groupRecord,
    destinationKeyPath: ["a", "c"],
  });
  assert.equal(descendantMove.error, "A container cannot be moved into its own descendant path.");
});

test("appendChildToGroup and createItemAtPath treat existing layers as containers", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        actions: [],
        key: "f",
        label: "Find",
        type: "layer",
      },
    ],
    type: "group",
  });

  let payload = await buildCachePayload(configDirectory);
  const layerRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "f" && candidate.kind === "layer"),
    "expected source layer",
  );

  await appendChildToGroup(layerRecord, {
    key: "b",
    type: "shortcut",
    value: "Cb",
  });
  await createItemAtPath(globalPath, ["f", "g"], {
    key: "x",
    type: "command",
    value: "echo nested",
  });

  const savedRoot = await readJsonFile<GroupNode>(globalPath);
  const layer = savedRoot.actions[0] as LayerNode;
  const group = layer.actions[1] as GroupNode;

  assert.equal(layer.type, "layer");
  assert.equal(layer.actions[0]?.key, "b");
  assert.equal(group.type, "group");
  assert.equal(group.key, "g");
  assert.equal(group.actions[0]?.key, "x");
});

test("mutation helpers reject duplicate sibling keys across actions groups and layers", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "normal-fallback-config.json", {
    actions: [
      {
        key: "f",
        type: "shortcut",
        value: "Cf",
      },
      {
        actions: [],
        key: "g",
        type: "group",
      },
    ],
    type: "group",
  });

  const payload = await buildCachePayload(configDirectory);
  const actionRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "f" && candidate.kind === "action"),
    "expected action record",
  );
  const groupRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "g" && candidate.kind === "group"),
    "expected group record",
  );

  await assert.rejects(
    insertSiblingAfter(actionRecord, {
      actions: [],
      key: "g",
      type: "layer",
    }),
    /already exists/,
  );

  assert.equal(
    validateSiblingKeyInPayload(payload, {
      configFilePath: actionRecord.effectiveConfigPath,
      key: "f",
      parentKeyPath: actionRecord.parentEffectiveKeyPath,
    }),
    "An item with key 'f' already exists at this path.",
  );

  await assert.rejects(
    insertSiblingAfter(groupRecord, {
      key: "f",
      type: "command",
      value: "echo duplicate",
    }),
    /already exists/,
  );
});

test("mutation helpers reject duplicate children and nested layers inside layers", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "normal-fallback-config.json", {
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
        type: "layer",
      },
    ],
    type: "group",
  });

  const payload = await buildCachePayload(configDirectory);
  const layerRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "f" && candidate.kind === "layer"),
    "expected layer record",
  );

  await assert.rejects(
    appendChildToGroup(layerRecord, {
      key: "b",
      type: "command",
      value: "echo duplicate",
    }),
    /already exists/,
  );

  await assert.rejects(
    appendChildToGroup(layerRecord, {
      actions: [],
      key: "l",
      type: "layer",
    }),
    /Nested layers are not supported/,
  );
});

test("normal app overrides materialize inherited fallback layers as layers", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "normal-fallback-config.json", {
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
        type: "layer",
      },
    ],
    type: "group",
  });
  const normalAppPath = await writeConfigFile(configDirectory, "normal-app.com.google.Chrome.json", {
    actions: [],
    type: "group",
  }, {
    customName: "Chrome Normal",
  });

  const payload = await buildCachePayload(configDirectory);
  const inheritedLayerRecord = expectRecord(
    payload.records.find((candidate) =>
      candidate.effectiveConfigPath === normalAppPath &&
      candidate.inherited &&
      candidate.keySequence === "f" &&
      candidate.kind === "layer"
    ),
    "expected inherited normal app layer",
  );
  const inheritedChildRecord = expectRecord(
    payload.records.find((candidate) =>
      candidate.effectiveConfigPath === normalAppPath &&
      candidate.inherited &&
      candidate.keySequence === "f -> b" &&
      candidate.kind === "action"
    ),
    "expected inherited normal app layer child",
  );

  await appendChildToGroup(inheritedLayerRecord, {
    key: "x",
    type: "command",
    value: "echo child",
  });
  await insertSiblingAfter(inheritedChildRecord, {
    key: "c",
    type: "shortcut",
    value: "Cc",
  });

  const savedRoot = await readJsonFile<GroupNode>(normalAppPath);
  const layer = savedRoot.actions[0] as LayerNode;

  assert.equal(layer.type, "layer");
  assert.equal(layer.key, "f");
  assert.deepEqual(layer.actions.map((item) => item.key), ["x", "c"]);
});

test("config item validation rejects layer scope and recursive action value errors", () => {
  assert.equal(
    validateConfigItem({
      key: "right_command",
      type: "shortcut",
      value: "Ct",
    }),
    undefined,
  );

  assert.equal(
    validateConfigItem({
      key: "not_a_key",
      type: "shortcut",
      value: "Ct",
    }),
    "Key must resolve to exactly one key.",
  );

  assert.equal(
    validateConfigItem({
      actions: [],
      key: "f",
      type: "layer",
    }, { scope: "global" }),
    "Layers are only supported in normal-mode configs.",
  );

  assert.equal(
    validateConfigItem({
      actions: [],
      key: "f",
      type: "layer",
    }, { parentInsideLayer: true, scope: "normalFallback" }),
    "Nested layers are not supported.",
  );

  assert.equal(
    validateConfigItem({
      actions: [],
      key: "caps_lock",
      type: "layer",
    }, { scope: "normalFallback" }),
    "Modifier keys cannot be used as normal-mode layer triggers.",
  );

  assert.match(
    validateConfigItem({
      actions: [],
      key: "f",
      tapAction: {
        type: "shortcut",
        value: "",
      },
      type: "layer",
    }, { scope: "normalFallback" }) ?? "",
    /Tap action/,
  );

  assert.match(
    validateConfigItem({
      key: "m",
      macroSteps: [
        {
          action: {
            type: "command",
            value: "",
          },
          delay: 0,
          enabled: true,
        },
      ],
      type: "macro",
      value: "",
    }, { scope: "normalFallback" }) ?? "",
    /Step 1/,
  );
});

test("validateRecordPath allows local overrides of inherited fallback content in app configs", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  const fallbackPath = await writeConfigFile(configDirectory, "app-fallback-config.json", {
    actions: [
      {
        actions: [
          {
            key: "d",
            type: "menu",
            value: "Google Chrome > Tab > Duplicate Tab",
          },
        ],
        key: "w",
        type: "group",
      },
    ],
    type: "group",
  });
  const chromePath = await writeConfigFile(configDirectory, "app.com.google.Chrome.json", {
    actions: [],
    type: "group",
  }, {
    customName: "Chrome",
  });

  const payload = await buildCachePayload(configDirectory);
  const validation = validateRecordPath(payload, {
    configFilePath: chromePath,
    destinationKeyPath: ["w", "d"],
  });

  assert.equal(validation.error, undefined);
  assert.deepEqual(validation.autoCreateGroupKeys, ["w"]);
  assert.equal(validation.overrideRecord?.sourceConfigPath, fallbackPath);
});

test("updateRecordAtPath preserves explicit action descriptions while labels stay automatic", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        description: "Close tab hard",
        key: "x",
        type: "shortcut",
        value: "Cx",
      },
    ],
    type: "group",
  });

  let payload = await buildCachePayload(configDirectory);
  const record = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "x" && candidate.kind === "action"),
    "expected source action",
  );

  await updateRecordAtPath(record, {
    description: "Paste over the current selection",
    key: "x",
    type: "shortcut",
    value: "Cv",
  }, ["x"]);

  payload = await buildCachePayload(configDirectory);
  const updatedRecord = expectRecord(
    payload.records.find((candidate) => candidate.keySequence === "x" && candidate.kind === "action"),
    "expected updated action",
  );

  assert.equal(updatedRecord.displayLabel, "Shortcut: Cmd+V");
  assert.equal(updatedRecord.description, "Paste over the current selection");
});
