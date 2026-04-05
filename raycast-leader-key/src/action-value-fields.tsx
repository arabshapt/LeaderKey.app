import { Form } from "@raycast/api";
import type { InstalledApp } from "@leaderkey/config-core";
import { useMemo, type Dispatch, type SetStateAction } from "react";

import { menuAppPrefix, replaceMenuAppPrefix, type ItemFormState } from "./form-utils.js";

interface ActionValueFieldsProps {
  defaultMenuAppName?: string;
  formState: ItemFormState;
  installedApps: InstalledApp[];
  setFormState: Dispatch<SetStateAction<ItemFormState>>;
  valueFieldError?: string;
}

export function ActionValueFields(props: ActionValueFieldsProps) {
  const { defaultMenuAppName, formState, installedApps, setFormState, valueFieldError } = props;

  const knownMenuAppNames = useMemo(() => {
    const names = new Set<string>();
    for (const app of installedApps) {
      names.add(app.name);
    }
    if (defaultMenuAppName) {
      names.add(defaultMenuAppName);
    }
    return Array.from(names).sort((left, right) => left.localeCompare(right));
  }, [defaultMenuAppName, installedApps]);
  const selectedMenuAppName = menuAppPrefix(formState.menuValue, knownMenuAppNames);
  const selectedMenuAppValue = selectedMenuAppName
    ? installedApps.find((app) => app.name === selectedMenuAppName)?.bundlePath ?? `__current__:${selectedMenuAppName}`
    : "__none__";

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
            info="Selecting an app only rewrites the leading app prefix."
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
            {installedApps.map((app) => (
              <Form.Dropdown.Item key={app.bundlePath} title={app.name} value={app.bundlePath} />
            ))}
          </Form.Dropdown>
          <Form.TextField
            error={valueFieldError}
            id="menuValue"
            info="Stored as App > Menu > Item. Use the app picker above to set the prefix quickly."
            onChange={(value) => setFormState((current) => ({ ...current, menuValue: value }))}
            title="Menu Path"
            value={formState.menuValue}
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
        <Form.TextField
          error={valueFieldError}
          id="intellijValue"
          onChange={(value) => setFormState((current) => ({ ...current, intellijValue: value }))}
          title="IntelliJ Actions"
          value={formState.intellijValue}
        />
      ) : null}
    </>
  );
}
