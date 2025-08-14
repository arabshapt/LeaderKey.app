import Defaults
import SwiftUI
import SymbolPicker

struct KeyReference {
    static let keyCategories: [String: [String]] = [
        "Special Commands": ["vk_none", "release_modifiers", "delay:500", "keydown:left_command", "keyup:left_command", "keydown:left_shift", "keyup:left_shift", "keydown:left_option", "keyup:left_option", "keydown:left_control", "keyup:left_control", "keydown:right_command", "keyup:right_command", "keydown:right_shift", "keyup:right_shift", "keydown:right_option", "keyup:right_option", "keydown:right_control", "keyup:right_control"],
        "Letters": ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"],
        "Numbers": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
        "Arrows": ["left_arrow", "right_arrow", "up_arrow", "down_arrow"],
        "Function Keys": ["f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20"],
        "Special Keys": ["escape", "tab", "spacebar", "return_or_enter", "enter", "delete_or_backspace", "delete_forward", "home", "end", "page_up", "page_down", "help", "insert"],
        "Keypad": ["keypad_0", "keypad_1", "keypad_2", "keypad_3", "keypad_4", "keypad_5", "keypad_6", "keypad_7", "keypad_8", "keypad_9", "keypad_period", "keypad_enter", "keypad_plus", "keypad_minus", "keypad_multiply", "keypad_divide", "keypad_equal_sign", "keypad_clear", "keypad_num_lock"],
        "Modifiers": ["caps_lock", "left_control", "left_shift", "left_option", "left_command", "right_control", "right_shift", "right_option", "right_command", "fn"],
        "Symbols": ["grave_accent_and_tilde", "hyphen", "equal_sign", "open_bracket", "close_bracket", "backslash", "semicolon", "quote", "comma", "period", "slash"],
        "Media": ["volume_increment", "volume_decrement", "mute"],
        "Other": ["print_screen", "scroll_lock", "pause", "lang1", "lang2", "japanese_eisuu", "japanese_kana"]
    ]
    
    static func getKeyHelp(for key: String) -> String {
        switch key {
        case "vk_none":
            return "Release all modifier keys (Karabiner-compatible). Use in sequences like 'Ctab vk_none'"
        case "release_modifiers":
            return "Release all modifier keys. Use to prevent stuck modifiers after shortcuts"
        case let str where str.hasPrefix("delay:"):
            return "Wait for specified milliseconds (0-10000). Example: 'tab delay:500 tab' waits 500ms between tabs"
        case let str where str.hasPrefix("keydown:"):
            return "Hold down the specified key. Example: 'keydown:left_command tab tab keyup:left_command' for app switching"
        case let str where str.hasPrefix("keyup:"):
            return "Release a held key. Must be paired with a previous keydown command"
        default:
            return ""
        }
    }
}

// Helper function to recursively convert fallback items to app-specific
func convertNestedFallbacksToAppSpecific(_ items: [ActionOrGroup]) -> [ActionOrGroup] {
    return items.map { item in
        switch item {
        case .action(var action):
            // Only convert if this action is actually from fallback
            if action.isFromFallback {
                action.isFromFallback = false
                action.fallbackSource = nil
            }
            // Convert macro steps if any are from fallback
            if let macroSteps = action.macroSteps {
                action.macroSteps = macroSteps.map { step in
                    var newStep = step
                    if newStep.action.isFromFallback {
                        newStep.action.isFromFallback = false
                        newStep.action.fallbackSource = nil
                    }
                    return newStep
                }
            }
            return .action(action)
        case .group(var group):
            // Only convert if this group is actually from fallback
            if group.isFromFallback {
                group.isFromFallback = false
                group.fallbackSource = nil
            }
            // Recursively convert nested items (only fallback ones)
            group.actions = convertNestedFallbacksToAppSpecific(group.actions)
            return .group(group)
        }
    }
}

// Helper function to create a deep duplicate with a new UUID
func makeTrueDuplicate(item: ActionOrGroup) -> ActionOrGroup {
    switch item {
    case .action(let action):
        // Create a new Action instance, which will get a new UUID
        var newAction = Action(key: action.key, type: action.type, label: action.label, value: action.value, iconPath: action.iconPath, activates: action.activates, stickyMode: action.stickyMode, macroSteps: action.macroSteps)
        // Preserve metadata properties
        newAction.isFromFallback = action.isFromFallback
        newAction.fallbackSource = action.fallbackSource
        // Preserve macro step fallback metadata if any
        if let macroSteps = action.macroSteps {
            newAction.macroSteps = macroSteps.map { step in
                var newStep = step
                // Preserve fallback metadata for macro step actions
                newStep.action.isFromFallback = step.action.isFromFallback
                newStep.action.fallbackSource = step.action.fallbackSource
                return newStep
            }
        }
        return .action(newAction)
    case .group(let group):
        // Recursively duplicate actions within the group
        let newActions = group.actions.map { makeTrueDuplicate(item: $0) }
        // Create a new Group instance, which will get a new UUID
        var newGroup = Group(key: group.key, label: group.label, iconPath: group.iconPath, stickyMode: group.stickyMode, actions: newActions)
        // Preserve metadata properties
        newGroup.isFromFallback = group.isFromFallback
        newGroup.fallbackSource = group.fallbackSource
        return .group(newGroup)
    }
}

