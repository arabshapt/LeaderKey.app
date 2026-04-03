import {
  Action,
  ActionPanel,
  Form,
  Icon,
  Toast,
  showToast,
  useNavigation,
} from "@raycast/api";
import {
  appendChildToGroup,
  createItemAtPath,
  materializeRecordToConfigItem,
  type CachePayload,
  findInstalledApps,
  insertSiblingAfter,
  triggerLeaderKeyConfigReload,
  type ConfigItem,
  type FlatIndexRecord,
  updateRecord,
} from "@leaderkey/config-core";
import { useEffect, useState } from "react";

import { rebuildIndex } from "./cache.js";
import {
  emptyFormState,
  encodeKeystrokeRawValue,
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

function formStateToItem(state: ItemFormState, preserveItem?: ConfigItem): ConfigItem {
  if (state.type === "group") {
    const preservedGroup = preserveItem?.type === "group" ? preserveItem : undefined;
    return {
      actions: preservedGroup?.actions ?? [],
      iconPath: preservedGroup?.iconPath,
      key: state.key.trim(),
      label: state.label.trim() || undefined,
      stickyMode: state.stickyMode || undefined,
      type: "group",
    };
  }

  const preservedAction = preserveItem?.type === state.type ? preserveItem : undefined;
  const baseItem = {
    activates: state.type === "url" ? state.activates : undefined,
    iconPath: preservedAction?.iconPath,
    key: state.key.trim(),
    label: state.label.trim() || undefined,
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

export function RecordEditorForm(props: RecordEditorFormProps) {
  const { configDirectory, createAtPath, initialFormState, initialType, mode, preserveItem: initialPreserveItem, targetRecord, title } = props;
  const [formState, setFormState] = useState<ItemFormState>(() => {
    if (initialFormState) {
      const nextState = structuredClone(initialFormState);
      if (mode === "create-at-path" && createAtPath?.suggestedKey && !nextState.key.trim()) {
        nextState.key = createAtPath.suggestedKey;
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
    if (mode === "create-at-path" && createAtPath?.suggestedKey) {
      nextState.key = createAtPath.suggestedKey;
    }
    return nextState;
  });
  const [preservedItem, setPreservedItem] = useState<ConfigItem | undefined>(initialPreserveItem);
  const [installedApps, setInstalledApps] = useState<Array<{ bundlePath: string; name: string }>>([]);
  const [isSaving, setIsSaving] = useState(false);
  const { pop } = useNavigation();

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
    const nextItem = formStateToItem(formState, preservedItem);
    const validationError = validateItem(nextItem);
    if (validationError) {
      await showToast({ style: Toast.Style.Failure, title: validationError });
      return;
    }

    setIsSaving(true);
    try {
      if (mode === "create-at-path") {
        if (!createAtPath) {
          throw new Error("Missing create-at-path target.");
        }
        await createItemAtPath(createAtPath.configPath, createAtPath.parentKeyPath, nextItem);
      } else if (mode === "append-child") {
        if (!targetRecord) {
          throw new Error("Missing target record for append-child.");
        }
        await appendChildToGroup(targetRecord, nextItem);
      } else if (mode === "create-sibling") {
        if (!targetRecord) {
          throw new Error("Missing target record for create-sibling.");
        }
        await insertSiblingAfter(targetRecord, nextItem);
      } else {
        if (!targetRecord) {
          throw new Error("Missing target record for edit mode.");
        }
        await updateRecord(targetRecord, nextItem, mode);
      }

      let syncError: unknown;

      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const payload = await rebuildIndex(configDirectory);
      const savedKey = nextItem.key?.trim() ?? "";
      const parentPath = mode === "create-at-path"
        ? createAtPath?.parentKeyPath ?? []
        : mode === "append-child"
          ? targetRecord?.effectiveKeyPath ?? []
          : mode === "create-sibling"
            ? targetRecord?.parentEffectiveKeyPath ?? []
            : targetRecord?.effectiveKeyPath.slice(0, -1) ?? [];
      const configDisplayName = mode === "create-at-path"
        ? createAtPath?.configDisplayName ?? ""
        : targetRecord?.effectiveConfigDisplayName ?? "";

      await props.onDidSave?.(payload, {
        configDisplayName,
        savedKeyPath: savedKey ? [...parentPath, savedKey] : parentPath,
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

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm icon={Icon.CheckCircle} onSubmit={handleSubmit} title={isSaving ? "Saving…" : "Save"} />
        </ActionPanel>
      }
      isLoading={isSaving}
      navigationTitle={title}
    >
      <Form.TextField
        id="key"
        onChange={(value) => setFormState((current) => ({ ...current, key: value }))}
        title="Key"
        value={formState.key}
      />
      <Form.TextField
        id="label"
        onChange={(value) => setFormState((current) => ({ ...current, label: value }))}
        title="Label"
        value={formState.label}
      />
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
      {showStickyModeField ? (
        <Form.Checkbox
          id="sticky"
          label="Sticky Mode"
          onChange={(value) => setFormState((current) => ({ ...current, stickyMode: value }))}
          value={formState.stickyMode}
        />
      ) : null}

      {showApplicationPicker ? (
        <Form.Dropdown
          filtering
          id="applicationPath"
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
          id="folderPath"
          onChange={(value) => setFormState((current) => ({ ...current, folderPath: value[0] ?? "" }))}
          title="Folder"
          value={formState.folderPath ? [formState.folderPath] : []}
        />
      ) : null}

      {showShortcutField ? (
        <Form.TextField
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
          id="commandValue"
          onChange={(value) => setFormState((current) => ({ ...current, commandValue: value }))}
          title="Command"
          value={formState.commandValue}
        />
      ) : null}

      {showMenuField ? (
        <Form.TextField
          id="menuValue"
          onChange={(value) => setFormState((current) => ({ ...current, menuValue: value }))}
          title="Menu Path"
          value={formState.menuValue}
        />
      ) : null}

      {showTextField ? (
        <Form.TextArea
          id="textValue"
          onChange={(value) => setFormState((current) => ({ ...current, textValue: value }))}
          title="Text"
          value={formState.textValue}
        />
      ) : null}

      {showIntellijField ? (
        <Form.TextField
          id="intellijValue"
          onChange={(value) => setFormState((current) => ({ ...current, intellijValue: value }))}
          title="IntelliJ Actions"
          value={formState.intellijValue}
        />
      ) : null}
    </Form>
  );
}
