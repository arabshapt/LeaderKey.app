import { Action, ActionPanel, Icon, List, useNavigation } from "@raycast/api";
import { listLeaderKeyMenuItems, type LeaderKeyMenuItem } from "@leaderkey/config-core";
import { useEffect, useMemo, useState } from "react";

interface MenuItemPickerProps {
  appName: string;
  onSelect: (path: string) => void;
  title: string;
}

function detailMarkdown(item: LeaderKeyMenuItem): string {
  return [
    `**App**: ${item.appName}`,
    `**Path**: ${item.path}`,
    `**Enabled**: ${item.enabled ? "Yes" : "No"}`,
  ].join("\n\n");
}

export function MenuItemPicker(props: MenuItemPickerProps) {
  const { appName, onSelect, title } = props;
  const [items, setItems] = useState<LeaderKeyMenuItem[]>([]);
  const [error, setError] = useState<string>();
  const [isLoading, setIsLoading] = useState(true);
  const { pop } = useNavigation();

  useEffect(() => {
    let isMounted = true;
    setIsLoading(true);
    setError(undefined);

    void listLeaderKeyMenuItems(appName)
      .then((nextItems) => {
        if (!isMounted) {
          return;
        }
        setItems(nextItems);
      })
      .catch((loadError) => {
        if (!isMounted) {
          return;
        }
        setItems([]);
        setError(loadError instanceof Error ? loadError.message : String(loadError));
      })
      .finally(() => {
        if (isMounted) {
          setIsLoading(false);
        }
      });

    return () => {
      isMounted = false;
    };
  }, [appName]);

  const sortedItems = useMemo(
    () => [...items].sort((left, right) => left.path.localeCompare(right.path)),
    [items],
  );

  return (
    <List isLoading={isLoading} isShowingDetail navigationTitle={title} searchBarPlaceholder={`Search ${appName} menu items`}>
      {!isLoading && error ? (
        <List.EmptyView
          description={error}
          title="Live Menu Search Unavailable"
        />
      ) : null}
      {!isLoading && !error && sortedItems.length === 0 ? (
        <List.EmptyView
          description={`No leaf menu items were discovered for ${appName}. Make sure the app is running and accessibility access is enabled.`}
          title="No Menu Items Found"
        />
      ) : null}
      {sortedItems.map((item) => (
        <List.Item
          actions={
            <ActionPanel>
              <Action
                icon={Icon.CheckCircle}
                onAction={() => {
                  onSelect(item.path);
                  pop();
                }}
                title="Use Menu Path"
              />
            </ActionPanel>
          }
          accessories={item.enabled ? [] : [{ icon: Icon.XMarkCircle, tooltip: "Currently disabled" }]}
          detail={<List.Item.Detail markdown={detailMarkdown(item)} />}
          icon={item.enabled ? Icon.AppWindow : Icon.XMarkCircle}
          key={item.path}
          subtitle={item.path}
          title={item.title}
        />
      ))}
    </List>
  );
}
