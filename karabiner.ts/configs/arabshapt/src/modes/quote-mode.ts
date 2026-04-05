import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 47: "quote-mode"
// 2 manipulators
export const description = "quote-mode"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "shell_command": "open -g 'raycast://confetti'"
      }
    ],
    "conditions": [
      {
        "name": "quote-mode",
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
          "name": "quote-mode",
          "value": 1
        }
      },
      {
        "shell_command": "open -g 'raycast://confetti'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "quote"
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
              "name": "quote-mode",
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
