import {
  Action,
  ActionPanel,
  Icon,
  Keyboard,
  List,
  environment,
  type Image,
  type List as RaycastList,
} from "@raycast/api";
import {
  analyzePathInConfig,
  locateNodeInFile,
  openInEditor,
  type CachePayload,
  type ConfigSummary,
  type EditorId,
  type FlatIndexRecord,
  type PathAnalysis,
} from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { ConfigNodesList } from "./browser.js";
import { recordListItemDetail, RecordDetailView } from "./detail.js";
import type { DetailMetadataRow } from "./detail-presentation.js";
import { buildPathEditorDeeplink, configTargetForSummary } from "./deeplinks.js";
import { RecordEditorForm } from "./editor-form.js";
import { buildRowPresentation, recordIcon } from "./presentation.js";
import { keyPathText } from "./record-formatting.js";

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
  return record.kind === "group" ? record.effectiveKeyPath : record.parentEffectiveKeyPath;
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

  useEffect(() => {
    setPayload(initialPayload);
  }, [initialPayload]);

  const analysis = useMemo(
    () => analyzePathInConfig(payload, configSummary, pathInput),
    [configSummary, pathInput, payload],
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

  function outcomeRows(): OutcomeRow[] {
    if (analysis.state === "root") {
      return [rootOutcomeRow(analysis, configDirectory, payload, (nextPayload) => void handleDidMutate(nextPayload), preferredEditor)];
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
                title="Open Group"
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
                title={record.inherited ? "Edit Fallback Source" : "Edit Group"}
              />
              <Action
                icon={Icon.Code}
                onAction={() => void openRecordInEditor(record, preferredEditor)}
                shortcut={{ modifiers: ["cmd"], key: "return" }}
                title="Open in Editor"
              />
            </ActionPanel>
          ),
          detail: recordListItemDetail(record),
          icon: Icon.Folder,
          id: `outcome:group:${record.id}`,
          subtitle: {
            tooltip: `Open ${record.displayLabel}`,
            value: "Open group",
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
      ];
    }

    return [];
  }

  const topRows = outcomeRows();
  const childRows = analysis.visibleChildren;
  const combinedIds = [...topRows.map((row) => row.id), ...childRows.map((record) => record.id)];

  useEffect(() => {
    if (combinedIds.length === 0) {
      setSelectedId(undefined);
      return;
    }

    if (!selectedId || !combinedIds.includes(selectedId)) {
      setSelectedId(combinedIds[0]);
    }
  }, [combinedIds, selectedId]);

  return (
    <List
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
            detail={selectedId === row.id ? row.detail : undefined}
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
          const isSelected = selectedId === record.id;
          const showDetailsShortcut: Keyboard.Shortcut = record.kind === "group"
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
                  {record.kind === "group" ? (
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
                    title={record.kind === "group" ? "Browse Group in Config" : "Browse in Config"}
                  />
                </ActionPanel>
              }
            />
          );
        })}
      </List.Section>
    </List>
  );
}
