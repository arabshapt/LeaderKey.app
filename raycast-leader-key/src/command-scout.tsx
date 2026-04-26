import { Action, ActionPanel, Icon, List, Toast, showHUD, showToast } from "@raycast/api";
import type { CachePayload, ConfigSummary } from "@leaderkey/config-core";
import { openLeaderKeyCommandScout } from "@leaderkey/config-core";

import { getExtensionPreferences } from "./preferences.js";
import { SHORTCUTS } from "./shortcuts.js";
import { useIndexPayload } from "./use-index-payload.js";

function appConfigs(payload: CachePayload | undefined): ConfigSummary[] {
  if (!payload) return [];
  return payload.configs.filter((c) => c.scope === "app" && c.bundleId);
}

export default function CommandScoutCommand() {
  const { configDirectory } = getExtensionPreferences();
  const { payload, isInitialLoading } = useIndexPayload(configDirectory);
  const configs = appConfigs(payload);

  async function openScout(config: ConfigSummary) {
    try {
      await openLeaderKeyCommandScout({
        bundleId: config.bundleId!,
        appName: config.displayName,
        source: "raycast",
      });
      await showHUD(`Opened Command Scout for ${config.displayName}`);
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Failed to open Command Scout",
        message: error instanceof Error ? error.message : String(error),
      });
    }
  }

  return (
    <List isLoading={isInitialLoading} searchBarPlaceholder="Pick an app config for Command Scout...">
      {configs.map((config) => (
        <List.Item
          key={config.filePath}
          title={config.displayName}
          subtitle={config.bundleId ?? ""}
          icon={Icon.MagnifyingGlass}
          actions={
            <ActionPanel>
              <Action shortcut={SHORTCUTS.openCommandScout} title="Open Command Scout" icon={Icon.MagnifyingGlass} onAction={() => openScout(config)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
