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
export type VoiceSafety = "safe" | "confirm" | "block";

export type ScopeType = "app" | "fallback" | "global" | "normalApp" | "normalFallback" | "normalTag" | "tag";
export type TagAssignmentScope = "app" | "normalApp";

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
  voiceId?: string;
  voiceSafety?: VoiceSafety;
  voiceAliases?: string[];
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

export interface TagDefinition {
  createdAt?: number;
  id: string;
  lastModified?: number;
  name: string;
}

export interface TagsRegistry {
  assignments: Record<TagAssignmentScope, Record<string, string[]>>;
  tags: TagDefinition[];
  version: 1;
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
  tagId?: string;
  virtual?: boolean;
}

export interface ConfigSummary {
  bundleId?: string;
  displayName: string;
  filePath: string;
  scope: ScopeType;
  tagId?: string;
  virtual?: boolean;
}

export interface SourceSummary {
  bundleId?: string;
  configDisplayName: string;
  configPath: string;
  keySequence?: string;
  priority: number;
  scope: ScopeType;
  sourceStatus: "fallback" | "local" | "tag";
  tagId?: string;
}

export interface ConfigDiagnostic {
  affectedBundleIds?: string[];
  hiddenSource?: SourceSummary;
  id: string;
  keySequence?: string;
  kind: "missingTagConfig" | "missingTagDefinition" | "shadowedSource";
  message: string;
  severity: "warning";
  tagId?: string;
  winnerSource?: SourceSummary;
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
  effectiveBundleId?: string;
  effectiveScope: ScopeType;
  sourceConfigDisplayName: string;
  sourceConfigPath: string;
  sourceBundleId?: string;
  sourceScope: ScopeType;
  sourceNodePath: number[];
  inherited: boolean;
  sourceStatus: "fallback" | "local" | "tag";
  sourcePriority: number;
  sourceTagId?: string;
  hiddenSources?: SourceSummary[];
  stickyMode?: boolean;
  normalModeAfter?: NormalModeAfter;
  activates?: boolean;
  voiceId?: string;
  voiceSafety?: VoiceSafety;
  voiceAliases?: string[];
  childCount?: number;
  tapAction?: ActionNode;
  macroStepSummary?: string[];
  sourceNode?: ConfigItem;
  appName?: string;
  searchText: string;
}

export interface CachePayload {
  configDirectory: string;
  configs: ConfigSummary[];
  diagnostics: ConfigDiagnostic[];
  fingerprint: string;
  generatedAt: string;
  records: FlatIndexRecord[];
  tagsRegistry: TagsRegistry;
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
