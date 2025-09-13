import Foundation
import KeyboardShortcuts

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []

    private var profilesURL: URL {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupportDir.appendingPathComponent("Leader Key")
        return dir.appendingPathComponent("profiles.json")
    }

    init() {
        loadProfiles()
    }

    func loadProfiles() {
        do {
            let data = try Data(contentsOf: profilesURL)
            profiles = try JSONDecoder().decode([Profile].self, from: data)
        } catch {
            // If the file doesn't exist, create a default profile
            if profiles.isEmpty {
                let defaultProfile = Profile(name: "default")
                profiles = [defaultProfile]
                saveProfiles()
            }
        }
    }

    func saveProfiles() {
        do {
            let data = try JSONEncoder().encode(profiles)
            try data.write(to: profilesURL, options: .atomic)
        } catch {
            print("Failed to save profiles: \(error)")
        }
    }

    func createProfile(name: String) {
        let newProfile = Profile(name: name)
        profiles.append(newProfile)
        saveProfiles()
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
    }

    func renameProfile(_ profile: Profile, to newName: String) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].name = newName
            saveProfiles()
        }
    }
}
