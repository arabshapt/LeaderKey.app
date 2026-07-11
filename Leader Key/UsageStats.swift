import Combine
import Defaults
import Foundation

enum UsageScope: String, Codable, CaseIterable {
  case global
  case fallback
  case app
}

struct UsageContext: Codable, Hashable {
  let scope: UsageScope
  let bundleId: String?

  init(scope: UsageScope, bundleId: String? = nil) {
    self.scope = scope
    let trimmedBundleId = bundleId?.trimmingCharacters(in: .whitespacesAndNewlines)
    self.bundleId = trimmedBundleId?.isEmpty == false ? trimmedBundleId : nil
  }
}

struct UsageRecord: Codable, Equatable {
  let context: UsageContext
  let keys: [String]
  var count: Int
  let firstObservedAt: Date
}

struct UsageStatsSnapshot: Equatable {
  var records: [UsageRecord]
  var totalExecutions: Int

  static let empty = UsageStatsSnapshot(records: [], totalExecutions: 0)

  func count(context: UsageContext, keys: [String]) -> Int {
    records.first { $0.context == context && $0.keys == keys }?.count ?? 0
  }

  func totalExecutions(in context: UsageContext) -> Int {
    records.lazy.filter { $0.context == context }.reduce(0) { $0 + $1.count }
  }

  func firstObservedAt(in context: UsageContext) -> Date? {
    records.lazy.filter { $0.context == context }.map(\.firstObservedAt).min()
  }
}

private struct UsageRecordKey: Hashable {
  let context: UsageContext
  let keys: [String]
}

private struct UsageStatsDocument: Codable {
  static let currentVersion = 1

  var version: Int
  var records: [UsageRecord]
  var totalExecutions: Int

  static let empty = UsageStatsDocument(
    version: currentVersion,
    records: [],
    totalExecutions: 0
  )
}

final class UsageStatsStore: ObservableObject, @unchecked Sendable {
  static let shared = UsageStatsStore()
  static let fileName = "usage-stats.json"

  @Published private(set) var snapshot = UsageStatsSnapshot.empty

  private let lock = NSLock()
  private let fileManager: FileManager
  private let configDirectoryProvider: () -> String
  private let trackingEnabledProvider: () -> Bool
  private let now: () -> Date
  private let flushQueue: DispatchQueue
  private let debounceInterval: TimeInterval

  private var currentDirectory: String?
  private var records: [UsageRecordKey: UsageRecord] = [:]
  private var totalExecutions = 0
  private var isDirty = false
  private var debounceGeneration: UInt64 = 0
  private var pendingFlushWorkItem: DispatchWorkItem?

  init(
    fileManager: FileManager = .default,
    configDirectoryProvider: @escaping () -> String = { Defaults[.configDir] },
    trackingEnabledProvider: @escaping () -> Bool = { Defaults[.usageTrackingEnabled] },
    now: @escaping () -> Date = Date.init,
    debounceInterval: TimeInterval = 2,
    flushQueue: DispatchQueue = DispatchQueue(label: "com.leaderkey.usage-stats", qos: .utility)
  ) {
    self.fileManager = fileManager
    self.configDirectoryProvider = configDirectoryProvider
    self.trackingEnabledProvider = trackingEnabledProvider
    self.now = now
    self.debounceInterval = debounceInterval
    self.flushQueue = flushQueue
  }

  func record(context: UsageContext, keys: [String]) {
    guard trackingEnabledProvider(), !keys.isEmpty else { return }
    let directory = configDirectoryProvider()
    let observedAt = now()

    lock.lock()
    switchDirectoryIfNeededLocked(to: directory)
    let key = UsageRecordKey(context: context, keys: keys)
    if var existing = records[key] {
      existing.count += 1
      records[key] = existing
    } else {
      records[key] = UsageRecord(
        context: context,
        keys: keys,
        count: 1,
        firstObservedAt: observedAt
      )
    }
    totalExecutions += 1
    isDirty = true
    let updatedSnapshot = snapshotLocked()
    scheduleFlushLocked()
    lock.unlock()

    publish(updatedSnapshot)
  }

  func currentSnapshot() -> UsageStatsSnapshot {
    let directory = configDirectoryProvider()
    lock.lock()
    switchDirectoryIfNeededLocked(to: directory)
    let current = snapshotLocked()
    lock.unlock()
    publish(current)
    return current
  }

  func switchConfigDirectory(to directory: String) {
    lock.lock()
    switchDirectoryIfNeededLocked(to: directory)
    let current = snapshotLocked()
    lock.unlock()
    publish(current)
  }

  func clearHistory() {
    let directory = configDirectoryProvider()
    lock.lock()
    switchDirectoryIfNeededLocked(to: directory)
    records.removeAll()
    totalExecutions = 0
    isDirty = true
    cancelPendingFlushLocked()
    flushLocked()
    let current = snapshotLocked()
    lock.unlock()
    publish(current)
  }

