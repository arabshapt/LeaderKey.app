import AppKit
import Defaults
import os
import SwiftUI

typealias NodeID = UUID

struct NodeRecord: Identifiable {
  let id: NodeID
  let parentID: NodeID?
  let path: [Int]
  let depth: Int
  let item: ActionOrGroup

  var isGroup: Bool {
    if case .group = item { return true }
    return false
  }

  var displayKey: String {
    item.item.key ?? ""
  }

  var displayLabel: String {
    item.item.displayName
  }

  var typeLabel: String {
    switch item {
    case .group:
      return "Group"
    case .action(let action):
      return action.type.rawValue
    }
  }

  var showsStickyMode: Bool {
    switch item {
    case .group(let group):
      return group.stickyMode == true
    case .action(let action):
      return action.stickyMode == true
    }
  }

  var isFromFallback: Bool {
    switch item {
    case .group(let group):
      return group.isFromFallback
    case .action(let action):
      return action.isFromFallback
    }
  }
}

enum ConfigOutlinePerfMetrics {
  #if DEBUG
    private static let instrumentationEnabled =
      ProcessInfo.processInfo.environment["LK_CONFIG_OUTLINE_METRICS"] == "1"
    private static let logger = Logger(
      subsystem: Bundle.main.bundleIdentifier ?? "com.brnbw.Leader-Key", category: "ConfigOutlinePerf")
    private static let signposter = OSSignposter(
      subsystem: Bundle.main.bundleIdentifier ?? "com.brnbw.Leader-Key", category: "ConfigOutlinePerf")
    private static var rawSelectionEvents = 0
    private static var coalescedSelectionPublishes = 0
    private static var totalSelectionPublishes = 0
    private static var inspectorCommits = 0
    private static var lastReportUptime = ProcessInfo.processInfo.systemUptime
  #endif

  static func beginSelectionEvent(source: ConfigEditorSession.SelectionSource) -> OSSignpostIntervalState? {
    #if DEBUG
      guard instrumentationEnabled else { return nil }
      rawSelectionEvents += 1
      maybeReportCounters()
      let state = signposter.beginInterval("SelectionEvent")
      return state
    #else
      let _ = source
      return nil
    #endif
  }

  static func endSelectionEvent(_ state: OSSignpostIntervalState?) {
    #if DEBUG
      guard instrumentationEnabled else { return }
      guard let state else { return }
      signposter.endInterval("SelectionEvent", state)
    #endif
  }

  static func recordSelectionPublish(coalesced: Bool) {
    #if DEBUG
      guard instrumentationEnabled else { return }
      totalSelectionPublishes += 1
      if coalesced {
        coalescedSelectionPublishes += 1
      }
      maybeReportCounters()
    #endif
  }

  static func recordInspectorCommit() {
    #if DEBUG
      guard instrumentationEnabled else { return }
      inspectorCommits += 1
      maybeReportCounters()
    #endif
  }

  #if DEBUG
    private static func maybeReportCounters() {
      let now = ProcessInfo.processInfo.systemUptime
      guard now - lastReportUptime >= 1.0 else { return }

      logger.debug(
        "perf counters rawSelectionEvents=\(rawSelectionEvents) publishes=\(totalSelectionPublishes) coalescedPublishes=\(coalescedSelectionPublishes) inspectorCommits=\(inspectorCommits)"
      )
      rawSelectionEvents = 0
      totalSelectionPublishes = 0
      coalescedSelectionPublishes = 0
      inspectorCommits = 0
      lastReportUptime = now
    }
  #endif
}

final class ConfigEditorSession: ObservableObject {
  enum SelectionSource: String {
    case mouse
    case keyboardTap
    case keyboardRepeat
    case scroll
    case programmatic
  }

  @Published private(set) var root: Group = emptyRoot
  @Published private(set) var rootID: NodeID = emptyRoot.id
  @Published private(set) var nodeIndex: [NodeID: NodeRecord] = [:]
  @Published private(set) var childrenIndex: [NodeID: [NodeID]] = [:]
  @Published private(set) var expanded: Set<NodeID> = []
  @Published private(set) var selectedTreeID: NodeID?
  @Published private(set) var inspectorSelectedID: NodeID?
  @Published private(set) var isInspectorNavigating = false
  @Published private(set) var validationErrors: [ValidationError] = []
  @Published private(set) var validationByNodeID: [NodeID: ValidationError] = [:]
  @Published private(set) var structureVersion: Int = 0
  @Published private(set) var expansionVersion: Int = 0
  @Published private(set) var displayVersion: Int = 0
  @Published var showFallbackItems: Bool = Defaults[.showFallbackItems] {
    didSet {
      rebuildIndex(preserveExpansion: true)
    }
  }
  @Published var sortForDisplay: Bool = true {
    didSet {
      rebuildIndex(preserveExpansion: true)
    }
  }
  @Published private(set) var isDirty = false
  @Published private(set) var inspectorFocusToken = UUID()

  private weak var userConfig: UserConfig?
  private var selectedConfigKey = globalDefaultDisplayName
  private var pathForNodeID: [NodeID: [Int]] = [:]
  private var nodeIDForPath: [[Int]: NodeID] = [:]
  private var pendingValidationWorkItem: DispatchWorkItem?
  private var pendingInspectorSelectionWorkItem: DispatchWorkItem?
  private let deferredInspectorSelectionDelay: TimeInterval = 0.06

  var rootChildren: [NodeID] {
    childrenIndex[rootID] ?? []
  }

  var selectedRecord: NodeRecord? {
    guard let selectedTreeID else { return nil }
    return nodeIndex[selectedTreeID]
  }

  var inspectorSelectedRecord: NodeRecord? {
    guard let inspectorSelectedID else { return nil }
    return nodeIndex[inspectorSelectedID]
  }

  var inspectorSelectedItem: ActionOrGroup? {
    inspectorSelectedRecord?.item
  }

  var selectedValidationError: ValidationError? {
    guard let inspectorSelectedID else { return nil }
    return validationByNodeID[inspectorSelectedID]
  }

  func bind(to userConfig: UserConfig) {
    self.userConfig = userConfig
    self.selectedConfigKey = userConfig.selectedConfigKeyForEditing
    self.showFallbackItems = Defaults[.showFallbackItems]
    self.sortForDisplay = !userConfig.isActivelyEditing
    load(
      root: userConfig.currentlyEditingGroup,
      validationErrors: userConfig.validationErrors,
      selectedConfigKey: userConfig.selectedConfigKeyForEditing,
      preserveExpansion: false
    )
  }

  func load(
    root: Group,
    validationErrors: [ValidationError],
    selectedConfigKey: String,
    preserveExpansion: Bool
  ) {
    self.root = root
    self.rootID = root.id
    self.selectedConfigKey = selectedConfigKey
    self.validationErrors = validationErrors
    rebuildIndex(preserveExpansion: preserveExpansion)
    rebuildValidationMap()
    if selectedTreeID == nil || (selectedTreeID != nil && nodeIndex[selectedTreeID!] == nil) {
      select(rootChildren.first, source: .programmatic)
    }
    if inspectorSelectedID != selectedTreeID {
      applyInspectorSelectionImmediately(selectedTreeID)
    }
    isDirty = false
  }

  func focusInspector() {
    if selectedTreeID != inspectorSelectedID {
      select(selectedTreeID, source: .programmatic)
    }
    inspectorFocusToken = UUID()
  }

  func path(for nodeID: NodeID) -> [Int]? {
    pathForNodeID[nodeID]
  }

  func nodeID(forPath path: [Int]) -> NodeID? {
    nodeIDForPath[path]
  }

  func expand(_ nodeID: NodeID) {
    if expanded.insert(nodeID).inserted {
      expansionVersion &+= 1
    }
  }

  func collapse(_ nodeID: NodeID) {
    if expanded.remove(nodeID) != nil {
      expansionVersion &+= 1
    }
  }

  func toggle(_ nodeID: NodeID) {
    if expanded.contains(nodeID) {
      collapse(nodeID)
    } else {
      expand(nodeID)
    }
  }

  func select(_ nodeID: NodeID?, source: SelectionSource = .programmatic) {
    if selectedTreeID != nodeID {
      selectedTreeID = nodeID
    }

    switch source {
    case .keyboardRepeat, .scroll:
      scheduleInspectorSelection(nodeID, delay: deferredInspectorSelectionDelay)
    case .keyboardTap, .mouse, .programmatic:
      applyInspectorSelectionImmediately(nodeID)
    }
  }

  func collapseAll() {
    guard !expanded.isEmpty else { return }
    expanded.removeAll()
    expansionVersion &+= 1
  }

  func expandAll() {
    let ids = nodeIndex.values.filter { $0.isGroup && $0.id != rootID }.map(\.id)
    let newExpanded = Set(ids)
    guard newExpanded != expanded else { return }
    expanded = newExpanded
    expansionVersion &+= 1
  }

