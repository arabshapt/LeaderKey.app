import { Action, ActionPanel, Icon, List } from "@raycast/api";
import {
  isNormalScope,
  parentPathIsInsideLayer,
  type CachePayload,
  type ConfigSummary,
} from "@leaderkey/config-core";

import { RecordEditorForm } from "./editor-form.js";
import { keyPathText } from "./record-formatting.js";

type CreateItemType = "group" | "layer" | "shortcut";

interface TypedPathCreatePickerProps {
  configDirectory: string;
  initialPayload: CachePayload;
  itemType: CreateItemType;
  literalPath: string[];
  onDidSave: (payload: CachePayload) => void;
}

function createTitle(itemType: CreateItemType, pathTitle: string, configDisplayName: string): string {
  const itemLabel = itemType === "group" ? "Group" : itemType === "layer" ? "Layer" : "Action";
  return `Create ${itemLabel} at ${pathTitle} in ${configDisplayName}`;
}

function iconForItemType(itemType: CreateItemType): Icon {
  if (itemType === "group") {
    return Icon.NewFolder;
  }
  if (itemType === "layer") {
    return Icon.Layers;
  }
  return Icon.Plus;
}

function canCreateItemInConfig(
  itemType: CreateItemType,
  config: ConfigSummary,
  payload: CachePayload,
  parentKeyPath: string[],
): boolean {
  return itemType !== "layer"
    || (isNormalScope(config.scope) && !parentPathIsInsideLayer(payload, config.filePath, parentKeyPath));
}

function configSections(
  configs: ConfigSummary[],
  itemType: CreateItemType,
  payload: CachePayload,
  parentKeyPath: string[],
): Array<{ title: string; values: ConfigSummary[] }> {
  return [
    {
      title: "Global And Fallback",
      values: configs.filter((config) =>
        canCreateItemInConfig(itemType, config, payload, parentKeyPath)
        && (config.scope === "global" || config.scope === "fallback" || config.scope === "normalFallback")
      ),
    },
    {
      title: "App Configs",
      values: configs.filter((config) =>
        canCreateItemInConfig(itemType, config, payload, parentKeyPath)
        && (config.scope === "app" || config.scope === "normalApp")
      ),
    },
  ].filter((section) => section.values.length > 0);
}

export function TypedPathCreatePicker(props: TypedPathCreatePickerProps) {
  const { configDirectory, initialPayload, itemType, literalPath, onDidSave } = props;
  const pathTitle = keyPathText(literalPath);
  const parentKeyPath = literalPath.slice(0, -1);
  const suggestedKey = literalPath.at(-1);

  if (!suggestedKey) {
    return (
      <List navigationTitle="Choose Config">
        <List.Item
          id="typed-path-create-empty"
          icon={Icon.ExclamationMark}
          title="Type a path first"
          subtitle="Creation by typed path needs at least one key"
        />
      </List>
    );
  }

  return (
    <List
      navigationTitle={itemType === "group" ? "Create Group by Typed Path" : itemType === "layer" ? "Create Layer by Typed Path" : "Create Action by Typed Path"}
      searchBarPlaceholder={`Choose a config for ${pathTitle}`}
    >
      {configSections(initialPayload.configs, itemType, initialPayload, parentKeyPath).map((section) => (
        <List.Section key={section.title} title={section.title}>
          {section.values.map((config) => (
            <List.Item
              accessories={[{ tag: { value: config.scope } }]}
              icon={config.scope === "app" || config.scope === "normalApp" ? Icon.AppWindow : Icon.Book}
              id={`typed-path-create:${itemType}:${config.filePath}`}
              key={config.filePath}
              subtitle={config.filePath}
              title={config.displayName}
              actions={
                <ActionPanel>
                  <Action.Push
                    icon={iconForItemType(itemType)}
                    shortcut={{ key: "return", modifiers: [] }}
                    target={
                      <RecordEditorForm
                        configDirectory={configDirectory}
                        createAtPath={{
                          configDisplayName: config.displayName,
                          configPath: config.filePath,
                          parentKeyPath,
                          suggestedKey,
                        }}
                        initialType={itemType}
                        mode="create-at-path"
                        onDidSave={async (nextPayload) => {
                          onDidSave(nextPayload);
                        }}
                        title={createTitle(itemType, pathTitle, config.displayName)}
                      />
                    }
                    title={itemType === "group" ? "Create Group in Config" : itemType === "layer" ? "Create Layer in Config" : "Create Action in Config"}
                  />
                </ActionPanel>
              }
            />
          ))}
        </List.Section>
      ))}
    </List>
  );
}
