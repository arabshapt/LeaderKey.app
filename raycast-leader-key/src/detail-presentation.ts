import { parseIntellijActionValue, parseMenuActionValue, type FlatIndexRecord } from "@leaderkey/config-core";

import { fullPathText } from "./record-formatting.js";

export interface DetailMetadataRow {
  title: string;
  text: string;
}

export interface RecordDetailPresentation {
  markdown: string;
  metadata: DetailMetadataRow[];
  title: string;
}

interface ParsedKeystrokeValue {
  app?: string;
  focusTargetApp: boolean;
  spec: string;
}

function escapeInlineCode(value: string): string {
  return value.replace(/`/g, "\\`");
}

function codeBlock(value: string, language = "text"): string {
  const safeValue = value.replace(/```/g, "``\\`");
  return [`\`\`\`${language}`, safeValue, "```"].join("\n");
}

function simpleValueLine(label: string, value: string): string[] {
  return ["**Value**", "", `${label}: ${value}`];
}

function humanTitle(record: FlatIndexRecord): string {
  switch (record.actionType) {
    case "application":
      return `Open ${record.valuePreview || record.displayLabel}`;
    case "command":
      return record.displayLabel.startsWith("Run ") ? record.displayLabel : `Run ${record.displayLabel}`;
    case "folder":
      return record.displayLabel.startsWith("Open ") ? record.displayLabel : `Open ${record.valuePreview || record.displayLabel}`;
    case "intellij":
      return "Run IntelliJ Actions";
    case "keystroke": {
      const parsed = parseKeystrokeValue(record.rawValue);
      if (parsed.app && record.valuePreview) {
        return `Send ${record.valuePreview.split(" • ").at(-1) ?? record.valuePreview} to ${parsed.app}`;
      }
      return `Send ${record.valuePreview || record.displayLabel}`;
    }
    case "macro":
      return "Run Macro";
    case "menu":
      return "Select Menu Item";
    case "shortcut":
      return `Send ${record.valuePreview || record.displayLabel.replace(/^Shortcut:\s*/i, "")}`;
    case "text":
      return record.displayLabel.startsWith("Type ") ? record.displayLabel : `Type ${record.displayLabel}`;
    case "normalModeDisable":
      return "Disable Normal Mode";
    case "normalModeEnable":
      return "Enable Normal Mode";
    case "normalModeInput":
      return "Enter Normal Input Mode";
    case "toggleStickyMode":
      return "Toggle Sticky Mode";
    case "url":
      return record.displayLabel.startsWith("Open ") ? record.displayLabel : `Open ${record.displayLabel}`;
    case "group":
      return `${record.displayLabel} Group`;
  }
}

function parseKeystrokeValue(rawValue: string): ParsedKeystrokeValue {
  const parts = rawValue.split(" > ").map((part) => part.trim()).filter(Boolean);
  if (parts.length === 0) {
    return { focusTargetApp: false, spec: "" };
  }

  const spec = parts.at(-1)!;
  const focusTargetApp = parts.length > 2 && parts.at(-2) === "[focus]";
  const app = parts.length > 1 ? parts[0] : undefined;
  return { app, focusTargetApp, spec };
}

function parseIntellijValue(rawValue: string): { actions: string[]; delayMs?: number } {
  const parsed = parseIntellijActionValue(rawValue);
  return {
    actions: parsed.actionIds.map((action) => action.replace(/([a-z0-9])([A-Z])/g, "$1 $2")),
    delayMs: parsed.delayMs,
  };
}

function plainEnglishSummary(record: FlatIndexRecord): string {
  switch (record.actionType) {
    case "application":
      return `Opens the ${record.valuePreview || record.displayLabel} application.`;
    case "command":
      return "Runs this shell command.";
    case "folder":
      return "Opens this folder in Finder.";
    case "intellij": {
      const parsed = parseIntellijValue(record.rawValue);
      if (parsed.actions.length === 0) {
        return "Runs an IntelliJ action sequence.";
      }
      const delayText = parsed.delayMs ? ` with ${parsed.delayMs} ms delay between actions.` : ".";
      return `Runs ${parsed.actions.length} IntelliJ action${parsed.actions.length === 1 ? "" : "s"}${delayText}`;
    }
    case "keystroke": {
      const parsed = parseKeystrokeValue(record.rawValue);
      const shortcut = record.valuePreview.split(" • ").at(-1) ?? record.valuePreview;
      if (parsed.app) {
        const focusText = parsed.focusTargetApp ? " It focuses the app after sending." : " It does not focus the app first.";
        return `Sends ${shortcut} directly to ${parsed.app}.${focusText}`;
      }
      return `Sends ${shortcut} to the frontmost app.`;
    }
    case "macro": {
      const count = record.macroStepSummary?.length ?? 0;
      return `Runs a macro with ${count} enabled step${count === 1 ? "" : "s"} shown in the preview below.`;
    }
    case "menu":
      return record.menuFallbackPaths?.length
        ? "Selects this menu item in the target application and can retry ordered fallback menu paths if the primary path is missing."
        : "Selects this menu item in the target application.";
    case "shortcut":
      return `Sends ${record.valuePreview || record.displayLabel.replace(/^Shortcut:\s*/i, "")} to the frontmost app.`;
    case "text":
      return "Types this text value.";
    case "normalModeDisable":
      return "Disables persistent normal mode and returns keys to the frontmost app.";
    case "normalModeEnable":
      return "Enables persistent normal mode.";
    case "normalModeInput":
      return "Leaves normal mode enabled but passes keys through for text input.";
    case "toggleStickyMode":
      return "Turns sticky mode on or off for the current sequence.";
    case "url":
      return "Opens this URL.";
    case "group": {
      const count = record.childCount ?? 0;
      return `This group contains ${count} child item${count === 1 ? "" : "s"}.`;
    }
  }
}

function valueSection(record: FlatIndexRecord): string[] {
  if (!record.rawValue) {
    return [];
  }

  switch (record.actionType) {
    case "application":
      return simpleValueLine("App", record.rawValue);
    case "command":
      return ["**Value**", "", codeBlock(record.rawValue, "sh")];
    case "folder":
      return simpleValueLine("Folder", record.rawValue);
    case "url":
      return simpleValueLine("URL", record.rawValue);
    case "text":
      return ["**Value**", "", codeBlock(record.rawValue)];
    case "menu":
      return [
        "**Value**",
        "",
        `Primary: \`${parseMenuActionValue(record.rawValue).path || record.rawValue}\``,
        ...(record.menuFallbackPaths?.length
          ? ["Fallbacks:", ...record.menuFallbackPaths.map((path) => `- \`${escapeInlineCode(path)}\``)]
          : []),
        "",
        codeBlock(record.rawValue),
      ];
    case "intellij": {
      const parsed = parseIntellijValue(record.rawValue);
      const lines = [
        "**Value**",
        "",
        `Actions: \`${escapeInlineCode(parsed.actions.join(", ") || record.valuePreview)}\``,
      ];
      if (parsed.delayMs) {
        lines.push(`Delay: \`${parsed.delayMs} ms\``);
      }
      lines.push("", codeBlock(record.rawValue));
      return lines;
    }
    case "keystroke": {
      const parsed = parseKeystrokeValue(record.rawValue);
      const human = record.valuePreview.split(" • ").at(-1) ?? record.valuePreview;
      const lines = ["**Value**", "", `Shortcut: \`${escapeInlineCode(human)}\``];
      if (parsed.app) {
        lines.push(`Target: \`${escapeInlineCode(parsed.app)}\``);
      }
      lines.push(`Focus After Send: \`${parsed.focusTargetApp ? "Yes" : "No"}\``);
      lines.push(`Raw: \`${escapeInlineCode(record.rawValue)}\``);
      return lines;
    }
    case "shortcut":
      return [
        "**Value**",
        "",
        `Shortcut: \`${escapeInlineCode(record.valuePreview || record.displayLabel)}\``,
        `Raw: \`${escapeInlineCode(record.rawValue)}\``,
      ];
    default:
      return ["**Value**", "", codeBlock(record.rawValue)];
  }
}

function extraSection(record: FlatIndexRecord): string[] {
  if (record.actionType === "macro" && record.macroStepSummary && record.macroStepSummary.length > 0) {
    return [
      "**Steps**",
      "",
      ...record.macroStepSummary.map((step) => `- ${step}`),
    ];
  }

  return [];
}

function descriptionSection(record: FlatIndexRecord): string[] {
  const sections: string[] = [];

  if (record.description) {
    sections.push("**Description**", "", record.description);
  }

  if (record.aiDescription) {
    if (sections.length > 0) {
      sections.push("");
    }
    sections.push("**AI Description**", "", record.aiDescription);
  }

  return sections;
}

function metadataRows(record: FlatIndexRecord): DetailMetadataRow[] {
  const rows: DetailMetadataRow[] = [
    { title: "Type", text: record.actionType },
    { title: "Config", text: record.effectiveConfigDisplayName },
    { title: "Source Status", text: record.inherited ? "fallback" : "local" },
    { title: "Source Config", text: record.sourceConfigDisplayName },
    { title: "File", text: record.sourceConfigPath },
  ];

  if (record.stickyMode !== undefined) {
    rows.push({ title: "Sticky Mode", text: record.stickyMode ? "On" : "Off" });
  }

  if (record.normalModeAfter) {
    rows.push({ title: "Normal Mode After", text: record.normalModeAfter });
  }

  if (record.activates !== undefined) {
    rows.push({ title: "Activates", text: record.activates ? "Yes" : "No" });
  }

  if (record.childCount !== undefined) {
    rows.push({ title: "Children", text: String(record.childCount) });
  }

  if (record.macroStepSummary && record.macroStepSummary.length > 0) {
    rows.push({ title: "Enabled Steps", text: String(record.macroStepSummary.length) });
  }

  if (record.menuFallbackPaths && record.menuFallbackPaths.length > 0) {
    rows.push({ title: "Fallback Menu Paths", text: record.menuFallbackPaths.join(" | ") });
  }

  if (record.description) {
    rows.push({ title: "Description", text: record.description });
  }

  if (record.aiDescription) {
    rows.push({ title: "AI Description", text: record.aiDescription });
  }

  return rows;
}

export function buildRecordDetailPresentation(record: FlatIndexRecord): RecordDetailPresentation {
  const title = humanTitle(record);
  const descriptions = descriptionSection(record);
  const value = valueSection(record);
  const extra = extraSection(record);
  const markdown = [
    `## ${title}`,
    "",
    `\`${escapeInlineCode(fullPathText(record))}\``,
    "",
    "**What It Does**",
    "",
    plainEnglishSummary(record),
    "",
    ...descriptions,
    ...(descriptions.length > 0 ? [""] : []),
    ...value,
    ...(value.length > 0 ? [""] : []),
    ...extra,
  ]
    .filter((line, index, lines) => !(line === "" && lines[index - 1] === ""))
    .join("\n")
    .trim();

  return {
    markdown,
    metadata: metadataRows(record),
    title,
  };
}
