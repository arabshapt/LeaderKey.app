import assert from "node:assert/strict";
import test from "node:test";

import { searchRecords, searchRecordsInSubtree, type FlatIndexRecord } from "../src/index.js";

function makeRecord(overrides: Partial<FlatIndexRecord>): FlatIndexRecord {
  return {
    actionType: "application",
    activates: undefined,
    appName: undefined,
    breadcrumbDisplay: "Global -> o -> a",
    breadcrumbPath: ["Global", "o", "a"],
    childCount: undefined,
    displayLabel: "Open Arc",
    effectiveConfigDisplayName: "Global",
    effectiveConfigPath: "/tmp/global-config.json",
    effectiveKeyPath: ["o", "a"],
    effectiveScope: "global",
    id: "record",
    inherited: false,
    key: "a",
    keySequence: "o -> a",
    kind: "action",
    label: undefined,
    macroStepSummary: undefined,
    parentEffectiveKeyPath: ["o"],
    rawValue: "/Applications/Arc.app",
    searchText: "unused",
    sourceConfigDisplayName: "Global",
    sourceConfigPath: "/tmp/global-config.json",
    sourceNodePath: [0, 0],
    sourceScope: "global",
    sourceStatus: "local",
    stickyMode: undefined,
    valuePreview: "Arc",
    ...overrides,
  };
}

test("searchRecords matches shortcut path variants without separators", () => {
  const pathRecord = makeRecord({ id: "path-record" });
  const otherRecord = makeRecord({
    breadcrumbDisplay: "Global -> x -> y",
    breadcrumbPath: ["Global", "x", "y"],
    displayLabel: "Open Other",
    effectiveKeyPath: ["x", "y"],
    id: "other-record",
    key: "y",
    keySequence: "x -> y",
    parentEffectiveKeyPath: ["x"],
    rawValue: "/Applications/Other.app",
    valuePreview: "Other",
  });

  for (const query of ["oa", "o a", "o->a", "o→a"]) {
    const results = searchRecords([otherRecord, pathRecord], query);
    assert.equal(results[0]?.id, pathRecord.id, `expected ${query} to rank the path match first`);
  }
});

test("searchRecords ranks direct path hits above loose label matches", () => {
  const pathRecord = makeRecord({
    displayLabel: "Arc",
    id: "path-record",
  });
  const labelOnlyRecord = makeRecord({
    breadcrumbDisplay: "Global -> x -> y",
    breadcrumbPath: ["Global", "x", "y"],
    displayLabel: "OA helper",
    effectiveKeyPath: ["x", "y"],
    id: "label-record",
    key: "y",
    keySequence: "x -> y",
    parentEffectiveKeyPath: ["x"],
    rawValue: "oa-helper",
    valuePreview: "oa-helper",
  });

  const results = searchRecords([labelOnlyRecord, pathRecord], "oa");
  assert.equal(results[0]?.id, pathRecord.id);
});

test("searchRecordsInSubtree finds deep descendants using relative path variants", () => {
  const directChild = makeRecord({
    breadcrumbDisplay: "Global -> g -> a",
    breadcrumbPath: ["Global", "g", "a"],
    displayLabel: "Direct Arc",
    effectiveKeyPath: ["g", "a"],
    id: "direct-child",
    key: "a",
    keySequence: "g -> a",
    parentEffectiveKeyPath: ["g"],
    valuePreview: "Arc",
  });
  const deepDescendant = makeRecord({
    breadcrumbDisplay: "Global -> g -> o -> a",
    breadcrumbPath: ["Global", "g", "o", "a"],
    displayLabel: "Deep Arc",
    effectiveKeyPath: ["g", "o", "a"],
    id: "deep-descendant",
    key: "a",
    keySequence: "g -> o -> a",
    parentEffectiveKeyPath: ["g", "o"],
    valuePreview: "Arc",
  });
  const outsideBranch = makeRecord({
    breadcrumbDisplay: "Global -> o -> a",
    breadcrumbPath: ["Global", "o", "a"],
    displayLabel: "Outside Branch",
    effectiveKeyPath: ["o", "a"],
    id: "outside-branch",
    key: "a",
    keySequence: "o -> a",
    parentEffectiveKeyPath: ["o"],
    valuePreview: "Arc",
  });

  for (const query of ["oa", "o a", "o->a", "o→a"]) {
    const results = searchRecordsInSubtree([outsideBranch, directChild, deepDescendant], query, ["g"]);
    assert.equal(results[0]?.id, deepDescendant.id, `expected ${query} to match the deep relative path first`);
    assert.ok(results.every((record) => record.id !== outsideBranch.id), "expected subtree search to stay in branch");
  }
});

test("searchRecordsInSubtree falls back to absolute path matching and prefers shallower results on ties", () => {
  const directChild = makeRecord({
    breadcrumbDisplay: "Global -> g -> a",
    breadcrumbPath: ["Global", "g", "a"],
    displayLabel: "Direct Match",
    effectiveKeyPath: ["g", "a"],
    id: "direct-child",
    key: "a",
    keySequence: "g -> a",
    parentEffectiveKeyPath: ["g"],
    rawValue: "shared-value",
    valuePreview: "shared-value",
  });
  const deepDescendant = makeRecord({
    breadcrumbDisplay: "Global -> g -> x -> a",
    breadcrumbPath: ["Global", "g", "x", "a"],
    displayLabel: "Deep Match",
    effectiveKeyPath: ["g", "x", "a"],
    id: "deep-descendant",
    key: "a",
    keySequence: "g -> x -> a",
    parentEffectiveKeyPath: ["g", "x"],
    rawValue: "shared-value",
    valuePreview: "shared-value",
  });

  const absoluteResults = searchRecordsInSubtree([directChild, deepDescendant], "gxa", ["g"]);
  assert.equal(absoluteResults[0]?.id, deepDescendant.id);

  const tieResults = searchRecordsInSubtree([deepDescendant, directChild], "shared value", ["g"]);
  assert.equal(tieResults[0]?.id, directChild.id);
});
