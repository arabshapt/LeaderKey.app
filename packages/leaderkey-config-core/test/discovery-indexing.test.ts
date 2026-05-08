import assert from "node:assert/strict";
import fs from "node:fs/promises";
import test from "node:test";
import path from "node:path";

import {
  buildCachePayload,
  discoverLiveConfigs,
  searchRecords,
  type GroupNode,
  type LayerNode,
} from "../src/index.js";
import { createTempConfigDirectory, expectRecord, writeConfigFile, writeTagsRegistry } from "./helpers.js";

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

  const normalFallbackRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "s",
            normalModeAfter: "input",
            type: "shortcut",
            value: "Cs",
          },
        ],
        key: "e",
        type: "group",
      },
    ],
    type: "group",
  };

  const normalChromeRoot: GroupNode = {
    actions: [
      {
        actions: [
          {
            key: "b",
            type: "url",
            value: "raycast://extensions/raycast/raycast/search-quicklinks",
          },
        ],
        key: "e",
        type: "group",
      },
    ],
    type: "group",
  };

  await writeConfigFile(configDirectory, "global-config.json", globalRoot);
  await writeConfigFile(configDirectory, "app-fallback-config.json", fallbackRoot);
  await writeConfigFile(configDirectory, "normal-fallback-config.json", normalFallbackRoot);
  await writeConfigFile(configDirectory, "app.com.google.Chrome.json", chromeRoot, {
    customName: "Chrome",
  });
  await writeConfigFile(configDirectory, "normal-app.com.google.Chrome.json", normalChromeRoot, {
    customName: "Chrome Normal",
  });
  await writeConfigFile(configDirectory, "config.json", globalRoot);

  const discovered = await discoverLiveConfigs(configDirectory);
  assert.deepEqual(
    discovered.map((config) => config.displayName),
    ["Global", "Fallback App Config", "Normal Fallback Config", "Chrome", "Chrome Normal"],
  );

  const payload = await buildCachePayload(configDirectory);
  assert.equal(payload.configs.length, 5);

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

  const localNormalChromeRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome Normal" && record.keySequence === "e -> b"),
    "expected local normal Chrome record",
  );
  assert.equal(localNormalChromeRecord.inherited, false);
  assert.equal(localNormalChromeRecord.effectiveScope, "normalApp");
  assert.equal(localNormalChromeRecord.sourceScope, "normalApp");

  const inheritedNormalChromeRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome Normal" && record.keySequence === "e -> s"),
    "expected inherited normal Chrome record",
  );
  assert.equal(inheritedNormalChromeRecord.inherited, true);
  assert.equal(inheritedNormalChromeRecord.effectiveScope, "normalApp");
  assert.equal(inheritedNormalChromeRecord.sourceScope, "normalFallback");
  assert.equal(inheritedNormalChromeRecord.sourceConfigDisplayName, "Normal Fallback Config");
  assert.equal(inheritedNormalChromeRecord.normalModeAfter, "input");
});

