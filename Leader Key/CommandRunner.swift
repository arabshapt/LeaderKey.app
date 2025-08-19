import Cocoa
import Defaults
import Foundation

class CommandRunner {
  static func run(_ command: String) {
    DispatchQueue.global(qos: .userInitiated).async {
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
      var timeoutWorkItem: DispatchWorkItem?
      if timeout > 0 {
        timeoutWorkItem = DispatchWorkItem {
          if task.isRunning {
            task.terminate()
            print("[CommandRunner] Command timed out after \(timeout) seconds")
          }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(timeout), execute: timeoutWorkItem!)
      }

      let startTime = Date()

      task.terminationHandler = { task in
          timeoutWorkItem?.cancel()
          
          let duration = Date().timeIntervalSince(startTime)
          let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
          let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
          let error = String(data: errorData, encoding: .utf8) ?? ""
          let output = String(data: outputData, encoding: .utf8) ?? ""

          CommandHistory.shared.addEntry(
            command: command,
            exitCode: task.terminationStatus,
            output: output,
            error: error,
            duration: duration,
            workingDirectory: task.currentDirectoryPath,
            shell: shellPath
          )

          if task.terminationStatus != 0 {
            handleCommandOutput(
              command: command,
              exitCode: task.terminationStatus,
              error: error,
              output: output,
              outputMode: outputMode,
              isError: true
            )
          } else {
            handleCommandOutput(
              command: command,
              exitCode: 0,
              error: error,
              output: output,
              outputMode: outputMode,
              isError: false
            )
          }
      }
      
      do {
        try task.run()
      } catch {
        timeoutWorkItem?.cancel()
        showLaunchError(command: command, error: error)
      }
    }
  }

  /// Handle command output based on configured output mode
  private static func handleCommandOutput(
    command: String,
    exitCode: Int32,
    error: String,
    output: String,
    outputMode: CommandOutputMode,
    isError: Bool
  ) {
    let combinedOutput = [output, error].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch outputMode {
    case .silent:
      if isError {
        showCommandError(command: command, exitCode: exitCode, error: error, output: output)
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
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.alertStyle = isError ? .warning : .informational
        alert.messageText = isError ? "Command Failed (Exit: \(exitCode))" : "Command Output"

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
          let pasteboard = NSPasteboard.general
          pasteboard.clearContents()
          pasteboard.setString(output, forType: .string)
        }
    }
  }
  
  /// Show command execution error with details
  private static func showCommandError(
    command: String,
    exitCode: Int32,
    error: String,
    output: String
  ) {
    var message = "Command failed with exit code \(exitCode)"
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
  private static func showLaunchError(command: String, error: Error) {
    var message = "Failed to run command"
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
