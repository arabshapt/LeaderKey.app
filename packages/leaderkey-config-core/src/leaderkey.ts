import fs from "node:fs/promises";
import path from "node:path";
import { spawn, type ChildProcess } from "node:child_process";
import net from "node:net";

import type { EditCommand } from "./types.js";
import { GLOBAL_CONFIG_FILE_NAME } from "./constants.js";

const LEADERKEY_SOCKET_PATH = "/tmp/leaderkey.sock";

export function buildLeaderKeyReloadCommand(): EditCommand {
  return {
    command: "open",
    args: ["-g", "leaderkey://apply-config"],
  };
}

async function rewriteFileWithoutChangingContents(filePath: string): Promise<void> {
  const contents = await fs.readFile(filePath);
  await fs.writeFile(filePath, contents);
}

async function sendSocketCommand(command: string, socketPath = LEADERKEY_SOCKET_PATH): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const client = net.createConnection(socketPath);
    let response = "";
    let settled = false;

    const settle = (callback: () => void) => {
      if (settled) {
        return;
      }
      settled = true;
      callback();
    };

    client.setEncoding("utf8");
    client.setTimeout(1500);

    client.once("connect", () => {
      client.write(command);
      client.end();
    });

    client.on("data", (chunk) => {
      response += chunk;
    });

    client.once("timeout", () => {
      client.destroy();
      settle(() => reject(new Error(`Timed out waiting for Leader Key socket response at ${socketPath}`)));
    });

    client.once("error", (error) => {
      settle(() => reject(error));
    });

    client.once("close", () => {
      const trimmed = response.trim();
      if (trimmed.startsWith("ERROR")) {
        settle(() => reject(new Error(trimmed)));
        return;
      }
      settle(resolve);
    });
  });
}

export async function triggerLeaderKeyConfigReload(
  configDirectory: string,
  spawnProcess: typeof spawn = spawn,
): Promise<void> {
  let socketError: unknown;

  try {
    await sendSocketCommand("apply-config");
    return;
  } catch (error) {
    socketError = error;
  }

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
    `Failed to trigger Leader Key reload. socket=${socketError instanceof Error ? socketError.message : String(socketError)}; file_write=${rewriteError instanceof Error ? rewriteError.message : String(rewriteError)}; url_trigger=${urlTriggerError instanceof Error ? urlTriggerError.message : String(urlTriggerError)}`,
  );
}
