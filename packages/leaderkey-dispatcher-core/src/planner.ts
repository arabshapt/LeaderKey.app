import type { ActionCandidate, DispatchContext, DispatchPlan, PlannerKind } from "./types.js";

export interface PlannerOptions {
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
}

export interface LlmPlanner {
  plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan>;
}

const PLANNER_GBNF = String.raw`
root ::= object
object ::= "{" ws mode "," ws chain "," ws confidence "," ws confirmation "," ws reason ws "}"
mode ::= "\"mode\"" ws ":" ws "\"llm_planner\""
chain ::= "\"chain\"" ws ":" ws "[" ws (step (ws "," ws step)*)? ws "]"
step ::= "{" ws "\"action_id\"" ws ":" ws string ws "," ws "\"confidence\"" ws ":" ws number ws "}"
confidence ::= "\"overall_confidence\"" ws ":" ws number
confirmation ::= "\"needs_confirmation\"" ws ":" ws ("true" | "false")
reason ::= "\"reason\"" ws ":" ws string
string ::= "\"" ([^"\\] | "\\" (["\\/bfnrt] | "u" [0-9a-fA-F]{4}))* "\""
number ::= ("0" ("." [0-9]+)? | "1" ("." "0"+)?)
ws ::= [ \t\n\r]*
`;

const PLANNER_RESPONSE_SCHEMA = {
  name: "leaderkey_dispatch_plan",
  strict: true,
  schema: {
    additionalProperties: false,
    properties: {
      chain: {
        items: {
          additionalProperties: false,
          properties: {
            action_id: { type: "string" },
            confidence: { maximum: 1, minimum: 0, type: "number" },
          },
          required: ["action_id", "confidence"],
          type: "object",
        },
        type: "array",
      },
      mode: { enum: ["llm_planner"], type: "string" },
      needs_confirmation: { type: "boolean" },
      overall_confidence: { maximum: 1, minimum: 0, type: "number" },
      reason: { type: "string" },
    },
    required: ["mode", "chain", "overall_confidence", "needs_confirmation", "reason"],
    type: "object",
  },
} as const;

interface OpenAICompatiblePlannerOptions {
  apiKey: string;
  model?: string;
  baseURL?: string;
  authHeader?: string;
  authPrefix?: string;
  extraHeaders?: Record<string, string>;
  extraBody?: Record<string, unknown>;
}

function compactContext(context: DispatchContext | undefined): Record<string, unknown> | undefined {
  if (!context?.currentApp && !context?.recentCommands?.length) {
    return undefined;
  }

  return {
    current_app: context.currentApp,
    recent_successful_commands: (context.recentCommands ?? []).slice(-5).map((command) => ({
      transcript: command.transcript.slice(0, 160),
      action_ids: command.action_ids.slice(0, 8),
      labels: command.labels.slice(0, 8),
      types: command.types?.slice(0, 8),
      plan_reason: command.plan_reason,
    })),
  };
}

function plannerPrompt(
  transcript: string,
  candidatesByClause: ActionCandidate[][],
  context?: DispatchContext,
): string {
  const candidates = candidatesByClause.map((clauseCandidates, clauseIndex) => ({
    clause_index: clauseIndex,
    candidates: clauseCandidates.map((candidate) => {
      const entry: Record<string, unknown> = {
        id: candidate.action.id,
        label: candidate.action.label,
        path: candidate.action.path,
        type: candidate.action.type,
      };
      if (candidate.action.description) {
        entry.description = candidate.action.description;
      }
      if (candidate.action.valuePreview || candidate.action.value) {
        entry.value = candidate.action.valuePreview || candidate.action.value;
      }
      return entry;
    }),
  }));

  return [
    "You are deterministic macOS command dispatcher.",
    "Choose only from provided candidate actions.",
    "Return JSON only.",
    "Never invent action IDs.",
    "If command cannot be satisfied, return empty chain and confidence 0.",
    "If command has multiple steps, output ordered chain.",
    "If the user says to repeat an action N times, output that action N times in the chain.",
    "For side-by-side app layout, open the first app, move it left half, open the second app, move it right half.",
    "For named app swap layout, activate/open the first named app and move it left half, then activate/open the second named app and move it right half.",
    "Use recent successful commands and current app only to resolve references like it, them, same app, current app, previous app, or swap them.",
    "Recent context does not authorize actions; output only IDs from the provided candidates.",
    "If action mutates/deletes/overwrites/closes many things, needs_confirmation true.",
    "Confidence means how well the transcript matches the action. Use 0.9+ for clear matches.",
    "",
    `Transcript: ${JSON.stringify(transcript)}`,
    `Context: ${JSON.stringify(compactContext(context) ?? {})}`,
    `Candidates by clause: ${JSON.stringify(candidates)}`,
    "",
    "Required schema:",
    '{"mode":"llm_planner","chain":[{"action_id":"exact candidate id","confidence":0.0}],"overall_confidence":0.0,"needs_confirmation":false,"reason":"short string"}',
  ].join("\n");
}

