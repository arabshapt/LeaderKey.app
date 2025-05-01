import Foundation

// MARK: - Group Path Handling
extension UserConfig {

    // Get a unique identifier for a group based on its path in the tree
    func getGroupPath(for group: Group) -> String {
        var path = ""
        // This should operate on the default config structure
        findGroupPathRecursive(root, [], group, &path)
        return path.isEmpty ? "root" : path
    }

    private func findGroupPathRecursive(_ current: Group, _ currentPath: [String], _ target: Group, _ result: inout String) {
        if current.key == target.key && current.label == target.label {
            result = currentPath.joined(separator: "/")
            return
        }

        for (index, item) in current.actions.enumerated() {
            if case .group(let subgroup) = item {
                var newPath = currentPath
                newPath.append("\(index)_\(subgroup.key ?? "")")
                findGroupPathRecursive(subgroup, newPath, target, &result)
            }
        }
    }

    // Find a group by its path
    func findGroupByPath(_ path: String) -> Group? {
        // This should operate on the default config structure
        if path == "root" {
            return root
        }

        let components = path.components(separatedBy: "/")
        // Start search from default root
        var currentGroup = root

        for component in components {
            let parts = component.components(separatedBy: "_")
            guard parts.count >= 2, let index = Int(parts[0]) else { return nil }

            if index < currentGroup.actions.count {
                if case .group(let subgroup) = currentGroup.actions[index] {
                    currentGroup = subgroup
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }

        return currentGroup
    }
} 