import SwiftUI

struct AlternativeMappingsView: View {
  @StateObject private var manager = AlternativeMappingsManager.shared
  @State private var showingAddSheet = false
  @State private var editingMapping: AlternativeMapping?
  @State private var searchText = ""
  @State private var showingSaveAsSheet = false
  @State private var newSetName = ""
  @State private var showingDeleteConfirmation = false
  @State private var setToDelete = ""
  @Environment(\.dismiss) var dismiss
  
  var filteredMappings: [AlternativeMapping] {
    if searchText.isEmpty {
      return manager.mappings
    }
    return manager.mappings.filter { mapping in
      mapping.originalKey.localizedCaseInsensitiveContains(searchText) ||
      mapping.alternativeKey.localizedCaseInsensitiveContains(searchText) ||
      (mapping.description ?? "").localizedCaseInsensitiveContains(searchText) ||
      mapping.conditions.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      // Header
      VStack(spacing: 12) {
        HStack {
          Text("Alternative Key Mappings")
            .font(.title2)
            .fontWeight(.semibold)
          
          Spacer()
          
          Button("Done") {
            dismiss()
          }
          .keyboardShortcut(.escape, modifiers: [])
        }
        
        // Set Management Bar
        HStack {
          Text("Mapping Set:")
            .font(.subheadline)
          
          Picker("", selection: $manager.currentSetName) {
            ForEach(Array(manager.availableSets.keys).sorted(), id: \.self) { key in
              Text(manager.availableSets[key] ?? key)
                .tag(key)
            }
          }
          .frame(width: 150)
          .onChange(of: manager.currentSetName) { newValue in
            manager.switchToSet(name: newValue)
          }
          
          Divider()
            .frame(height: 20)
          
          Button(action: { showingSaveAsSheet = true }) {
            Image(systemName: "square.and.arrow.down")
              .help("Save As New Set")
          }
          .disabled(manager.mappings.isEmpty)
          
          Button(action: {
            setToDelete = manager.currentSetName
            showingDeleteConfirmation = true
          }) {
            Image(systemName: "trash")
              .foregroundColor(.red)
              .help("Delete Current Set")
          }
          .disabled(manager.currentSetName == "default")
          
          Spacer()
          
          if manager.hasUnsavedChanges {
            Text("• Unsaved")
              .font(.caption)
              .foregroundColor(.orange)
          }
          
          Text("\(manager.mappings.count) mapping\(manager.mappings.count == 1 ? "" : "s")")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      
      Divider()
      
      // Search bar
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.secondary)
        TextField("Search mappings...", text: $searchText)
          .textFieldStyle(.plain)
      }
      .padding(8)
      .background(Color.gray.opacity(0.1))
      .cornerRadius(6)
      .padding(.horizontal)
      .padding(.top, 12)
      
      // Table
      if manager.mappings.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "keyboard.badge.ellipsis")
            .font(.system(size: 48))
            .foregroundColor(.secondary)
          
          Text("No Alternative Mappings")
            .font(.title3)
            .foregroundColor(.secondary)
          
          Text("Add alternative key mappings to trigger Leader Key actions\nwithout entering Leader Key mode")
            .multilineTextAlignment(.center)
            .font(.callout)
            .foregroundColor(.secondary)
          
          Button(action: { showingAddSheet = true }) {
            Label("Add First Mapping", systemImage: "plus.circle.fill")
          }
          .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      } else {
        ScrollView {
          VStack(spacing: 8) {
            ForEach(filteredMappings) { mapping in
              AlternativeMappingRow(
                mapping: mapping,
                onEdit: {
                  editingMapping = mapping
                },
                onDelete: {
                  manager.deleteMapping(mapping)
                }
              )
            }
          }
          .padding()
        }
      }
      
      Divider()
      
