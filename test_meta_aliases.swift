#!/usr/bin/env swift

import Foundation

// Test meta file based alias generation
print("=== Testing Meta File Based Alias Generation ===\n")

// Define test cases with custom names
let testCases: [(bundleId: String, customName: String?, expected: String)] = [
    // With custom names
    ("com.microsoft.VSCode", "VSCode", "vscode"),
    ("com.todesktop.230313mzl4w4u92", "Cursor", "cursor"),
    ("company.thebrowser.Browser", "Arc", "arc"),
    ("com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm", "Email Randstad", "email_randstad"),
    ("com.apple.Terminal", "Terminal & Shell", "terminal_and_shell"),
    ("com.test.app", "My App (Beta)", "my_app_beta"),
    ("com.test.app2", "App-With-Dashes", "app_with_dashes"),
    ("com.test.app3", "App #1 @Home!", "app_1_athome"),
    ("com.test.app4", "App/With Slashes", "app_with_slashes"),
    
    // Without custom names (fallback)
    ("com.apple.finder", nil, "finder"),
    ("com.jetbrains.intellij", nil, "intellij"),
    ("dev.warp.Warp-Stable", nil, "warp"),
    ("com.unknown.app", nil, "com_unknown_app"),
    
    // Edge cases
    ("com.test.app5", "", "com_test_app5"), // Empty custom name
    ("com.test.app6", "   ", "com_test_app6"), // Whitespace only
    ("com.test.app7", "___", "com_test_app7"), // Only underscores
    ("com.test.app8", "A & B + C @ D", "a_and_b_plus_c_at_d"),
]

// Function to generate alias (simplified version of the actual implementation)
func generateAppAlias(from bundleId: String, customName: String? = nil) -> String {
    // If we have a custom name from meta file, use it
    if let customName = customName, !customName.isEmpty {
        // Convert custom name to valid Goku alias
        let cleaned = customName
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "+", with: "plus")
            .replacingOccurrences(of: "@", with: "at")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "^", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "|", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: ";", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "~", with: "")
        
        // Remove consecutive underscores and trim
        let normalized = cleaned
            .split(separator: "_")
            .filter { !$0.isEmpty }
            .joined(separator: "_")
        
        return normalized.isEmpty ? bundleId.replacingOccurrences(of: ".", with: "_").lowercased() : normalized
    }
    
    // Fallback to hardcoded mappings
    let knownApps: [String: String] = [
        "com.apple.finder": "finder",
        "com.jetbrains.intellij": "intellij",
        "dev.warp.Warp-Stable": "warp",
    ]
    
    if let known = knownApps[bundleId] {
        return known
    }
    
    // Default fallback
    return bundleId.replacingOccurrences(of: ".", with: "_").lowercased()
}

// Run tests
var passed = 0
var failed = 0

for (bundleId, customName, expected) in testCases {
    let result = generateAppAlias(from: bundleId, customName: customName)
    if result == expected {
        print("✅ PASS: \(bundleId)")
        print("   Custom Name: \(customName ?? "nil")")
        print("   Result: \(result)")
        passed += 1
    } else {
        print("❌ FAIL: \(bundleId)")
        print("   Custom Name: \(customName ?? "nil")")
        print("   Expected: \(expected)")
        print("   Got: \(result)")
        failed += 1
    }
    print()
}

print("=== Test Results ===")
print("Passed: \(passed)")
print("Failed: \(failed)")
print("Total: \(passed + failed)")

if failed == 0 {
    print("\n✅ All tests passed!")
} else {
    print("\n❌ Some tests failed!")
}