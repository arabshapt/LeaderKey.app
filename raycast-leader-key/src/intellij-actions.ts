export interface IntelliJActionExplain {
  actionId: string;
  category?: string;
  description?: string;
  exists?: boolean;
  requirements?: {
    needsBuildSystem?: boolean;
    needsEditor?: boolean;
    needsFile?: boolean;
    needsGit?: boolean;
    needsProject?: boolean;
  };
  smartDelay?: number;
}

const INTELLIJ_ACTIONS_BASE_URL = "http://localhost:63343/api/intellij-actions";

async function fetchIntelliJJson<T>(path: string): Promise<T> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 1500);

  try {
    const response = await fetch(`${INTELLIJ_ACTIONS_BASE_URL}${path}`, {
      signal: controller.signal,
    });
    const text = await response.text();

    if (!response.ok) {
      throw new Error(text || `HTTP ${response.status}`);
    }

    return JSON.parse(text) as T;
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new Error("Timed out while querying the IntelliJ custom server.");
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

export async function searchIntelliJActions(query: string): Promise<string[]> {
  const trimmed = query.trim();
  if (!trimmed) {
    return [];
  }

  const response = await fetchIntelliJJson<{ actions?: string[] }>(`/search?q=${encodeURIComponent(trimmed)}`);
  return Array.isArray(response.actions) ? response.actions : [];
}

export async function explainIntelliJAction(actionId: string): Promise<IntelliJActionExplain> {
  return await fetchIntelliJJson<IntelliJActionExplain>(`/explain?action=${encodeURIComponent(actionId)}`);
}
