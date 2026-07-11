import Combine
import XCTest

@testable import Leader_Key

final class UsageStatsTests: XCTestCase {
  private var temporaryDirectories: [URL] = []

  override func tearDownWithError() throws {
    for directory in temporaryDirectories {
      try? FileManager.default.removeItem(at: directory)
    }
    temporaryDirectories.removeAll()
    try super.tearDownWithError()
  }

  func testDisabledStoreDoesNotRecordOrWrite() {
    let directory = makeTemporaryDirectory()
    let store = makeStore(directory: directory, enabled: false)

    store.record(
      context: UsageContext(scope: .app, bundleId: "com.example.App"),
      keys: ["t", "N"]
    )
    store.flush()

    XCTAssertEqual(store.currentSnapshot(), .empty)
    XCTAssertFalse(FileManager.default.fileExists(atPath: usageFile(in: directory).path))
  }

  func testRecordFlushAndLoadRoundTripPreservesExactKeysAndContext() throws {
    let directory = makeTemporaryDirectory()
    let observedAt = Date(timeIntervalSince1970: 1_700_000_000)
    let context = UsageContext(scope: .app, bundleId: "com.example.App")
    let store = makeStore(directory: directory, now: { observedAt })

    store.record(context: context, keys: ["t", "N"])
    store.record(context: context, keys: ["t", "N"])
    store.record(context: UsageContext(scope: .global), keys: ["/"])
    store.flush()

    let json = try String(contentsOf: usageFile(in: directory), encoding: .utf8)
    XCTAssertTrue(json.contains("\"version\" : 1"))
    XCTAssertFalse(json.contains("actionValue"))
    XCTAssertFalse(json.contains("secret-action"))

    let reloaded = makeStore(directory: directory).currentSnapshot()
    XCTAssertEqual(reloaded.totalExecutions, 3)
    XCTAssertEqual(reloaded.count(context: context, keys: ["t", "N"]), 2)
    XCTAssertEqual(reloaded.count(context: context, keys: ["t", "n"]), 0)
    XCTAssertEqual(reloaded.firstObservedAt(in: context), observedAt)
    XCTAssertEqual(reloaded.totalExecutions(in: context), 2)
  }

  func testDebouncedFlushUsesDispatchWorkItem() {
    let directory = makeTemporaryDirectory()
    let store = makeStore(directory: directory, debounceInterval: 0.02)
    let flushed = expectation(description: "debounced usage write")

    store.record(context: UsageContext(scope: .fallback), keys: [","])
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.15) {
      if FileManager.default.fileExists(atPath: self.usageFile(in: directory).path) {
        flushed.fulfill()
      }
    }

    wait(for: [flushed], timeout: 2)
  }

  func testCorruptFileIsPreservedAndRecoveredAsEmpty() throws {
    let directory = makeTemporaryDirectory()
    try Data("not-json".utf8).write(to: usageFile(in: directory))
    let store = makeStore(
      directory: directory,
      now: { Date(timeIntervalSince1970: 1_700_000_001) }
    )

    XCTAssertEqual(store.currentSnapshot(), .empty)
    XCTAssertFalse(FileManager.default.fileExists(atPath: usageFile(in: directory).path))
    let recoveredNames = try FileManager.default.contentsOfDirectory(atPath: directory.path)
    XCTAssertTrue(recoveredNames.contains("usage-stats.corrupt-1700000001.json"))
  }

  func testConfigDirectorySwitchFlushesOldAndLoadsNewHistory() {
    let firstDirectory = makeTemporaryDirectory()
    let secondDirectory = makeTemporaryDirectory()
    let directoryBox = LockedStringBox(firstDirectory.path)
    let store = UsageStatsStore(
      configDirectoryProvider: { directoryBox.value },
      trackingEnabledProvider: { true },
      debounceInterval: 60
    )
    let firstContext = UsageContext(scope: .app, bundleId: "com.example.First")

    store.record(context: firstContext, keys: ["a"])
    directoryBox.value = secondDirectory.path
    store.switchConfigDirectory(to: secondDirectory.path)
    XCTAssertEqual(store.currentSnapshot(), .empty)

    store.record(context: UsageContext(scope: .global), keys: ["G"])
    store.flush()
    directoryBox.value = firstDirectory.path
    store.switchConfigDirectory(to: firstDirectory.path)

    let restored = store.currentSnapshot()
    XCTAssertEqual(restored.totalExecutions, 1)
    XCTAssertEqual(restored.count(context: firstContext, keys: ["a"]), 1)
  }

  func testConcurrentRecordingIsLossless() {
    let directory = makeTemporaryDirectory()
    let store = makeStore(directory: directory, debounceInterval: 60)
    let context = UsageContext(scope: .app, bundleId: "com.example.Concurrent")
    let queue = DispatchQueue(label: "UsageStatsTests.concurrent", attributes: .concurrent)
    let group = DispatchGroup()

    for index in 0..<500 {
      group.enter()
      queue.async {
        store.record(context: context, keys: ["t", index.isMultiple(of: 2) ? "N" : "/"])
        group.leave()
      }
    }

    XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
    store.flush()
    let snapshot = store.currentSnapshot()
    XCTAssertEqual(snapshot.totalExecutions, 500)
    XCTAssertEqual(snapshot.count(context: context, keys: ["t", "N"]), 250)
    XCTAssertEqual(snapshot.count(context: context, keys: ["t", "/"]), 250)
  }

  func testClearHistoryPersistsEmptyDocumentAndPublishesUpdate() throws {
    let directory = makeTemporaryDirectory()
    let store = makeStore(directory: directory, debounceInterval: 60)
    var cancellables = Set<AnyCancellable>()
    let published = expectation(description: "observable snapshot update")
    store.$snapshot.dropFirst().sink { snapshot in
      if snapshot.totalExecutions == 1 {
        published.fulfill()
      }
    }.store(in: &cancellables)

    store.record(context: UsageContext(scope: .global), keys: ["a"])
    wait(for: [published], timeout: 1)
    store.clearHistory()

    XCTAssertEqual(store.currentSnapshot(), .empty)
    XCTAssertEqual(makeStore(directory: directory).currentSnapshot(), .empty)
    let json = try String(contentsOf: usageFile(in: directory), encoding: .utf8)
    XCTAssertTrue(json.contains("\"totalExecutions\" : 0"))
  }

  private func makeStore(
    directory: URL,
    enabled: Bool = true,
    now: @escaping () -> Date = Date.init,
    debounceInterval: TimeInterval = 60
  ) -> UsageStatsStore {
    UsageStatsStore(
      configDirectoryProvider: { directory.path },
      trackingEnabledProvider: { enabled },
      now: now,
      debounceInterval: debounceInterval
    )
  }

  private func makeTemporaryDirectory() -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("UsageStatsTests-\(UUID().uuidString)", isDirectory: true)
    try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    temporaryDirectories.append(directory)
    return directory
  }

  private func usageFile(in directory: URL) -> URL {
    directory.appendingPathComponent(UsageStatsStore.fileName)
  }
}

private final class LockedStringBox: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: String

  init(_ value: String) {
    storage = value
  }

  var value: String {
    get {
      lock.lock()
      defer { lock.unlock() }
      return storage
    }
    set {
      lock.lock()
      storage = newValue
      lock.unlock()
    }
  }
}