  func reveal(path: [Int], collapseBeforeExpand: Bool = false) {
    guard let nodeID = nodeID(forPath: path) else { return }

    var newExpanded = expanded
    if collapseBeforeExpand {
      newExpanded.removeAll()
    }

    var currentID = nodeID
    while let parentID = nodeIndex[currentID]?.parentID, parentID != rootID {
      newExpanded.insert(parentID)
      currentID = parentID
    }

    if newExpanded != expanded {
      expanded = newExpanded
      expansionVersion &+= 1
    }

    select(nodeID, source: .programmatic)
  }

  func copy(_ nodeID: NodeID? = nil) {
    let targetID = nodeID ?? selectedTreeID
    guard let targetID,
      let item = nodeIndex[targetID]?.item,
      targetID != rootID
    else { return }

    ClipboardManager.shared.copyItem(item, fromConfig: selectedConfigKey)
  }

  func paste(into nodeID: NodeID? = nil) {
    guard let pastedItem = ClipboardManager.shared.pasteItem() else { return }

    let targetID = nodeID ?? selectedTreeID

    if let targetID,
      let record = nodeIndex[targetID],
      let targetPath = path(for: targetID)
    {
      switch record.item {
      case .group(let group):
        let insertPath = targetPath + [group.actions.count]
        let cleanedItem = validateAndCleanItem(pastedItem, parentPath: targetPath)
        insert(item: cleanedItem, at: insertPath)
        finalizeStructuralChange(selectPath: insertPath)
      case .action:
        guard let siblingIndex = targetPath.last else { return }
        let parentPath = Array(targetPath.dropLast())
        let insertPath = parentPath + [siblingIndex + 1]
        let cleanedItem = validateAndCleanItem(pastedItem, parentPath: parentPath)
        insert(item: cleanedItem, at: insertPath)
        finalizeStructuralChange(selectPath: insertPath)
      }
      return
    }

    let parentPath: [Int] = []
    let insertPath = [root.actions.count]
    let cleanedItem = validateAndCleanItem(pastedItem, parentPath: parentPath)
    insert(item: cleanedItem, at: insertPath)
    finalizeStructuralChange(selectPath: insertPath)
  }

  func insertAction(after nodeID: NodeID? = nil) {
    let newAction = ActionOrGroup.action(Action(key: "", type: .shortcut, value: ""))

    guard let targetID = nodeID ?? selectedTreeID,
      let targetPath = path(for: targetID),
      let record = nodeIndex[targetID]
    else {
      let insertPath = [root.actions.count]
      insert(item: newAction, at: insertPath)
      finalizeStructuralChange(selectPath: insertPath)
      return
    }

    switch record.item {
    case .group(let group):
      let insertPath = targetPath + [group.actions.count]
      insert(item: newAction, at: insertPath)
      finalizeStructuralChange(selectPath: insertPath)
    case .action:
      guard let siblingIndex = targetPath.last else { return }
      let insertPath = Array(targetPath.dropLast()) + [siblingIndex + 1]
      insert(item: newAction, at: insertPath)
      finalizeStructuralChange(selectPath: insertPath)
    }
  }

  func insertGroup(after nodeID: NodeID? = nil) {
    let newGroup = ActionOrGroup.group(Group(key: "", stickyMode: nil, actions: []))

    guard let targetID = nodeID ?? selectedTreeID,
      let targetPath = path(for: targetID),
      let record = nodeIndex[targetID]
    else {
      let insertPath = [root.actions.count]
      insert(item: newGroup, at: insertPath)
      finalizeStructuralChange(selectPath: insertPath)
      return
    }

    switch record.item {
    case .group(let group):
      let insertPath = targetPath + [group.actions.count]
      insert(item: newGroup, at: insertPath)
      finalizeStructuralChange(selectPath: insertPath)
    case .action:
      guard let siblingIndex = targetPath.last else { return }
      let insertPath = Array(targetPath.dropLast()) + [siblingIndex + 1]
      insert(item: newGroup, at: insertPath)
      finalizeStructuralChange(selectPath: insertPath)
    }
  }

  func duplicate(_ nodeID: NodeID? = nil) {
    let targetID = nodeID ?? selectedTreeID
    guard let targetID,
      let record = nodeIndex[targetID],
      targetID != rootID,
      let sourcePath = path(for: targetID),
      let sourceIndex = sourcePath.last
    else { return }

    let parentPath = Array(sourcePath.dropLast())
    let insertPath = parentPath + [sourceIndex + 1]
    let duplicated = makeTrueDuplicate(item: record.item)
    insert(item: duplicated, at: insertPath)
    finalizeStructuralChange(selectPath: insertPath)
  }

  func delete(_ maybeNodeID: NodeID? = nil) {
    let targetID = maybeNodeID ?? selectedTreeID
    guard let targetID,
      targetID != rootID,
      let targetPath = path(for: targetID),
      let siblingIndex = targetPath.last
    else { return }

    let parentPath = Array(targetPath.dropLast())
    delete(at: targetPath)

    rebuildIndex(preserveExpansion: true)

    let siblingCountAfterDelete: Int
    if parentPath.isEmpty {
      siblingCountAfterDelete = root.actions.count
    } else if let parentItem = itemAtPath(parentPath), case .group(let parentGroup) = parentItem {
      siblingCountAfterDelete = parentGroup.actions.count
    } else {
      siblingCountAfterDelete = 0
    }

    if siblingCountAfterDelete > 0 {
      let nextIndex = min(siblingIndex, siblingCountAfterDelete - 1)
      let nextPath = parentPath + [nextIndex]
      select(self.nodeID(forPath: nextPath), source: .programmatic)
    } else if !parentPath.isEmpty {
      select(self.nodeID(forPath: parentPath), source: .programmatic)
    } else {
      select(rootChildren.first, source: .programmatic)
    }

    notifyDirtyStateChanged()
  }

  func makeSelectedEditable() {
    let targetID = inspectorSelectedID ?? selectedTreeID
    guard let selectedID = targetID,
      let record = nodeIndex[selectedID],
      let targetPath = path(for: selectedID)
    else { return }

    switch record.item {
    case .action(var action):
      guard action.isFromFallback else { return }
      action.isFromFallback = false
      action.fallbackSource = nil
      if let macroSteps = action.macroSteps {
        action.macroSteps = macroSteps.map { step in
          var newStep = step
          newStep.action.isFromFallback = false
          newStep.action.fallbackSource = nil
          return newStep
        }
      }
      applyEdit(nodeID: selectedID) { item in
        item = .action(action)
      }
    case .group(var group):
      guard group.isFromFallback else { return }
      group.isFromFallback = false
      group.fallbackSource = nil
      group.actions = convertNestedFallbacksToAppSpecific(group.actions)
      applyEdit(nodeID: selectedID) { item in
        item = .group(group)
      }
    }

    select(self.nodeID(forPath: targetPath), source: .programmatic)
  }

  func applyEdit(nodeID targetNodeID: NodeID, patch: (inout ActionOrGroup) -> Void) {
    guard targetNodeID != rootID,
      let targetPath = path(for: targetNodeID),
      let previousRecord = nodeIndex[targetNodeID]
    else { return }

    modifyItem(in: &root, at: targetPath) { item in
      patch(&item)
    }

    if let updatedItem = itemAtPath(targetPath),
      canApplyActionOnlyUpdate(previous: previousRecord.item, updated: updatedItem)
    {
      var updatedNodeIndex = nodeIndex
      updatedNodeIndex[targetNodeID] = NodeRecord(
        id: previousRecord.id,
        parentID: previousRecord.parentID,
        path: previousRecord.path,
        depth: previousRecord.depth,
        item: updatedItem
      )
      nodeIndex = updatedNodeIndex

      if sortForDisplay,
        let parentID = previousRecord.parentID,
        var siblingIDs = childrenIndex[parentID]
      {
        let previousSiblingOrder = siblingIDs
        siblingIDs.sort { left, right in
          compareSortOrder(left, right, nodeIndex: updatedNodeIndex)
        }
        if siblingIDs != previousSiblingOrder {
          var updatedChildrenIndex = childrenIndex
          updatedChildrenIndex[parentID] = siblingIDs
          childrenIndex = updatedChildrenIndex
          structureVersion += 1
        }
      }

      select(targetNodeID, source: .programmatic)
      markDisplayUpdated()
    } else {
      rebuildIndex(preserveExpansion: true)
      select(self.nodeID(forPath: targetPath), source: .programmatic)
    }

    notifyDirtyStateChanged()
  }

  func updateSelectedAction(_ newAction: Action) {
    guard let selectedID = inspectorSelectedID ?? selectedTreeID else { return }
    applyEdit(nodeID: selectedID) { item in
      guard case .action = item else { return }
      item = .action(newAction)
    }
  }

