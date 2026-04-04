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

  private func applyManagedRules(_ managedRules: [[String: Any]], karabinerPath: String? = nil) throws {
    let resolvedKarabinerPath = karabinerPath ?? (NSHomeDirectory() + "/.config/karabiner/karabiner.json")
    let url = URL(fileURLWithPath: resolvedKarabinerPath)
    let data = try Data(contentsOf: url)

    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw NSError(
        domain: "KarabinerTsExportService",
        code: 3,
        userInfo: [NSLocalizedDescriptionKey: "Invalid karabiner.json structure"])
    }

    let patchedRoot = try Self.patchedKarabinerRoot(root, compiledRules: managedRules)

    let backupPath = resolvedKarabinerPath + ".leaderkey.backup.\(Int(Date().timeIntervalSince1970))"
    _ = try? FileManager.default.copyItem(atPath: resolvedKarabinerPath, toPath: backupPath)

    let output = try JSONSerialization.data(withJSONObject: patchedRoot)
    try output.write(to: url, options: .atomic)
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
