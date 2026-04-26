import {
  Action,
  ActionPanel,
  Alert,
  confirmAlert,
  Icon,
  List,
  Toast,
  environment,
  showToast,
} from "@raycast/api";
import {
  deleteRecord,
  locateNodeInFile,
  openInEditor,
  parentPathIsInsideLayer,
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
import { SHORTCUTS } from "./shortcuts.js";
import { isNormalScope } from "./scope-utils.js";
import { TypedPathCreatePicker } from "./typed-path-create-picker.js";
import { useIndexPayload } from "./use-index-payload.js";

const MAX_VISIBLE_RESULTS = 300;

function browseTargetPath(record: FlatIndexRecord): string[] {
  return record.kind === "group" || record.kind === "layer" ? record.effectiveKeyPath : record.parentEffectiveKeyPath;
}

function isContainerRecord(record: FlatIndexRecord): boolean {
  return record.kind === "group" || record.kind === "layer";
}

function recordKindLabel(record: Pick<FlatIndexRecord, "kind">): string {
  switch (record.kind) {
    case "group":
      return "group";
    case "layer":
      return "layer";
    case "action":
      return "action";
  }
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
  const typedPathItemIds = typedPathTitle ? ["typed-path:create-action", "typed-path:create-group", "typed-path:create-layer"] : [];

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
        title: `Copied ${clipboardPayload.kind}`,
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
                  shortcut={SHORTCUTS.refresh}
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
                  shortcut={SHORTCUTS.newAction}
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
                  shortcut={SHORTCUTS.newGroup}
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
          <List.Item
            detail={activeSelectedId === "typed-path:create-layer" ? (
              <List.Item.Detail
                markdown={[
                  "# Create Layer by Typed Path",
                  "",
                  `Treat \`${searchText.trim()}\` as the literal Leader Key sequence \`${typedPathTitle}\`.`,
                  "",
                  "Pick a config next and create a normal-mode layer there.",
                ].join("\n")}
              />
            ) : undefined}
            icon={Icon.Layers}
            id="typed-path:create-layer"
            title={`Create Layer at ${typedPathTitle}`}
            subtitle={`Treat "${searchText.trim()}" as literal keys`}
            actions={
              <ActionPanel>
                <Action.Push
                  icon={Icon.Layers}
                  shortcut={SHORTCUTS.newLayer}
                  target={
                    <TypedPathCreatePicker
                      configDirectory={configDirectory}
                      initialPayload={payload}
                      itemType="layer"
                      literalPath={literalTypedPath}
                      onDidSave={setPayload}
                    />
                  }
                  title="Choose Config for Layer"
                />
              </ActionPanel>
            }
          />
        </List.Section>
      ) : null}
      {visibleResults.map((record) => {
        const row = buildRowPresentation(record);
        const isSelected = activeSelectedId === record.id;
        const createOverrideTitle = record.effectiveScope === "normalApp"
          ? "Create Normal App Override"
          : "Create App Override";

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
                {isContainerRecord(record) ? (
                  <Action.Push
                    icon={Icon.ChevronRight}
                    shortcut={SHORTCUTS.primary}
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
                    title={record.kind === "layer" ? "Open Layer" : "Open Group"}
                  />
                ) : (
                  <Action.Push
                    icon={Icon.Pencil}
                    shortcut={SHORTCUTS.primary}
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
                  shortcut={SHORTCUTS.showDetails}
                  target={<RecordDetailView record={record} />}
                  title="Show Details"
                />
                <Action
                  icon={Icon.CopyClipboard}
                  onAction={() => void handleCopy(record)}
                  shortcut={SHORTCUTS.copy}
                  title={`Copy ${recordKindLabel(record)}`}
                />
                <Action
                  icon={Icon.Code}
                  onAction={() => void handleOpenInEditor(record.id)}
                  shortcut={SHORTCUTS.openInEditor}
                  title="Open in Editor"
                />
                {pathEditorDeeplink(record) ? (
                  <Action.Open
                    icon={Icon.AppWindowSidebarLeft}
                    shortcut={SHORTCUTS.openPathEditor}
                    target={pathEditorDeeplink(record)!}
                    title="Open in Path Editor"
                  />
                ) : null}
                <Action.Push
                  icon={Icon.ChevronRight}
                  shortcut={SHORTCUTS.browseInConfig}
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
                  title={isContainerRecord(record) ? `Browse ${record.kind === "layer" ? "Layer" : "Group"} in Config` : "Browse in Config"}
                />
                {isContainerRecord(record) ? (
                  <Action.Push
                    icon={Icon.Pencil}
                    shortcut={SHORTCUTS.edit}
                    target={
                      editorForm(
                        "edit-source",
                        record,
                        record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`,
                      )
                    }
                    title={record.inherited ? "Edit Fallback Source" : record.kind === "layer" ? "Edit Layer" : "Edit Group"}
                  />
                ) : null}
                {record.inherited ? (
                  <Action.Push
                    icon={Icon.PlusCircle}
                    shortcut={SHORTCUTS.createOverride}
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
                    title={createOverrideTitle}
                  />
                ) : null}
                <Action.Push
                  icon={Icon.Plus}
                  shortcut={SHORTCUTS.siblingAction}
                  target={editorForm("create-sibling", record, `Create Sibling After ${record.displayLabel}`)}
                  title="Create Sibling Action"
                />
                <Action.Push
                  icon={Icon.NewFolder}
                  shortcut={SHORTCUTS.siblingGroup}
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
                {isNormalScope(record.effectiveScope) && payload && !parentPathIsInsideLayer(payload, record.effectiveConfigPath, record.parentEffectiveKeyPath) ? (
                  <Action.Push
                    icon={Icon.Layers}
                    shortcut={SHORTCUTS.siblingLayer}
                    target={
                      <RecordEditorForm
                        configDirectory={configDirectory}
                        initialType="layer"
                        mode="create-sibling"
                        onDidSave={async (nextPayload) => {
                          setPayload(nextPayload);
                        }}
                        targetRecord={record}
                        title={`Create Sibling Layer After ${record.displayLabel}`}
                      />
                    }
                    title="Create Sibling Layer"
                  />
                ) : null}
                {isContainerRecord(record) ? (
                  <>
                    <Action.Push
                      icon={Icon.Plus}
                      shortcut={SHORTCUTS.childAction}
                      target={editorForm("append-child", record, `Append Child to ${record.displayLabel}`)}
                      title="Append Child Action"
                    />
                    <Action.Push
                      icon={Icon.NewFolder}
                      shortcut={SHORTCUTS.childGroup}
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
                    {isNormalScope(record.effectiveScope) && record.kind !== "layer" && payload && !parentPathIsInsideLayer(payload, record.effectiveConfigPath, record.effectiveKeyPath) ? (
                      <Action.Push
                        icon={Icon.Layers}
                        shortcut={SHORTCUTS.childLayer}
                        target={
                          <RecordEditorForm
                            configDirectory={configDirectory}
                            initialType="layer"
                            mode="append-child"
                            onDidSave={async (nextPayload) => {
                              setPayload(nextPayload);
                            }}
                            targetRecord={record}
                            title={`Append Child Layer to ${record.displayLabel}`}
                          />
                        }
                        title="Append Child Layer"
                      />
                    ) : null}
                  </>
                ) : null}
                {!record.inherited ? (
                  <Action
                    icon={Icon.Trash}
                    onAction={() => void handleDelete(record)}
                    shortcut={SHORTCUTS.delete}
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
