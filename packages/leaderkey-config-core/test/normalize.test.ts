import assert from "node:assert/strict";
import test from "node:test";

import { normalizeLabelsInConfigDirectory, type GroupNode } from "../src/index.js";
import { createTempConfigDirectory, readJsonFile, writeConfigFile } from "./helpers.js";

test("normalizeLabelsInConfigDirectory migrates legacy custom action labels into descriptions", async () => {
  const configDirectory = await createTempConfigDirectory();
  const globalPath = await writeConfigFile(configDirectory, "global-config.json", {
    actions: [
      {
        key: "x",
        label: "Shortcut: Cmd+X - Close Tab Hard",
        type: "shortcut",
        value: "Cx",
      },
      {
        key: "t",
        type: "shortcut",
        value: "Ct",
      },
    ],
    type: "group",
  });

  await normalizeLabelsInConfigDirectory(configDirectory);

  const savedRoot = await readJsonFile<GroupNode>(globalPath);
  assert.equal(savedRoot.actions[0]?.label, "Shortcut: Cmd+X");
  assert.equal(savedRoot.actions[0]?.description, "Shortcut: Cmd+X - Close Tab Hard");
  assert.equal(savedRoot.actions[1]?.label, "Shortcut: Cmd+T");
  assert.equal(savedRoot.actions[1]?.description, undefined);
});
