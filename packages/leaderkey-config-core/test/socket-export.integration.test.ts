import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import test from "node:test";

import { triggerLeaderKeyConfigReload } from "../src/index.js";

const execFileAsync = promisify(execFile);
const APP_DEFAULTS_DOMAIN = "com.brnbw.Leader-Key";

async function readDefault(key: string): Promise<string | undefined> {
  try {
    const { stdout } = await execFileAsync("/usr/bin/defaults", ["read", APP_DEFAULTS_DOMAIN, key]);
    const value = stdout.trim();
    return value.length > 0 ? value : undefined;
  } catch {
    return undefined;
  }
}

async function writeDefault(key: string, value: string): Promise<void> {
  await execFileAsync("/usr/bin/defaults", ["write", APP_DEFAULTS_DOMAIN, key, value]);
}

async function deleteDefault(key: string): Promise<void> {
  try {
    await execFileAsync("/usr/bin/defaults", ["delete", APP_DEFAULTS_DOMAIN, key]);
  } catch {
    // Missing defaults are fine during cleanup.
  }
}

async function waitForFileContaining(filePath: string, marker: string): Promise<string> {
  const deadline = Date.now() + 10_000;
  let lastError: unknown;

  while (Date.now() < deadline) {
    try {
      const text = await fs.readFile(filePath, "utf8");
      if (text.includes(marker)) {
        return text;
      }
    } catch (error) {
      lastError = error;
    }
    await new Promise((resolve) => setTimeout(resolve, 250));
  }

  throw new Error(`Timed out waiting for ${filePath} to contain ${marker}: ${lastError instanceof Error ? lastError.message : String(lastError)}`);
}

test(
  "socket apply-config exports a tag-assigned virtual app action",
  { skip: process.env.LEADERKEY_SOCKET_EXPORT_TEST === "1" ? false : "Set LEADERKEY_SOCKET_EXPORT_TEST=1 to run live socket export integration." },
  async (t) => {
    if (process.env.LEADERKEY_SOCKET_EXPORT_MUTATE_DEFAULTS !== "1") {
      t.skip("Set LEADERKEY_SOCKET_EXPORT_MUTATE_DEFAULTS=1 to allow temporary defaults configDir changes.");
      return;
    }

    const tempDirectory = await fs.mkdtemp(path.join(os.tmpdir(), "leaderkey-socket-export-"));
    const marker = `leaderkey-tag-socket-export-${Date.now()}`;
    const bundleId = "com.example.LeaderKeyTagSocketExport";
    const previousConfigDir = await readDefault("configDir");
    const configuredRulesPath = process.env.LEADERKEY_SOCKET_EXPORT_RULES_PATH;
    const repoPath = configuredRulesPath ? undefined : await readDefault("karabinerTsRepoPath");
    const rulesPath = configuredRulesPath ?? (repoPath ? path.join(repoPath, "configs/leaderkey/leaderkey-generated.json") : undefined);

    if (!rulesPath) {
      t.skip("Set LEADERKEY_SOCKET_EXPORT_RULES_PATH or configure karabinerTsRepoPath in Leader Key defaults.");
      return;
    }

    try {
      await fs.writeFile(
        path.join(tempDirectory, "global-config.json"),
        `${JSON.stringify({ actions: [], type: "group" }, null, 2)}\n`,
      );
      await fs.writeFile(
        path.join(tempDirectory, "tags-registry.json"),
        `${JSON.stringify({
          assignments: { app: { [bundleId]: ["browser"] }, normalApp: {} },
          tags: [{ id: "browser", name: "Browser" }],
          version: 1,
        }, null, 2)}\n`,
      );
      await fs.writeFile(
        path.join(tempDirectory, "tag.browser.json"),
        `${JSON.stringify({
          actions: [
            {
              key: "t",
              label: "Socket Export Tag Action",
              type: "command",
              value: `echo ${marker}`,
            },
          ],
          type: "group",
        }, null, 2)}\n`,
      );

      await writeDefault("configDir", tempDirectory);
      await triggerLeaderKeyConfigReload(tempDirectory);

      const exportedRules = await waitForFileContaining(rulesPath, marker);
      assert.match(exportedRules, new RegExp(bundleId.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
      assert.match(exportedRules, new RegExp(marker));
    } finally {
      if (previousConfigDir) {
        await writeDefault("configDir", previousConfigDir);
      } else {
        await deleteDefault("configDir");
      }
      await fs.rm(tempDirectory, { force: true, recursive: true });
    }
  },
);

