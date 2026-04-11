import Defaults
import Foundation

struct KarabinerTsExportResult {
  let success: Bool
  let message: String
}

typealias KarCompilerResult = KarabinerTsExportResult

final class KarabinerTsExportService {
  static let shared = KarabinerTsExportService()

  static let managedRuleDescriptionPrefix = "LeaderKeyManaged/"
  static let legacyManagedRuleDescriptionPrefix = "Leader Key - "
  static let generatedDirectoryRelativePath = "configs/leaderkey"
  static let generatedModuleRelativePath = generatedDirectoryRelativePath + "/leaderkey-generated.ts"
  static let generatedBootstrapRelativePath = generatedDirectoryRelativePath + "/index.ts"

  private init() {}

  func validateKarabinerTsRepo(repoPath: String? = nil) -> KarabinerTsExportResult {
    do {
      let resolved = try validatedRepoPath(repoPath)
      return KarabinerTsExportResult(success: true, message: "karabiner.ts workspace is available at \(resolved)")
    } catch {
      return KarabinerTsExportResult(success: false, message: error.localizedDescription)
    }
  }

  func compileAndApply(
    managedRules: [[String: Any]],
    repoModuleSource: String,
    repoPath: String? = nil,
    karabinerJsonPath: String? = nil
  ) -> KarabinerTsExportResult {
    do {
      let resolvedRepoPath = try validatedRepoPath(repoPath)
      try writeManagedRepoFiles(repoPath: resolvedRepoPath, repoModuleSource: repoModuleSource)
      try applyManagedRules(managedRules, karabinerPath: karabinerJsonPath)
      return KarabinerTsExportResult(
        success: true,
        message:
          "Updated \(Self.generatedModuleRelativePath) and applied \(managedRules.count) LeaderKey rules via karabiner.ts")
    } catch {
      return KarabinerTsExportResult(success: false, message: "Failed to export/apply karabiner.ts config: \(error.localizedDescription)")
    }
  }

  /// Write repo files only (Phase 1 of split export). Allows caller to release
  /// repoModuleSource before the heavier JSON patching phase.
  func writeRepoFiles(repoModuleSource: String, repoPath: String? = nil) throws {
    let resolvedRepoPath = try validatedRepoPath(repoPath)
    try writeManagedRepoFiles(repoPath: resolvedRepoPath, repoModuleSource: repoModuleSource)
  }

  /// Apply managed rules to karabiner.json (Phase 2 of split export).
  func applyRules(_ managedRules: [[String: Any]], karabinerJsonPath: String? = nil) throws {
    try applyManagedRules(managedRules, karabinerPath: karabinerJsonPath)
  }

  private func writeManagedRepoFiles(repoPath: String, repoModuleSource: String) throws {
    let managedDirectory = (repoPath as NSString).appendingPathComponent(Self.generatedDirectoryRelativePath)
    try FileManager.default.createDirectory(atPath: managedDirectory, withIntermediateDirectories: true)

    let generatedModulePath = (repoPath as NSString).appendingPathComponent(Self.generatedModuleRelativePath)
    try repoModuleSource.write(toFile: generatedModulePath, atomically: true, encoding: .utf8)

    let bootstrapPath = (repoPath as NSString).appendingPathComponent(Self.generatedBootstrapRelativePath)
    if !FileManager.default.fileExists(atPath: bootstrapPath) {
      try Self.bootstrapModuleSource().write(toFile: bootstrapPath, atomically: true, encoding: .utf8)
    }
  }

  /// Cache for the non-managed portion of karabiner.json. Avoids re-reading and
  /// re-parsing the full 11MB file on every export when we just wrote it ourselves.
  private struct KarabinerTemplateCache {
    /// The full parsed root dict with managed rules stripped out.
    let templateRoot: [String: Any]
    /// Index of the selected profile in the profiles array.
    let selectedProfileIndex: Int
    /// Non-managed rules from the selected profile (everything except LeaderKey rules).
    let nonManagedRules: [[String: Any]]
    /// Parameters dict from complex_modifications.
    let parameters: [String: Any]?
    /// Modification date of karabiner.json when this cache was built.
    let fileMtime: Date
    /// Path this cache was built from.
    let path: String
  }

  private var templateCache: KarabinerTemplateCache?

