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
  generateActionLabel,
  macroStepSummary,
  createItemAtPath,
  deleteRecord,
  FALLBACK_CONFIG_FILE_NAME,
  GLOBAL_CONFIG_FILE_NAME,
  NORMAL_FALLBACK_CONFIG_FILE_NAME,
  validateRecordPath,
  materializeRecordToConfigItem,
  type CachePayload,
  findInstalledApps,
  insertSiblingAfter,
  triggerLeaderKeyConfigReload,
  type ConfigItem,
  type ActionNode,
  type FlatIndexRecord,
  updateRecord,
  updateRecordAtPath,
} from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { formStateToActionNode, isModeControlActionType, validateActionNode } from "./action-form.js";
import { ActionValueFieldActions, ActionValueFields, knownMenuAppNamesFor } from "./action-value-fields.js";
import { getMemoryCachedPayload, readCachedPayloadSync, rebuildIndex } from "./cache.js";
import { isNormalConfigPath } from "./scope-utils.js";
import {
  emptyFormState,
  formatFullPath,
  itemToFormState,
  parseTokenizedFullPath,
  replaceMenuAppPrefix,
  menuAppPrefix,
  recordToFormState,
  type ItemFormState,
} from "./form-utils.js";
import { MacroStepsEditor } from "./macro-editor.js";

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

function selectedMenuAppNameFor(state: ItemFormState, defaultMenuAppName: string | undefined, installedApps: Array<{ bundlePath: string; name: string }>): string | undefined {
  if (state.type !== "menu") {
    return undefined;
  }

  return menuAppPrefix(state.menuValue, knownMenuAppNamesFor(defaultMenuAppName, installedApps, state.menuValue))
    ?? defaultMenuAppName;
}

function formStateToItem(
  state: ItemFormState,
  key: string,
  preserveItem?: ConfigItem,
  menuAppName?: string,
): ConfigItem {
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

  if (state.type === "layer") {
    const preservedLayer = preserveItem?.type === "layer" ? preserveItem : undefined;
    return {
      actions: preservedLayer?.actions ?? [],
      iconPath: preservedLayer?.iconPath,
      key,
      label: state.label.trim() || undefined,
      tapAction: state.tapAction,
      type: "layer",
    };
  }

  const action = formStateToActionNode(state, {
    menuAppName,
    preserveAction: preserveItem?.type === "group" || preserveItem?.type === "layer" ? undefined : preserveItem,
  });
  return {
    ...action,
    key,
  };
}

