#!/usr/bin/env node

import process from "node:process";

import {
  buildCachePayload,
  defaultConfigDirectory,
  normalizeLabelsInConfigDirectory,
} from "@leaderkey/config-core";

function printUsage(): void {
  process.stdout.write(
    `Leader Key Config CLI

Usage:
  leaderkey-config build-index [--config-dir path]
  leaderkey-config normalize-labels [--config-dir path]
`,
  );
}

function readFlag(flag: string): string | undefined {
  const index = process.argv.indexOf(flag);
  if (index < 0) {
    return undefined;
  }
  return process.argv[index + 1];
}

async function main(): Promise<void> {
  const command = process.argv[2];
  const configDirectory = readFlag("--config-dir") ?? defaultConfigDirectory();

  if (!command || command === "help" || command === "--help" || command === "-h") {
    printUsage();
    return;
  }

  if (command === "build-index") {
    const payload = await buildCachePayload(configDirectory);
    process.stdout.write(`${JSON.stringify(payload, null, 2)}\n`);
    return;
  }

  if (command === "normalize-labels") {
    const touchedFiles = await normalizeLabelsInConfigDirectory(configDirectory);
    process.stdout.write(`${JSON.stringify({ touchedFiles }, null, 2)}\n`);
    return;
  }

  throw new Error(`Unknown command: ${command}`);
}

main().catch((error) => {
  process.stderr.write(`${error instanceof Error ? error.stack ?? error.message : String(error)}\n`);
  process.exitCode = 1;
});
