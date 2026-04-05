import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 55: "a-mode"
// 30 manipulators
export const description = "a-mode"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "key_code": "t",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.Browser"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "t",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "n"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.Browser"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.Browser"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "m"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.Browser"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "comma"
    },
    "to": [
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.Browser"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "comma"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.Browser"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "key_code": "t",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "t",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "n"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "m"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "comma"
    },
    "to": [
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_command",
          "left_option"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "comma"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 1\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 1\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "j"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 2\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 2\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "k"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 3\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 3\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "l"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "semicolon"
    },
    "to": [
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 4\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"Goto harpoon file 4\"'"
      },
      {
        "key_code": "f2",
        "modifiers": [
          "left_control"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "semicolon"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.jetbrains.intellij"
        ]
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "key_code": "open_bracket",
        "modifiers": [
          "left_command",
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "open_bracket",
        "modifiers": [
          "left_command",
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "m"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "comma"
    },
    "to": [
      {
        "key_code": "close_bracket",
        "modifiers": [
          "left_command",
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "close_bracket",
        "modifiers": [
          "left_command",
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "comma"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "key_code": "open_bracket",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "open_bracket",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "j"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "key_code": "close_bracket",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "close_bracket",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "k"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "key_code": "l",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "conditions": [
      {
        "name": "a-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "type": "basic",
    "parameters": {
      "basic.simultaneous_threshold_milliseconds": 400
    },
    "to": [
      {
        "set_variable": {
          "name": "a-mode",
          "value": 1
        }
      },
      {
        "key_code": "l",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "a"
        },
        {
          "key_code": "l"
        }
      ],
      "simultaneous_options": {
        "detect_key_down_uninterruptedly": true,
        "key_down_order": "strict",
        "key_up_order": "strict_inverse",
        "key_up_when": "any",
        "to_after_key_up": [
          {
            "set_variable": {
              "name": "a-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      },
      {
        "identifiers": [
          {
            "product_id": 0,
            "vendor_id": 0
          }
        ],
        "type": "device_if"
      }
    ]
  }
]`)
