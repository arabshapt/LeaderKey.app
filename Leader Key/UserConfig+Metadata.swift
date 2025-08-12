import Foundation
import Defaults

struct ConfigMetadata: Codable {
    var customName: String?
    var createdAt: Date?
    var lastModified: Date?
    var author: String?
}

extension UserConfig {
    
    private func metadataPath(for configPath: String) -> String {
        let configURL = URL(fileURLWithPath: configPath)
        let configNameWithoutExtension = configURL.deletingPathExtension().lastPathComponent
        let metadataFileName = "\(configNameWithoutExtension).meta.json"
        return configURL.deletingLastPathComponent().appendingPathComponent(metadataFileName).path
    }
    
    func loadMetadata(for configPath: String) -> ConfigMetadata? {
        let metaPath = metadataPath(for: configPath)
        
        guard fileManager.fileExists(atPath: metaPath) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: metaPath))
            let decoder = JSONDecoder()
            return try decoder.decode(ConfigMetadata.self, from: data)
        } catch {
            print("[UserConfig] Failed to load metadata from \(metaPath): \(error)")
            return nil
        }
    }
    
    func saveMetadata(_ metadata: ConfigMetadata, for configPath: String) {
        let metaPath = metadataPath(for: configPath)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
            let data = try encoder.encode(metadata)
            try data.write(to: URL(fileURLWithPath: metaPath))
            print("[UserConfig] Successfully saved metadata to \(metaPath)")
        } catch {
            print("[UserConfig] Failed to save metadata to \(metaPath): \(error)")
        }
    }
    
    func deleteMetadata(for configPath: String) {
        let metaPath = metadataPath(for: configPath)
        
        guard fileManager.fileExists(atPath: metaPath) else {
            return
        }
        
        do {
            try fileManager.removeItem(atPath: metaPath)
            print("[UserConfig] Successfully deleted metadata at \(metaPath)")
        } catch {
            print("[UserConfig] Failed to delete metadata at \(metaPath): \(error)")
        }
    }
    
    func updateMetadataCustomName(_ customName: String?, for configPath: String) {
        var metadata = loadMetadata(for: configPath) ?? ConfigMetadata()
        metadata.customName = customName
        metadata.lastModified = Date()
        if metadata.createdAt == nil {
            metadata.createdAt = Date()
        }
        saveMetadata(metadata, for: configPath)
    }
    
    func migrateCustomNamesToMetadata() {
        let customNames = Defaults[.configFileCustomNames]
        
        guard !customNames.isEmpty else {
            print("[UserConfig] No custom names to migrate")
            return
        }
        
        print("[UserConfig] Migrating \(customNames.count) custom names to metadata files")
        
        for (configPath, customName) in customNames {
            if fileManager.fileExists(atPath: configPath) {
                var metadata = loadMetadata(for: configPath) ?? ConfigMetadata()
                if metadata.customName == nil {
                    metadata.customName = customName
                    metadata.createdAt = Date()
                    metadata.lastModified = Date()
                    saveMetadata(metadata, for: configPath)
                    print("[UserConfig] Migrated custom name '\(customName)' for \(configPath)")
                }
            }
        }
        
        print("[UserConfig] Migration complete")
    }
}