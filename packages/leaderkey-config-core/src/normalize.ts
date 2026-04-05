import { discoverLiveConfigs, loadGroupFromFile, writeGroupToFile } from "./discovery.js";
import { generateActionLabel, generateGroupLabel, resolveActionAiDescription, resolveActionDescription } from "./labels.js";
import type { ActionNode, ConfigItem, GroupNode, ItemContext } from "./types.js";

function shouldReplaceGroupLabel(label: string | undefined): boolean {
  const trimmed = label?.trim() ?? "";
  return trimmed.length === 0 || /^(\.+|\d+|group)$/i.test(trimmed);
}

function normalizeItem(item: ConfigItem, context: ItemContext): ConfigItem {
  if (item.type === "group") {
    const nextGroupLabel = generateGroupLabel(item);
    const nextActions = item.actions.map((child, index) =>
      normalizeItem(child, {
        ...context,
        breadcrumbPath: [...context.breadcrumbPath, child.key ?? `#${index}`],
      }));

    return {
      ...item,
      actions: nextActions,
      label: shouldReplaceGroupLabel(item.label) ? nextGroupLabel ?? item.label : item.label,
    };
  }

  const nextAction = item as ActionNode;
  return {
    ...nextAction,
    aiDescription: resolveActionAiDescription(nextAction),
    description: resolveActionDescription(nextAction, context),
    label: generateActionLabel(nextAction, context),
  };
}

export async function normalizeLabelsInConfigDirectory(configDirectory: string): Promise<string[]> {
  const configs = await discoverLiveConfigs(configDirectory);
  const touchedFiles: string[] = [];

  for (const config of configs) {
    const root = await loadGroupFromFile(config.filePath);
    const normalizedRoot = normalizeItem(root, {
      breadcrumbPath: [],
      configDisplayName: config.displayName,
      inherited: false,
    }) as GroupNode;
    await writeGroupToFile(config.filePath, normalizedRoot);
    touchedFiles.push(config.filePath);
  }

  return touchedFiles;
}
