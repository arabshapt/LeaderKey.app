import {
  Action,
  ActionPanel,
  Alert,
  Form,
  Icon,
  Toast,
  confirmAlert,
  showToast,
  useNavigation,
} from "@raycast/api";
import {
  appendChildToGroup,
  createItemAtPath,
  deleteRecord,
  validateRecordPath,
  materializeRecordToConfigItem,
  type CachePayload,
  findInstalledApps,
  insertSiblingAfter,
  triggerLeaderKeyConfigReload,
  type ConfigItem,
  type FlatIndexRecord,
  updateRecord,
  updateRecordAtPath,
} from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { getMemoryCachedPayload, readCachedPayloadSync, rebuildIndex } from "./cache.js";
import {
  emptyFormState,
  encodeKeystrokeRawValue,
  formatFullPath,
  parseTokenizedFullPath,
  recordToFormState,
  type ItemFormState,
} from "./form-utils.js";

type EditorMode = "append-child" | "create-at-path" | "create-sibling" | "edit-source" | "override-in-effective-config";

interface PathCreationTarget {
  configDisplayName: string;
  configPath: string;
  parentKeyPath: string[];
  suggestedKey: string;
}

interface SaveResultContext {
  configDisplayName: string;
  savedKeyPath: string[];
}

interface RecordEditorFormProps {
  createAtPath?: PathCreationTarget;
  configDirectory: string;
  initialFormState?: ItemFormState;
  initialType?: ConfigItem["type"];
  mode: EditorMode;
  onDidSave?: (payload: CachePayload, context: SaveResultContext) => Promise<void> | void;
  preserveItem?: ConfigItem;
  targetRecord?: FlatIndexRecord;
  title: string;
}

function keyPathMatches(left: string[], right: string[]): boolean {
  return left.length === right.length && left.every((segment, index) => segment === right[index]);
}

function formStateToItem(state: ItemFormState, key: string, preserveItem?: ConfigItem): ConfigItem {
  if (state.type === "group") {
    const preservedGroup = preserveItem?.type === "group" ? preserveItem : undefined;
    return {
      actions: preservedGroup?.actions ?? [],
      iconPath: preservedGroup?.iconPath,
      key,
      label: state.label.trim() || undefined,
      stickyMode: state.stickyMode || undefined,
      type: "group",
    };
  }

  const preservedAction = preserveItem?.type === state.type ? preserveItem : undefined;
  const baseItem = {
    activates: state.type === "url" ? state.activates : undefined,
    aiDescription: state.aiDescription.trim() || undefined,
    description: state.description.trim() || undefined,
    iconPath: preservedAction?.iconPath,
    key,
    label: preservedAction?.label,
    stickyMode: state.stickyMode || undefined,
    type: state.type,
  } as const;

  switch (state.type) {
    case "application":
      return { ...baseItem, value: state.applicationPath.trim() };
    case "command":
      return { ...baseItem, value: state.commandValue.trim() };
    case "folder":
      return { ...baseItem, value: state.folderPath.trim() };
    case "intellij":
      return { ...baseItem, value: state.intellijValue.trim() };
    case "keystroke":
      return { ...baseItem, value: encodeKeystrokeRawValue(state.keystroke) };
    case "macro":
      return {
        ...baseItem,
        macroSteps: preservedAction?.type === "macro" ? preservedAction.macroSteps ?? [] : [],
        value: preservedAction?.type === "macro" ? preservedAction.value : "",
      };
    case "menu":
      return { ...baseItem, value: state.menuValue.trim() };
    case "shortcut":
      return { ...baseItem, value: state.shortcutValue.trim() };
    case "text":
      return { ...baseItem, value: state.textValue };
    case "toggleStickyMode":
      return { ...baseItem, value: "" };
    case "url":
      return { ...baseItem, value: state.urlValue.trim() };
  }
}

