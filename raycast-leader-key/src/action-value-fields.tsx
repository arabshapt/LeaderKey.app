import { Action, Form, Icon } from "@raycast/api";
import {
  encodeIntellijActionValue,
  encodeMenuActionValue,
  parseIntellijActionValue,
  type InstalledApp,
} from "@leaderkey/config-core";
import { useEffect, useMemo, type Dispatch, type SetStateAction } from "react";

import { IntelliJActionPicker } from "./intellij-action-picker.js";
import { MenuFallbackPathsEditor } from "./menu-fallbacks-editor.js";
import { MenuItemPicker } from "./menu-picker.js";
import { composeMenuDraftValue, menuAppPrefix, menuPathValue, replaceMenuAppPrefix, type ItemFormState } from "./form-utils.js";

interface ActionValueFieldsProps {
  defaultMenuAppName?: string;
  formState: ItemFormState;
  installedApps: InstalledApp[];
  setFormState: Dispatch<SetStateAction<ItemFormState>>;
  valueFieldError?: string;
}

interface ActionValueFieldActionsProps {
  defaultMenuAppName?: string;
  formState: ItemFormState;
  installedApps: InstalledApp[];
  setFormState: Dispatch<SetStateAction<ItemFormState>>;
}

function normalizeCommaSeparatedActions(value: string): string[] {
  return value.split(",").map((action) => action.trim()).filter(Boolean);
}

export function knownMenuAppNamesFor(defaultMenuAppName: string | undefined, installedApps: InstalledApp[], menuValue: string): string[] {
  const names = new Set<string>();
  for (const app of installedApps) {
    names.add(app.name);
  }
  if (defaultMenuAppName) {
    names.add(defaultMenuAppName);
  }

  if (menuValue.trim().endsWith(">")) {
    const rawAppName = menuAppPrefix(menuValue);
    if (rawAppName) {
      names.add(rawAppName);
    }
  }

  return Array.from(names);
}

export function ActionValueFieldActions(props: ActionValueFieldActionsProps) {
  const { defaultMenuAppName, formState, installedApps, setFormState } = props;
  const knownMenuAppNames = useMemo(
    () => knownMenuAppNamesFor(defaultMenuAppName, installedApps, formState.menuValue),
    [defaultMenuAppName, formState.menuValue, installedApps],
  );
  const selectedMenuAppName = useMemo(
    () => menuAppPrefix(formState.menuValue, knownMenuAppNames) ?? defaultMenuAppName,
    [defaultMenuAppName, formState.menuValue, knownMenuAppNames],
  );
  const parsedIntellij = useMemo(() => parseIntellijActionValue(formState.intellijValue), [formState.intellijValue]);

  return (
    <>
      {formState.type === "menu" && selectedMenuAppName ? (
        <Action.Push
          icon={Icon.MagnifyingGlass}
          target={
            <MenuItemPicker
              appName={selectedMenuAppName}
              onSelect={(path) =>
                setFormState((current) => {
                  return {
                    ...current,
                    menuValue: encodeMenuActionValue({
                      appName: selectedMenuAppName,
                      path,
                    }),
                  };
                })}
              title="Search Menu Items"
            />
          }
          title="Search Menu Items"
        />
      ) : null}
      {formState.type === "menu" ? (
        <Action.Push
          icon={Icon.List}
          target={
            <MenuFallbackPathsEditor
              appName={selectedMenuAppName}
              initialPaths={formState.menuFallbackPaths}
              onChange={(menuFallbackPaths) => setFormState((current) => ({ ...current, menuFallbackPaths }))}
              title="Edit Fallback Menu Paths"
            />
          }
          title="Edit Fallback Menu Paths"
        />
      ) : null}
      {formState.type === "intellij" ? (
        <Action.Push
          icon={Icon.MagnifyingGlass}
          target={
            <IntelliJActionPicker
              currentActionIds={parsedIntellij.actionIds}
              currentDelayMs={parsedIntellij.delayMs}
              onAppend={(actionId) =>
                setFormState((current) => {
                  const parsed = parseIntellijActionValue(current.intellijValue);
                  return {
                    ...current,
                    intellijValue: encodeIntellijActionValue({
                      actionIds: [...parsed.actionIds, actionId],
                      delayMs: parsed.delayMs,
                    }),
                  };
                })}
              title="Search IntelliJ Actions"
            />
          }
          title="Search IntelliJ Actions"
        />
      ) : null}
    </>
  );
}