// Helper function to sort actions alphabetically for display
extension Array where Element == ActionOrGroup {
  func sortedAlphabetically() -> [ActionOrGroup] {
    return self.sorted { item1, item2 in
      let key1 = item1.item.key?.lowercased() ?? "zzz" // Treat nil/empty keys as last
      let key2 = item2.item.key?.lowercased() ?? "zzz"
      // Ensure empty/nil keys are always after non-empty keys
      if key1 == "zzz" && key2 != "zzz" { return false }
      if key1 != "zzz" && key2 == "zzz" { return true }
      return key1 < key2
    }
  }
}

let generalPadding: CGFloat = 8

struct AddButtons: View {
  let onAddAction: () -> Void
  let onAddGroup: () -> Void
  let onPaste: () -> Void
  @ObservedObject var clipboardManager = ClipboardManager.shared

  var body: some View {
    HStack(spacing: generalPadding) {
      Button(action: {
        print("[UI LOG] AddButtons: 'Add action' button TAPPED.")
        onAddAction()
      }) {
        Image(systemName: "rays")
        Text("Add action")
      }
      Button(action: {
        print("[UI LOG] AddButtons: 'Add group' button TAPPED.")
        onAddGroup()
      }) {
        Image(systemName: "folder")
        Text("Add group")
      }
      Button(action: {
        print("[UI LOG] AddButtons: 'Paste' button TAPPED.")
        onPaste()
      }) {
        Image(systemName: "doc.on.clipboard.fill")
        Text("Paste")
      }
      .disabled(!clipboardManager.canPaste())
      Spacer()
    }
  }
}

struct GroupContentView: View {
  @Binding var group: Group
  @EnvironmentObject var userConfig: UserConfig
  var isRoot: Bool = false
  var parentPath: [Int] = []
  @Binding var expandedGroups: Set<[Int]>
  @Default(.showFallbackItems) var showFallbackItems

  // Conditionally sort actions and show/hide fallback items
  var visibleActions: [ActionOrGroup] {
    let actionsToShow = userConfig.isActivelyEditing ? group.actions : group.actions.sortedAlphabetically()
    if showFallbackItems {
      return actionsToShow
    } else {
      return actionsToShow.filter { item in
        switch item {
        case .action(let action):
          return !action.isFromFallback
        case .group(let subgroup):
          return !subgroup.isFromFallback
        }
      }
    }
  }

  var body: some View {
    LazyVStack(spacing: generalPadding) {
      ForEach(Array(visibleActions.enumerated()), id: \.element.id) { _, item in
        // Find the original index in the unfiltered array
        if let originalIndex = group.actions.firstIndex(where: { $0.id == item.id }) {
          let currentPath = parentPath + [originalIndex]
          ActionOrGroupRow(
            item: Binding(
              get: {
                guard originalIndex < group.actions.count else { return item }
                return group.actions[originalIndex]
              },
              set: { newValue in
                guard originalIndex < group.actions.count else { return }
                group.actions[originalIndex] = newValue
              }
            ),
            path: currentPath,
            onDelete: {
              group.actions.removeAll { $0.id == item.id }
            },
            onDuplicate: {
              let duplicatedItemWithNewID = makeTrueDuplicate(item: item)
              if let sourceIndex = group.actions.firstIndex(where: { $0.id == item.id }),
                 sourceIndex >= 0 && sourceIndex < group.actions.count {
                let insertAtIndex = min(sourceIndex + 1, group.actions.count)
                group.actions.insert(duplicatedItemWithNewID, at: insertAtIndex)
              }
            },
            expandedGroups: $expandedGroups
          )
        }
      }

      AddButtons(
        onAddAction: {
          withAnimation {
            userConfig.isActivelyEditing = true // Mark as actively editing
            group.actions.append(
              .action(Action(key: "", type: .shortcut, value: "")))
          }
        },
        onAddGroup: {
          withAnimation {
            userConfig.isActivelyEditing = true // Mark as actively editing
            group.actions.append(.group(Group(key: "", stickyMode: nil, actions: [])))
          }
        },
        onPaste: {
          withAnimation {
            userConfig.pasteItem(at: parentPath + [group.actions.count])
          }
        }
      )
      .padding(.top, generalPadding * 0.5)
    }
  }
}

struct ConfigEditorView: View {
  @Binding var group: Group
  @EnvironmentObject var userConfig: UserConfig
  var isRoot: Bool = true
  @Binding var expandedGroups: Set<[Int]>

  var body: some View {
    ScrollView {
      GroupContentView(
        group: $group, isRoot: isRoot, parentPath: [], expandedGroups: $expandedGroups
      )
      .padding(
        EdgeInsets(
          top: generalPadding, leading: generalPadding,
          bottom: generalPadding, trailing: 0))
    }
  }
}

