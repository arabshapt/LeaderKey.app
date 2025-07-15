import Defaults
import SwiftUI
import SymbolPicker

struct KeyReference {
    static let keyCategories: [String: [String]] = [
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
}

// Helper function to create a deep duplicate with a new UUID
func makeTrueDuplicate(item: ActionOrGroup) -> ActionOrGroup {
    switch item {
    case .action(let action):
        // Create a new Action instance, which will get a new UUID
        return .action(Action(key: action.key, type: action.type, label: action.label, value: action.value, iconPath: action.iconPath, activates: action.activates, stickyMode: action.stickyMode, macroSteps: action.macroSteps))
    case .group(let group):
        // Recursively duplicate actions within the group
        let newActions = group.actions.map { makeTrueDuplicate(item: $0) }
        // Create a new Group instance, which will get a new UUID
        return .group(Group(key: group.key, label: group.label, iconPath: group.iconPath, stickyMode: group.stickyMode, actions: newActions))
    }
}

let generalPadding: CGFloat = 8

struct AddButtons: View {
  let onAddAction: () -> Void
  let onAddGroup: () -> Void

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

  var body: some View {
    // Log actions count and items being rendered
    // let _ = print("[GroupContentView] Rendering group '\(group.displayName)' with \(group.actions.count) actions. Path: \(parentPath)")
    LazyVStack(spacing: generalPadding) {
      ForEach($group.actions) { $itemInForEach in // Iterating over bindings to identifiable items
        // Find the index of the current item to construct the path
        // This is necessary if ActionOrGroupRow or its children rely on the index-based path.
        // Ensure this logic correctly handles potential nil if item is not found (should not happen here).
        if let index = group.actions.firstIndex(where: { $0.id == itemInForEach.id }) {
            let currentPath = parentPath + [index]
            ActionOrGroupRow(
              item: $itemInForEach, // Pass the binding directly
              path: currentPath,
              onDelete: {
                // Remove by ID, which is safer when the array might be reordered
                group.actions.removeAll { $0.id == itemInForEach.id }
              },
              onDuplicate: {
                // Use the new makeTrueDuplicate function
                if let sourceIndex = group.actions.firstIndex(where: { $0.id == itemInForEach.id }) {
                    let duplicatedItemWithNewID = makeTrueDuplicate(item: itemInForEach)
                    // Insert after the current item, or at the same index if preferred.
                    // Make sure the index is valid.
                    let insertAtIndex = min(sourceIndex + 1, group.actions.count)
                    group.actions.insert(duplicatedItemWithNewID, at: insertAtIndex)
                }
              },
              expandedGroups: $expandedGroups
            )
        } else {
            // Fallback or error logging if an item's index can't be found.
            // This case should ideally not be reached if itemInForEach is always from group.actions.
            // Text("Error: Item not found in group.actions for ID \\(itemInForEach.id)")
            //     .foregroundColor(.red)
        }
      }

      AddButtons(
        onAddAction: {
          withAnimation {
            print("[UI LOG] GroupContentView: Adding new ACTION (key: \"\", type: .shortcut, value: \"\") to group at path \(parentPath)")
            group.actions.append(
              .action(Action(key: "", type: .shortcut, value: "")))
          }
        },
        onAddGroup: {
          withAnimation {
            print("[UI LOG] GroupContentView: Adding new GROUP (key: \"\", actions: []) to group at path \(parentPath)")
            group.actions.append(.group(Group(key: "", stickyMode: nil, actions: [])))
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
    // Log the received group when the view appears or updates
    // let _ = Self._printChanges()
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

  var body: some View {
    // Log which type of row is being rendered
    // let _ = print("[ActionOrGroupRow] Path: \(path), Rendering item with key '\(item.item.key ?? "nil")' as \(item.item.type == .group ? "GroupRow" : "ActionRow")")
    switch item {
    case .action:
      ActionRow(
        action: Binding(
          get: {
            if case .action(let action) = item { return action }
            fatalError("Unexpected state")
          },
          set: { newAction in
            item = .action(newAction)
          }
        ),
        path: path,
        onDelete: onDelete,
        onDuplicate: onDuplicate
      )
    case .group:
      GroupRow(
        group: Binding(
          get: {
            if case .group(let group) = item { return group }
            fatalError("Unexpected state")
          },
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
}

struct IconPickerMenu: View {
  @Binding var item: ActionOrGroup
  @State private var iconPickerPresented = false

  var body: some View {
    Menu {
      Button("App Icon") {
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

struct ActionRow: View {
  @Binding var action: Action
  var path: [Int]
  let onDelete: () -> Void
  let onDuplicate: () -> Void
  @FocusState private var isKeyFocused: Bool
  @EnvironmentObject var userConfig: UserConfig
  
  @State private var keyInputValue: String = ""
  @State private var valueInputValue: String = ""
  @State private var labelInputValue: String = ""
  @State private var isListening: Bool = false
  @State private var wasPreviouslyListening: Bool = false
  @State private var selectedType: Type = .shortcut // Local state for Picker
  // UI state for inline editors
  @State private var isShortcutEditorPresented = false
  @State private var isTextEditorPresented = false
  @State private var isUrlEditorPresented = false
  @State private var isCommandEditorPresented = false
  @State private var showingShortcutHelp = false
  @State private var showingKeyReference = false

  var body: some View {
    // Log action details + ID for tracking
    let _ = print("[UI LOG] ActionRow BODY START: Path \(path), ID \(action.id), Key '\(action.key ?? "nil")', Type: \(action.type)")
    
    // Add bounds checking to prevent crash
    guard !path.isEmpty && path.allSatisfy({ $0 >= 0 }) else {
      print("[UI LOG] ActionRow BODY: Invalid path \(path) - empty or negative indices")
      return AnyView(Text("Invalid path: empty or negative indices").foregroundColor(.red))
    }
    
    return AnyView(
    HStack(spacing: generalPadding) {
      KeyButton(
        text: $keyInputValue,
        placeholder: "Key", 
        validationError: validationErrorForKey,
        path: path,
        onKeyChanged: { keyButtonPath, capturedKey in
          print("[UI LOG] ActionRow KeyButton.onKeyChanged: Path \(keyButtonPath), Captured key: '\(capturedKey)'. Updating local keyInputValue.")
          keyInputValue = capturedKey
          print("[UI LOG] ActionRow KeyButton.onKeyChanged: Forcing call to userConfig.updateKey for path \(keyButtonPath) with key '\(capturedKey)'.")
          userConfig.updateKey(at: keyButtonPath, newKey: capturedKey)
        }
      )
      .onChange(of: isListening) { isNowListening in
          // Split log for ActionRow.onChange(isListening)
          print("[UI LOG] ActionRow.onChange(isListening): Path \(path), isNowListen: \(isNowListening), wasPrevListen: \(wasPreviouslyListening)")
          print("[UI LOG] ActionRow.onChange(isListening): Path \(path), keyInVal: '\(keyInputValue)', modelKey: '\(action.key ?? "nil")'.")
          if wasPreviouslyListening && !isNowListening {
              let modelKey = action.key ?? ""
              if keyInputValue != modelKey {
                  print("[UI LOG] ActionRow.onChange(isListening): Key value changed for path \(path) from '\(modelKey)' to '\(keyInputValue)'. Calling userConfig.updateKey.")
                  userConfig.updateKey(at: path, newKey: keyInputValue)
              } else {
                  print("[UI LOG] ActionRow.onChange(isListening): Key value NOT changed for path \(path). Current: '\(keyInputValue)'. No call to userConfig.updateKey.")
              }
          }
          wasPreviouslyListening = isNowListening
      }
      // Add onChange for the local selectedType state
      .onChange(of: selectedType) { newTypeValue in
        // Call the UserConfig method to handle the update
        // This avoids direct mutation of the binding within this view's update cycle
        let oldModelType = action.type // Store the type from the model BEFORE the update
        print("[UI LOG] ActionRow.onChange(selectedType): Path \(path) detected change TO \(newTypeValue). Old model type: \(oldModelType). Calling userConfig.updateActionType.")
        userConfig.updateActionType(at: path, newType: newTypeValue)

        // Check if the model's type ACTUALLY changed as a result of the call
        if action.type != oldModelType {
            print("[UI LOG] ActionRow.onChange(selectedType): Path \(path). Model type CHANGED from \(oldModelType) to \(action.type). Resetting valueInputValue locally.")
            valueInputValue = "" // Only reset if the type in the model was actually changed
        } else {
            print("[UI LOG] ActionRow.onChange(selectedType): Path \(path). Model type (\(action.type)) did NOT change from old (\(oldModelType)). Not resetting valueInputValue.")
        }
      }

      // Log before Picker
      let _ = print("[UI LOG] ActionRow BODY: Drawing Picker for Path \(path), ID \(action.id), Type: \(selectedType)") // Log selectedType
      Picker("Type", selection: $selectedType) { // Bind Picker to local state
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

      // Log before Switch
      let _ = print("[UI LOG] ActionRow BODY: Entering Switch for Path \(path), ID \(action.id), Type: \(action.type)") // Log action.type
      switch action.type { // Switch on the actual model type
      case .application:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .application for Path \(path), ID \(action.id)")
        Button("Choose…") {
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
        Text(action.value).truncationMode(.middle).lineLimit(1)
      case .folder:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .folder for Path \(path), ID \(action.id)")
        Button("Choose…") {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = true
          panel.canChooseFiles = false
          panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser

          if panel.runModal() == .OK {
            action.value = panel.url?.path ?? ""
          }
        }
        Text(action.value).truncationMode(.middle).lineLimit(1)
      case .shortcut:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .shortcut for Path \(path), ID \(action.id)")
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
                LazyVStack(alignment: .leading, spacing: 8) {
                  ForEach(KeyReference.keyCategories.keys.sorted(), id: \.self) { category in
                    VStack(alignment: .leading, spacing: 4) {
                      Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)
                      
                      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 4), spacing: 4) {
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
                valueInputValue = action.value
                isShortcutEditorPresented = false
              }
              Button("Save") {
                action.value = valueInputValue
                isShortcutEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 380)
        }
      case .url:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .url for Path \(path), ID \(action.id)")
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
              get: { action.activates ?? true },
              set: { action.activates = $0 }
            ))
            .toggleStyle(.checkbox)
            HStack {
              Spacer()
              Button("Cancel") {
                valueInputValue = action.value
                isUrlEditorPresented = false
              }
              Button("Save") {
                action.value = valueInputValue
                isUrlEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 420)
        }
      case .text:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .text for Path \(path), ID \(action.id)")
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
                valueInputValue = action.value
                isTextEditorPresented = false
              }
              Button("Save") {
                action.value = valueInputValue
                isTextEditorPresented = false
              }
              .keyboardShortcut(.defaultAction)
            }
          }
          .padding(24)
          .frame(width: 480, height: 300)
        }
      case .toggleStickyMode:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .toggleStickyMode for Path \(path), ID \(action.id)")
        Text("No value required")
          .foregroundColor(.secondary)
          .font(.caption)
      case .macro:
        // Log inside case
        let _ = print("[UI LOG] ActionRow Switch Case: .macro for Path \(path), ID \(action.id)")
        MacroEditorView(action: $action, path: path)
      default:
        // Log inside case (includes .command initially? Check your Type enum)
        let _ = print("[UI LOG] ActionRow Switch Case: .default/\(String(describing: action.type)) for Path \(path), ID \(action.id)") // Log action.type
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
                valueInputValue = action.value
                isCommandEditorPresented = false
              }
              Button("Save") {
                action.value = valueInputValue
                isCommandEditorPresented = false
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

      TextField(action.bestGuessDisplayName, text: $labelInputValue, onCommit: {
        action.label = labelInputValue.isEmpty ? nil : labelInputValue
      })
      .frame(width: 120)
      .padding(.trailing, generalPadding)

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
    .onAppear {
      print("[UI LOG] ActionRow.onAppear: Path \(path), Initial action key: '\(action.key ?? "nil")', value: '\(action.value)', label: '\(action.label ?? "nil")'. Setting local state.")
      keyInputValue = action.key ?? ""
      valueInputValue = action.value
      // If the label from the model is nil when the view appears,
      // set the local state to the best guess display name.
      // The onChange(of: labelInputValue) below will update the model.
      if action.label == nil {
        let guessedLabel = action.bestGuessDisplayName
        labelInputValue = guessedLabel
        print("[UI LOG] ActionRow.onAppear: Path \(path), Label was nil. Set labelInputValue to guessed name '\(guessedLabel)'.")
      } else {
        labelInputValue = action.label ?? ""
      }
      // Set initial local state for the Picker type
      selectedType = action.type 
    }
    // Re-add onChange listeners to sync local state back to the model
    .onChange(of: valueInputValue) { newValue in
        // Avoid syncing while the dedicated editor sheet is open; commit occurs on Save.
        let editorOpen = isShortcutEditorPresented || isUrlEditorPresented || isCommandEditorPresented || isTextEditorPresented
        if !editorOpen && action.value != newValue {
            print("[UI LOG] ActionRow.onChange(valueInputValue): Path \(path) syncing value '\(newValue)' to action.value (inline update).")
            action.value = newValue
        }
    }
    .onChange(of: labelInputValue) { newValue in
        let effectiveNewLabel = newValue.isEmpty ? nil : newValue
        if action.label != effectiveNewLabel {
            print("[UI LOG] ActionRow.onChange(labelInputValue): Path \(path) syncing label '\(effectiveNewLabel ?? "nil")' to action.label.")
            action.label = effectiveNewLabel
        }
    }
    ) // Close AnyView
  }

  private var validationErrorForKey: ValidationErrorType? {
    guard !path.isEmpty else { return nil }

    // Find validation errors for this item
    let errors = userConfig.validationErrors.filter { error in
      error.path == path
    }

    if let error = errors.first {
      return error.type
    }

    return nil
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
    // Log group details
    // let _ = print("[GroupRow] Rendering group. Path: \(path), Key: '\(group.key ?? "nil")', Actions count: \(group.actions.count)")
    VStack(spacing: generalPadding) {
      HStack(spacing: generalPadding) {
        // --- Add simple debug text --- START
        /* Text("DBG:[\(path.map(String.init).joined(separator: ","))] Key:\(group.key ?? "?")")
             .font(.caption)
             .foregroundColor(.red)
             .padding(.leading, 5) // Indent slightly based on path depth
             .opacity(0.7) */
        // --- Add simple debug text --- END
        
        KeyButton(
          text: $keyInputValue,
          placeholder: "Group Key",
          validationError: validationErrorForKey,
          path: path,
          onKeyChanged: { keyButtonPath, capturedKey in
            print("[UI LOG] GroupRow KeyButton.onKeyChanged: Path \(keyButtonPath), Captured key: '\(capturedKey)'. Updating local keyInputValue.")
            keyInputValue = capturedKey
            print("[UI LOG] GroupRow KeyButton.onKeyChanged: Forcing call to userConfig.updateKey for path \(keyButtonPath) with key '\(capturedKey)'.")
            userConfig.updateKey(at: keyButtonPath, newKey: capturedKey)
          }
        )
        .onChange(of: isListening) { isNowListening in
          // Split log for GroupRow.onChange(isListening)
          print("[UI LOG] GroupRow.onChange(isListening): Path \(path), isNowListen: \(isNowListening), wasPrevListen: \(wasPreviouslyListening)")
          print("[UI LOG] GroupRow.onChange(isListening): Path \(path), keyInVal: '\(keyInputValue)', modelKey: '\(group.key ?? "nil")'.")
            if wasPreviouslyListening && !isNowListening {
                let modelKey = group.key ?? ""
                if keyInputValue != modelKey {
                    print("[UI LOG] GroupRow.onChange(isListening): Key value changed for path \(path) from '\(modelKey)' to '\(keyInputValue)'. Calling userConfig.updateKey.")
                    userConfig.updateKey(at: path, newKey: keyInputValue)
                } else {
                    print("[UI LOG] GroupRow.onChange(isListening): Key value NOT changed for path \(path). Current: '\(keyInputValue)'. No call to userConfig.updateKey.")
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
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .padding(.leading, generalPadding / 3)
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

        TextField("Label", text: $labelInputValue).frame(width: 120)
          .padding(.trailing, generalPadding)

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
      print("[UI LOG] GroupRow.onAppear: Path \(path), Initial group key: '\(group.key ?? "nil")', label: '\(group.label ?? "nil")'. Setting local state.")
      keyInputValue = group.key ?? ""
      labelInputValue = group.label ?? ""
    }
    .onChange(of: group.key) { newValue in
        let newKeyValue = newValue ?? ""
        if keyInputValue != newKeyValue { // Prevent potential loops
            keyInputValue = newKeyValue
            print("[UI LOG] GroupRow.onChange(group.key): Path \(path). Model key changed to '\(newKeyValue)'. Updated keyInputValue.") // Added log
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

  private var validationErrorForKey: ValidationErrorType? {
    guard !path.isEmpty else { return nil }

    // Find validation errors for this item
    let errors = userConfig.validationErrors.filter { error in
      error.path == path
    }

    if let error = errors.first {
      return error.type
    }

    return nil
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
            ),
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
                      value: "raycast://window-management/left-half")),
                ])),
          ])),
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
            if let index = macroSteps.firstIndex(where: { $0.id == step.id }) {
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
                LazyVStack(alignment: .leading, spacing: 8) {
                  ForEach(KeyReference.keyCategories.keys.sorted(), id: \.self) { category in
                    VStack(alignment: .leading, spacing: 4) {
                      Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)
                      
                      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 4), spacing: 4) {
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
