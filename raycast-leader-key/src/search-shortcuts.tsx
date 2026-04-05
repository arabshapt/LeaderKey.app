import {
  Action,
  ActionPanel,
  Alert,
  confirmAlert,
  Icon,
  Keyboard,
  List,
  Toast,
  environment,
  showToast,
} from "@raycast/api";
import {
  deleteRecord,
  locateNodeInFile,
  openInEditor,
  searchRecords,
  triggerLeaderKeyConfigReload,
  type CachePayload,
  type FlatIndexRecord,
} from "@leaderkey/config-core";
import { useEffect, useState } from "react";

import { rebuildIndex } from "./cache.js";
import { ConfigNodesList } from "./browser.js";
import { copyRecordToInternalClipboard } from "./clipboard.js";
import { recordListItemDetail, RecordDetailView } from "./detail.js";
import { buildPathEditorDeeplink, configTargetForSummary } from "./deeplinks.js";
import { RecordEditorForm } from "./editor-form.js";
import { getExtensionPreferences } from "./preferences.js";
import { buildRowPresentation, recordIcon } from "./presentation.js";
import { keyPathText } from "./record-formatting.js";
import { TypedPathCreatePicker } from "./typed-path-create-picker.js";
import { useIndexPayload } from "./use-index-payload.js";

const MAX_VISIBLE_RESULTS = 300;

function browseTargetPath(record: FlatIndexRecord): string[] {
  return record.kind === "group" ? record.effectiveKeyPath : record.parentEffectiveKeyPath;
}

