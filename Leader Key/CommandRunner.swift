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
    
    // Get all shell preferences
    let shellPreference = Defaults[.commandShellPreference]
    let loadRCFiles = Defaults[.loadShellRCFiles]
    let useInteractive = Defaults[.useInteractiveShell]
    let customArgs = Defaults[.customShellArguments]
    let workingDirectory = Defaults[.commandWorkingDirectory]
    let customEnvVars = Defaults[.commandEnvironmentVariables]
    let timeout = Defaults[.commandTimeoutSeconds]
    let outputMode = Defaults[.commandOutputMode]
    
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
    
    // Set working directory
    task.currentDirectoryPath = workingDirectory.path
    
    // Set environment variables
    var environment = ProcessInfo.processInfo.environment
    for (key, value) in customEnvVars {
      environment[key] = value
    }
    task.environment = environment
    
    // Build shell arguments
    var arguments: [String] = []
    
    // Add login shell flag if needed
    if loadRCFiles {
      arguments.append("-l")
    }
    
    // Add interactive flag if needed
    if useInteractive {
      arguments.append("-i")
    }
    
    // Add custom arguments if provided
    if !customArgs.isEmpty {
      let customArgArray = customArgs.split(separator: " ").map(String.init)
      arguments.append(contentsOf: customArgArray)
    }
    
    // Build the final command with hooks if enabled
    let finalCommand: String
    if Defaults[.enableCommandHooks] {
      let preHook = Defaults[.preCommandHook].trimmingCharacters(in: .whitespacesAndNewlines)
      let postHook = Defaults[.postCommandHook].trimmingCharacters(in: .whitespacesAndNewlines)
      
      var commandParts: [String] = []
      
      // Add pre-command hook
      if !preHook.isEmpty {
        // Replace $COMMAND placeholder with the actual command
        let processedPreHook = preHook.replacingOccurrences(of: "$COMMAND", with: command)
        commandParts.append(processedPreHook)
      }
      
      // Add main command
      commandParts.append(command)
      
      // Add post-command hook
      if !postHook.isEmpty {
        // Replace $COMMAND placeholder with the actual command
        let processedPostHook = postHook.replacingOccurrences(of: "$COMMAND", with: command)
        commandParts.append(processedPostHook)
      }
      
      // Join commands with && to ensure proper sequencing
      finalCommand = commandParts.joined(separator: " && ")
    } else {
      finalCommand = command
    }
    
    // Add the command
    arguments.append("-c")
    arguments.append(finalCommand)
    
    task.arguments = arguments
    
    // Set up timeout if configured
    var timeoutTimer: DispatchWorkItem?
    if timeout > 0 {
      timeoutTimer = DispatchWorkItem {
        if task.isRunning {
          task.terminate()
          print("[CommandRunner] Command timed out after \(timeout) seconds")
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout), execute: timeoutTimer!)
    }

    // Track start time for history
    let startTime = Date()
    
    do {
      try task.run()
      task.waitUntilExit()
      
      // Cancel timeout if it was set
      timeoutTimer?.cancel()
      
      // Calculate duration
      let duration = Date().timeIntervalSince(startTime)

      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
      let error = String(data: errorData, encoding: .utf8) ?? ""
      let output = String(data: outputData, encoding: .utf8) ?? ""
      
      // Add to command history (only on final attempt or success)
      if task.terminationStatus == 0 || !shouldRetry(exitCode: task.terminationStatus, error: error, attempt: attempt) {
        CommandHistory.shared.addEntry(
          command: command,
          exitCode: task.terminationStatus,
          output: output,
          error: error,
          duration: duration,
          workingDirectory: task.currentDirectoryPath,
          shell: shellPath
        )
      }
      
      if task.terminationStatus != 0 {
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
          handleCommandOutput(
            command: command,
            exitCode: task.terminationStatus,
            error: error,
            output: output,
            attempt: attempt,
            outputMode: outputMode,
            isError: true
          )
        }
      } else {
        // Command succeeded - handle output based on mode
        handleCommandOutput(
          command: command,
          exitCode: 0,
          error: error,
          output: output,
          attempt: attempt,
          outputMode: outputMode,
          isError: false
        )
      }
    } catch {
      // Cancel timeout if it was set
      timeoutTimer?.cancel()
      
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
  
  /// Handle command output based on configured output mode
  private static func handleCommandOutput(
    command: String,
    exitCode: Int32,
    error: String,
    output: String,
    attempt: Int,
    outputMode: CommandOutputMode,
    isError: Bool
  ) {
    let combinedOutput = [output, error].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch outputMode {
    case .silent:
      // Do nothing - silent mode
      if isError {
        // Still show errors even in silent mode
        showCommandError(command: command, exitCode: exitCode, error: error, output: output, attempt: attempt)
      }
      
    case .notification:
      DispatchQueue.main.async {
        let notification = NSUserNotification()
        notification.title = isError ? "Command Failed" : "Command Completed"
        notification.informativeText = combinedOutput.isEmpty ? "Command executed successfully" : String(combinedOutput.prefix(200))
        notification.soundName = isError ? NSUserNotificationDefaultSoundName : nil
        NSUserNotificationCenter.default.deliver(notification)
      }
      
    case .clipboard:
      if !combinedOutput.isEmpty {
        DispatchQueue.main.async {
          let pasteboard = NSPasteboard.general
          pasteboard.clearContents()
          pasteboard.setString(combinedOutput, forType: .string)
          
          // Show notification that output was copied
          let notification = NSUserNotification()
          notification.title = "Output Copied"
          notification.informativeText = "Command output has been copied to clipboard"
          NSUserNotificationCenter.default.deliver(notification)
        }
      }
      
    case .log:
      let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
      print("[CommandRunner] [\(timestamp)] Command: \(command)")
      print("[CommandRunner] Exit Code: \(exitCode)")
      if !combinedOutput.isEmpty {
        print("[CommandRunner] Output: \(combinedOutput)")
      }
      
    case .window:
      DispatchQueue.main.async {
        showOutputWindow(
          command: command,
          exitCode: exitCode,
          output: combinedOutput,
          isError: isError
        )
      }
    }
  }
  
  /// Show output in a window
  private static func showOutputWindow(command: String, exitCode: Int32, output: String, isError: Bool) {
    let alert = NSAlert()
    alert.alertStyle = isError ? .warning : .informational
    alert.messageText = isError ? "Command Failed (Exit: \(exitCode))" : "Command Output"
    
    // Create scrollable text view for output
    let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = true
    scrollView.autohidesScrollers = false
    scrollView.borderType = .bezelBorder
    
    let textView = NSTextView(frame: scrollView.bounds)
    textView.isEditable = false
    textView.isSelectable = true
    textView.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    textView.string = "Command: \(command)\n\n\(output.isEmpty ? "(No output)" : output)"
    textView.autoresizingMask = [.width, .height]
    
    scrollView.documentView = textView
    alert.accessoryView = scrollView
    
    alert.addButton(withTitle: "OK")
    if !output.isEmpty {
      alert.addButton(withTitle: "Copy Output")
    }
    
    let response = alert.runModal()
    if response == .alertSecondButtonReturn {
      // Copy output button was clicked
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(output, forType: .string)
    }
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
