import assert from "node:assert/strict";
import test from "node:test";

import { buildEditorCommand } from "../src/index.js";

const target = {
  column: 8,
  filePath: "/tmp/demo.json",
  line: 42,
};

test("builds launcher commands when a dedicated launcher exists", () => {
  const vscode = buildEditorCommand("vscode", target, () => true);
  assert.deepEqual(vscode, {
    args: ["--goto", "/tmp/demo.json:42:8"],
    command: "code",
  });

  const intellij = buildEditorCommand("intellij", target, () => true);
  assert.deepEqual(intellij, {
    args: ["--line", "42", "/tmp/demo.json"],
    command: "idea",
  });

  const zed = buildEditorCommand("zed", target, () => true);
  assert.deepEqual(zed, {
    args: ["/tmp/demo.json:42:8"],
    command: "zed",
  });
});

test("falls back to open -a or open when no launcher exists", () => {
  const cursor = buildEditorCommand("cursor", target, () => false);
  assert.deepEqual(cursor, {
    args: ["-a", "Cursor", "/tmp/demo.json"],
    command: "open",
  });

  const system = buildEditorCommand("system", target, () => false);
  assert.deepEqual(system, {
    args: ["/tmp/demo.json"],
    command: "open",
  });
});
