import { Action, ActionPanel, Icon, List, useNavigation } from "@raycast/api";
import { useEffect, useMemo, useState } from "react";

import { explainIntelliJAction, searchIntelliJActions, type IntelliJActionExplain } from "./intellij-actions.js";

interface IntelliJActionPickerProps {
  currentActionIds: string[];
  onAppend: (actionId: string) => void;
  title: string;
}

function explainMarkdown(explain: IntelliJActionExplain | undefined): string {
  if (!explain) {
    return "Loading action details…";
  }

  const lines = [
    `**Action ID**: ${explain.actionId}`,
    `**Category**: ${explain.category ?? "Unknown"}`,
    `**Recommended Delay**: ${explain.smartDelay ?? 0} ms`,
    "",
    explain.description ?? "No description available.",
  ];

  if (explain.requirements) {
    lines.push(
      "",
      `Needs editor: ${explain.requirements.needsEditor ? "Yes" : "No"}`,
      `Needs file: ${explain.requirements.needsFile ? "Yes" : "No"}`,
      `Needs project: ${explain.requirements.needsProject ? "Yes" : "No"}`,
      `Needs Git: ${explain.requirements.needsGit ? "Yes" : "No"}`,
      `Needs build system: ${explain.requirements.needsBuildSystem ? "Yes" : "No"}`,
    );
  }

  return lines.join("\n");
}

export function IntelliJActionPicker(props: IntelliJActionPickerProps) {
  const { currentActionIds, onAppend, title } = props;
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

  const selectedExplain = selectedActionId ? explainById[selectedActionId] : undefined;
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
          detail={<List.Item.Detail markdown={selectedActionId === actionId ? explainMarkdown(selectedExplain) : "Select an action to inspect it."} />}
          icon={Icon.Bolt}
          key={actionId}
          subtitle={explainById[actionId]?.description ?? explainById[actionId]?.category}
          title={actionId}
        />
      ))}
    </List>
  );
}