  func updateSelectedGroup(_ newGroup: Group) {
    guard let selectedID = inspectorSelectedID ?? selectedTreeID else { return }
    applyEdit(nodeID: selectedID) { item in
      guard case .group = item else { return }
      item = .group(newGroup)
    }
  }

  func commitToUserConfig() {
    guard let userConfig else { return }
    userConfig.currentlyEditingGroup = root
    userConfig.isActivelyEditing = true
    userConfig.validationErrors = validationErrors
  }

  // MARK: - Command Scout Apply

  func applyCommandScoutSuggestions(_ suggestions: [CommandScoutSuggestion]) -> CommandScoutApplyResult {
    var insertedCount = 0
    var skippedMessages: [String] = []

    for suggestion in suggestions {
      guard let action = suggestion.makeAction() else {
        skippedMessages.append("\(suggestion.title): invalid action")
        continue
      }
      let tokens = suggestion.sequenceTokens
      guard !tokens.isEmpty else {
        skippedMessages.append("\(suggestion.title): invalid sequence")
        continue
      }

      if tokens.count == 1 {
        // Single key: insert at root
        root.actions.append(.action(action))
      } else {
        // Multi-key: create/reuse intermediate groups, insert action at leaf
        insertAtSequencePath(tokens: tokens, action: action, category: suggestion.category)
      }
      insertedCount += 1
    }

    if insertedCount > 0 {
      rebuildIndex(preserveExpansion: true)
      notifyDirtyStateChanged()
    }

    return CommandScoutApplyResult(insertedCount: insertedCount, skippedMessages: skippedMessages)
  }

  private func insertAtSequencePath(tokens: [String], action: Action, category: String) {
    // Navigate/create groups for all tokens except the last (which is the action key)
    var currentActions = root.actions
    var groupIndices: [Int] = []

    for (i, token) in tokens.dropLast().enumerated() {
      if let existingIndex = currentActions.firstIndex(where: {
        if case .group(let g) = $0 { return g.key?.lowercased() == token }
        return false
      }) {
        groupIndices.append(existingIndex)
        if case .group(let g) = currentActions[existingIndex] {
          currentActions = g.actions
        }
      } else {
        // Create new group
        let label = i == 0 ? category : nil
        let newGroup = Group(key: token, label: label, stickyMode: nil, actions: [])
        // Insert into the tree at the right level
        insertGroupAtPath(groupIndices, newGroup: newGroup, remainingTokens: Array(tokens.dropLast().dropFirst(i + 1)), action: action)
        return
      }
    }

    // All intermediate groups exist — insert action at the deepest group
    insertActionAtGroupPath(groupIndices, action: action)
  }

  private func insertGroupAtPath(_ parentPath: [Int], newGroup: Group, remainingTokens: [String], action: Action) {
    // Build nested group structure from inside out
    var innerGroup = newGroup
    // Create remaining intermediate groups
    for token in remainingTokens {
      innerGroup = Group(key: innerGroup.key, label: innerGroup.label, stickyMode: nil,
                         actions: [.group(Group(key: token, label: nil, stickyMode: nil, actions: []))])
    }

    // Find deepest existing group to add the action
    func addActionToDeepest(_ group: inout Group) {
      if group.actions.isEmpty {
        group.actions.append(.action(action))
      } else if case .group(var sub) = group.actions.last {
        addActionToDeepest(&sub)
        group.actions[group.actions.count - 1] = .group(sub)
      } else {
        group.actions.append(.action(action))
      }
    }
    addActionToDeepest(&innerGroup)

    // Insert at the right parent level
    if parentPath.isEmpty {
      root.actions.append(.group(innerGroup))
    } else {
      appendToGroup(at: parentPath, item: .group(innerGroup))
    }
  }

  private func insertActionAtGroupPath(_ path: [Int], action: Action) {
    if path.isEmpty {
      root.actions.append(.action(action))
      return
    }
    appendToGroup(at: path, item: .action(action))
  }

  private func appendToGroup(at path: [Int], item: ActionOrGroup) {
    func appendInGroup(_ group: inout Group, remainingPath: [Int]) {
      guard let first = remainingPath.first, first < group.actions.count else {
        group.actions.append(item)
        return
      }
      if remainingPath.count == 1 {
        if case .group(var sub) = group.actions[first] {
          sub.actions.append(item)
          group.actions[first] = .group(sub)
        }
      } else {
        if case .group(var sub) = group.actions[first] {
          appendInGroup(&sub, remainingPath: Array(remainingPath.dropFirst()))
          group.actions[first] = .group(sub)
        }
      }
    }
    appendInGroup(&root, remainingPath: path)
  }

  private func finalizeStructuralChange(selectPath: [Int]) {
    rebuildIndex(preserveExpansion: true)
    select(self.nodeID(forPath: selectPath), source: .programmatic)
    notifyDirtyStateChanged()
  }

  private func notifyDirtyStateChanged() {
    isDirty = true
    userConfig?.currentlyEditingGroup = root
    userConfig?.isActivelyEditing = true
    scheduleValidation()
  }

