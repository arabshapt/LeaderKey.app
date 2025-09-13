import Foundation
import KeyboardShortcuts

struct Profile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String

    var shortcutName: KeyboardShortcuts.Name {
        .init(name, default: nil)
    }

    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
}
