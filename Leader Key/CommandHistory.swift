import Foundation
import Defaults

/// Stores history of executed commands for debugging and replay
class CommandHistory {
  static let shared = CommandHistory()
  
  private var history: [CommandHistoryEntry] = []
  private let maxHistorySize = 50
  private let queue = DispatchQueue(label: "com.leaderkey.commandhistory")
  
  private init() {
    loadHistory()
  }
  
  /// Add a command to history
  func addEntry(
    command: String,
    exitCode: Int32,
    output: String,
    error: String,
    duration: TimeInterval,
    workingDirectory: String,
    shell: String
  ) {
    let entry = CommandHistoryEntry(
      id: UUID().uuidString,
      command: command,
      timestamp: Date(),
      exitCode: exitCode,
      output: output,
      error: error,
      duration: duration,
      workingDirectory: workingDirectory,
      shell: shell
    )
    
    queue.async { [weak self] in
      guard let self = self else { return }
      self.history.append(entry)
      
      // Limit history size
      if self.history.count > self.maxHistorySize {
        self.history.removeFirst(self.history.count - self.maxHistorySize)
      }
      
      self.saveHistory()
    }
  }
  
  /// Get all history entries
  func getHistory() -> [CommandHistoryEntry] {
    return queue.sync { history }
  }
  
  /// Clear all history
  func clearHistory() {
    queue.async { [weak self] in
      self?.history.removeAll()
      self?.saveHistory()
    }
  }
  
  /// Get a specific entry by ID
  func getEntry(id: String) -> CommandHistoryEntry? {
    return queue.sync {
      history.first { $0.id == id }
    }
  }
  
  /// Save history to disk
  private func saveHistory() {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    do {
      let data = try encoder.encode(history)
      let url = historyFileURL()
      try data.write(to: url)
    } catch {
      print("[CommandHistory] Failed to save history: \(error)")
    }
  }
  
  /// Load history from disk
  private func loadHistory() {
    let url = historyFileURL()
    
    guard FileManager.default.fileExists(atPath: url.path) else {
      return
    }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      history = try decoder.decode([CommandHistoryEntry].self, from: data)
      
      // Limit to max size
      if history.count > maxHistorySize {
        history = Array(history.suffix(maxHistorySize))
      }
    } catch {
      print("[CommandHistory] Failed to load history: \(error)")
    }
  }
  
  /// Get history file URL
  private func historyFileURL() -> URL {
    let configDir = URL(fileURLWithPath: Defaults[.configDir])
    return configDir.appendingPathComponent("command_history.json")
  }
  
  /// Export history as text
  func exportAsText() -> String {
    let entries = getHistory()
    var text = "Command History Export\n"
    text += "Generated: \(Date())\n"
    text += "Total Commands: \(entries.count)\n"
    text += String(repeating: "=", count: 50) + "\n\n"
    
    for entry in entries {
      text += "Command: \(entry.command)\n"
      text += "Timestamp: \(entry.timestamp)\n"
      text += "Exit Code: \(entry.exitCode)\n"
      text += "Duration: \(String(format: "%.2f", entry.duration))s\n"
      text += "Working Dir: \(entry.workingDirectory)\n"
      text += "Shell: \(entry.shell)\n"
      
      if !entry.output.isEmpty {
        text += "Output:\n\(entry.output)\n"
      }
      
      if !entry.error.isEmpty {
        text += "Error:\n\(entry.error)\n"
      }
      
      text += String(repeating: "-", count: 50) + "\n\n"
    }
    
    return text
  }
}

/// Represents a single command in history
struct CommandHistoryEntry: Codable, Identifiable {
  let id: String
  let command: String
  let timestamp: Date
  let exitCode: Int32
  let output: String
  let error: String
  let duration: TimeInterval
  let workingDirectory: String
  let shell: String
  
  var isSuccess: Bool {
    return exitCode == 0
  }
  
  var formattedTimestamp: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter.string(from: timestamp)
  }
  
  var formattedDuration: String {
    return String(format: "%.2fs", duration)
  }
  
  var truncatedCommand: String {
    if command.count > 100 {
      return String(command.prefix(97)) + "..."
    }
    return command
  }
}