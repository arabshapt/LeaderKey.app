import { Action, ActionPanel, Form, Icon, List, Toast, showToast, useNavigation } from "@raycast/api";
import { useState } from "react";

import { MenuItemPicker } from "./menu-picker.js";
import { SHORTCUTS } from "./shortcuts.js";

interface ManualMenuPathFormProps {
  initialPath: string;
  onSave: (path: string) => void;
  title: string;
}

interface MenuFallbackPathsEditorProps {
  appName?: string;
  initialPaths: string[];
  onChange: (paths: string[]) => void;
  title: string;
}

function listMarkdown(path: string, index: number): string {
  return [`**Priority**: ${index + 1}`, `**Path**: ${path}`].join("\n\n");
}

function normalizePath(path: string): string {
  return path
    .split(">")
    .map((part) => part.trim())
    .filter(Boolean)
    .join(" > ");
}

function ManualMenuPathForm(props: ManualMenuPathFormProps) {
  const { initialPath, onSave, title } = props;
  const [path, setPath] = useState(initialPath);
  const { pop } = useNavigation();

  async function handleSubmit(): Promise<void> {
    const normalizedPath = normalizePath(path);
    if (!normalizedPath) {
      await showToast({ style: Toast.Style.Failure, title: "A fallback menu path is required." });
      return;
    }

    onSave(normalizedPath);
    pop();
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm icon={Icon.CheckCircle} onSubmit={handleSubmit} shortcut={SHORTCUTS.save} title="Save Fallback Path" />
        </ActionPanel>
      }
      navigationTitle={title}
    >
      <Form.TextField
        id="fallbackPath"
        info="Enter the menu path without the app prefix."
        onChange={setPath}
        title="Fallback Menu Path"
        value={path}
      />
    </Form>
  );
}

export function MenuFallbackPathsEditor(props: MenuFallbackPathsEditorProps) {
  const { appName, initialPaths, onChange, title } = props;
  const [paths, setPaths] = useState<string[]>(() => [...initialPaths]);

  function updatePaths(nextPaths: string[]): void {
    setPaths(nextPaths);
    onChange([...nextPaths]);
  }

  function replacePath(index: number, nextPath: string): void {
    updatePaths(paths.map((path, pathIndex) => (pathIndex === index ? nextPath : path)));
  }

  function deletePath(index: number): void {
    updatePaths(paths.filter((_, pathIndex) => pathIndex !== index));
  }

  function movePath(index: number, direction: -1 | 1): void {
    const destination = index + direction;
    if (destination < 0 || destination >= paths.length) {
      return;
    }

    const nextPaths = [...paths];
    const [path] = nextPaths.splice(index, 1);
    if (!path) {
      return;
    }
    nextPaths.splice(destination, 0, path);
    updatePaths(nextPaths);
  }

  return (
    <List filtering={false} isShowingDetail navigationTitle={title}>
      {paths.length === 0 ? (
        <List.Item
          actions={
            <ActionPanel>
              {appName ? (
                <Action.Push
                  icon={Icon.MagnifyingGlass}
                  shortcut={SHORTCUTS.searchValueSource}
                  target={
                    <MenuItemPicker
                      appName={appName}
                      onSelect={(path) => updatePaths([...paths, path])}
                      title="Add Fallback Menu Path"
                    />
                  }
                  title="Add from Live Menu Search"
                />
              ) : null}
              <Action.Push
                icon={Icon.Pencil}
                shortcut={SHORTCUTS.newAction}
                target={
                  <ManualMenuPathForm
                    initialPath=""
                    onSave={(path) => updatePaths([...paths, path])}
                    title="Add Fallback Menu Path"
                  />
                }
                title="Add Manual Fallback Path"
              />
            </ActionPanel>
          }
          detail={<List.Item.Detail markdown="No fallback menu paths configured." />}
          icon={Icon.List}
          subtitle="Try the primary menu path only"
          title="No fallback menu paths"
        />
      ) : null}
      {paths.map((path, index) => (
        <List.Item
          actions={
            <ActionPanel>
              {appName ? (
                <Action.Push
                  icon={Icon.MagnifyingGlass}
                  shortcut={SHORTCUTS.searchValueSource}
                  target={
                    <MenuItemPicker
                      appName={appName}
                      onSelect={(nextPath) => updatePaths([...paths, nextPath])}
                      title="Add Fallback Menu Path"
                    />
                  }
                  title="Add from Live Menu Search"
                />
              ) : null}
              <Action.Push
                icon={Icon.Pencil}
                shortcut={SHORTCUTS.primary}
                target={
                  <ManualMenuPathForm
                    initialPath={path}
                    onSave={(nextPath) => replacePath(index, nextPath)}
                    title={`Edit Fallback Path ${index + 1}`}
                  />
                }
                title="Edit Path"
              />
              <Action.Push
                icon={Icon.Plus}
                shortcut={SHORTCUTS.newAction}
                target={
                  <ManualMenuPathForm
                    initialPath=""
                    onSave={(nextPath) => updatePaths([...paths, nextPath])}
                    title="Add Fallback Menu Path"
                  />
                }
                title="Add Manual Fallback Path"
              />
              <Action
                icon={Icon.ArrowUp}
                onAction={() => movePath(index, -1)}
                shortcut={SHORTCUTS.moveUp}
                title="Move Up"
              />
              <Action
                icon={Icon.ArrowDown}
                onAction={() => movePath(index, 1)}
                shortcut={SHORTCUTS.moveDown}
                title="Move Down"
              />
              <Action
                icon={Icon.Trash}
                onAction={() => deletePath(index)}
                shortcut={SHORTCUTS.delete}
                style={Action.Style.Destructive}
                title="Delete Path"
              />
            </ActionPanel>
          }
          detail={<List.Item.Detail markdown={listMarkdown(path, index)} />}
          icon={Icon.AppWindow}
          key={`${index}-${path}`}
          subtitle={path}
          title={`Fallback ${index + 1}`}
        />
      ))}
    </List>
  );
}
