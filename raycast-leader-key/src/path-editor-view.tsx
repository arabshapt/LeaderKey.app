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
  type Image,
  type List as RaycastList,
  useNavigation,
} from "@raycast/api";
import {
  analyzePathInConfig,
  createItemAtPath,
  deleteRecord,
  locateNodeInFile,
  openInEditor,
  parentPathIsInsideLayer,
  triggerLeaderKeyConfigReload,
  type CachePayload,
  type ConfigSummary,
  type EditorId,
  type FlatIndexRecord,
  type PathAnalysis,
} from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { rebuildIndex } from "./cache.js";
import { copyRecordToInternalClipboard, readInternalClipboard } from "./clipboard.js";
import { ConfigNodesList } from "./browser.js";
import { recordListItemDetail, RecordDetailView } from "./detail.js";
import type { DetailMetadataRow } from "./detail-presentation.js";
import { buildPathEditorDeeplink, configTargetForSummary } from "./deeplinks.js";
import { RecordEditorForm } from "./editor-form.js";
import { itemToFormState } from "./form-utils.js";
import { buildRowPresentation, recordIcon } from "./presentation.js";
import { keyPathText } from "./record-formatting.js";
import { isNormalScope } from "./scope-utils.js";

interface PathEditorViewProps {
  configDirectory: string;
  configSummary: ConfigSummary;
  initialPath?: string;
  initialPayload: CachePayload;
  onDidMutate: (payload: CachePayload) => void;
  preferredEditor: EditorId;
}

interface OutcomeRow {
  actions: RaycastList.Item.Props["actions"];
  detail: RaycastList.Item.Props["detail"];
  icon: Image.ImageLike;
  id: string;
  subtitle: RaycastList.Item.Props["subtitle"];
  title: RaycastList.Item.Props["title"];
}

interface MetadataComponents {
  Label: any;
  Root: any;
  Separator: any;
}

interface PasteTarget {
  groupLabel: string;
  parentKeyPath: string[];
}

function renderMetadata(rows: DetailMetadataRow[], components: MetadataComponents) {
  const Root = components.Root;
  const Label = components.Label;
  const Separator = components.Separator;

  return (
    <Root>
      {rows.flatMap((row, index) => [
        <Label key={`label-${row.title}-${index}`} title={row.title} text={row.text} />,
        index < rows.length - 1 ? <Separator key={`separator-${index}`} /> : null,
      ])}
    </Root>
  );
}

function outcomeDetail(title: string, markdown: string, metadata: DetailMetadataRow[]) {
  return (
    <List.Item.Detail
      markdown={markdown}
      metadata={renderMetadata(metadata, {
        Label: List.Item.Detail.Metadata.Label,
        Root: List.Item.Detail.Metadata,
        Separator: List.Item.Detail.Metadata.Separator,
      })}
    />
  );
}

function typedPathTitle(analysis: PathAnalysis): string {
  return analysis.typedPath.length > 0 ? keyPathText(analysis.typedPath) : analysis.config.displayName;
}

function typedPathMarkdown(analysis: PathAnalysis): string {
  return analysis.typedPath.length > 0 ? `\`${typedPathTitle(analysis)}\`` : `\`${analysis.config.displayName}\``;
}

function baseMetadata(analysis: PathAnalysis): DetailMetadataRow[] {
  return [
    { title: "Config", text: analysis.config.displayName },
    { title: "Scope", text: analysis.config.scope },
    { title: "File", text: analysis.config.filePath },
  ];
}

function rootOutcomeRow(
  analysis: PathAnalysis,
  configDirectory: string,
  payload: CachePayload,
  onDidMutate: (payload: CachePayload) => void,
  preferredEditor: EditorId,
  onPaste: () => void,
): OutcomeRow {
  const metadata = [
    ...baseMetadata(analysis),
    { title: "Children", text: String(analysis.visibleChildren.length) },
  ];

  return {
    actions: (
      <ActionPanel>
        <Action.Push
          icon={Icon.ChevronRight}
          shortcut={{ key: "return", modifiers: [] }}
          target={
            <ConfigNodesList
              configDirectory={configDirectory}
              configDisplayName={analysis.config.displayName}
              initialPayload={payload}
              onDidMutate={onDidMutate}
              preferredEditor={preferredEditor}
            />
          }
          title="Open Config Root"
        />
        <Action
          icon={Icon.Clipboard}
          onAction={onPaste}
          shortcut={{ modifiers: ["cmd"], key: "v" }}
          title="Paste at Root"
        />
      </ActionPanel>
    ),
    detail: outcomeDetail(
      "Config Root",
      [
        "# Config Root",
        "",
        typedPathMarkdown(analysis),
        "",
        "## What It Does",
        "",
        `Browse and add shortcuts in ${analysis.config.displayName}. Type a path like \`ab.c\` to jump straight to a node.`,
      ].join("\n"),
      metadata,
    ),
    icon: Icon.AppWindowSidebarLeft,
    id: `outcome:root:${analysis.config.filePath}`,
    subtitle: {
      tooltip: `Browse ${analysis.config.displayName} root`,
      value: `Browse ${analysis.config.displayName}`,
    },
    title: {
      tooltip: analysis.config.displayName,
      value: analysis.config.displayName,
    },
  };
}