struct ActionOrGroupRow: View {
  @Binding var item: ActionOrGroup
  var path: [Int]
  let onDelete: () -> Void
  let onDuplicate: () -> Void
  @EnvironmentObject var userConfig: UserConfig
  @Binding var expandedGroups: Set<[Int]>
  @ObservedObject var clipboardManager = ClipboardManager.shared

  var body: some View {
    SwiftUI.Group {
      switch item {
      case .action(let action):
        ActionRow(
          action: Binding(
            get: { action },
            set: { newAction in
              item = .action(newAction)
            }
          ),
          path: path,
          onDelete: onDelete,
          onDuplicate: onDuplicate
        )
      case .group(let group):
        GroupRow(
          group: Binding(
            get: { group },
            set: { newGroup in
              item = .group(newGroup)
            }
          ),
          path: path,
          expandedGroups: $expandedGroups,
          onDelete: onDelete,
          onDuplicate: onDuplicate
        )
      }
    }
    .contextMenu {
      Button("Copy") {
        ClipboardManager.shared.copyItem(item, fromConfig: userConfig.selectedConfigKeyForEditing)
      }

      Button("Paste") {
        userConfig.pasteItem(at: path)
      }
      .disabled(!clipboardManager.canPaste())

      Divider()

      Button("Duplicate") {
        onDuplicate()
      }

      Button("Delete") {
        onDelete()
      }
    }
  }
}

struct IconPickerMenu: View {
  @Binding var item: ActionOrGroup
  @State private var iconPickerPresented = false

  var body: some View {
    Menu {
      Button("App Icon") {
        DispatchQueue.main.async {
          let panel = NSOpenPanel()
          panel.allowedContentTypes = [.applicationBundle, .application]
          panel.canChooseFiles = true
          panel.canChooseDirectories = true
          panel.allowsMultipleSelection = false
          panel.directoryURL = URL(fileURLWithPath: "/Applications")
          if panel.runModal() == .OK {
            switch item {
            case .action(var action):
              action.iconPath = panel.url?.path
              item = .action(action)
            case .group(var group):
              group.iconPath = panel.url?.path
              item = .group(group)
            }
          }
        }
      }
      Button("Symbol") {
        iconPickerPresented = true
      }
      Divider()
      Button("✕ Clear") {
        switch item {
        case .action(var action):
          action.iconPath = nil
          item = .action(action)
        case .group(var group):
          group.iconPath = nil
          item = .group(group)
        }
      }
    } label: {
      actionIcon(item: item, iconSize: NSSize(width: 24, height: 24))
    }
    .buttonStyle(PlainButtonStyle())
    .sheet(isPresented: $iconPickerPresented) {
      switch item {
      case .action(var action):
        SymbolPicker(
          symbol: Binding(
            get: { action.iconPath },
            set: { newPath in
              action.iconPath = newPath
              item = .action(action)
            }
          ))
      case .group(var group):
        SymbolPicker(
          symbol: Binding(
            get: { group.iconPath },
            set: { newPath in
              group.iconPath = newPath
              item = .group(group)
            }
          ))
      }
    }
  }
}

struct ActionRowState {
  var keyInputValue: String
  var valueInputValue: String
  var labelInputValue: String
  var isListening: Bool
  var wasPreviouslyListening: Bool
  var selectedType: Type
  var isShortcutEditorPresented: Bool
  var isTextEditorPresented: Bool
  var isUrlEditorPresented: Bool
  var isCommandEditorPresented: Bool
  var showingKeyReference: Bool

  var isAnyEditorPresented: Bool {
    isShortcutEditorPresented || isTextEditorPresented || isUrlEditorPresented || isCommandEditorPresented
  }

  init() {
    self.keyInputValue = ""
    self.valueInputValue = ""
    self.labelInputValue = ""
    self.isListening = false
    self.wasPreviouslyListening = false
    self.selectedType = .shortcut
    self.isShortcutEditorPresented = false
    self.isTextEditorPresented = false
    self.isUrlEditorPresented = false
    self.isCommandEditorPresented = false
    self.showingKeyReference = false
  }
}

struct ActionRow: View {
  @Binding var action: Action
  var path: [Int]
  let onDelete: () -> Void
  let onDuplicate: () -> Void
  @FocusState private var isKeyFocused: Bool
  @EnvironmentObject var userConfig: UserConfig

  @State private var state = ActionRowState()

