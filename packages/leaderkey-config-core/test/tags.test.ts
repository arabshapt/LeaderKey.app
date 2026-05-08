import assert from "node:assert/strict";
import fs from "node:fs/promises";
import test from "node:test";
import path from "node:path";

import {
  createTag,
  deleteTag,
  ensureTagConfigFile,
  generateTagId,
  loadTagsRegistry,
  moveAssignedTag,
  renameTag,
  tagConfigPath,
  tagReferences,
  updateTagAssignments,
  type GroupNode,
  type TagsRegistry,
} from "../src/index.js";
import { createTempConfigDirectory, readJsonFile, writeTagsRegistry } from "./helpers.js";

test("generates stable slug tag ids with suffixes for collisions", () => {
  const registry: TagsRegistry = {
    assignments: { app: {}, normalApp: {} },
    tags: [
      { id: "browser-tools", name: "Browser Tools" },
      { id: "browser-tools-2", name: "Browser Tools Copy" },
    ],
    version: 1,
  };

  assert.equal(generateTagId(" Browser Tools! ", registry), "browser-tools-3");
  assert.equal(generateTagId("!!!", { assignments: { app: {}, normalApp: {} }, tags: [], version: 1 }), "tag");
});

test("creates, renames, and ensures tag config files without changing ids", async () => {
  const configDirectory = await createTempConfigDirectory();
  const tag = await createTag(configDirectory, { name: "Browser Tools" });

  assert.equal(tag.id, "browser-tools");
  await fs.access(tagConfigPath(configDirectory, tag.id));

  const renamed = await renameTag(configDirectory, tag.id, "Web Browsers");
  assert.equal(renamed.id, "browser-tools");
  assert.equal(renamed.name, "Web Browsers");

  const normalPath = await ensureTagConfigFile(configDirectory, tag.id, true);
  const normalConfig = await readJsonFile<GroupNode>(normalPath);
  assert.deepEqual(normalConfig, { actions: [], type: "group" });
});

test("updates and reorders tag assignments through the registry", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeTagsRegistry(configDirectory, {
    assignments: { app: {}, normalApp: {} },
    tags: [
      { id: "browser", name: "Browser" },
      { id: "web", name: "Web" },
    ],
    version: 1,
  });

  await updateTagAssignments(configDirectory, "app", "com.google.Chrome", ["browser", "web", "browser"]);
  let registry = (await loadTagsRegistry(configDirectory)).registry;
  assert.deepEqual(registry.assignments.app["com.google.Chrome"], ["browser", "web"]);
  assert.deepEqual(tagReferences(registry, "browser"), [
    { bundleId: "com.google.Chrome", index: 0, scope: "app", tagId: "browser" },
  ]);

  await moveAssignedTag(configDirectory, "app", "com.google.Chrome", "web", -1);
  registry = (await loadTagsRegistry(configDirectory)).registry;
  assert.deepEqual(registry.assignments.app["com.google.Chrome"], ["web", "browser"]);

  await updateTagAssignments(configDirectory, "app", "com.google.Chrome", []);
  registry = (await loadTagsRegistry(configDirectory)).registry;
  assert.equal(registry.assignments.app["com.google.Chrome"], undefined);
});

test("blocks assigned tag deletion unless references are removed", async () => {
  const configDirectory = await createTempConfigDirectory();
  await writeTagsRegistry(configDirectory, {
    assignments: {
      app: { "com.google.Chrome": ["browser"] },
      normalApp: { "com.google.Chrome": ["browser"] },
    },
    tags: [{ id: "browser", name: "Browser" }],
    version: 1,
  });
  await ensureTagConfigFile(configDirectory, "browser", false);
  await ensureTagConfigFile(configDirectory, "browser", true);
  await fs.writeFile(path.join(configDirectory, "tag.browser.meta.json"), "{}\n");

  await assert.rejects(deleteTag(configDirectory, "browser"), /assigned to 2 configs/);

  await deleteTag(configDirectory, "browser", { removeAssignments: true });
  const registry = (await loadTagsRegistry(configDirectory)).registry;
  assert.deepEqual(registry.tags, []);
  assert.deepEqual(registry.assignments, { app: {}, normalApp: {} });
  await assert.rejects(fs.access(tagConfigPath(configDirectory, "browser")));
  await assert.rejects(fs.access(tagConfigPath(configDirectory, "browser", true)));
  await assert.rejects(fs.access(path.join(configDirectory, "tag.browser.meta.json")));
});
