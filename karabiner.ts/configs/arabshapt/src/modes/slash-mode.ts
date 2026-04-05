import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 49: "slash-mode symbols"
// 60 manipulators
export const description = "slash-mode symbols"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "q",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "2",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "2",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
        },
        {
          "key_code": "q"
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
              "name": "slash-mode",
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
      "key_code": "w",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "semicolon"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "semicolon"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
        },
        {
          "key_code": "w"
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
              "name": "slash-mode",
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
      "key_code": "e",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "open_bracket"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "open_bracket"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "r",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "close_bracket"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "close_bracket"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
        },
        {
          "key_code": "r"
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
              "name": "slash-mode",
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
      "key_code": "t",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "6",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "6",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "1",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "1",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
          "shift"
        ],
        "key_code": "comma"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "comma"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
          "shift"
        ],
        "key_code": "period"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "period"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "equal_sign"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "equal_sign"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "7",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "7",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "backslash"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "backslash"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "slash"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "slash"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
          "shift"
        ],
        "key_code": "open_bracket"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "open_bracket"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "f",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "close_bracket"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "close_bracket"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "8",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "8",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "slash",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "slash",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "modifiers": [
          "shift"
        ],
        "key_code": "9"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "9"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "modifiers": [
          "shift"
        ],
        "key_code": "0"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "modifiers": [
          "shift"
        ],
        "key_code": "0"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "hyphen"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "hyphen"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "semicolon",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "semicolon",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "z",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "3",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "3",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "x",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "4",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "4",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
        },
        {
          "key_code": "x"
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
              "name": "slash-mode",
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
      "key_code": "c",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "backslash",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "backslash",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "grave_accent_and_tilde",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "grave_accent_and_tilde",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "b",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "grave_accent_and_tilde"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "grave_accent_and_tilde"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
        "key_code": "equal_sign",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "equal_sign",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "m",
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
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "5",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "comma",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "quote",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "quote",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
      "key_code": "period",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "hyphen",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "hyphen",
        "modifiers": [
          "left_shift"
        ]
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
        },
        {
          "key_code": "period"
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
              "name": "slash-mode",
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
      "key_code": "slash",
      "modifiers": {
        "optional": [
          "any"
        ]
      }
    },
    "to": [
      {
        "key_code": "semicolon"
      }
    ],
    "conditions": [
      {
        "name": "slash-mode",
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
          "name": "slash-mode",
          "value": 1
        }
      },
      {
        "key_code": "semicolon"
      }
    ],
    "from": {
      "simultaneous": [
        {
          "key_code": "slash"
        },
        {
          "key_code": "slash"
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
              "name": "slash-mode",
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