  var body: some View {
    // Add bounds checking to prevent crash
    guard !path.isEmpty && path.allSatisfy({ $0 >= 0 }) else {
      return AnyView(Text("Invalid path: empty or negative indices").foregroundColor(.red))
    }

    return AnyView(
    HStack(spacing: generalPadding) {
      KeyButton(
        text: $state.keyInputValue,
        placeholder: "Key",
        validationError: validationErrorForKey,
        path: path,
        onKeyChanged: { keyButtonPath, capturedKey in
          state.keyInputValue = capturedKey
          userConfig.updateKey(at: keyButtonPath, newKey: capturedKey)
        },
        showFallbackIndicator: action.isFromFallback
      )
      .onChange(of: state.isListening) { isNowListening in
          if state.wasPreviouslyListening && !isNowListening {
              let modelKey = action.key ?? ""
              if state.keyInputValue != modelKey {
                  userConfig.updateKey(at: path, newKey: state.keyInputValue)
              }
          }
          state.wasPreviouslyListening = isNowListening
      }
      // Add onChange for the local selectedType state
      .onChange(of: state.selectedType) { newTypeValue in
        let oldModelType = action.type
        userConfig.updateActionType(at: path, newType: newTypeValue)

        if action.type != oldModelType {
            state.valueInputValue = ""
        }
      }

      Picker("Type", selection: $state.selectedType) {
        Text("Shortcut").tag(Type.shortcut)
        Text("Application").tag(Type.application)
        Text("URL").tag(Type.url)
        Text("Command").tag(Type.command)
        Text("Folder").tag(Type.folder)
        Text("Type Text").tag(Type.text)
        Text("Toggle Sticky Mode").tag(Type.toggleStickyMode)
        Text("Macro").tag(Type.macro)
      }
      .frame(width: 110)
      .labelsHidden()

      IconPickerMenu(
        item: Binding(
          get: { .action(action) },
          set: { newItem in
            if case .action(let newAction) = newItem {
              action = newAction
            }
          }
        ))

      switch action.type {
      case .application:
        Button("Choose…") {
          DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.applicationBundle, .application]
            panel.canChooseFiles = true
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            panel.directoryURL = URL(fileURLWithPath: "/Applications")

            if panel.runModal() == .OK {
              action.value = panel.url?.path ?? ""
            }
          }
        }
        Text(action.value).truncationMode(.middle).lineLimit(1)
      case .folder:
        Button("Choose…") {
          DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser

            if panel.runModal() == .OK {
              action.value = panel.url?.path ?? ""
            }
          }
        }
        Text(action.value).truncationMode(.middle).lineLimit(1)
      case .shortcut:
        Button {
          state.isShortcutEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "keyboard")
            Text(state.valueInputValue.isEmpty ? "Set shortcut…" : (state.valueInputValue.count > 25 ? "\(state.valueInputValue.prefix(25))…" : state.valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $state.isShortcutEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit Shortcut")
              .font(.title2)
            TextEditor(text: $state.valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 120)
              .border(Color.gray.opacity(0.2))
            Text("Use letters for modifiers before the key: C=⌘, S=⇧, O=⌥, T=⌃. Example: CSb means ⌘⇧B.")
              .font(.footnote)
              .foregroundColor(.secondary)

            DisclosureGroup("Key Reference", isExpanded: $state.showingKeyReference) {
              ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                  ForEach(KeyReference.keyCategories.keys.sorted(), id: \.self) { category in
                    VStack(alignment: .leading, spacing: 4) {
                      Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)

                      let columns = [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                      ]
                      
                      LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(KeyReference.keyCategories[category] ?? [], id: \.self) { key in
                          Text(key)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        }
                      }
                    }
                  }
                }
                .padding(.top, 8)
              }
              .frame(maxHeight: 200)
            }
            .font(.footnote)
            HStack {
              Spacer()
              Button("Cancel") {
                // Revert local changes
                state.valueInputValue = action.value
                state.isShortcutEditorPresented = false
              }
              Button("Save") {
                action.value = state.valueInputValue
                state.isShortcutEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 380)
        }
      case .url:
        Button {
          state.isUrlEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "link")
            Text(state.valueInputValue.isEmpty ? "Edit URL…" : (state.valueInputValue.count > 30 ? "\(state.valueInputValue.prefix(30))…" : state.valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $state.isUrlEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit URL")
              .font(.title2)
            TextEditor(text: $state.valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 120)
              .border(Color.gray.opacity(0.2))
            Toggle("Activate after open", isOn: Binding(
              get: { action.activates ?? true },
              set: { action.activates = $0 }
            ))
            .toggleStyle(.checkbox)
            HStack {
              Spacer()
              Button("Cancel") {
                state.valueInputValue = action.value
                state.isUrlEditorPresented = false
              }
              Button("Save") {
                action.value = state.valueInputValue
                state.isUrlEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 420)
        }
      case .text:
        Button {
          state.isTextEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "square.and.pencil")
            Text(state.valueInputValue.isEmpty ? "Edit text…" : (state.valueInputValue.count > 20 ? "\(state.valueInputValue.prefix(20))…" : state.valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $state.isTextEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit Text to Type")
              .font(.title2)
            TextEditor(text: $state.valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 180)
              .border(Color.gray.opacity(0.2))
            HStack {
              Spacer()
              Button("Cancel") {
                state.valueInputValue = action.value
                state.isTextEditorPresented = false
              }
              Button("Save") {
                action.value = state.valueInputValue
                state.isTextEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 480, height: 300)
        }
      case .toggleStickyMode:
        Text("No value required")
          .foregroundColor(.secondary)
          .font(.caption)
      case .macro:
        MacroEditorView(action: $action, path: path)
      default:
        Button {
          state.isCommandEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "terminal")
            Text(state.valueInputValue.isEmpty ? "Edit command…" : (state.valueInputValue.count > 30 ? "\(state.valueInputValue.prefix(30))…" : state.valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $state.isCommandEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit Command")
              .font(.title2)
            TextEditor(text: $state.valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 120)
              .border(Color.gray.opacity(0.2))
            HStack {
              Spacer()
              Button("Cancel") {
                state.valueInputValue = action.value
                state.isCommandEditorPresented = false
              }
              Button("Save") {
                action.value = state.valueInputValue
                state.isCommandEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 420)
        }
      }

      // Add sticky mode checkbox for all action types except Toggle Sticky Mode
      if action.type != .toggleStickyMode {
        Toggle("SM", isOn: Binding(
          get: { action.stickyMode ?? false },
          set: { action.stickyMode = $0 }
        ))
        .toggleStyle(.checkbox)
        .frame(width: 40)
        .help("Sticky Mode: Keep window open after executing this action")
      }

      Spacer()

      HStack(spacing: 4) {
        TextField(action.bestGuessDisplayName, text: $state.labelInputValue, onCommit: {
          action.label = state.labelInputValue.isEmpty ? nil : state.labelInputValue
        })
        .frame(width: action.isFromFallback ? 70 : 120)

        if action.isFromFallback {
          HStack(spacing: 3) {
            Image(systemName: "arrow.down")
              .foregroundColor(.blue.opacity(0.6))
              .font(.system(size: 11, weight: .medium))
              .help("Inherited from \(action.fallbackSource ?? "Fallback App Config")")

            Button("Make Editable") {
              // Convert fallback item to app-specific item, including macro steps
              var newAction = action
              newAction.isFromFallback = false
              newAction.fallbackSource = nil
              // Convert macro steps if any
              if let macroSteps = newAction.macroSteps {
                newAction.macroSteps = macroSteps.map { step in
                  var newStep = step
                  newStep.action.isFromFallback = false
                  newStep.action.fallbackSource = nil
                  return newStep
                }
              }
              userConfig.updateAction(at: path, newAction: newAction)
            }
            .font(.system(size: 9, weight: .medium))
            .buttonStyle(.bordered)
            .controlSize(.mini)
            .help("Create app-specific copy of this fallback item that you can modify")
          }
        }
      }
      .frame(width: 120)
      .padding(.trailing, generalPadding)

      Button(role: .none, action: {
        ClipboardManager.shared.copyItem(.action(action), fromConfig: userConfig.selectedConfigKeyForEditing)
      }) {
        Image(systemName: "doc.on.clipboard")
      }
      .buttonStyle(.plain)

      Button(role: .none, action: onDuplicate) {
        Image(systemName: "document.on.document")
      }
      .buttonStyle(.plain)

      Button(role: .destructive, action: onDelete) {
        Image(systemName: "trash")
      }
      .buttonStyle(.plain)
      .padding(.trailing, generalPadding)
    }
    .background(
      action.isFromFallback ? 
        Color.blue.opacity(0.05) : 
        Color.clear
    )
    .cornerRadius(action.isFromFallback ? 4 : 0)
    .onAppear {
      state.keyInputValue = action.key ?? ""
      state.valueInputValue = action.value
      if action.label == nil {
        let guessedLabel = action.bestGuessDisplayName
        state.labelInputValue = guessedLabel
      } else {
        state.labelInputValue = action.label ?? ""
      }
      state.selectedType = action.type
    }
    // Consolidated onChange handler for better performance
    .onChange(of: state.valueInputValue) { newValue in
        if !state.isAnyEditorPresented && action.value != newValue {
            action.value = newValue
        }
    }
    .onChange(of: state.labelInputValue) { newValue in
        let effectiveNewLabel = newValue.isEmpty ? nil : newValue
        if action.label != effectiveNewLabel {
            action.label = effectiveNewLabel
        }
    }
    ) // Close AnyView
  }

  private var validationErrorForKey: ValidationError? {
    guard !path.isEmpty else { return nil }

    // Find validation errors for this item
    let errors = userConfig.validationErrors.filter { error in
      error.path == path
    }

    return errors.first
  }
}

struct GroupRow: View {
  @Binding var group: Group
  var path: [Int]
  @Binding var expandedGroups: Set<[Int]>
  @FocusState private var isKeyFocused: Bool
  let onDelete: () -> Void
  let onDuplicate: () -> Void
  @EnvironmentObject var userConfig: UserConfig

  @State private var keyInputValue: String = ""
  @State private var labelInputValue: String = ""
  @State private var isListening: Bool = false
  @State private var wasPreviouslyListening: Bool = false

  private var isExpanded: Bool {
    expandedGroups.contains(path)
  }

  private func toggleExpanded() {
    if isExpanded {
      expandedGroups.remove(path)
    } else {
      expandedGroups.insert(path)
    }
  }

  var body: some View {
    VStack(spacing: generalPadding) {
      HStack(spacing: generalPadding) {

        KeyButton(
          text: $keyInputValue,
          placeholder: "Group Key",
          validationError: validationErrorForKey,
          path: path,
          onKeyChanged: { keyButtonPath, capturedKey in
            keyInputValue = capturedKey
            userConfig.updateKey(at: keyButtonPath, newKey: capturedKey)
          },
          showFallbackIndicator: group.isFromFallback
        )
        .onChange(of: isListening) { isNowListening in
            if wasPreviouslyListening && !isNowListening {
                let modelKey = group.key ?? ""
                if keyInputValue != modelKey {
                    userConfig.updateKey(at: path, newKey: keyInputValue)
                }
            }
            wasPreviouslyListening = isNowListening
        }

        IconPickerMenu(
          item: Binding(
            get: { .group(group) },
            set: { newItem in
              if case .group(let newGroup) = newItem {
                group = newGroup
              }
            }
          ))

        Button(
          role: .none,
          action: {
            withAnimation(.easeOut(duration: 0.1)) {
              toggleExpanded()
            }

          }
        ) {
          HStack {
            Image(systemName: "chevron.right")
              .rotationEffect(.degrees(isExpanded ? 90 : 0))
              .padding(.leading, generalPadding / 3)
            Spacer()
          }
          .frame(width: 30, height: 16)
          .background(Color.blue.opacity(0.2))
          .cornerRadius(4)
          .contentShape(Rectangle())
        }.buttonStyle(.plain)

        Spacer(minLength: 0)

        // Add sticky mode checkbox for groups
        Toggle("SM", isOn: Binding(
          get: { group.stickyMode ?? false },
          set: { group.stickyMode = $0 }
        ))
        .toggleStyle(.checkbox)
        .frame(width: 40)
        .help("Sticky Mode: Automatically activate sticky mode when entering this group")

        HStack(spacing: 4) {
          TextField("Label", text: $labelInputValue)
            .frame(width: group.isFromFallback ? 70 : 120)

          if group.isFromFallback {
            HStack(spacing: 3) {
              Image(systemName: "arrow.down")
                .foregroundColor(.blue.opacity(0.6))
                .font(.system(size: 11, weight: .medium))
                .help("Inherited from \(group.fallbackSource ?? "Fallback App Config")")

              Button("Make Editable") {
                // Convert fallback item to app-specific item, including all nested items
                var newGroup = group
                newGroup.isFromFallback = false
                newGroup.fallbackSource = nil
                // Recursively convert all nested items from fallback to app-specific
                newGroup.actions = convertNestedFallbacksToAppSpecific(newGroup.actions)
                userConfig.updateGroup(at: path, newGroup: newGroup)
              }
              .font(.system(size: 9, weight: .medium))
              .buttonStyle(.bordered)
              .controlSize(.mini)
              .help("Create app-specific copy of this fallback group that you can modify")
            }
          }
        }
        .frame(width: 120)
        .padding(.trailing, generalPadding)

        Button(role: .none, action: {
          ClipboardManager.shared.copyItem(.group(group), fromConfig: userConfig.selectedConfigKeyForEditing)
        }) {
          Image(systemName: "doc.on.clipboard")
        }
        .buttonStyle(.plain)

        Button(role: .none, action: onDuplicate) {
          Image(systemName: "document.on.document")
        }
        .buttonStyle(.plain)

        Button(role: .destructive, action: onDelete) {
          Image(systemName: "trash")
        }
        .buttonStyle(.plain)
        .padding(.trailing, generalPadding)
      }
      .background(
        group.isFromFallback ? 
          Color.blue.opacity(0.05) : 
          Color.clear
      )
      .cornerRadius(group.isFromFallback ? 4 : 0)

      if isExpanded {
        HStack(spacing: 0) {
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 1)
            .padding(.leading, generalPadding)
            .padding(.trailing, generalPadding / 3)

          GroupContentView(group: $group, parentPath: path, expandedGroups: $expandedGroups)
            .padding(.leading, generalPadding)
        }
      }
    }
    .onAppear {
      keyInputValue = group.key ?? ""
      labelInputValue = group.label ?? ""
    }
    .onChange(of: group.key) { newValue in
        let newKeyValue = newValue ?? ""
        if keyInputValue != newKeyValue {
            keyInputValue = newKeyValue
        }
    }
    .onChange(of: group.label) { newValue in labelInputValue = newValue ?? "" }

    .onChange(of: labelInputValue) { newValue in
        // Update label immediately when local state changes
        let effectiveNewLabel = newValue.isEmpty ? nil : newValue
        if group.label != effectiveNewLabel {
            group.label = effectiveNewLabel
        }
    }
    .padding(.horizontal, 0)
  }

  private var validationErrorForKey: ValidationError? {
    guard !path.isEmpty else { return nil }

    // Find validation errors for this item
    let errors = userConfig.validationErrors.filter { error in
      error.path == path
    }

    return errors.first
  }
}