export default function SearchShortcutsCommand() {
  const { configDirectory, preferredEditor } = getExtensionPreferences();
  const { payload, setPayload, isInitialLoading, isRefreshing, loadError, loadingSubtitle, reload } = useIndexPayload(configDirectory);
  const [searchText, setSearchText] = useState("");
  const [selectedId, setSelectedId] = useState<string>();
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;
  const literalTypedPath = Array.from(searchText.trim());
  const typedPathTitle = literalTypedPath.length > 0 ? keyPathText(literalTypedPath) : undefined;
  const typedPathItemIds = typedPathTitle ? ["typed-path:create-action", "typed-path:create-group"] : [];

  const results = payload ? searchRecords(payload.records, searchText) : [];
  const visibleResults = results.slice(0, MAX_VISIBLE_RESULTS);
  const combinedIds = [...typedPathItemIds, ...visibleResults.map((record) => record.id)];
  const activeSelectedId = selectedId && combinedIds.includes(selectedId)
    ? selectedId
    : combinedIds[0];

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

  async function handleCopy(record: FlatIndexRecord): Promise<void> {
    try {
      const clipboardPayload = await copyRecordToInternalClipboard(record);
      await showToast({
        style: Toast.Style.Success,
        title: clipboardPayload.kind === "group" ? "Copied group" : "Copied action",
        message: clipboardPayload.sourceDisplayLabel,
      });
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Copy failed",
        message: error instanceof Error ? error.message : String(error),
      });
    }
  }

  async function handleDelete(record: FlatIndexRecord): Promise<void> {
    const confirmed = await confirmAlert({
      title: `Delete ${record.displayLabel}?`,
      message: "This removes the item from the source config file.",
      primaryAction: {
        style: Alert.ActionStyle.Destructive,
        title: "Delete",
      },
    });

    if (!confirmed) {
      return;
    }

    try {
      await deleteRecord(record);

      let syncError: unknown;
      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const nextPayload = await rebuildIndex(configDirectory);
      setPayload(nextPayload);

      await showToast(
        syncError
          ? {
              style: Toast.Style.Failure,
              title: "Deleted item, but Leader Key sync failed",
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: "Deleted config item",
              message: "Triggered Leader Key reload",
            },
      );
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Delete failed",
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

  function editorForm(
    mode: "append-child" | "create-sibling" | "edit-source" | "override-in-effective-config",
    record: FlatIndexRecord,
    title: string,
  ) {
    return (
      <RecordEditorForm
        configDirectory={configDirectory}
        initialType={mode === "append-child" || mode === "create-sibling" ? "shortcut" : undefined}
        mode={mode}
        onDidSave={async (nextPayload) => {
          setPayload(nextPayload);
        }}
        targetRecord={record}
        title={title}
      />
    );
  }

  if (!payload) {
    if (loadError) {
      return (
        <List
          key={`error:${configDirectory}`}
          isShowingDetail
          searchBarPlaceholder="Search shortcuts, apps, keys"
        >
          <List.Item
            id="shortcuts-index-load-error"
            icon={Icon.ExclamationMark}
            title="Couldn’t load Leader Key shortcuts"
            subtitle={loadError}
            actions={
              <ActionPanel>
                <Action
                  icon={Icon.ArrowClockwise}
                  onAction={reload}
                  title="Retry Loading Index"
                />
              </ActionPanel>
            }
          />
        </List>
      );
    }

    return (
      <List
        key={`loading:${configDirectory}`}
        isLoading={isInitialLoading}
        isShowingDetail
        searchBarPlaceholder="Search shortcuts, apps, keys"
      >
        <List.Item
          id="loading-shortcuts"
          title="Loading shortcuts…"
          subtitle={loadingSubtitle}
        />
      </List>
    );
  }

  return (
    <List
      filtering={false}
      key={`ready:${payload.fingerprint}`}
      isLoading={isRefreshing}
      isShowingDetail
      onSearchTextChange={setSearchText}
      onSelectionChange={(id) => setSelectedId(id ?? undefined)}
      searchBarPlaceholder="Search shortcuts, apps, keys"
    >
      {typedPathTitle ? (
        <List.Section title="Create by Typed Path">
          <List.Item
            detail={activeSelectedId === "typed-path:create-action" ? (
              <List.Item.Detail
                markdown={[
                  "# Create Action by Typed Path",
                  "",
                  `Treat \`${searchText.trim()}\` as the literal Leader Key sequence \`${typedPathTitle}\`.`,
                  "",
                  "Pick a config next and create an action there.",
                ].join("\n")}
              />
            ) : undefined}
            icon={Icon.Plus}
            id="typed-path:create-action"
            title={`Create Action at ${typedPathTitle}`}
            subtitle={`Treat "${searchText.trim()}" as literal keys`}
            actions={
              <ActionPanel>
                <Action.Push
                  icon={Icon.Plus}
                  shortcut={{ modifiers: ["cmd"], key: "n" }}
                  target={
                    <TypedPathCreatePicker
                      configDirectory={configDirectory}
                      initialPayload={payload}
                      itemType="shortcut"
                      literalPath={literalTypedPath}
                      onDidSave={setPayload}
                    />
                  }
                  title="Choose Config for Action"
                />
              </ActionPanel>
            }
          />
          <List.Item
            detail={activeSelectedId === "typed-path:create-group" ? (
              <List.Item.Detail
                markdown={[
                  "# Create Group by Typed Path",
                  "",
                  `Treat \`${searchText.trim()}\` as the literal Leader Key sequence \`${typedPathTitle}\`.`,
                  "",
                  "Pick a config next and create a group there.",
                ].join("\n")}
              />
            ) : undefined}
            icon={Icon.NewFolder}
            id="typed-path:create-group"
            title={`Create Group at ${typedPathTitle}`}
            subtitle={`Treat "${searchText.trim()}" as literal keys`}
            actions={
              <ActionPanel>
                <Action.Push
                  icon={Icon.NewFolder}
                  shortcut={{ modifiers: ["cmd", "shift"], key: "n" }}
                  target={
                    <TypedPathCreatePicker
                      configDirectory={configDirectory}
                      initialPayload={payload}
                      itemType="group"
                      literalPath={literalTypedPath}
                      onDidSave={setPayload}
                    />
                  }
                  title="Choose Config for Group"
                />
              </ActionPanel>
            }
          />
        </List.Section>
      ) : null}
      {visibleResults.map((record) => {
        const row = buildRowPresentation(record);
        const isSelected = activeSelectedId === record.id;
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
                  icon={Icon.CopyClipboard}
                  onAction={() => void handleCopy(record)}
                  shortcut={{ modifiers: ["cmd"], key: "c" }}
                  title={record.kind === "group" ? "Copy Group" : "Copy Action"}
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
                      editorForm(
                        "edit-source",
                        record,
                        record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`,
                      )
                    }
                    title={record.inherited ? "Edit Fallback Source" : "Edit Group"}
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
                <Action.Push
                  icon={Icon.Plus}
                  shortcut={{ modifiers: ["cmd"], key: "n" }}
                  target={editorForm("create-sibling", record, `Create Sibling After ${record.displayLabel}`)}
                  title="Create Sibling Action"
                />
                <Action.Push
                  icon={Icon.NewFolder}
                  shortcut={{ modifiers: ["cmd", "shift"], key: "n" }}
                  target={
                    <RecordEditorForm
                      configDirectory={configDirectory}
                      initialType="group"
                      mode="create-sibling"
                      onDidSave={async (nextPayload) => {
                        setPayload(nextPayload);
                      }}
                      targetRecord={record}
                      title={`Create Sibling Group After ${record.displayLabel}`}
                    />
                  }
                  title="Create Sibling Group"
                />
                {record.kind === "group" ? (
                  <>
                    <Action.Push
                      icon={Icon.Plus}
                      shortcut={{ modifiers: ["ctrl", "cmd"], key: "n" }}
                      target={editorForm("append-child", record, `Append Child to ${record.displayLabel}`)}
                      title="Append Child Action"
                    />
                    <Action.Push
                      icon={Icon.NewFolder}
                      shortcut={{ modifiers: ["ctrl", "cmd", "shift"], key: "n" }}
                      target={
                        <RecordEditorForm
                          configDirectory={configDirectory}
                          initialType="group"
                          mode="append-child"
                          onDidSave={async (nextPayload) => {
                            setPayload(nextPayload);
                          }}
                          targetRecord={record}
                          title={`Append Child Group to ${record.displayLabel}`}
                        />
                      }
                      title="Append Child Group"
                    />
                  </>
                ) : null}
                {!record.inherited ? (
                  <Action
                    icon={Icon.Trash}
                    onAction={() => void handleDelete(record)}
                    shortcut={{ modifiers: ["cmd"], key: "backspace" }}
                    style={Action.Style.Destructive}
                    title="Delete"
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