test("applies ordered tag assignments without creating empty app configs", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeTagsRegistry(configDirectory, {
    assignments: {
      app: {
        "com.google.Chrome": ["browser", "web"],
      },
      normalApp: {},
    },
    tags: [
      { id: "browser", name: "Browser" },
      { id: "web", name: "Web" },
    ],
    version: 1,
  });

  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "app-fallback-config.json", {
    actions: [
      {
        actions: [
          { key: "d", type: "command", value: "echo fallback duplicate" },
          { key: "f", type: "command", value: "echo fallback only" },
        ],
        key: "w",
        type: "group",
      },
    ],
    type: "group",
  });
  await writeConfigFile(configDirectory, "tag.browser.json", {
    actions: [
      {
        actions: [
          { key: "d", type: "command", value: "echo browser wins" },
          { key: "b", type: "command", value: "echo browser only" },
        ],
        key: "w",
        type: "group",
      },
    ],
    type: "group",
  });
  await writeConfigFile(configDirectory, "tag.web.json", {
    actions: [
      {
        actions: [
          { key: "d", type: "command", value: "echo web shadowed" },
          { key: "x", type: "command", value: "echo web only" },
        ],
        key: "w",
        type: "group",
      },
    ],
    type: "group",
  });

  const payload = await buildCachePayload(configDirectory);
  const chromeSummary = expectRecord(
    payload.configs.find((config) => config.scope === "app" && config.bundleId === "com.google.Chrome"),
    "expected virtual Chrome app config from tag assignment",
  );
  assert.equal(chromeSummary.virtual, true);
  await assert.rejects(fs.stat(path.join(configDirectory, "app.com.google.Chrome.json")));

  const winningRecord = expectRecord(
    payload.records.find((record) =>
      record.effectiveConfigDisplayName === "App: com.google.Chrome" && record.keySequence === "w -> d"
    ),
    "expected winning tag record",
  );
  assert.equal(winningRecord.sourceStatus, "tag");
  assert.equal(winningRecord.sourceTagId, "browser");
  assert.equal(winningRecord.sourcePriority, 1);
  assert.equal(winningRecord.sourceConfigDisplayName, "Tag: Browser");
  assert.deepEqual(
    winningRecord.hiddenSources?.map((source) => source.configDisplayName),
    ["Tag: Web", "Fallback App Config"],
  );

  const lowerTagRecord = expectRecord(
    payload.records.find((record) =>
      record.effectiveConfigDisplayName === "App: com.google.Chrome" && record.keySequence === "w -> x"
    ),
    "expected lower-priority tag item to remain when not shadowed",
  );
  assert.equal(lowerTagRecord.sourceTagId, "web");
  assert.equal(lowerTagRecord.sourcePriority, 2);

  const fallbackRecord = expectRecord(
    payload.records.find((record) =>
      record.effectiveConfigDisplayName === "App: com.google.Chrome" && record.keySequence === "w -> f"
    ),
    "expected fallback item below tags",
  );
  assert.equal(fallbackRecord.sourceStatus, "fallback");

  assert.ok(
    payload.diagnostics.some((diagnostic) =>
      diagnostic.kind === "shadowedSource" &&
      diagnostic.keySequence === "w -> d" &&
      diagnostic.message.includes("Tag: Browser overrides Tag: Web")
    ),
    "expected aggregate shadow diagnostic for tag collision",
  );
});

test("applies tag assignments even when fallback config is missing", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeTagsRegistry(configDirectory, {
    assignments: {
      app: {
        "com.google.Chrome": ["browser"],
      },
      normalApp: {},
    },
    tags: [{ id: "browser", name: "Browser" }],
    version: 1,
  });
  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "tag.browser.json", {
    actions: [{ key: "b", type: "command", value: "echo browser" }],
    type: "group",
  });

  const payload = await buildCachePayload(configDirectory);
  const tagRecord = expectRecord(
    payload.records.find((record) =>
      record.effectiveConfigDisplayName === "App: com.google.Chrome" && record.keySequence === "b"
    ),
    "expected tag record without fallback config",
  );
  assert.equal(tagRecord.sourceStatus, "tag");
  assert.equal(tagRecord.sourceTagId, "browser");
});

