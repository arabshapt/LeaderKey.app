#!/usr/bin/env swift

// Test script to verify the new modifier syntax

import Foundation

// Simple test strings to verify conversion
let testCases = [
    "x",       // Simple key -> :x
    "X",       // Uppercase -> {:key :x :modi :shift}
    "Sx",      // Shift+x -> {:key :x :modi :shift}
    "Cx",      // Cmd+x -> {:key :x :modi :command}
    "CSx",     // Cmd+Shift+x -> {:key :x :modi [:command :shift]}
    "COx",     // Cmd+Option+x -> {:key :x :modi [:command :option]}
    "CTx",     // Cmd+Ctrl+x -> {:key :x :modi [:command :control]}
    "CSOTx",   // All modifiers -> {:key :x :modi [:command :shift :option :control]}
]

// The convertToKarabinerKey function from Karabiner2Exporter.swift
func convertToKarabinerKey(_ key: String) -> String {
    // Handle empty key
    guard !key.isEmpty else { return key }
    
    // Parse modifier prefixes (C=cmd, S=shift, O=option, T=ctrl)
    var modifierList: [String] = []
    var baseKey = key
    
    // Check for modifier prefixes at the start of the key
    if key.count > 1 {
        let prefixes = key.prefix(while: { "CSOT".contains($0) })
        if !prefixes.isEmpty {
            // Build modifier list for expanded notation
            for char in prefixes {
                switch char {
                case "C": modifierList.append(":command")
                case "S": modifierList.append(":shift")
                case "O": modifierList.append(":option")
                case "T": modifierList.append(":control")
                default: break
                }
            }
            baseKey = String(key.dropFirst(prefixes.count))
        }
    }
    
    // Check if baseKey is a single uppercase letter (implies Shift modifier)
    if baseKey.count == 1, let char = baseKey.first, char.isUppercase {
        // Add Shift modifier if not already present
        if !modifierList.contains(":shift") {
            modifierList.append(":shift")
        }
        // Convert to lowercase
        baseKey = baseKey.lowercased()
    }
    
    // Map special keys to Karabiner notation
    let keyMap: [String: String] = [
        " ": "spacebar",
        "space": "spacebar",
        "spacebar": "spacebar",
        "return": "return_or_enter",
        "enter": "return_or_enter",
        "tab": "tab",
        "delete": "delete_or_backspace",
        "backspace": "delete_or_backspace",
        ".": "period",
        ",": "comma",
        ";": "semicolon",
        "/": "slash",
        "-": "hyphen",
        "=": "equal_sign",
        "[": "open_bracket",
        "]": "close_bracket",
        "'": "quote",
        "`": "grave_accent_and_tilde",
        "\\": "backslash",
        // Unicode arrow symbols
        "↑": "up_arrow",
        "↓": "down_arrow",
        "←": "left_arrow",
        "→": "right_arrow",
        // Text representations
        "up": "up_arrow",
        "down": "down_arrow",
        "left": "left_arrow",
        "right": "right_arrow",
        "escape": "escape",
        "esc": "escape",
    ]
    
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
    ]
    
    // Check if it's a shifted special character
    if let shiftedKey = shiftedKeyMap[baseKey] {
        // Add Shift modifier if not already present
        if !modifierList.contains(":shift") {
            modifierList.append(":shift")
        }
        baseKey = shiftedKey
    }
    
    // Get the mapped key or use the base key lowercased
    let mappedKey = keyMap[baseKey.lowercased()] ?? baseKey.lowercased()
    
    // Return in expanded format
    if modifierList.isEmpty {
        // No modifiers, just return the key with colon prefix
        return ":\(mappedKey)"
    } else if modifierList.count == 1 {
        // Single modifier
        return "{:key :\(mappedKey) :modi \(modifierList[0])}"
    } else {
        // Multiple modifiers - use array notation
        let modifiersStr = "[" + modifierList.joined(separator: " ") + "]"
        return "{:key :\(mappedKey) :modi \(modifiersStr)}"
    }
}

// Test the function
print("Testing modifier syntax conversion:\n")
for testCase in testCases {
    let result = convertToKarabinerKey(testCase)
    print("\(testCase.padding(toLength: 8, withPad: " ", startingAt: 0)) -> \(result)")
}