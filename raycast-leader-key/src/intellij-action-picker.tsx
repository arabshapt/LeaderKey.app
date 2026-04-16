import { Action, ActionPanel, Icon, List, useNavigation } from "@raycast/api";
import { useEffect, useMemo, useState } from "react";

import {
  explainIntelliJAction,
  humanizeIntelliJActionId,
  intellijActionClassName,
  searchIntelliJActions,
  type IntelliJActionExplain,
} from "./intellij-actions.js";

interface IntelliJActionPickerProps {
  currentActionIds: string[];
  currentDelayMs?: number;
  onAppend: (actionId: string) => void;
  title: string;
}

function formatActionString(actionIds: string[], delayMs: number | undefined): string {
  const actionString = actionIds.join(",");
  if (!actionString) {
    return "Empty";
  }

  return delayMs === undefined ? actionString : `${actionString}|${delayMs}`;
}

function unknownFieldMarkdownValue(value: unknown): string | undefined {
  if (value === undefined || value === null) {
    return undefined;
  }
  if (typeof value === "string") {
    return value || undefined;
  }
  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }
  if (Array.isArray(value) && value.every((item) => typeof item === "string")) {
    return value.length > 0 ? value.join(", ") : undefined;
  }

  const json = JSON.stringify(value);
  if (!json || json === "{}" || json === "[]") {
    return undefined;
  }
  return json.length > 500 ? `${json.slice(0, 500)}...` : json;
}

function extraMetadataMarkdown(explain: IntelliJActionExplain): string[] {
  const renderedKeys = new Set([
    "actionId",
    "category",
    "className",
    "description",
    "exists",
    "group",
    "name",
    "pluginId",
    "pluginName",
    "presentation",
    "requirements",
    "shortcuts",
    "smartDelay",
    "text",
  ]);

  const rows = Object.entries(explain)
    .filter(([key]) => !renderedKeys.has(key))
    .map(([key, value]) => {
      const formatted = unknownFieldMarkdownValue(value);
      return formatted ? `- **${key}**: ${formatted}` : undefined;
    })
    .filter((row): row is string => Boolean(row));

  return rows.length > 0 ? ["", "## Additional Metadata", ...rows] : [];
}

function explainMarkdown(
  actionId: string,
  explain: IntelliJActionExplain | undefined,
  currentActionIds: string[],
  currentDelayMs: number | undefined,
): string {
  const appendedActionIds = [...currentActionIds, actionId];
  const title = explain?.text
    ?? explain?.presentation?.text
    ?? explain?.name
    ?? humanizeIntelliJActionId(actionId);
  const description = explain?.description
    ?? explain?.presentation?.description
    ?? "No description available from the IntelliJ custom server.";
  const lines = [
    `**Title**: ${title}`,
    `**Action ID**: ${explain?.actionId ?? actionId}`,
    `**Action Class**: ${explain?.className ?? intellijActionClassName(actionId)}`,
    `**Action String After Append**: ${formatActionString(appendedActionIds, currentDelayMs)}`,
    `**Current Action String**: ${formatActionString(currentActionIds, currentDelayMs)}`,
    `**Already in Current Action**: ${currentActionIds.includes(actionId) ? "Yes" : "No"}`,
    "",
  ];

  if (!explain) {
    lines.push("Loading metadata from the IntelliJ custom server…");
    return lines.join("\n");
  }

  lines.push(
    `**Exists**: ${explain.exists === undefined ? "Unknown" : explain.exists ? "Yes" : "No"}`,
    `**Category**: ${explain.category ?? "Unknown"}`,
    `**Group**: ${explain.group ?? "Unknown"}`,
    `**Plugin**: ${explain.pluginName ?? explain.pluginId ?? "Unknown"}`,
    `**Recommended Delay**: ${explain.smartDelay ?? 0} ms`,
    `**Shortcuts**: ${explain.shortcuts?.length ? explain.shortcuts.join(", ") : "None known"}`,
    "",
    description,
  );

  if (explain.requirements) {
    lines.push(
      "",
      "## Requirements",
      `- Editor: ${explain.requirements.needsEditor ? "Required" : "Not required"}`,
      `- File: ${explain.requirements.needsFile ? "Required" : "Not required"}`,
      `- Project: ${explain.requirements.needsProject ? "Required" : "Not required"}`,
      `- Git: ${explain.requirements.needsGit ? "Required" : "Not required"}`,
      `- Build system: ${explain.requirements.needsBuildSystem ? "Required" : "Not required"}`,
    );
  }

  lines.push(...extraMetadataMarkdown(explain));

  return lines.join("\n");
}

