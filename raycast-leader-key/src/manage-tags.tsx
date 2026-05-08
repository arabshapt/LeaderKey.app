import {
  Action,
  ActionPanel,
  Alert,
  Form,
  Icon,
  List,
  Toast,
  confirmAlert,
  showToast,
  useNavigation,
} from "@raycast/api";
import {
  createTag,
  deleteTag,
  ensureTagConfigFile,
  moveAssignedTag,
  renameTag,
  tagReferences,
  triggerLeaderKeyConfigReload,
  updateTagAssignments,
  type CachePayload,
  type ConfigSummary,
  type TagAssignmentScope,
  type TagDefinition,
  type TagsRegistry,
} from "@leaderkey/config-core";
import { useMemo, useState } from "react";

import { ConfigNodesList } from "./browser.js";
import { rebuildIndex } from "./cache.js";
import { getExtensionPreferences } from "./preferences.js";
import { SHORTCUTS } from "./shortcuts.js";
import { useIndexPayload } from "./use-index-payload.js";

type RegistryMutation = () => Promise<void>;
type RegistryMutationHandler = (successTitle: string, mutation: RegistryMutation) => Promise<CachePayload | undefined>;

interface TagFormProps {
  initialName?: string;
  onSubmit: (name: string) => Promise<unknown>;
  title: string;
}

interface AssignTagFormProps {
  onSubmit: (scope: TagAssignmentScope, bundleId: string, position: "bottom" | "top") => Promise<unknown>;
  tag: TagDefinition;
}

interface AssignmentRow {
  bundleId: string;
  index: number;
  scope: TagAssignmentScope;
  tag?: TagDefinition;
  tagId: string;
}

function referenceCountText(registry: TagsRegistry, tagId: string): string {
  const references = tagReferences(registry, tagId);
  const appCount = references.filter((reference) => reference.scope === "app").length;
  const normalCount = references.filter((reference) => reference.scope === "normalApp").length;
  return `${appCount} app${appCount === 1 ? "" : "s"} · ${normalCount} normal`;
}

function referencesPreview(registry: TagsRegistry, tagId: string): string {
  const references = tagReferences(registry, tagId);
  if (references.length === 0) {
    return "No app assignments";
  }

  return references
    .map((reference) => `${reference.scope === "normalApp" ? "normal " : ""}${reference.bundleId} (#${reference.index + 1})`)
    .join("\n");
}

function assignmentsForRegistry(registry: TagsRegistry): AssignmentRow[] {
  const tagsById = new Map(registry.tags.map((tag) => [tag.id, tag]));
  const rows: AssignmentRow[] = [];
  for (const scope of ["app", "normalApp"] as const) {
    for (const [bundleId, tagIds] of Object.entries(registry.assignments[scope])) {
      tagIds.forEach((tagId, index) => {
        rows.push({
          bundleId,
          index,
          scope,
          tag: tagsById.get(tagId),
          tagId,
        });
      });
    }
  }

  return rows.sort((left, right) =>
    left.scope.localeCompare(right.scope) ||
    left.bundleId.localeCompare(right.bundleId) ||
    left.index - right.index
  );
}

function tagConfigSummary(payload: CachePayload, tagId: string, normalMode: boolean): ConfigSummary | undefined {
  return payload.configs.find((config) =>
    config.tagId === tagId &&
    config.scope === (normalMode ? "normalTag" : "tag")
  );
}

function tagById(registry: TagsRegistry, tagId: string): TagDefinition | undefined {
  return registry.tags.find((tag) => tag.id === tagId);
}

function TagNameForm(props: TagFormProps) {
  const { initialName = "", onSubmit, title } = props;
  const [name, setName] = useState(initialName);
  const [isSaving, setIsSaving] = useState(false);
  const { pop } = useNavigation();

  async function handleSubmit(): Promise<void> {
    if (!name.trim()) {
      await showToast({ style: Toast.Style.Failure, title: "Tag name is required" });
      return;
    }

    setIsSaving(true);
    try {
      await onSubmit(name);
      pop();
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            icon={Icon.CheckCircle}
            onSubmit={handleSubmit}
            shortcut={SHORTCUTS.save}
            title={isSaving ? "Saving…" : "Save Tag"}
          />
        </ActionPanel>
      }
      isLoading={isSaving}
      navigationTitle={title}
    >
      <Form.TextField
        id="name"
        onChange={setName}
        placeholder="Browser"
        title="Name"
        value={name}
      />
    </Form>
  );
}

