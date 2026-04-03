import { Action, ActionPanel, Icon, Keyboard, List, Toast, environment, showToast } from "@raycast/api";
import {
  locateNodeInFile,
  openInEditor,
  searchRecords,
  type CachePayload,
  type FlatIndexRecord,
} from "@leaderkey/config-core";
import { useEffect, useState } from "react";

import { loadIndex } from "./cache.js";
import { ConfigNodesList } from "./browser.js";
import { recordListItemDetail, RecordDetailView } from "./detail.js";
import { buildPathEditorDeeplink, configTargetForSummary } from "./deeplinks.js";
import { RecordEditorForm } from "./editor-form.js";
import { getExtensionPreferences } from "./preferences.js";
import { buildRowPresentation, recordIcon } from "./presentation.js";

const MAX_VISIBLE_RESULTS = 300;

function browseTargetPath(record: FlatIndexRecord): string[] {
  return record.kind === "group" ? record.effectiveKeyPath : record.parentEffectiveKeyPath;
}

export default function SearchShortcutsCommand() {
  const { configDirectory, preferredEditor } = getExtensionPreferences();
  const [payload, setPayload] = useState<CachePayload>();
  const [isLoading, setIsLoading] = useState(true);
  const [searchText, setSearchText] = useState("");
  const [selectedId, setSelectedId] = useState<string>();
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;

  useEffect(() => {
    let isMounted = true;

    async function load(): Promise<void> {
      const result = await loadIndex(configDirectory);
      if (!isMounted) {
        return;
      }
      if (result.cached) {
        setPayload(result.cached);
      }
      if (result.fresh) {
        setPayload(result.fresh);
      }
      setIsLoading(false);
    }

    void load();
    return () => {
      isMounted = false;
    };
  }, [configDirectory]);

  const results = payload ? searchRecords(payload.records, searchText) : [];
  const visibleResults = results.slice(0, MAX_VISIBLE_RESULTS);

  useEffect(() => {
    if (visibleResults.length === 0) {
      setSelectedId(undefined);
      return;
    }

    if (!selectedId || !visibleResults.some((record) => record.id === selectedId)) {
      setSelectedId(visibleResults[0]!.id);
    }
  }, [selectedId, visibleResults]);

  async function handleOpenInEditor(recordId: string): Promise<void> {
    const record = payload?.records.find((candidate) => candidate.id === recordId);
    if (!record) {
      return;
    }

    try {
      const location = await locateNodeInFile(record.sourceConfigPath, record.sourceNodePath);
      await openInEditor(preferredEditor, {
        column: location.column,
        filePath: record.sourceConfigPath,
        line: location.line,
      });
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Open in editor failed",
        message: error instanceof Error ? error.message : String(error),
      });
    }
  }

  function pathEditorDeeplink(record: FlatIndexRecord): string | undefined {
    const configSummary = payload?.configs.find((config) => config.filePath === record.effectiveConfigPath);
    if (!configSummary) {
      return undefined;
    }

    return buildPathEditorDeeplink(
      configTargetForSummary(configSummary),
      ownerOrAuthorName,
      extensionName,
      record.effectiveKeyPath.join(""),
    );
  }

  return (
    <List
      isLoading={isLoading}
      isShowingDetail
      onSearchTextChange={setSearchText}
      onSelectionChange={(id) => setSelectedId(id ?? undefined)}
      searchBarPlaceholder="Search shortcuts, apps, keys"
    >
      {visibleResults.map((record) => {
        const row = buildRowPresentation(record);
        const isSelected = selectedId === record.id;
        const showDetailsShortcut: Keyboard.Shortcut = record.kind === "group"
          ? { modifiers: ["cmd"], key: "return" }
          : { modifiers: ["cmd"], key: "." };

        return (
          <List.Item
            accessories={row.accessories}
            detail={isSelected ? recordListItemDetail(record) : undefined}
            id={record.id}
            icon={recordIcon(record)}
            key={record.id}
            subtitle={row.subtitle}
            title={row.title}
            actions={
              <ActionPanel>
                {record.kind === "group" ? (
                  <Action.Push
                    icon={Icon.ChevronRight}
                    shortcut={{ key: "return", modifiers: [] }}
                    target={
                      <ConfigNodesList
                        configDirectory={configDirectory}
                        configDisplayName={record.effectiveConfigDisplayName}
                        initialPayload={payload!}
                        onDidMutate={setPayload}
                        parentEffectiveKeyPath={record.effectiveKeyPath}
                        preferredEditor={preferredEditor}
                      />
                    }
                    title="Open Group"
                  />
                ) : (
                  <Action.Push
                    icon={Icon.Pencil}
                    shortcut={{ key: "return", modifiers: [] }}
                    target={
                      <RecordEditorForm
                        configDirectory={configDirectory}
                        mode="edit-source"
                        onDidSave={async (nextPayload) => {
                          setPayload(nextPayload);
                        }}
                        targetRecord={record}
                        title={record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`}
                      />
                    }
                    title={record.inherited ? "Edit Fallback Source" : "Edit Item"}
                  />
                )}
                <Action.Push
                  icon={Icon.Sidebar}
                  shortcut={showDetailsShortcut}
                  target={<RecordDetailView record={record} />}
                  title="Show Details"
                />
                <Action
                  icon={Icon.Code}
                  onAction={() => void handleOpenInEditor(record.id)}
                  shortcut={record.kind === "action" ? { modifiers: ["cmd"], key: "return" } : undefined}
                  title="Open in Editor"
                />
                {pathEditorDeeplink(record) ? (
                  <Action.Open
                    icon={Icon.AppWindowSidebarLeft}
                    shortcut={{ modifiers: ["ctrl", "cmd"], key: "p" }}
                    target={pathEditorDeeplink(record)!}
                    title="Open in Path Editor"
                  />
                ) : null}
                <Action.Push
                  icon={Icon.ChevronRight}
                  shortcut={{ modifiers: ["cmd"], key: "o" }}
                  target={
                    <ConfigNodesList
                      configDirectory={configDirectory}
                      configDisplayName={record.effectiveConfigDisplayName}
                      initialPayload={payload!}
                      onDidMutate={setPayload}
                      parentEffectiveKeyPath={browseTargetPath(record)}
                      preferredEditor={preferredEditor}
                    />
                  }
                  title={record.kind === "group" ? "Browse Group in Config" : "Browse in Config"}
                />
                {record.kind === "group" ? (
                  <Action.Push
                    icon={Icon.Pencil}
                    shortcut={Keyboard.Shortcut.Common.Edit}
                    target={
                      <RecordEditorForm
                        configDirectory={configDirectory}
                        mode="edit-source"
                        onDidSave={async (nextPayload) => {
                          setPayload(nextPayload);
                        }}
                        targetRecord={record}
                        title={record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`}
                      />
                    }
                    title={record.inherited ? "Edit Fallback Source" : "Edit Item"}
                  />
                ) : null}
                {record.inherited ? (
                  <Action.Push
                    icon={Icon.PlusCircle}
                    shortcut={{ modifiers: ["cmd", "shift"], key: "e" }}
                    target={
                      <RecordEditorForm
                        configDirectory={configDirectory}
                        mode="override-in-effective-config"
                        onDidSave={async (nextPayload) => {
                          setPayload(nextPayload);
                        }}
                        targetRecord={record}
                        title={`Create Override for ${record.displayLabel}`}
                      />
                    }
                    title="Create App Override"
                  />
                ) : null}
              </ActionPanel>
            }
          />
        );
      })}
    </List>
  );
}
