import Defaults
import Foundation

struct GokuCompilerResult {
  let success: Bool
  let message: String
}

final class GokuCompilerService {
  static let shared = GokuCompilerService()

  private init() {}

  func validateGokuBinary() -> GokuCompilerResult {
    let resolved = resolvedGokuBinaryPath()
    if resolved != "goku" {
      if isExecutable(path: resolved) {
        return GokuCompilerResult(success: true, message: "goku is available at \(resolved)")
      }
      return GokuCompilerResult(success: false, message: "goku not executable at \(resolved)")
    }

    let process = Process()
    process.launchPath = "/usr/bin/which"
    process.arguments = ["goku"]

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return GokuCompilerResult(success: false, message: "goku not found: \(error)")
    }

    guard process.terminationStatus == 0 else {
      let errorOutput = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
      return GokuCompilerResult(success: false, message: "goku not found: \(errorOutput)")
    }

    let path = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? "goku"
    return GokuCompilerResult(success: true, message: "goku is available at \(path)")
  }

  func compileAndApply(configPath: String) -> GokuCompilerResult {
    let resolved = resolvedGokuBinaryPath()
    let process = Process()
    process.launchPath = resolved
    process.arguments = ["-c", configPath]

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

  private func resolvedGokuBinaryPath() -> String {
    let configured = Defaults[.gokuBinaryPath].trimmingCharacters(in: .whitespacesAndNewlines)
    return configured.isEmpty ? "goku" : configured
  }

  private func isExecutable(path: String) -> Bool {
    let fm = FileManager.default
    var isDir: ObjCBool = false
    return fm.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue && fm.isExecutableFile(atPath: path)
  }
}
