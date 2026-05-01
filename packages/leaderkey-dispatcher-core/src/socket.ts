import net from "node:net";

const DEFAULT_SOCKET_PATH = "/tmp/leaderkey.sock";

export async function sendLeaderKeySocketRequest(
  command: string,
  socketPath = DEFAULT_SOCKET_PATH,
  timeoutMs = 1500,
): Promise<string> {
  return await new Promise<string>((resolve, reject) => {
    const client = net.createConnection(socketPath);
    let response = "";
    let settled = false;

    function settle(callback: () => void): void {
      if (settled) {
        return;
      }
      settled = true;
      callback();
    }

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

export async function readFrontmostBundleId(): Promise<string | undefined> {
  const response = await sendLeaderKeySocketRequest("state");
  const parsed = JSON.parse(response) as { bundleId?: string };
  const bundleId = parsed.bundleId?.trim();
  return bundleId || undefined;
}
