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

import { ConfigNodesList } from "./browser.js";
import { CreateAppConfigForm } from "./create-app-config-form.js";
import {
  FRONTMOST_BUNDLE_ID_PLACEHOLDER,
  appBundleIdForConfigTarget,
  buildBrowseConfigsDeeplink,
  buildPathEditorDeeplink,
  configTargetForSummary,
  resolveConfigTarget,
} from "./deeplinks.js";
import { PathEditorView } from "./path-editor-view.js";
import { getExtensionPreferences } from "./preferences.js";
import { keyPathText } from "./record-formatting.js";
import { TypedPathCreatePicker } from "./typed-path-create-picker.js";
import { useIndexPayload } from "./use-index-payload.js";

type BrowseConfigsProps = LaunchProps<{
  arguments: {
    configTarget?: string;
  };
  launchContext?: {
    configTarget?: string;
  };
}>;

function quicklinkName(label: string): string {
  return `Leader Key: ${label}`;
}

function pathEditorQuicklinkName(label: string): string {
  return `Leader Key Path: ${label}`;
}

function configTargetFromProps(props: BrowseConfigsProps): string | undefined {
  return props.launchContext?.configTarget ?? props.arguments?.configTarget;
}

function openConfigTarget(
  config: ConfigSummary,
  configDirectory: string,
  payload: CachePayload,
  setPayload: (payload: CachePayload) => void,
  preferredEditor: EditorId,
) {
  return (
    <ConfigNodesList
      configDirectory={configDirectory}
      configDisplayName={config.displayName}
      initialPayload={payload}
      onDidMutate={setPayload}
      preferredEditor={preferredEditor}
    />
  );
}

function openPathEditor(
  config: ConfigSummary,
  configDirectory: string,
  payload: CachePayload,
  setPayload: (payload: CachePayload) => void,
  preferredEditor: EditorId,
) {
  return (
    <PathEditorView
      configDirectory={configDirectory}
      configSummary={config}
      initialPayload={payload}
      onDidMutate={setPayload}
      preferredEditor={preferredEditor}
    />
  );
}

export default function BrowseConfigsCommand(props: BrowseConfigsProps) {
  const { configDirectory, preferredEditor } = getExtensionPreferences();
  const requestedTarget = configTargetFromProps(props);
  const { payload, setPayload, isInitialLoading, isRefreshing, loadError, loadingSubtitle, reload } = useIndexPayload(configDirectory, {
    seedFromDisk: Boolean(requestedTarget),
    showRefreshingIndicator: !requestedTarget,
  });
  const [launchTargetErrorShown, setLaunchTargetErrorShown] = useState<string>();
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;

  const resolvedLaunchTarget = useMemo(() => {
    if (!payload || !requestedTarget) {
      return undefined;
    }

    return resolveConfigTarget(payload.configs, requestedTarget);
  }, [payload, requestedTarget]);

  const requestedAppBundleId = useMemo(() => appBundleIdForConfigTarget(requestedTarget), [requestedTarget]);
  const needsCreateAppConfig = Boolean(payload && requestedAppBundleId && !resolvedLaunchTarget);
  const currentAppDeeplinkTemplate = buildBrowseConfigsDeeplink(
    `app:${FRONTMOST_BUNDLE_ID_PLACEHOLDER}`,
    ownerOrAuthorName,
    extensionName,
  );
  const [searchText, setSearchText] = useState("");
  const literalTypedPath = Array.from(searchText.trim());
  const typedPathTitle = literalTypedPath.length > 0 ? keyPathText(literalTypedPath) : undefined;

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
    return openConfigTarget(resolvedLaunchTarget, configDirectory, payload, setPayload, preferredEditor);
  }

  if (payload && requestedAppBundleId && needsCreateAppConfig) {
    return (
      <CreateAppConfigForm
        bundleId={requestedAppBundleId}
        configDirectory={configDirectory}
        initialPayload={payload}
        onDidCreate={setPayload}
      />
    );
  }

  if (!payload) {
    if (loadError) {
      return (
        <List
          key={`error:${configDirectory}:${requestedTarget ?? "root"}`}
          searchBarPlaceholder="Browse Leader Key configs"
        >
          <List.Item
            id="configs-index-load-error"
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
        searchBarPlaceholder="Browse Leader Key configs"
      >
        <List.Item
          id="loading-configs"
          title="Loading configs…"
          subtitle={loadingSubtitle}
        />
      </List>
    );
  }

  return (
    <List
      key={`ready:${payload.fingerprint}:${requestedTarget ?? "root"}`}
      isLoading={isRefreshing}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Browse Leader Key configs"
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
          id="current-app-config-template"
          subtitle="Leader Key expands {frontmostBundleId} before Raycast opens"
          title="Current App Config Deeplink Template"
          actions={
            <ActionPanel>
              <Action.CopyToClipboard
                content={currentAppDeeplinkTemplate}
                icon={Icon.Link}
                title="Copy Current App Config Deeplink"
              />
            </ActionPanel>
          }
        />
      </List.Section>

      <List.Section title="Configs">
        {payload.configs.map((config) => {
          const deeplink = buildBrowseConfigsDeeplink(
            configTargetForSummary(config),
            ownerOrAuthorName,
            extensionName,
          );
          const pathEditorDeeplink = buildPathEditorDeeplink(
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
                    icon={Icon.ChevronRight}
                    target={openConfigTarget(config, configDirectory, payload, setPayload, preferredEditor)}
                    title="Open Config"
                  />
                  <Action.Push
                    icon={Icon.Pencil}
                    shortcut={{ modifiers: ["ctrl", "cmd"], key: "p" }}
                    target={openPathEditor(config, configDirectory, payload, setPayload, preferredEditor)}
                    title="Open Path Editor"
                  />
                  <Action.CopyToClipboard
                    content={deeplink}
                    icon={Icon.Link}
                    title="Copy Config Deeplink"
                  />
                  <Action.CopyToClipboard
                    content={pathEditorDeeplink}
                    icon={Icon.AppWindowSidebarLeft}
                    title="Copy Path Editor Deeplink"
                  />
                  <Action.CreateQuicklink
                    quicklink={{
                      link: deeplink,
                      name: quicklinkName(config.displayName),
                    }}
                    title="Create Config Quicklink"
                  />
                  <Action.CreateQuicklink
                    quicklink={{
                      link: pathEditorDeeplink,
                      name: pathEditorQuicklinkName(config.displayName),
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