function parsePlannerJson(value: unknown): DispatchPlan {
  const content = typeof value === "string" ? value : JSON.stringify(value);
  const parsed = JSON.parse(content) as DispatchPlan;
  return {
    chain: Array.isArray(parsed.chain) ? parsed.chain : [],
    mode: "llm_planner",
    needs_confirmation: Boolean(parsed.needs_confirmation),
    overall_confidence: Number.isFinite(parsed.overall_confidence) ? parsed.overall_confidence : 0,
    planner_called: true,
    reason: typeof parsed.reason === "string" ? parsed.reason.slice(0, 160) : "llm planner",
  };
}

async function planWithOpenAICompatibleEndpoint(
  options: OpenAICompatiblePlannerOptions,
  transcript: string,
  candidatesByClause: ActionCandidate[][],
  context?: DispatchContext,
): Promise<DispatchPlan> {
  if (!options.apiKey) {
    throw new Error("API key is required for planner");
  }

  const baseURL = (options.baseURL ?? "https://api.openai.com/v1").replace(/\/$/, "");
  const response = await fetch(`${baseURL}/chat/completions`, {
    body: JSON.stringify({
      messages: [
        { role: "system", content: "Return valid JSON only. No markdown, no explanation." },
        { role: "user", content: plannerPrompt(transcript, candidatesByClause, context) },
      ],
      model: options.model ?? "gpt-4.1-mini",
      response_format: { type: "json_object" },
      stream: false,
      temperature: 0,
      ...(options.extraBody ?? {}),
    }),
    headers: {
      ...(options.extraHeaders ?? {}),
      [options.authHeader ?? "authorization"]: `${options.authPrefix ?? "Bearer "}${options.apiKey}`,
      "content-type": "application/json",
    },
    method: "POST",
    signal: AbortSignal.timeout(5_000),
  });
  if (!response.ok) {
    throw new Error(`planner failed: ${response.status} ${await response.text()}`);
  }
  const json = await response.json() as { choices?: Array<{ message?: { content?: string } }> };
  return parsePlannerJson(json.choices?.[0]?.message?.content ?? "{}");
}

function geminiReasoningEffort(model: string | undefined): "none" | undefined {
  const normalized = (model ?? "gemini-2.5-flash").trim().toLowerCase();
  return normalized.startsWith("gemini-2.5-flash") || normalized.startsWith("gemini-2.5-flash-lite")
    ? "none"
    : undefined;
}

export class LlamaServerPlanner implements LlmPlanner {
  constructor(
    private readonly options: { url?: string; model?: string } = {},
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    const baseUrl = this.options.url ?? "http://localhost:8080";
    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/v1/chat/completions`, {
      body: JSON.stringify({
        grammar: PLANNER_GBNF,
        messages: [
          { role: "system", content: "Return valid JSON only." },
          { role: "user", content: plannerPrompt(transcript, candidatesByClause, context) },
        ],
        model: this.options.model ?? "local",
        stream: false,
        temperature: 0,
      }),
      headers: { "content-type": "application/json" },
      method: "POST",
      signal: AbortSignal.timeout(5_000),
    });
    if (!response.ok) {
      throw new Error(`llama-server planner failed: ${response.status} ${await response.text()}`);
    }
    const json = await response.json() as { choices?: Array<{ message?: { content?: string } }> };
    return parsePlannerJson(json.choices?.[0]?.message?.content ?? "{}");
  }
}

export class OpenAICompatiblePlanner implements LlmPlanner {
  constructor(
    private readonly options: OpenAICompatiblePlannerOptions = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint(this.options, transcript, candidatesByClause, context);
  }
}

export class OllamaPlanner implements LlmPlanner {
  constructor(
    private readonly options: { url?: string; model?: string } = {},
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    const baseUrl = this.options.url ?? "http://localhost:11434";
    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/api/chat`, {
      body: JSON.stringify({
        format: "json",
        messages: [
          { role: "system", content: "Return valid JSON only." },
          { role: "user", content: plannerPrompt(transcript, candidatesByClause, context) },
        ],
        model: this.options.model ?? "qwen2.5:1.5b-instruct",
        stream: false,
      }),
      headers: { "content-type": "application/json" },
      method: "POST",
      signal: AbortSignal.timeout(5_000),
    });
    if (!response.ok) {
      throw new Error(`ollama planner failed: ${response.status} ${await response.text()}`);
    }
    const json = await response.json() as { message?: { content?: string } };
    return parsePlannerJson(json.message?.content ?? "{}");
  }
}