  func flush() {
    lock.lock()
    switchDirectoryIfNeededLocked(to: configDirectoryProvider())
    cancelPendingFlushLocked()
    flushLocked()
    lock.unlock()
  }

  private func switchDirectoryIfNeededLocked(to rawDirectory: String) {
    let directory = (rawDirectory as NSString).standardizingPath
    guard currentDirectory != directory else { return }

    cancelPendingFlushLocked()
    flushLocked()
    currentDirectory = directory
    loadLocked(from: directory)
  }

  private func loadLocked(from directory: String) {
    records.removeAll()
    totalExecutions = 0
    isDirty = false

    let url = fileURL(for: directory)
    guard fileManager.fileExists(atPath: url.path) else { return }

    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let document = try decoder.decode(UsageStatsDocument.self, from: data)
      guard document.version == UsageStatsDocument.currentVersion else {
        throw UsageStatsStoreError.unsupportedVersion(document.version)
      }

      for record in document.records where !record.keys.isEmpty && record.count > 0 {
        let key = UsageRecordKey(context: record.context, keys: record.keys)
        if let existing = records[key] {
          records[key] = UsageRecord(
            context: record.context,
            keys: record.keys,
            count: existing.count + record.count,
            firstObservedAt: min(existing.firstObservedAt, record.firstObservedAt)
          )
        } else {
          records[key] = record
        }
      }
      totalExecutions = max(document.totalExecutions, records.values.reduce(0) { $0 + $1.count })
    } catch {
      recoverCorruptFileLocked(at: url)
      records.removeAll()
      totalExecutions = 0
    }
  }

  private func recoverCorruptFileLocked(at url: URL) {
    let timestamp = Int(now().timeIntervalSince1970)
    var destination = url.deletingLastPathComponent()
      .appendingPathComponent("usage-stats.corrupt-\(timestamp).json")
    if fileManager.fileExists(atPath: destination.path) {
      destination = url.deletingLastPathComponent()
        .appendingPathComponent("usage-stats.corrupt-\(timestamp)-\(UUID().uuidString).json")
    }
    do {
      try fileManager.moveItem(at: url, to: destination)
    } catch {
      debugLog("[UsageStats] Failed to preserve corrupt usage file: \(error.localizedDescription)")
    }
  }

  private func scheduleFlushLocked() {
    cancelPendingFlushLocked()
    let generation = debounceGeneration
    let workItem = DispatchWorkItem { [weak self] in
      self?.flushIfCurrent(generation: generation)
    }
    pendingFlushWorkItem = workItem
    flushQueue.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
  }

  private func flushIfCurrent(generation: UInt64) {
    lock.lock()
    guard generation == debounceGeneration else {
      lock.unlock()
      return
    }
    pendingFlushWorkItem = nil
    flushLocked()
    lock.unlock()
  }

  private func cancelPendingFlushLocked() {
    debounceGeneration &+= 1
    pendingFlushWorkItem?.cancel()
    pendingFlushWorkItem = nil
  }

  private func flushLocked() {
    guard isDirty, let currentDirectory else { return }

    do {
      try fileManager.createDirectory(
        at: URL(fileURLWithPath: currentDirectory, isDirectory: true),
        withIntermediateDirectories: true
      )
      let document = UsageStatsDocument(
        version: UsageStatsDocument.currentVersion,
        records: snapshotLocked().records,
        totalExecutions: totalExecutions
      )
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(document)
      try data.write(to: fileURL(for: currentDirectory), options: .atomic)
      isDirty = false
    } catch {
      debugLog("[UsageStats] Failed to write usage history: \(error.localizedDescription)")
    }
  }

  private func snapshotLocked() -> UsageStatsSnapshot {
    let sortedRecords = records.values.sorted { lhs, rhs in
      if lhs.context.scope.rawValue != rhs.context.scope.rawValue {
        return lhs.context.scope.rawValue < rhs.context.scope.rawValue
      }
      if (lhs.context.bundleId ?? "") != (rhs.context.bundleId ?? "") {
        return (lhs.context.bundleId ?? "") < (rhs.context.bundleId ?? "")
      }
      return lhs.keys.lexicographicallyPrecedes(rhs.keys)
    }
    return UsageStatsSnapshot(records: sortedRecords, totalExecutions: totalExecutions)
  }

  private func fileURL(for directory: String) -> URL {
    URL(fileURLWithPath: directory, isDirectory: true)
      .appendingPathComponent(Self.fileName)
  }

  private func publish(_ updatedSnapshot: UsageStatsSnapshot) {
    if Thread.isMainThread {
      snapshot = updatedSnapshot
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.snapshot = updatedSnapshot
      }
    }
  }
}

private enum UsageStatsStoreError: Error {
  case unsupportedVersion(Int)
}
