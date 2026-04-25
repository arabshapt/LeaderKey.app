import type { ConfigSummary } from "@leaderkey/config-core";

export const DEFAULT_BROWSE_CONFIGS_COMMAND = "browse-configs";
export const DEFAULT_PATH_EDITOR_COMMAND = "add-edit-by-path";
export const FRONTMOST_BUNDLE_ID_PLACEHOLDER = "{frontmostBundleId}";

export function configTargetForSummary(config: ConfigSummary): string {
  if (config.scope === "global") {
    return "global";
  }

  if (config.scope === "fallback") {
    return "fallback";
  }

  if (config.scope === "normalFallback") {
    return "normal-fallback";
  }

  if (config.scope === "normalApp" && config.bundleId) {
    return `normal-app:${config.bundleId}`;
  }

  if (config.bundleId) {
    return `app:${config.bundleId}`;
  }

  return `file:${config.filePath}`;
}

function buildConfigCommandDeeplink(
  command: string,
  launchPayload: Record<string, string>,
  ownerOrAuthorName: string,
  extensionName: string,
): string {
  const encodedPayload = JSON.stringify(launchPayload);
  const params = new URLSearchParams({
    arguments: encodedPayload,
    context: encodedPayload,
    launchType: "userInitiated",
  });

  return `raycast://extensions/${ownerOrAuthorName}/${extensionName}/${command}?${params.toString()}`;
}

export function buildBrowseConfigsDeeplink(
  configTarget: string,
  ownerOrAuthorName: string,
  extensionName: string,
  command = DEFAULT_BROWSE_CONFIGS_COMMAND,
): string {
  return buildConfigCommandDeeplink(command, { configTarget }, ownerOrAuthorName, extensionName);
}

export function buildPathEditorDeeplink(
  configTarget: string,
  ownerOrAuthorName: string,
  extensionName: string,
  initialPath?: string,
  command = DEFAULT_PATH_EDITOR_COMMAND,
): string {
  return buildConfigCommandDeeplink(
    command,
    initialPath ? { configTarget, initialPath } : { configTarget },
    ownerOrAuthorName,
    extensionName,
  );
}

export function appBundleIdForConfigTarget(configTarget: string | undefined): string | undefined {
  if (!configTarget) {
    return undefined;
  }

  if (!configTarget.startsWith("app:")) {
    return undefined;
  }

  const bundleId = configTarget.slice("app:".length).trim();
  return bundleId || undefined;
}

export function normalAppBundleIdForConfigTarget(configTarget: string | undefined): string | undefined {
  if (!configTarget) {
    return undefined;
  }

  if (!configTarget.startsWith("normal-app:")) {
    return undefined;
  }

  const bundleId = configTarget.slice("normal-app:".length).trim();
  return bundleId || undefined;
}

export function resolveConfigTarget(
  configs: ConfigSummary[],
  configTarget: string | undefined,
): ConfigSummary | undefined {
  if (!configTarget) {
    return undefined;
  }

  if (configTarget === "global") {
    return configs.find((config) => config.scope === "global");
  }

  if (configTarget === "fallback") {
    return configs.find((config) => config.scope === "fallback");
  }

  if (configTarget === "normal-fallback") {
    return configs.find((config) => config.scope === "normalFallback");
  }

  const normalBundleId = normalAppBundleIdForConfigTarget(configTarget);
  if (normalBundleId) {
    return configs.find((config) => config.scope === "normalApp" && config.bundleId === normalBundleId);
  }

  const bundleId = appBundleIdForConfigTarget(configTarget);
  if (bundleId) {
    return configs.find((config) => config.scope === "app" && config.bundleId === bundleId);
  }

  if (configTarget.startsWith("file:")) {
    const filePath = configTarget.slice("file:".length);
    return configs.find((config) => config.filePath === filePath);
  }

  return undefined;
}