function validateItem(item: ConfigItem): string | undefined {
  if (!item.key?.trim()) {
    return "A key is required.";
  }

  if (item.type === "group") {
    return undefined;
  }

  if (item.type === "macro") {
    return undefined;
  }

  if (item.type === "toggleStickyMode") {
    return undefined;
  }

  if (!item.value.trim()) {
    return "A value is required for this action type.";
  }

  return undefined;
}

function pathIsEditable(mode: EditorMode): boolean {
  return mode !== "override-in-effective-config";
}

function editableConfigPath(mode: EditorMode, createAtPath: PathCreationTarget | undefined, targetRecord: FlatIndexRecord | undefined): string {
  if (mode === "create-at-path") {
    if (!createAtPath) {
      throw new Error("Missing create-at-path target.");
    }
    return createAtPath.configPath;
  }

  if (!targetRecord) {
    throw new Error("Missing target record for path editing.");
  }

  if (mode === "edit-source") {
    return targetRecord.sourceConfigPath;
  }

  return targetRecord.inherited ? targetRecord.effectiveConfigPath : targetRecord.sourceConfigPath;
}

function editableConfigDisplayName(
  mode: EditorMode,
  createAtPath: PathCreationTarget | undefined,
  targetRecord: FlatIndexRecord | undefined,
): string {
  if (mode === "create-at-path") {
    return createAtPath?.configDisplayName ?? "";
  }

  if (mode === "edit-source") {
    return targetRecord?.sourceConfigDisplayName ?? "";
  }

  return targetRecord?.effectiveConfigDisplayName ?? "";
}

function defaultFullPath(
  mode: EditorMode,
  createAtPath: PathCreationTarget | undefined,
  targetRecord: FlatIndexRecord | undefined,
): string {
  if (mode === "create-at-path") {
    return createAtPath ? formatFullPath([...createAtPath.parentKeyPath, createAtPath.suggestedKey]) : "";
  }

  if (!targetRecord) {
    return "";
  }

  if (mode === "append-child") {
    return formatFullPath(targetRecord.effectiveKeyPath);
  }

  if (mode === "create-sibling") {
    return formatFullPath(targetRecord.parentEffectiveKeyPath);
  }

  return formatFullPath(targetRecord.effectiveKeyPath);
}

function saveResultConfigDisplayName(
  mode: EditorMode,
  createAtPath: PathCreationTarget | undefined,
  targetRecord: FlatIndexRecord | undefined,
): string {
  if (mode === "create-at-path") {
    return createAtPath?.configDisplayName ?? "";
  }

  return targetRecord?.effectiveConfigDisplayName ?? "";
}

