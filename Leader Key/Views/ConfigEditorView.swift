import Defaults
import SwiftUI
import SymbolPicker

let generalPadding: CGFloat = 8

struct AddButtons: View {
  let onAddAction: () -> Void
  let onAddGroup: () -> Void

  var body: some View {
    HStack(spacing: generalPadding) {
      Button(action: onAddAction) {
        Image(systemName: "rays")
        Text("Add action")
      }
      Button(action: onAddGroup) {
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
      ForEach(group.actions.indices, id: \.self) { index in
        // Log each item being considered for rendering
        // let _ = print("[GroupContentView ForEach] Index: \(index), Item Key: \(index < group.actions.count ? (group.actions[index].item.key ?? "nil") : "OUT OF BOUNDS")")
        if index < group.actions.count {
            let currentPath = parentPath + [index]
            ActionOrGroupRow(
              item: $group.actions[index],
              path: currentPath,
              onDelete: { 
                if index < group.actions.count {
                     let idToRemove = group.actions[index].id
                     group.actions.removeAll { $0.id == idToRemove }
                }
              },
              onDuplicate: { 
                 if index < group.actions.count {
                    group.actions.insert(group.actions[index], at: index)
                 }
              },
              expandedGroups: $expandedGroups
            )
        }
      }

      AddButtons(
        onAddAction: {
          withAnimation {
            group.actions.append(
              .action(Action(key: "", type: .application, value: "")))
          }
        },
        onAddGroup: {
          withAnimation {
            group.actions.append(.group(Group(key: "", actions: [])))
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

  var body: some View {
    // Log action details
    // let _ = print("[ActionRow] Rendering action. Path: \(path), Key: '\(action.key ?? "nil")', Type: \(action.type), Value: '\(action.value)'")
    HStack(spacing: generalPadding) {
      KeyButton(
        text: $keyInputValue,
        placeholder: "Key", 
        validationError: validationErrorForKey,
        path: path,
        onKeyChanged: { _, capturedKey in
          keyInputValue = capturedKey
        }
      )
      .onChange(of: isListening) { isNowListening in
          if wasPreviouslyListening && !isNowListening {
              let modelKey = action.key ?? ""
              if keyInputValue != modelKey {
                  print("[ActionRow onChange(isListening)] Key changed from '\(modelKey)' to '\(keyInputValue)'. Updating model for path \(path).")
                  userConfig.updateKey(at: path, newKey: keyInputValue)
              }
          }
          wasPreviouslyListening = isNowListening
      }

      Picker("Type", selection: $action.type) {
        Text("Application").tag(Type.application)
        Text("URL").tag(Type.url)
        Text("Command").tag(Type.command)
        Text("Folder").tag(Type.folder)
        Text("Shortcut").tag(Type.shortcut)
        Text("Type Text").tag(Type.text)
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
        TextField("Shortcut (e.g., CSb, Oa)", text: $valueInputValue, onCommit: {
          action.value = valueInputValue
        })
      case .url:
        HStack {
          TextField("URL", text: $valueInputValue, onCommit: {
            action.value = valueInputValue
          })
          Toggle("Activates", isOn: Binding(
            get: { action.activates ?? true },
            set: { action.activates = $0 }
          ))
          .toggleStyle(.checkbox)
          .frame(width: 90)
        }
      case .text:
        TextField("Text to type", text: $valueInputValue, onCommit: {
          action.value = valueInputValue
        })
      default:
        TextField("Value", text: $valueInputValue, onCommit: {
          action.value = valueInputValue
        })
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
      keyInputValue = action.key ?? ""
      valueInputValue = action.value
      labelInputValue = action.label ?? ""
    }
    .onChange(of: valueInputValue) { newValue in
        // Update value immediately when local state changes
        if action.value != newValue {
            action.value = newValue
        }
    }
    .onChange(of: labelInputValue) { newValue in
        // Update label immediately when local state changes
        let effectiveNewLabel = newValue.isEmpty ? nil : newValue
        if action.label != effectiveNewLabel {
            action.label = effectiveNewLabel
        }
    }
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
          onKeyChanged: { _, capturedKey in
            keyInputValue = capturedKey
          }
        )
        .onChange(of: isListening) { isNowListening in
            if wasPreviouslyListening && !isNowListening {
                let modelKey = group.key ?? ""
                if keyInputValue != modelKey {
                    print("[GroupRow onChange(isListening)] Key changed from '\(modelKey)' to '\(keyInputValue)'. Updating model for path \(path).")
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
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .padding(.leading, generalPadding / 3)
        }.buttonStyle(.plain)

        Spacer(minLength: 0)

        TextField("Label", text: $group.label ?? "").frame(width: 120)
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
      keyInputValue = group.key ?? ""
      labelInputValue = group.label ?? ""
    }
    .onChange(of: group.key) { newValue in
        let newKeyValue = newValue ?? ""
        if keyInputValue != newKeyValue { // Prevent potential loops
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
