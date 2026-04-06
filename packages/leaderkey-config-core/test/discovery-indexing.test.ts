import assert from "node:assert/strict";
import test from "node:test";
import path from "node:path";

import {
  buildCachePayload,
  discoverLiveConfigs,
  searchRecords,
  type GroupNode,
} from "../src/index.js";
import { createTempConfigDirectory, expectRecord, writeConfigFile } from "./helpers.js";

test("discovers live configs, respects custom names, and indexes merged fallback items", async () => {
  const configDirectory = await createTempConfigDirectory();

  const globalRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "a",
            type: "application",
            value: "/Applications/Arc.app",
          },
        ],
        key: "o",
        type: "group",
      },
    ],
    type: "group",
  };

  const fallbackRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "d",
            menuFallbackPaths: ["Tab > Clone Tab", "Window > Duplicate Tab"],
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

  await writeConfigFile(configDirectory, "global-config.json", globalRoot);
  await writeConfigFile(configDirectory, "app-fallback-config.json", fallbackRoot);
  await writeConfigFile(configDirectory, "app.com.google.Chrome.json", chromeRoot, {
    customName: "Chrome",
  });
  await writeConfigFile(configDirectory, "config.json", globalRoot);

  const discovered = await discoverLiveConfigs(configDirectory);
  assert.deepEqual(
    discovered.map((config) => config.displayName),
    ["Global", "Fallback App Config", "Chrome"],
  );

  const payload = await buildCachePayload(configDirectory);
  assert.equal(payload.configs.length, 3);

  const localChromeRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome" && record.keySequence === "w -> n"),
    "expected local Chrome record",
  );
  assert.equal(localChromeRecord.inherited, false);
  assert.equal(localChromeRecord.sourceConfigDisplayName, "Chrome");
  assert.equal(localChromeRecord.sourceConfigPath, path.join(configDirectory, "app.com.google.Chrome.json"));

  const inheritedChromeRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome" && record.keySequence === "w -> d"),
    "expected inherited Chrome record",
  );
  assert.equal(inheritedChromeRecord.inherited, true);
  assert.equal(inheritedChromeRecord.sourceConfigDisplayName, "Fallback App Config");
  assert.deepEqual(inheritedChromeRecord.sourceNodePath, [0, 0]);
  assert.deepEqual(inheritedChromeRecord.menuFallbackPaths, ["Tab > Clone Tab", "Window > Duplicate Tab"]);
  assert.match(inheritedChromeRecord.searchText, /clone tab/);

  const searchResult = expectRecord(
    searchRecords(payload.records, "clone tab").find((record) => record.id === inheritedChromeRecord.id),
    "expected fallback menu query to find inherited record",
  );
  assert.equal(searchResult.displayLabel, "Tab → Duplicate Tab");
});
