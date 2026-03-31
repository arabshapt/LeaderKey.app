import Carbon.HIToolbox
import Foundation

struct KeystrokeActionValue: Equatable {
  static let focusMarker = "[focus]"

  var app: String?
  var spec: String
  var focusTargetApp: Bool

  init(app: String? = nil, spec: String, focusTargetApp: Bool = false) {
    let trimmedApp = app?.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedApp = trimmedApp?.isEmpty == false ? trimmedApp : nil

    self.app = normalizedApp
    self.spec = spec.trimmingCharacters(in: .whitespacesAndNewlines)
    self.focusTargetApp = normalizedApp != nil && focusTargetApp
  }

  static func parse(_ value: String) -> KeystrokeActionValue {
    let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
    let parts = trimmedValue.components(separatedBy: " > ").map {
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    if parts.count >= 3, parts[1] == focusMarker {
      return KeystrokeActionValue(
        app: parts[0],
        spec: parts.dropFirst(2).joined(separator: " > "),
        focusTargetApp: true
      )
    }

    if parts.count >= 2 {
      return KeystrokeActionValue(
        app: parts[0],
        spec: parts.dropFirst().joined(separator: " > ")
      )
    }

    return KeystrokeActionValue(spec: trimmedValue)
  }

  var serialized: String {
    guard let app else { return spec }
    if focusTargetApp {
      return "\(app) > \(Self.focusMarker) > \(spec)"
    }
    return "\(app) > \(spec)"
  }
}

enum CompactShortcut {
  static func keyCode(for keyName: String) -> CGKeyCode? {
    keyCodeMap[keyName.lowercased()]
  }

  static func parse(_ shortcut: String) -> (keyCode: CGKeyCode, flags: CGEventFlags)? {
    guard !shortcut.isEmpty else { return nil }

    var modifierFlags: CGEventFlags = []
    var remainingString = shortcut

    while let firstChar = remainingString.first,
          let modifierFlag = modifierFlag(for: firstChar) {
      modifierFlags.insert(modifierFlag)
      remainingString.removeFirst()
    }

    let keyName = remainingString.lowercased()
    guard !keyName.isEmpty, let keyCode = keyCode(for: keyName) else { return nil }

    return (keyCode: keyCode, flags: modifierFlags)
  }

  private static func modifierFlag(for character: Character) -> CGEventFlags? {
    switch character {
    case "C":
      .maskCommand
    case "T":
      .maskControl
    case "O":
      .maskAlternate
    case "S":
      .maskShift
    case "F":
      .maskSecondaryFn
    default:
      nil
    }
  }

