export type ActionType =
  | "application"
  | "command"
  | "folder"
  | "group"
  | "intellij"
  | "keystroke"
  | "layer"
  | "macro"
  | "menu"
  | "shortcut"
  | "text"
  | "normalModeDisable"
  | "normalModeEnable"
  | "normalModeInput"
  | "toggleHintOverlay"
  | "toggleStickyMode"
  | "url";

export type NormalModeAfter = "disabled" | "input" | "normal";

export type ScopeType = "app" | "fallback" | "global" | "normalApp" | "normalFallback";

export interface MacroStep {
  action: ActionNode;
  delay: number;
  enabled: boolean;
}

export interface ActionNode {
  key?: string;
  type: Exclude<ActionType, "group" | "layer">;
  label?: string;
  description?: string;
  aiDescription?: string;
  value: string;
  iconPath?: string;
  activates?: boolean;
  menuFallbackPaths?: string[];
  normalModeAfter?: NormalModeAfter;
  stickyMode?: boolean;
  macroSteps?: MacroStep[];
}

export interface GroupNode {
  key?: string;
  type: "group";
  label?: string;
  iconPath?: string;
  stickyMode?: boolean;
  actions: ConfigItem[];
}

export interface LayerNode {
  key?: string;
  type: "layer";
  label?: string;
  iconPath?: string;
  tapAction?: ActionNode;
  actions: ConfigItem[];
}

export type ConfigItem = ActionNode | GroupNode | LayerNode;

export interface ConfigMetadata {
  createdAt?: number;
  customName?: string;
  lastModified?: number;
}

export interface DiscoveredConfigFile {
  defaultDisplayName: string;
  displayName: string;
  fileName: string;
  filePath: string;
  metaPath: string;
  scope: ScopeType;
  bundleId?: string;
  customName?: string;
  fileMtimeMs: number;
  metaMtimeMs?: number;
}

export interface ConfigSummary {
  bundleId?: string;
  displayName: string;
  filePath: string;
  scope: ScopeType;
}

export interface FlatIndexRecord {
  id: string;
  kind: "action" | "group" | "layer";
  actionType: ActionType;
  key: string;
  keySequence: string;
  effectiveKeyPath: string[];
  parentEffectiveKeyPath: string[];
  breadcrumbPath: string[];
  breadcrumbDisplay: string;
  label?: string;
  description?: string;
  aiDescription?: string;
  displayLabel: string;
  rawValue: string;
  valuePreview: string;
  menuFallbackPaths?: string[];
  effectiveConfigDisplayName: string;
  effectiveConfigPath: string;
  effectiveScope: ScopeType;
  sourceConfigDisplayName: string;
  sourceConfigPath: string;
  sourceScope: ScopeType;
  sourceNodePath: number[];
  inherited: boolean;
  sourceStatus: "fallback" | "local";
  stickyMode?: boolean;
  normalModeAfter?: NormalModeAfter;
  activates?: boolean;
  childCount?: number;
  tapAction?: ActionNode;
  macroStepSummary?: string[];
  appName?: string;
  searchText: string;
}

export interface CachePayload {
  configDirectory: string;
  configs: ConfigSummary[];
  fingerprint: string;
  generatedAt: string;
  records: FlatIndexRecord[];
  version: number;
}

export interface EditorTarget {
  column: number;
  filePath: string;
  line: number;
}

export type EditorId = "cursor" | "intellij" | "system" | "vscode" | "zed";

export interface EditCommand {
  args: string[];
  command: string;
}

export interface ItemContext {
  breadcrumbPath: string[];
  configDisplayName: string;
  inherited: boolean;
}
