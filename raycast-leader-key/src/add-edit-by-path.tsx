import {
  Action,
  ActionPanel,
  Icon,
  List,
  Toast,
  environment,
  showToast,
  type LaunchProps,
} from "@raycast/api";
import { type CachePayload, type ConfigSummary, type EditorId } from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { loadIndex } from "./cache.js";
import { CreateAppConfigForm } from "./create-app-config-form.js";
import {
  FRONTMOST_BUNDLE_ID_PLACEHOLDER,
  appBundleIdForConfigTarget,
  buildPathEditorDeeplink,
  resolveConfigTarget,
} from "./deeplinks.js";
import { PathEditorView } from "./path-editor-view.js";
import { getExtensionPreferences } from "./preferences.js";

type AddEditByPathProps = LaunchProps<{
  arguments: {
    configTarget?: string;
    initialPath?: string;
  };
  launchContext?: {
    configTarget?: string;
    initialPath?: string;
  };
}>;

function configTargetFromProps(props: AddEditByPathProps): string | undefined {
  return props.launchContext?.configTarget ?? props.arguments?.configTarget;
}

function initialPathFromProps(props: AddEditByPathProps): string | undefined {
  return props.launchContext?.initialPath ?? props.arguments?.initialPath;
}

function quicklinkName(label: string): string {
  return `Leader Key Path: ${label}`;
}

function openPathEditor(
  config: ConfigSummary,
  configDirectory: string,
  payload: CachePayload,
  setPayload: (payload: CachePayload) => void,
  preferredEditor: EditorId,
  initialPath?: string,
) {
  return (
    <PathEditorView
      configDirectory={configDirectory}
      configSummary={config}
      initialPath={initialPath}
      initialPayload={payload}
      onDidMutate={setPayload}
      preferredEditor={preferredEditor}
    />
  );
}

export default function AddEditByPathCommand(props: AddEditByPathProps) {
  const { configDirectory, preferredEditor } = getExtensionPreferences();
  const [payload, setPayload] = useState<CachePayload>();
  const [isLoading, setIsLoading] = useState(true);
  const [launchTargetErrorShown, setLaunchTargetErrorShown] = useState<string>();
  const requestedTarget = configTargetFromProps(props);
  const initialPath = initialPathFromProps(props);
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;

  useEffect(() => {
    let isMounted = true;

    async function load(): Promise<void> {
      const result = await loadIndex(configDirectory);
      if (!isMounted) {
        return;
      }
      setPayload(result.fresh ?? result.cached);
      setIsLoading(false);
    }

    void load();
    return () => {
      isMounted = false;
    };
  }, [configDirectory]);

  const resolvedLaunchTarget = useMemo(() => {
    if (!payload || !requestedTarget) {
      return undefined;
    }

    return resolveConfigTarget(payload.configs, requestedTarget);
  }, [payload, requestedTarget]);

  const requestedAppBundleId = useMemo(() => appBundleIdForConfigTarget(requestedTarget), [requestedTarget]);
  const needsCreateAppConfig = Boolean(payload && requestedAppBundleId && !resolvedLaunchTarget);
  const currentAppTemplate = buildPathEditorDeeplink(
    `app:${FRONTMOST_BUNDLE_ID_PLACEHOLDER}`,
    ownerOrAuthorName,
    extensionName,
  );

  useEffect(() => {
    if (!payload || !requestedTarget || needsCreateAppConfig) {
      return;
    }

    if (resolvedLaunchTarget || launchTargetErrorShown === requestedTarget) {
      return;
    }

    setLaunchTargetErrorShown(requestedTarget);
    void showToast({
      style: Toast.Style.Failure,
      title: "Config deeplink target not found",
      message: `Could not resolve ${requestedTarget}.`,
    });
  }, [launchTargetErrorShown, needsCreateAppConfig, payload, requestedTarget, resolvedLaunchTarget]);

  if (payload && requestedTarget && resolvedLaunchTarget) {
    return openPathEditor(
      resolvedLaunchTarget,
      configDirectory,
      payload,
      setPayload,
      preferredEditor,
      initialPath,
    );
  }

  if (payload && requestedAppBundleId && needsCreateAppConfig) {
    return (
      <CreateAppConfigForm
        bundleId={requestedAppBundleId}
        configDirectory={configDirectory}
        initialPayload={payload}
        onDidCreate={async (nextPayload) => {
          setPayload(nextPayload);
        }}
      />
    );
  }

  return (
    <List
      isLoading={isLoading}
      searchBarPlaceholder="Choose a config for path editing"
    >
      <List.Section title="Deeplinks">
        <List.Item
          icon={Icon.Link}
          id="current-app-path-template"
          subtitle="Leader Key expands {frontmostBundleId} before Raycast opens"
          title="Current App Path Deeplink Template"
          actions={
            <ActionPanel>
              <Action.CopyToClipboard
                content={currentAppTemplate}
                icon={Icon.Link}
                title="Copy Current App Path Deeplink"
              />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Global And Fallback">
        {(payload?.configs ?? [])
          .filter((config) => config.scope === "global" || config.scope === "fallback")
          .map((config) => {
            const deeplink = buildPathEditorDeeplink(config.scope, ownerOrAuthorName, extensionName);

            return (
              <List.Item
                accessories={[{ tag: { value: config.scope } }]}
                icon={Icon.Book}
                id={config.filePath}
                key={config.filePath}
                subtitle={config.filePath}
                title={config.displayName}
                actions={
                  <ActionPanel>
                    {payload ? (
                      <Action.Push
                        icon={Icon.Pencil}
                        shortcut={{ key: "return", modifiers: [] }}
                        target={openPathEditor(config, configDirectory, payload, setPayload, preferredEditor)}
                        title="Open Path Editor"
                      />
                    ) : null}
                    <Action.CopyToClipboard
                      content={deeplink}
                      icon={Icon.Link}
                      title="Copy Path Editor Deeplink"
                    />
                    <Action.CreateQuicklink
                      quicklink={{
                        link: deeplink,
                        name: quicklinkName(config.displayName),
                      }}
                      title="Create Path Editor Quicklink"
                    />
                  </ActionPanel>
                }
              />
            );
          })}
      </List.Section>

      <List.Section title="App Configs">
        {(payload?.configs ?? [])
          .filter((config) => config.scope === "app")
          .map((config) => {
            const deeplink = buildPathEditorDeeplink(`app:${config.bundleId}`, ownerOrAuthorName, extensionName);

            return (
              <List.Item
                accessories={[{ tag: { value: "app" } }]}
                icon={Icon.AppWindow}
                id={config.filePath}
                key={config.filePath}
                subtitle={config.filePath}
                title={config.displayName}
                actions={
                  <ActionPanel>
                    {payload ? (
                      <Action.Push
                        icon={Icon.Pencil}
                        shortcut={{ key: "return", modifiers: [] }}
                        target={openPathEditor(config, configDirectory, payload, setPayload, preferredEditor)}
                        title="Open Path Editor"
                      />
                    ) : null}
                    <Action.CopyToClipboard
                      content={deeplink}
                      icon={Icon.Link}
                      title="Copy Path Editor Deeplink"
                    />
                    <Action.CreateQuicklink
                      quicklink={{
                        link: deeplink,
                        name: quicklinkName(config.displayName),
                      }}
                      title="Create Path Editor Quicklink"
                    />
                  </ActionPanel>
                }
              />
            );
          })}
      </List.Section>
    </List>
  );
}
