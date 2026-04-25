import { Icon, type Image, type List } from "@raycast/api";
import type { FlatIndexRecord } from "@leaderkey/config-core";
import { canonicalSequenceText, fullPathText, keyPathText, truncateText } from "./record-formatting.js";

interface RowPresentationOptions {
  relativeKeyPath?: string[];
}

function preferredDescription(record: FlatIndexRecord): string | undefined {
  const description = record.description?.trim();
  if (description) {
    return description;
  }

  const aiDescription = record.aiDescription?.trim();
  return aiDescription || undefined;
}

function compactActionSummary(record: FlatIndexRecord): string {
  if (record.kind === "group") {
    const count = record.childCount ?? 0;
    return `${record.displayLabel} · ${count} item${count === 1 ? "" : "s"}`;
  }
  if (record.kind === "layer") {
    const count = record.childCount ?? 0;
    const tap = record.tapAction ? " · tap action" : "";
    return `${record.displayLabel} layer · ${count} item${count === 1 ? "" : "s"}${tap}`;
  }

  const note = preferredDescription(record);
  const label = record.displayLabel.trim();
  const withNote = (summary: string): string => {
    if (!note || note === summary) {
      return summary;
    }

    return `${truncateText(note)} · ${summary}`;
  };

  switch (record.actionType) {
    case "application":
      return withNote(`↗ ${record.valuePreview || label}`);
    case "command":
      return withNote(`› ${truncateText(label.replace(/^Run\s+/i, "") || record.valuePreview)}`);
    case "folder":
      return withNote(`↗ ${record.valuePreview || label}`);
    case "intellij":
      return withNote(`IJ ${truncateText(label.replace(/^IntelliJ:\s*/i, "") || record.valuePreview)}`);
    case "keystroke":
      return withNote(`⌨ ${label.replace(/^Keystroke:\s*/i, "") || record.valuePreview}`);
    case "macro":
      return withNote(`M ${label.replace(/^Macro:\s*/i, "") || record.valuePreview || "Macro"}`);
    case "menu":
      return withNote(`☰ ${label}`);
    case "shortcut":
      return withNote(`⌨ ${label.replace(/^Shortcut:\s*/i, "") || record.valuePreview}`);
    case "text":
      return withNote(`✎ ${truncateText(label.replace(/^Type\s+/i, "") || record.valuePreview)}`);
    case "normalModeDisable":
      return withNote("N Off");
    case "normalModeEnable":
      return withNote("N On");
    case "normalModeInput":
      return withNote("N Input");
    case "toggleStickyMode":
      return withNote("⇄ Sticky");
    case "url":
      return withNote(label.replace(/^Open\s+/i, "↗ "));
  }

  return withNote(truncateText(label || record.valuePreview || record.rawValue || record.actionType));
}

function subtitleTooltip(record: FlatIndexRecord): string {
  const parts = [record.displayLabel];

  if (record.description) {
    parts.push(`Description: ${record.description}`);
  }

  if (record.aiDescription) {
    parts.push(`AI Description: ${record.aiDescription}`);
  }

  if (record.rawValue && record.rawValue !== record.displayLabel) {
    parts.push(record.rawValue);
  } else if (record.valuePreview && record.valuePreview !== record.displayLabel) {
    parts.push(record.valuePreview);
  }

  if (record.inherited) {
    parts.push(`Inherited from ${record.sourceConfigDisplayName}`);
  }

  return parts.join("\n");
}

function recordStatusAccessories(record: FlatIndexRecord, options?: RowPresentationOptions): List.Item.Accessory[] | undefined {
  const statusParts: string[] = [];
  const tooltipParts: string[] = [];

  if (options?.relativeKeyPath && options.relativeKeyPath.length > 1) {
    statusParts.push(`↳${options.relativeKeyPath.length}`);
    tooltipParts.push(`${options.relativeKeyPath.length} levels below the current group`);
  }

  if (record.inherited) {
    statusParts.push("fb");
    tooltipParts.push(`Inherited from ${record.sourceConfigDisplayName}`);
  }

  if (statusParts.length === 0) {
    return undefined;
  }

  return [
    {
      text: statusParts.join(" "),
      tooltip: tooltipParts.join("\n"),
    },
  ];
}

export function recordIcon(record: FlatIndexRecord): Image.ImageLike {
  if (record.kind === "group") {
    return Icon.Folder;
  }
  if (record.kind === "layer") {
    return Icon.Layers;
  }

  switch (record.actionType) {
    case "application":
      return record.rawValue ? { fileIcon: record.rawValue } : Icon.AppWindow;
    case "command":
      return Icon.Terminal;
    case "folder":
      return record.rawValue ? { fileIcon: record.rawValue } : Icon.Folder;
    case "intellij":
      return Icon.Hammer;
    case "keystroke":
    case "shortcut":
      return Icon.Keyboard;
    case "macro":
      return Icon.List;
    case "menu":
      return Icon.AppWindowSidebarLeft;
    case "text":
      return Icon.Text;
    case "normalModeDisable":
    case "normalModeEnable":
    case "normalModeInput":
      return Icon.Switch;
    case "toggleStickyMode":
      return Icon.Bolt;
    case "url":
      return Icon.Link;
  }

  return Icon.Circle;
}

export function buildRowPresentation(
  record: FlatIndexRecord,
  options?: RowPresentationOptions,
): Pick<List.Item.Props, "accessories" | "subtitle" | "title"> {
  const titleValue = options?.relativeKeyPath
    ? keyPathText(options.relativeKeyPath) || canonicalSequenceText(record)
    : canonicalSequenceText(record);

  return {
    accessories: recordStatusAccessories(record, options),
    subtitle: {
      tooltip: subtitleTooltip(record),
      value: truncateText(compactActionSummary(record)),
    },
    title: {
      tooltip: fullPathText(record),
      value: titleValue,
    },
  };
}
