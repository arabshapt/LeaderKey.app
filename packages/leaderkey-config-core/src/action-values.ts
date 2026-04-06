export interface ParsedIntellijActionValue {
  actionIds: string[];
  delayMs?: number;
}

export interface ParsedMenuActionValue {
  appName?: string;
  path: string;
  pathSegments: string[];
}

function splitMenuValue(rawValue: string): string[] {
  return rawValue.split(" > ").map((part) => part.trim()).filter(Boolean);
}

export function parseMenuActionValue(rawValue: string): ParsedMenuActionValue {
  const hasTrailingDelimiter = />\s*$/.test(rawValue);
  const parts = splitMenuValue(rawValue);
  if (parts.length === 0) {
    return { appName: undefined, path: "", pathSegments: [] };
  }

  if (hasTrailingDelimiter && parts.length === 1) {
    return {
      appName: parts[0]!,
      path: "",
      pathSegments: [],
    };
  }

  if (parts.length === 1) {
    return {
      appName: undefined,
      path: parts[0]!,
      pathSegments: [parts[0]!],
    };
  }

  const pathSegments = parts.slice(1);
  return {
    appName: parts[0],
    path: pathSegments.join(" > "),
    pathSegments,
  };
}

export function encodeMenuActionValue(input: { appName?: string; path: string }): string {
  const appName = input.appName?.trim();
  const path = input.path
    .split(">")
    .map((part) => part.trim())
    .filter(Boolean)
    .join(" > ");

  if (!appName) {
    return path;
  }

  return path ? `${appName} > ${path}` : `${appName} > `;
}

export function parseIntellijActionValue(rawValue: string): ParsedIntellijActionValue {
  const [actionsPart, delayPart] = rawValue.split("|");
  const actionIds = actionsPart
    .split(",")
    .map((action) => action.trim())
    .filter(Boolean);

  const delayMs = delayPart?.trim() ? Number.parseInt(delayPart.trim(), 10) : undefined;
  return {
    actionIds,
    delayMs: Number.isFinite(delayMs) ? delayMs : undefined,
  };
}

export function encodeIntellijActionValue(input: { actionIds: string[]; delayMs?: number }): string {
  const actionIds = input.actionIds.map((actionId) => actionId.trim()).filter(Boolean);
  const actionValue = actionIds.join(",");
  if (!actionValue) {
    return "";
  }

  if (input.delayMs === undefined || !Number.isFinite(input.delayMs)) {
    return actionValue;
  }

  return `${actionValue}|${Math.trunc(input.delayMs)}`;
}
