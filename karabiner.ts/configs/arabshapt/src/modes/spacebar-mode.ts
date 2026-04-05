import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 52: "spacebar-mode applications"
// 42 manipulators
export const description = "spacebar-mode applications"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "h",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "h",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "h",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "h"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "j",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "j",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "j",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "k",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "k",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "k",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "l",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "l",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "l",
        "modifiers": [
          "fn"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "left_command"
    },
    "to": [
      {
        "key_code": "5",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "5",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "left_command"
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
              "name": "spacebar-mode",
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
        "modifiers": [
          "left_option"
        ],
        "key_code": "delete_or_backspace"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "left_option"
        ],
        "key_code": "delete_or_backspace"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
        "key_code": "delete_or_backspace"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "delete_or_backspace"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "u",
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
        "key_code": "u"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "u"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "u"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "i",
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
        "key_code": "i"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "i"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "o",
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
        "key_code": "o"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "o"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "o"
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
              "name": "spacebar-mode",
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
        "modifiers": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ],
        "key_code": "d"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "d"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "y",
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
        "key_code": "f"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "f"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "y"
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
              "name": "spacebar-mode",
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
        "modifiers": [
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ],
        "key_code": "g"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "g"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "h",
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
        "key_code": "h"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "h"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "h"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "n",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "5",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "5",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "k",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "5",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "key_code": "5",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "l",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"open: MSTeams\"'"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "shell_command": "osascript -e 'tell application \"Keyboard Maestro Engine\" to do script \"open: MSTeams\"'"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "p",
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
        "key_code": "p"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "p"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "p"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "v",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "modifiers": [
          "command",
          "shift"
        ],
        "key_code": "v"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "command",
          "shift"
        ],
        "key_code": "v"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
        },
        {
          "key_code": "v"
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
              "name": "spacebar-mode",
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
      }
    ]
  },
  {
    "from": {
      "key_code": "semicolon",
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
        "key_code": "semicolon"
      }
    ],
    "conditions": [
      {
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
        "key_code": "semicolon"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
        "name": "spacebar-mode",
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
          "name": "spacebar-mode",
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
          "key_code": "spacebar"
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
              "name": "spacebar-mode",
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
      }
    ]
  }
]`)
