import AppKit
import Foundation

enum KarabinerCommandRouter {
  static func route(command: String, delegate: UnixSocketServerDelegate?) -> String {
    let trimmedCommand = command.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmedCommand.lowercased().hasPrefix("menu-items") {
      let payloadStart = trimmedCommand.index(trimmedCommand.startIndex, offsetBy: "menu-items".count)
      let payloadText = trimmedCommand[payloadStart...].trimmingCharacters(in: .whitespacesAndNewlines)
      guard let payloadData = payloadText.data(using: .utf8),
            let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
            let appName = (payload["app"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
            !appName.isEmpty else {
        return "ERROR: menu-items requires a JSON payload with an app name"
      }

      return KarabinerUserCommandReceiver.listMenuItemsJSON(app: appName)
    }

    let parts = trimmedCommand.split(separator: " ")

    guard !parts.isEmpty else {
      return "ERROR: Empty command"
    }

    let action = String(parts[0]).lowercased()

    switch action {
    case "activate":
      let bundleId = parts.count > 1 ? String(parts[1]) : nil
      delegate?.unixSocketServerDidReceiveActivation(bundleId: bundleId)
      return "OK"

    case "apply-config":
      delegate?.unixSocketServerDidReceiveApplyConfig()
      return "OK"

    case "key":
      guard parts.count > 1 else {
        return "ERROR: Key command requires keycode"
      }

      let keyString = String(parts[1])
      let keyCode: UInt16

      if let numericKeyCode = UInt16(keyString) {
        keyCode = numericKeyCode
      } else {
        guard let convertedKeyCode = characterToKeyCode(keyString) else {
          return "ERROR: Invalid key: \(keyString)"
        }
        keyCode = convertedKeyCode
      }

      let modifiers = parseModifiers(from: parts.dropFirst(2))
      delegate?.unixSocketServerDidReceiveKey(keyCode, modifiers: modifiers)
      return "OK"

    case "deactivate":
      delegate?.unixSocketServerDidReceiveDeactivation()
      return "OK"

    case "settings":
      delegate?.unixSocketServerDidReceiveSettings()
      return "OK"

    case "sequence":
      guard parts.count > 1 else {
        return "ERROR: Sequence command requires keys"
      }
      let sequence = parts.dropFirst().joined(separator: " ")
      delegate?.unixSocketServerDidReceiveSequence(sequence)
      return "OK"

    case "stateid":
      guard parts.count > 1 else {
        return "ERROR: stateid command requires a state ID"
      }
      guard let stateId = Int32(parts[1]) else {
        return "ERROR: Invalid state ID"
      }
      let sticky = parts.count > 2 && parts[2].lowercased() == "sticky"
      delegate?.unixSocketServerDidReceiveStateId(stateId, sticky: sticky)
      return "OK"

    case "state":
      if let state = delegate?.unixSocketServerRequestState() {
        return formatState(state)
      }
      return "{\"active\": false}"

    case "shake":
      delegate?.unixSocketServerDidReceiveShake()
      return "OK"

    default:
      return "ERROR: Unknown command: \(action)"
    }
  }

  static func normalizeSendUserCommandPayload(_ payload: Any) -> String? {
    if let stringPayload = payload as? String {
      let trimmed = stringPayload.trimmingCharacters(in: .whitespacesAndNewlines)
      return trimmed.isEmpty ? nil : trimmed
    }

    if let stringArrayPayload = payload as? [String] {
      let trimmed = stringArrayPayload.joined(separator: " ")
        .trimmingCharacters(in: .whitespacesAndNewlines)
      return trimmed.isEmpty ? nil : trimmed
    }

    if let anyArrayPayload = payload as? [Any] {
      let strings = anyArrayPayload.compactMap { $0 as? String }
      guard strings.count == anyArrayPayload.count else {
        return nil
      }
      let trimmed = strings.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
      return trimmed.isEmpty ? nil : trimmed
    }

    if let objectPayload = payload as? [String: Any] {
      if let commandLineArguments = objectPayload["command_line_arguments"] as? [String] {
        let trimmed = commandLineArguments.joined(separator: " ")
          .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
      }

      if let commandLineArguments = objectPayload["command_line_arguments"] as? [Any] {
        let strings = commandLineArguments.compactMap { $0 as? String }
        guard strings.count == commandLineArguments.count else {
          return nil
        }
        let trimmed = strings.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
      }

      if let command = objectPayload["command"] as? String {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
      }
    }

    return nil
  }

  private static func characterToKeyCode(_ character: String) -> UInt16? {
    switch character.lowercased() {
    case "spacebar", "space": return 49
    case "return", "return_or_enter", "enter": return 36
    case "tab": return 48
    case "delete", "delete_or_backspace", "backspace": return 51
    case "escape", "esc": return 53
    case "period", ".": return 47
    case "comma", ",": return 43
    case "semicolon", ";": return 41
    case "slash", "/": return 44
    case "backslash", "\\": return 42
    case "minus", "hyphen", "-": return 27
    case "equal", "equals", "=": return 24
    case "left_bracket", "open_bracket", "[": return 33
    case "right_bracket", "close_bracket", "]": return 30
    case "quote", "'", "\"": return 39
    case "grave", "backtick", "`": return 50
    default:
      break
    }

    guard character.count == 1 else { return nil }
    let char = character.lowercased().first!

    switch char {
    case "a": return 0
    case "b": return 11
    case "c": return 8
    case "d": return 2
    case "e": return 14
    case "f": return 3
    case "g": return 5
    case "h": return 4
    case "i": return 34
    case "j": return 38
    case "k": return 40
    case "l": return 37
    case "m": return 46
    case "n": return 45
    case "o": return 31
    case "p": return 35
    case "q": return 12
    case "r": return 15
    case "s": return 1
    case "t": return 17
    case "u": return 32
    case "v": return 9
    case "w": return 13
    case "x": return 7
    case "y": return 16
    case "z": return 6
    case "0": return 29
    case "1": return 18
    case "2": return 19
    case "3": return 20
    case "4": return 21
    case "5": return 23
    case "6": return 22
    case "7": return 26
    case "8": return 28
    case "9": return 25
    default:
      return nil
    }
  }

  private static func parseModifiers(from parts: ArraySlice<Substring>) -> NSEvent.ModifierFlags {
    var flags = NSEvent.ModifierFlags()
    for part in parts {
      switch part.lowercased() {
      case "cmd", "command":
        flags.insert(.command)
      case "shift":
        flags.insert(.shift)
      case "option", "alt":
        flags.insert(.option)
      case "control", "ctrl":
        flags.insert(.control)
      default:
        break
      }
    }
    return flags
  }

  private static func formatState(_ state: [String: Any]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: state, options: .prettyPrinted),
      let json = String(data: data, encoding: .utf8)
    else {
      return "{\"error\": \"Failed to serialize state\"}"
    }
    return json
  }
}
