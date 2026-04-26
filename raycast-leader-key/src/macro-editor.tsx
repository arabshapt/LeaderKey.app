import {
  Action,
  ActionPanel,
  Form,
  Icon,
  List,
  Toast,
  showToast,
  useNavigation,
} from "@raycast/api";
import {
  actionValuePreview,
  generateActionLabel,
  macroStepSummary,
  type ActionNode,
  type InstalledApp,
  type MacroStep,
} from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { type MacroStepActionType, cloneMacroSteps, createEmptyMacroStep, formStateToActionNode, validateActionNode } from "./action-form.js";
import { ActionValueFieldActions, ActionValueFields, knownMenuAppNamesFor } from "./action-value-fields.js";
import { itemToFormState, menuAppPrefix, replaceMenuAppPrefix, type ItemFormState } from "./form-utils.js";
import { SHORTCUTS } from "./shortcuts.js";

const MACRO_STEP_TYPE_OPTIONS: Array<{ title: string; value: MacroStepActionType }> = [
  { title: "Application", value: "application" },
  { title: "Command", value: "command" },
  { title: "Folder", value: "folder" },
  { title: "IntelliJ", value: "intellij" },
  { title: "Keystroke", value: "keystroke" },
  { title: "Macro", value: "macro" },
  { title: "Menu", value: "menu" },
  { title: "Shortcut", value: "shortcut" },
  { title: "Text", value: "text" },
  { title: "Normal Mode Enable", value: "normalModeEnable" },
  { title: "Normal Mode Input", value: "normalModeInput" },
  { title: "Normal Mode Disable", value: "normalModeDisable" },
  { title: "Toggle Hint Overlay", value: "toggleHintOverlay" },
  { title: "Toggle Sticky Mode", value: "toggleStickyMode" },
  { title: "URL", value: "url" },
];

const EMPTY_ITEM_CONTEXT = {
  breadcrumbPath: [],
  configDisplayName: "",
  inherited: false,
};

interface MacroStepsEditorProps {
  defaultMenuAppName?: string;
  initialSteps: MacroStep[];
  installedApps: InstalledApp[];
  onChange: (steps: MacroStep[]) => void;
  title: string;
}

interface MacroStepEditorFormProps {
  defaultMenuAppName?: string;
  initialStep: MacroStep;
  installedApps: InstalledApp[];
  onSave: (step: MacroStep) => void;
  title: string;
}

function macroPreviewText(macroSteps: MacroStep[]): string {
  const summary = macroStepSummary({
    key: undefined,
    macroSteps,
    type: "macro",
    value: "",
  });
  return summary.length > 0 ? summary.join(" -> ") : "No enabled steps yet.";
}

function macroDescriptionText(macroSteps: MacroStep[]): string {
  const enabledCount = macroSteps.filter((step) => step.enabled).length;
  return [
    `Steps: ${macroSteps.length}`,
    `Enabled: ${enabledCount}`,
    `Preview: ${macroPreviewText(macroSteps)}`,
  ].join("\n");
}

function delayErrorText(delayText: string): string | undefined {
  const trimmed = delayText.trim();
  if (!trimmed) {
    return "Delay is required.";
  }

  const parsed = Number(trimmed);
  if (!Number.isFinite(parsed) || parsed < 0) {
    return "Delay must be a non-negative number.";
  }

  return undefined;
}

function selectedMenuAppNameFor(
  formState: ItemFormState,
  defaultMenuAppName: string | undefined,
  installedApps: InstalledApp[],
): string | undefined {
  if (formState.type !== "menu") {
    return undefined;
  }

  return menuAppPrefix(formState.menuValue, knownMenuAppNamesFor(defaultMenuAppName, installedApps, formState.menuValue))
    ?? defaultMenuAppName;
}

function stepTitle(step: MacroStep): string {
  return generateActionLabel(step.action, EMPTY_ITEM_CONTEXT);
}

function stepSubtitle(step: MacroStep): string {
  const parts: string[] = [step.action.type];
  const preview = actionValuePreview(step.action);
  if (preview) {
    parts.push(preview);
  }
  if (step.delay > 0) {
    parts.push(`${step.delay}s delay`);
  }
  if (!step.enabled) {
    parts.push("disabled");
  }
  return parts.join(" • ");
}