  private func scheduleValidation() {
    pendingValidationWorkItem?.cancel()
    let snapshot = root

    let workItem = DispatchWorkItem { [weak self] in
      let errors = ConfigValidator.validate(group: snapshot)
      DispatchQueue.main.async {
        guard let self else { return }
        self.validationErrors = errors
        self.rebuildValidationMap()
        self.userConfig?.validationErrors = errors
      }
    }

    pendingValidationWorkItem = workItem
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.12, execute: workItem)
  }

  private func rebuildValidationMap() {
    var map: [NodeID: ValidationError] = [:]
    for error in validationErrors {
      if let nodeID = nodeID(forPath: error.path), map[nodeID] == nil {
        map[nodeID] = error
      }
    }
    validationByNodeID = map
    markDisplayUpdated()
  }

  private func rebuildIndex(preserveExpansion: Bool) {
    let spid = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: "rebuildIndex", signpostID: spid)
    defer { os_signpost(.end, log: signpostLog, name: "rebuildIndex", signpostID: spid) }
    let previousExpanded = expanded
    let previousSelected = selectedTreeID

    var newNodeIndex: [NodeID: NodeRecord] = [:]
    var newChildrenIndex: [NodeID: [NodeID]] = [:]
    var newPathForNodeID: [NodeID: [Int]] = [:]
    var newNodeIDForPath: [[Int]: NodeID] = [:]

    let rootItem = ActionOrGroup.group(root)
    let rootRecord = NodeRecord(
      id: rootID,
      parentID: nil,
      path: [],
      depth: -1,
      item: rootItem
    )
    newNodeIndex[rootID] = rootRecord
    newPathForNodeID[rootID] = []
    newNodeIDForPath[[]] = rootID

    var topLevelChildren: [NodeID] = []
    for (index, childItem) in root.actions.enumerated() {
      if !showFallbackItems && isFallback(childItem) {
        continue
      }

      let childPath = [index]
      let childID = indexNode(
        childItem,
        parentID: rootID,
        path: childPath,
        depth: 0,
        nodeIndex: &newNodeIndex,
        childrenIndex: &newChildrenIndex,
        pathForNodeID: &newPathForNodeID,
        nodeIDForPath: &newNodeIDForPath
      )
      topLevelChildren.append(childID)
    }

    if sortForDisplay {
      topLevelChildren.sort { left, right in
        compareSortOrder(left, right, nodeIndex: newNodeIndex)
      }
    }

    newChildrenIndex[rootID] = topLevelChildren

    nodeIndex = newNodeIndex
    childrenIndex = newChildrenIndex
    pathForNodeID = newPathForNodeID
    nodeIDForPath = newNodeIDForPath

    let nextExpanded =
      preserveExpansion
      ? previousExpanded.intersection(Set(newNodeIndex.keys))
      : Set<NodeID>()
    if nextExpanded != expanded {
      expanded = nextExpanded
      expansionVersion &+= 1
    }

    if let previousSelected,
      newNodeIndex[previousSelected] != nil
    {
      select(previousSelected, source: .programmatic)
    } else {
      select(rootChildren.first, source: .programmatic)
    }

    structureVersion += 1
    rebuildValidationMap()
  }

  private func markDisplayUpdated() {
    displayVersion &+= 1
  }

  private func applyInspectorSelectionImmediately(_ nodeID: NodeID?) {
    pendingInspectorSelectionWorkItem?.cancel()
    pendingInspectorSelectionWorkItem = nil

    if inspectorSelectedID != nodeID {
      inspectorSelectedID = nodeID
      ConfigOutlinePerfMetrics.recordInspectorCommit()
    }

    if isInspectorNavigating {
      isInspectorNavigating = false
    }
  }

  private func scheduleInspectorSelection(_ nodeID: NodeID?, delay: TimeInterval) {
    pendingInspectorSelectionWorkItem?.cancel()
    isInspectorNavigating = true

    let workItem = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.inspectorSelectedID = nodeID
      self.isInspectorNavigating = false
      self.pendingInspectorSelectionWorkItem = nil
      ConfigOutlinePerfMetrics.recordInspectorCommit()
    }

    pendingInspectorSelectionWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  private func indexNode(
    _ item: ActionOrGroup,
    parentID: NodeID,
    path: [Int],
    depth: Int,
    nodeIndex: inout [NodeID: NodeRecord],
    childrenIndex: inout [NodeID: [NodeID]],
    pathForNodeID: inout [NodeID: [Int]],
    nodeIDForPath: inout [[Int]: NodeID]
  ) -> NodeID {
    let nodeID = item.id

    let record = NodeRecord(
      id: nodeID,
      parentID: parentID,
      path: path,
      depth: depth,
      item: item
    )
    nodeIndex[nodeID] = record
    pathForNodeID[nodeID] = path
    nodeIDForPath[path] = nodeID

    if case .group(let group) = item {
      var childIDs: [NodeID] = []
      for (childIndex, childItem) in group.actions.enumerated() {
        if !showFallbackItems && isFallback(childItem) {
          continue
        }

        let childPath = path + [childIndex]
        let childID = indexNode(
          childItem,
          parentID: nodeID,
          path: childPath,
          depth: depth + 1,
          nodeIndex: &nodeIndex,
          childrenIndex: &childrenIndex,
          pathForNodeID: &pathForNodeID,
          nodeIDForPath: &nodeIDForPath
        )
        childIDs.append(childID)
      }

      if sortForDisplay {
        childIDs.sort { left, right in
          compareSortOrder(left, right, nodeIndex: nodeIndex)
        }
      }

      childrenIndex[nodeID] = childIDs
    }

    return nodeID
  }

  private func compareSortOrder(_ left: NodeID, _ right: NodeID, nodeIndex: [NodeID: NodeRecord]) -> Bool {
    let leftKey = nodeIndex[left]?.item.item.key?.lowercased() ?? "zzz"
    let rightKey = nodeIndex[right]?.item.item.key?.lowercased() ?? "zzz"

    if leftKey == "zzz" && rightKey != "zzz" { return false }
    if leftKey != "zzz" && rightKey == "zzz" { return true }
    return leftKey < rightKey
  }

  private func isFallback(_ item: ActionOrGroup) -> Bool {
    switch item {
    case .action(let action):
      return action.isFromFallback
    case .group(let group):
      return group.isFromFallback
    }
  }

  private func itemAtPath(_ path: [Int]) -> ActionOrGroup? {
    guard !path.isEmpty else { return nil }

    var currentGroup = root
    for (depth, index) in path.enumerated() {
      guard index >= 0 && index < currentGroup.actions.count else { return nil }

      let item = currentGroup.actions[index]
      let isLast = depth == path.count - 1
      if isLast {
        return item
      }

      guard case .group(let subgroup) = item else { return nil }
      currentGroup = subgroup
    }

    return nil
  }

  private func modifyItem(in group: inout Group, at path: [Int], update: (inout ActionOrGroup) -> Void) {
    guard !path.isEmpty else {
      return
    }

    var currentPath = path
    let index = currentPath.removeFirst()

    guard index >= 0 && index < group.actions.count else {
      return
    }

    if currentPath.isEmpty {
      var itemToUpdate = group.actions[index]
      update(&itemToUpdate)
      group.actions[index] = itemToUpdate
    } else {
      guard case .group(var subgroup) = group.actions[index] else {
        return
      }
      modifyItem(in: &subgroup, at: currentPath, update: update)
      group.actions[index] = .group(subgroup)
    }
  }

  private func insert(item: ActionOrGroup, at path: [Int]) {
    insertItemInGroup(item, in: &root, at: path)
  }

  private func insertItemInGroup(_ item: ActionOrGroup, in group: inout Group, at path: [Int]) {
    guard !path.isEmpty else {
      group.actions.append(item)
      return
    }

    var currentPath = path
    let index = currentPath.removeFirst()

    guard index >= 0 && index <= group.actions.count else {
      return
    }

    if currentPath.isEmpty {
      group.actions.insert(item, at: index)
    } else {
      guard index < group.actions.count,
        case .group(var subgroup) = group.actions[index]
      else {
        return
      }
      insertItemInGroup(item, in: &subgroup, at: currentPath)
      group.actions[index] = .group(subgroup)
    }
  }

  private func delete(at path: [Int]) {
    deleteItemFromGroup(in: &root, at: path)
  }

  private func deleteItemFromGroup(in group: inout Group, at path: [Int]) {
    guard !path.isEmpty else { return }

    if path.count == 1 {
      let index = path[0]
      guard index >= 0 && index < group.actions.count else { return }
      group.actions.remove(at: index)
      return
    }

    let index = path[0]
    guard index >= 0 && index < group.actions.count,
      case .group(var subgroup) = group.actions[index]
    else {
      return
    }

    deleteItemFromGroup(in: &subgroup, at: Array(path.dropFirst()))
    group.actions[index] = .group(subgroup)
  }

  private func validateAndCleanItem(_ item: ActionOrGroup, parentPath: [Int]) -> ActionOrGroup {
    var cleanedItem = item

    let existingKeys: [String]
    if parentPath.isEmpty {
      existingKeys = root.actions.compactMap { $0.item.key }
    } else if let parentItem = itemAtPath(parentPath),
      case .group(let parentGroup) = parentItem
    {
      existingKeys = parentGroup.actions.compactMap { $0.item.key }
    } else {
      existingKeys = []
    }

    switch cleanedItem {
    case .action(var action):
      if let key = action.key, existingKeys.contains(key) {
        action.key = generateUniqueKey(base: key, existingKeys: existingKeys)
      }
      cleanedItem = .action(action)
    case .group(var group):
      if let key = group.key, existingKeys.contains(key) {
        group.key = generateUniqueKey(base: key, existingKeys: existingKeys)
      }
      cleanedItem = .group(group)
    }

    return cleanedItem
  }

  private func generateUniqueKey(base: String, existingKeys: [String]) -> String {
    let baseKey = base.isEmpty ? "key" : base
    var counter = 1
    var newKey = baseKey

    while existingKeys.contains(newKey) {
      newKey = "\(baseKey)_\(counter)"
      counter += 1
    }

    return newKey
  }

  private func canApplyActionOnlyUpdate(previous: ActionOrGroup, updated: ActionOrGroup) -> Bool {
    guard case .action(let previousAction) = previous,
      case .action(let updatedAction) = updated
    else {
      return false
    }

    return previousAction.id == updatedAction.id
  }
}

struct NativeConfigEditorView: View {
  @ObservedObject var session: ConfigEditorSession

