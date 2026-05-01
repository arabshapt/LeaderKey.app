import type { ActionCandidate, ActionCatalog, DispatchPlan, ValidationReport } from "./types.js";

export interface ValidatePlanOptions {
  candidatesByClause?: ActionCandidate[][];
  allowGlobalLookup?: boolean;
  confidenceFloor?: number;
}

export function validateDispatchPlan(
  catalog: ActionCatalog,
  plan: DispatchPlan,
  options: ValidatePlanOptions = {},
): ValidationReport {
  const confidenceFloor = options.confidenceFloor ?? 0.85;
  const entriesById = new Map(catalog.entries.map((entry) => [entry.id, entry]));
  const allowedCandidateIds = new Set(
    (options.candidatesByClause ?? []).flat().map((candidate) => candidate.action.id),
  );
  const steps = plan.chain.map((step) => {
    const action = entriesById.get(step.action_id);
    if (!action) {
      return {
        action: undefined,
        blocked: true,
        confidence: step.confidence,
        reason: `invented action id: ${step.action_id}`,
        requiresConfirmation: false,
      };
    }
    if (!options.allowGlobalLookup && allowedCandidateIds.size > 0 && !allowedCandidateIds.has(step.action_id)) {
      return {
        action,
        blocked: true,
        confidence: step.confidence,
        reason: `action id was not in retrieved candidates: ${step.action_id}`,
        requiresConfirmation: action.requiresConfirmation,
      };
    }
    if (step.confidence < confidenceFloor || plan.overall_confidence < confidenceFloor) {
      return {
        action,
        blocked: true,
        confidence: step.confidence,
        reason: `confidence below ${confidenceFloor}`,
        requiresConfirmation: action.requiresConfirmation,
      };
    }
    if (action.safety === "block") {
      return {
        action,
        blocked: true,
        confidence: step.confidence,
        reason: action.safetyReasons.join("; "),
        requiresConfirmation: action.requiresConfirmation,
      };
    }
    return {
      action,
      blocked: false,
      confidence: step.confidence,
      requiresConfirmation: action.requiresConfirmation || action.safety === "confirm",
    };
  });

  const invented = steps.some((step) => !step.action);
  const blocked = invented || steps.some((step) => step.blocked);
  const needsConfirmation = plan.needs_confirmation || steps.some((step) => step.requiresConfirmation || step.action?.safety === "block");
  const typedSteps = steps.filter((step): step is typeof step & { action: NonNullable<typeof step.action> } => Boolean(step.action));

  if (plan.chain.length === 0) {
    return {
      blocked: true,
      needs_confirmation: false,
      reason: plan.reason || "empty action chain",
      steps: [],
      valid: false,
    };
  }

  return {
    blocked,
    needs_confirmation: needsConfirmation,
    reason: blocked
      ? steps.find((step) => step.blocked)?.reason ?? "blocked"
      : needsConfirmation
        ? "confirmation required"
        : "valid",
    steps: typedSteps,
    valid: !blocked,
  };
}