#Preview {
  let group = Group(
    key: "",
    stickyMode: nil,
    actions: [
      // Level 1 actions
      .action(
        Action(key: "t", type: .application, value: "/Applications/WezTerm.app")
      ),
      .action(
        Action(key: "f", type: .application, value: "/Applications/Firefox.app")
      ),
      .action(
        Action(key: "a", type: .command, value: "ls")
      ),
      .action(
        Action(key: "c", type: .url, value: "raycast://confetti")
      ),
      .action(
        Action(key: "g", type: .url, value: "https://google.com")
      ),

      // Level 1 group with actions
      .group(
        Group(
          key: "b",
          stickyMode: nil,
          actions: [
            .action(
              Action(
                key: "c", type: .application,
                value: "/Applications/Google Chrome.app")),
            .action(
              Action(
                key: "s", type: .application, value: "/Applications/Safari.app")
            )
          ])),

      // Level 1 group with subgroups
      .group(
        Group(
          key: "r",
          stickyMode: nil,
          actions: [
            .action(
              Action(
                key: "e", type: .url,
                value:
                  "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"
              )),
            .group(
              Group(
                key: "w",
                stickyMode: nil,
                actions: [
                  .action(
                    Action(
                      key: "f", type: .url,
                      value: "raycast://window-management/maximize")),
                  .action(
                    Action(
                      key: "h", type: .url,
                      value: "raycast://window-management/left-half"))
                ]))
          ]))
    ])

  let userConfig = UserConfig()

  return ConfigEditorView(group: .constant(group), expandedGroups: .constant(Set<[Int]>()))
    .frame(width: 600, height: 500)
    .environmentObject(userConfig)
}