  var body: some View {
    HStack(spacing: 8) {
      ConfigOutlineView(session: session)
        .frame(minWidth: 420)

      Divider()

      ConfigInspectorView(session: session)
        .frame(minWidth: 340, idealWidth: 360, maxWidth: 420)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

final class OutlineNodeHandle: NSObject {
  let id: NodeID

  init(id: NodeID) {
    self.id = id
    super.init()
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? OutlineNodeHandle else { return false }
    return id == other.id
  }

  override var hash: Int {
    id.hashValue
  }
}

private struct ConfigInspectorView: View {
  @ObservedObject var session: ConfigEditorSession
  @State private var selectedNodeID: NodeID?
  @State private var keyValue: String = ""
  @State private var labelValue: String = ""
  @State private var descriptionValue: String = ""
  @State private var aiDescriptionValue: String = ""
  @State private var valueValue: String = ""
  @State private var isMenuEditorPresented: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Inspector")
        .font(.title3)
        .fontWeight(.semibold)

      if session.isInspectorNavigating, session.selectedTreeID != session.inspectorSelectedID {
        VStack(alignment: .leading, spacing: 8) {
          Label("Navigating…", systemImage: "arrow.up.arrow.down")
            .font(.headline)
          Text("Inspector updates when navigation settles.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      } else if let record = session.inspectorSelectedRecord {
        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
              Text(record.typeLabel.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(6)

              if record.isFromFallback {
                Text("Fallback")
                  .font(.caption)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.blue.opacity(0.12))
                  .cornerRadius(6)
              }

              if record.showsStickyMode {
                Text("SM")
                  .font(.caption)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.green.opacity(0.12))
                  .cornerRadius(6)
              }
            }

            if let validationError = session.selectedValidationError {
              HStack(spacing: 8) {
                Image(systemName: validationError.severity.iconName)
                  .foregroundColor(validationError.severity == .error ? .red : .orange)
                Text(validationError.message)
                  .font(.caption)
              }
              .padding(8)
              .background(Color.orange.opacity(0.08))
              .cornerRadius(8)
            }

            switch record.item {
            case .group(let group):
              groupEditor(group: group)
            case .action(let action):
              actionEditor(action: action)
            }
          }
          .padding(.vertical, 4)
        }
      } else {
        VStack(alignment: .leading, spacing: 8) {
          Text("Select an item")
            .font(.headline)
          Text("Choose a row in the tree to edit keys, labels, values, and options.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }

      Spacer(minLength: 0)

      HStack(spacing: 8) {
        Button {
          session.insertAction()
        } label: {
          Label("Add Action", systemImage: "plus")
        }

        Button {
          session.insertGroup()
        } label: {
          Label("Add Group", systemImage: "folder.badge.plus")
        }
      }
      .disabled(session.isInspectorNavigating)
    }
    .onAppear {
      syncLocalState()
    }
    .onChange(of: session.inspectorSelectedID) { _ in
      syncLocalState()
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
  }

  @ViewBuilder
  private func groupEditor(group: Group) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      TextField(
        "Group key",
        text: Binding(
          get: { keyValue },
          set: { newValue in
            keyValue = newValue
            var updated = group
            updated.key = newValue.isEmpty ? nil : newValue
            session.updateSelectedGroup(updated)
          }
        )
      )

      TextField(
        "Label",
        text: Binding(
          get: { labelValue },
          set: { newValue in
            labelValue = newValue
            var updated = group
            updated.label = newValue.isEmpty ? nil : newValue
            session.updateSelectedGroup(updated)
          }
        )
      )

      Toggle(
        "Sticky Mode",
        isOn: Binding(
          get: { group.stickyMode ?? false },
          set: { newValue in
            var updated = group
            updated.stickyMode = newValue
            session.updateSelectedGroup(updated)
          }
        )
      )
      .toggleStyle(.checkbox)

      if group.isFromFallback {
        Button("Make Editable") {
          session.makeSelectedEditable()
        }
      }

      HStack(spacing: 8) {
        Button("Copy") { session.copy(session.inspectorSelectedID) }
        Button("Paste") { session.paste(into: session.inspectorSelectedID) }
          .disabled(!ClipboardManager.shared.canPaste())
        Button("Duplicate") { session.duplicate(session.inspectorSelectedID) }
        Button("Delete", role: .destructive) { session.delete(session.inspectorSelectedID) }
      }
    }
  }

  @ViewBuilder
  private func actionEditor(action: Action) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      TextField(
        "Action key",
        text: Binding(
          get: { keyValue },
          set: { newValue in
            keyValue = newValue
            var updated = action
            updated.key = newValue.isEmpty ? nil : newValue
            session.updateSelectedAction(updated)
          }
        )
      )

      Picker(
        "Type",
        selection: Binding(
          get: { action.type },
          set: { newType in
            var updated = action
            if updated.type != newType {
              updated.type = newType
              updated.value = ""
              valueValue = ""
            }
            session.updateSelectedAction(updated)
          }
        )
      ) {
        Text("Shortcut").tag(Type.shortcut)
        Text("Application").tag(Type.application)
        Text("URL").tag(Type.url)
        Text("Command").tag(Type.command)
        Text("Folder").tag(Type.folder)
        Text("Type Text").tag(Type.text)
        Text("Menu").tag(Type.menu)
        Text("IntelliJ").tag(Type.intellij)
        Text("Keystroke").tag(Type.keystroke)
        Text("Toggle Sticky Mode").tag(Type.toggleStickyMode)
        Text("Normal Mode Enable").tag(Type.normalModeEnable)
        Text("Normal Mode Input").tag(Type.normalModeInput)
        Text("Normal Mode Disable").tag(Type.normalModeDisable)
        Text("Macro").tag(Type.macro)
      }

      valueEditor(action: action)

      TextField(
        "Description",
        text: Binding(
          get: { descriptionValue },
          set: { newValue in
            descriptionValue = newValue
            var updated = action
            updated.description = newValue.isEmpty ? nil : newValue
            session.updateSelectedAction(updated)
          }
        )
      )

      TextField(
        "AI Description",
        text: Binding(
          get: { aiDescriptionValue },
          set: { newValue in
            aiDescriptionValue = newValue
            var updated = action
            updated.aiDescription = newValue.isEmpty ? nil : newValue
            session.updateSelectedAction(updated)
          }
        )
      )

      if action.isFromFallback {
        Button("Make Editable") {
          session.makeSelectedEditable()
        }
      }

      if !action.type.isModeControlAction {
        Toggle(
          "Sticky Mode",
          isOn: Binding(
            get: { action.stickyMode ?? false },
            set: { newValue in
              var updated = action
              updated.stickyMode = newValue
              session.updateSelectedAction(updated)
            }
          )
        )
        .toggleStyle(.checkbox)
      }

      if !action.type.isModeControlAction {
        Picker(
          "Normal Mode After",
          selection: Binding(
            get: { action.normalModeAfter ?? .normal },
            set: { newValue in
              var updated = action
              updated.normalModeAfter = newValue == .normal ? nil : newValue
              session.updateSelectedAction(updated)
            }
          )
        ) {
          Text("Normal").tag(NormalModeAfter.normal)
          Text("Input").tag(NormalModeAfter.input)
          Text("Disabled").tag(NormalModeAfter.disabled)
        }
      }

      HStack(spacing: 8) {
        Button("Copy") { session.copy(session.inspectorSelectedID) }
        Button("Paste") { session.paste(into: session.inspectorSelectedID) }
          .disabled(!ClipboardManager.shared.canPaste())
        Button("Duplicate") { session.duplicate(session.inspectorSelectedID) }
        Button("Delete", role: .destructive) { session.delete(session.inspectorSelectedID) }
      }
    }
  }

  @ViewBuilder
  private func valueEditor(action: Action) -> some View {
    switch action.type {
    case .application:
      HStack(spacing: 8) {
        Button("Choose App…") {
          let panel = NSOpenPanel()
          panel.allowedContentTypes = [.applicationBundle, .application]
          panel.canChooseFiles = true
          panel.canChooseDirectories = true
          panel.allowsMultipleSelection = false
          panel.directoryURL = URL(fileURLWithPath: "/Applications")

          if panel.runModal() == .OK {
            let newValue = panel.url?.path ?? ""
            valueValue = newValue
            var updated = action
            updated.value = newValue
            session.updateSelectedAction(updated)
          }
        }
        Text(action.value)
          .lineLimit(1)
          .truncationMode(.middle)
      }
    case .folder:
      HStack(spacing: 8) {
        Button("Choose Folder…") {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = true
          panel.canChooseFiles = false
          panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser

          if panel.runModal() == .OK {
            let newValue = panel.url?.path ?? ""
            valueValue = newValue
            var updated = action
            updated.value = newValue
            session.updateSelectedAction(updated)
          }
        }
        Text(action.value)
          .lineLimit(1)
          .truncationMode(.middle)
      }
    case .toggleStickyMode, .normalModeEnable, .normalModeInput, .normalModeDisable:
      Text("No value required")
        .font(.caption)
        .foregroundColor(.secondary)
    case .menu:
      HStack(spacing: 8) {
        Button {
          isMenuEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "filemenu.and.selection")
            Text(
              action.value.isEmpty
                ? "Edit menu…"
                : (action.value.count > 30
                  ? "\(action.value.prefix(30))…" : action.value))
          }
        }
        .sheet(isPresented: $isMenuEditorPresented) {
          MenuActionEditor(
            value: Binding(
              get: { valueValue },
              set: { newValue in
                valueValue = newValue
                var updated = action
                updated.value = newValue
                session.updateSelectedAction(updated)
              }
            ),
            isPresented: $isMenuEditorPresented,
            onSave: {}
          )
        }
      }
    case .intellij:
      VStack(alignment: .leading, spacing: 6) {
        TextEditor(
          text: Binding(
            get: { valueValue },
            set: { newValue in
              valueValue = newValue
              var updated = action
              updated.value = newValue
              session.updateSelectedAction(updated)
            }
          )
        )
        .font(.system(.body, design: .monospaced))
        .frame(minHeight: 60)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        VStack(alignment: .leading, spacing: 2) {
          Text("Single action:  ReformatCode")
          Text("Multiple:  SaveAll,ReformatCode")
          Text("With delay (ms):  SaveAll,ReformatCode|100")
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundColor(.secondary)
      }
    case .keystroke:
      KeystrokeValueEditor(value: Binding(
        get: { valueValue },
        set: { newValue in
          valueValue = newValue
          var updated = action
          updated.value = newValue
          session.updateSelectedAction(updated)
        }
      ))
    case .macro:
      MacroEditorView(action: selectedActionBinding(fallback: action), path: session.path(for: action.id) ?? [])
    default:
      TextEditor(
        text: Binding(
          get: { valueValue },
          set: { newValue in
            valueValue = newValue
            var updated = action
            updated.value = newValue
            session.updateSelectedAction(updated)
          }
        )
      )
      .font(.system(.body, design: .monospaced))
      .frame(minHeight: 100)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray.opacity(0.2), lineWidth: 1)
      )
    }
  }

  private func selectedActionBinding(fallback: Action) -> Binding<Action> {
    Binding(
      get: {
        if let item = session.inspectorSelectedItem,
          case .action(let action) = item
        {
          return action
        }
        return fallback
      },
      set: { newValue in
        session.updateSelectedAction(newValue)
      }
    )
  }

  private func syncLocalState() {
    guard let selected = session.inspectorSelectedID,
      selectedNodeID != selected,
      let record = session.inspectorSelectedRecord
    else {
      if session.inspectorSelectedID == nil {
        selectedNodeID = nil
        keyValue = ""
        labelValue = ""
        descriptionValue = ""
        aiDescriptionValue = ""
        valueValue = ""
      }
      return
    }

    selectedNodeID = selected
    switch record.item {
    case .group(let group):
      keyValue = group.key ?? ""
      labelValue = group.label ?? ""
      descriptionValue = ""
      aiDescriptionValue = ""
      valueValue = ""
    case .action(let action):
      keyValue = action.key ?? ""
      labelValue = ""
      descriptionValue = action.description ?? ""
      aiDescriptionValue = action.aiDescription ?? ""
      valueValue = action.value
    }
  }
}

