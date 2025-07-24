import AppKit
import SwiftUI

struct KeyButton: View {
  @Binding var text: String
  let placeholder: String
  @State private var isListening = false
  var validationError: ValidationError?
  var path: [Int]
  var onKeyChanged: (([Int], String) -> Void)?
  var showFallbackIndicator: Bool = false

  var body: some View {
    Button(action: {
      isListening = true
    }) {
      ZStack(alignment: .bottomTrailing) {
        Text(text.isEmpty ? placeholder : text)
          .frame(width: 32, height: 24)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .fill(backgroundColor)
              .overlay(
                RoundedRectangle(cornerRadius: 5)
                  .stroke(borderColor, lineWidth: borderWidth)
              )
          )
          .foregroundColor(text.isEmpty ? .gray : .primary)
        
        // Validation error indicator
        if let error = validationError {
          Image(systemName: error.severity.iconName)
            .foregroundColor(errorIconColor)
            .font(.system(size: 8, weight: .bold))
            .offset(x: -2, y: -2)
        } else if showFallbackIndicator {
          Image(systemName: "arrow.down")
            .foregroundColor(.blue.opacity(0.7))
            .font(.system(size: 8, weight: .bold))
            .offset(x: -2, y: -2)
        }
      }
    }
    .buttonStyle(PlainButtonStyle())
    .help(helpText)
    .background(
      KeyListenerView(isListening: $isListening, path: path, onKeyChanged: onKeyChanged)
    )
  }

  private var backgroundColor: Color {
    if isListening {
      return Color.blue.opacity(0.2)
    } else if let error = validationError {
      return error.severity == .error ? Color.red.opacity(0.1) : Color.orange.opacity(0.1)
    } else {
      return Color(.controlBackgroundColor)
    }
  }

  private var borderColor: Color {
    if isListening {
      return Color.blue
    } else if let error = validationError {
      return error.severity == .error ? Color.red : Color.orange
    } else {
      return Color.gray.opacity(0.5)
    }
  }
  
  private var borderWidth: CGFloat {
    if validationError != nil {
      return 2.0
    } else {
      return 1.0
    }
  }
  
  private var errorIconColor: Color {
    guard let error = validationError else { return .clear }
    return error.severity == .error ? .red : .orange
  }
  
  private var helpText: String {
    if let error = validationError {
      var text = error.message
      if let suggestion = error.suggestion {
        text += "\n\n💡 " + suggestion
      }
      return text
    } else if showFallbackIndicator {
      return "This key is inherited from fallback configuration. Click 'Make Editable' to customize it."
    } else {
      return "Click to set a key, then press any character"
    }
  }
}

struct KeyListenerView: NSViewRepresentable {
  @Binding var isListening: Bool
  var path: [Int]
  var onKeyChanged: (([Int], String) -> Void)?

  func makeNSView(context: Context) -> NSView {
    let view = KeyListenerNSView()
    view.isListening = $isListening
    view.path = path
    view.onKeyChanged = onKeyChanged
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    if let view = nsView as? KeyListenerNSView {
      view.isListening = $isListening
      view.path = path
      view.onKeyChanged = onKeyChanged

      if isListening {
        DispatchQueue.main.async {
          view.window?.makeFirstResponder(view)
        }
      }
    }
  }

  class KeyListenerNSView: NSView {
    var isListening: Binding<Bool>?
    var path: [Int]?
    var onKeyChanged: (([Int], String) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
      guard let isListeningBinding = isListening, isListeningBinding.wrappedValue else {
        super.keyDown(with: event)
        return
      }

      var capturedKey: String?

      // Simplified key capture logic (similar to AppDelegate but for single key)
      switch event.keyCode {
        case 53: capturedKey = nil // Escape cancels
        case 51, 117: capturedKey = "" // Backspace/Delete clears
        case 36: capturedKey = "\u{21B5}" // Enter
        case 48: capturedKey = "\t" // Tab
        case 49: capturedKey = " " // Space
        case 126: capturedKey = "↑" // Up
        case 125: capturedKey = "↓" // Down
        case 123: capturedKey = "←" // Left
        case 124: capturedKey = "→" // Right
        default:
           // Use characters (respects shift) for other keys
           capturedKey = event.characters
      }

      // Only proceed if a key was meaningfully captured
      if let finalKey = capturedKey {
          print("[KeyListenerNSView] KeyDown captured: '\(finalKey)'. Calling handler and stopping listening.")
          // Call the handler *synchronously* with the new key and path
          if let currentPath = self.path {
             self.onKeyChanged?(currentPath, finalKey)
          } else {
              print("[KeyListenerNSView] Error: Path is nil, cannot call onKeyChanged.")
          }
          // Stop listening asynchronously
          DispatchQueue.main.async {
            isListeningBinding.wrappedValue = false
          }
      } else {
           // Escape was pressed, just stop listening without calling callback
           print("[KeyListenerNSView] Escape key pressed. Stopping listening without change.")
           DispatchQueue.main.async {
               isListeningBinding.wrappedValue = false
           }
      }
    }
  }
}

#Preview {
  struct Container: View {
    @State var text = "a"

    var body: some View {
      VStack(spacing: 20) {
        KeyButton(
          text: $text,
          placeholder: "Key",
          path: [0],
          onKeyChanged: { path, capturedKey in print("Key changed at path \(path) to: \(capturedKey)") }
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: ValidationError(
            path: [1],
            message: "Multiple actions for the same key 'a'",
            type: .duplicateKey,
            suggestion: "Change this key to a unique character"
          ),
          path: [1],
          onKeyChanged: { path, capturedKey in print("Key changed at path \(path) to: \(capturedKey)") }
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: ValidationError(
            path: [2],
            message: "Key is empty",
            type: .emptyKey,
            suggestion: "Click the key button and press a single character"
          ),
          path: [2],
          onKeyChanged: { path, capturedKey in print("Key changed at path \(path) to: \(capturedKey)") }
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: ValidationError(
            path: [3],
            message: "Key must be a single character",
            type: .nonSingleCharacterKey,
            severity: .warning,
            suggestion: "Use only one character (a-z, 0-9, or symbols)"
          ),
          path: [3],
          onKeyChanged: { path, capturedKey in print("Key changed at path \(path) to: \(capturedKey)") }
        )
        Text("Current value: '\(text)'")
      }
      .padding()
      .frame(width: 300)
    }
  }

  return Container()
}