function stepSummaryText(step: MacroStep): string {
  const lines = [
    `Type: ${step.action.type}`,
    `Enabled: ${step.enabled ? "Yes" : "No"}`,
    `Delay: ${step.delay}s`,
  ];
  const preview = actionValuePreview(step.action);
  if (preview) {
    lines.push(`Preview: ${preview}`);
  }
  if (step.action.type === "macro") {
    lines.push(`Nested: ${macroDescriptionText(step.action.macroSteps ?? [])}`);
  }
  return lines.join("\n");
}

export function MacroStepsEditor(props: MacroStepsEditorProps) {
  const { defaultMenuAppName, initialSteps, installedApps, onChange, title } = props;
  const [steps, setSteps] = useState<MacroStep[]>(() => cloneMacroSteps(initialSteps));

  function updateSteps(nextSteps: MacroStep[]): void {
    setSteps(nextSteps);
    onChange(cloneMacroSteps(nextSteps));
  }

  function replaceStep(index: number, nextStep: MacroStep): void {
    updateSteps(steps.map((step, stepIndex) => (stepIndex === index ? nextStep : step)));
  }

  function deleteStep(index: number): void {
    updateSteps(steps.filter((_, stepIndex) => stepIndex !== index));
  }

  function moveStep(index: number, direction: -1 | 1): void {
    const destination = index + direction;
    if (destination < 0 || destination >= steps.length) {
      return;
    }

    const nextSteps = [...steps];
    const [step] = nextSteps.splice(index, 1);
    if (!step) {
      return;
    }
    nextSteps.splice(destination, 0, step);
    updateSteps(nextSteps);
  }

  function toggleStepEnabled(index: number): void {
    replaceStep(index, {
      ...steps[index]!,
      enabled: !steps[index]!.enabled,
    });
  }

  return (
    <List filtering={false} isShowingDetail navigationTitle={title} searchBarPlaceholder="Macro steps">
      {steps.length === 0 ? (
        <List.Item
          actions={
            <ActionPanel>
              <Action.Push
                icon={Icon.Plus}
                shortcut={SHORTCUTS.newAction}
                target={
                  <MacroStepEditorForm
                    defaultMenuAppName={defaultMenuAppName}
                    initialStep={createEmptyMacroStep()}
                    installedApps={installedApps}
                    onSave={(nextStep) => updateSteps([...steps, nextStep])}
                    title="Add Macro Step"
                  />
                }
                title="Add Step"
              />
            </ActionPanel>
          }
          icon={Icon.List}
          subtitle="Add the first step"
          title="No macro steps yet"
        />
      ) : null}
      {steps.map((step, index) => (
        <List.Item
          accessories={[
            step.enabled ? { icon: Icon.CheckCircle } : { icon: Icon.XMarkCircle },
            { text: `${index + 1}` },
          ]}
          actions={
            <ActionPanel>
              <Action.Push
                icon={Icon.Pencil}
                shortcut={SHORTCUTS.primary}
                target={
                  <MacroStepEditorForm
                    defaultMenuAppName={defaultMenuAppName}
                    initialStep={step}
                    installedApps={installedApps}
                    onSave={(nextStep) => replaceStep(index, nextStep)}
                    title={`Edit Step ${index + 1}`}
                  />
                }
                title="Edit Step"
              />
              <Action.Push
                icon={Icon.Plus}
                shortcut={SHORTCUTS.newAction}
                target={
                  <MacroStepEditorForm
                    defaultMenuAppName={defaultMenuAppName}
                    initialStep={createEmptyMacroStep()}
                    installedApps={installedApps}
                    onSave={(nextStep) => updateSteps([...steps, nextStep])}
                    title="Add Macro Step"
                  />
                }
                title="Add Step"
              />
              <Action
                icon={step.enabled ? Icon.EyeDisabled : Icon.Eye}
                onAction={() => toggleStepEnabled(index)}
                shortcut={SHORTCUTS.toggleEnabled}
                title={step.enabled ? "Disable Step" : "Enable Step"}
              />
              <Action
                icon={Icon.ArrowUp}
                onAction={() => moveStep(index, -1)}
                shortcut={SHORTCUTS.moveUp}
                title="Move Up"
              />
              <Action
                icon={Icon.ArrowDown}
                onAction={() => moveStep(index, 1)}
                shortcut={SHORTCUTS.moveDown}
                title="Move Down"
              />
              <Action
                icon={Icon.Trash}
                onAction={() => deleteStep(index)}
                shortcut={SHORTCUTS.delete}
                style={Action.Style.Destructive}
                title="Delete Step"
              />
            </ActionPanel>
          }
          detail={<List.Item.Detail markdown={stepSummaryText(step)} />}
          icon={step.action.type === "macro" ? Icon.List : Icon.Dot}
          key={`${index}-${step.action.type}-${step.action.value}`}
          subtitle={stepSubtitle(step)}
          title={stepTitle(step)}
        />
      ))}
    </List>
  );
}