struct ConfigOutlineView: NSViewRepresentable {
  @ObservedObject var session: ConfigEditorSession

  func makeCoordinator() -> ConfigOutlineCoordinator {
    ConfigOutlineCoordinator(session: session)
  }

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true

    let outlineView = NativeConfigOutlineNativeView(frame: .zero)
    outlineView.headerView = nil
    outlineView.rowHeight = 26
    outlineView.usesAlternatingRowBackgroundColors = false
    outlineView.selectionHighlightStyle = .regular
    outlineView.focusRingType = .none
    outlineView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle

    let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ConfigTreeColumn"))
    column.title = "Config"
    column.resizingMask = .autoresizingMask
    outlineView.addTableColumn(column)
    outlineView.outlineTableColumn = column

    outlineView.delegate = context.coordinator
    outlineView.dataSource = context.coordinator
    outlineView.commandHandler = { [weak coordinator = context.coordinator] command in
      coordinator?.handle(command)
    }

    outlineView.menu = context.coordinator.makeMenu()

    context.coordinator.outlineView = outlineView
    scrollView.documentView = outlineView
    context.coordinator.attach(scrollView: scrollView)

    context.coordinator.resetSyncState()
    context.coordinator.rebuildHandleCache()
    context.coordinator.lastStructureVersion = session.structureVersion
    outlineView.reloadData()
    context.coordinator.applyExpandedStateIfNeeded(force: true)
    context.coordinator.applySelectionStateIfNeeded(force: true)
    context.coordinator.refreshVisibleRows()
    context.coordinator.lastDisplayVersion = session.displayVersion

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    context.coordinator.session = session

    guard let outlineView = context.coordinator.outlineView else { return }

    if context.coordinator.lastStructureVersion != session.structureVersion {
      context.coordinator.lastStructureVersion = session.structureVersion
      context.coordinator.resetSyncState()
      context.coordinator.rebuildHandleCache()
      outlineView.reloadData()
      context.coordinator.applyExpandedStateIfNeeded(force: true)
      context.coordinator.applySelectionStateIfNeeded(force: true)
      context.coordinator.refreshVisibleRows()
      context.coordinator.lastDisplayVersion = session.displayVersion
      return
    }

    context.coordinator.applyExpandedStateIfNeeded()
    context.coordinator.applySelectionStateIfNeeded()
    if context.coordinator.lastDisplayVersion != session.displayVersion {
      if context.coordinator.isLiveScrolling {
        context.coordinator.deferVisibleRowsRefresh()
      } else {
        context.coordinator.refreshVisibleRows()
      }
      context.coordinator.lastDisplayVersion = session.displayVersion
    }
  }
}