struct MacroEditorView: View {
  @Binding var action: Action
  var path: [Int]
  @State private var isMacroEditorPresented = false

  var body: some View {
    Button {
      isMacroEditorPresented = true
    } label: {
      HStack(spacing: 4) {
        Image(systemName: "play.rectangle.on.rectangle")
        Text(macroButtonText)
      }
    }
    .buttonStyle(.plain)
    .sheet(isPresented: $isMacroEditorPresented) {
      MacroEditorSheet(action: $action, path: path, isPresented: $isMacroEditorPresented)
    }
  }

  private var macroButtonText: String {
    let stepCount = action.macroSteps?.count ?? 0
    if stepCount == 0 {
      return "Create macro…"
    } else {
      return "Edit macro (\(stepCount) steps)"
    }
  }
}

struct MacroEditorSheet: View {
  @Binding var action: Action
  var path: [Int]
  @Binding var isPresented: Bool
  @State private var macroSteps: [MacroStep] = []

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Edit Macro")
        .font(.title2)

      Text("Create a sequence of actions that will be executed in order with configurable delays.")
        .font(.body)
        .foregroundColor(.secondary)

      List {
        ForEach($macroSteps) { $step in
          MacroStepRow(step: $step, onDelete: {
            if let index = macroSteps.firstIndex(where: { $0.id == step.id }),
               index >= 0 && index < macroSteps.count {
              macroSteps.remove(at: index)
            }
          })
        }
        .onMove(perform: moveMacroStep)
      }
      .frame(minHeight: 200)
      .border(Color.gray.opacity(0.2))