  private func applyManagedRules(_ managedRules: [[String: Any]], karabinerPath: String? = nil) throws {
    try autoreleasepool {
      let resolvedKarabinerPath = karabinerPath ?? (NSHomeDirectory() + "/.config/karabiner/karabiner.json")
      let url = URL(fileURLWithPath: resolvedKarabinerPath)

      // Check if we can reuse the cached template.
      let fm = FileManager.default
      let fileAttrs = try fm.attributesOfItem(atPath: resolvedKarabinerPath)
      let fileMtime = fileAttrs[.modificationDate] as? Date ?? Date.distantPast

      let root: [String: Any]
      if let cache = templateCache,
         cache.path == resolvedKarabinerPath,
         cache.fileMtime == fileMtime
      {
        // Cache hit: rebuild the root from the cached template + new managed rules.
        root = try Self.rebuildFromCache(cache, compiledRules: managedRules)
        debugLog("[Benchmark] karabiner.ts.apply cache HIT — skipped 11MB read+parse")
      } else {
        // Cache miss: full read + parse.
        let data = try Data(contentsOf: url)
        guard let parsed = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
          throw NSError(
            domain: "KarabinerTsExportService",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "Invalid karabiner.json structure"])
        }
        root = try Self.patchedKarabinerRoot(parsed, compiledRules: managedRules)

        // Build cache from the parsed root for next time.
        templateCache = try Self.buildTemplateCache(
          from: parsed, path: resolvedKarabinerPath, mtime: fileMtime)
        debugLog("[Benchmark] karabiner.ts.apply cache MISS — built new template cache")
      }

      let backupPath = resolvedKarabinerPath + ".leaderkey.backup.\(Int(Date().timeIntervalSince1970))"
      _ = try? fm.copyItem(atPath: resolvedKarabinerPath, toPath: backupPath)

      let output = try JSONSerialization.data(withJSONObject: root)
      try output.write(to: url, options: .atomic)

      // Update cache mtime to match what we just wrote so next call hits the cache.
      let newAttrs = try fm.attributesOfItem(atPath: resolvedKarabinerPath)
      let newMtime = newAttrs[.modificationDate] as? Date ?? Date.distantPast
      if var cache = templateCache, cache.path == resolvedKarabinerPath {
        cache = KarabinerTemplateCache(
          templateRoot: cache.templateRoot,
          selectedProfileIndex: cache.selectedProfileIndex,
          nonManagedRules: cache.nonManagedRules,
          parameters: cache.parameters,
          fileMtime: newMtime,
          path: cache.path
        )
        templateCache = cache
      }

