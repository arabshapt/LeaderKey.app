import Cocoa
import Defaults
import Foundation

class CommandRunner {
  private static let maxRetries = 3
  private static let retryDelay = 0.5 // seconds
  static func run(_ command: String) {
    runWithRetry(command, attempt: 1)
  }
  
  private static func runWithRetry(_ command: String, attempt: Int) {
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
        
        // Check if we should retry
        if shouldRetry(exitCode: task.terminationStatus, error: error, attempt: attempt) {
          print("[CommandRunner] Command failed with exit code \(task.terminationStatus), retrying (attempt \(attempt + 1)/\(maxRetries))")
          
          // Retry with exponential backoff
          let delay = retryDelay * pow(2.0, Double(attempt - 1))
          DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            runWithRetry(command, attempt: attempt + 1)
          }
        } else {
          // Max retries reached or non-retryable error
          showCommandError(
            command: command,
            exitCode: task.terminationStatus,
            error: error,
            output: output,
            attempt: attempt
          )
        }
      }
    } catch {
      // Process launch error - check if we should retry
      if isTransientError(error) && attempt < maxRetries {
        print("[CommandRunner] Failed to launch command, retrying (attempt \(attempt + 1)/\(maxRetries)): \(error)")
        
        let delay = retryDelay * pow(2.0, Double(attempt - 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          runWithRetry(command, attempt: attempt + 1)
        }
      } else {
        // Show error after max retries
        showLaunchError(command: command, error: error, attempt: attempt)
      }
    }
  }
  
  /// Determine if command should be retried based on exit code and error
  private static func shouldRetry(exitCode: Int32, error: String, attempt: Int) -> Bool {
    guard attempt < maxRetries else { return false }
    
    // Common retryable exit codes
    let retryableExitCodes: Set<Int32> = [
      126,  // Command found but not executable (might be temporary permission issue)
      127,  // Command not found (might be PATH issue that resolves)
      130,  // Script terminated by Ctrl+C (might be accidental)
      255   // Exit status out of range (often indicates abnormal termination)
    ]
    
    if retryableExitCodes.contains(exitCode) {
      return true
    }
    
    // Check error message for retryable patterns
    let retryablePatterns = [
      "resource temporarily unavailable",
      "device not configured",
      "broken pipe",
      "connection reset",
      "timeout"
    ]
    
    let lowerError = error.lowercased()
    return retryablePatterns.contains { lowerError.contains($0) }
  }
  
  /// Check if error is transient and should be retried
  private static func isTransientError(_ error: Error) -> Bool {
    let nsError = error as NSError
    
    // POSIX errors that are often transient
    if nsError.domain == NSPOSIXErrorDomain {
      switch nsError.code {
      case Int(EAGAIN), Int(EINTR), Int(EBUSY):
        return true
      default:
        break
      }
    }
    
    // Check error message
    let errorMessage = error.localizedDescription.lowercased()
    return errorMessage.contains("temporarily") || errorMessage.contains("busy")
  }
  
  /// Show command execution error with details
  private static func showCommandError(
    command: String,
    exitCode: Int32,
    error: String,
    output: String,
    attempt: Int
  ) {
    var message = "Command failed with exit code \(exitCode)"
    
    if attempt > 1 {
      message += " after \(attempt) attempts"
    }
    
    message += "\n\nCommand: \(command.prefix(100))..."
    
    let details = [error, output].joined(separator: "\n").trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    
    if !details.isEmpty {
      message += "\n\nDetails: \(details.prefix(500))"
    }
    
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Command Execution Failed"
      alert.informativeText = message
      alert.runModal()
    }
  }
  
  /// Show process launch error
  private static func showLaunchError(command: String, error: Error, attempt: Int) {
    var message = "Failed to run command"
    
    if attempt > 1 {
      message += " after \(attempt) attempts"
    }
    
    message += "\n\nCommand: \(command.prefix(100))..."
    message += "\n\nError: \(error.localizedDescription)"
    
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Command Launch Failed"
      alert.informativeText = message
      alert.runModal()
    }
  }
}
