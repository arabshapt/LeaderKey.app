import AppKit
import SwiftUI

struct KeyButton: View {
  @Binding var text: String
  let placeholder: String
  @State private var isListening = false
  var validationError: ValidationErrorType? = nil
  var onKeyChanged: ((String) -> Void)? = nil

  var body: some View {
    Button(action: {
      isListening = true
    }) {
      Text(text.isEmpty ? placeholder : text)
        .frame(width: 32, height: 24)
        .background(
          RoundedRectangle(cornerRadius: 5)
            .fill(backgroundColor)
            .overlay(
              RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: 1)
            )
        )
        .foregroundColor(text.isEmpty ? .gray : .primary)
    }
    .buttonStyle(PlainButtonStyle())
    .background(
      KeyListenerView(isListening: $isListening, onKeyChanged: onKeyChanged)
    )
  }

  private var backgroundColor: Color {
    if isListening {
      return Color.blue.opacity(0.2)
    } else if validationError != nil {
      return Color.red.opacity(0.1)
    } else {
      return Color(.controlBackgroundColor)
    }
  }

  private var borderColor: Color {
    if isListening {
      return Color.blue
    } else if validationError != nil {
      return Color.red
    } else {
      return Color.gray.opacity(0.5)
    }
  }
}

struct KeyListenerView: NSViewRepresentable {
  @Binding var isListening: Bool
  var onKeyChanged: ((String) -> Void)?

  func makeNSView(context: Context) -> NSView {
    let view = KeyListenerNSView()
    view.isListening = $isListening
    view.onKeyChanged = onKeyChanged
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    if let view = nsView as? KeyListenerNSView {
      view.isListening = $isListening
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
    var onKeyChanged: ((String) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
    }

    override func keyDown(with event: NSEvent) {
      guard let isListeningBinding = isListening, isListeningBinding.wrappedValue else {
        super.keyDown(with: event)
        return
      }
      
      var capturedKey: String? = nil
      
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
          print("[KeyListenerNSView] KeyDown captured: '\(finalKey)'. Stopping listening.")
          DispatchQueue.main.async {
            isListeningBinding.wrappedValue = false
            // Pass the captured key string back
            self.onKeyChanged?(finalKey) 
          }
      } else {
           // Escape was pressed, just stop listening without calling callback
           print("[KeyListenerNSView] Escape key pressed. Stopping listening without change.")
           DispatchQueue.main.async {
               isListeningBinding.wrappedValue = false
           }
      }
    }

    override func resignFirstResponder() -> Bool {
      if let isListeningBinding = isListening, isListeningBinding.wrappedValue {
         print("[KeyListenerNSView] Resign first responder while listening. Stopping listening.")
         DispatchQueue.main.async {
            isListeningBinding.wrappedValue = false
         }
      }
      return super.resignFirstResponder()
    }
  }
}

#Preview {
  // Add placeholder definitions needed for Preview
  enum ValidationErrorType { case duplicateKey, emptyKey, nonSingleCharacterKey }
  class UserConfig: ObservableObject {}

  struct Container: View {
    @State var text = "a"
    @StateObject var userConfig = UserConfig()

    var body: some View {
      VStack(spacing: 20) {
        KeyButton(
          text: $text,
          placeholder: "Key",
          // Update closure to accept the String argument
          onKeyChanged: { capturedKey in print("Key changed to: \(capturedKey)") } 
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: .duplicateKey,
          // Update closure to accept the String argument
          onKeyChanged: { capturedKey in print("Key changed to: \(capturedKey)") } 
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: .emptyKey,
          // Update closure to accept the String argument
          onKeyChanged: { capturedKey in print("Key changed to: \(capturedKey)") } 
        )
        KeyButton(
          text: $text,
          placeholder: "Key",
          validationError: .nonSingleCharacterKey,
          // Update closure to accept the String argument
          onKeyChanged: { capturedKey in print("Key changed to: \(capturedKey)") } 
        )
        Text("Current value: '\(text)'")
      }
      .padding()
      .frame(width: 300)
      .environmentObject(userConfig)
    }
  }

  return Container()
}
