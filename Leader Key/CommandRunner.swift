import Cocoa
import Defaults

class CommandRunner {
  static func run(_ command: String) {
    let task = Process()
    let pipe = Pipe()
    let errorPipe = Pipe()

    task.standardOutput = pipe
    task.standardError = errorPipe
    
    // Get shell preference and RC file loading preference
    let shellPreference = Defaults[.commandShellPreference]
    let loadRCFiles = Defaults[.loadShellRCFiles]
    
    var shellPath = shellPreference.path
    
    // Validate custom shell path if using custom shell
    if shellPreference == .custom {
      let customPath = Defaults[.customShellPath]
      if !customPath.isEmpty && ShellPreference.isValidShellPath(customPath) {
        shellPath = customPath
      } else {
        // Fall back to system shell and notify user
        shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
        
        if !customPath.isEmpty {
          // Only show alert if user has entered a path (not empty)
          DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Invalid Custom Shell"
            alert.informativeText = "The custom shell path '\(customPath)' is invalid or not executable. Falling back to system shell."
            alert.runModal()
          }
        }
      }
    }
    
    task.launchPath = shellPath
    
    // Use login shell (-l) to load RC files if enabled
    // This ensures aliases and environment variables from .zshrc/.bashrc are available
    if loadRCFiles {
      task.arguments = ["-l", "-c", command]
    } else {
      task.arguments = ["-c", command]
    }

    do {
      try task.run()
      task.waitUntilExit()

      if task.terminationStatus != 0 {
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(data: errorData, encoding: .utf8) ?? ""
        let output = String(data: outputData, encoding: .utf8) ?? ""

        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Command failed with exit code \(task.terminationStatus)"
        alert.informativeText = [error, output].joined(separator: "\n").trimmingCharacters(
          in: .whitespacesAndNewlines)
        alert.runModal()
      }
    } catch {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Failed to run command"
      alert.informativeText = error.localizedDescription
      alert.runModal()
    }
  }
}
