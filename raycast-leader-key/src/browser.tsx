import {
  Action,
  ActionPanel,
  Alert,
  confirmAlert,
  environment,
  Icon,
  Keyboard,
  List,
  Toast,
  showToast,
  useNavigation,
} from "@raycast/api";
import {
  createItemAtPath,
  deleteRecord,
  locateNodeInFile,
  openInEditor,
  searchRecordsInSubtree,
  triggerLeaderKeyConfigReload,
  type CachePayload,
  type EditorId,
  type FlatIndexRecord,
} from "@leaderkey/config-core";
import { useEffect, useState } from "react";

import { rebuildIndex } from "./cache.js";
import { copyRecordToInternalClipboard, readInternalClipboard } from "./clipboard.js";
import { recordListItemDetail, RecordDetailView } from "./detail.js";
import { buildPathEditorDeeplink, configTargetForSummary } from "./deeplinks.js";
import { RecordEditorForm } from "./editor-form.js";
import { itemToFormState } from "./form-utils.js";
import { buildRowPresentation, recordIcon } from "./presentation.js";

interface ConfigNodesListProps {
  configDirectory: string;
  configDisplayName: string;
  initialPayload: CachePayload;
  onDidMutate: (payload: CachePayload) => void;
  parentEffectiveKeyPath?: string[];
  preferredEditor: EditorId;
}

function effectivePathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

function configChildren(
  payload: CachePayload,
  configDisplayName: string,
  parentEffectiveKeyPath: string[],
): FlatIndexRecord[] {
  return payload.records.filter((record) =>
    record.effectiveConfigDisplayName === configDisplayName &&
    effectivePathMatches(record.parentEffectiveKeyPath, parentEffectiveKeyPath)
  );
}

function configRecords(payload: CachePayload, configDisplayName: string): FlatIndexRecord[] {
  return payload.records.filter((record) => record.effectiveConfigDisplayName === configDisplayName);
}

function relativeKeyPath(record: FlatIndexRecord, parentEffectiveKeyPath: string[]): string[] {
  return record.effectiveKeyPath.slice(parentEffectiveKeyPath.length);
}

function currentContextGroupRecord(
  payload: CachePayload,
  configDisplayName: string,
  parentEffectiveKeyPath: string[],
): FlatIndexRecord | undefined {
  if (parentEffectiveKeyPath.length > 0) {
    return payload.records.find((record) =>
      record.kind === "group" &&
      record.effectiveConfigDisplayName === configDisplayName &&
      effectivePathMatches(record.effectiveKeyPath, parentEffectiveKeyPath)
    );
  }

  const configSummary = payload.configs.find((config) => config.displayName === configDisplayName);
  if (!configSummary) {
    return undefined;
  }

  return {
    actionType: "group",
    activates: undefined,
    appName: undefined,
    breadcrumbDisplay: configDisplayName,
    breadcrumbPath: [configDisplayName],
    childCount: 0,
    displayLabel: configDisplayName,
    effectiveConfigDisplayName: configDisplayName,
    effectiveConfigPath: configSummary.filePath,
    effectiveKeyPath: [],
    effectiveScope: configSummary.scope,
    id: `__root__:${configSummary.filePath}`,
    inherited: false,
    key: "",
    keySequence: "",
    kind: "group",
    label: configDisplayName,
    macroStepSummary: undefined,
    parentEffectiveKeyPath: [],
    rawValue: "",
    searchText: configDisplayName.toLowerCase(),
    sourceConfigDisplayName: configDisplayName,
    sourceConfigPath: configSummary.filePath,
    sourceNodePath: [],
    sourceScope: configSummary.scope,
    sourceStatus: "local",
    stickyMode: undefined,
    valuePreview: "Contains 0 items",
  };
}

async function openRecordInEditor(record: FlatIndexRecord, preferredEditor: EditorId): Promise<void> {
  const location = await locateNodeInFile(record.sourceConfigPath, record.sourceNodePath);
  await openInEditor(preferredEditor, {
    column: location.column,
    filePath: record.sourceConfigPath,
    line: location.line,
  });
}