final class ConfigOutlineCoordinator: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
  var session: ConfigEditorSession
  weak var outlineView: NativeConfigOutlineNativeView?
  var lastStructureVersion: Int = -1
  var lastDisplayVersion: Int = -1
  private var isApplyingSelection = false
  private var isApplyingExpansion = false
  private var lastAppliedExpansionVersion: Int = -1
  private var lastAppliedExpandedIDs: Set<NodeID> = []
  private var lastAppliedSelectionID: NodeID?
  private var handleCache: [NodeID: OutlineNodeHandle] = [:]
  private var pendingSelection: (nodeID: NodeID?, source: ConfigEditorSession.SelectionSource)?
  private var pendingSelectionWorkItem: DispatchWorkItem?
  private let keyboardRepeatCoalesceDelay: TimeInterval = 0.008
  private let scrollCoalesceDelay: TimeInterval = 0.016
  private var pendingScrollBaseGeneration: UInt64?
  private var selectionPublishGeneration: UInt64 = 0
  private weak var observedScrollView: NSScrollView?
  private(set) var isLiveScrolling = false
  private var needsVisibleRowsRefreshAfterLiveScroll = false

  init(session: ConfigEditorSession) {
    self.session = session
  }

  deinit {
    if let observedScrollView {
      NotificationCenter.default.removeObserver(
        self, name: NSScrollView.willStartLiveScrollNotification, object: observedScrollView)
      NotificationCenter.default.removeObserver(
        self, name: NSScrollView.didEndLiveScrollNotification, object: observedScrollView)
    }
  }

  func attach(scrollView: NSScrollView) {
    guard observedScrollView !== scrollView else { return }

    if let observedScrollView {
      NotificationCenter.default.removeObserver(
        self, name: NSScrollView.willStartLiveScrollNotification, object: observedScrollView)
      NotificationCenter.default.removeObserver(
        self, name: NSScrollView.didEndLiveScrollNotification, object: observedScrollView)
    }

    observedScrollView = scrollView
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleWillStartLiveScroll),
      name: NSScrollView.willStartLiveScrollNotification,
      object: scrollView
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidEndLiveScroll),
      name: NSScrollView.didEndLiveScrollNotification,
      object: scrollView
    )
  }

  func deferVisibleRowsRefresh() {
    needsVisibleRowsRefreshAfterLiveScroll = true
  }

  @objc private func handleWillStartLiveScroll(_ notification: Notification) {
    guard notification.object as AnyObject? === observedScrollView else { return }
    isLiveScrolling = true

    if pendingSelection?.source == .scroll, pendingSelectionWorkItem != nil {
      pendingSelectionWorkItem?.cancel()
      pendingSelectionWorkItem = nil
    }
  }

  @objc private func handleDidEndLiveScroll(_ notification: Notification) {
    guard notification.object as AnyObject? === observedScrollView else { return }
    isLiveScrolling = false

    flushPendingSelectionIfNeeded(onlyScroll: true)

    if needsVisibleRowsRefreshAfterLiveScroll {
      refreshVisibleRows()
      needsVisibleRowsRefreshAfterLiveScroll = false
      lastDisplayVersion = session.displayVersion
    }
  }

  func makeMenu() -> NSMenu {
    let menu = NSMenu(title: "Config")
    menu.addItem(withTitle: "Copy", action: #selector(copySelected), keyEquivalent: "")
    menu.addItem(withTitle: "Paste", action: #selector(pasteIntoSelected), keyEquivalent: "")
    menu.addItem(.separator())
    menu.addItem(withTitle: "Add Action", action: #selector(addActionAfterSelected), keyEquivalent: "")
    menu.addItem(withTitle: "Add Group", action: #selector(addGroupAfterSelected), keyEquivalent: "")
    menu.addItem(.separator())
    menu.addItem(withTitle: "Duplicate", action: #selector(duplicateSelected), keyEquivalent: "")
    menu.addItem(withTitle: "Delete", action: #selector(deleteSelected), keyEquivalent: "")
    menu.items.forEach { $0.target = self }
    return menu
  }

  @objc private func copySelected() {
    session.copy(currentSelectedID())
  }

  @objc private func pasteIntoSelected() {
    session.paste(into: currentSelectedID())
  }

  @objc private func addActionAfterSelected() {
    session.insertAction(after: currentSelectedID())
  }

  @objc private func addGroupAfterSelected() {
    session.insertGroup(after: currentSelectedID())
  }

  @objc private func duplicateSelected() {
    session.duplicate(currentSelectedID())
  }

  @objc private func deleteSelected() {
    session.delete(currentSelectedID())
  }

  func handle(_ command: NativeConfigOutlineCommand) {
    switch command {
    case .collapse:
      if let id = currentSelectedID() {
        session.collapse(id)
      }
    case .expand:
      if let id = currentSelectedID() {
        session.expand(id)
      }
    case .copy:
      session.copy(currentSelectedID())
    case .paste:
      session.paste(into: currentSelectedID())
    case .duplicate:
      session.duplicate(currentSelectedID())
    case .delete:
      session.delete(currentSelectedID())
    case .addAction:
      session.insertAction(after: currentSelectedID())
    case .addGroup:
      session.insertGroup(after: currentSelectedID())
    case .edit:
      session.focusInspector()
    }
  }

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if item == nil {
      return session.rootChildren.count
    }

    guard let itemID = nodeID(from: item) else { return 0 }
    return session.childrenIndex[itemID]?.count ?? 0
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    let childID: NodeID
    if item == nil {
      childID = session.rootChildren[index]
    } else if let itemID = nodeID(from: item),
      let children = session.childrenIndex[itemID],
      index < children.count
    {
      childID = children[index]
    } else {
      return handle(for: session.rootID)
    }

    return handle(for: childID)
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    guard let itemID = nodeID(from: item),
      let record = session.nodeIndex[itemID],
      record.isGroup
    else {
      return false
    }

    return !(session.childrenIndex[itemID]?.isEmpty ?? true)
  }

  func outlineView(
    _ outlineView: NSOutlineView,
    viewFor tableColumn: NSTableColumn?,
    item: Any
  ) -> NSView? {
    guard let itemID = nodeID(from: item),
      let record = session.nodeIndex[itemID]
    else {
      return nil
    }

    let identifier = NSUserInterfaceItemIdentifier("ConfigOutlineCell")
    let cellView =
      (outlineView.makeView(withIdentifier: identifier, owner: self) as? ConfigOutlineCellView)
      ?? ConfigOutlineCellView(frame: .zero)
    cellView.identifier = identifier
    cellView.configure(record: record, validationError: session.validationByNodeID[itemID])
    return cellView
  }

  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard !isApplyingSelection,
      let outlineView
    else { return }

    let source = outlineView.consumeSelectionSource() ?? .programmatic
    let signpostState = ConfigOutlinePerfMetrics.beginSelectionEvent(source: source)
    defer { ConfigOutlinePerfMetrics.endSelectionEvent(signpostState) }

    let row = outlineView.selectedRow
    guard row >= 0,
      let item = outlineView.item(atRow: row)
    else {
      publishSelection(nil, source: source, coalesced: false)
      return
    }

    let selectedID = nodeID(from: item)

    switch source {
    case .keyboardRepeat:
      scheduleCoalescedSelection(
        nodeID: selectedID, source: source, delay: keyboardRepeatCoalesceDelay)
    case .scroll:
      scheduleCoalescedSelection(nodeID: selectedID, source: source, delay: scrollCoalesceDelay)
    case .keyboardTap, .mouse, .programmatic:
      publishSelection(selectedID, source: source, coalesced: false)
    }
  }

  private func publishSelection(
    _ nodeID: NodeID?,
    source: ConfigEditorSession.SelectionSource,
    coalesced: Bool
  ) {
    pendingSelectionWorkItem?.cancel()
    pendingSelectionWorkItem = nil
    pendingSelection = nil
    pendingScrollBaseGeneration = nil
    session.select(nodeID, source: source)
    lastAppliedSelectionID = nodeID
    selectionPublishGeneration &+= 1
    ConfigOutlinePerfMetrics.recordSelectionPublish(coalesced: coalesced)
  }

  private func scheduleCoalescedSelection(
    nodeID: NodeID?,
    source: ConfigEditorSession.SelectionSource,
    delay: TimeInterval
  ) {
    let previousPendingSource = pendingSelection?.source
    pendingSelection = (nodeID, source)

    if source == .scroll {
      pendingScrollBaseGeneration = selectionPublishGeneration
    }

    if source == .scroll, isLiveScrolling {
      pendingSelectionWorkItem?.cancel()
      pendingSelectionWorkItem = nil
      return
    }

    if previousPendingSource != source {
      pendingSelectionWorkItem?.cancel()
      pendingSelectionWorkItem = nil
    }

    guard pendingSelectionWorkItem == nil else { return }

    let workItem = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.pendingSelectionWorkItem = nil
      self.flushPendingSelectionIfNeeded(onlyScroll: false)
    }

    pendingSelectionWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  private func flushPendingSelectionIfNeeded(onlyScroll: Bool) {
    guard let pending = pendingSelection else { return }

    if onlyScroll, pending.source != .scroll {
      return
    }

    if pending.source == .scroll {
      let baseGeneration = pendingScrollBaseGeneration ?? selectionPublishGeneration
      if selectionPublishGeneration > baseGeneration {
        pendingSelection = nil
        pendingSelectionWorkItem?.cancel()
        pendingSelectionWorkItem = nil
        pendingScrollBaseGeneration = nil
        return
      }
    }

    publishSelection(pending.nodeID, source: pending.source, coalesced: true)
  }

  func outlineViewItemDidExpand(_ notification: Notification) {
    guard !isApplyingExpansion else { return }
    guard let item = notification.userInfo?["NSObject"] else { return }
    if let nodeID = nodeID(from: item) {
      session.expand(nodeID)
      lastAppliedExpandedIDs.insert(nodeID)
      lastAppliedExpansionVersion = session.expansionVersion
    }
  }

  func outlineViewItemDidCollapse(_ notification: Notification) {
    guard !isApplyingExpansion else { return }
    guard let item = notification.userInfo?["NSObject"] else { return }
    if let nodeID = nodeID(from: item) {
      session.collapse(nodeID)
      lastAppliedExpandedIDs.remove(nodeID)
      lastAppliedExpansionVersion = session.expansionVersion
    }
  }

  func resetSyncState() {
    pendingSelectionWorkItem?.cancel()
    pendingSelectionWorkItem = nil
    pendingSelection = nil
    pendingScrollBaseGeneration = nil
    lastAppliedExpansionVersion = -1
    lastAppliedExpandedIDs.removeAll()
    lastAppliedSelectionID = nil
    lastDisplayVersion = -1
  }

  func rebuildHandleCache() {
    let validIDs = Set(session.nodeIndex.keys)
    handleCache = handleCache.filter { validIDs.contains($0.key) }
    for nodeID in validIDs where handleCache[nodeID] == nil {
      handleCache[nodeID] = OutlineNodeHandle(id: nodeID)
    }
  }

  func applyExpandedStateIfNeeded(force: Bool = false) {
    guard force || lastAppliedExpansionVersion != session.expansionVersion else { return }
    applyExpandedState()
    lastAppliedExpansionVersion = session.expansionVersion
  }

  func applyExpandedState() {
    guard let outlineView else { return }

    let desired = session.expanded.intersection(Set(session.nodeIndex.keys))
    let toExpand = desired.subtracting(lastAppliedExpandedIDs)
      .sorted { depth(for: $0) < depth(for: $1) }
    let toCollapse = lastAppliedExpandedIDs.subtracting(desired)
      .sorted { depth(for: $0) > depth(for: $1) }

    guard !toExpand.isEmpty || !toCollapse.isEmpty else {
      lastAppliedExpandedIDs = desired
      return
    }

    isApplyingExpansion = true
    defer {
      isApplyingExpansion = false
      lastAppliedExpandedIDs = desired
    }

    for nodeID in toCollapse {
      outlineView.collapseItem(handle(for: nodeID))
    }

    for nodeID in toExpand {
      outlineView.expandItem(handle(for: nodeID))
    }
  }

  func applySelectionStateIfNeeded(force: Bool = false) {
    guard force || lastAppliedSelectionID != session.selectedTreeID else { return }
    applySelectionState()
    lastAppliedSelectionID = session.selectedTreeID
  }

  func applySelectionState() {
    guard let outlineView else { return }

    guard let selectedID = session.selectedTreeID,
      selectedID != session.rootID
    else {
      isApplyingSelection = true
      outlineView.deselectAll(nil)
      isApplyingSelection = false
      return
    }

    let item = handle(for: selectedID)
    let row = outlineView.row(forItem: item)
    guard row >= 0 else { return }

    if outlineView.selectedRow != row {
      isApplyingSelection = true
      outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
      outlineView.scrollRowToVisible(row)
      isApplyingSelection = false
    }
  }

  private func depth(for nodeID: NodeID) -> Int {
    session.nodeIndex[nodeID]?.depth ?? 0
  }

  func refreshVisibleRows() {
    guard let outlineView else { return }

    let visibleRows = outlineView.rows(in: outlineView.visibleRect)
    guard visibleRows.length > 0 else { return }

    let upperBound = min(NSMaxRange(visibleRows), outlineView.numberOfRows)
    guard visibleRows.location < upperBound else { return }

    for row in visibleRows.location..<upperBound {
      guard let item = outlineView.item(atRow: row),
        let itemID = nodeID(from: item),
        let record = session.nodeIndex[itemID]
      else { continue }

      let view = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false)
      if let cellView = view as? ConfigOutlineCellView {
        cellView.configure(record: record, validationError: session.validationByNodeID[itemID])
      }
    }
  }

  private func currentSelectedID() -> NodeID? {
    if let selected = session.selectedTreeID {
      return selected
    }

    guard let outlineView else { return nil }
    let row = outlineView.clickedRow >= 0 ? outlineView.clickedRow : outlineView.selectedRow
    guard row >= 0,
      let item = outlineView.item(atRow: row)
    else {
      return nil
    }

    return nodeID(from: item)
  }

  private func nodeID(from item: Any?) -> NodeID? {
    if let handle = item as? OutlineNodeHandle {
      return handle.id
    }

    if let uuid = item as? UUID {
      return uuid
    }

    if let string = item as? NSString {
      return UUID(uuidString: string as String)
    }

    if let string = item as? String {
      return UUID(uuidString: string)
    }

    return nil
  }

  private func handle(for nodeID: NodeID) -> OutlineNodeHandle {
    if let cached = handleCache[nodeID] {
      return cached
    }

    let newHandle = OutlineNodeHandle(id: nodeID)
    handleCache[nodeID] = newHandle
    return newHandle
  }
}

enum NativeConfigOutlineCommand {
  case collapse
  case expand
  case copy
  case paste
  case duplicate
  case delete
  case addAction
  case addGroup
  case edit
}

final class NativeConfigOutlineNativeView: NSOutlineView {
  var commandHandler: ((NativeConfigOutlineCommand) -> Void)?
  private var pendingSelectionSource: ConfigEditorSession.SelectionSource?
  private var pendingSelectionSourceToken: UInt64 = 0

  func recordSelectionSource(_ source: ConfigEditorSession.SelectionSource) {
    pendingSelectionSource = source
    pendingSelectionSourceToken &+= 1
    let token = pendingSelectionSourceToken

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard self.pendingSelectionSourceToken == token else { return }
      self.pendingSelectionSource = nil
    }
  }

  func consumeSelectionSource() -> ConfigEditorSession.SelectionSource? {
    let source = pendingSelectionSource
    pendingSelectionSource = nil
    return source
  }

  override func keyDown(with event: NSEvent) {
    if event.keyCode == 125 || event.keyCode == 126 {
      if event.isARepeat {
        recordSelectionSource(.keyboardRepeat)
      } else {
        recordSelectionSource(.keyboardTap)
      }
    }

    let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""

    if flags.contains(.command) {
      if flags.contains(.shift), chars == "n" {
        commandHandler?(.addGroup)
        return
      }

      switch chars {
      case "c":
        commandHandler?(.copy)
        return
      case "v":
        commandHandler?(.paste)
        return
      case "d":
        commandHandler?(.duplicate)
        return
      case "n":
        commandHandler?(.addAction)
        return
      case "e", "\r":
        commandHandler?(.edit)
        return
      default:
        break
      }
    }

    switch event.keyCode {
    case 123:  // left
      commandHandler?(.collapse)
      return
    case 124:  // right
      commandHandler?(.expand)
      return
    case 51, 117:  // backspace/delete
      commandHandler?(.delete)
      return
    default:
      break
    }

    super.keyDown(with: event)
  }

  override func scrollWheel(with event: NSEvent) {
    recordSelectionSource(.scroll)
    super.scrollWheel(with: event)
  }

  override func mouseDown(with event: NSEvent) {
    recordSelectionSource(.mouse)
    super.mouseDown(with: event)
  }

  override func rightMouseDown(with event: NSEvent) {
    recordSelectionSource(.mouse)
    super.rightMouseDown(with: event)
  }

  override func otherMouseDown(with event: NSEvent) {
    recordSelectionSource(.mouse)
    super.otherMouseDown(with: event)
  }
}

final class ConfigOutlineCellView: NSTableCellView {
  private static let keyParagraphStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    style.lineBreakMode = .byTruncatingMiddle
    return style
  }()

  private static let typeParagraphStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    style.lineBreakMode = .byTruncatingTail
    return style
  }()

  private static let labelParagraphStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    style.lineBreakMode = .byTruncatingTail
    return style
  }()

  private static let flagsParagraphStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .right
    style.lineBreakMode = .byTruncatingHead
    return style
  }()

  private let keyFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
  private let typeFont = NSFont.systemFont(ofSize: 11, weight: .regular)
  private let labelFont = NSFont.systemFont(ofSize: 12, weight: .regular)
  private let flagsFont = NSFont.systemFont(ofSize: 11, weight: .semibold)
  private let textInset = NSEdgeInsets(top: 2, left: 4, bottom: 2, right: 6)
  private let keyColumnWidth: CGFloat = 116
  private let typeColumnWidth: CGFloat = 88
  private let flagsColumnWidth: CGFloat = 44

  private var renderedNodeID: NodeID?
  private var keyText = "—"
  private var typeText = ""
  private var labelText = ""
  private var flagsText = ""
  private var hasValidationError = false

  override var backgroundStyle: NSView.BackgroundStyle {
    didSet {
      if oldValue != backgroundStyle {
        needsDisplay = true
      }
    }
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(record: NodeRecord, validationError: ValidationError?) {
    let nextKeyText = record.displayKey.isEmpty ? "—" : record.displayKey
    let nextTypeText = record.typeLabel.capitalized
    let nextLabelText = record.displayLabel

    var flags: [String] = []
    if record.showsStickyMode {
      flags.append("SM")
    }
    if record.isFromFallback {
      flags.append("FB")
    }
    if validationError != nil {
      flags.append("!")
    }
    let nextFlagsText = flags.joined(separator: " ")
    let nextHasValidationError = validationError != nil

    if renderedNodeID == record.id,
      keyText == nextKeyText,
      typeText == nextTypeText,
      labelText == nextLabelText,
      flagsText == nextFlagsText,
      hasValidationError == nextHasValidationError
    {
      return
    }

    renderedNodeID = record.id
    keyText = nextKeyText
    typeText = nextTypeText
    labelText = nextLabelText
    flagsText = nextFlagsText
    hasValidationError = nextHasValidationError
    needsDisplay = true
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let contentRect = bounds.insetBy(dx: textInset.left, dy: textInset.top)
    let usableHeight = max(0, contentRect.height - textInset.bottom)
    guard usableHeight > 0 else { return }

    let baseRect = NSRect(
      x: contentRect.minX,
      y: contentRect.minY,
      width: max(0, contentRect.width - textInset.right),
      height: usableHeight
    )

    let flagsRect = NSRect(
      x: max(baseRect.minX, baseRect.maxX - flagsColumnWidth),
      y: baseRect.minY,
      width: min(flagsColumnWidth, baseRect.width),
      height: baseRect.height
    )
    let keyRect = NSRect(
      x: baseRect.minX,
      y: baseRect.minY,
      width: min(keyColumnWidth, max(0, baseRect.width * 0.26)),
      height: baseRect.height
    )
    let typeRect = NSRect(
      x: keyRect.maxX + 8,
      y: baseRect.minY,
      width: min(typeColumnWidth, max(0, baseRect.width * 0.18)),
      height: baseRect.height
    )
    let labelRect = NSRect(
      x: typeRect.maxX + 8,
      y: baseRect.minY,
      width: max(0, flagsRect.minX - (typeRect.maxX + 10)),
      height: baseRect.height
    )

    let isSelected = backgroundStyle == .emphasized
    let primaryColor = isSelected ? NSColor.selectedControlTextColor : NSColor.labelColor
    let secondaryColor = isSelected ? NSColor.selectedControlTextColor : NSColor.secondaryLabelColor
    let tertiaryColor = isSelected ? NSColor.selectedControlTextColor : NSColor.tertiaryLabelColor
    let keyColor = hasValidationError && !isSelected ? NSColor.systemOrange : primaryColor

    drawText(
      keyText,
      in: keyRect,
      font: keyFont,
      color: keyColor,
      paragraphStyle: Self.keyParagraphStyle
    )
    drawText(
      typeText,
      in: typeRect,
      font: typeFont,
      color: secondaryColor,
      paragraphStyle: Self.typeParagraphStyle
    )
    drawText(
      labelText,
      in: labelRect,
      font: labelFont,
      color: primaryColor,
      paragraphStyle: Self.labelParagraphStyle
    )
    drawText(
      flagsText,
      in: flagsRect,
      font: flagsFont,
      color: tertiaryColor,
      paragraphStyle: Self.flagsParagraphStyle
    )
  }

  private func drawText(
    _ text: String,
    in rect: NSRect,
    font: NSFont,
    color: NSColor,
    paragraphStyle: NSParagraphStyle
  ) {
    guard !text.isEmpty, rect.width > 2, rect.height > 2 else { return }

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraphStyle,
    ]

    (text as NSString).draw(
      with: rect,
      options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
      attributes: attributes
    )
  }
}