export function ActionValueFields(props: ActionValueFieldsProps) {
  const { defaultMenuAppName, formState, installedApps, setFormState, valueFieldError } = props;

  const knownMenuAppNames = useMemo(
    () => knownMenuAppNamesFor(defaultMenuAppName, installedApps, formState.menuValue).sort((left, right) => left.localeCompare(right)),
    [defaultMenuAppName, formState.menuValue, installedApps],
  );
  const parsedIntellij = useMemo(() => parseIntellijActionValue(formState.intellijValue), [formState.intellijValue]);
  const selectedMenuAppName = menuAppPrefix(formState.menuValue, knownMenuAppNames) ?? defaultMenuAppName;
  const selectedMenuPath = menuPathValue(formState.menuValue, selectedMenuAppName);
  const selectedMenuAppValue = selectedMenuAppName
    ? installedApps.find((app) => app.name === selectedMenuAppName)?.bundlePath ?? `__current__:${selectedMenuAppName}`
    : "__none__";
  const fallbackSummary = formState.menuFallbackPaths.length > 0
    ? formState.menuFallbackPaths.map((path, index) => `${index + 1}. ${path}`).join("\n")
    : "No fallback menu paths.";

  useEffect(() => {
    if (formState.type !== "menu" || !defaultMenuAppName || !formState.menuValue.trim()) {
      return;
    }

    setFormState((current) => {
      if (current.type !== "menu" || !current.menuValue.trim()) {
        return current;
      }

      const currentKnownNames = knownMenuAppNamesFor(defaultMenuAppName, installedApps, current.menuValue);
      if (menuAppPrefix(current.menuValue, currentKnownNames)) {
        return current;
      }

      return {
        ...current,
        menuValue: replaceMenuAppPrefix(current.menuValue, defaultMenuAppName),
      };
    });
  }, [defaultMenuAppName, formState.menuValue, formState.type, installedApps, setFormState]);

  return (
    <>
      {formState.type === "application" ? (
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

      {formState.type === "folder" ? (
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

      {formState.type === "shortcut" ? (
        <Form.TextField
          error={valueFieldError}
          id="shortcutValue"
          onChange={(value) => setFormState((current) => ({ ...current, shortcutValue: value }))}
          title="Shortcut"
          value={formState.shortcutValue}
        />
      ) : null}

      {formState.type === "keystroke" ? (
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

      {formState.type === "url" ? (
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

      {formState.type === "command" ? (
        <Form.TextArea
          error={valueFieldError}
          id="commandValue"
          onChange={(value) => setFormState((current) => ({ ...current, commandValue: value }))}
          title="Command"
          value={formState.commandValue}
        />
      ) : null}

      {formState.type === "menu" ? (
        <>
          <Form.Dropdown
            filtering
            id="menuApp"
            info="Selecting an app rewrites only the app prefix. Live menu search uses the selected app."
            onChange={(value) => {
              const nextAppName = value === "__none__"
                ? undefined
                : value.startsWith("__current__:")
                  ? value.slice("__current__:".length)
                  : installedApps.find((app) => app.bundlePath === value)?.name;
              setFormState((current) => ({
                ...current,
                menuValue: replaceMenuAppPrefix(current.menuValue, nextAppName, selectedMenuAppName),
              }));
            }}
            title="App"
            value={selectedMenuAppValue}
          >
            <Form.Dropdown.Item title="No App Prefix" value="__none__" />
            {selectedMenuAppName && !installedApps.some((app) => app.name === selectedMenuAppName) ? (
              <Form.Dropdown.Item title={`${selectedMenuAppName} (Current)`} value={`__current__:${selectedMenuAppName}`} />
            ) : null}
            {knownMenuAppNames
              .filter((appName) => !installedApps.some((app) => app.name === appName))
              .map((appName) => (
                <Form.Dropdown.Item key={`manual-${appName}`} title={`${appName} (Typed)`} value={`__current__:${appName}`} />
              ))}
            {installedApps.map((app) => (
              <Form.Dropdown.Item key={app.bundlePath} title={app.name} value={app.bundlePath} />
            ))}
          </Form.Dropdown>
          <Form.TextField
            error={valueFieldError}
            id="menuPrimaryPath"
            info="Stored as App > Menu > Item. The app prefix comes from the picker above."
            onChange={(value) =>
              setFormState((current) => ({
                ...current,
                menuValue: composeMenuDraftValue(value, selectedMenuAppName),
              }))}
            title="Primary Menu Path"
            value={selectedMenuPath}
          />
          <Form.Description
            text={fallbackSummary}
            title="Fallback Menu Paths"
          />
        </>
      ) : null}

      {formState.type === "text" ? (
        <Form.TextArea
          error={valueFieldError}
          id="textValue"
          onChange={(value) => setFormState((current) => ({ ...current, textValue: value }))}
          title="Text"
          value={formState.textValue}
        />
      ) : null}

      {formState.type === "intellij" ? (
        <>
          <Form.TextArea
            error={valueFieldError}
            id="intellijActions"
            info="Use search to append known actions, or edit the comma-separated IDs directly."
            onChange={(value) =>
              setFormState((current) => {
                const parsed = parseIntellijActionValue(current.intellijValue);
                return {
                  ...current,
                  intellijValue: encodeIntellijActionValue({
                    actionIds: normalizeCommaSeparatedActions(value),
                    delayMs: parsed.delayMs,
                  }),
                };
              })}
            title="IntelliJ Actions"
            value={parsedIntellij.actionIds.join(", ")}
          />
          <Form.TextField
            error={valueFieldError}
            id="intellijDelay"
            info="Optional delay in milliseconds between IntelliJ actions."
            onChange={(value) =>
              setFormState((current) => {
                const parsed = parseIntellijActionValue(current.intellijValue);
                const trimmed = value.trim();
                const nextDelayMs = trimmed ? Number.parseInt(trimmed, 10) : undefined;
                return {
                  ...current,
                  intellijValue: encodeIntellijActionValue({
                    actionIds: parsed.actionIds,
                    delayMs: Number.isFinite(nextDelayMs) ? nextDelayMs : undefined,
                  }),
                };
              })}
            title="Delay (ms)"
            value={parsedIntellij.delayMs !== undefined ? String(parsedIntellij.delayMs) : ""}
          />
        </>
      ) : null}
    </>
  );
}
