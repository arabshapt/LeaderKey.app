import type { ActionNode, VoiceSafety } from "@leaderkey/config-core";
import type { ActionEntry } from "./types.js";
import { normalizeText } from "./text.js";

const BLOCK_PATTERNS: RegExp[] = [
  /\brm\s+-rf\b/i,
  /\bsudo\b/i,
  /\bcurl\b.*\|\s*sh\b/i,
  /\bdrop\s+table\b/i,
  /\bdiskutil\s+erase\b/i,
  /\bchmod\s+-r\s+777\b/i,
  /\blaunchctl\s+unload\b/i,
  /\bosascript\b.*\bdelete\b.*\bfile/i,
];

const CONFIRM_PATTERNS: RegExp[] = [
  /\bdelete\b/i,
  /\bremove\b/i,
  /\bclose\b.*\ball\b/i,
  /\bquit\b/i,
  /\boverwrite\b/i,
  /\berase\b/i,
  /\bshutdown\b/i,
  /\brestart\b/i,
];

function maxSafety(left: VoiceSafety, right: VoiceSafety): VoiceSafety {
  const rank: Record<VoiceSafety, number> = { safe: 0, confirm: 1, block: 2 };
  return rank[left] >= rank[right] ? left : right;
}

export function deriveActionSafety(input: {
  type: string;
  value: string;
  label?: string;
  description?: string;
  searchText?: string;
  source?: ActionNode;
}): { safety: VoiceSafety; reasons: string[] } {
  let safety: VoiceSafety = "safe";
  const reasons: string[] = [];
  const haystack = [input.value, input.label, input.description, input.searchText]
    .filter(Boolean)
    .join(" ");

  if (input.type === "command") {
    safety = "block";
    reasons.push("voice real-run blocks shell command actions");
  }

  for (const pattern of BLOCK_PATTERNS) {
    if (pattern.test(haystack)) {
      safety = "block";
      reasons.push(`blocked pattern: ${pattern.source}`);
    }
  }

  for (const pattern of CONFIRM_PATTERNS) {
    if (pattern.test(haystack)) {
      safety = maxSafety(safety, "confirm");
      reasons.push(`confirmation pattern: ${pattern.source}`);
    }
  }

  if (input.type === "macro") {
    for (const step of input.source?.macroSteps ?? []) {
      if (!step.enabled) {
        continue;
      }
      const child = deriveActionSafety({
        type: step.action.type,
        value: step.action.value,
        label: step.action.label,
        description: step.action.description,
        searchText: [
          step.action.label,
          step.action.description,
          step.action.aiDescription,
          step.action.value,
          step.action.voiceAliases?.join(" "),
        ].filter(Boolean).join(" "),
        source: step.action,
      });
      safety = maxSafety(safety, child.safety);
      reasons.push(...child.reasons.map((reason) => `macro step: ${reason}`));
    }
  }

  const override = input.source?.voiceSafety;
  if (override && input.type !== "command") {
    safety = override;
    reasons.push(`voiceSafety override: ${override}`);
  }

  return { safety, reasons: reasons.length > 0 ? reasons : [`derived ${normalizeText(safety)}`] };
}

export function executableInRealMode(entry: ActionEntry): boolean {
  return entry.safety === "safe" && !entry.requiresConfirmation && entry.type !== "command";
}
