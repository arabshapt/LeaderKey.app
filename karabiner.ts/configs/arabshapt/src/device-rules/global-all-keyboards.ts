import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 35: "global all keyboards"
// 22 manipulators
export const description = "global all keyboards"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "caps_lock",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "fn"
      }
    ],
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 866,
            "vendor_id": 10730
          },
          {
            "product_id": 24926,
            "vendor_id": 7504
          },
          {
            "product_id": 10203,
            "vendor_id": 5824
          },
          {
            "product_id": 45074,
            "vendor_id": 1133
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "application",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "caps_lock"
      }
    ],
    "conditions": [
      {
        "identifiers": [
          {
            "product_id": 866,
            "vendor_id": 10730
          },
          {
            "product_id": 24926,
            "vendor_id": 7504
          },
          {
            "product_id": 10203,
            "vendor_id": 5824
          },
          {
            "product_id": 45074,
            "vendor_id": 1133
          }
        ],
        "type": "device_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "keypad_7"
    },
    "to": [
      {
        "modifiers": [
          "command",
          "shift",
          "control"
        ],
        "key_code": "f10"
      },
      {
        "key_code": "vk_none"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "keypad_5"
    },
    "to": [
      {
        "modifiers": [
          "command",
          "control",
          "option"
        ],
        "key_code": "f9"
      },
      {
        "key_code": "vk_none"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "keypad_3"
    },
    "to": [
      {
        "modifiers": [
          "command",
          "control",
          "option"
        ],
        "key_code": "f8"
      },
      {
        "key_code": "vk_none"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "close_bracket"
    },
    "to": [
      {
        "key_code": "delete_or_backspace"
      }
    ],
    "conditions": [
      {
        "name": "tilde-mode",
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
    "from": {
      "key_code": "close_bracket"
    },
    "to": [
      {
        "modifiers": [
          "command",
          "shift",
          "control"
        ],
        "key_code": "f10"
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
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
    "from": {
      "modifiers": {
        "mandatory": [
          "fn",
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "a"
    },
    "to": [
      {
        "key_code": "spacebar"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "fn",
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "o"
    },
    "to": [
      {
        "key_code": "v",
        "modifiers": [
          "left_command",
          "left_shift"
        ]
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "fn",
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "k"
    },
    "to": [
      {
        "key_code": "return_or_enter"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "fn",
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "period"
    },
    "to": [
      {
        "key_code": "z",
        "modifiers": [
          "left_command"
        ]
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "fn",
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "p"
    },
    "to": [
      {
        "key_code": "z",
        "modifiers": [
          "left_command",
          "left_shift"
        ]
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ]
      },
      "key_code": "f12"
    },
    "to": [
      {
        "shell_command": "open -g 'raycast://extensions/raycast/clipboard-history/clipboard-history'"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "close_bracket"
    },
    "to": [
      {
        "key_code": "mission_control"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "period"
    },
    "to": [
      {
        "consumer_key_code": "display_brightness_decrement"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "p"
    },
    "to": [
      {
        "consumer_key_code": "display_brightness_increment"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "a"
    },
    "to": [
      {
        "consumer_key_code": "mute"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "o"
    },
    "to": [
      {
        "consumer_key_code": "volume_decrement"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "e"
    },
    "to": [
      {
        "consumer_key_code": "play_or_pause"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "left_shift",
          "right_command",
          "left_option",
          "right_option"
        ]
      },
      "key_code": "u"
    },
    "to": [
      {
        "consumer_key_code": "volume_increment"
      }
    ],
    "type": "basic"
  },
  {
    "to_if_alone": [
      {
        "pointing_button": "button2"
      }
    ],
    "to_if_held_down": [
      {
        "modifiers": [
          "fn",
          "left_command",
          "left_option",
          "left_control"
        ],
        "key_code": "left_shift"
      }
    ],
    "parameters": {
      "basic.to_if_alone_timeout_milliseconds": 200,
      "basic.to_if_held_down_threshold_milliseconds": 199
    },
    "from": {
      "pointing_button": "button2"
    },
    "type": "basic"
  },
  {
    "to_if_alone": [
      {
        "pointing_button": "button4"
      }
    ],
    "to_if_held_down": [
      {
        "modifiers": [
          "fn",
          "left_command",
          "left_option",
          "left_control"
        ],
        "key_code": "left_shift"
      }
    ],
    "parameters": {
      "basic.to_if_alone_timeout_milliseconds": 0,
      "basic.to_if_held_down_threshold_milliseconds": 0
    },
    "from": {
      "pointing_button": "button4"
    },
    "type": "basic"
  }
]`)
