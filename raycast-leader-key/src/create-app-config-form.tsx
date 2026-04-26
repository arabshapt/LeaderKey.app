import {
  Action,
  ActionPanel,
  Form,
  Icon,
  Toast,
  getApplications,
  showToast,
  type Application,
} from "@raycast/api";
import {
  createAppConfig,
  triggerLeaderKeyConfigReload,
  type CachePayload,
  type ConfigSummary,
} from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

import { rebuildIndex } from "./cache.js";
import { SHORTCUTS } from "./shortcuts.js";

const EMPTY_TEMPLATE_VALUE = "__empty__";

interface CreateAppConfigFormProps {
  bundleId: string;
  configDirectory: string;
  initialPayload: CachePayload;
  normalMode?: boolean;
  onDidCreate?: (payload: CachePayload) => Promise<void> | void;
}

function fallbackAppName(bundleId: string): string {
  const lastSegment = bundleId.split(".").filter(Boolean).at(-1);
  return lastSegment && lastSegment.length > 0 ? lastSegment : bundleId;
}

function resolveTemplate(configs: ConfigSummary[], templateValue: string) {
  if (templateValue === EMPTY_TEMPLATE_VALUE) {
    return { kind: "empty" } as const;
  }

  const template = configs.find((config) => config.filePath === templateValue);
  if (!template) {
    throw new Error("Selected template could not be found.");
  }

  return {
    filePath: template.filePath,
    kind: "config",
  } as const;
}

export function CreateAppConfigForm(props: CreateAppConfigFormProps) {
  const { bundleId, configDirectory, initialPayload, normalMode = false, onDidCreate } = props;
  const [resolvedApp, setResolvedApp] = useState<Application>();
  const [customName, setCustomName] = useState("");
  const [templateValue, setTemplateValue] = useState(EMPTY_TEMPLATE_VALUE);
  const [isSaving, setIsSaving] = useState(false);
  const [didEditCustomName, setDidEditCustomName] = useState(false);

  useEffect(() => {
    let isMounted = true;

    void getApplications()
      .then((applications) => {
        if (!isMounted) {
          return;
        }

        const matchingApp = applications.find((application) => application.bundleId === bundleId);
        setResolvedApp(matchingApp);

        if (!didEditCustomName && !customName.trim()) {
          setCustomName(matchingApp?.name ?? fallbackAppName(bundleId));
        }
      })
      .catch(() => {
        if (isMounted && !didEditCustomName && !customName.trim()) {
          setCustomName(fallbackAppName(bundleId));
        }
      });

    return () => {
      isMounted = false;
    };
  }, [bundleId, didEditCustomName]);

  const appName = resolvedApp?.name ?? fallbackAppName(bundleId);
  const templateOptions = useMemo(
    () => [
      { title: "Empty", value: EMPTY_TEMPLATE_VALUE },
      ...initialPayload.configs.map((config) => ({
        title: config.displayName,
        value: config.filePath,
      })),
    ],
    [initialPayload.configs],
  );

  async function handleSubmit(): Promise<void> {
    setIsSaving(true);

    try {
      const template = resolveTemplate(initialPayload.configs, templateValue);
      await createAppConfig(configDirectory, {
        bundleId,
        customName: customName.trim() || undefined,
        normalMode,
        template: template.kind === "empty" ? { kind: "empty" } : { filePath: template.filePath, kind: "config" },
      });

      let syncError: unknown;
      try {
        await triggerLeaderKeyConfigReload(configDirectory);
      } catch (error) {
        syncError = error;
      }

      const nextPayload = await rebuildIndex(configDirectory);
      await onDidCreate?.(nextPayload);

      await showToast(
        syncError
          ? {
              style: Toast.Style.Failure,
              title: "Created app config, but Leader Key sync failed",
              message: syncError instanceof Error ? syncError.message : String(syncError),
            }
          : {
              style: Toast.Style.Success,
              title: `Created ${normalMode ? "normal " : ""}${appName} config`,
              message: "Triggered Leader Key reload",
            },
      );
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Failed to create app config",
        message: error instanceof Error ? error.message : String(error),
      });
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            icon={Icon.PlusCircle}
            onSubmit={handleSubmit}
            shortcut={SHORTCUTS.save}
            title={isSaving ? "Creating…" : normalMode ? "Create Normal App Config" : "Create App Config"}
          />
        </ActionPanel>
      }
      isLoading={isSaving}
      navigationTitle={`Create ${normalMode ? "Normal " : ""}Config for ${appName}`}
    >
      <Form.TextField
        id="appName"
        onChange={() => {}}
        title="App"
        value={appName}
      />
      <Form.TextField
        id="bundleId"
        onChange={() => {}}
        title="Bundle ID"
        value={bundleId}
      />
      <Form.TextField
        id="configScope"
        onChange={() => {}}
        title="Scope"
        value={normalMode ? "Normal Mode App Config" : "Leader Key App Config"}
      />
      <Form.Dropdown
        id="template"
        onChange={setTemplateValue}
        title="Start With"
        value={templateValue}
      >
        {templateOptions.map((option) => (
          <Form.Dropdown.Item key={option.value} title={option.title} value={option.value} />
        ))}
      </Form.Dropdown>
      <Form.TextField
        id="customName"
        onChange={(value) => {
          setDidEditCustomName(true);
          setCustomName(value);
        }}
        title="Optional Sidebar Name"
        value={customName}
      />
    </Form>
  );
}