export function ConfigNodesList(props: ConfigNodesListProps) {
  const {
    configDirectory,
    configDisplayName,
    initialPayload,
    onDidMutate,
    parentEffectiveKeyPath = [],
    preferredEditor,
  } = props;
  const [payload, setPayload] = useState(initialPayload);
  const [searchText, setSearchText] = useState("");
  const [selectedId, setSelectedId] = useState<string>();
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;
  const { push } = useNavigation();

  useEffect(() => {
    setPayload(initialPayload);
  }, [initialPayload]);

  const children = configChildren(payload, configDisplayName, parentEffectiveKeyPath);
  const branchRecords = configRecords(payload, configDisplayName);
  const visibleRecords = searchText
    ? searchRecordsInSubtree(branchRecords, searchText, parentEffectiveKeyPath)
    : children;
  const contextRecord = currentContextGroupRecord(payload, configDisplayName, parentEffectiveKeyPath);
  const activeSelectedId = selectedId && visibleRecords.some((record) => record.id === selectedId)
    ? selectedId
    : visibleRecords[0]?.id;

  function handleDidMutate(nextPayload: CachePayload): void {
    setPayload(nextPayload);
    onDidMutate(nextPayload);
  }

  function conflictForPaste(parentKeyPath: string[], key: string): FlatIndexRecord | undefined {
    return payload.records.find((record) =>
      record.effectiveConfigDisplayName === configDisplayName &&
      record.key === key &&
      effectivePathMatches(record.parentEffectiveKeyPath, parentKeyPath)
    );
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

  async function handlePasteIntoGroup(targetConfigPath: string, parentKeyPath: string[], groupLabel: string): Promise<void> {
    try {
      const clipboardPayload = await readInternalClipboard();
      if (!clipboardPayload) {
        await showToast({
          style: Toast.Style.Failure,
          title: "Clipboard is empty",
          message: "Copy an action or group in the Leader Key Raycast extension first.",
        });
        return;
      }

      const key = clipboardPayload.item.key?.trim();
      if (!key) {
        await showToast({
          style: Toast.Style.Failure,
          title: "Clipboard item has no key",
        });
        return;
      }

      const conflict = conflictForPaste(parentKeyPath, key);
      if (conflict) {
        push(
          <RecordEditorForm
            configDirectory={configDirectory}
            createAtPath={{
              configDisplayName,
              configPath: targetConfigPath,
              parentKeyPath,
              suggestedKey: key,
            }}
            initialFormState={itemToFormState(clipboardPayload.item)}
            initialType={clipboardPayload.item.type}
            mode="create-at-path"
            onDidSave={async (nextPayload) => {
              handleDidMutate(nextPayload);
            }}
            preserveItem={clipboardPayload.item}
            title={`Resolve Key Conflict in ${groupLabel}`}
          />,
        );
        return;
      }

      await createItemAtPath(targetConfigPath, parentKeyPath, clipboardPayload.item);

      let syncError: unknown;
      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const nextPayload = await rebuildIndex(configDirectory);
      handleDidMutate(nextPayload);

      await showToast(
        syncError
          ? {
              style: Toast.Style.Failure,
              title: "Pasted item, but Leader Key sync failed",
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: clipboardPayload.kind === "group" ? "Pasted group" : "Pasted action",
              message: `Added to ${groupLabel}`,
            },
      );
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Paste failed",
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
      handleDidMutate(nextPayload);

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
          handleDidMutate(nextPayload);
        }}
        targetRecord={record}
        title={title}
      />
    );
  }

  function pathEditorDeeplink(record: FlatIndexRecord): string | undefined {
    const configSummary = payload.configs.find((config) => config.filePath === record.effectiveConfigPath);
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

  function emptyStateActions() {
    if (!contextRecord) {
      return undefined;
    }

    return (
      <ActionPanel>
        <Action.Push
          icon={Icon.Plus}
          shortcut={{ modifiers: ["ctrl", "cmd"], key: "n" }}
          target={editorForm("append-child", contextRecord, `Add First Action to ${contextRecord.displayLabel}`)}
          title="Add First Action"
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
                handleDidMutate(nextPayload);
              }}
              targetRecord={contextRecord}
              title={`Add First Group to ${contextRecord.displayLabel}`}
            />
          }
          title="Add First Group"
        />
        <Action
          icon={Icon.Clipboard}
          onAction={() => void handlePasteIntoGroup(
            contextRecord.effectiveConfigPath,
            contextRecord.effectiveKeyPath,
            contextRecord.displayLabel,
          )}
          shortcut={{ modifiers: ["cmd"], key: "v" }}
          title="Paste into This Group"
        />
        <Action
          icon={Icon.Code}
          onAction={() => void openRecordInEditor(contextRecord, preferredEditor)}
          title="Open in Editor"
        />
      </ActionPanel>
    );
  }

  return (
    <List
      key={`config:${payload.fingerprint}:${configDisplayName}:${parentEffectiveKeyPath.join(".")}`}
      isShowingDetail
      isLoading={false}
      navigationTitle={configDisplayName}
      onSearchTextChange={setSearchText}
      onSelectionChange={(id) => setSelectedId(id ?? undefined)}
      searchBarPlaceholder="Search this config"
    >
      {visibleRecords.length === 0 ? (
        <List.EmptyView
          actions={emptyStateActions()}
          description={searchText ? "No matching items in this branch." : "This group is empty. Add the first action or subgroup."}
          title={searchText ? "No Results" : "Empty Group"}
        />
      ) : null}
      {visibleRecords.map((record) => {
        const row = buildRowPresentation(
          record,
          searchText
            ? {
                relativeKeyPath: relativeKeyPath(record, parentEffectiveKeyPath),
              }
            : undefined,
        );
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
                        configDisplayName={configDisplayName}
                        initialPayload={payload}
                        onDidMutate={handleDidMutate}
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
                    target={editorForm("edit-source", record, `Edit ${record.displayLabel}`)}
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
                  icon={Icon.Clipboard}
                  onAction={() =>
                    void handlePasteIntoGroup(
                      contextRecord?.effectiveConfigPath ?? record.effectiveConfigPath,
                      contextRecord?.effectiveKeyPath ?? parentEffectiveKeyPath,
                      contextRecord?.displayLabel ?? configDisplayName,
                    )}
                  shortcut={{ modifiers: ["cmd"], key: "v" }}
                  title="Paste into Current Group"
                />
                <Action
                  icon={Icon.Code}
                  onAction={() => void openRecordInEditor(record, preferredEditor)}
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
                {record.kind === "group" ? (
                  <Action.Push
                    icon={Icon.Pencil}
                    shortcut={Keyboard.Shortcut.Common.Edit}
                    target={editorForm("edit-source", record, `Edit ${record.displayLabel}`)}
                    title={record.inherited ? "Edit Fallback Source" : "Edit Item"}
                  />
                ) : null}
                {record.inherited ? (
                  <Action.Push
                    icon={Icon.PlusCircle}
                    shortcut={{ modifiers: ["cmd", "shift"], key: "e" }}
                    target={editorForm("override-in-effective-config", record, `Create Override for ${record.displayLabel}`)}
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
                        handleDidMutate(nextPayload);
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
                            handleDidMutate(nextPayload);
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
