import type {
  ActionNode,
  ActionType,
  CachePayload,
  FlatIndexRecord,
  ScopeType,
  VoiceSafety,
} from "@leaderkey/config-core";

export type DispatchScope = "frontmost" | "global" | "all";
export type PlannerKind =
  | "none"
  | "llama"
  | "ollama"
  | "groq"
  | "gemini"
  | "openai"
  | "openrouter"
  | "fireworks"
  | "together"
  | "deepinfra"
  | "perplexity"
  | "compatible";

export interface DispatchRequest {
  transcript: string;
  scope?: DispatchScope;
  bundleId?: string;
  context?: DispatchContext;
  configDirectory?: string;
  catalogPath?: string;
  includeGlobal?: boolean;
  dryRun?: boolean;
  execute?: boolean;
  allowDestructive?: boolean;
  planner?: PlannerKind;
  model?: string;
  llamaUrl?: string;
  ollamaUrl?: string;
  groqApiKey?: string;
  geminiApiKey?: string;
  openaiApiKey?: string;
  openrouterApiKey?: string;
  fireworksApiKey?: string;
  togetherApiKey?: string;
  deepinfraApiKey?: string;
  perplexityApiKey?: string;
  plannerBaseURL?: string;
  alwaysPlan?: boolean;
}

export interface CurrentAppContext {
  bundleId?: string;
  localizedName?: string;
}

export interface RecentVoiceCommandContext {
  transcript: string;
  action_ids: string[];
  labels: string[];
  types?: ActionType[];
  plan_reason?: string;
}

export interface DispatchContext {
  currentApp?: CurrentAppContext;
  recentCommands?: RecentVoiceCommandContext[];
}

export interface DispatchReference {
  actionId: string;
  actionType: ActionType;
  bundleId?: string;
  effectiveKeyPath: string[];
  effectiveScope: ScopeType | "catalog";
  requiresConfirmation: boolean;
  safety: VoiceSafety;
}

export interface ActionEntry {
  id: string;
  recordId?: string;
  key: string;
  keys: string[];
  path: string;
  label: string;
  description?: string;
  aiDescription?: string;
  type: ActionType;
  value: string;
  valuePreview: string;
  macroStepSummary?: string[];
  searchText: string;
  requiresConfirmation: boolean;
  safety: VoiceSafety;
  safetyReasons: string[];
  source?: ActionNode;
  record?: FlatIndexRecord;
  effectiveScope: ScopeType | "catalog";
  sourceScope?: ScopeType;
  bundleId?: string;
  effectiveConfigDisplayName: string;
  effectiveConfigPath?: string;
  sourceNodePath?: number[];
  dispatchRef: DispatchReference;
}

export interface ActionCatalog {
  entries: ActionEntry[];
  fingerprint: string;
  source: "catalog" | "config";
  payload?: CachePayload;
}

export interface ActionCandidate {
  action: ActionEntry;
  score: number;
  confidence: number;
  reason: string;
}

export interface PlannedStep {
  action_id: string;
  confidence: number;
}

export interface DispatchPlan {
  mode: "fast_match" | "llm_planner" | "blocked";
  chain: PlannedStep[];
  overall_confidence: number;
  needs_confirmation: boolean;
  reason: string;
  unresolved?: string[];
  planner_called?: boolean;
  planner_error?: string;
}

export interface ValidatedStep {
  action: ActionEntry;
  confidence: number;
  blocked: boolean;
  requiresConfirmation: boolean;
  reason?: string;
}

export interface ValidationReport {
  valid: boolean;
  blocked: boolean;
  needs_confirmation: boolean;
  reason: string;
  steps: ValidatedStep[];
}

export interface ExecutionStepReport {
  action_id: string;
  label: string;
  type: ActionType;
  executed: boolean;
  dry_run: boolean;
  blocked: boolean;
  requires_confirmation: boolean;
  reason?: string;
}

export interface ExecutionReport {
  executed: boolean;
  dry_run: boolean;
  blocked: boolean;
  needs_confirmation: boolean;
  reason: string;
  steps: ExecutionStepReport[];
}

export interface BenchRow {
  transcript: string;
  expected_action_ids: string[];
  expect_confirmation: boolean;
  expect_no_action: boolean;
  category: "direct" | "fuzzy" | "chain" | "ambiguous" | "impossible" | "unsafe";
}