      // Bottom bar
      HStack {
        Button(action: { showingAddSheet = true }) {
          Label("Add Mapping", systemImage: "plus")
        }
        
        Spacer()
      }
      .padding()
    }
    .frame(width: 700, height: 500)
    .sheet(isPresented: $showingAddSheet) {
      AlternativeMappingEditView(mapping: nil)
    }
    .sheet(item: $editingMapping) { mapping in
      AlternativeMappingEditView(mapping: mapping)
    }
    .sheet(isPresented: $showingSaveAsSheet) {
      SaveAsSheet(isPresented: $showingSaveAsSheet, currentName: manager.currentSetName) { newName in
        if manager.saveAsNewSet(name: newName) {
          // Success - already switched to new set
        } else {
          // Show error - set already exists
          // In a real app, show an alert
        }
      }
    }
    .alert("Delete Mapping Set", isPresented: $showingDeleteConfirmation) {
      Button("Cancel", role: .cancel) { }
      Button("Delete", role: .destructive) {
        _ = manager.deleteSet(name: setToDelete)
      }
    } message: {
      Text("Are you sure you want to delete the '\(manager.availableSets[setToDelete] ?? setToDelete)' mapping set? This cannot be undone.")
    }
  }
}

// MARK: - Save As Sheet

struct SaveAsSheet: View {
  @Binding var isPresented: Bool
  let currentName: String
  let onSave: (String) -> Void
  
  @State private var newName = ""
  @FocusState private var isFocused: Bool
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Save Mapping Set As")
        .font(.title3)
        .fontWeight(.semibold)
      
      TextField("Enter new set name", text: $newName)
        .textFieldStyle(.roundedBorder)
        .frame(width: 250)
        .focused($isFocused)
      
      HStack {
        Button("Cancel") {
          isPresented = false
        }
        .keyboardShortcut(.escape, modifiers: [])
        
        Spacer()
        
        Button("Save") {
          onSave(newName)
          isPresented = false
        }
        .keyboardShortcut(.return, modifiers: [])
        .disabled(newName.isEmpty)
      }
    }
    .padding(30)
    .frame(width: 350)
    .onAppear {
      isFocused = true
    }
  }
}

// MARK: - Row View

struct AlternativeMappingRow: View {
  let mapping: AlternativeMapping
  let onEdit: () -> Void
  let onDelete: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      // Original key
      VStack(alignment: .leading, spacing: 4) {
        Text("Original")
          .font(.caption)
          .foregroundColor(.secondary)
        Text(mapping.originalKey)
          .font(.system(.body, design: .monospaced))
      }
      .frame(width: 80, alignment: .leading)
      
      Image(systemName: "arrow.right")
        .foregroundColor(.secondary)
      
      // Alternative key
      VStack(alignment: .leading, spacing: 4) {
        Text("Alternative")
          .font(.caption)
          .foregroundColor(.secondary)
        Text(mapping.alternativeKey)
          .font(.system(.body, design: .monospaced))
      }
      .frame(width: 80, alignment: .leading)
      
      // Conditions
      VStack(alignment: .leading, spacing: 4) {
        Text("Conditions")
          .font(.caption)
          .foregroundColor(.secondary)
        Text(mapping.conditions.isEmpty ? "None" : mapping.conditions.joined(separator: ", "))
          .font(.caption)
          .lineLimit(1)
      }
      .frame(minWidth: 100, alignment: .leading)
      
      // App
      if let appAlias = mapping.appAlias {
        VStack(alignment: .leading, spacing: 4) {
          Text("App")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(appAlias)
            .font(.caption)
        }
      }
      
      Spacer()
      
      // Description
      if let description = mapping.description, !description.isEmpty {
        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
      
      // Actions
      Button(action: onEdit) {
        Image(systemName: "pencil")
      }
      .buttonStyle(.plain)
      
      Button(action: onDelete) {
        Image(systemName: "trash")
          .foregroundColor(.red)
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color.gray.opacity(0.05))
    .cornerRadius(6)
  }
}

// MARK: - Edit View

struct AlternativeMappingEditView: View {
  let mapping: AlternativeMapping?
  
