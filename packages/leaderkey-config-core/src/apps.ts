import type { Dirent } from "node:fs";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

import { basenameWithoutApp, uniqueBy } from "./utils.js";

export interface InstalledApp {
  bundlePath: string;
  name: string;
}

const APP_SCAN_DIRECTORIES = [
  "/Applications",
  "/System/Applications",
  "/System/Applications/Utilities",
  path.join(os.homedir(), "Applications"),
];

async function walkApps(directory: string, depth: number, result: InstalledApp[]): Promise<void> {
  if (depth < 0) {
    return;
  }

  let entries: Dirent[];
  try {
    entries = await fs.readdir(directory, { withFileTypes: true });
  } catch {
    return;
  }

  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory() && entry.name.endsWith(".app")) {
      result.push({
        bundlePath: fullPath,
        name: basenameWithoutApp(fullPath),
      });
      continue;
    }

    if (entry.isDirectory()) {
      await walkApps(fullPath, depth - 1, result);
    }
  }
}

export async function findInstalledApps(): Promise<InstalledApp[]> {
  const foundApps: InstalledApp[] = [];
  for (const directory of APP_SCAN_DIRECTORIES) {
    await walkApps(directory, 2, foundApps);
  }

  return uniqueBy(foundApps, (app) => `${app.name}:${app.bundlePath}`).sort((left, right) =>
    left.name.localeCompare(right.name),
  );
}