function childBrowseTarget(record: FlatIndexRecord): string[] {
  return record.kind === "group" || record.kind === "layer" ? record.effectiveKeyPath : record.parentEffectiveKeyPath;
}

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
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

export function recordPathInput(record: Pick<FlatIndexRecord, "effectiveKeyPath">): string {
  return record.effectiveKeyPath.join("");
}

function buildOutcomeMetadata(analysis: PathAnalysis, extraRows: DetailMetadataRow[]): DetailMetadataRow[] {
  return [
    ...baseMetadata(analysis),
    ...extraRows,
  ];
}

function createOutcomeDetail(
  analysis: PathAnalysis,
  title: string,
  summary: string,
  extraMetadata: DetailMetadataRow[],
): RaycastList.Item.Props["detail"] {
  return outcomeDetail(
    title,
    [
      `# ${title}`,
      "",
      typedPathMarkdown(analysis),
      "",
      "## What It Does",
      "",
      summary,
    ].join("\n"),
    buildOutcomeMetadata(analysis, extraMetadata),
  );
}

async function openRecordInEditor(record: FlatIndexRecord, preferredEditor: EditorId): Promise<void> {
  const location = await locateNodeInFile(record.sourceConfigPath, record.sourceNodePath);
  await openInEditor(preferredEditor, {
    column: location.column,
    filePath: record.sourceConfigPath,
    line: location.line,
  });
}

