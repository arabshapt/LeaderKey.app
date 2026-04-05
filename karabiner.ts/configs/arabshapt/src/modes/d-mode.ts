import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 53: "d-mode"
// 10 manipulators
export const description = "d-mode"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"CopyLink_with_rightclick\"'"
      }
    ],
    "conditions": [
      {
        "name": "d-mode",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_unless",
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
          "name": "d-mode",
          "value": 1
        }
      },
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"CopyLink_with_rightclick\"'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "d"
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
              "name": "d-mode",
              "value": 0
            }
          }
        ]
      }
    },
    "conditions": [
      {
        "type": "frontmost_application_unless",
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
      "key_code": "j"
    },
    "to": [
      {
        "key_code": "page_down"
      }
    ],
    "conditions": [
      {
        "name": "d-mode",
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
          "name": "d-mode",
          "value": 1
        }
      },
      {
        "key_code": "page_down"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "d"
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
              "name": "d-mode",
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
        "key_code": "page_up"
      }
    ],
    "conditions": [
      {
        "name": "d-mode",
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
          "name": "d-mode",
          "value": 1
        }
      },
      {
        "key_code": "page_up"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "d"
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
              "name": "d-mode",
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
        "name": "d-mode",
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
          "name": "d-mode",
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
          "key_code": "d"
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
              "name": "d-mode",
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
        "name": "d-mode",
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
          "name": "d-mode",
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
          "key_code": "d"
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
              "name": "d-mode",
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
  }
]`)
