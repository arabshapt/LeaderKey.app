import { Toast, showHUD, showToast } from "@raycast/api";

import { triggerLeaderKeyGokuProfileSync } from "@leaderkey/config-core";

export default async function SyncGokuProfileCommand() {
  try {
    const response = await triggerLeaderKeyGokuProfileSync();
    await showHUD(response || "Started Goku profile sync");
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to sync Goku profile",
      message: error instanceof Error ? error.message : String(error),
    });
  }
}
