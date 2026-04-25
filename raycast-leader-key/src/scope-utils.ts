import {
  NORMAL_APP_CONFIG_PREFIX,
  NORMAL_FALLBACK_CONFIG_FILE_NAME,
  type ScopeType,
} from "@leaderkey/config-core";

export function isNormalScope(scope: ScopeType | undefined): boolean {
  return scope === "normalApp" || scope === "normalFallback";
}

export function isNormalConfigPath(filePath: string): boolean {
  const fileName = filePath.split(/[\\/]/).at(-1);
  return fileName === NORMAL_FALLBACK_CONFIG_FILE_NAME
    || Boolean(fileName?.startsWith(NORMAL_APP_CONFIG_PREFIX));
}