export function MacroStepEditorForm(props: MacroStepEditorFormProps) {
  const { defaultMenuAppName, initialStep, installedApps, onSave, title } = props;
  const [formState, setFormState] = useState<ItemFormState>(() => itemToFormState(initialStep.action));
  const [delayText, setDelayText] = useState(() => String(initialStep.delay));
  const [enabled, setEnabled] = useState(initialStep.enabled);
  const [preservedAction] = useState<ActionNode>(() => ({
    ...initialStep.action,
    macroSteps: cloneMacroSteps(initialStep.action.macroSteps),
  }));
  const { pop } = useNavigation();

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

  const delayError = delayErrorText(delayText);

  async function handleSubmit(): Promise<void> {
    if (delayError) {
      await showToast({ style: Toast.Style.Failure, title: delayError });
      return;
    }

    const nextMenuAppName = selectedMenuAppNameFor(formState, defaultMenuAppName, installedApps);
    const nextStepAction = formStateToActionNode(formState, {
      menuAppName: nextMenuAppName,
      preserveAction: preservedAction,
      preserveHiddenMetadata: true,
    });
    const nextValueError = validateActionNode(nextStepAction);
    if (nextValueError) {
      await showToast({ style: Toast.Style.Failure, title: nextValueError });
      return;
    }

    onSave({
      action: nextStepAction,
      delay: Number(delayText.trim()),
      enabled,
    });
    pop();
  }

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
          <Action.SubmitForm icon={Icon.CheckCircle} onSubmit={handleSubmit} shortcut={SHORTCUTS.save} title="Save Step" />
          {formState.type === "macro" ? (
            <Action.Push
              icon={Icon.List}
              shortcut={SHORTCUTS.editMacroSteps}
              target={
                <MacroStepsEditor
                  defaultMenuAppName={defaultMenuAppName}
                  initialSteps={formState.macroSteps}
                  installedApps={installedApps}
                  onChange={(macroSteps) => setFormState((current) => ({ ...current, macroSteps }))}
                  title="Edit Nested Macro Steps"
                />
              }
              title="Edit Nested Macro Steps"
            />
          ) : null}
        </ActionPanel>
      }
      navigationTitle={title}
    >
      <Form.Checkbox
        id="enabled"
        label="Enabled"
        onChange={setEnabled}
        value={enabled}
      />
      <Form.TextField
        error={delayError}
        id="delay"
        onChange={setDelayText}
        title="Delay (seconds)"
        value={delayText}
      />
      <Form.Dropdown
        id="type"
        onChange={(value) =>
          setFormState((current) => {
            const nextType = value as MacroStepActionType;
            if (current.type === nextType) {
              return current;
            }

            const nextState = { ...current, type: nextType };
            if (nextType === "menu" && !current.menuValue.trim() && defaultMenuAppName) {
              nextState.menuValue = replaceMenuAppPrefix("", defaultMenuAppName);
            }

            return nextState;
          })}
        title="Type"
        value={formState.type}
      >
        {MACRO_STEP_TYPE_OPTIONS.map((option) => (
          <Form.Dropdown.Item key={option.value} title={option.title} value={option.value} />
        ))}
      </Form.Dropdown>
      {formState.type === "macro" ? (
        <Form.Description
          text={macroDescriptionText(formState.macroSteps)}
          title="Nested Macro"
        />
      ) : null}
      <ActionValueFields
        defaultMenuAppName={defaultMenuAppName}
        formState={formState}
        installedApps={installedApps}
        setFormState={setFormState}
      />
    </Form>
  );
}
