#!/usr/bin/env swift

import Foundation

// Test unique alias generation with duplicate custom names
print("=== Testing Unique Alias Generation ===\n")

// Function to generate alias (simplified version)
func generateAppAlias(from bundleId: String, customName: String? = nil) -> String {
    if let customName = customName, !customName.isEmpty {
        let cleaned = customName
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "+", with: "plus")
            .replacingOccurrences(of: "@", with: "at")
        
        let normalized = cleaned
            .split(separator: "_")
            .filter { !$0.isEmpty }
            .joined(separator: "_")
        
        return normalized.isEmpty ? bundleId.replacingOccurrences(of: ".", with: "_").lowercased() : normalized
    }
    
    return bundleId.replacingOccurrences(of: ".", with: "_").lowercased()
}

// Function to ensure uniqueness
func generateUniqueAliases(configs: [(bundleId: String, customName: String?)]) -> [(bundleId: String, alias: String)] {
    var result: [(bundleId: String, alias: String)] = []
    var usedAliases = Set<String>()
    
    for (bundleId, customName) in configs {
        var alias = generateAppAlias(from: bundleId, customName: customName)
        
        // Ensure uniqueness
        var counter = 1
        let baseAlias = alias
        while usedAliases.contains(alias) {
            alias = "\(baseAlias)_\(counter)"
            counter += 1
        }
        usedAliases.insert(alias)
        
        result.append((bundleId: bundleId, alias: alias))
    }
    
    return result
}

// Test cases with some duplicate custom names
let testConfigs: [(bundleId: String, customName: String?)] = [
    // Different apps with same custom name "Editor"
    ("com.microsoft.VSCode", "Editor"),
    ("com.todesktop.230313mzl4w4u92", "Editor"),
    ("dev.zed.Zed", "Editor"),
    
    // Apps with unique names
    ("company.thebrowser.Browser", "Arc"),
    ("com.apple.Terminal", "Terminal"),
    
    // More duplicates with "Browser"
    ("com.google.Chrome", "Browser"),
    ("company.thebrowser.dia", "Browser"),
    
    // Apps without custom names that might collide
    ("com.app.meta", nil),  // Would become "com_app_meta"
    ("com.app.meta2", nil), // Would become "com_app_meta2"
    
    // Edge case: custom name that becomes empty after cleaning
    ("com.test.app", "___"),
    ("com.test.app2", "   "),
]

print("Test Configs:")
for (bundleId, customName) in testConfigs {
    print("  \(bundleId): \"\(customName ?? "nil")\"")
}

print("\n" + String(repeating: "-", count: 50) + "\n")

let uniqueAliases = generateUniqueAliases(configs: testConfigs)

print("Generated Unique Aliases:")
for (bundleId, alias) in uniqueAliases {
    print("  :\(alias) [\"\(bundleId)\"]")
}

print("\n" + String(repeating: "-", count: 50) + "\n")

// Check for duplicates
var aliasSet = Set<String>()
var hasDuplicates = false
for (_, alias) in uniqueAliases {
    if aliasSet.contains(alias) {
        print("❌ DUPLICATE FOUND: \(alias)")
        hasDuplicates = true
    }
    aliasSet.insert(alias)
}

if !hasDuplicates {
    print("✅ All aliases are unique!")
} else {
    print("❌ Duplicate aliases found!")
}

// Verify expected behavior
print("\nExpected Behavior Verification:")
let expectedPairs: [(bundleId: String, expectedAlias: String)] = [
    ("com.microsoft.VSCode", "editor"),      // First "Editor"
    ("com.todesktop.230313mzl4w4u92", "editor_1"), // Second "Editor"
    ("dev.zed.Zed", "editor_2"),            // Third "Editor"
    ("company.thebrowser.Browser", "arc"),
    ("com.apple.Terminal", "terminal"),
    ("com.google.Chrome", "browser"),        // First "Browser"
    ("company.thebrowser.dia", "browser_1"), // Second "Browser"
]

for (bundleId, expectedAlias) in expectedPairs {
    if let actual = uniqueAliases.first(where: { $0.bundleId == bundleId }) {
        if actual.alias == expectedAlias {
            print("  ✅ \(bundleId): \(actual.alias)")
        } else {
            print("  ❌ \(bundleId): expected '\(expectedAlias)', got '\(actual.alias)'")
        }
    }
}