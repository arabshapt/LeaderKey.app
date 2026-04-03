import assert from "node:assert/strict";
import test from "node:test";
import path from "node:path";

import {
  appendChildToGroup,
  buildCachePayload,
  createItemAtPath,
  insertSiblingAfter,
  type GroupNode,
  updateRecord,
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
      key: "d",
      label: "Duplicate Tab Here",
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