export function RecordEditorForm(props: RecordEditorFormProps) {
  const { configDirectory, createAtPath, initialFormState, initialType, mode, preserveItem: initialPreserveItem, targetRecord, title } = props;
  const [formState, setFormState] = useState<ItemFormState>(() => {
    if (initialFormState) {
      const nextState = structuredClone(initialFormState);
      if (!nextState.fullPath.trim()) {
        nextState.fullPath = defaultFullPath(mode, createAtPath, targetRecord);
      }
      return nextState;
    }

    if (mode === "edit-source" || mode === "override-in-effective-config") {
      if (!targetRecord) {
        throw new Error("RecordEditorForm requires a targetRecord in edit modes.");
      }
      return recordToFormState(targetRecord);
    }

    const nextState = emptyFormState(initialType ?? "shortcut");
    nextState.fullPath = defaultFullPath(mode, createAtPath, targetRecord);
    return nextState;
  });
  const [preservedItem, setPreservedItem] = useState<ConfigItem | undefined>(initialPreserveItem);
  const [installedApps, setInstalledApps] = useState<Array<{ bundlePath: string; name: string }>>([]);
  const [validationPayload, setValidationPayload] = useState<CachePayload | undefined>(() =>
    getMemoryCachedPayload(configDirectory) ?? readCachedPayloadSync(configDirectory),
  );
  const [isSaving, setIsSaving] = useState(false);
  const { pop } = useNavigation();
  const primaryTextFieldTitle = "Description";
  const primaryTextFieldPlaceholder = formState.type === "group"
    ? "Optional group description"
    : "Optional action description";
  const canDeleteTarget = mode === "edit-source" && Boolean(targetRecord && !targetRecord.inherited);
  const destinationConfigPath = editableConfigPath(mode, createAtPath, targetRecord);
  const destinationConfigDisplayName = editableConfigDisplayName(mode, createAtPath, targetRecord);
  const parsedFullPath = useMemo(
    () => pathIsEditable(mode)
      ? parseTokenizedFullPath(formState.fullPath)
      : { keyPath: targetRecord?.effectiveKeyPath ?? [] },
    [formState.fullPath, mode, targetRecord],
  );
  const destinationKeyPath = parsedFullPath.keyPath;
  const pathValidation = useMemo(
    () => {
      if (!pathIsEditable(mode) || parsedFullPath.error || !validationPayload) {
        return undefined;
      }

      return validateRecordPath(validationPayload, {
        configFilePath: destinationConfigPath,
        currentRecord: mode === "edit-source" ? targetRecord : undefined,
        destinationKeyPath,
      });
    },
    [destinationConfigPath, destinationKeyPath, mode, parsedFullPath.error, targetRecord, validationPayload],
  );
  const pathError = pathIsEditable(mode)
    ? parsedFullPath.error ?? pathValidation?.error
    : undefined;
  const currentPathText = targetRecord ? formatFullPath(targetRecord.effectiveKeyPath) : defaultFullPath(mode, createAtPath, targetRecord);
  const fixedPathInfo = !pathIsEditable(mode) && targetRecord
    ? `Overrides stay at ${formatFullPath(targetRecord.effectiveKeyPath)}.`
    : undefined;
  const destinationKey = destinationKeyPath.at(-1) ?? "";
  const tentativeItem = destinationKey
    ? formStateToItem(formState, destinationKey, preservedItem)
    : undefined;
  const valueError = tentativeItem ? validateItem(tentativeItem) : undefined;

  useEffect(() => {
    let isMounted = true;
    void findInstalledApps().then((apps) => {
      if (isMounted) {
        setInstalledApps(apps);
      }
    });
    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    setPreservedItem(initialPreserveItem);
  }, [initialPreserveItem]);
  useEffect(() => {
    setValidationPayload(getMemoryCachedPayload(configDirectory) ?? readCachedPayloadSync(configDirectory));
  }, [configDirectory]);

  useEffect(() => {
    let isMounted = true;

    if (!targetRecord) {
      return () => {
        isMounted = false;
      };
    }

    void materializeRecordToConfigItem(targetRecord)
      .then((item) => {
        if (isMounted) {
          setPreservedItem(item);
        }
      })
      .catch(() => {
        if (isMounted) {
          setPreservedItem(initialPreserveItem);
        }
      });

    return () => {
      isMounted = false;
    };
  }, [initialPreserveItem, targetRecord]);

  async function handleSubmit(): Promise<void> {
    const nextPathError = pathIsEditable(mode) ? pathError : undefined;
    if (nextPathError) {
      await showToast({ style: Toast.Style.Failure, title: nextPathError });
      return;
    }

    if (!destinationKey) {
      await showToast({ style: Toast.Style.Failure, title: "A full path is required." });
      return;
    }
    const nextItem = formStateToItem(formState, destinationKey, preservedItem);
    if (valueError) {
      await showToast({ style: Toast.Style.Failure, title: valueError });
      return;
    }

    setIsSaving(true);
    try {
      if (mode === "create-at-path") {
        if (!createAtPath) {
          throw new Error("Missing create-at-path target.");
        }
        await createItemAtPath(createAtPath.configPath, destinationKeyPath.slice(0, -1), nextItem);
      } else if (mode === "append-child") {
        if (!targetRecord) {
          throw new Error("Missing target record for append-child.");
        }
        if (keyPathMatches(destinationKeyPath.slice(0, -1), targetRecord.effectiveKeyPath)) {
          await appendChildToGroup(targetRecord, nextItem);
        } else {
          await createItemAtPath(destinationConfigPath, destinationKeyPath.slice(0, -1), nextItem);
        }
      } else if (mode === "create-sibling") {
        if (!targetRecord) {
          throw new Error("Missing target record for create-sibling.");
        }
        if (keyPathMatches(destinationKeyPath.slice(0, -1), targetRecord.parentEffectiveKeyPath)) {
          await insertSiblingAfter(targetRecord, nextItem);
        } else {
          await createItemAtPath(destinationConfigPath, destinationKeyPath.slice(0, -1), nextItem);
        }
      } else {
        if (!targetRecord) {
          throw new Error("Missing target record for edit mode.");
        }
        if (mode === "override-in-effective-config") {
          await updateRecord(targetRecord, nextItem, mode);
        } else {
          await updateRecordAtPath(targetRecord, nextItem, destinationKeyPath, mode);
        }
      }

      let syncError: unknown;

      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const payload = await rebuildIndex(configDirectory);
      setValidationPayload(payload);

      await props.onDidSave?.(payload, {
        configDisplayName: saveResultConfigDisplayName(mode, createAtPath, targetRecord),
        savedKeyPath: destinationKeyPath,
      });

      await showToast(
        syncError
          ? {
              style: Toast.Style.Failure,
              title: "Saved config, but Leader Key sync failed",
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: "Saved Leader Key config",
              message: "Triggered Leader Key reload",
            },
      );

      pop();
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Failed to save config",
        message: error instanceof Error ? error.message : String(error),
      });
    } finally {
      setIsSaving(false);
    }
  }

  async function handleDelete(): Promise<void> {
    if (!targetRecord || targetRecord.inherited) {
      return;
    }

    const confirmed = await confirmAlert({
      title: `Delete ${targetRecord.displayLabel}?`,
      message: "This removes the item from the source config file.",
      primaryAction: {
        style: Alert.ActionStyle.Destructive,
        title: "Delete",
      },
    });

    if (!confirmed) {
      return;
    }

    setIsSaving(true);
    try {
      await deleteRecord(targetRecord);

      let syncError: unknown;

      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const payload = await rebuildIndex(configDirectory);
      await props.onDidSave?.(payload, {
        configDisplayName: targetRecord.effectiveConfigDisplayName,
        savedKeyPath: targetRecord.parentEffectiveKeyPath,
      });

      await showToast(
        syncError
          ? {
              style: Toast.Style.Failure,
              title: "Deleted item, but Leader Key sync failed",
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: targetRecord.kind === "group" ? "Deleted group" : "Deleted item",
              message: "Triggered Leader Key reload",
            },
      );

      pop();
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Delete failed",
        message: error instanceof Error ? error.message : String(error),
      });
    } finally {
      setIsSaving(false);
    }
  }

  const showApplicationPicker = formState.type === "application";
  const showFolderPicker = formState.type === "folder";
  const showShortcutField = formState.type === "shortcut";
  const showUrlField = formState.type === "url";
  const showCommandField = formState.type === "command";
  const showMenuField = formState.type === "menu";
  const showTextField = formState.type === "text";
  const showIntellijField = formState.type === "intellij";
  const showKeystrokeFields = formState.type === "keystroke";
  const showStickyModeField = formState.type !== "toggleStickyMode";
  const fullPathInfo = pathIsEditable(mode)
    ? [
        "Use tokenized syntax like a -> left -> space.",
        pathValidation?.autoCreateGroupKeys.length
          ? `Missing parent groups will be created automatically: ${formatFullPath(pathValidation.autoCreateGroupKeys)}.`
          : undefined,
        pathValidation?.overrideRecord
          ? `This will create a local override for inherited ${pathValidation.overrideRecord.displayLabel}.`
          : undefined,
      ].filter(Boolean).join("\n")
    : fixedPathInfo;
  const valueFieldError = valueError;

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm icon={Icon.CheckCircle} onSubmit={handleSubmit} title={isSaving ? "Saving…" : "Save"} />
          {canDeleteTarget ? (
            <Action
              icon={Icon.Trash}
              onAction={() => void handleDelete()}
              style={Action.Style.Destructive}
              title={targetRecord?.kind === "group" ? "Delete Group" : "Delete Item"}
            />
          ) : null}
        </ActionPanel>
      }
      isLoading={isSaving}
      navigationTitle={title}
    >
      <Form.Description
        text={`Config: ${destinationConfigDisplayName || "—"}\nCurrent Path: ${currentPathText || "—"}`}
        title="Context"
      />
      <Form.Separator />
      {formState.type === "group" ? (
        <Form.TextField
          id="label"
          onChange={(value) => setFormState((current) => ({ ...current, label: value }))}
          placeholder={primaryTextFieldPlaceholder}
          title={primaryTextFieldTitle}
          value={formState.label}
        />
      ) : null}
      {formState.type === "group" ? (
        <Form.TextField
          error={pathError}
          id="fullPath"
          info={fullPathInfo}
          onChange={(value) => {
            if (!pathIsEditable(mode)) {
              return;
            }
            setFormState((current) => ({ ...current, fullPath: value }));
          }}
          title="Full Path"
          value={pathIsEditable(mode) ? formState.fullPath : currentPathText}
        />
      ) : null}
      <Form.Dropdown
        id="type"
        onChange={(value) => setFormState((current) => ({ ...current, type: value as ConfigItem["type"] }))}
        title="Type"
        value={formState.type}
      >
        <Form.Dropdown.Item title="Application" value="application" />
        <Form.Dropdown.Item title="Command" value="command" />
        <Form.Dropdown.Item title="Folder" value="folder" />
        <Form.Dropdown.Item title="Group" value="group" />
        <Form.Dropdown.Item title="IntelliJ" value="intellij" />
        <Form.Dropdown.Item title="Keystroke" value="keystroke" />
        <Form.Dropdown.Item title="Macro" value="macro" />
        <Form.Dropdown.Item title="Menu" value="menu" />
        <Form.Dropdown.Item title="Shortcut" value="shortcut" />
        <Form.Dropdown.Item title="Text" value="text" />
        <Form.Dropdown.Item title="Toggle Sticky Mode" value="toggleStickyMode" />
        <Form.Dropdown.Item title="URL" value="url" />
      </Form.Dropdown>

      {showApplicationPicker ? (
        <Form.Dropdown
          filtering
          id="applicationPath"
          error={valueFieldError}
          onChange={(value) => setFormState((current) => ({ ...current, applicationPath: value }))}
          title="Application"
          value={formState.applicationPath}
        >
          {formState.applicationPath ? (
            <Form.Dropdown.Item title={formState.applicationPath} value={formState.applicationPath} />
          ) : null}
          {installedApps.map((app) => (
            <Form.Dropdown.Item key={app.bundlePath} title={app.name} value={app.bundlePath} />
          ))}
        </Form.Dropdown>
      ) : null}

      {showFolderPicker ? (
        <Form.FilePicker
          allowMultipleSelection={false}
          canChooseDirectories
          canChooseFiles={false}
          error={valueFieldError}
          id="folderPath"
          onChange={(value) => setFormState((current) => ({ ...current, folderPath: value[0] ?? "" }))}
          title="Folder"
          value={formState.folderPath ? [formState.folderPath] : []}
        />
      ) : null}

      {showShortcutField ? (
        <Form.TextField
          error={valueFieldError}
          id="shortcutValue"
          onChange={(value) => setFormState((current) => ({ ...current, shortcutValue: value }))}
          title="Shortcut"
          value={formState.shortcutValue}
        />
      ) : null}

      {showKeystrokeFields ? (
        <>
          <Form.Dropdown
            filtering
            id="keystrokeApp"
            onChange={(value) =>
              setFormState((current) => ({
                ...current,
                keystroke: {
                  ...current.keystroke,
                  app: value === "__none__" ? undefined : value,
                },
              }))}
            title="Target App"
            value={formState.keystroke.app ?? "__none__"}
          >
            <Form.Dropdown.Item title="Frontmost App" value="__none__" />
            {installedApps.map((app) => (
              <Form.Dropdown.Item key={app.bundlePath} title={app.name} value={app.name} />
            ))}
          </Form.Dropdown>
          <Form.Checkbox
            id="focusTargetApp"
            label="Focus Target App After Send"
            onChange={(value) =>
              setFormState((current) => ({
                ...current,
                keystroke: { ...current.keystroke, focusTargetApp: value },
              }))}
            value={formState.keystroke.focusTargetApp}
          />
          <Form.TextField
            error={valueFieldError}
            id="keystrokeSpec"
            onChange={(value) =>
              setFormState((current) => ({
                ...current,
                keystroke: { ...current.keystroke, spec: value },
              }))}
            title="Keystroke"
            value={formState.keystroke.spec}
          />
        </>
      ) : null}

      {showUrlField ? (
        <>
          <Form.TextField
            error={valueFieldError}
            id="urlValue"
            onChange={(value) => setFormState((current) => ({ ...current, urlValue: value }))}
            title="URL"
            value={formState.urlValue}
          />
          <Form.Checkbox
            id="activates"
            label="Activate App"
            onChange={(value) => setFormState((current) => ({ ...current, activates: value }))}
            value={formState.activates}
          />
        </>
      ) : null}

      {showCommandField ? (
        <Form.TextArea
          error={valueFieldError}
          id="commandValue"
          onChange={(value) => setFormState((current) => ({ ...current, commandValue: value }))}
          title="Command"
          value={formState.commandValue}
        />
      ) : null}

      {showMenuField ? (
        <Form.TextField
          error={valueFieldError}
          id="menuValue"
          onChange={(value) => setFormState((current) => ({ ...current, menuValue: value }))}
          title="Menu Path"
          value={formState.menuValue}
        />
      ) : null}

      {showTextField ? (
        <Form.TextArea
          error={valueFieldError}
          id="textValue"
          onChange={(value) => setFormState((current) => ({ ...current, textValue: value }))}
          title="Text"
          value={formState.textValue}
        />
      ) : null}

      {showIntellijField ? (
        <Form.TextField
          error={valueFieldError}
          id="intellijValue"
          onChange={(value) => setFormState((current) => ({ ...current, intellijValue: value }))}
          title="IntelliJ Actions"
          value={formState.intellijValue}
        />
      ) : null}
      {formState.type !== "group" ? (
        <Form.TextField
          id="description"
          onChange={(value) => setFormState((current) => ({ ...current, description: value }))}
          placeholder={primaryTextFieldPlaceholder}
          title={primaryTextFieldTitle}
          value={formState.description}
        />
      ) : null}
      {formState.type !== "group" ? (
        <Form.TextField
          id="aiDescription"
          info="Optional AI-generated description. Search includes this text when present."
          onChange={(value) => setFormState((current) => ({ ...current, aiDescription: value }))}
          placeholder="Reserved for AI-generated notes"
          title="AI Description"
          value={formState.aiDescription}
        />
      ) : null}
      {formState.type !== "group" ? (
        <Form.TextField
          error={pathError}
          id="fullPath"
          info={fullPathInfo}
          onChange={(value) => {
            if (!pathIsEditable(mode)) {
              return;
            }
            setFormState((current) => ({ ...current, fullPath: value }));
          }}
          title="Full Path"
          value={pathIsEditable(mode) ? formState.fullPath : currentPathText}
        />
      ) : null}
      {showStickyModeField ? (
        <Form.Checkbox
          id="sticky"
          label="Sticky Mode"
          onChange={(value) => setFormState((current) => ({ ...current, stickyMode: value }))}
          value={formState.stickyMode}
        />
      ) : null}
    </Form>
  );
}
