/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** Config Directory - Leader Key config directory. Defaults to ~/Library/Application Support/Leader Key. */
  "configDirectory"?: string,
  /** Preferred Editor - Editor used by Open in Editor actions. */
  "preferredEditor"?: "system" | "vscode" | "cursor" | "intellij" | "zed"
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `search-shortcuts` command */
  export type SearchShortcuts = ExtensionPreferences & {}
  /** Preferences accessible in the `browse-configs` command */
  export type BrowseConfigs = ExtensionPreferences & {}
  /** Preferences accessible in the `add-edit-by-path` command */
  export type AddEditByPath = ExtensionPreferences & {}
  /** Preferences accessible in the `rebuild-index` command */
  export type RebuildIndex = ExtensionPreferences & {}
  /** Preferences accessible in the `sync-goku-profile` command */
  export type SyncGokuProfile = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `search-shortcuts` command */
  export type SearchShortcuts = {}
  /** Arguments passed to the `browse-configs` command */
  export type BrowseConfigs = {}
  /** Arguments passed to the `add-edit-by-path` command */
  export type AddEditByPath = {}
  /** Arguments passed to the `rebuild-index` command */
  export type RebuildIndex = {}
  /** Arguments passed to the `sync-goku-profile` command */
  export type SyncGokuProfile = {}
}

