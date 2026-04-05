import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 51: "o-mode applications"
// 30 manipulators
export const description = "o-mode applications"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "shell_command": "open -a '/Applications/Visual Studio Code.app/Contents/MacOS/Electron'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/Applications/Visual Studio Code.app/Contents/MacOS/Electron'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "c"
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
              "name": "o-mode",
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
      "key_code": "b"
    },
    "to": [
      {
        "shell_command": "open -a '/System/Volumes/Data/Users/arabshaptukaev/Applications/Chrome Apps.localized/NotebookLM.app'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/System/Volumes/Data/Users/arabshaptukaev/Applications/Chrome Apps.localized/NotebookLM.app'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "b"
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
              "name": "o-mode",
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
      "key_code": "g"
    },
    "to": [
      {
        "shell_command": "open \"/System/Volumes/Data/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gemini.app\""
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open \"/System/Volumes/Data/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gemini.app\""
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "g"
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
              "name": "o-mode",
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
      "key_code": "n"
    },
    "to": [
      {
        "shell_command": "open \"/System/Volumes/Data/Applications/Notion.app\""
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open \"/System/Volumes/Data/Applications/Notion.app\""
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
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
              "name": "o-mode",
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
      "key_code": "m"
    },
    "to": [
      {
        "shell_command": "open \"/Applications/TickTick.app/Contents/MacOS/TickTick\""
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open \"/Applications/TickTick.app/Contents/MacOS/TickTick\""
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
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
              "name": "o-mode",
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
      "key_code": "g",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "shell_command": "open \"raycast://extensions/gdsmith/jetbrains/recent\""
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open \"raycast://extensions/gdsmith/jetbrains/recent\""
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "g"
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
              "name": "o-mode",
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
      "key_code": "s",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "shell_command": "open -a '/Applications/Notion.app/Contents/MacOS/Notion'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/Applications/Notion.app/Contents/MacOS/Notion'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "s"
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
              "name": "o-mode",
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
      "key_code": "z",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "shell_command": "open -a '/Applications/Warp.app/Contents/MacOS/stable'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/Applications/Warp.app/Contents/MacOS/stable'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "z"
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
              "name": "o-mode",
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
      "key_code": "t"
    },
    "to": [
      {
        "shell_command": "open -a '/Users/arabshaptukaev/Applications/Chrome Apps.localized/Microsoft Teams.app/Contents/MacOS/app_mode_loader'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/Users/arabshaptukaev/Applications/Chrome Apps.localized/Microsoft Teams.app/Contents/MacOS/app_mode_loader'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "t"
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
              "name": "o-mode",
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
      "key_code": "e"
    },
    "to": [
      {
        "shell_command": "open -a '/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gmail.app'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gmail.app'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "e"
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
              "name": "o-mode",
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
      "key_code": "f"
    },
    "to": [
      {
        "shell_command": "open -a '/System/Volumes/Data/Applications/Path Finder.app'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/System/Volumes/Data/Applications/Path Finder.app'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "f"
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
              "name": "o-mode",
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
      "key_code": "i"
    },
    "to": [
      {
        "shell_command": "open -a '/System/Volumes/Data/Applications/IntelliJ IDEA Ultimate.app'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/System/Volumes/Data/Applications/IntelliJ IDEA Ultimate.app'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "i"
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
              "name": "o-mode",
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
      "key_code": "a",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "shell_command": "open -a '/System/Volumes/Data/Applications/Arc.app'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/System/Volumes/Data/Applications/Arc.app'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "a"
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
              "name": "o-mode",
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
      "key_code": "d",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "shell_command": "open -a '/Applications/PDF Expert.app'"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -a '/Applications/PDF Expert.app'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "d"
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
              "name": "o-mode",
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
      "key_code": "equal_sign",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "modifiers": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ],
        "key_code": "equal_sign"
      }
    ],
    "conditions": [
      {
        "name": "o-mode",
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
          "name": "o-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ],
        "key_code": "equal_sign"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "o"
        },
        {
          "key_code": "equal_sign"
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
              "name": "o-mode",
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
