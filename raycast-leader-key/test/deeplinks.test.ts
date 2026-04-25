import assert from "node:assert/strict";
import test from "node:test";

import type { ConfigSummary } from "@leaderkey/config-core";

import {
  FRONTMOST_BUNDLE_ID_PLACEHOLDER,
  appBundleIdForConfigTarget,
  buildPathEditorDeeplink,
  buildBrowseConfigsDeeplink,
  configTargetForSummary,
  normalAppBundleIdForConfigTarget,
  resolveConfigTarget,
} from "../src/deeplinks.js";

const configs: ConfigSummary[] = [
  {
    displayName: "Global",
    filePath: "/tmp/global-config.json",
    scope: "global",
  },
  {
    displayName: "Fallback App Config",
    filePath: "/tmp/app-fallback-config.json",
    scope: "fallback",
  },
  {
    bundleId: "com.google.Chrome",
    displayName: "Chrome",
    filePath: "/tmp/app.com.google.Chrome.json",
    scope: "app",
  },
  {
    displayName: "Normal Fallback Config",
    filePath: "/tmp/normal-fallback-config.json",
    scope: "normalFallback",
  },
  {
    bundleId: "com.google.Chrome",
    displayName: "Chrome Normal",
    filePath: "/tmp/normal-app.com.google.Chrome.json",
    scope: "normalApp",
  },
];

test("configTargetForSummary produces stable browse targets", () => {
  assert.equal(configTargetForSummary(configs[0]!), "global");
  assert.equal(configTargetForSummary(configs[1]!), "fallback");
  assert.equal(configTargetForSummary(configs[2]!), "app:com.google.Chrome");
  assert.equal(configTargetForSummary(configs[3]!), "normal-fallback");
  assert.equal(configTargetForSummary(configs[4]!), "normal-app:com.google.Chrome");
});

test("resolveConfigTarget resolves explicit targets", () => {
  assert.equal(resolveConfigTarget(configs, "global")?.displayName, "Global");
  assert.equal(resolveConfigTarget(configs, "fallback")?.displayName, "Fallback App Config");
  assert.equal(resolveConfigTarget(configs, "app:com.google.Chrome")?.displayName, "Chrome");
  assert.equal(resolveConfigTarget(configs, "normal-fallback")?.displayName, "Normal Fallback Config");
  assert.equal(resolveConfigTarget(configs, "normal-app:com.google.Chrome")?.displayName, "Chrome Normal");
});

test("buildBrowseConfigsDeeplink encodes both arguments and context for browse targets", () => {
  const deeplink = buildBrowseConfigsDeeplink("app:com.google.Chrome", "arabshaptukaev", "leader-key-raycast", "browse-configs");
  assert.match(deeplink, /^raycast:\/\/extensions\/arabshaptukaev\/leader-key-raycast\/browse-configs\?/);
  assert.match(deeplink, /arguments=/);
  assert.match(deeplink, /context=/);
  assert.match(deeplink, /app%3Acom\.google\.Chrome/);
});

test("appBundleIdForConfigTarget extracts bundle ids from app targets", () => {
  assert.equal(appBundleIdForConfigTarget("app:com.apple.dt.Xcode"), "com.apple.dt.Xcode");
  assert.equal(appBundleIdForConfigTarget("global"), undefined);
});

test("normalAppBundleIdForConfigTarget extracts bundle ids from normal app targets", () => {
  assert.equal(normalAppBundleIdForConfigTarget("normal-app:com.apple.dt.Xcode"), "com.apple.dt.Xcode");
  assert.equal(normalAppBundleIdForConfigTarget("app:com.apple.dt.Xcode"), undefined);
});

test("buildBrowseConfigsDeeplink preserves the current-app placeholder for Leader Key expansion", () => {
  const deeplink = buildBrowseConfigsDeeplink(
    `app:${FRONTMOST_BUNDLE_ID_PLACEHOLDER}`,
    "arabshaptukaev",
    "leader-key-raycast",
    "browse-configs",
  );

  assert.match(deeplink, /app%3A%7BfrontmostBundleId%7D/);
});

test("buildPathEditorDeeplink preserves config target and optional initial path", () => {
  const deeplink = buildPathEditorDeeplink(
    "app:com.google.Chrome",
    "arabshaptukaev",
    "leader-key-raycast",
    "ab.c",
  );

  assert.match(deeplink, /add-edit-by-path\?/);
  assert.match(deeplink, /app%3Acom\.google\.Chrome/);
  assert.match(deeplink, /ab\.c/);
});
