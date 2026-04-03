import { Toast, showHUD, showToast } from "@raycast/api";

import { rebuildIndex } from "./cache.js";
import { getExtensionPreferences } from "./preferences.js";

export default async function RebuildIndexCommand() {
  const { configDirectory } = getExtensionPreferences();
  try {
    const payload = await rebuildIndex(configDirectory);
    await showHUD(`Rebuilt Leader Key index (${payload.records.length} records)`);
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to rebuild Leader Key index",
      message: error instanceof Error ? error.message : String(error),
    });
  }
}