export function IntelliJActionPicker(props: IntelliJActionPickerProps) {
  const { currentActionIds, currentDelayMs, onAppend, title } = props;
  const [searchText, setSearchText] = useState("");
  const [results, setResults] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string>();
  const [selectedActionId, setSelectedActionId] = useState<string>();
  const [explainById, setExplainById] = useState<Record<string, IntelliJActionExplain>>({});
  const { pop } = useNavigation();

  useEffect(() => {
    let isMounted = true;
    const trimmedSearch = searchText.trim();

    if (!trimmedSearch) {
      setResults([]);
      setError(undefined);
      setIsLoading(false);
      return () => {
        isMounted = false;
      };
    }

    setIsLoading(true);
    setError(undefined);

    void searchIntelliJActions(trimmedSearch)
      .then((nextResults) => {
        if (isMounted) {
          setResults(nextResults);
        }
      })
      .catch((searchError) => {
        if (isMounted) {
          setResults([]);
          setError(searchError instanceof Error ? searchError.message : String(searchError));
        }
      })
      .finally(() => {
        if (isMounted) {
          setIsLoading(false);
        }
      });

    return () => {
      isMounted = false;
    };
  }, [searchText]);

  useEffect(() => {
    const nextSelectedActionId = selectedActionId && results.includes(selectedActionId)
      ? selectedActionId
      : results[0];

    if (nextSelectedActionId !== selectedActionId) {
      setSelectedActionId(nextSelectedActionId);
    }
  }, [results, selectedActionId]);

  useEffect(() => {
    const actionId = selectedActionId?.trim();
    if (!actionId || explainById[actionId]) {
      return;
    }

    let isMounted = true;
    void explainIntelliJAction(actionId)
      .then((nextExplain) => {
        if (isMounted) {
          setExplainById((current) => ({ ...current, [actionId]: nextExplain }));
        }
      })
      .catch(() => {
        if (isMounted) {
          setExplainById((current) => ({
            ...current,
            [actionId]: {
              actionId,
              description: "No action metadata available from the IntelliJ custom server.",
            },
          }));
        }
      });

    return () => {
      isMounted = false;
    };
  }, [explainById, selectedActionId]);

  const duplicateCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const actionId of currentActionIds) {
      counts.set(actionId, (counts.get(actionId) ?? 0) + 1);
    }
    return counts;
  }, [currentActionIds]);

  return (
    <List
      filtering={false}
      isLoading={isLoading}
      isShowingDetail
      navigationTitle={title}
      onSearchTextChange={setSearchText}
      onSelectionChange={(id) => setSelectedActionId(id ?? undefined)}
      searchBarPlaceholder="Search IntelliJ action IDs"
    >
      {!isLoading && error ? (
        <List.EmptyView
          description={error}
          title="IntelliJ Search Unavailable"
        />
      ) : null}
      {!isLoading && !error && !searchText.trim() ? (
        <List.EmptyView
          description="Type part of an IntelliJ action ID to search the custom server."
          title="Start Typing to Search"
        />
      ) : null}
      {!isLoading && !error && searchText.trim() && results.length === 0 ? (
        <List.EmptyView
          description={`No IntelliJ actions matched "${searchText.trim()}".`}
          title="No Actions Found"
        />
      ) : null}
      {results.map((actionId) => (
        <List.Item
          actions={
            <ActionPanel>
              <Action
                icon={Icon.Plus}
                onAction={() => {
                  onAppend(actionId);
                  pop();
                }}
                title="Append IntelliJ Action"
              />
            </ActionPanel>
          }
          accessories={[
            ...(duplicateCounts.get(actionId)
              ? [{ text: `Already in list x${duplicateCounts.get(actionId)}` }]
              : []),
            ...(explainById[actionId]?.smartDelay !== undefined
              ? [{ text: `${explainById[actionId]!.smartDelay}ms` }]
              : []),
          ]}
          detail={<List.Item.Detail markdown={explainMarkdown(actionId, explainById[actionId], currentActionIds, currentDelayMs)} />}
          icon={Icon.Bolt}
          id={actionId}
          key={actionId}
          subtitle={explainById[actionId]?.description ?? explainById[actionId]?.presentation?.description ?? explainById[actionId]?.category}
          title={explainById[actionId]?.text ?? explainById[actionId]?.presentation?.text ?? humanizeIntelliJActionId(actionId)}
        />
      ))}
    </List>
  );
}
