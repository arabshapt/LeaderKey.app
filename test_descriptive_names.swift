#!/usr/bin/env swift

// Test descriptive name handling (like "question" instead of "?")

func parseCompactShortcutToKarabiner(_ shortcut: String) -> String? {
    guard !shortcut.isEmpty else { return nil }
    
    var modifierLetters = ""
    var remainingString = shortcut
    
    // Parse modifier characters: C=Cmd, S=Shift, O=Option, T=Control, F=Function
    while !remainingString.isEmpty {
        let firstChar = remainingString.first!
        var consumedModifier = false
        
        switch firstChar {
        case "C":  // Command
            modifierLetters += "C"
            consumedModifier = true
        case "S":  // Shift
            modifierLetters += "S"
            consumedModifier = true
        case "O":  // Option/Alt
            modifierLetters += "O"
            consumedModifier = true
        case "T":  // Control
            modifierLetters += "T"
            consumedModifier = true
        case "F":  // Function
            modifierLetters += "F"
            consumedModifier = true
        default:
            break
        }
        
        if consumedModifier {
            remainingString.removeFirst()
        } else {
            break
        }
    }
    
    // The rest is the key name
    var keyName = remainingString
    guard !keyName.isEmpty else { return nil }
    
    // Map descriptive names back to their special characters
    let descriptiveNameMap: [String: String] = [
        "question": "?",
        "exclamation": "!",
        "at": "@",
        "hash": "#",
        "dollar": "$",
        "percent": "%",
        "caret": "^",
        "ampersand": "&",
        "asterisk": "*",
        "parenleft": "(",
        "parenright": ")",
        "underscore": "_",
        "plus": "+",
        "braceleft": "{",
        "braceright": "}",
        "quote": "\"",
        "tilde": "~",
        "pipe": "|",
        "colon": ":",
        "less": "<",
        "greater": ">",
    ]
    
    // Check if the key name is a descriptive name that needs conversion
    if let specialChar = descriptiveNameMap[keyName.lowercased()] {
        keyName = specialChar
    }
    
    // Special characters that require Shift modifier
    let shiftedKeyMap: [String: String] = [
        "!": "1",
        "@": "2",
        "#": "3",
        "$": "4",
        "%": "5",
        "^": "6",
        "&": "7",
        "*": "8",
        "(": "9",
        ")": "0",
        "_": "hyphen",
        "+": "equal_sign",
        "{": "open_bracket",
        "}": "close_bracket",
        "\"": "quote",
        "~": "grave_accent_and_tilde",
        "|": "backslash",
        "?": "slash",
        ":": "semicolon",
        "<": "comma",
        ">": "period",
    ]
    
    // Check if it's a shifted special character
    if let shiftedKey = shiftedKeyMap[keyName] {
        // Add Shift modifier if not already present
        if !modifierLetters.contains("S") {
            modifierLetters += "S"
        }
        keyName = shiftedKey
    }
    
    // Map special keys to Karabiner notation
    let keyMap: [String: String] = [
        "space": "spacebar",
        "return": "return_or_enter",
        "enter": "return_or_enter",
        "tab": "tab",
        "delete": "delete_or_backspace",
        "backspace": "delete_or_backspace",
        "escape": "escape",
        "esc": "escape",
        "up": "up_arrow",
        "down": "down_arrow",
        "left": "left_arrow",
        "right": "right_arrow",
    ]
    
    // Get the mapped key or use the key lowercased
    let finalKey = keyMap[keyName.lowercased()] ?? keyName.lowercased()
    
    // Build the final format
    if !modifierLetters.isEmpty {
        return ":!\(modifierLetters)\(finalKey)"
    } else {
        return ":\(finalKey)"
    }
}

// Test cases - descriptive names that should be converted
let tests = [
    // Descriptive names that need conversion
    ("Cquestion", ":!CSslash"),        // Cmd+? (stored as "question")
    ("Oquestion", ":!OSslash"),        // Option+?
    ("question", ":!Sslash"),          // Just ? (needs Shift)
    
    ("Cexclamation", ":!CS1"),         // Cmd+!
    ("exclamation", ":!S1"),           // Just !
    
    ("Cat", ":!CS2"),                  // Cmd+@
    ("at", ":!S2"),                    // Just @
    
    ("Ccolon", ":!CSsemicolon"),       // Cmd+:
    ("colon", ":!Ssemicolon"),         // Just :
    
    ("Cpipe", ":!CSbackslash"),        // Cmd+|
    ("pipe", ":!Sbackslash"),          // Just |
    
    ("Cunderscore", ":!CShyphen"),     // Cmd+_
    ("underscore", ":!Shyphen"),       // Just _
    
    ("Cplus", ":!CSequal_sign"),       // Cmd++
    ("plus", ":!Sequal_sign"),         // Just +
    
    ("Cless", ":!CScomma"),            // Cmd+<
    ("less", ":!Scomma"),              // Just <
    
    ("Cgreater", ":!CSperiod"),        // Cmd+>
    ("greater", ":!Speriod"),          // Just >
    
    // Regular shortcuts should still work
    ("Ca", ":!Ca"),
    ("CSa", ":!CSa"),
    ("tab", ":tab"),
]

print("Testing descriptive name handling:")
print("-" * 50)

var passed = 0
var failed = 0

for (input, expected) in tests {
    let result = parseCompactShortcutToKarabiner(input) ?? "nil"
    let isCorrect = result == expected
    let symbol = isCorrect ? "✅" : "❌"
    
    print("\(symbol) \"\(input)\" -> \(result)")
    if !isCorrect {
        print("   Expected: \(expected)")
        failed += 1
    } else {
        passed += 1
    }
}

print("\nSummary: \(passed) passed, \(failed) failed")

// Extension for String multiplication
extension String {
    static func * (lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}