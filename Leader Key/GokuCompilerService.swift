import Defaults
import Foundation

struct GokuCompilerResult {
  let success: Bool
  let message: String
}

final class GokuCompilerService {
  static let shared = GokuCompilerService()

  private init() {}

  /// Finder/Xcode launches often do not inherit the interactive shell PATH,
  /// so include common install locations when resolving/running goku.
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

  func validateGokuBinary() -> GokuCompilerResult {
    let configured = configuredGokuBinaryPath()
    if let configured {
      if isExecutable(path: configured) {
        return GokuCompilerResult(success: true, message: "goku is available at \(configured)")
      }
      return GokuCompilerResult(success: false, message: "goku not executable at \(configured)")
    }

    if let discovered = discoverGokuBinaryPath() {
      return GokuCompilerResult(success: true, message: "goku is available at \(discovered)")
    }

    return GokuCompilerResult(success: false, message: "goku not found on PATH")
  }

  func compileAndApply(configPath: String) -> GokuCompilerResult {
    let resolved = resolvedGokuBinaryPath()
    let process = Process()
    process.launchPath = resolved
    process.arguments = ["-c", configPath]
    process.environment = enrichedEnvironment()

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return GokuCompilerResult(success: false, message: "Failed to run goku: \(error)")
    }

    guard process.terminationStatus == 0 else {
      let errorOutput = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
      return GokuCompilerResult(success: false, message: "goku failed: \(errorOutput)")
    }

    let output = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
    let message = trimmed.isEmpty ? "goku compiled karabiner.edn" : trimmed
    return GokuCompilerResult(success: true, message: message)
  }

  private func configuredGokuBinaryPath() -> String? {
    let configured = Defaults[.gokuBinaryPath].trimmingCharacters(in: .whitespacesAndNewlines)
    return configured.isEmpty ? nil : configured
  }

  private func discoverGokuBinaryPath() -> String? {
    let process = Process()
    process.launchPath = "/usr/bin/which"
    process.arguments = ["goku"]
    process.environment = enrichedEnvironment()

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return nil
    }

    guard process.terminationStatus == 0 else {
      return nil
    }

    let path = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let path, !path.isEmpty else {
      return nil
    }

    return path
  }

  private func resolvedGokuBinaryPath() -> String {
    if let configured = configuredGokuBinaryPath() {
      if isExecutable(path: configured) {
        return configured
      }
    }

    return discoverGokuBinaryPath() ?? "goku"
  }

  private func isExecutable(path: String) -> Bool {
    let fm = FileManager.default
    var isDir: ObjCBool = false
    return fm.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue && fm.isExecutableFile(atPath: path)
  }
}
