import { LocalStorage } from "@raycast/api";
import {
  materializeRecordToConfigItem,
  type ConfigItem,
  type FlatIndexRecord,
} from "@leaderkey/config-core";

const INTERNAL_CLIPBOARD_KEY = "leaderkey-internal-clipboard";

export interface InternalClipboardPayload {
  copiedAt: string;
  item: ConfigItem;
  kind: "action" | "group" | "layer";
  sourceDisplayLabel: string;
  sourceKeyPath: string[];
}

export async function copyRecordToInternalClipboard(record: FlatIndexRecord): Promise<InternalClipboardPayload> {
  const item = await materializeRecordToConfigItem(record);
  const payload: InternalClipboardPayload = {
    copiedAt: new Date().toISOString(),
    item,
    kind: record.kind,
    sourceDisplayLabel: record.displayLabel,
    sourceKeyPath: record.effectiveKeyPath,
  };

  await LocalStorage.setItem(INTERNAL_CLIPBOARD_KEY, JSON.stringify(payload));
  return payload;
}

export async function readInternalClipboard(): Promise<InternalClipboardPayload | undefined> {
  const rawValue = await LocalStorage.getItem<string>(INTERNAL_CLIPBOARD_KEY);
  if (!rawValue) {
    return undefined;
  }

  try {
    return JSON.parse(rawValue) as InternalClipboardPayload;
  } catch {
    await LocalStorage.removeItem(INTERNAL_CLIPBOARD_KEY);
    return undefined;
  }
}