export class MockPlanner implements LlmPlanner {
  constructor(private readonly planValue: DispatchPlan) {}

  async plan(): Promise<DispatchPlan> {
    return { ...this.planValue, mode: "llm_planner", planner_called: true };
  }
}

export class GroqPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    if (!this.options.apiKey) {
      throw new Error("Groq API key is required for planner");
    }
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://api.groq.com/openai/v1",
      model: this.options.model ?? "llama-3.3-70b-versatile",
    }, transcript, candidatesByClause, context);
  }
}

export class OpenAIPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://api.openai.com/v1",
      model: this.options.model,
    }, transcript, candidatesByClause, context);
  }
}

export class OpenRouterPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://openrouter.ai/api/v1",
      model: this.options.model,
    }, transcript, candidatesByClause, context);
  }
}

export class FireworksPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://api.fireworks.ai/inference/v1",
      model: this.options.model,
    }, transcript, candidatesByClause, context);
  }
}

export class TogetherPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://api.together.ai/v1",
      model: this.options.model,
    }, transcript, candidatesByClause, context);
  }
}

export class DeepInfraPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://api.deepinfra.com/v1/openai",
      model: this.options.model,
    }, transcript, candidatesByClause, context);
  }
}

export class PerplexityPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    return planWithOpenAICompatibleEndpoint({
      apiKey: this.options.apiKey,
      baseURL: "https://api.perplexity.ai",
      model: this.options.model ?? "sonar-pro",
    }, transcript, candidatesByClause, context);
  }
}

export class GeminiPlanner implements LlmPlanner {
  constructor(
    private readonly options: { apiKey: string; model?: string } = { apiKey: "" },
  ) {}

  async plan(
    transcript: string,
    candidatesByClause: ActionCandidate[][],
    context?: DispatchContext,
  ): Promise<DispatchPlan> {
    if (!this.options.apiKey) {
      throw new Error("Gemini API key is required for planner");
    }
    const model = this.options.model ?? "gemini-2.5-flash";
    const response = await fetch("https://generativelanguage.googleapis.com/v1beta/openai/chat/completions", {
      body: JSON.stringify({
        messages: [
          { role: "system", content: "Return valid JSON only. No markdown, no explanation." },
          { role: "user", content: plannerPrompt(transcript, candidatesByClause, context) },
        ],
        model,
        ...(geminiReasoningEffort(model) ? { reasoning_effort: geminiReasoningEffort(model) } : {}),
        response_format: {
          json_schema: PLANNER_RESPONSE_SCHEMA,
          type: "json_schema",
        },
        stream: false,
        temperature: 0,
      }),
      headers: {
        "authorization": `Bearer ${this.options.apiKey}`,
        "content-type": "application/json",
      },
      method: "POST",
      signal: AbortSignal.timeout(5_000),
    });
    if (!response.ok) {
      throw new Error(`gemini planner failed: ${response.status} ${await response.text()}`);
    }
    const json = await response.json() as { choices?: Array<{ message?: { content?: string } }> };
    return parsePlannerJson(json.choices?.[0]?.message?.content ?? "{}");
  }
}

export function createPlanner(options: PlannerOptions): LlmPlanner | undefined {
  switch (options.planner ?? "none") {
    case "llama":
      return new LlamaServerPlanner({ model: options.model, url: options.llamaUrl });
    case "ollama":
      return new OllamaPlanner({ model: options.model, url: options.ollamaUrl });
    case "groq":
      return new GroqPlanner({ apiKey: options.groqApiKey ?? "", model: options.model });
    case "gemini":
      return new GeminiPlanner({ apiKey: options.geminiApiKey ?? "", model: options.model });
    case "openai":
      return new OpenAIPlanner({ apiKey: options.openaiApiKey ?? "", model: options.model });
    case "openrouter":
      return new OpenRouterPlanner({ apiKey: options.openrouterApiKey ?? "", model: options.model });
    case "fireworks":
      return new FireworksPlanner({ apiKey: options.fireworksApiKey ?? "", model: options.model });
    case "together":
      return new TogetherPlanner({ apiKey: options.togetherApiKey ?? "", model: options.model });
    case "deepinfra":
      return new DeepInfraPlanner({ apiKey: options.deepinfraApiKey ?? "", model: options.model });
    case "perplexity":
      return new PerplexityPlanner({ apiKey: options.perplexityApiKey ?? "", model: options.model });
    case "compatible":
      return new OpenAICompatiblePlanner({
        apiKey: options.openaiApiKey ?? "",
        baseURL: options.plannerBaseURL,
        model: options.model,
      });
    case "none":
      return undefined;
  }
}