  @State private var originalKey: String = ""
  @State private var alternativeKey: String = ""
  @State private var selectedConditions: Set<String> = []
  @State private var customCondition: String = ""
  @State private var appAlias: String = ""
  @State private var description: String = ""
  @State private var showingKeyPicker = false
  
  @Environment(\.dismiss) var dismiss
  @StateObject private var manager = AlternativeMappingsManager.shared
  
  var isEditing: Bool { mapping != nil }
  
  init(mapping: AlternativeMapping?) {
    self.mapping = mapping
    if let mapping = mapping {
      _originalKey = State(initialValue: mapping.originalKey)
      _alternativeKey = State(initialValue: mapping.alternativeKey)
      _selectedConditions = State(initialValue: Set(mapping.conditions))
      _appAlias = State(initialValue: mapping.appAlias ?? "")
      _description = State(initialValue: mapping.description ?? "")
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text(isEditing ? "Edit Alternative Mapping" : "Add Alternative Mapping")
          .font(.title3)
          .fontWeight(.semibold)
        
        Spacer()
      }
      .padding()
      
      Divider()
      
      // Form
      Form {
        Section {
          TextField("Key to substitute (e.g., hyphen, minus)", text: $originalKey)
            .help("The key you want to create an alternative for")
        } header: {
          Text("Original Key")
        } footer: {
          Text("Common keys: hyphen, semicolon, slash, return, tab, space")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Section {
          TextField("Alternative key (e.g., l, f, j)", text: $alternativeKey)
            .help("The key that will act as the original key when conditions are met")
        } header: {
          Text("Alternative Key")
        } footer: {
          Text("This key will trigger the same actions as the original key")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Section {
          VStack(alignment: .leading, spacing: 8) {
            ForEach(CommonCondition.commonConditions, id: \.id) { condition in
              Toggle(isOn: Binding(
                get: { selectedConditions.contains(condition.id) },
                set: { isSelected in
                  if isSelected {
                    selectedConditions.insert(condition.id)
                  } else {
                    selectedConditions.remove(condition.id)
                  }
                }
              )) {
                HStack {
                  Text(condition.displayName)
                  Text(condition.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }
            }
            
            HStack {
              TextField("Custom condition (e.g., my-mode)", text: $customCondition)
              if !customCondition.isEmpty {
                Button("Add") {
                  selectedConditions.insert(customCondition)
                  customCondition = ""
                }
              }
            }
          }
        } header: {
          Text("Conditions")
        } footer: {
          if !selectedConditions.isEmpty {
            Text("Selected: \(selectedConditions.sorted().joined(separator: ", "))")
              .font(.caption)
          }
        }
        
        Section {
          TextField("App Alias (optional)", text: $appAlias)
            .help("Leave empty for global mapping")
        } header: {
          Text("App-Specific (Optional)")
        }
        
        Section {
          TextField("Description (optional)", text: $description)
        } header: {
          Text("Notes")
        }
      }
      .padding()
      
      Divider()
      
      // Actions
      HStack {
        Button("Cancel") {
          dismiss()
        }
        .keyboardShortcut(.escape, modifiers: [])
        
        Spacer()
        
        Button(isEditing ? "Save" : "Add") {
          save()
        }
        .buttonStyle(.borderedProminent)
        .disabled(originalKey.isEmpty || alternativeKey.isEmpty)
      }
      .padding()
    }
    .frame(width: 550, height: 600)
  }
  
  private func save() {
    let newMapping = AlternativeMapping(
      id: mapping?.id ?? UUID(),
      originalKey: originalKey,
      alternativeKey: alternativeKey,
      conditions: Array(selectedConditions).sorted(),
      appAlias: appAlias.isEmpty ? nil : appAlias,
      description: description.isEmpty ? nil : description
    )
    
    if isEditing {
      manager.updateMapping(newMapping)
    } else {
      manager.addMapping(newMapping)
    }
    
    dismiss()
  }
}
