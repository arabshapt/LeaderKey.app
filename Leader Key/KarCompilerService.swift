import Defaults
import Foundation

struct KarCompilerResult {
  let success: Bool
  let message: String
}

final class KarCompilerService {
  static let shared = KarCompilerService()

  static let managedRuleDescriptionPrefix = "LeaderKeyManaged/"
  static var generatedConfigPath: String {
    (Defaults[.configDir] as NSString).appendingPathComponent("export/leaderkey-generated.config.ts")
  }

  private init() {}

  /// Build an environment dictionary with an enriched PATH so that
  /// child processes (kar) can find TypeScript runtimes (deno, bun)
  /// even when the app is launched from Finder/Launchd.
  private func enrichedEnvironment() -> [String: String] {
    var env = ProcessInfo.processInfo.environment
    let home = NSHomeDirectory()
    let extraPaths = [
      "/opt/homebrew/bin",
      "/opt/homebrew/sbin",
      "/usr/local/bin",
      "\(home)/.bun/bin",
      "\(home)/.deno/bin",
      "\(home)/.cargo/bin",
      "\(home)/bin",
      "\(home)/.local/bin",
    ]
    let currentPath = env["PATH"] ?? "/usr/bin:/bin:/usr/sbin:/sbin"
    env["PATH"] = (extraPaths + [currentPath]).joined(separator: ":")
    return env
  }

  func validateKarBinary() -> KarCompilerResult {
    let karBinary = resolvedKarBinaryPath()
    let process = Process()
    process.launchPath = karBinary
    process.arguments = ["--help"]
    process.environment = enrichedEnvironment()

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return KarCompilerResult(success: false, message: "kar not found (\(karBinary)): \(error)")
    }

    guard process.terminationStatus == 0 else {
      let errorOutput = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
      return KarCompilerResult(success: false, message: "kar validation failed: \(errorOutput)")
    }

    return KarCompilerResult(success: true, message: "kar is available at \(karBinary)")
  }

  func compileAndApply(configTS: String) -> KarCompilerResult {
    do {
      let configPath = try writeGeneratedConfig(configTS)
      let compiledRules = try compileRules(configPath: configPath)
      try applyCompiledRules(compiledRules)
      return KarCompilerResult(success: true, message: "Applied \(compiledRules.count) LeaderKey rules via kar")
    } catch {
      return KarCompilerResult(success: false, message: "Failed to compile/apply kar config: \(error)")
    }
  }

  private func writeGeneratedConfig(_ configTS: String) throws -> String {
    let path = Self.generatedConfigPath
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
    try configTS.write(toFile: path, atomically: true, encoding: .utf8)
    return path
  }

  private func compileRules(configPath: String) throws -> [[String: Any]] {
    let karBinary = resolvedKarBinaryPath()
    let process = Process()
    process.launchPath = karBinary
    process.arguments = ["--dry-run", "--config", configPath]
    process.environment = enrichedEnvironment()

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    try process.run()
    process.waitUntilExit()

    let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
    let stderrString = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

    guard process.terminationStatus == 0 else {
      throw NSError(
        domain: "KarCompilerService",
        code: Int(process.terminationStatus),
        userInfo: [NSLocalizedDescriptionKey: "kar --dry-run failed: \(stderrString)"])
    }

    return try parseCompiledRules(stdoutData)
  }

  private func applyCompiledRules(_ compiledRules: [[String: Any]]) throws {
    let karabinerPath = NSHomeDirectory() + "/.config/karabiner/karabiner.json"
    let url = URL(fileURLWithPath: karabinerPath)
    let data = try Data(contentsOf: url)

    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw NSError(
        domain: "KarCompilerService",
        code: 3,
        userInfo: [NSLocalizedDescriptionKey: "Invalid karabiner.json structure"])
    }

    let patchedRoot = try Self.patchedKarabinerRoot(root, compiledRules: compiledRules)

    let backupPath = karabinerPath + ".leaderkey.backup.\(Int(Date().timeIntervalSince1970))"
    _ = try? FileManager.default.copyItem(atPath: karabinerPath, toPath: backupPath)

    let output = try JSONSerialization.data(withJSONObject: patchedRoot, options: [.prettyPrinted])
    try output.write(to: url, options: .atomic)
  }

  static func patchedKarabinerRoot(
    _ root: [String: Any],
    compiledRules: [[String: Any]]
  ) throws -> [String: Any] {
    guard var profiles = root["profiles"] as? [[String: Any]] else {
      throw NSError(
        domain: "KarCompilerService",
        code: 5,
        userInfo: [NSLocalizedDescriptionKey: "Invalid karabiner.json: missing profiles"])
    }

    let selectedIndex = profiles.firstIndex { ($0["selected"] as? Bool) == true } ?? 0
    guard profiles.indices.contains(selectedIndex) else {
      throw NSError(
        domain: "KarCompilerService",
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
      if description.hasPrefix(Self.managedRuleDescriptionPrefix) {
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

  private func parseCompiledRules(_ stdoutData: Data) throws -> [[String: Any]] {
    let parsed = try JSONSerialization.jsonObject(with: stdoutData)

    if let ruleArray = parsed as? [[String: Any]] {
      return ruleArray
    }

    if let object = parsed as? [String: Any], let rules = object["rules"] as? [[String: Any]] {
      return rules
    }

    throw NSError(
      domain: "KarCompilerService",
      code: 2,
      userInfo: [NSLocalizedDescriptionKey: "kar --dry-run did not return rules array JSON"])
  }

  private func resolvedKarBinaryPath() -> String {
    let configured = Defaults[.karBinaryPath].trimmingCharacters(in: .whitespacesAndNewlines)
    return configured.isEmpty ? "kar" : configured
  }
}
