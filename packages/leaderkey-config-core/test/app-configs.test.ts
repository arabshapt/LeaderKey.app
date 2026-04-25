import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";

import {
  EMPTY_APP_CONFIG_TEMPLATE,
  createAppConfig,
  discoverLiveConfigs,
  type GroupNode,
} from "../src/index.js";
import { createTempConfigDirectory, readJsonFile, writeConfigFile } from "./helpers.js";

test("creates an empty app config with optional custom name", async () => {
  const configDirectory = await createTempConfigDirectory();

  const created = await createAppConfig(configDirectory, {
    bundleId: "com.apple.dt.Xcode",
    customName: "Xcode",
    template: { kind: "empty" },
  });

  assert.deepEqual(created, {
    bundleId: "com.apple.dt.Xcode",
    displayName: "Xcode",
    filePath: path.join(configDirectory, "app.com.apple.dt.Xcode.json"),
    scope: "app",
  });

  const group = await readJsonFile<GroupNode>(created.filePath);
  assert.deepEqual(group, { actions: [], type: "group" });

  const meta = await readJsonFile<{ customName?: string }>(created.filePath.replace(/\.json$/i, ".meta.json"));
  assert.equal(meta.customName, "Xcode");
});

test("creates an app config from an existing template file", async () => {
  const configDirectory = await createTempConfigDirectory();

  const templateRoot: GroupNode = {
    actions: [
      {
        key: "a",
        type: "shortcut",
        value: "Ct",
      },
    ],
    type: "group",
  };

  const templatePath = await writeConfigFile(configDirectory, "global-config.json", templateRoot);
  await writeConfigFile(configDirectory, "app-fallback-config.json", { actions: [], type: "group" });

  const created = await createAppConfig(configDirectory, {
    bundleId: "com.google.Chrome",
    template: { filePath: templatePath, kind: "config" },
  });

  const group = await readJsonFile<GroupNode>(created.filePath);
  assert.deepEqual(group, templateRoot);

  const discovered = await discoverLiveConfigs(configDirectory);
  assert.equal(discovered.find((config) => config.bundleId === "com.google.Chrome")?.displayName, "App: com.google.Chrome");
});

test("creates a normal-mode app config with normal scope and file name", async () => {
  const configDirectory = await createTempConfigDirectory();

  const created = await createAppConfig(configDirectory, {
    bundleId: "com.google.Chrome",
    normalMode: true,
    template: { kind: "empty" },
  });

  assert.deepEqual(created, {
    bundleId: "com.google.Chrome",
    displayName: "Normal: com.google.Chrome",
    filePath: path.join(configDirectory, "normal-app.com.google.Chrome.json"),
    scope: "normalApp",
  });

  const group = await readJsonFile<GroupNode>(created.filePath);
  assert.deepEqual(group, { actions: [], type: "group" });

  const discovered = await discoverLiveConfigs(configDirectory);
  assert.equal(discovered.find((config) => config.scope === "normalApp")?.displayName, "Normal: com.google.Chrome");
});

test("EMPTY_APP_CONFIG_TEMPLATE matches the native empty-template sentinel", () => {
  assert.equal(EMPTY_APP_CONFIG_TEMPLATE, "EMPTY_TEMPLATE");
});
