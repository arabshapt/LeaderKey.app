import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 66: "kinesis-amps-mode kinesis"
// 11 manipulators
export const description = "kinesis-amps-mode kinesis"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
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
        "name": "kinesis-amps-mode",
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
      "key_code": "b",
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
        "key_code": "b"
      }
    ],
    "conditions": [
      {
        "name": "kinesis-amps-mode",
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
        "name": "kinesis-amps-mode",
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
        "key_code": "j"
      }
    ],
    "conditions": [
      {
        "name": "kinesis-amps-mode",
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
      "key_code": "t",
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
        "name": "kinesis-amps-mode",
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
      "key_code": "n",
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
        "name": "kinesis-amps-mode",
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
        "key_code": "semicolon"
      }
    ],
    "conditions": [
      {
        "name": "kinesis-amps-mode",
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
        "key_code": "p"
      }
    ],
    "conditions": [
      {
        "name": "kinesis-amps-mode",
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
        "key_code": "u"
      }
    ],
    "conditions": [
      {
        "name": "kinesis-amps-mode",
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
      "key_code": "c",
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
        "name": "kinesis-amps-mode",
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
      "key_code": "r",
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
        "name": "kinesis-amps-mode",
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
