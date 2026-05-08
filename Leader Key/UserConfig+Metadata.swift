import Defaults
import Foundation

struct ConfigMetadata: Codable {
  var customName: String?
  var createdAt: Date?
  var lastModified: Date?
  var author: String?
}

struct TagReference: Identifiable, Equatable {
  var id: String { "\(scope):\(bundleId):\(tagId):\(index)" }
  let bundleId: String
  let index: Int
  let normalMode: Bool
  let scope: String
  let tagId: String
}

struct TagShadowWarning: Identifiable, Equatable {
  let id: String
  let message: String
}

extension UserConfig {

  private func metadataPath(for configPath: String) -> String {
    let configURL = URL(fileURLWithPath: configPath)
    let configNameWithoutExtension = configURL.deletingPathExtension().lastPathComponent
    let metadataFileName = "\(configNameWithoutExtension).meta.json"
    return configURL.deletingLastPathComponent().appendingPathComponent(metadataFileName).path
  }

  func loadMetadata(for configPath: String) -> ConfigMetadata? {
    let metaPath = metadataPath(for: configPath)

    guard fileManager.fileExists(atPath: metaPath) else {
      return nil
    }

    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: metaPath))
      let decoder = JSONDecoder()
      return try decoder.decode(ConfigMetadata.self, from: data)
    } catch {
      print("[UserConfig] Failed to load metadata from \(metaPath): \(error)")
      return nil
    }
  }

  func saveMetadata(_ metadata: ConfigMetadata, for configPath: String) {
    let metaPath = metadataPath(for: configPath)

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
      let data = try encoder.encode(metadata)
      try data.write(to: URL(fileURLWithPath: metaPath))
      print("[UserConfig] Successfully saved metadata to \(metaPath)")
    } catch {
      print("[UserConfig] Failed to save metadata to \(metaPath): \(error)")
    }
  }

  func deleteMetadata(for configPath: String) {
    let metaPath = metadataPath(for: configPath)

    guard fileManager.fileExists(atPath: metaPath) else {
      return
    }

    do {
      try fileManager.removeItem(atPath: metaPath)
      print("[UserConfig] Successfully deleted metadata at \(metaPath)")
    } catch {
      print("[UserConfig] Failed to delete metadata at \(metaPath): \(error)")
    }
  }

  func updateMetadataCustomName(_ customName: String?, for configPath: String) {
    var metadata = loadMetadata(for: configPath) ?? ConfigMetadata()
    metadata.customName = customName
    metadata.lastModified = Date()
    if metadata.createdAt == nil {
      metadata.createdAt = Date()
    }
    saveMetadata(metadata, for: configPath)
  }

  func migrateCustomNamesToMetadata() {
    let customNames = Defaults[.configFileCustomNames]

    guard !customNames.isEmpty else {
      print("[UserConfig] No custom names to migrate")
      return
    }

    print("[UserConfig] Migrating \(customNames.count) custom names to metadata files")

    for (configPath, customName) in customNames {
      if fileManager.fileExists(atPath: configPath) {
        var metadata = loadMetadata(for: configPath) ?? ConfigMetadata()
        if metadata.customName == nil {
          metadata.customName = customName
          metadata.createdAt = Date()
          metadata.lastModified = Date()
          saveMetadata(metadata, for: configPath)
          print("[UserConfig] Migrated custom name '\(customName)' for \(configPath)")
        }
      }
    }

    print("[UserConfig] Migration complete")
  }

  func tagsRegistryPath() -> String {
    (Defaults[.configDir] as NSString).appendingPathComponent(tagsRegistryFileName)
  }

  func loadTagsRegistry() -> TagsRegistry {
    let path = tagsRegistryPath()
    guard fileManager.fileExists(atPath: path) else {
      return TagsRegistry()
    }

    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      return try JSONDecoder().decode(TagsRegistry.self, from: data)
    } catch {
      print("[UserConfig] Failed to load tags registry from \(path): \(error)")
      return TagsRegistry()
    }
  }

  func saveTagsRegistry(_ registry: TagsRegistry) {
    do {
      try fileManager.createDirectory(atPath: Defaults[.configDir], withIntermediateDirectories: true)
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
      let data = try encoder.encode(registry)
      try data.write(to: URL(fileURLWithPath: tagsRegistryPath()))
    } catch {
      print("[UserConfig] Failed to save tags registry: \(error)")
    }
  }

  func tagDisplayName(for tagId: String, registry: TagsRegistry? = nil) -> String {
    let loadedRegistry = registry ?? loadTagsRegistry()
    if let tag = loadedRegistry.tags.first(where: { $0.id == tagId }),
      !tag.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return tag.name
    }

    return tagId
      .replacingOccurrences(of: "-", with: " ")
      .replacingOccurrences(of: "_", with: " ")
      .split(separator: " ")
      .map { word in
        word.prefix(1).uppercased() + String(word.dropFirst())
      }
      .joined(separator: " ")
  }

  func assignedTagIds(for bundleId: String, normalMode: Bool, registry: TagsRegistry? = nil) -> [String] {
    let loadedRegistry = registry ?? loadTagsRegistry()
    let rawTagIds = normalMode
      ? loadedRegistry.assignments.normalApp[bundleId] ?? []
      : loadedRegistry.assignments.app[bundleId] ?? []

    var seen = Set<String>()
    return rawTagIds.compactMap { tagId in
      let trimmed = tagId.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, !seen.contains(trimmed) else {
        return nil
      }
      seen.insert(trimmed)
      return trimmed
    }
  }

  func tagConfigPath(for tagId: String, normalMode: Bool) -> String {
    let fileName = "\(normalMode ? normalTagConfigPrefix : tagConfigPrefix)\(tagId).json"
    return (Defaults[.configDir] as NSString).appendingPathComponent(fileName)
  }

  func generateTagId(for name: String, registry: TagsRegistry? = nil) -> String {
    let loadedRegistry = registry ?? loadTagsRegistry()
    let base =
      name
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
      .replacingOccurrences(of: #"[^a-z0-9]+"#, with: "-", options: .regularExpression)
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    let slug = base.isEmpty ? "tag" : base
    let existing = Set(loadedRegistry.tags.map(\.id))
    guard existing.contains(slug) else { return slug }

    var suffix = 2
    while true {
      let candidate = "\(slug)-\(suffix)"
      if !existing.contains(candidate) {
        return candidate
      }
      suffix += 1
    }
  }

  @discardableResult
  func ensureTagConfigFile(tagId: String, normalMode: Bool) -> String? {
    let path = tagConfigPath(for: tagId, normalMode: normalMode)
    guard !fileManager.fileExists(atPath: path) else { return path }

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
      let data = try encoder.encode(Group(actions: []))
      try data.write(to: URL(fileURLWithPath: path))
      return path
    } catch {
      print("[UserConfig] Failed to create tag config at \(path): \(error)")
      return nil
    }
  }

  @discardableResult
  func createTag(name: String, createRegularConfig: Bool = true) -> TagDefinition? {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else {
      alertHandler.showAlert(style: .warning, message: "Tag name cannot be empty.")
      return nil
    }

    var registry = loadTagsRegistry()
    let now = Date().timeIntervalSince1970 * 1000
    let tag = TagDefinition(
      id: generateTagId(for: trimmedName, registry: registry),
      name: trimmedName,
      createdAt: now,
      lastModified: now
    )
    registry.tags.append(tag)
    saveTagsRegistry(registry)
    if createRegularConfig {
      _ = ensureTagConfigFile(tagId: tag.id, normalMode: false)
    }
    reloadConfig()
    return tag
  }

  @discardableResult
  func renameTag(id tagId: String, name: String) -> TagDefinition? {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else {
      alertHandler.showAlert(style: .warning, message: "Tag name cannot be empty.")
      return nil
    }

    var registry = loadTagsRegistry()
    guard let index = registry.tags.firstIndex(where: { $0.id == tagId }) else {
      alertHandler.showAlert(style: .warning, message: "Tag '\(tagId)' does not exist.")
      return nil
    }

    registry.tags[index].name = trimmedName
    registry.tags[index].lastModified = Date().timeIntervalSince1970 * 1000
    let tag = registry.tags[index]
    saveTagsRegistry(registry)
    reloadConfig()
    return tag
  }

  func tagReferences(for tagId: String, registry: TagsRegistry? = nil) -> [TagReference] {
    let loadedRegistry = registry ?? loadTagsRegistry()
    var references: [TagReference] = []
    for (bundleId, tagIds) in loadedRegistry.assignments.app {
      for (index, assignedTagId) in tagIds.enumerated() where assignedTagId == tagId {
        references.append(
          TagReference(bundleId: bundleId, index: index, normalMode: false, scope: "app", tagId: tagId)
        )
      }
    }
    for (bundleId, tagIds) in loadedRegistry.assignments.normalApp {
      for (index, assignedTagId) in tagIds.enumerated() where assignedTagId == tagId {
        references.append(
          TagReference(bundleId: bundleId, index: index, normalMode: true, scope: "normalApp", tagId: tagId)
        )
      }
    }
    return references.sorted {
      $0.scope == $1.scope ? $0.bundleId < $1.bundleId : $0.scope < $1.scope
    }
  }

  @discardableResult
  func updateTagAssignments(bundleId: String, normalMode: Bool, tagIds: [String]) -> TagsRegistry {
    let normalizedBundleId = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedBundleId.isEmpty else { return loadTagsRegistry() }

    var registry = loadTagsRegistry()
    let knownIds = Set(registry.tags.map(\.id))
    var seen = Set<String>()
    let normalizedTagIds = tagIds.compactMap { rawTagId -> String? in
      let tagId = rawTagId.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !tagId.isEmpty, knownIds.contains(tagId), !seen.contains(tagId) else { return nil }
      seen.insert(tagId)
      return tagId
    }

    if normalMode {
      if normalizedTagIds.isEmpty {
        registry.assignments.normalApp.removeValue(forKey: normalizedBundleId)
      } else {
        registry.assignments.normalApp[normalizedBundleId] = normalizedTagIds
      }
    } else {
      if normalizedTagIds.isEmpty {
        registry.assignments.app.removeValue(forKey: normalizedBundleId)
      } else {
        registry.assignments.app[normalizedBundleId] = normalizedTagIds
      }
    }

    saveTagsRegistry(registry)
    appConfigs.removeValue(forKey: normalMode ? "normal.\(normalizedBundleId)" : normalizedBundleId)
    reloadConfig()
    return registry
  }

  @discardableResult
  func moveAssignedTag(bundleId: String, normalMode: Bool, tagId: String, direction: Int) -> TagsRegistry {
    let current = assignedTagIds(for: bundleId, normalMode: normalMode)
    guard let index = current.firstIndex(of: tagId) else { return loadTagsRegistry() }
    let nextIndex = index + direction
    guard nextIndex >= 0 && nextIndex < current.count else { return loadTagsRegistry() }

    var next = current
    next.swapAt(index, nextIndex)
    return updateTagAssignments(bundleId: bundleId, normalMode: normalMode, tagIds: next)
  }

  @discardableResult
  func deleteTag(id tagId: String, removeAssignments: Bool = false) -> Bool {
    var registry = loadTagsRegistry()
    guard registry.tags.contains(where: { $0.id == tagId }) else {
      alertHandler.showAlert(style: .warning, message: "Tag '\(tagId)' does not exist.")
      return false
    }

    let references = tagReferences(for: tagId, registry: registry)
    if !references.isEmpty && !removeAssignments {
      alertHandler.showAlert(
        style: .warning,
        message: "Tag '\(tagId)' is assigned to \(references.count) configuration\(references.count == 1 ? "" : "s"). Remove assignments before deleting it."
      )
      return false
    }

    registry.tags.removeAll { $0.id == tagId }
    for (bundleId, tagIds) in registry.assignments.app {
      let next = tagIds.filter { $0 != tagId }
      registry.assignments.app[bundleId] = next.isEmpty ? nil : next
    }
    for (bundleId, tagIds) in registry.assignments.normalApp {
      let next = tagIds.filter { $0 != tagId }
      registry.assignments.normalApp[bundleId] = next.isEmpty ? nil : next
    }
    saveTagsRegistry(registry)

    for normalMode in [false, true] {
      let path = tagConfigPath(for: tagId, normalMode: normalMode)
      if fileManager.fileExists(atPath: path) {
        try? fileManager.removeItem(atPath: path)
      }
      deleteMetadata(for: path)
    }
    reloadConfig()
    return true
  }

  func tagShadowWarnings(for bundleId: String, normalMode: Bool) -> [TagShadowWarning] {
    struct SourceItem {
      let displayName: String
      let kind: String
      let path: [String]
    }

    func appendItems(from group: Group, sourceName: String, prefix: [String], into output: inout [SourceItem]) {
      for item in group.actions {
        guard let key = item.item.key, !key.isEmpty else { continue }
        let path = prefix + [key]
        switch item {
        case .action:
          output.append(SourceItem(displayName: sourceName, kind: "action", path: path))
        case .group(let group):
          output.append(SourceItem(displayName: sourceName, kind: "group", path: path))
          appendItems(from: group, sourceName: sourceName, prefix: path, into: &output)
        case .layer(let layer):
          output.append(SourceItem(displayName: sourceName, kind: "layer", path: path))
          let layerGroup = Group(actions: layer.actions)
          appendItems(from: layerGroup, sourceName: sourceName, prefix: path, into: &output)
        }
      }
    }

    var sources: [(group: Group, name: String)] = []
    let localPrefix = normalMode ? normalAppConfigPrefix : appConfigPrefix
    let localPath = (Defaults[.configDir] as NSString).appendingPathComponent("\(localPrefix)\(bundleId).json")
    if fileManager.fileExists(atPath: localPath),
      let localGroup = decodeConfig(from: localPath, suppressAlerts: true, isDefaultConfig: false)
    {
      sources.append((localGroup, normalMode ? "Normal: \(bundleId)" : "App: \(bundleId)"))
    }

    let registry = loadTagsRegistry()
    for tagId in assignedTagIds(for: bundleId, normalMode: normalMode, registry: registry) {
      let path = tagConfigPath(for: tagId, normalMode: normalMode)
      if let tagGroup = decodeConfig(from: path, suppressAlerts: true, isDefaultConfig: false) {
        let prefix = normalMode ? normalTagConfigDisplayPrefix : tagConfigDisplayPrefix
        sources.append((tagGroup, "\(prefix)\(tagDisplayName(for: tagId, registry: registry))"))
      }
    }

    let fallbackPath = (Defaults[.configDir] as NSString).appendingPathComponent(
      normalMode ? normalFallbackConfigFileName : defaultAppConfigFileName)
    if fileManager.fileExists(atPath: fallbackPath),
      let fallback = decodeConfig(from: fallbackPath, suppressAlerts: true, isDefaultConfig: false)
    {
      sources.append((fallback, normalMode ? normalFallbackConfigDisplayName : defaultAppConfigDisplayName))
    }

    var items: [SourceItem] = []
    for source in sources {
      appendItems(from: source.group, sourceName: source.name, prefix: [], into: &items)
    }

    var winnersByPath: [String: SourceItem] = [:]
    var warnings: [TagShadowWarning] = []
    for item in items {
      let key = item.path.joined(separator: " -> ")
      if let winner = winnersByPath[key] {
        if winner.kind == item.kind && (winner.kind == "group" || winner.kind == "layer") {
          continue
        }
        let id = "\(winner.displayName)|\(item.displayName)|\(key)"
        if !warnings.contains(where: { $0.id == id }) {
          warnings.append(
            TagShadowWarning(
              id: id,
              message: "\(winner.displayName) overrides \(item.displayName) at \(key)."
            )
          )
        }
      } else {
        winnersByPath[key] = item
      }
    }
    return warnings
  }
}