function AssignTagForm(props: AssignTagFormProps) {
  const { onSubmit, tag } = props;
  const [bundleId, setBundleId] = useState("");
  const [scope, setScope] = useState<TagAssignmentScope>("app");
  const [position, setPosition] = useState<"bottom" | "top">("bottom");
  const [isSaving, setIsSaving] = useState(false);
  const { pop } = useNavigation();

  async function handleSubmit(): Promise<void> {
    if (!bundleId.trim()) {
      await showToast({ style: Toast.Style.Failure, title: "Bundle ID is required" });
      return;
    }

    setIsSaving(true);
    try {
      await onSubmit(scope, bundleId, position);
      pop();
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            icon={Icon.Tag}
            onSubmit={handleSubmit}
            shortcut={SHORTCUTS.save}
            title={isSaving ? "Assigning…" : `Assign ${tag.name}`}
          />
        </ActionPanel>
      }
      isLoading={isSaving}
      navigationTitle={`Assign ${tag.name}`}
    >
      <Form.TextField
        id="bundleId"
        info="Assignments can target an existing app config or create a virtual app config through the registry."
        onChange={setBundleId}
        placeholder="com.google.Chrome"
        title="Bundle ID"
        value={bundleId}
      />
      <Form.Dropdown
        id="scope"
        onChange={(value) => setScope(value as TagAssignmentScope)}
        title="Scope"
        value={scope}
      >
        <Form.Dropdown.Item title="App Config" value="app" />
        <Form.Dropdown.Item title="Normal App Config" value="normalApp" />
      </Form.Dropdown>
      <Form.Dropdown
        id="position"
        info="Top tags win over lower tags."
        onChange={(value) => setPosition(value as "bottom" | "top")}
        title="Priority"
        value={position}
      >
        <Form.Dropdown.Item title="Add at Bottom" value="bottom" />
        <Form.Dropdown.Item title="Add at Top" value="top" />
      </Form.Dropdown>
    </Form>
  );
}