  private static let keyCodeMap: [String: CGKeyCode] = [
    // Modifier keys
    "caps_lock": CGKeyCode(kVK_CapsLock),
    "left_control": CGKeyCode(kVK_Control),
    "left_shift": CGKeyCode(kVK_Shift),
    "left_option": CGKeyCode(kVK_Option),
    "left_command": CGKeyCode(kVK_Command),
    "right_control": CGKeyCode(kVK_RightControl),
    "right_shift": CGKeyCode(kVK_RightShift),
    "right_option": CGKeyCode(kVK_RightOption),
    "right_command": CGKeyCode(kVK_RightCommand),
    "fn": CGKeyCode(kVK_Function),

    // Letters
    "a": CGKeyCode(kVK_ANSI_A), "b": CGKeyCode(kVK_ANSI_B), "c": CGKeyCode(kVK_ANSI_C),
    "d": CGKeyCode(kVK_ANSI_D), "e": CGKeyCode(kVK_ANSI_E), "f": CGKeyCode(kVK_ANSI_F),
    "g": CGKeyCode(kVK_ANSI_G), "h": CGKeyCode(kVK_ANSI_H), "i": CGKeyCode(kVK_ANSI_I),
    "j": CGKeyCode(kVK_ANSI_J), "k": CGKeyCode(kVK_ANSI_K), "l": CGKeyCode(kVK_ANSI_L),
    "m": CGKeyCode(kVK_ANSI_M), "n": CGKeyCode(kVK_ANSI_N), "o": CGKeyCode(kVK_ANSI_O),
    "p": CGKeyCode(kVK_ANSI_P), "q": CGKeyCode(kVK_ANSI_Q), "r": CGKeyCode(kVK_ANSI_R),
    "s": CGKeyCode(kVK_ANSI_S), "t": CGKeyCode(kVK_ANSI_T), "u": CGKeyCode(kVK_ANSI_U),
    "v": CGKeyCode(kVK_ANSI_V), "w": CGKeyCode(kVK_ANSI_W), "x": CGKeyCode(kVK_ANSI_X),
    "y": CGKeyCode(kVK_ANSI_Y), "z": CGKeyCode(kVK_ANSI_Z),

    // Numbers
    "0": CGKeyCode(kVK_ANSI_0), "1": CGKeyCode(kVK_ANSI_1), "2": CGKeyCode(kVK_ANSI_2),
    "3": CGKeyCode(kVK_ANSI_3), "4": CGKeyCode(kVK_ANSI_4), "5": CGKeyCode(kVK_ANSI_5),
    "6": CGKeyCode(kVK_ANSI_6), "7": CGKeyCode(kVK_ANSI_7), "8": CGKeyCode(kVK_ANSI_8),
    "9": CGKeyCode(kVK_ANSI_9),

    // Common keys
    "return_or_enter": CGKeyCode(kVK_Return),
    "enter": CGKeyCode(kVK_Return),
    "tab": CGKeyCode(kVK_Tab),
    "spacebar": CGKeyCode(kVK_Space),
    "delete_or_backspace": CGKeyCode(kVK_Delete),
    "delete_forward": CGKeyCode(kVK_ForwardDelete),
    "escape": CGKeyCode(kVK_Escape),
    "home": CGKeyCode(kVK_Home),
    "end": CGKeyCode(kVK_End),
    "page_up": CGKeyCode(kVK_PageUp),
    "page_down": CGKeyCode(kVK_PageDown),
    "help": CGKeyCode(kVK_Help),
    "insert": CGKeyCode(kVK_Help),

    // Arrows
    "left_arrow": CGKeyCode(kVK_LeftArrow),
    "right_arrow": CGKeyCode(kVK_RightArrow),
    "down_arrow": CGKeyCode(kVK_DownArrow),
    "up_arrow": CGKeyCode(kVK_UpArrow),

    // Function keys
    "f1": CGKeyCode(kVK_F1), "f2": CGKeyCode(kVK_F2), "f3": CGKeyCode(kVK_F3),
    "f4": CGKeyCode(kVK_F4), "f5": CGKeyCode(kVK_F5), "f6": CGKeyCode(kVK_F6),
    "f7": CGKeyCode(kVK_F7), "f8": CGKeyCode(kVK_F8), "f9": CGKeyCode(kVK_F9),
    "f10": CGKeyCode(kVK_F10), "f11": CGKeyCode(kVK_F11), "f12": CGKeyCode(kVK_F12),
    "f13": CGKeyCode(kVK_F13), "f14": CGKeyCode(kVK_F14), "f15": CGKeyCode(kVK_F15),
    "f16": CGKeyCode(kVK_F16), "f17": CGKeyCode(kVK_F17), "f18": CGKeyCode(kVK_F18),
    "f19": CGKeyCode(kVK_F19), "f20": CGKeyCode(kVK_F20),

    // Keypad
    "keypad_0": CGKeyCode(kVK_ANSI_Keypad0), "keypad_1": CGKeyCode(kVK_ANSI_Keypad1),
    "keypad_2": CGKeyCode(kVK_ANSI_Keypad2), "keypad_3": CGKeyCode(kVK_ANSI_Keypad3),
    "keypad_4": CGKeyCode(kVK_ANSI_Keypad4), "keypad_5": CGKeyCode(kVK_ANSI_Keypad5),
    "keypad_6": CGKeyCode(kVK_ANSI_Keypad6), "keypad_7": CGKeyCode(kVK_ANSI_Keypad7),
    "keypad_8": CGKeyCode(kVK_ANSI_Keypad8), "keypad_9": CGKeyCode(kVK_ANSI_Keypad9),
    "keypad_period": CGKeyCode(kVK_ANSI_KeypadDecimal),
    "keypad_enter": CGKeyCode(kVK_ANSI_KeypadEnter),
    "keypad_plus": CGKeyCode(kVK_ANSI_KeypadPlus),
    "keypad_minus": CGKeyCode(kVK_ANSI_KeypadMinus),
    "keypad_multiply": CGKeyCode(kVK_ANSI_KeypadMultiply),
    "keypad_divide": CGKeyCode(kVK_ANSI_KeypadDivide),
    "keypad_equal_sign": CGKeyCode(kVK_ANSI_KeypadEquals),
    "keypad_clear": CGKeyCode(kVK_ANSI_KeypadClear),
    "keypad_num_lock": CGKeyCode(kVK_ANSI_KeypadClear),

    // Symbols
    "grave_accent_and_tilde": CGKeyCode(kVK_ANSI_Grave),
    "hyphen": CGKeyCode(kVK_ANSI_Minus),
    "equal_sign": CGKeyCode(kVK_ANSI_Equal),
    "open_bracket": CGKeyCode(kVK_ANSI_LeftBracket),
    "close_bracket": CGKeyCode(kVK_ANSI_RightBracket),
    "backslash": CGKeyCode(kVK_ANSI_Backslash),
    "semicolon": CGKeyCode(kVK_ANSI_Semicolon),
    "quote": CGKeyCode(kVK_ANSI_Quote),
    "comma": CGKeyCode(kVK_ANSI_Comma),
    "period": CGKeyCode(kVK_ANSI_Period),
    "slash": CGKeyCode(kVK_ANSI_Slash),

    // Media keys
    "volume_increment": CGKeyCode(kVK_VolumeUp),
    "volume_decrement": CGKeyCode(kVK_VolumeDown),
    "mute": CGKeyCode(kVK_Mute),

    // PC / miscellaneous keys
    "print_screen": CGKeyCode(kVK_F13),
    "scroll_lock": CGKeyCode(kVK_F14),
    "pause": CGKeyCode(kVK_F15),

    // International keys
    "lang1": CGKeyCode(kVK_JIS_Eisu),
    "lang2": CGKeyCode(kVK_JIS_Kana),
    "japanese_eisuu": CGKeyCode(kVK_JIS_Eisu),
    "japanese_kana": CGKeyCode(kVK_JIS_Kana),
  ]
}
