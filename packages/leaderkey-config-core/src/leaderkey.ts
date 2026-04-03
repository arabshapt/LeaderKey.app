import net from "node:net";

const LEADERKEY_SOCKET_PATH = "/tmp/leaderkey.sock";

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
  _configDirectory: string,
): Promise<void> {
  try {
    await sendSocketCommand("apply-config");
    return;
  } catch (error) {
    throw new Error(
      `Failed to trigger Leader Key reload through local IPC: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}