      Button("Add Step") {
        let newStep = MacroStep(
          action: Action(key: "", type: .shortcut, value: ""),
          delay: 0.0,
          enabled: true
        )
        macroSteps.append(newStep)
      }

      HStack {
        Spacer()
        Button("Cancel") {
          // Revert changes
          macroSteps = action.macroSteps ?? []
          isPresented = false
        }
        Button("Save") {
          action.macroSteps = macroSteps
          isPresented = false
        }
        .keyboardShortcut(.defaultAction)
      }
    }
    .padding(24)
    .frame(width: 600, height: 500)
    .onAppear {
      macroSteps = action.macroSteps ?? []
    }
  }

  private func moveMacroStep(from source: IndexSet, to destination: Int) {
    macroSteps.move(fromOffsets: source, toOffset: destination)
  }
}

struct MacroStepRow: View {
  @Binding var step: MacroStep
  let onDelete: () -> Void
  @State private var valueInputValue: String = ""
  @State private var isShortcutEditorPresented = false
  @State private var isTextEditorPresented = false
  @State private var isUrlEditorPresented = false
  @State private var isCommandEditorPresented = false
  @State private var showingKeyReference = false

  var body: some View {
    HStack(spacing: 12) {
      // Drag handle
      Image(systemName: "line.3.horizontal")
        .foregroundColor(.secondary)
        .frame(width: 20)

      // Enable/disable toggle
      Toggle("", isOn: $step.enabled)
        .toggleStyle(.checkbox)
        .frame(width: 20)

      // Delay field
      VStack(alignment: .leading, spacing: 2) {
        Text("Delay (s)")
          .font(.caption)
          .foregroundColor(.secondary)
        TextField("0.0", text: Binding(
          get: { String(step.delay) },
          set: { newValue in
            if let doubleValue = Double(newValue) {
              step.delay = doubleValue
            }
          }
        ))
          .frame(width: 60)
          .textFieldStyle(.roundedBorder)
      }

      // Action type picker
      Picker("Type", selection: $step.action.type) {
        Text("Shortcut").tag(Type.shortcut)
        Text("Application").tag(Type.application)
        Text("URL").tag(Type.url)
        Text("Command").tag(Type.command)
        Text("Folder").tag(Type.folder)
        Text("Type Text").tag(Type.text)
      }
      .frame(width: 100)
      .labelsHidden()

      // Action value field - now with popup editors similar to ActionRow, made wider
      HStack(spacing: 8) {
        switch step.action.type {
      case .application:
        Button("Choose…") {
          let panel = NSOpenPanel()
          panel.allowedContentTypes = [.applicationBundle, .application]
          panel.canChooseFiles = true
          panel.canChooseDirectories = true
          panel.allowsMultipleSelection = false
          panel.directoryURL = URL(fileURLWithPath: "/Applications")

          if panel.runModal() == .OK {
            step.action.value = panel.url?.path ?? ""
          }
        }
        .buttonStyle(.plain)
        Text(step.action.value).truncationMode(.middle).lineLimit(1)
      case .folder:
        Button("Choose…") {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = true
          panel.canChooseFiles = false
          panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser

          if panel.runModal() == .OK {
            step.action.value = panel.url?.path ?? ""
          }
        }
        .buttonStyle(.plain)
        Text(step.action.value).truncationMode(.middle).lineLimit(1)
      case .shortcut:
        Button {
          isShortcutEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "keyboard")
            Text(valueInputValue.isEmpty ? "Set shortcut…" : (valueInputValue.count > 25 ? "\(valueInputValue.prefix(25))…" : valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShortcutEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit Shortcut")
              .font(.title2)
            TextEditor(text: $valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 120)
              .border(Color.gray.opacity(0.2))
            Text("Use letters for modifiers before the key: C=⌘, S=⇧, O=⌥, T=⌃. Example: CSb means ⌘⇧B.")
              .font(.footnote)
              .foregroundColor(.secondary)

            DisclosureGroup("Key Reference", isExpanded: $showingKeyReference) {
              ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                  ForEach(KeyReference.keyCategories.keys.sorted(), id: \.self) { category in
                    VStack(alignment: .leading, spacing: 4) {
                      Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)

                      let columns = [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                      ]
                      
                      LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(KeyReference.keyCategories[category] ?? [], id: \.self) { key in
                          Text(key)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        }
                      }
                    }
                  }
                }
                .padding(.top, 8)
              }
              .frame(maxHeight: 200)
            }
            .font(.footnote)
            HStack {
              Spacer()
              Button("Cancel") {
                valueInputValue = step.action.value
                isShortcutEditorPresented = false
              }
              Button("Save") {
                step.action.value = valueInputValue
                isShortcutEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 380)
        }
      case .url:
        Button {
          isUrlEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "link")
            Text(valueInputValue.isEmpty ? "Edit URL…" : (valueInputValue.count > 30 ? "\(valueInputValue.prefix(30))…" : valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isUrlEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit URL")
              .font(.title2)
            TextEditor(text: $valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 120)
              .border(Color.gray.opacity(0.2))
            Toggle("Activate after open", isOn: Binding(
              get: { step.action.activates ?? true },
              set: { step.action.activates = $0 }
            ))
            .toggleStyle(.checkbox)
            HStack {
              Spacer()
              Button("Cancel") {
                valueInputValue = step.action.value
                isUrlEditorPresented = false
              }
              Button("Save") {
                step.action.value = valueInputValue
                isUrlEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 420)
        }
      case .text:
        Button {
          isTextEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "square.and.pencil")
            Text(valueInputValue.isEmpty ? "Edit text…" : (valueInputValue.count > 20 ? "\(valueInputValue.prefix(20))…" : valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isTextEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit Text to Type")
              .font(.title2)
            TextEditor(text: $valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 180)
              .border(Color.gray.opacity(0.2))
            HStack {
              Spacer()
              Button("Cancel") {
                valueInputValue = step.action.value
                isTextEditorPresented = false
              }
              Button("Save") {
                step.action.value = valueInputValue
                isTextEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 480, height: 300)
        }
      case .toggleStickyMode:
        Text("No value required")
          .foregroundColor(.secondary)
          .font(.caption)
      default:
        Button {
          isCommandEditorPresented = true
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "terminal")
            Text(valueInputValue.isEmpty ? "Edit command…" : (valueInputValue.count > 30 ? "\(valueInputValue.prefix(30))…" : valueInputValue))
          }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isCommandEditorPresented) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Edit Command")
              .font(.title2)
            TextEditor(text: $valueInputValue)
              .font(.system(.body, design: .monospaced))
              .frame(minHeight: 120)
              .border(Color.gray.opacity(0.2))
            HStack {
              Spacer()
              Button("Cancel") {
                valueInputValue = step.action.value
                isCommandEditorPresented = false
              }
              Button("Save") {
                step.action.value = valueInputValue
                isCommandEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 420)
        }
      }

        Spacer()
      }

      // Fallback indicator for macro steps
      if step.action.isFromFallback {
        Image(systemName: "circle.fill")
          .foregroundColor(.white.opacity(0.2))
          .font(.system(size: 4))
          .help("From \(step.action.fallbackSource ?? "Fallback App Config")")
      }

      // Delete button
      Button(role: .destructive, action: onDelete) {
        Image(systemName: "trash")
      }
      .buttonStyle(.plain)
    }
    .padding(8)
    .background(Color.gray.opacity(0.1))
    .cornerRadius(4)
    .onAppear {
      valueInputValue = step.action.value
    }
    .onChange(of: step.action.value) { newValue in
      valueInputValue = newValue
    }
  }
}
