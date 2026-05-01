import { buildActionCatalog } from "./catalog.js";
import { fastMatch } from "./matcher.js";
import { createPlanner } from "./planner.js";
import { retrieveActions } from "./retriever.js";
import { sendLeaderKeySocketRequest } from "./socket.js";
import { validateDispatchPlan } from "./validator.js";
import type {
  ActionCandidate,
  ActionCatalog,
  DispatchPlan,
  DispatchRequest,
  ExecutionReport,
  ValidationReport,
} from "./types.js";

export interface PlanResult {
  catalog: ActionCatalog;
  plan: DispatchPlan;
  validation: ValidationReport;
}

export async function planDispatch(request: DispatchRequest): Promise<PlanResult> {
  const catalog = await buildActionCatalog({
    bundleId: request.bundleId,
    catalogPath: request.catalogPath,
    configDirectory: request.configDirectory,
    includeGlobal: request.includeGlobal,
    scope: request.scope ?? "frontmost",
  });
  const fast = fastMatch(catalog, request.transcript);
  let plan = fast.plan;

  const shouldCallPlanner = request.planner && request.planner !== "none" && (
    request.alwaysPlan || plan.chain.length === 0 || (plan.unresolved?.length ?? 0) > 0
  );

  if (shouldCallPlanner) {
    try {
      const planner = createPlanner({
        groqApiKey: request.groqApiKey,
        llamaUrl: request.llamaUrl,
        model: request.model,
        ollamaUrl: request.ollamaUrl,
        planner: request.planner,
      });
      if (planner) {
        let candidatesByClause: ActionCandidate[][];
        if (request.alwaysPlan) {
          // In always-plan mode, send the full catalog so the LLM can compose
          // multi-step plans from any available action (e.g. window tiling + app switching)
          const allCandidates: ActionCandidate[] = catalog.entries.map((entry) => ({
            action: entry,
            confidence: 1,
            reason: "catalog",
            score: 0,
          }));
          candidatesByClause = [allCandidates];
        } else {
          candidatesByClause = fast.candidatesByClause.length > 0
            ? fast.candidatesByClause
            : [retrieveActions(catalog, request.transcript, 12)];
        }
        plan = await planner.plan(request.transcript, candidatesByClause);
      }
    } catch (error) {
      plan = {
        ...plan,
        planner_called: true,
        planner_error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  const validation = validateDispatchPlan(catalog, plan, {
    allowGlobalLookup: request.alwaysPlan,
    candidatesByClause: fast.candidatesByClause,
    confidenceFloor: plan.mode === "llm_planner" ? 0.5 : undefined,
  });
  return { catalog, plan, validation };
}

function dryRunReport(validation: ValidationReport, dryRun: boolean): ExecutionReport {
  return {
    blocked: validation.blocked,
    dry_run: dryRun,
    executed: false,
    needs_confirmation: validation.needs_confirmation,
    reason: validation.reason,
    steps: validation.steps.map((step) => ({
      action_id: step.action.id,
      blocked: step.blocked,
      dry_run: dryRun,
      executed: false,
      label: step.action.label,
      reason: step.reason,
      requires_confirmation: step.requiresConfirmation,
      type: step.action.type,
    })),
  };
}

export async function executeValidation(
  validation: ValidationReport,
  execute: boolean,
  allowDestructive = false,
): Promise<ExecutionReport> {
  const confirmationBlocks = validation.needs_confirmation && !allowDestructive;
  if (!execute || validation.blocked || confirmationBlocks) {
    return dryRunReport(validation, !execute);
  }

  const payload = {
    dryRun: false,
    steps: validation.steps.map((step) => ({
      ...step.action.dispatchRef,
      label: step.action.label,
    })),
  };
  const response = await sendLeaderKeySocketRequest(`dispatch execute ${JSON.stringify(payload)}`, "/tmp/leaderkey.sock", 5000);
  return JSON.parse(response) as ExecutionReport;
}

export async function executeDispatch(request: DispatchRequest): Promise<{ plan: DispatchPlan; execution: ExecutionReport; validation: ValidationReport }> {
  const result = await planDispatch(request);
  const execution = await executeValidation(
    result.validation,
    request.execute === true,
    request.allowDestructive === true,
  );
  return {
    execution,
    plan: result.plan,
    validation: result.validation,
  };
}
