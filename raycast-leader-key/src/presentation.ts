import { Icon, type Image, type List } from "@raycast/api";
import type { FlatIndexRecord } from "@leaderkey/config-core";
import { canonicalSequenceText, fullPathText, truncateText } from "./record-formatting.js";

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

function recordStatusAccessories(record: FlatIndexRecord): List.Item.Accessory[] | undefined {
  if (!record.inherited) {
    return undefined;
  }

  return [
    {
      text: "fallback",
      tooltip: `Inherited from ${record.sourceConfigDisplayName}`,
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

export function buildRowPresentation(record: FlatIndexRecord): Pick<List.Item.Props, "accessories" | "subtitle" | "title"> {
  return {
    accessories: recordStatusAccessories(record),
    subtitle: {
      tooltip: subtitleTooltip(record),
      value: truncateText(compactActionSummary(record)),
    },
    title: {
      tooltip: fullPathText(record),
      value: canonicalSequenceText(record),
    },
  };
}
