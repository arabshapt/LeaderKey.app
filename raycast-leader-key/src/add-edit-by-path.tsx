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

import { CreateAppConfigForm } from "./create-app-config-form.js";
import {
  FRONTMOST_BUNDLE_ID_PLACEHOLDER,
  appBundleIdForConfigTarget,
  buildPathEditorDeeplink,
  configTargetForSummary,
  normalAppBundleIdForConfigTarget,
  resolveConfigTarget,
} from "./deeplinks.js";
import { PathEditorView } from "./path-editor-view.js";
import { getExtensionPreferences } from "./preferences.js";
import { keyPathText } from "./record-formatting.js";
import { TypedPathCreatePicker } from "./typed-path-create-picker.js";
import { useIndexPayload } from "./use-index-payload.js";

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

function matchesConfigSearch(config: ConfigSummary, query: string): boolean {
  const trimmed = query.trim().toLowerCase();
  if (!trimmed) {
    return true;
  }

  return [
    config.displayName,
    config.filePath,
    config.scope,
    config.bundleId,
  ]
    .filter(Boolean)
    .some((value) => value!.toLowerCase().includes(trimmed));
}

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
  const requestedTarget = configTargetFromProps(props);
  const [searchText, setSearchText] = useState("");
  const { payload, setPayload, isInitialLoading, isRefreshing, loadError, loadingSubtitle, reload } = useIndexPayload(configDirectory, {
    // Raycast can visually stick in an empty state if this command mounts a
    // loading list first and only swaps to real config rows after async cache I/O.
    seedFromDisk: true,
    showRefreshingIndicator: false,
  });
  const [launchTargetErrorShown, setLaunchTargetErrorShown] = useState<string>();
  const initialPath = initialPathFromProps(props);
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;

  const resolvedLaunchTarget = useMemo(() => {
    if (!payload || !requestedTarget) {
      return undefined;
    }

    return resolveConfigTarget(payload.configs, requestedTarget);
  }, [payload, requestedTarget]);

  const requestedAppBundleId = useMemo(() => appBundleIdForConfigTarget(requestedTarget), [requestedTarget]);
  const requestedNormalAppBundleId = useMemo(() => normalAppBundleIdForConfigTarget(requestedTarget), [requestedTarget]);
  const missingRequestedBundleId = requestedAppBundleId ?? requestedNormalAppBundleId;
  const needsCreateAppConfig = Boolean(payload && missingRequestedBundleId && !resolvedLaunchTarget);
  const currentAppTemplate = buildPathEditorDeeplink(
    `app:${FRONTMOST_BUNDLE_ID_PLACEHOLDER}`,
    ownerOrAuthorName,
    extensionName,
  );
  const currentNormalAppTemplate = buildPathEditorDeeplink(
    `normal-app:${FRONTMOST_BUNDLE_ID_PLACEHOLDER}`,
    ownerOrAuthorName,
    extensionName,
  );
  const literalTypedPath = Array.from(searchText.trim());
  const typedPathTitle = literalTypedPath.length > 0 ? keyPathText(literalTypedPath) : undefined;
  const visibleConfigs = payload?.configs.filter((config) => matchesConfigSearch(config, searchText)) ?? [];

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

  if (payload && missingRequestedBundleId && needsCreateAppConfig) {
    return (
      <CreateAppConfigForm
        bundleId={missingRequestedBundleId}
        configDirectory={configDirectory}
        initialPayload={payload}
        normalMode={Boolean(requestedNormalAppBundleId)}
        onDidCreate={async (nextPayload) => {
          setPayload(nextPayload);
        }}
      />
    );
  }

  if (!payload) {
    if (loadError) {
      return (
        <List
          key={`error:${configDirectory}:${requestedTarget ?? "root"}`}
          searchBarPlaceholder="Choose a config for path editing"
        >
          <List.Item
            id="path-editor-index-load-error"
            icon={Icon.ExclamationMark}
            title="Couldn’t load Leader Key configs"
            subtitle={loadError}
            actions={
              <ActionPanel>
                <Action
                  icon={Icon.ArrowClockwise}
                  onAction={reload}
                  title="Retry Loading Index"
                />
              </ActionPanel>
            }
          />
        </List>
      );
    }

    return (
      <List
        key={`loading:${configDirectory}:${requestedTarget ?? "root"}`}
        isLoading={isInitialLoading}
        searchBarPlaceholder="Choose a config for path editing"
      >
        <List.Item
          id="loading-path-editor-configs"
          title="Loading configs…"
          subtitle={loadingSubtitle}
        />
      </List>
    );
  }

  return (
    <List
      filtering={false}
      key={`ready:${payload.fingerprint}:${requestedTarget ?? "root"}`}
      isLoading={isRefreshing}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Choose a config for path editing"
    >
      {typedPathTitle ? (
        <List.Section title="Create by Typed Path">
          <List.Item
            icon={Icon.Plus}
            id="typed-path:create-action"
            title={`Create Action at ${typedPathTitle}`}
            subtitle={`Treat "${searchText.trim()}" as literal keys`}
            actions={
              <ActionPanel>
                <Action.Push
                  icon={Icon.Plus}
                  shortcut={{ modifiers: ["cmd"], key: "n" }}
                  target={
                    <TypedPathCreatePicker
                      configDirectory={configDirectory}
                      initialPayload={payload}
                      itemType="shortcut"
                      literalPath={literalTypedPath}
                      onDidSave={setPayload}
                    />
                  }
                  title="Choose Config for Action"
                />
              </ActionPanel>
            }
          />
          <List.Item
            icon={Icon.NewFolder}
            id="typed-path:create-group"
            title={`Create Group at ${typedPathTitle}`}
            subtitle={`Treat "${searchText.trim()}" as literal keys`}
            actions={
              <ActionPanel>
                <Action.Push
                  icon={Icon.NewFolder}
                  shortcut={{ modifiers: ["cmd", "shift"], key: "n" }}
                  target={
                    <TypedPathCreatePicker
                      configDirectory={configDirectory}
                      initialPayload={payload}
                      itemType="group"
                      literalPath={literalTypedPath}
                      onDidSave={setPayload}
                    />
                  }
                  title="Choose Config for Group"
                />
              </ActionPanel>
            }
          />
        </List.Section>
      ) : null}
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
        <List.Item
          icon={Icon.Link}
          id="current-normal-app-path-template"
          subtitle="Leader Key expands {frontmostBundleId} before Raycast opens"
          title="Current App Normal Path Deeplink Template"
          actions={
            <ActionPanel>
              <Action.CopyToClipboard
                content={currentNormalAppTemplate}
                icon={Icon.Link}
                title="Copy Current App Normal Path Deeplink"
              />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Global And Fallback">
        {payload.configs
          .filter((config) => (
            config.scope === "global" ||
            config.scope === "fallback" ||
            config.scope === "normalFallback"
          ) && visibleConfigs.includes(config))
          .map((config) => {
            const deeplink = buildPathEditorDeeplink(
              configTargetForSummary(config),
              ownerOrAuthorName,
              extensionName,
            );

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
                    <Action.Push
                      icon={Icon.Pencil}
                      shortcut={{ key: "return", modifiers: [] }}
                      target={openPathEditor(config, configDirectory, payload, setPayload, preferredEditor)}
                      title="Open Path Editor"
                    />
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
        {payload.configs
          .filter((config) => (config.scope === "app" || config.scope === "normalApp") && visibleConfigs.includes(config))
          .map((config) => {
            const deeplink = buildPathEditorDeeplink(
              config.scope === "normalApp" ? `normal-app:${config.bundleId}` : `app:${config.bundleId}`,
              ownerOrAuthorName,
              extensionName,
            );

            return (
              <List.Item
                accessories={[{ tag: { value: config.scope === "normalApp" ? "normal" : "app" } }]}
                icon={Icon.AppWindow}
                id={config.filePath}
                key={config.filePath}
                subtitle={config.filePath}
                title={config.displayName}
                actions={
                  <ActionPanel>
                    <Action.Push
                      icon={Icon.Pencil}
                      shortcut={{ key: "return", modifiers: [] }}
                      target={openPathEditor(config, configDirectory, payload, setPayload, preferredEditor)}
                      title="Open Path Editor"
                    />
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
