#!/usr/bin/env swift

import Foundation
import AppKit

// Test unified EDN generation with real app configs
print("=== Testing Unified EDN Generation with Real Configs ===\n")

// Simulate the export process from Karabiner2InputMethod
let configDir = NSHomeDirectory() + "/Library/Application Support/Leader Key"
var appConfigs: [(bundleId: String, customName: String?)] = []

do {
    let files = try FileManager.default.contentsOfDirectory(atPath: configDir)
    for file in files {
        // Match app config files (app.{bundleId}.json) but exclude .meta.json files
        if file.hasPrefix("app.") && file.hasSuffix(".json") && !file.hasSuffix(".meta.json") && file != "app-fallback-config.json" {
            // Extract bundle ID from filename
            let bundleId = String(file.dropFirst(4).dropLast(5)) // Remove "app." and ".json"
            
            // Skip certain system configs
            if bundleId == "default" || bundleId.contains("Leader-Key") || bundleId.contains("leaderkey") {
                continue
            }
            
            // Try to read custom name from meta file
            var customName: String? = nil
            let metaFilePath = configDir + "/app.\(bundleId).meta.json"
            if FileManager.default.fileExists(atPath: metaFilePath) {
                do {
                    let metaData = try Data(contentsOf: URL(fileURLWithPath: metaFilePath))
                    if let json = try JSONSerialization.jsonObject(with: metaData) as? [String: Any],
                       let name = json["customName"] as? String {
                        customName = name
                    }
                } catch {
                    print("Failed to read meta file for \(bundleId): \(error)")
                }
            }
            
            appConfigs.append((bundleId: bundleId, customName: customName))
        }
    }
} catch {
    print("Failed to list config directory: \(error)")
}

print("Found \(appConfigs.count) app-specific configs:\n")

// Function to generate alias (same as in Karabiner2Exporter)
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

// Generate unique aliases
var uniqueAliases: [(bundleId: String, alias: String)] = []
var usedAliases = Set<String>()

for (bundleId, customName) in appConfigs {
    var alias = generateAppAlias(from: bundleId, customName: customName)
    
    // Ensure uniqueness
    var counter = 1
    let baseAlias = alias
    while usedAliases.contains(alias) {
        alias = "\(baseAlias)_\(counter)"
        counter += 1
    }
    usedAliases.insert(alias)
    
    uniqueAliases.append((bundleId: bundleId, alias: alias))
}

// Display results
print("Generated Unique Aliases:")
print("-" + String(repeating: "-", count: 80))
for (bundleId, alias) in uniqueAliases.sorted(by: { $0.alias < $1.alias }) {
    let customName = appConfigs.first(where: { $0.bundleId == bundleId })?.customName ?? ""
    let nameDisplay = customName.isEmpty ? "(no custom name)" : "\"\(customName)\""
    print("  \(bundleId) → :\(alias) \(nameDisplay)")
}

print("\n" + String(repeating: "-", count: 80))

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
    print("\n✅ All \(uniqueAliases.count) aliases are unique!")
} else {
    print("\n❌ Duplicate aliases found!")
}

// Generate sample :applications section
print("\n\nSample :applications section for Goku EDN:")
print("-" + String(repeating: "-", count: 80))
print("{:applications {")
for (bundleId, alias) in uniqueAliases.sorted(by: { $0.alias < $1.alias }) {
    print("                :\(alias) [\"\(bundleId)\"]")
}
print("                }}")