export default function ManageTagsCommand() {
  const { configDirectory, preferredEditor } = getExtensionPreferences();
  const { payload, setPayload, isInitialLoading, isRefreshing, loadError, loadingSubtitle, reload } = useIndexPayload(configDirectory, {
    seedFromDisk: true,
  });
  const { push } = useNavigation();

  const registry = payload?.tagsRegistry;
  const assignmentRows = useMemo(
    () => registry ? assignmentsForRegistry(registry) : [],
    [registry],
  );

  async function runMutation(successTitle: string, mutation: RegistryMutation): Promise<CachePayload | undefined> {
    try {
      await mutation();

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
              title: `${successTitle}, but Leader Key sync failed`,
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: successTitle,
              message: "Triggered Leader Key reload",
            },
      );
      return nextPayload;
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Tag update failed",
        message: error instanceof Error ? error.message : String(error),
      });
      return undefined;
    }
  }

  async function openTagConfig(tag: TagDefinition, normalMode: boolean): Promise<void> {
    const nextPayload = await runMutation(
      normalMode ? `Opened normal ${tag.name} tag config` : `Opened ${tag.name} tag config`,
      () => ensureTagConfigFile(configDirectory, tag.id, normalMode).then(() => undefined),
    );
    if (!nextPayload) {
      return;
    }

    const summary = tagConfigSummary(nextPayload, tag.id, normalMode);
    if (!summary) {
      await showToast({ style: Toast.Style.Failure, title: "Tag config was not found after creation" });
      return;
    }

    push(
      <ConfigNodesList
        configDirectory={configDirectory}
        configDisplayName={summary.displayName}
        initialPayload={nextPayload}
        onDidMutate={setPayload}
        preferredEditor={preferredEditor}
      />,
    );
  }

  async function confirmDeleteTag(tag: TagDefinition): Promise<void> {
    if (!registry) {
      return;
    }

    const references = tagReferences(registry, tag.id);
    const confirmed = await confirmAlert({
      title: references.length > 0 ? `Delete ${tag.name} and remove assignments?` : `Delete ${tag.name}?`,
      message: references.length > 0
        ? `This tag is assigned to ${references.length} app config${references.length === 1 ? "" : "s"}.\n\n${referencesPreview(registry, tag.id)}`
        : "This removes the regular and normal tag config files if they exist.",
      primaryAction: {
        style: Alert.ActionStyle.Destructive,
        title: references.length > 0 ? "Delete and Remove Assignments" : "Delete Tag",
      },
    });

    if (!confirmed) {
      return;
    }

    await runMutation(`Deleted ${tag.name}`, () =>
      deleteTag(configDirectory, tag.id, { removeAssignments: references.length > 0 })
    );
  }

  async function assignTag(tag: TagDefinition, scope: TagAssignmentScope, bundleId: string, position: "bottom" | "top"): Promise<void> {
    if (!registry) {
      return;
    }

    const normalizedBundleId = bundleId.trim();
    const current = registry.assignments[scope][normalizedBundleId] ?? [];
    const withoutTag = current.filter((tagId) => tagId !== tag.id);
    const next = position === "top" ? [tag.id, ...withoutTag] : [...withoutTag, tag.id];
    await runMutation(`Assigned ${tag.name}`, () =>
      updateTagAssignments(configDirectory, scope, normalizedBundleId, next).then(() => undefined)
    );
  }

  async function removeAssignment(row: AssignmentRow): Promise<void> {
    if (!registry) {
      return;
    }

    const current = registry.assignments[row.scope][row.bundleId] ?? [];
    await runMutation(`Removed ${row.tag?.name ?? row.tagId} from ${row.bundleId}`, () =>
      updateTagAssignments(
        configDirectory,
        row.scope,
        row.bundleId,
        current.filter((tagId) => tagId !== row.tagId),
      ).then(() => undefined)
    );
  }

  async function moveAssignment(row: AssignmentRow, direction: -1 | 1): Promise<void> {
    await runMutation(`Moved ${row.tag?.name ?? row.tagId}`, () =>
      moveAssignedTag(configDirectory, row.scope, row.bundleId, row.tagId, direction).then(() => undefined)
    );
  }

  if (!payload) {
    if (loadError) {
      return (
        <List searchBarPlaceholder="Manage Leader Key tags">
          <List.Item
            icon={Icon.ExclamationMark}
            id="tags-index-load-error"
            subtitle={loadError}
            title="Couldn’t load Leader Key configs"
            actions={
              <ActionPanel>
                <Action icon={Icon.ArrowClockwise} onAction={reload} shortcut={SHORTCUTS.refresh} title="Retry Loading Index" />
              </ActionPanel>
            }
          />
        </List>
      );
    }

    return (
      <List isLoading={isInitialLoading} searchBarPlaceholder="Manage Leader Key tags">
        <List.Item id="loading-tags" subtitle={loadingSubtitle} title="Loading tags…" />
      </List>
    );
  }

  const readyRegistry = payload.tagsRegistry;

  return (
    <List isLoading={isRefreshing} searchBarPlaceholder="Manage Leader Key tags">
      <List.Section title="Tags">
        {readyRegistry.tags.length === 0 ? (
          <List.Item
            icon={Icon.Tag}
            id="tags-empty"
            subtitle="Create a reusable group of app shortcuts"
            title="No Tags"
            actions={
              <ActionPanel>
                <Action.Push
                  icon={Icon.Plus}
                  target={
                    <TagNameForm
                      onSubmit={(name) => runMutation(`Created ${name}`, () => createTag(configDirectory, { name }).then(() => undefined))}
                      title="Create Tag"
                    />
                  }
                  title="Create Tag"
                />
              </ActionPanel>
            }
          />
        ) : null}
        {readyRegistry.tags.map((tag) => (
          <List.Item
            accessories={[
              { tag: { value: tag.id } },
              { text: referenceCountText(readyRegistry, tag.id), tooltip: referencesPreview(readyRegistry, tag.id) },
            ]}
            icon={Icon.Tag}
            id={`tag:${tag.id}`}
            key={tag.id}
            subtitle={tag.id}
            title={tag.name}
            actions={
              <ActionPanel>
                <Action
                  icon={Icon.Document}
                  onAction={() => void openTagConfig(tag, false)}
                  shortcut={SHORTCUTS.primary}
                  title="Open Tag Config"
                />
                <Action
                  icon={Icon.Keyboard}
                  onAction={() => void openTagConfig(tag, true)}
                  title="Open Normal Tag Config"
                />
                <Action.Push
                  icon={Icon.Plus}
                  target={<AssignTagForm onSubmit={(scope, bundleId, position) => assignTag(tag, scope, bundleId, position)} tag={tag} />}
                  title="Assign Tag to App"
                />
                <Action.Push
                  icon={Icon.Pencil}
                  shortcut={SHORTCUTS.edit}
                  target={
                    <TagNameForm
                      initialName={tag.name}
                      onSubmit={(name) => runMutation(`Renamed ${tag.id}`, () => renameTag(configDirectory, tag.id, name).then(() => undefined))}
                      title={`Rename ${tag.name}`}
                    />
                  }
                  title="Rename Tag"
                />
                <Action
                  icon={Icon.Trash}
                  onAction={() => void confirmDeleteTag(tag)}
                  shortcut={SHORTCUTS.delete}
                  style={Action.Style.Destructive}
                  title="Delete Tag"
                />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>

      <List.Section title="Assignments">
        {assignmentRows.length === 0 ? (
          <List.Item
            icon={Icon.AppWindow}
            id="assignments-empty"
            subtitle="Assign tags to apps from a tag row"
            title="No Tag Assignments"
          />
        ) : null}
        {assignmentRows.map((row) => {
          const activeTag = row.tag ?? tagById(readyRegistry, row.tagId);
          const tagName = activeTag?.name ?? row.tagId;
          const currentAssignments = readyRegistry.assignments[row.scope][row.bundleId] ?? [];
          return (
            <List.Item
              accessories={[
                { tag: { value: row.scope === "normalApp" ? "normal" : "app" } },
                { text: `#${row.index + 1}`, tooltip: "Top tag wins" },
              ]}
              icon={Icon.AppWindow}
              id={`assignment:${row.scope}:${row.bundleId}:${row.tagId}`}
              key={`${row.scope}:${row.bundleId}:${row.tagId}`}
              subtitle={row.bundleId}
              title={tagName}
              actions={
                <ActionPanel>
                  {activeTag ? (
                    <>
                      <Action
                        icon={Icon.Document}
                        onAction={() => void openTagConfig(activeTag, row.scope === "normalApp")}
                        shortcut={SHORTCUTS.primary}
                        title="Open Assigned Tag Config"
                      />
                      <Action.Push
                        icon={Icon.Plus}
                        target={<AssignTagForm onSubmit={(scope, bundleId, position) => assignTag(activeTag, scope, bundleId, position)} tag={activeTag} />}
                        title="Assign Tag to Another App"
                      />
                    </>
                  ) : null}
                  {row.index > 0 ? (
                    <Action
                      icon={Icon.ArrowUp}
                      onAction={() => void moveAssignment(row, -1)}
                      shortcut={SHORTCUTS.moveUp}
                      title="Move Tag Up"
                    />
                  ) : null}
                  {row.index < currentAssignments.length - 1 ? (
                    <Action
                      icon={Icon.ArrowDown}
                      onAction={() => void moveAssignment(row, 1)}
                      shortcut={SHORTCUTS.moveDown}
                      title="Move Tag Down"
                    />
                  ) : null}
                  <Action
                    icon={Icon.XMarkCircle}
                    onAction={() => void removeAssignment(row)}
                    shortcut={SHORTCUTS.delete}
                    style={Action.Style.Destructive}
                    title="Remove Assignment"
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
