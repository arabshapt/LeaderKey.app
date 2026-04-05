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
  configTargetForSummary,
  resolveConfigTarget,
} from "./deeplinks.js";
import { getExtensionPreferences } from "./preferences.js";
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

export default function BrowseConfigsCommand(props: BrowseConfigsProps) {
  const { configDirectory, preferredEditor } = getExtensionPreferences();
  const requestedTarget = configTargetFromProps(props);
  const { payload, setPayload, isInitialLoading, isRefreshing } = useIndexPayload(configDirectory, {
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
    return (
      <List
        key={`loading:${configDirectory}:${requestedTarget ?? "root"}`}
        isLoading={isInitialLoading}
        searchBarPlaceholder="Browse Leader Key configs"
      >
        <List.Item
          id="loading-configs"
          title="Loading configs…"
          subtitle="Reading cached index"
        />
      </List>
    );
  }

  return (
    <List
      key={`ready:${payload.fingerprint}:${requestedTarget ?? "root"}`}
      isLoading={isRefreshing}
      searchBarPlaceholder="Browse Leader Key configs"
    >
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
                  <Action.CopyToClipboard
                    content={deeplink}
                    icon={Icon.Link}
                    title="Copy Config Deeplink"
                  />
                  <Action.CreateQuicklink
                    quicklink={{
                      link: deeplink,
                      name: quicklinkName(config.displayName),
                    }}
                    title="Create Config Quicklink"
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
