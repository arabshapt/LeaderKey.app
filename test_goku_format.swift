#!/usr/bin/env swift

// Test Goku format generation

// Parse a single compact shortcut like "CSa" to Karabiner format  
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
    let keyName = remainingString.lowercased()
    guard !keyName.isEmpty else { return nil }
    
    // Build the final format
    if !modifierLetters.isEmpty {
        // Format: :!CSa for Cmd+Shift+A (no brackets when used in action array)
        // The ! prefix indicates modifiers are present, followed by modifier letters
        return ":!\(modifierLetters)\(keyName)"
    } else {
        // No modifiers, just the key
        return ":\(keyName)"
    }
}

// Test cases
let tests = [
    ("a", ":a"),                   // Just 'a' key
    ("Ca", ":!Ca"),                // Cmd+A
    ("Sa", ":!Sa"),                // Shift+A (with implicit Cmd from !)
    ("CSa", ":!CSa"),              // Cmd+Shift+A
    ("Oa", ":!Oa"),                // Option+A
    ("COa", ":!COa"),              // Cmd+Option+A
    ("Ta", ":!Ta"),                // Control+A
    ("CTa", ":!CTa"),              // Cmd+Control+A
    ("COSTa", ":!COSTa"),          // Cmd+Option+Shift+Control+A (hyper-like)
    ("Fa", ":!Fa"),                // Function+A
    ("CFa", ":!CFa"),              // Cmd+Function+A
    ("tab", ":tab"),               // Tab key
    ("Ctab", ":!Ctab"),            // Cmd+Tab
    ("return", ":return"),         // Return key
]

print("Testing Goku format generation:")
print("-" * 50)

for (input, expected) in tests {
    let result = parseCompactShortcutToKarabiner(input) ?? "nil"
    let passed = result == expected
    let symbol = passed ? "✅" : "❌"
    
    print("\(symbol) \"\(input)\" -> \(result)")
    if !passed {
        print("   Expected: \(expected)")
    }
}

// Extension for String multiplication
extension String {
    static func * (lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}