export function PathEditorView(props: PathEditorViewProps) {
  const {
    configDirectory,
    configSummary,
    initialPath = "",
    initialPayload,
    onDidMutate,
    preferredEditor,
  } = props;
  const [payload, setPayload] = useState(initialPayload);
  const [pathInput, setPathInput] = useState(initialPath);
  const [selectedId, setSelectedId] = useState<string>();
  const ownerOrAuthorName = environment.ownerOrAuthorName;
  const extensionName = environment.extensionName;
  const { push } = useNavigation();
  const canCreateLayerInConfig = isNormalScope(configSummary.scope);
  const canCreateLayerAtParent = (parentKeyPath: string[]) =>
    canCreateLayerInConfig && !parentPathIsInsideLayer(payload, configSummary.filePath, parentKeyPath);

  useEffect(() => {
    setPayload(initialPayload);
  }, [initialPayload]);

  const analysis = useMemo(
    () => analyzePathInConfig(payload, configSummary, pathInput),
    [configSummary, pathInput, payload],
  );
  const literalTypedPath = useMemo(() => Array.from(pathInput.trim()), [pathInput]);
  const literalPathTitle = literalTypedPath.length > 0 ? keyPathText(literalTypedPath) : undefined;
  const configRecords = useMemo(
    () => payload.records.filter((record) => record.effectiveConfigDisplayName === configSummary.displayName),
    [configSummary.displayName, payload.records],
  );
  const literalExactRecord = useMemo(
    () => configRecords.find((record) => keyPathMatches(record.effectiveKeyPath, literalTypedPath)),
    [configRecords, literalTypedPath],
  );
  const literalBlockingAction = useMemo(
    () => configRecords.find((record) =>
      record.kind === "action" &&
      record.effectiveKeyPath.length < literalTypedPath.length &&
      keyPathMatches(record.effectiveKeyPath, literalTypedPath.slice(0, record.effectiveKeyPath.length))
    ),
    [configRecords, literalTypedPath],
  );
  const shouldOfferLiteralTypedPath = Boolean(
    literalPathTitle &&
    !keyPathMatches(literalTypedPath, analysis.typedPath) &&
    !literalExactRecord &&
    !literalBlockingAction,
  );

  async function handleDidMutate(nextPayload: CachePayload): Promise<void> {
    setPayload(nextPayload);
    onDidMutate(nextPayload);
  }

  function handleSavedPath(nextPayload: CachePayload, savedKeyPath: string[]): void {
    void handleDidMutate(nextPayload).then(() => {
      setPathInput(savedKeyPath.join(""));
    });
  }

  function pathEditorDeeplink(record: FlatIndexRecord): string {
    return buildPathEditorDeeplink(
      configTargetForSummary(configSummary),
      ownerOrAuthorName,
      extensionName,
      recordPathInput(record),
    );
  }

  function conflictForPaste(parentKeyPath: string[], key: string): FlatIndexRecord | undefined {
    return payload.records.find((record) =>
      record.effectiveConfigDisplayName === configSummary.displayName &&
      record.key === key &&
      keyPathMatches(record.parentEffectiveKeyPath, parentKeyPath)
    );
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
      await handleDidMutate(nextPayload);

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

  async function handlePasteIntoGroup(target: PasteTarget): Promise<void> {
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

      const key = clipboardPayload.item.key;
      if (key === undefined || key.length === 0) {
        await showToast({
          style: Toast.Style.Failure,
          title: "Clipboard item has no key",
        });
        return;
      }

      const conflict = conflictForPaste(target.parentKeyPath, key);
      if (conflict) {
        push(
          <RecordEditorForm
            configDirectory={configDirectory}
            createAtPath={{
              configDisplayName: configSummary.displayName,
              configPath: configSummary.filePath,
              parentKeyPath: target.parentKeyPath,
              suggestedKey: key,
            }}
            initialFormState={itemToFormState(clipboardPayload.item)}
            initialType={clipboardPayload.item.type}
            mode="create-at-path"
            onDidSave={async (nextPayload, context) => {
              handleSavedPath(nextPayload, context.savedKeyPath);
            }}
            preserveItem={clipboardPayload.item}
            title={`Resolve Key Conflict in ${target.groupLabel}`}
          />,
        );
        return;
      }

      await createItemAtPath(configSummary.filePath, target.parentKeyPath, clipboardPayload.item);

      let syncError: unknown;
      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const nextPayload = await rebuildIndex(configDirectory);
      await handleDidMutate(nextPayload);

      await showToast(
        syncError
          ? {
              style: Toast.Style.Failure,
              title: "Pasted item, but Leader Key sync failed",
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: `Pasted ${clipboardPayload.kind}`,
              message: `Added to ${target.groupLabel}`,
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

  function currentPasteTarget(): PasteTarget {
    if (analysis.state === "exact-group" && analysis.exactMatch) {
      return {
        groupLabel: analysis.exactMatch.displayLabel,
        parentKeyPath: analysis.exactMatch.effectiveKeyPath,
      };
    }

    if (analysis.state === "root") {
      return {
        groupLabel: configSummary.displayName,
        parentKeyPath: [],
      };
    }

    if (analysis.state === "exact-action" && analysis.exactMatch) {
      return {
        groupLabel: analysis.exactMatch.parentEffectiveKeyPath.length > 0
          ? keyPathText(analysis.exactMatch.parentEffectiveKeyPath)
          : configSummary.displayName,
        parentKeyPath: analysis.exactMatch.parentEffectiveKeyPath,
      };
    }

    return {
      groupLabel: analysis.deepestExistingGroupPath.length > 0
        ? keyPathText(analysis.deepestExistingGroupPath)
        : configSummary.displayName,
      parentKeyPath: analysis.deepestExistingGroupPath,
    };
  }

  function outcomeRows(): OutcomeRow[] {
    if (analysis.state === "root") {
      return [
        rootOutcomeRow(
          analysis,
          configDirectory,
          payload,
          (nextPayload) => void handleDidMutate(nextPayload),
          preferredEditor,
          () => void handlePasteIntoGroup(currentPasteTarget()),
        ),
      ];
    }

    if (analysis.state === "exact-action" && analysis.exactMatch) {
      const record = analysis.exactMatch;
      return [
        {
          actions: (
            <ActionPanel>
              <Action.Push
                icon={Icon.Pencil}
                shortcut={{ key: "return", modifiers: [] }}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    mode="edit-source"
                    onDidSave={async (nextPayload, context) => {
                      handleSavedPath(nextPayload, context.savedKeyPath);
                    }}
                    targetRecord={record}
                    title={record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`}
                  />
                }
                title={record.inherited ? "Edit Fallback Source" : "Edit Action"}
              />
              <Action
                icon={Icon.CopyClipboard}
                onAction={() => void handleCopy(record)}
                shortcut={{ modifiers: ["cmd"], key: "c" }}
                title="Copy Action"
              />
              <Action
                icon={Icon.Clipboard}
                onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                shortcut={{ modifiers: ["cmd"], key: "v" }}
                title="Paste into Parent Group"
              />
              <Action
                icon={Icon.Code}
                onAction={() => void openRecordInEditor(record, preferredEditor)}
                shortcut={{ modifiers: ["cmd"], key: "return" }}
                title="Open in Editor"
              />
              <Action.Push
                icon={Icon.ChevronRight}
                shortcut={{ modifiers: ["cmd"], key: "o" }}
                target={
                  <ConfigNodesList
                    configDirectory={configDirectory}
                    configDisplayName={configSummary.displayName}
                    initialPayload={payload}
                    onDidMutate={(nextPayload) => void handleDidMutate(nextPayload)}
                    parentEffectiveKeyPath={record.parentEffectiveKeyPath}
                    preferredEditor={preferredEditor}
                  />
                }
                title="Browse Parent Group"
              />
              {record.inherited ? (
                <Action.Push
                  icon={Icon.PlusCircle}
                  shortcut={{ modifiers: ["cmd", "shift"], key: "e" }}
                  target={
                    <RecordEditorForm
                      configDirectory={configDirectory}
                      mode="override-in-effective-config"
                      onDidSave={async (nextPayload, context) => {
                        handleSavedPath(nextPayload, context.savedKeyPath);
                      }}
                      targetRecord={record}
                      title={`Create Override for ${record.displayLabel}`}
                    />
                  }
                  title="Create App Override"
                />
              ) : null}
              {!record.inherited ? (
                <Action
                  icon={Icon.Trash}
                  onAction={() => void handleDelete(record)}
                  shortcut={{ modifiers: ["cmd"], key: "backspace" }}
                  style={Action.Style.Destructive}
                  title="Delete Action"
                />
              ) : null}
            </ActionPanel>
          ),
          detail: recordListItemDetail(record),
          icon: recordIcon(record),
          id: `outcome:edit:${record.id}`,
          subtitle: {
            tooltip: record.displayLabel,
            value: record.inherited ? "Edit fallback action" : "Edit action",
          },
          title: {
            tooltip: typedPathTitle(analysis),
            value: typedPathTitle(analysis),
          },
        },
      ];
    }

    if (analysis.state === "exact-group" && analysis.exactMatch) {
      const record = analysis.exactMatch;
      return [
        {
          actions: (
            <ActionPanel>
              <Action.Push
                icon={Icon.ChevronRight}
                shortcut={{ key: "return", modifiers: [] }}
                target={
                  <ConfigNodesList
                    configDirectory={configDirectory}
                    configDisplayName={configSummary.displayName}
                    initialPayload={payload}
                    onDidMutate={(nextPayload) => void handleDidMutate(nextPayload)}
                    parentEffectiveKeyPath={record.effectiveKeyPath}
                    preferredEditor={preferredEditor}
                  />
                }
                title={record.kind === "layer" ? "Open Layer" : "Open Group"}
              />
              <Action.Push
                icon={Icon.Pencil}
                shortcut={Keyboard.Shortcut.Common.Edit}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    mode="edit-source"
                    onDidSave={async (nextPayload, context) => {
                      handleSavedPath(nextPayload, context.savedKeyPath);
                    }}
                    targetRecord={record}
                    title={record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`}
                  />
                }
                title={record.inherited ? "Edit Fallback Source" : record.kind === "layer" ? "Edit Layer" : "Edit Group"}
              />
              <Action
                icon={Icon.CopyClipboard}
                onAction={() => void handleCopy(record)}
                shortcut={{ modifiers: ["cmd"], key: "c" }}
                title={`Copy ${recordKindLabel(record)}`}
              />
              <Action
                icon={Icon.Clipboard}
                onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                shortcut={{ modifiers: ["cmd"], key: "v" }}
                title="Paste into Group"
              />
              <Action
                icon={Icon.Code}
                onAction={() => void openRecordInEditor(record, preferredEditor)}
                shortcut={{ modifiers: ["cmd"], key: "return" }}
                title="Open in Editor"
              />
              {!record.inherited ? (
                <Action
                  icon={Icon.Trash}
                  onAction={() => void handleDelete(record)}
                  shortcut={{ modifiers: ["cmd"], key: "backspace" }}
                  style={Action.Style.Destructive}
                  title={record.kind === "layer" ? "Delete Layer" : "Delete Group"}
                />
              ) : null}
            </ActionPanel>
          ),
          detail: recordListItemDetail(record),
          icon: recordIcon(record),
          id: `outcome:group:${record.id}`,
          subtitle: {
            tooltip: `Open ${record.displayLabel}`,
            value: record.kind === "layer" ? "Open layer" : "Open group",
          },
          title: {
            tooltip: typedPathTitle(analysis),
            value: typedPathTitle(analysis),
          },
        },
      ];
    }

    if (analysis.state === "blocked" && analysis.terminalAction) {
      const record = analysis.terminalAction;
      const remaining = keyPathText(analysis.blockedRemainingPath);
      return [
        {
          actions: (
            <ActionPanel>
              <Action.Push
                icon={Icon.Pencil}
                shortcut={{ key: "return", modifiers: [] }}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    mode="edit-source"
                    onDidSave={async (nextPayload, context) => {
                      handleSavedPath(nextPayload, context.savedKeyPath);
                    }}
                    targetRecord={record}
                    title={record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`}
                  />
                }
                title={record.inherited ? "Edit Fallback Source" : "Edit Blocking Action"}
              />
              <Action.Push
                icon={Icon.ChevronRight}
                shortcut={{ modifiers: ["cmd"], key: "o" }}
                target={
                  <ConfigNodesList
                    configDirectory={configDirectory}
                    configDisplayName={configSummary.displayName}
                    initialPayload={payload}
                    onDidMutate={(nextPayload) => void handleDidMutate(nextPayload)}
                    parentEffectiveKeyPath={record.parentEffectiveKeyPath}
                    preferredEditor={preferredEditor}
                  />
                }
                title="Browse Parent Group"
              />
              <Action
                icon={Icon.Clipboard}
                onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                shortcut={{ modifiers: ["cmd"], key: "v" }}
                title="Paste into Deepest Existing Group"
              />
            </ActionPanel>
          ),
          detail: createOutcomeDetail(
            analysis,
            "Blocked by Existing Action",
            `The path hits the existing action \`${record.displayLabel}\` before reaching the remaining segment \`${remaining || "—"}\`. Actions are terminal in this flow.`,
            [
              { title: "Blocking Action", text: record.displayLabel },
              { title: "Stops At", text: keyPathText(record.effectiveKeyPath) },
              { title: "Remaining", text: remaining || "—" },
            ],
          ),
          icon: Icon.ExclamationMark,
          id: `outcome:blocked:${record.id}`,
          subtitle: {
            tooltip: `Blocked by ${record.displayLabel}`,
            value: "Blocked by existing action",
          },
          title: {
            tooltip: typedPathTitle(analysis),
            value: typedPathTitle(analysis),
          },
        },
      ];
    }

    if (analysis.state === "missing" && analysis.finalKey) {
      const autoGroups = analysis.autoCreateGroupKeys.length > 0 ? keyPathText(analysis.autoCreateGroupKeys) : "None";
      const canCreateLayerAtMissingPath = canCreateLayerAtParent(analysis.createParentKeyPath);
      const sharedMetadata = [
        { title: "Parent Path", text: analysis.createParentKeyPath.length > 0 ? keyPathText(analysis.createParentKeyPath) : "Root" },
        { title: "Auto Groups", text: autoGroups },
        { title: "Final Key", text: analysis.finalKey },
      ];

      return [
        {
          actions: (
            <ActionPanel>
              <Action.Push
                icon={Icon.Plus}
                shortcut={{ key: "return", modifiers: [] }}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    createAtPath={{
                      configDisplayName: configSummary.displayName,
                      configPath: configSummary.filePath,
                      parentKeyPath: analysis.createParentKeyPath,
                      suggestedKey: analysis.finalKey,
                    }}
                    initialType="shortcut"
                    mode="create-at-path"
                    onDidSave={async (nextPayload, context) => {
                      await handleDidMutate(nextPayload);
                      setPathInput(context.savedKeyPath.join(""));
                    }}
                    title={`Create Action at ${typedPathTitle(analysis)}`}
                  />
                }
                title="Create Action at Path"
              />
              <Action.Push
                icon={Icon.NewFolder}
                shortcut={{ modifiers: ["cmd", "shift"], key: "n" }}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    createAtPath={{
                      configDisplayName: configSummary.displayName,
                      configPath: configSummary.filePath,
                      parentKeyPath: analysis.createParentKeyPath,
                      suggestedKey: analysis.finalKey,
                    }}
                    initialType="group"
                    mode="create-at-path"
                    onDidSave={async (nextPayload, context) => {
                      await handleDidMutate(nextPayload);
                      setPathInput(context.savedKeyPath.join(""));
                    }}
                    title={`Create Group at ${typedPathTitle(analysis)}`}
                  />
                }
                title="Create Group at Path"
              />
              {canCreateLayerAtMissingPath ? (
                <Action.Push
                  icon={Icon.Layers}
                  shortcut={{ modifiers: ["cmd", "opt"], key: "n" }}
                  target={
                    <RecordEditorForm
                      configDirectory={configDirectory}
                      createAtPath={{
                        configDisplayName: configSummary.displayName,
                        configPath: configSummary.filePath,
                        parentKeyPath: analysis.createParentKeyPath,
                        suggestedKey: analysis.finalKey,
                      }}
                      initialType="layer"
                      mode="create-at-path"
                      onDidSave={async (nextPayload, context) => {
                        await handleDidMutate(nextPayload);
                        setPathInput(context.savedKeyPath.join(""));
                      }}
                      title={`Create Layer at ${typedPathTitle(analysis)}`}
                    />
                  }
                  title="Create Layer at Path"
                />
              ) : null}
              <Action.Push
                icon={Icon.ChevronRight}
                shortcut={{ modifiers: ["cmd"], key: "o" }}
                target={
                  <ConfigNodesList
                    configDirectory={configDirectory}
                    configDisplayName={configSummary.displayName}
                    initialPayload={payload}
                    onDidMutate={(nextPayload) => void handleDidMutate(nextPayload)}
                    parentEffectiveKeyPath={analysis.deepestExistingGroupPath}
                    preferredEditor={preferredEditor}
                  />
                }
                title="Browse Deepest Existing Group"
              />
              <Action
                icon={Icon.Clipboard}
                onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                shortcut={{ modifiers: ["cmd"], key: "v" }}
                title="Paste into Deepest Existing Group"
              />
            </ActionPanel>
          ),
          detail: createOutcomeDetail(
            analysis,
            "Create Action at Path",
            `Creates a new action at ${typedPathTitle(analysis)}.${analysis.autoCreateGroupKeys.length > 0 ? ` Missing intermediate groups will be created automatically: ${autoGroups}.` : ""}`,
            [...sharedMetadata, { title: "Final Type", text: "shortcut action" }],
          ),
          icon: Icon.Plus,
          id: `outcome:create-action:${configSummary.filePath}:${analysis.input}`,
          subtitle: {
            tooltip: `Create action at ${typedPathTitle(analysis)}`,
            value: "Create action",
          },
          title: {
            tooltip: typedPathTitle(analysis),
            value: typedPathTitle(analysis),
          },
        },
        {
          actions: (
            <ActionPanel>
              <Action.Push
                icon={Icon.NewFolder}
                shortcut={{ key: "return", modifiers: [] }}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    createAtPath={{
                      configDisplayName: configSummary.displayName,
                      configPath: configSummary.filePath,
                      parentKeyPath: analysis.createParentKeyPath,
                      suggestedKey: analysis.finalKey,
                    }}
                    initialType="group"
                    mode="create-at-path"
                    onDidSave={async (nextPayload, context) => {
                      await handleDidMutate(nextPayload);
                      setPathInput(context.savedKeyPath.join(""));
                    }}
                    title={`Create Group at ${typedPathTitle(analysis)}`}
                  />
                }
                title="Create Group at Path"
              />
              <Action
                icon={Icon.Clipboard}
                onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                shortcut={{ modifiers: ["cmd"], key: "v" }}
                title="Paste into Deepest Existing Group"
              />
            </ActionPanel>
          ),
          detail: createOutcomeDetail(
            analysis,
            "Create Group at Path",
            `Creates a new group at ${typedPathTitle(analysis)}.${analysis.autoCreateGroupKeys.length > 0 ? ` Missing intermediate groups will be created automatically: ${autoGroups}.` : ""}`,
            [...sharedMetadata, { title: "Final Type", text: "group" }],
          ),
          icon: Icon.NewFolder,
          id: `outcome:create-group:${configSummary.filePath}:${analysis.input}`,
          subtitle: {
            tooltip: `Create group at ${typedPathTitle(analysis)}`,
            value: "Create group",
          },
          title: {
            tooltip: typedPathTitle(analysis),
            value: typedPathTitle(analysis),
          },
        },
        ...(canCreateLayerAtMissingPath ? [{
          actions: (
            <ActionPanel>
              <Action.Push
                icon={Icon.Layers}
                shortcut={{ key: "return", modifiers: [] }}
                target={
                  <RecordEditorForm
                    configDirectory={configDirectory}
                    createAtPath={{
                      configDisplayName: configSummary.displayName,
                      configPath: configSummary.filePath,
                      parentKeyPath: analysis.createParentKeyPath,
                      suggestedKey: analysis.finalKey,
                    }}
                    initialType="layer"
                    mode="create-at-path"
                    onDidSave={async (nextPayload, context) => {
                      await handleDidMutate(nextPayload);
                      setPathInput(context.savedKeyPath.join(""));
                    }}
                    title={`Create Layer at ${typedPathTitle(analysis)}`}
                  />
                }
                title="Create Layer at Path"
              />
              <Action
                icon={Icon.Clipboard}
                onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                shortcut={{ modifiers: ["cmd"], key: "v" }}
                title="Paste into Deepest Existing Group"
              />
            </ActionPanel>
          ),
          detail: createOutcomeDetail(
            analysis,
            "Create Layer at Path",
            `Creates a new hold layer at ${typedPathTitle(analysis)}.${analysis.autoCreateGroupKeys.length > 0 ? ` Missing intermediate groups will be created automatically: ${autoGroups}.` : ""}`,
            [...sharedMetadata, { title: "Final Type", text: "layer" }],
          ),
          icon: Icon.Layers,
          id: `outcome:create-layer:${configSummary.filePath}:${analysis.input}`,
          subtitle: {
            tooltip: `Create layer at ${typedPathTitle(analysis)}`,
            value: "Create layer",
          },
          title: {
            tooltip: typedPathTitle(analysis),
            value: typedPathTitle(analysis),
          },
        }] : []),
      ];
    }

    return [];
  }

  function literalTypedPathRows(): OutcomeRow[] {
    if (!shouldOfferLiteralTypedPath || !literalPathTitle) {
      return [];
    }

    const parentKeyPath = literalTypedPath.slice(0, -1);
    const suggestedKey = literalTypedPath.at(-1);
    if (!suggestedKey) {
      return [];
    }

    const canCreateLiteralLayer = canCreateLayerAtParent(parentKeyPath);
    const metadata = [
      ...baseMetadata(analysis),
      { title: "Literal Path", text: literalPathTitle },
      { title: "Parent Path", text: parentKeyPath.length > 0 ? keyPathText(parentKeyPath) : "Root" },
      { title: "Final Key", text: suggestedKey },
    ];

    return [
      {
        actions: (
          <ActionPanel>
            <Action.Push
              icon={Icon.Plus}
              shortcut={{ modifiers: ["cmd"], key: "n" }}
              target={
                <RecordEditorForm
                  configDirectory={configDirectory}
                  createAtPath={{
                    configDisplayName: configSummary.displayName,
                    configPath: configSummary.filePath,
                    parentKeyPath,
                    suggestedKey,
                  }}
                  initialType="shortcut"
                  mode="create-at-path"
                  onDidSave={async (nextPayload, context) => {
                    await handleDidMutate(nextPayload);
                    setPathInput(context.savedKeyPath.join(""));
                  }}
                  title={`Create Action at ${literalPathTitle}`}
                />
              }
              title="Create Literal Action"
            />
          </ActionPanel>
        ),
        detail: outcomeDetail(
          "Create Literal Action",
          [
            "# Create Literal Action",
            "",
            `Treat \`${pathInput.trim()}\` as the literal key path \`${literalPathTitle}\`, not the alias-resolved match.`,
            "",
            "Missing intermediate groups will be created automatically if needed.",
          ].join("\n"),
          metadata,
        ),
        icon: Icon.Plus,
        id: `outcome:literal-create-action:${configSummary.filePath}:${pathInput}`,
        subtitle: {
          tooltip: `Create literal action at ${literalPathTitle}`,
          value: "Create literal action",
        },
        title: {
          tooltip: literalPathTitle,
          value: literalPathTitle,
        },
      },
      {
        actions: (
          <ActionPanel>
            <Action.Push
              icon={Icon.NewFolder}
              shortcut={{ modifiers: ["cmd", "shift"], key: "n" }}
              target={
                <RecordEditorForm
                  configDirectory={configDirectory}
                  createAtPath={{
                    configDisplayName: configSummary.displayName,
                    configPath: configSummary.filePath,
                    parentKeyPath,
                    suggestedKey,
                  }}
                  initialType="group"
                  mode="create-at-path"
                  onDidSave={async (nextPayload, context) => {
                    await handleDidMutate(nextPayload);
                    setPathInput(context.savedKeyPath.join(""));
                  }}
                  title={`Create Group at ${literalPathTitle}`}
                />
              }
              title="Create Literal Group"
            />
          </ActionPanel>
        ),
        detail: outcomeDetail(
          "Create Literal Group",
          [
            "# Create Literal Group",
            "",
            `Treat \`${pathInput.trim()}\` as the literal key path \`${literalPathTitle}\`, not the alias-resolved match.`,
            "",
            "Missing intermediate groups will be created automatically if needed.",
          ].join("\n"),
          metadata,
        ),
        icon: Icon.NewFolder,
        id: `outcome:literal-create-group:${configSummary.filePath}:${pathInput}`,
        subtitle: {
          tooltip: `Create literal group at ${literalPathTitle}`,
          value: "Create literal group",
        },
        title: {
          tooltip: literalPathTitle,
          value: literalPathTitle,
        },
      },
      ...(canCreateLiteralLayer ? [{
        actions: (
          <ActionPanel>
            <Action.Push
              icon={Icon.Layers}
              shortcut={{ modifiers: ["cmd", "opt"], key: "n" }}
              target={
                <RecordEditorForm
                  configDirectory={configDirectory}
                  createAtPath={{
                    configDisplayName: configSummary.displayName,
                    configPath: configSummary.filePath,
                    parentKeyPath,
                    suggestedKey,
                  }}
                  initialType="layer"
                  mode="create-at-path"
                  onDidSave={async (nextPayload, context) => {
                    await handleDidMutate(nextPayload);
                    setPathInput(context.savedKeyPath.join(""));
                  }}
                  title={`Create Layer at ${literalPathTitle}`}
                />
              }
              title="Create Literal Layer"
            />
          </ActionPanel>
        ),
        detail: outcomeDetail(
          "Create Literal Layer",
          [
            "# Create Literal Layer",
            "",
            `Treat \`${pathInput.trim()}\` as the literal key path \`${literalPathTitle}\`, not the alias-resolved match.`,
            "",
            "Missing intermediate groups will be created automatically if needed.",
          ].join("\n"),
          metadata,
        ),
        icon: Icon.Layers,
        id: `outcome:literal-create-layer:${configSummary.filePath}:${pathInput}`,
        subtitle: {
          tooltip: `Create literal layer at ${literalPathTitle}`,
          value: "Create literal layer",
        },
        title: {
          tooltip: literalPathTitle,
          value: literalPathTitle,
        },
      }] : []),
    ];
  }

  const topRows = [...literalTypedPathRows(), ...outcomeRows()];
  const childRows = analysis.visibleChildren;
  const combinedIds = [...topRows.map((row) => row.id), ...childRows.map((record) => record.id)];
  const activeSelectedId = selectedId && combinedIds.includes(selectedId)
    ? selectedId
    : combinedIds[0];

  return (
    <List
      key={`path:${payload.fingerprint}:${configSummary.filePath}`}
      filtering={false}
      isShowingDetail
      navigationTitle={configSummary.displayName}
      onSearchTextChange={setPathInput}
      onSelectionChange={(id) => setSelectedId(id ?? undefined)}
      searchBarPlaceholder="Type shortcut path like ab.c"
      searchText={pathInput}
    >
      <List.Section title="Path Outcome">
        {topRows.map((row) => (
          <List.Item
            detail={activeSelectedId === row.id ? row.detail : undefined}
            icon={row.icon}
            id={row.id}
            key={row.id}
            subtitle={row.subtitle}
            title={row.title}
            actions={row.actions}
          />
        ))}
      </List.Section>

      <List.Section title={analysis.state === "exact-group" ? "Group Items" : "Deepest Existing Group"}>
        {childRows.map((record) => {
          const row = buildRowPresentation(record);
          const isSelected = activeSelectedId === record.id;
          const showDetailsShortcut: Keyboard.Shortcut = isContainerRecord(record)
            ? { modifiers: ["cmd"], key: "return" }
            : { modifiers: ["cmd"], key: "." };

          return (
            <List.Item
              accessories={row.accessories}
              detail={isSelected ? recordListItemDetail(record) : undefined}
              icon={recordIcon(record)}
              id={record.id}
              key={record.id}
              subtitle={row.subtitle}
              title={row.title}
              actions={
                <ActionPanel>
                  {isContainerRecord(record) ? (
                    <>
                      <Action.Push
                        icon={Icon.ChevronRight}
                        shortcut={{ key: "return", modifiers: [] }}
                        target={
                          <ConfigNodesList
                            configDirectory={configDirectory}
                            configDisplayName={configSummary.displayName}
                            initialPayload={payload}
                            onDidMutate={(nextPayload) => void handleDidMutate(nextPayload)}
                            parentEffectiveKeyPath={record.effectiveKeyPath}
                            preferredEditor={preferredEditor}
                          />
                        }
                        title={record.kind === "layer" ? "Open Layer" : "Open Group"}
                      />
                      <Action.Push
                        icon={Icon.Pencil}
                        shortcut={Keyboard.Shortcut.Common.Edit}
                        target={
                          <RecordEditorForm
                            configDirectory={configDirectory}
                            mode="edit-source"
                            onDidSave={async (nextPayload) => {
                              await handleDidMutate(nextPayload);
                            }}
                            targetRecord={record}
                            title={record.inherited ? `Edit Fallback Source for ${record.displayLabel}` : `Edit ${record.displayLabel}`}
                          />
                        }
                        title={record.inherited ? "Edit Fallback Source" : record.kind === "layer" ? "Edit Layer" : "Edit Group"}
                      />
                    </>
                  ) : (
                    <Action.Push
                      icon={Icon.Pencil}
                      shortcut={{ key: "return", modifiers: [] }}
                      target={
                        <RecordEditorForm
                          configDirectory={configDirectory}
                          mode="edit-source"
                          onDidSave={async (nextPayload) => {
                            await handleDidMutate(nextPayload);
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
                    title={`Copy ${recordKindLabel(record)}`}
                  />
                  <Action
                    icon={Icon.Clipboard}
                    onAction={() => void handlePasteIntoGroup(currentPasteTarget())}
                    shortcut={{ modifiers: ["cmd"], key: "v" }}
                    title="Paste into Current Group"
                  />
                  <Action
                    icon={Icon.Code}
                    onAction={() => void openRecordInEditor(record, preferredEditor)}
                    shortcut={record.kind === "action" ? { modifiers: ["cmd"], key: "return" } : undefined}
                    title="Open in Editor"
                  />
                  <Action.Open
                    icon={Icon.AppWindowSidebarLeft}
                    shortcut={{ modifiers: ["ctrl", "cmd"], key: "p" }}
                    target={pathEditorDeeplink(record)}
                    title="Open in Path Editor"
                  />
                  <Action.Push
                    icon={Icon.ChevronRight}
                    shortcut={{ modifiers: ["cmd"], key: "o" }}
                    target={
                      <ConfigNodesList
                        configDirectory={configDirectory}
                        configDisplayName={configSummary.displayName}
                        initialPayload={payload}
                        onDidMutate={(nextPayload) => void handleDidMutate(nextPayload)}
                        parentEffectiveKeyPath={childBrowseTarget(record)}
                        preferredEditor={preferredEditor}
                      />
                    }
                  title={isContainerRecord(record) ? `Browse ${record.kind === "layer" ? "Layer" : "Group"} in Config` : "Browse in Config"}
                  />
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
      </List.Section>
    </List>
  );
}
