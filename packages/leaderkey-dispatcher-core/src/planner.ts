import type { ActionCandidate, DispatchPlan, PlannerKind } from "./types.js";

export interface PlannerOptions {
  planner?: PlannerKind;
  model?: string;
  llamaUrl?: string;
  ollamaUrl?: string;
}

export interface LlmPlanner {
  plan(transcript: string, candidatesByClause: ActionCandidate[][]): Promise<DispatchPlan>;
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

function plannerPrompt(transcript: string, candidatesByClause: ActionCandidate[][]): string {
  const candidates = candidatesByClause.map((clauseCandidates, clauseIndex) => ({
    clause_index: clauseIndex,
    candidates: clauseCandidates.map((candidate) => ({
      description: candidate.action.description,
      id: candidate.action.id,
      label: candidate.action.label,
      path: candidate.action.path,
      requiresConfirmation: candidate.action.requiresConfirmation,
      type: candidate.action.type,
      value: candidate.action.valuePreview || candidate.action.value,
    })),
  }));

  return [
    "You are deterministic macOS command dispatcher.",
    "Choose only from provided candidate actions.",
    "Return JSON only.",
    "Never invent action IDs.",
    "If command cannot be satisfied, return empty chain and confidence 0.",
    "If command has multiple steps, output ordered chain.",
    "If action mutates/deletes/overwrites/closes many things, needs_confirmation true.",
    "",
    `Transcript: ${JSON.stringify(transcript)}`,
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

export class LlamaServerPlanner implements LlmPlanner {
  constructor(
    private readonly options: { url?: string; model?: string } = {},
  ) {}

  async plan(transcript: string, candidatesByClause: ActionCandidate[][]): Promise<DispatchPlan> {
    const baseUrl = this.options.url ?? "http://localhost:8080";
    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/v1/chat/completions`, {
      body: JSON.stringify({
        grammar: PLANNER_GBNF,
        messages: [
          { role: "system", content: "Return valid JSON only." },
          { role: "user", content: plannerPrompt(transcript, candidatesByClause) },
        ],
        model: this.options.model ?? "local",
        stream: false,
        temperature: 0,
      }),
      headers: { "content-type": "application/json" },
      method: "POST",
    });
    if (!response.ok) {
      throw new Error(`llama-server planner failed: ${response.status} ${await response.text()}`);
    }
    const json = await response.json() as { choices?: Array<{ message?: { content?: string } }> };
    return parsePlannerJson(json.choices?.[0]?.message?.content ?? "{}");
  }
}

export class OllamaPlanner implements LlmPlanner {
  constructor(
    private readonly options: { url?: string; model?: string } = {},
  ) {}

  async plan(transcript: string, candidatesByClause: ActionCandidate[][]): Promise<DispatchPlan> {
    const baseUrl = this.options.url ?? "http://localhost:11434";
    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/api/chat`, {
      body: JSON.stringify({
        format: "json",
        messages: [
          { role: "system", content: "Return valid JSON only." },
          { role: "user", content: plannerPrompt(transcript, candidatesByClause) },
        ],
        model: this.options.model ?? "qwen2.5:1.5b-instruct",
        stream: false,
      }),
      headers: { "content-type": "application/json" },
      method: "POST",
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

export function createPlanner(options: PlannerOptions): LlmPlanner | undefined {
  switch (options.planner ?? "none") {
    case "llama":
      return new LlamaServerPlanner({ model: options.model, url: options.llamaUrl });
    case "ollama":
      return new OllamaPlanner({ model: options.model, url: options.ollamaUrl });
    case "none":
      return undefined;
  }
}
