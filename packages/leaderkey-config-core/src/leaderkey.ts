import net from "node:net";

const LEADERKEY_SOCKET_PATH = "/tmp/leaderkey.sock";
const DEFAULT_SOCKET_TIMEOUT_MS = 1500;
const MENU_ITEMS_SOCKET_TIMEOUT_MS = 10000;

export interface LeaderKeyMenuItem {
  appName: string;
  enabled: boolean;
  path: string;
  title: string;
}

async function sendSocketRequest(
  command: string,
  socketPath = LEADERKEY_SOCKET_PATH,
  timeoutMs = DEFAULT_SOCKET_TIMEOUT_MS,
): Promise<string> {
  return await new Promise<string>((resolve, reject) => {
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
    client.setTimeout(timeoutMs);

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
      settle(() => resolve(trimmed));
    });
  });
}

export async function triggerLeaderKeyConfigReload(
  _configDirectory: string,
): Promise<void> {
  try {
    await sendSocketRequest("apply-config");
    return;
  } catch (error) {
    throw new Error(
      `Failed to trigger Leader Key reload through local IPC: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

export async function triggerLeaderKeyGokuProfileSync(): Promise<string> {
  try {
    return await sendSocketRequest("sync-goku-profile");
  } catch (error) {
    throw new Error(
      `Failed to trigger Leader Key Goku profile sync through local IPC: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

export async function listLeaderKeyMenuItems(appName: string): Promise<LeaderKeyMenuItem[]> {
  try {
    const response = await sendSocketRequest(
      `menu-items ${JSON.stringify({ app: appName })}`,
      LEADERKEY_SOCKET_PATH,
      MENU_ITEMS_SOCKET_TIMEOUT_MS,
    );
    const parsed = JSON.parse(response) as { items?: LeaderKeyMenuItem[] };
    return Array.isArray(parsed.items) ? parsed.items : [];
  } catch (error) {
    throw new Error(
      `Failed to query live menu items from Leader Key: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

export async function openLeaderKeyCommandScout(payload: {
  bundleId?: string;
  appName?: string;
  configKey?: string;
  source?: "raycast";
}): Promise<void> {
  const bundleId = payload.bundleId ?? payload.configKey ?? "";
  if (!bundleId) {
    throw new Error("Command Scout requires a bundleId or configKey");
  }
  try {
    await sendSocketRequest(
      `command-scout open ${JSON.stringify({ bundleId, source: payload.source ?? "raycast" })}`,
    );
  } catch (error) {
    throw new Error(
      `Failed to open Command Scout: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}