function validateItem(item: ConfigItem): string | undefined {
  if (item.key === undefined || item.key.length === 0) {
    return "A key is required.";
  }

  if (item.type === "group") {
    return undefined;
  }

  if (item.type === "layer") {
    if (item.tapAction) {
      const tapActionError = validateActionNode(item.tapAction);
      if (tapActionError) {
        return `Tap action: ${tapActionError}`;
      }
    }
    return undefined;
  }

  if (item.type === "macro") {
    return validateActionNode(item);
  }

  if (isModeControlActionType(item.type)) {
    return undefined;
  }

  return validateActionNode(item);
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

function inferredMenuAppName(
  mode: EditorMode,
  createAtPath: PathCreationTarget | undefined,
  targetRecord: FlatIndexRecord | undefined,
): string | undefined {
  if (mode === "create-at-path") {
    if (!createAtPath) {
      return undefined;
    }

    const fileName = createAtPath.configPath.split("/").at(-1);
    if (
      fileName === GLOBAL_CONFIG_FILE_NAME ||
      fileName === FALLBACK_CONFIG_FILE_NAME ||
      fileName === NORMAL_FALLBACK_CONFIG_FILE_NAME
    ) {
      return undefined;
    }

    return createAtPath.configDisplayName.trim() || undefined;
  }

  if (!targetRecord) {
    return undefined;
  }

  if (mode === "edit-source") {
    return targetRecord.sourceScope === "app" || targetRecord.sourceScope === "normalApp"
      ? targetRecord.sourceConfigDisplayName.trim() || undefined
      : undefined;
  }

  return targetRecord.effectiveScope === "app" || targetRecord.effectiveScope === "normalApp"
    ? targetRecord.effectiveConfigDisplayName.trim() || undefined
    : undefined;
}

function tapActionSummary(action?: ActionNode): string {
  if (!action) {
    return "Short taps pass the original key through.";
  }

  return generateActionLabel(action, {
    breadcrumbPath: [],
    configDisplayName: "",
    inherited: false,
  });
}

interface LayerTapActionEditorProps {
  defaultMenuAppName?: string;
  initialTapAction?: ActionNode;
  installedApps: Array<{ bundlePath: string; name: string }>;
  onChange: (action: ActionNode) => void;
}

function LayerTapActionEditor(props: LayerTapActionEditorProps) {
  const { defaultMenuAppName, initialTapAction, installedApps, onChange } = props;
  const [tapState, setTapState] = useState<ItemFormState>(() =>
    itemToFormState(initialTapAction ?? { type: "shortcut", value: "" }),
  );
  const { pop } = useNavigation();
  const tapMacroSummary = useMemo(
    () => macroStepSummary({
      macroSteps: tapState.macroSteps,
      type: "macro",
      value: "",
    }),
    [tapState.macroSteps],
  );

  async function handleSubmitTapAction(): Promise<void> {
    const nextMenuAppName = selectedMenuAppNameFor(tapState, defaultMenuAppName, installedApps);
    const nextAction = formStateToActionNode(tapState, {
      menuAppName: nextMenuAppName,
      preserveAction: initialTapAction,
    });
    const error = validateActionNode(nextAction);
    if (error) {
      await showToast({ style: Toast.Style.Failure, title: error });
      return;
    }

    onChange(nextAction);
    pop();
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <ActionValueFieldActions
            defaultMenuAppName={defaultMenuAppName}
            formState={tapState}
            installedApps={installedApps}
            setFormState={setTapState}
          />
          {tapState.type === "macro" ? (
            <Action.Push
              icon={Icon.List}
              target={
                <MacroStepsEditor
                  defaultMenuAppName={defaultMenuAppName}
                  initialSteps={tapState.macroSteps}
                  installedApps={installedApps}
                  onChange={(macroSteps) => setTapState((current) => ({ ...current, macroSteps }))}
                  title="Edit Tap Action Macro Steps"
                />
              }
              title="Edit Macro Steps"
            />
          ) : null}
          <Action.SubmitForm icon={Icon.CheckCircle} onSubmit={handleSubmitTapAction} title="Save Tap Action" />
        </ActionPanel>
      }
      navigationTitle="Layer Tap Action"
    >
      <Form.Dropdown
        id="tapActionType"
        onChange={(value) => setTapState((current) => ({ ...current, type: value as ActionNode["type"] }))}
        title="Type"
        value={tapState.type}
      >
        <Form.Dropdown.Item title="Application" value="application" />
        <Form.Dropdown.Item title="Command" value="command" />
        <Form.Dropdown.Item title="Folder" value="folder" />
        <Form.Dropdown.Item title="IntelliJ" value="intellij" />
        <Form.Dropdown.Item title="Keystroke" value="keystroke" />
        <Form.Dropdown.Item title="Macro" value="macro" />
        <Form.Dropdown.Item title="Menu" value="menu" />
        <Form.Dropdown.Item title="Shortcut" value="shortcut" />
        <Form.Dropdown.Item title="Text" value="text" />
        <Form.Dropdown.Item title="Normal Mode Enable" value="normalModeEnable" />
        <Form.Dropdown.Item title="Normal Mode Input" value="normalModeInput" />
        <Form.Dropdown.Item title="Normal Mode Disable" value="normalModeDisable" />
        <Form.Dropdown.Item title="Toggle Sticky Mode" value="toggleStickyMode" />
        <Form.Dropdown.Item title="URL" value="url" />
      </Form.Dropdown>
      {tapState.type === "macro" ? (
        <Form.Description
          text={[
            `Steps: ${tapState.macroSteps.length}`,
            `Enabled: ${tapState.macroSteps.filter((step) => step.enabled).length}`,
            `Preview: ${tapMacroSummary.length > 0 ? tapMacroSummary.join(" -> ") : "No enabled steps yet."}`,
          ].join("\n")}
          title="Macro Steps"
        />
      ) : null}
      <ActionValueFields
        defaultMenuAppName={defaultMenuAppName}
        formState={tapState}
        installedApps={installedApps}
        setFormState={setTapState}
      />
      {!isModeControlActionType(tapState.type) ? (
        <Form.Dropdown
          id="tapNormalModeAfter"
          info="State after this tap action runs from normal mode."
          onChange={(value) => setTapState((current) => ({ ...current, normalModeAfter: value as ItemFormState["normalModeAfter"] }))}
          title="Normal Mode After"
          value={tapState.normalModeAfter}
        >
          <Form.Dropdown.Item title="Normal" value="normal" />
          <Form.Dropdown.Item title="Input" value="input" />
          <Form.Dropdown.Item title="Disabled" value="disabled" />
        </Form.Dropdown>
      ) : null}
    </Form>
  );
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

    const nextType = initialType === "layer"
      && mode === "create-at-path"
      && createAtPath
      && !isNormalConfigPath(createAtPath.configPath)
      ? "shortcut"
      : initialType ?? "shortcut";
    const nextState = emptyFormState(nextType);
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
  const primaryTextFieldPlaceholder = formState.type === "group" || formState.type === "layer"
    ? "Optional container description"
    : "Optional action description";
  const canDeleteTarget = mode === "edit-source" && Boolean(targetRecord && !targetRecord.inherited);
  const destinationConfigPath = editableConfigPath(mode, createAtPath, targetRecord);
  const destinationConfigDisplayName = editableConfigDisplayName(mode, createAtPath, targetRecord);
  const destinationIsNormalConfig = isNormalConfigPath(destinationConfigPath);
  const defaultMenuAppName = inferredMenuAppName(mode, createAtPath, targetRecord);
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
  const macroSummary = useMemo(
    () => macroStepSummary({
      key: undefined,
      macroSteps: formState.macroSteps,
      type: "macro",
      value: "",
    }),
    [formState.macroSteps],
  );

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
    if (initialPreserveItem?.type !== "macro") {
      return;
    }

    setFormState((current) => {
      if (current.type !== "macro" || current.macroSteps.length > 0) {
        return current;
      }
      return {
        ...current,
        macroSteps: itemToFormState(initialPreserveItem).macroSteps,
      };
    });
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
          if (item.type === "macro") {
            setFormState((current) => {
              if (current.type !== "macro" || current.macroSteps.length > 0) {
                return current;
              }
              return {
                ...current,
                macroSteps: itemToFormState(item).macroSteps,
              };
            });
          }
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
    if (formState.type === "layer" && !destinationIsNormalConfig) {
      await showToast({ style: Toast.Style.Failure, title: "Layers are only supported in normal-mode configs." });
      return;
    }
    const nextMenuAppName = selectedMenuAppNameFor(formState, defaultMenuAppName, installedApps);
    const nextItem = formStateToItem(formState, destinationKey, preservedItem, nextMenuAppName);
    const nextValueError = validateItem(nextItem);
    if (nextValueError) {
      await showToast({ style: Toast.Style.Failure, title: nextValueError });
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
              title: targetRecord.kind === "group" ? "Deleted group" : targetRecord.kind === "layer" ? "Deleted layer" : "Deleted item",
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

  const showStickyModeField = formState.type !== "layer" && !isModeControlActionType(formState.type);
  const showNormalModeAfterField = formState.type !== "group" && formState.type !== "layer" && !isModeControlActionType(formState.type);
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

  useEffect(() => {
    if (formState.type !== "menu" || !defaultMenuAppName) {
      return;
    }

    setFormState((current) => {
      if (current.type !== "menu" || current.menuValue.trim()) {
        return current;
      }

      return {
        ...current,
        menuValue: replaceMenuAppPrefix("", defaultMenuAppName),
      };
    });
  }, [defaultMenuAppName, formState.type]);

  return (
    <Form
      actions={
        <ActionPanel>
          <ActionValueFieldActions
            defaultMenuAppName={defaultMenuAppName}
            formState={formState}
            installedApps={installedApps}
            setFormState={setFormState}
          />
          {formState.type === "macro" ? (
            <Action.Push
              icon={Icon.List}
              target={
                <MacroStepsEditor
                  defaultMenuAppName={defaultMenuAppName}
                  initialSteps={formState.macroSteps}
                  installedApps={installedApps}
                  onChange={(macroSteps) => setFormState((current) => ({ ...current, macroSteps }))}
                  title="Edit Macro Steps"
                />
              }
              title="Edit Macro Steps"
            />
          ) : null}
          {formState.type === "layer" ? (
            <Action.Push
              icon={Icon.Layers}
              target={
                <LayerTapActionEditor
                  defaultMenuAppName={defaultMenuAppName}
                  initialTapAction={formState.tapAction}
                  installedApps={installedApps}
                  onChange={(tapAction) => setFormState((current) => ({ ...current, tapAction }))}
                />
              }
              title={formState.tapAction ? "Edit Tap Action" : "Add Tap Action"}
            />
          ) : null}
          {formState.type === "layer" && formState.tapAction ? (
            <Action
              icon={Icon.XMarkCircle}
              onAction={() => setFormState((current) => ({ ...current, tapAction: undefined }))}
              title="Remove Tap Action"
            />
          ) : null}
          <Action.SubmitForm icon={Icon.CheckCircle} onSubmit={handleSubmit} title={isSaving ? "Saving…" : "Save"} />
          {canDeleteTarget ? (
            <Action
              icon={Icon.Trash}
              onAction={() => void handleDelete()}
              style={Action.Style.Destructive}
              title={targetRecord?.kind === "group" ? "Delete Group" : targetRecord?.kind === "layer" ? "Delete Layer" : "Delete Item"}
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
      {formState.type === "group" || formState.type === "layer" ? (
        <Form.TextField
          id="label"
          onChange={(value) => setFormState((current) => ({ ...current, label: value }))}
          placeholder={primaryTextFieldPlaceholder}
          title={primaryTextFieldTitle}
          value={formState.label}
        />
      ) : null}
      {formState.type === "group" || formState.type === "layer" ? (
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
        onChange={(value) =>
          setFormState((current) => {
            const nextType = value as ConfigItem["type"];
            if (current.type === nextType) {
              return current;
            }

            if (nextType === "menu" && !current.menuValue.trim() && defaultMenuAppName) {
              return {
                ...current,
                menuValue: replaceMenuAppPrefix("", defaultMenuAppName),
                type: nextType,
              };
            }

            return { ...current, type: nextType };
          })}
        title="Type"
        value={formState.type}
      >
        <Form.Dropdown.Item title="Application" value="application" />
        <Form.Dropdown.Item title="Command" value="command" />
        <Form.Dropdown.Item title="Folder" value="folder" />
        <Form.Dropdown.Item title="Group" value="group" />
        <Form.Dropdown.Item title="IntelliJ" value="intellij" />
        <Form.Dropdown.Item title="Keystroke" value="keystroke" />
        {destinationIsNormalConfig || formState.type === "layer" ? (
          <Form.Dropdown.Item title="Layer" value="layer" />
        ) : null}
        <Form.Dropdown.Item title="Macro" value="macro" />
        <Form.Dropdown.Item title="Menu" value="menu" />
        <Form.Dropdown.Item title="Shortcut" value="shortcut" />
        <Form.Dropdown.Item title="Text" value="text" />
        <Form.Dropdown.Item title="Normal Mode Enable" value="normalModeEnable" />
        <Form.Dropdown.Item title="Normal Mode Input" value="normalModeInput" />
        <Form.Dropdown.Item title="Normal Mode Disable" value="normalModeDisable" />
        <Form.Dropdown.Item title="Toggle Sticky Mode" value="toggleStickyMode" />
        <Form.Dropdown.Item title="URL" value="url" />
      </Form.Dropdown>
      {formState.type === "layer" ? (
        <Form.Description
          text={tapActionSummary(formState.tapAction)}
          title="Tap Action"
        />
      ) : null}

      {formState.type === "macro" ? (
        <Form.Description
          text={[
            `Steps: ${formState.macroSteps.length}`,
            `Enabled: ${formState.macroSteps.filter((step) => step.enabled).length}`,
            `Preview: ${macroSummary.length > 0 ? macroSummary.join(" -> ") : "No enabled steps yet."}`,
          ].join("\n")}
          title="Macro Steps"
        />
      ) : null}
      <ActionValueFields
        defaultMenuAppName={defaultMenuAppName}
        formState={formState}
        installedApps={installedApps}
        setFormState={setFormState}
      />
      {formState.type !== "group" && formState.type !== "layer" ? (
        <Form.TextField
          id="description"
          onChange={(value) => setFormState((current) => ({ ...current, description: value }))}
          placeholder={primaryTextFieldPlaceholder}
          title={primaryTextFieldTitle}
          value={formState.description}
        />
      ) : null}
      {formState.type !== "group" && formState.type !== "layer" ? (
        <Form.TextField
          id="aiDescription"
          info="Optional AI-generated description. Search includes this text when present."
          onChange={(value) => setFormState((current) => ({ ...current, aiDescription: value }))}
          placeholder="Reserved for AI-generated notes"
          title="AI Description"
          value={formState.aiDescription}
        />
      ) : null}
      {formState.type !== "group" && formState.type !== "layer" ? (
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
      {showNormalModeAfterField ? (
        <Form.Dropdown
          id="normalModeAfter"
          info="State after this action runs from normal mode."
          onChange={(value) => setFormState((current) => ({ ...current, normalModeAfter: value as ItemFormState["normalModeAfter"] }))}
          title="Normal Mode After"
          value={formState.normalModeAfter}
        >
          <Form.Dropdown.Item title="Normal" value="normal" />
          <Form.Dropdown.Item title="Input" value="input" />
          <Form.Dropdown.Item title="Disabled" value="disabled" />
        </Form.Dropdown>
      ) : null}
    </Form>
  );
}