      // Rotate backups: keep only the 2 most recent
      Self.rotateBackups(inDirectory: (resolvedKarabinerPath as NSString).deletingLastPathComponent)
    }
  }

  /// Build a template cache from a fully parsed karabiner.json root.
  private static func buildTemplateCache(
    from root: [String: Any],
    path: String,
    mtime: Date
  ) throws -> KarabinerTemplateCache {
    guard let profiles = root["profiles"] as? [[String: Any]] else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 5,
        userInfo: [NSLocalizedDescriptionKey: "Invalid karabiner.json: missing profiles"])
    }

    let selectedIndex = profiles.firstIndex { ($0["selected"] as? Bool) == true } ?? 0
    guard profiles.indices.contains(selectedIndex) else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 6,
        userInfo: [NSLocalizedDescriptionKey: "No Karabiner profile found"])
    }

    let selectedProfile = profiles[selectedIndex]
    let complexModifications = selectedProfile["complex_modifications"] as? [String: Any] ?? [:]
    let existingRules = complexModifications["rules"] as? [[String: Any]] ?? []
    let parameters = complexModifications["parameters"] as? [String: Any]

    // Keep only non-managed rules.
    let nonManagedRules = existingRules.filter { rule in
      let description = rule["description"] as? String ?? ""
      return !description.hasPrefix(managedRuleDescriptionPrefix)
        && !description.hasPrefix(legacyManagedRuleDescriptionPrefix)
    }

    // Build a template root with managed rules stripped (empty rules array).
    var templateRoot = root
    var templateProfiles = profiles
    var templateProfile = selectedProfile
    var templateComplexMods = complexModifications
    templateComplexMods["rules"] = [] as [[String: Any]]
    templateProfile["complex_modifications"] = templateComplexMods
    templateProfiles[selectedIndex] = templateProfile
    templateRoot["profiles"] = templateProfiles

    return KarabinerTemplateCache(
      templateRoot: templateRoot,
      selectedProfileIndex: selectedIndex,
      nonManagedRules: nonManagedRules,
      parameters: parameters,
      fileMtime: mtime,
      path: path
    )
  }

  /// Rebuild a full karabiner.json root from a cached template + new managed rules.
  private static func rebuildFromCache(
    _ cache: KarabinerTemplateCache,
    compiledRules: [[String: Any]]
  ) throws -> [String: Any] {
    var root = cache.templateRoot
    guard var profiles = root["profiles"] as? [[String: Any]] else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 5,
        userInfo: [NSLocalizedDescriptionKey: "Invalid cached template"])
    }

    var selectedProfile = profiles[cache.selectedProfileIndex]
    var complexModifications = selectedProfile["complex_modifications"] as? [String: Any] ?? [:]

    // Reconstruct rules: non-managed first, then compiled managed rules.
    // (Matches the insertion point behavior of patchedKarabinerRoot.)
    var patchedRules: [[String: Any]] = []

    // The cache's nonManagedRules are in their original order.
    // If the original had managed rules at the end, we append to the end.
    // For simplicity (and consistency with patchedKarabinerRoot), just append.
    patchedRules.append(contentsOf: cache.nonManagedRules)
    patchedRules.append(contentsOf: compiledRules)

    complexModifications["rules"] = patchedRules
    if let parameters = cache.parameters {
      complexModifications["parameters"] = parameters
    }
    selectedProfile["complex_modifications"] = complexModifications
    profiles[cache.selectedProfileIndex] = selectedProfile
    root["profiles"] = profiles
    return root
  }

  private static func rotateBackups(inDirectory directory: String, keepCount: Int = 2) {
    let fm = FileManager.default
    guard let files = try? fm.contentsOfDirectory(atPath: directory) else { return }
    let backups = files.filter { $0.contains(".leaderkey.backup.") }.sorted().reversed()
    for (index, file) in backups.enumerated() {
      if index >= keepCount {
        try? fm.removeItem(atPath: (directory as NSString).appendingPathComponent(file))
      }
    }
  }

  static func patchedKarabinerRoot(
    _ root: [String: Any],
    compiledRules: [[String: Any]]
  ) throws -> [String: Any] {
    guard var profiles = root["profiles"] as? [[String: Any]] else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 5,
        userInfo: [NSLocalizedDescriptionKey: "Invalid karabiner.json: missing profiles"])
    }

    let selectedIndex = profiles.firstIndex { ($0["selected"] as? Bool) == true } ?? 0
    guard profiles.indices.contains(selectedIndex) else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 6,
        userInfo: [NSLocalizedDescriptionKey: "No Karabiner profile found"])
    }

    var selectedProfile = profiles[selectedIndex]
    var complexModifications = selectedProfile["complex_modifications"] as? [String: Any] ?? [:]
    let existingRules = complexModifications["rules"] as? [[String: Any]] ?? []
    var patchedRules: [[String: Any]] = []
    var insertedCompiledRules = false

    for rule in existingRules {
      let description = rule["description"] as? String ?? ""
      if description.hasPrefix(Self.managedRuleDescriptionPrefix)
        || description.hasPrefix(Self.legacyManagedRuleDescriptionPrefix)
      {
        if !insertedCompiledRules {
          patchedRules.append(contentsOf: compiledRules)
          insertedCompiledRules = true
        }
        continue
      }
      patchedRules.append(rule)
    }

    if !insertedCompiledRules {
      patchedRules.append(contentsOf: compiledRules)
    }

    complexModifications["rules"] = patchedRules
    selectedProfile["complex_modifications"] = complexModifications
    profiles[selectedIndex] = selectedProfile

    var patched = root
    patched["profiles"] = profiles
    return patched
  }

  private func validatedRepoPath(_ repoPath: String? = nil) throws -> String {
    let configuredPath = (repoPath ?? Defaults[.karabinerTsRepoPath]).trimmingCharacters(
      in: .whitespacesAndNewlines)
    guard !configuredPath.isEmpty else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 10,
        userInfo: [NSLocalizedDescriptionKey: "karabiner.ts repo path is not configured"])
    }

    let expandedPath = (configuredPath as NSString).expandingTildeInPath
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDirectory), isDirectory.boolValue else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 11,
        userInfo: [NSLocalizedDescriptionKey: "karabiner.ts repo path does not exist: \(expandedPath)"])
    }

    guard FileManager.default.isWritableFile(atPath: expandedPath) else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 12,
        userInfo: [NSLocalizedDescriptionKey: "karabiner.ts repo path is not writable: \(expandedPath)"])
    }

    let workspaceMarkers = ["package.json", "tsconfig.json", "deno.json", ".git"]
    let hasWorkspaceMarker = workspaceMarkers.contains {
      FileManager.default.fileExists(atPath: (expandedPath as NSString).appendingPathComponent($0))
    }
    guard hasWorkspaceMarker else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 13,
        userInfo: [
          NSLocalizedDescriptionKey:
            "karabiner.ts repo path must contain a workspace marker (package.json, tsconfig.json, deno.json, or .git)"
        ])
    }

    return expandedPath
  }

  private static func bootstrapModuleSource() -> String {
    """
    // Created once by Leader Key. You can import this path from your own karabiner.ts config.
    // This file is not overwritten after creation.

    export {
      default,
      leaderKeyDefaultProfileName,
      leaderKeyManagedRules,
    } from './leaderkey-generated'
    """
  }
}

typealias KarCompilerService = KarabinerTsExportService
