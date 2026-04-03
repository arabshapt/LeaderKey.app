import fs from "node:fs/promises";
import path from "node:path";
import { spawn, type ChildProcess } from "node:child_process";

import type { EditCommand } from "./types.js";
import { GLOBAL_CONFIG_FILE_NAME } from "./constants.js";

export function buildLeaderKeyReloadCommand(): EditCommand {
  return {
    command: "open",
    args: ["-g", "leaderkey://reload-config"],
  };
}

async function rewriteFileWithoutChangingContents(filePath: string): Promise<void> {
  const contents = await fs.readFile(filePath);
  await fs.writeFile(filePath, contents);
}

export async function triggerLeaderKeyConfigReload(
  configDirectory: string,
  spawnProcess: typeof spawn = spawn,
): Promise<void> {
  const globalConfigPath = path.join(configDirectory, GLOBAL_CONFIG_FILE_NAME);
  let rewriteError: unknown;

  try {
    await rewriteFileWithoutChangingContents(globalConfigPath);
  } catch (error) {
    rewriteError = error;
  }

  const command = buildLeaderKeyReloadCommand();
  let urlTriggerError: unknown;

  try {
    await new Promise<void>((resolve, reject) => {
      const child = spawnProcess(command.command, command.args, {
        stdio: "ignore",
      }) as ChildProcess;

      child.once("error", reject);
      child.once("close", (code) => {
        if (code === 0) {
          resolve();
          return;
        }

        reject(new Error(`Leader Key reload trigger exited with code ${code ?? "unknown"}`));
      });
    });
  } catch (error) {
    urlTriggerError = error;
  }

  if (!rewriteError || !urlTriggerError) {
    return;
  }

  throw new Error(
    `Failed to trigger Leader Key reload. file_write=${rewriteError instanceof Error ? rewriteError.message : String(rewriteError)}; url_trigger=${urlTriggerError instanceof Error ? urlTriggerError.message : String(urlTriggerError)}`,
  );
}