test("indexes normal tag assignments separately from regular tags", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeTagsRegistry(configDirectory, {
    assignments: {
      app: {},
      normalApp: {
        "com.google.Chrome": ["browser"],
      },
    },
    tags: [{ id: "browser", name: "Browser" }],
    version: 1,
  });

  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "normal-fallback-config.json", {
    actions: [
      {
        actions: [{ key: "f", type: "shortcut", value: "Cf" }],
        key: "e",
        type: "group",
      },
    ],
    type: "group",
  });
  await writeConfigFile(configDirectory, "normal-tag.browser.json", {
    actions: [
      {
        actions: [{ key: "s", normalModeAfter: "input", type: "shortcut", value: "Cs" }],
        key: "e",
        type: "group",
      },
    ],
    type: "group",
  });

  const payload = await buildCachePayload(configDirectory);
  const normalChromeSummary = expectRecord(
    payload.configs.find((config) => config.scope === "normalApp" && config.bundleId === "com.google.Chrome"),
    "expected virtual normal Chrome app config from tag assignment",
  );
  assert.equal(normalChromeSummary.virtual, true);

  const tagRecord = expectRecord(
    payload.records.find((record) =>
      record.effectiveConfigDisplayName === "Normal: com.google.Chrome" && record.keySequence === "e -> s"
    ),
    "expected inherited normal tag record",
  );
  assert.equal(tagRecord.effectiveScope, "normalApp");
  assert.equal(tagRecord.sourceScope, "normalTag");
  assert.equal(tagRecord.sourceStatus, "tag");
  assert.equal(tagRecord.sourceTagId, "browser");
  assert.equal(tagRecord.normalModeAfter, "input");

  const fallbackRecord = expectRecord(
    payload.records.find((record) =>
      record.effectiveConfigDisplayName === "Normal: com.google.Chrome" && record.keySequence === "e -> f"
    ),
    "expected normal fallback below normal tag",
  );
  assert.equal(fallbackRecord.sourceScope, "normalFallback");
});

test("warns when assignments reference missing tag definitions or config files", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeTagsRegistry(configDirectory, {
    assignments: {
      app: {
        "com.google.Chrome": ["missing"],
      },
      normalApp: {},
    },
    tags: [],
    version: 1,
  });

  await writeConfigFile(configDirectory, "global-config.json", { actions: [], type: "group" });
  await writeConfigFile(configDirectory, "app-fallback-config.json", { actions: [], type: "group" });

  const payload = await buildCachePayload(configDirectory);
  assert.ok(
    payload.diagnostics.some((diagnostic) =>
      diagnostic.kind === "missingTagDefinition" && diagnostic.tagId === "missing"
    ),
    "expected missing tag definition warning",
  );
  assert.ok(
    payload.diagnostics.some((diagnostic) =>
      diagnostic.kind === "missingTagConfig" && diagnostic.tagId === "missing"
    ),
    "expected missing tag config warning",
  );
});

test("indexes layers as group-like containers and merges normal fallback layer children", async () => {
  const configDirectory = await createTempConfigDirectory();
  const tapAction = {
    normalModeAfter: "normal" as const,
    type: "shortcut" as const,
    value: "Cf",
  };
  const fallbackLayer: LayerNode = {
    actions: [
      {
        key: "b",
        type: "shortcut",
        value: "Cb",
      },
    ],
    key: "f",
    label: "Find",
    tapAction,
    type: "layer",
  };
  const appLayer: LayerNode = {
    actions: [
      {
        key: "x",
        type: "command",
        value: "echo local",
      },
    ],
    key: "f",
    label: "Find",
    tapAction,
    type: "layer",
  };

  await writeConfigFile(configDirectory, "normal-fallback-config.json", {
    actions: [fallbackLayer],
    type: "group",
  });
  await writeConfigFile(configDirectory, "normal-app.com.google.Chrome.json", {
    actions: [appLayer],
    type: "group",
  }, {
    customName: "Chrome Normal",
  });

  const payload = await buildCachePayload(configDirectory);
  const layerRecord = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome Normal" && record.keySequence === "f"),
    "expected merged layer record",
  );
  assert.equal(layerRecord.kind, "layer");
  assert.equal(layerRecord.actionType, "layer");
  assert.equal(layerRecord.childCount, 2);
  assert.equal(layerRecord.tapAction?.type, "shortcut");

  const localChild = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome Normal" && record.keySequence === "f -> x"),
    "expected local layer child",
  );
  assert.equal(localChild.inherited, false);
  assert.equal(localChild.sourceScope, "normalApp");

  const inheritedChild = expectRecord(
    payload.records.find((record) => record.effectiveConfigDisplayName === "Chrome Normal" && record.keySequence === "f -> b"),
    "expected inherited layer child",
  );
  assert.equal(inheritedChild.inherited, true);
  assert.equal(inheritedChild.sourceScope, "normalFallback");
});
