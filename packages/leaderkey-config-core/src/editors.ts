import { spawn, spawnSync } from "node:child_process";

import type { EditCommand, EditorId, EditorTarget } from "./types.js";

const EDITOR_CONFIG = {
  cursor: { appName: "Cursor", launcher: "cursor" },
  intellij: { appName: "IntelliJ IDEA", launcher: "idea" },
  system: { appName: "", launcher: "" },
  vscode: { appName: "Visual Studio Code", launcher: "code" },
  zed: { appName: "Zed", launcher: "zed" },
} as const satisfies Record<EditorId, { appName: string; launcher: string }>;

function commandExists(command: string): boolean {
  if (!command) {
    return false;
  }

  return spawnSync("which", [command], { stdio: "ignore" }).status === 0;
}

export function buildEditorCommand(
  editor: EditorId,
  target: EditorTarget,
  launcherExists: (command: string) => boolean = commandExists,
): EditCommand {
  if (editor === "vscode" || editor === "cursor") {
    const launcher = EDITOR_CONFIG[editor].launcher;
    if (launcherExists(launcher)) {
      return {
        args: ["--goto", `${target.filePath}:${target.line}:${target.column}`],
        command: launcher,
      };
    }

    return {
      args: ["-a", EDITOR_CONFIG[editor].appName, target.filePath],
      command: "open",
    };
  }

  if (editor === "intellij") {
    if (launcherExists("idea")) {
      return {
        args: ["--line", String(target.line), target.filePath],
        command: "idea",
      };
    }

    return {
      args: ["-a", EDITOR_CONFIG.intellij.appName, target.filePath],
      command: "open",
    };
  }

  if (editor === "zed") {
    if (launcherExists("zed")) {
      return {
        args: [`${target.filePath}:${target.line}:${target.column}`],
        command: "zed",
      };
    }

    return {
      args: ["-a", EDITOR_CONFIG.zed.appName, target.filePath],
      command: "open",
    };
  }

  return {
    args: [target.filePath],
    command: "open",
  };
}

export async function openInEditor(editor: EditorId, target: EditorTarget): Promise<void> {
  const command = buildEditorCommand(editor, target);
  await new Promise<void>((resolve, reject) => {
    const child = spawn(command.command, command.args, {
      detached: true,
      stdio: "ignore",
    });
    child.on("error", reject);
    child.unref();
    resolve();
  });
}
