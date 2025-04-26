import Combine
import Foundation
import SwiftUI

final class UserState: ObservableObject {
  var userConfig: UserConfig!

  @Published var display: String?
  @Published var isShowingRefreshState: Bool
  @Published var navigationPath: [Group] = []

  var currentGroup: Group? {
    return navigationPath.last
  }

  init(
    userConfig: UserConfig!,
    lastChar: String? = nil,
    isShowingRefreshState: Bool = false
  ) {
    self.userConfig = userConfig
    display = lastChar
    self.isShowingRefreshState = isShowingRefreshState
    self.navigationPath = []
  }

  func clear() {
    display = nil
    navigationPath = []
    isShowingRefreshState = false
  }

  func navigateToGroup(_ group: Group) {
    navigationPath.append(group)
  }
  
  // Navigate to a group by building the full path to it
  func navigateToGroupPath(_ group: Group) {
    clear()
    
    // Get the full path to this group
    var pathGroups: [Group] = []
    buildGroupPath(from: userConfig.root, to: group, currentPath: [], result: &pathGroups)
    
    // Navigate to each group in the path
    for pathGroup in pathGroups {
      navigateToGroup(pathGroup)
    }
  }
  
  // Helper function to build the full path to a group
  private func buildGroupPath(from current: Group, to target: Group, currentPath: [Group], result: inout [Group]) {
    // If we found the target, the path is complete
    if current.key == target.key && current.label == target.label {
      result = currentPath + [current]
      return
    }
    
    // Continue searching in subgroups
    for item in current.actions {
      if case .group(let subgroup) = item {
        buildGroupPath(from: subgroup, to: target, currentPath: currentPath + [current], result: &result)
        
        // If we found the path, stop searching
        if !result.isEmpty {
          return
        }
      }
    }
  }
}
