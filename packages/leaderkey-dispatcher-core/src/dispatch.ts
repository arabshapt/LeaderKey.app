import { buildActionCatalog } from "./catalog.js";
import { fastMatch } from "./matcher.js";
import { createPlanner } from "./planner.js";
import { sendLeaderKeySocketRequest } from "./socket.js";
import { validateDispatchPlan } from "./validator.js";
import type {
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

  if ((plan.chain.length === 0 || plan.unresolved?.length) && request.planner && request.planner !== "none") {
    const planner = createPlanner({
      llamaUrl: request.llamaUrl,
      model: request.model,
      ollamaUrl: request.ollamaUrl,
      planner: request.planner,
    });
    if (planner) {
      plan = await planner.plan(request.transcript, fast.candidatesByClause);
    }
  }

  const validation = validateDispatchPlan(catalog, plan, {
    candidatesByClause: fast.candidatesByClause,
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

export async function executeValidation(validation: ValidationReport, execute: boolean): Promise<ExecutionReport> {
  if (!execute || validation.blocked || validation.needs_confirmation) {
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
  const execution = await executeValidation(result.validation, request.execute === true);
  return {
    execution,
    plan: result.plan,
    validation: result.validation,
  };
}
