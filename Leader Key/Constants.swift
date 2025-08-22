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
  0x12: "1", 0x13: "2", 0x14: "3", 0x15: "4", 0x17: "5",
  0x16: "6", 0x1A: "7", 0x1C: "8", 0x19: "9", 0x1D: "0",
  
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

// Shifted key mappings for US QWERTY layout
// These are the characters produced when holding Shift with the corresponding keys
let englishShiftedKeymap: [UInt16: String] = [
  // Numbers to symbols (top row)
  0x12: "!",   // Shift+1
  0x13: "@",   // Shift+2
  0x14: "#",   // Shift+3
  0x15: "$",   // Shift+4
  0x17: "%",   // Shift+5
  0x16: "^",   // Shift+6
  0x1A: "&",   // Shift+7
  0x1C: "*",   // Shift+8
  0x19: "(",   // Shift+9
  0x1D: ")",   // Shift+0
  
  // Punctuation and symbol shifts
  0x1B: "_",   // Shift+minus → underscore
  0x18: "+",   // Shift+equals → plus
  0x21: "{",   // Shift+[ → left brace
  0x1E: "}",   // Shift+] → right brace
  0x2A: "|",   // Shift+\ → pipe
  0x29: ":",   // Shift+; → colon
  0x27: "\"",  // Shift+' → double quote
  0x2B: "<",   // Shift+, → less than
  0x2F: ">",   // Shift+. → greater than
  0x2C: "?",   // Shift+/ → question mark
  0x32: "~",   // Shift+` → tilde
]
