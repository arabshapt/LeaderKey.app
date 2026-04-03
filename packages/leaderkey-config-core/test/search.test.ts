import assert from "node:assert/strict";
import test from "node:test";

import { searchRecords, type FlatIndexRecord } from "../src/index.js";

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
