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
import { loadIndex } from "./cache.js";
import { CreateAppConfigForm } from "./create-app-config-form.js";
import {
  FRONTMOST_BUNDLE_ID_PLACEHOLDER,
  appBundleIdForConfigTarget,
  buildBrowseConfigsDeeplink,
  configTargetForSummary,
  resolveConfigTarget,
} from "./deeplinks.js";
import { getExtensionPreferences } from "./preferences.js";

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
  const [payload, setPayload] = useState<CachePayload>();
  const [isLoading, setIsLoading] = useState(true);
  const [launchTargetErrorShown, setLaunchTargetErrorShown] = useState<string>();
  const requestedTarget = configTargetFromProps(props);
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

  return (
    <List
      isLoading={isLoading}
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
        {(payload?.configs ?? []).map((config) => {
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
                  {payload ? (
                    <Action.Push
                      icon={Icon.ChevronRight}
                      target={openConfigTarget(config, configDirectory, payload, setPayload, preferredEditor)}
                      title="Open Config"
                    />
                  ) : null}
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
