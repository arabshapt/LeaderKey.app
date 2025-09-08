#!/usr/bin/env swift

// Test script to verify shortcut export functionality

import Foundation

// Test cases for shortcut detection
let testCases: [(shortcut: String, canExport: Bool, expected: String?)] = [
    // Simple shortcuts that can be exported
    ("CSa", true, "[:!CSa]"),           // Cmd+Shift+A
    ("Oa", true, "[:!Oa]"),             // Option+A
    ("tab", true, "[:tab]"),           // Tab key alone
    ("Ctab", true, "[:!Ctab]"),         // Cmd+Tab
    ("return", true, "[:return_or_enter]"), // Return key
    
    // Sequences that can be exported
    ("Ctab Oa", true, "[:!Ctab] [:!Oa]"), // Cmd+Tab then Option+A
    ("CSb Oa return", true, "[:!CSb] [:!Oa] [:return_or_enter]"), // Multi-step
    ("tab vk_none", true, "[:tab] [:vk_none]"), // Tab then release modifiers
    ("Ctab release_modifiers", true, "[:!Ctab] [:vk_none]"), // With alias
    
    // Complex shortcuts that cannot be exported (stay in LeaderKey)
    ("CSa delay:500 Ob", false, nil),   // Has delay
    ("keydown:left_command a", false, nil), // Has keydown
    ("a keyup:left_command", false, nil),   // Has keyup
    ("delay:100 CSa", false, nil),          // Starts with delay
]

// Helper function to test canExportShortcutToKarabiner
func canExportShortcutToKarabiner(_ shortcut: String) -> Bool {
    let parts = shortcut.split(separator: " ")
    for part in parts {
        let lower = part.lowercased()
        if lower.contains("delay:") || lower.contains("keydown:") || lower.contains("keyup:") {
            return false
        }
    }
    return true
}

// Test the analyzer
print("Testing shortcut analyzer:")
print("-" * 50)

for test in testCases {
    let result = canExportShortcutToKarabiner(test.shortcut)
    let passed = result == test.canExport
    let symbol = passed ? "✅" : "❌"
    
    print("\(symbol) \"\(test.shortcut)\"")
    print("   Expected: \(test.canExport ? "exportable" : "keep in LeaderKey")")
    print("   Got: \(result ? "exportable" : "keep in LeaderKey")")
    
    if !passed {
        print("   FAILED!")
    }
}

print("\nSummary:")
let passedCount = testCases.filter { canExportShortcutToKarabiner($0.shortcut) == $0.canExport }.count
print("Passed: \(passedCount)/\(testCases.count)")

// Extension for String multiplication
extension String {
    static func * (lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}