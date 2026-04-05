import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 65: "tilde-mode kinesis"
// 18 manipulators
export const description = "tilde-mode kinesis"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
      "key_code": "g"
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
      "key_code": "s",
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
        "key_code": "s"
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ],
        "key_code": "j"
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
          "left_command",
          "left_option",
          "left_control",
          "left_shift"
        ],
        "key_code": "k"
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
      "key_code": "l",
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
        "key_code": "l"
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
      "key_code": "spacebar",
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
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      },
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
  }
]`)
