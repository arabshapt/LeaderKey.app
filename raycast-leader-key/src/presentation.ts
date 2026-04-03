import { Icon, type Image, type List } from "@raycast/api";
import type { FlatIndexRecord } from "@leaderkey/config-core";
import { canonicalSequenceText, fullPathText, keyPathText, truncateText } from "./record-formatting.js";

interface RowPresentationOptions {
  relativeKeyPath?: string[];
}

function compactActionSummary(record: FlatIndexRecord): string {
  if (record.kind === "group") {
    const count = record.childCount ?? 0;
    return `${record.displayLabel} · ${count} item${count === 1 ? "" : "s"}`;
  }

  const label = record.displayLabel.trim();

  switch (record.actionType) {
    case "application":
      return `↗ ${record.valuePreview || label}`;
    case "command":
      return `› ${truncateText(label.replace(/^Run\s+/i, "") || record.valuePreview)}`;
    case "folder":
      return `↗ ${record.valuePreview || label}`;
    case "intellij":
      return `IJ ${truncateText(label.replace(/^IntelliJ:\s*/i, "") || record.valuePreview)}`;
    case "keystroke":
      return `⌨ ${label.replace(/^Keystroke:\s*/i, "") || record.valuePreview}`;
    case "macro":
      return `M ${label.replace(/^Macro:\s*/i, "") || record.valuePreview || "Macro"}`;
    case "menu":
      return `☰ ${label}`;
    case "shortcut":
      return `⌨ ${label.replace(/^Shortcut:\s*/i, "") || record.valuePreview}`;
    case "text":
      return `✎ ${truncateText(label.replace(/^Type\s+/i, "") || record.valuePreview)}`;
    case "toggleStickyMode":
      return "⇄ Sticky";
    case "url":
      return label.replace(/^Open\s+/i, "↗ ");
  }

  return truncateText(label || record.valuePreview || record.rawValue || record.actionType);
}

function subtitleTooltip(record: FlatIndexRecord): string {
  const parts = [record.displayLabel];

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
