import KeyboardShortcuts

// Key map for English characters based on US QWERTY keyboard layout
let englishKeymap: [UInt16: String] = [
  // Letters a-z
  0x00: "a", 0x0B: "b", 0x08: "c", 0x02: "d", 0x0E: "e", 0x03: "f",
  0x05: "g", 0x04: "h", 0x22: "i", 0x26: "j", 0x28: "k", 0x25: "l",
  0x2E: "m", 0x2D: "n", 0x1F: "o", 0x23: "p", 0x0C: "q", 0x0F: "r",
  0x01: "s", 0x11: "t", 0x20: "u", 0x09: "v", 0x0D: "w", 0x07: "x",
  0x10: "y", 0x06: "z",
  
  // Numbers 0-9
  0x12: "1", 0x13: "2", 0x14: "3", 0x15: "4", 0x16: "5",
  0x17: "6", 0x1A: "7", 0x19: "8", 0x1C: "9", 0x1D: "0",
  
  // Punctuation and symbols (non-shift versions)
  0x2B: ",",   // comma
  0x2F: ".",   // period
  0x2C: "/",   // forward slash
  0x29: ";",   // semicolon
  0x27: "'",   // apostrophe/single quote
  0x2A: "\\",  // backslash
  0x21: "[",   // left bracket
  0x1E: "]",   // right bracket
  0x1B: "-",   // minus/hyphen
  0x18: "=",   // equals
  0x32: "`",   // backtick/grave
  
  // Special keys
  0x24: "↵",   // Return/Enter (keeping existing symbol)
  0x30: "\t",  // Tab
  0x31: " ",   // Space
  0x33: "\u{0008}", // Backspace
  0x35: "\u{001B}", // Escape
  
  // Arrow keys
  0x7E: "↑", 0x7D: "↓", 0x7B: "←", 0x7C: "→"
]
