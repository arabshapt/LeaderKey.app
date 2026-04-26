import CryptoKit
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
  static let generatedModuleRelativePath = generatedDirectoryRelativePath + "/leaderkey-generated.json"
  static let legacyGeneratedModuleRelativePath = generatedDirectoryRelativePath + "/leaderkey-generated.ts"
  static let generatedBootstrapRelativePath = generatedDirectoryRelativePath + "/index.ts"
  static let migratedGokuProfileDirectoryRelativePath = "configs/arabshapt"
  static let migratedGokuComplexModificationsRelativePath =
    migratedGokuProfileDirectoryRelativePath + "/default-complex-modifications.json"
  static let migratedGokuProfileModuleRelativePath =
    migratedGokuProfileDirectoryRelativePath + "/default-profile.ts"
  static let migratedGokuMetadataRelativePath =
    migratedGokuProfileDirectoryRelativePath + "/migration-metadata.json"

  private init() {}

  func validateKarabinerTsRepo(repoPath: String? = nil) -> KarabinerTsExportResult {
    do {
      let resolved = try validatedRepoPath(repoPath)
      return KarabinerTsExportResult(success: true, message: "karabiner.ts workspace is available at \(resolved)")
    } catch {
      return KarabinerTsExportResult(success: false, message: error.localizedDescription)
    }
  }

  func migrateGokuProfileToKarabinerTs(
    repoPath: String? = nil,
    ednPath: String? = nil,
    profileName: String = "Default",
    gokuBinaryPath: String? = nil
  ) -> KarabinerTsExportResult {
    do {
      let resolvedRepoPath = try validatedRepoPath(repoPath)
      let resolvedEDNPath = (ednPath ?? (NSHomeDirectory() as NSString).appendingPathComponent(".config/karabiner.edn"))
        .trimmingCharacters(in: .whitespacesAndNewlines) as NSString
      let expandedEDNPath = resolvedEDNPath.expandingTildeInPath
      guard FileManager.default.fileExists(atPath: expandedEDNPath) else {
        throw Self.error("Goku EDN config does not exist: \(expandedEDNPath)", code: 20)
      }

      let configuredGokuBinary = gokuBinaryPath?.trimmingCharacters(in: .whitespacesAndNewlines)
      let gokuBinary = configuredGokuBinary?.isEmpty == false
        ? configuredGokuBinary!
        : GokuCompilerService.shared.binaryPathForExecution()
      let processOutput = try Self.runProcess(
        launchPath: "/usr/bin/env",
        arguments: [gokuBinary, "--dry-run"],
        environment: gokuEnvironment(ednPath: expandedEDNPath),
        workingDirectory: resolvedRepoPath
      )

      let migration = try Self.migratedGokuProfile(from: processOutput.stdout)
      try writeMigratedGokuProfile(
        migration,
        repoPath: resolvedRepoPath,
        profileName: profileName,
        ednPath: expandedEDNPath,
        gokuDiagnostics: processOutput.stderrText,
        gokuExitCode: processOutput.terminationStatus
      )

      return KarabinerTsExportResult(
        success: true,
        message:
          "Migrated \(migration.ruleCount) manual Goku rules to \(Self.migratedGokuComplexModificationsRelativePath) (removed \(migration.removedLegacyLeaderKeyRules) legacy Leader Key rules)"
      )
    } catch {
      return KarabinerTsExportResult(
        success: false,
        message: "Failed to migrate Goku profile to karabiner.ts: \(error.localizedDescription)"
      )
    }
  }

  func compileAndApply(
    managedRules: [[String: Any]],
    repoModuleData: Data,
    repoPath: String? = nil,
    karabinerJsonPath: String? = nil
  ) -> KarabinerTsExportResult {
    do {
      let resolvedRepoPath = try validatedRepoPath(repoPath)
      try writeManagedRepoFiles(repoPath: resolvedRepoPath, repoModuleData: repoModuleData)
      try applyManagedRules(managedRules, karabinerPath: karabinerJsonPath)
      return KarabinerTsExportResult(
        success: true,
        message:
          "Updated \(Self.generatedModuleRelativePath) and applied \(managedRules.count) LeaderKey rules via karabiner.ts")
    } catch {
      return KarabinerTsExportResult(success: false, message: "Failed to export/apply karabiner.ts config: \(error.localizedDescription)")
    }
  }

  /// Write repo files only (Phase 1 of split export). Writes raw JSON module data.
  func writeRepoFiles(repoModuleData: Data, repoPath: String? = nil) throws {
    let resolvedRepoPath = try validatedRepoPath(repoPath)
    try writeManagedRepoFiles(repoPath: resolvedRepoPath, repoModuleData: repoModuleData)
  }

  /// Apply managed rules to karabiner.json (Phase 2 of split export).
  func applyRules(_ managedRules: [[String: Any]], karabinerJsonPath: String? = nil) throws {
    try applyManagedRules(managedRules, karabinerPath: karabinerJsonPath)
  }

  static func stableManagedRulesData(_ managedRules: [[String: Any]]) throws -> Data {
    try JSONSerialization.data(withJSONObject: managedRules, options: [.sortedKeys])
  }

  private struct MigratedGokuProfile {
    let complexModifications: [String: Any]
    let compactJSONData: Data
    let sha256: String
    let sourceRuleCount: Int
    let ruleCount: Int
    let removedLegacyLeaderKeyRules: Int
    let removedLegacyLeaderKeyManipulators: Int
  }

  private struct ProcessOutput {
    let terminationStatus: Int32
    let stdout: Data
    let stderr: Data

    var stderrText: String {
      String(data: stderr, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var diagnostics: String {
      let stdoutText = String(data: stdout, encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      let parts = [
        stdoutText.isEmpty ? nil : "stdout=\(stdoutText)",
        stderrText.isEmpty ? nil : "stderr=\(stderrText)",
      ].compactMap { $0 }
      return parts.isEmpty ? "no output" : parts.joined(separator: "; ")
    }
  }

  private func writeManagedRepoFiles(repoPath: String, repoModuleData: Data) throws {
    let managedDirectory = (repoPath as NSString).appendingPathComponent(Self.generatedDirectoryRelativePath)
    try FileManager.default.createDirectory(atPath: managedDirectory, withIntermediateDirectories: true)

    let generatedModulePath = (repoPath as NSString).appendingPathComponent(Self.generatedModuleRelativePath)
    if try Self.writeFileIfChanged(repoModuleData, to: generatedModulePath) {
      debugLog("[Benchmark] karabiner.ts.writeRepoFiles skipped unchanged generated module")
    }

    let legacyModulePath = (repoPath as NSString).appendingPathComponent(Self.legacyGeneratedModuleRelativePath)
    let legacyModuleData = Data(Self.legacyCompatibilityModuleSource().utf8)
    if try Self.writeFileIfChanged(legacyModuleData, to: legacyModulePath) {
      debugLog("[Benchmark] karabiner.ts.writeRepoFiles skipped unchanged compatibility module")
    }

    let bootstrapPath = (repoPath as NSString).appendingPathComponent(Self.generatedBootstrapRelativePath)
    if !FileManager.default.fileExists(atPath: bootstrapPath) {
      try Self.bootstrapModuleSource().write(toFile: bootstrapPath, atomically: true, encoding: .utf8)
    }
  }

  private func gokuEnvironment(ednPath: String) -> [String: String] {
    var environment = GokuCompilerService.shared.environmentForExecution()
    environment["GOKU_EDN_CONFIG_FILE"] = ednPath
    return environment
  }

  private func writeMigratedGokuProfile(
    _ migration: MigratedGokuProfile,
    repoPath: String,
    profileName: String,
    ednPath: String,
    gokuDiagnostics: String,
    gokuExitCode: Int32
  ) throws {
    let outputDirectory = (repoPath as NSString).appendingPathComponent(Self.migratedGokuProfileDirectoryRelativePath)
    try FileManager.default.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true)

    let jsonPath = (repoPath as NSString).appendingPathComponent(Self.migratedGokuComplexModificationsRelativePath)
    try migration.compactJSONData.write(to: URL(fileURLWithPath: jsonPath), options: .atomic)

    let modulePath = (repoPath as NSString).appendingPathComponent(Self.migratedGokuProfileModuleRelativePath)
    let moduleData = Data(Self.migratedGokuProfileModuleSource(profileName: profileName, sha256: migration.sha256).utf8)
    try moduleData.write(to: URL(fileURLWithPath: modulePath), options: .atomic)

    let metadataPath = (repoPath as NSString).appendingPathComponent(Self.migratedGokuMetadataRelativePath)
    let metadata: [String: Any] = [
      "profile": profileName,
      "edn": ednPath,
      "generated_at": ISO8601DateFormatter().string(from: Date()),
      "sha256": migration.sha256,
      "bytes": migration.compactJSONData.count,
      "source_rules": migration.sourceRuleCount,
      "rules": migration.ruleCount,
      "removed_legacy_leaderkey_rules": migration.removedLegacyLeaderKeyRules,
      "removed_legacy_leaderkey_manipulators": migration.removedLegacyLeaderKeyManipulators,
      "goku_exit_code": gokuExitCode,
      "goku_stderr": gokuDiagnostics,
    ]
    let metadataData = try JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted, .sortedKeys])
    try metadataData.write(to: URL(fileURLWithPath: metadataPath), options: .atomic)
  }

  /// Writes the file only when content changed. Returns true when the write was skipped.
  @discardableResult
  private static func writeFileIfChanged(_ data: Data, to path: String) throws -> Bool {
    let url = URL(fileURLWithPath: path)
    if let existingData = try? Data(contentsOf: url),
       existingData == data
    {
      return true
    }

    try data.write(to: url, options: .atomic)
    return false
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

  private struct AppliedManagedRulesFingerprint {
    let path: String
    let fileMtime: Date
    let fileSize: UInt64
    let managedRulesData: Data
  }

  private var templateCache: KarabinerTemplateCache?
  private var lastAppliedManagedRulesFingerprint: AppliedManagedRulesFingerprint?

  private func applyManagedRules(_ managedRules: [[String: Any]], karabinerPath: String? = nil) throws {
    try autoreleasepool {
      let resolvedKarabinerPath = karabinerPath ?? (NSHomeDirectory() + "/.config/karabiner/karabiner.json")
      let url = URL(fileURLWithPath: resolvedKarabinerPath)
      let managedRulesData = try Self.stableManagedRulesData(managedRules)

      // Check if we can reuse the cached template.
      let fm = FileManager.default
      let fileAttrs = try fm.attributesOfItem(atPath: resolvedKarabinerPath)
      let fileMtime = fileAttrs[.modificationDate] as? Date ?? Date.distantPast
      let fileSize = Self.fileSize(from: fileAttrs)

      if let lastAppliedManagedRulesFingerprint,
         lastAppliedManagedRulesFingerprint.path == resolvedKarabinerPath,
         lastAppliedManagedRulesFingerprint.fileMtime == fileMtime,
         lastAppliedManagedRulesFingerprint.fileSize == fileSize,
         lastAppliedManagedRulesFingerprint.managedRulesData == managedRulesData
      {
        debugLog("[Benchmark] karabiner.ts.apply skipped unchanged managed rules")
        return
      }

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

        // Build cache from the parsed root for next time.
        templateCache = try Self.buildTemplateCache(
          from: parsed, path: resolvedKarabinerPath, mtime: fileMtime)

        let selectedLeaderKeyRules = try Self.selectedLeaderKeyRules(in: parsed)
        if !selectedLeaderKeyRules.containsLegacyManagedRules,
           try Self.stableManagedRulesData(selectedLeaderKeyRules.managedRules) == managedRulesData
        {
          lastAppliedManagedRulesFingerprint = AppliedManagedRulesFingerprint(
            path: resolvedKarabinerPath,
            fileMtime: fileMtime,
            fileSize: fileSize,
            managedRulesData: managedRulesData
          )
          debugLog("[Benchmark] karabiner.ts.apply skipped unchanged on-disk managed rules")
          return
        }

        root = try Self.patchedKarabinerRoot(parsed, compiledRules: managedRules)
        debugLog("[Benchmark] karabiner.ts.apply cache MISS — built new template cache")
      }

      let backupPath = resolvedKarabinerPath + ".leaderkey.backup.\(Int(Date().timeIntervalSince1970))"
      _ = try? fm.copyItem(atPath: resolvedKarabinerPath, toPath: backupPath)

      let output = try JSONSerialization.data(withJSONObject: root)
      try output.write(to: url, options: .atomic)

      // Update cache mtime to match what we just wrote so next call hits the cache.
      let newAttrs = try fm.attributesOfItem(atPath: resolvedKarabinerPath)
      let newMtime = newAttrs[.modificationDate] as? Date ?? Date.distantPast
      let newSize = Self.fileSize(from: newAttrs)
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
      lastAppliedManagedRulesFingerprint = AppliedManagedRulesFingerprint(
        path: resolvedKarabinerPath,
        fileMtime: newMtime,
        fileSize: newSize,
        managedRulesData: managedRulesData
      )

      // Rotate backups: keep only the 2 most recent
      Self.rotateBackups(inDirectory: (resolvedKarabinerPath as NSString).deletingLastPathComponent)
    }
  }

  private static func fileSize(from attributes: [FileAttributeKey: Any]) -> UInt64 {
    if let size = attributes[.size] as? UInt64 {
      return size
    }
    return (attributes[.size] as? NSNumber)?.uint64Value ?? 0
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

  private static func selectedLeaderKeyRules(
    in root: [String: Any]
  ) throws -> (managedRules: [[String: Any]], containsLegacyManagedRules: Bool) {
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
    var managedRules: [[String: Any]] = []
    var containsLegacyManagedRules = false

    for rule in existingRules {
      let description = rule["description"] as? String ?? ""
      if description.hasPrefix(managedRuleDescriptionPrefix) {
        managedRules.append(rule)
      } else if description.hasPrefix(legacyManagedRuleDescriptionPrefix) {
        containsLegacyManagedRules = true
      }
    }

    return (managedRules, containsLegacyManagedRules)
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

  private static func migratedGokuProfile(from stdoutData: Data) throws -> MigratedGokuProfile {
    guard !stdoutData.isEmpty else {
      throw error("goku --dry-run produced no JSON output", code: 22)
    }

    guard let parsed = try JSONSerialization.jsonObject(with: stdoutData) as? [String: Any] else {
      throw error("goku --dry-run output was not a JSON object", code: 23)
    }

    var complexModifications = (parsed["complex_modifications"] as? [String: Any]) ?? parsed

    guard let sourceRules = complexModifications["rules"] as? [[String: Any]] else {
      throw error("goku --dry-run output did not include complex_modifications.rules", code: 25)
    }

    var filteredRules: [[String: Any]] = []
    var removedLegacyLeaderKeyRules = 0
    var removedLegacyLeaderKeyManipulators = 0

    for rule in sourceRules {
      if isLegacyLeaderKeyRule(rule) {
        removedLegacyLeaderKeyRules += 1
        removedLegacyLeaderKeyManipulators += (rule["manipulators"] as? [Any])?.count ?? 0
        continue
      }
      filteredRules.append(rule)
    }

    complexModifications["rules"] = filteredRules
    let compactJSONData = try JSONSerialization.data(withJSONObject: complexModifications, options: [.sortedKeys])
    let digest = SHA256.hash(data: compactJSONData)
    let hash = digest.map { String(format: "%02x", $0) }.joined()

    return MigratedGokuProfile(
      complexModifications: complexModifications,
      compactJSONData: compactJSONData,
      sha256: hash,
      sourceRuleCount: sourceRules.count,
      ruleCount: filteredRules.count,
      removedLegacyLeaderKeyRules: removedLegacyLeaderKeyRules,
      removedLegacyLeaderKeyManipulators: removedLegacyLeaderKeyManipulators
    )
  }

  private static func isLegacyLeaderKeyRule(_ rule: [String: Any]) -> Bool {
    let description = rule["description"] as? String ?? ""
    return description.hasPrefix(managedRuleDescriptionPrefix)
      || description.hasPrefix(legacyManagedRuleDescriptionPrefix)
  }

  private static func runProcess(
    launchPath: String,
    arguments: [String],
    environment: [String: String],
    workingDirectory: String
  ) throws -> ProcessOutput {
    let process = Process()
    process.launchPath = launchPath
    process.arguments = arguments
    process.environment = environment
    process.currentDirectoryPath = workingDirectory

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe

    final class Capture {
      var data = Data()
    }

    let stdoutCapture = Capture()
    let stderrCapture = Capture()
    let readGroup = DispatchGroup()

    readGroup.enter()
    DispatchQueue.global(qos: .utility).async {
      stdoutCapture.data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
      readGroup.leave()
    }

    readGroup.enter()
    DispatchQueue.global(qos: .utility).async {
      stderrCapture.data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
      readGroup.leave()
    }

    do {
      try process.run()
      process.waitUntilExit()
      readGroup.wait()
    } catch {
      try? stdoutPipe.fileHandleForReading.close()
      try? stderrPipe.fileHandleForReading.close()
      readGroup.wait()
      throw error
    }

    return ProcessOutput(
      terminationStatus: process.terminationStatus,
      stdout: stdoutCapture.data,
      stderr: stderrCapture.data
    )
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
    import type { Rule } from '../../src/karabiner/karabiner-config.ts'
    import leaderKeyRules from './leaderkey-generated.json'

    export const leaderKeyDefaultProfileName = "Default"
    export const leaderKeyManagedRules = leaderKeyRules as Rule[]
    export default leaderKeyManagedRules
    """
  }

  private static func legacyCompatibilityModuleSource() -> String {
    """
    // Generated by Leader Key. Do not edit this file directly.
    // Compatibility wrapper for existing imports of ./leaderkey-generated.
    import type { Rule } from '../../src/karabiner/karabiner-config.ts'
    import leaderKeyRules from './leaderkey-generated.json'

    export const leaderKeyDefaultProfileName = "Default"
    export const leaderKeyManagedRules = leaderKeyRules as Rule[]
    export default leaderKeyManagedRules
    """
  }

  private static func migratedGokuProfileModuleSource(profileName: String, sha256: String) -> String {
    let profileLiteral = jsonStringLiteral(profileName)
    let hashLiteral = jsonStringLiteral(sha256)
    return """
      // Generated by Leader Key. Do not edit this file directly.
      import type { ComplexModifications } from '../../src/karabiner/karabiner-config.ts'
      import rawDefaultComplexModifications from './default-complex-modifications.json'

      export const defaultProfileName = \(profileLiteral)
      export const defaultComplexModificationsSha256 = \(hashLiteral)

      export type KarabinerConfigLike = {
        profiles: Array<{
          name: string
          [key: string]: unknown
        }>
        [key: string]: unknown
      }

      export const defaultComplexModifications = rawDefaultComplexModifications as ComplexModifications

      export function replaceProfileComplexModifications<T extends KarabinerConfigLike>(
        config: T,
        profileName = defaultProfileName,
      ): T {
        let found = false

        const profiles = config.profiles.map((profile) => {
          if (profile.name !== profileName) {
            return profile
          }

          found = true
          return {
            ...profile,
            complex_modifications: defaultComplexModifications,
          }
        })

        if (!found) {
          throw new Error(`Profile ${profileName} not found`)
        }

        return {
          ...config,
          profiles,
        } as T
      }
      """
  }

  private static func jsonStringLiteral(_ value: String) -> String {
    guard let data = try? JSONEncoder().encode(value),
          let literal = String(data: data, encoding: .utf8)
    else {
      return "\"\""
    }
    return literal
  }

  private static func error(_ message: String, code: Int) -> NSError {
    NSError(
      domain: "KarabinerTsExportService",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }
}

typealias KarCompilerService = KarabinerTsExportService
