import { getPreferenceValues } from "@raycast/api";
import { defaultConfigDirectory, type EditorId } from "@leaderkey/config-core";

interface ExtensionPreferences {
  configDirectory?: string;
  preferredEditor?: EditorId;
}

export function getExtensionPreferences(): { configDirectory: string; preferredEditor: EditorId } {
  const preferences = getPreferenceValues<ExtensionPreferences>();
  return {
    configDirectory: preferences.configDirectory?.trim() || defaultConfigDirectory(),
    preferredEditor: preferences.preferredEditor ?? "system",
  };
}

