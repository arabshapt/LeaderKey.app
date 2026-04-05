import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 9: "Leader Key - Ghostty"
// 230 manipulators
export const description = "Leader Key - Ghostty"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "left_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "caps_lock-mode",
        "value": 1,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "caps_lock-mode",
        "value": 1,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "right_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "caps_lock-mode",
        "value": 1,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "caps_lock-mode",
        "value": 1,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1496369035
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1496369035"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116342
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116342"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116349
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116349"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116351
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116351"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116352
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116352"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116353
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116353"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116355
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116355"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_sticky",
          "value": 1
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "o"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116356
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116356"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "q"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116358
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116358"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116360
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116360"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116361
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116361"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "w"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1425116364
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1425116364"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "left_arrow"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "left_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "up_arrow"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "right_arrow"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "right_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "down_arrow"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 75310,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "r"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/rexx HR - chrome - dev.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964734,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964734,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/AGIS-Portal-chrome-dev.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964734,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964734,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964734,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964734,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "1"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/ChatGPT.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Utilities/Activity Monitor.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Calendar.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Dia.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "e"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Keyboard Maestro.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Arc.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "i"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Miro.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Calendar.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "8",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Messages.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Comet.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "r"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Stremio.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Google AI Studio.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/AGIS-Portal-chrome-dev.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "v"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/VLC.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964742,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Codex.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964747,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964747,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678964747,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678964747,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "cleanshot://capture-area"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "cleanshot://capture-area?action=copy"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "2",
        "modifiers": [
          "left_command",
          "left_option",
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678967999,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/center-three-fourths"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://script-commands/next-fullscreen-display"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/toggle-fullscreen"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/left-half"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/right-half"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/maximize"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=Ttab"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968001,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1485712517
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1485712517"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/system/open-camera"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/dictionary/define-word"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "e"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/EvanZhouDev/raycast-gemini/askAI?arguments=%7B%22query%22%3A%22%22%7D"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/EvanZhouDev/raycast-gemini/aiChat"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "i"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": false,
            "target": "raycast://extensions/gdsmith/jetbrains/recent"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/raycast-notes/raycast-notes"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://confetti"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "q"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "escape",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "key_code": "escape"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/typing-practice/start-typing-practice"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "w"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=closeRaycast"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968006,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "o"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1485709253
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1485709253"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "stateid 782607250"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Arc.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "b"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/NotebookLM.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Visual Studio Code.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/PDF Expert.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "e"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gmail.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Path Finder.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gemini.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "i"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/IntelliJ IDEA Ultimate.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Jira_Stihl.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Karabiner-EventViewer.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/calibre.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Microsoft Teams.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Stickies.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Things3.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Notion.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Warp.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "x"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Xcode.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968009,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1485707064
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1485707064"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "shortcuts://run-shortcut?name=Low Power on"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "shell_command": "/opt/homebrew/bin/zsh -l -c 'open -a \"/System/Applications/Mission Control.app\"'"
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "shortcuts://run-shortcut?name=High Power on"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678968011,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "o"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "key_code": "o",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "u"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "key_code": "a"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "o"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "key_code": "o"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "s",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "u"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "u",
        "modifiers": [
          "left_option"
        ]
      },
      {
        "key_code": "u"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970181,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "stateid 1483341753"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "stateid 1483341756"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "e"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "stateid 1483341757"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "stateid 1483341768"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/joshmedeski/sesh/cmd-connect"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "stateid 1483341772"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "b"
    },
    "to": [
      {
        "shell_command": "/opt/homebrew/bin/zsh -l -c 'open -a \"Arc\" \"https://jira01.com.stihlgroup.net/secure/RapidBoard.jspa?projectKey=CONN&rapidView=2654\"'"
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970190,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970190,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970190,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970190,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/joshmedeski/sesh/cmd-connect"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970201,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970201,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 678970201,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 678970201,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "left_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "right_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116342,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "d",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "f",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "s",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116349,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678970201
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678970201"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678970190
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678970190"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678970183
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678970183"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "u"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678970181
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678970181"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/system/open-camera"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/dictionary/define-word"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "e"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/EvanZhouDev/raycast-gemini/askAI?arguments=%7B%22query%22%3A%22%22%7D"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/EvanZhouDev/raycast-gemini/aiChat"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "i"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": false,
            "target": "raycast://extensions/gdsmith/jetbrains/recent"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/raycast-notes/raycast-notes"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "tab",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "key_code": "vk_none"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "q"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "w",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "r"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "spacebar",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/typing-practice/start-typing-practice"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "w"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=closeRaycast"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116351,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "left_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "down_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "up_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "left_arrow",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116352,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678968011
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678968011"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "o"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678968009
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678968009"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "r"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678968006
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678968006"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "w"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678968001
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678968001"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "y"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678967999
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678967999"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "d",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "f",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "s",
        "modifiers": [
          "fn"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116353,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "set_variable": {
          "name": "leaderkey_sticky",
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
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116355,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "set_variable": {
          "name": "leaderkey_sticky",
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
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116355,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "j"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678964747
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678964747"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "o"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678964742
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678964742"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "w"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 678964734
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 678964734"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "8",
        "modifiers": [
          "left_command",
          "left_control",
          "left_option",
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "1"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Claude.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "2"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Cursor.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "g"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gemini.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Google Chrome.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "b"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/NotebookLM.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Visual Studio Code.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/PDF Expert.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "e"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gmail.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Path Finder.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/GoogleGeminiArab.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Postman.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "i"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/IntelliJ IDEA.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Karabiner-EventViewer.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/calibre.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Microsoft Teams.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "n"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Stickies.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Things3.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "q"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Codex.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "r"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Ghostty.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Notion.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Ghostty.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "v"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Bitwarden.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "x"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Xcode.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "y"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Antigravity.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "z"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Arc.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116356,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "escape",
        "modifiers": [
          "left_command",
          "left_option",
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "q"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "q",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "q"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "w",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116358,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/joshmedeski/sesh/cmd-connect"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116360,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "shift"
        ]
      },
      "key_code": "slash"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "slash",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "open_bracket"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "g"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "l"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "l",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "t",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "z"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "z"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116361,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "hyphen"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "tilde-mode",
        "value": 1,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "hyphen"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "hyphen"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/center-three-fourths"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://script-commands/next-fullscreen-display"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/toggle-fullscreen"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "h"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/left-half"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "l"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/right-half"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "raycast://extensions/raycast/window-management/maximize"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=Ttab"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "v"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "backslash",
        "modifiers": [
          "left_shift"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "x"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "a",
        "modifiers": [
          "left_control"
        ]
      },
      {
        "key_code": "x"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1425116364,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "z"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Zen.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485707064,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485707064,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485707064,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485707064,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Utilities/Activity Monitor.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "c"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Cursor.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "d"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Dia.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Google Chrome.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Calendar.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "m"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/System/Applications/Messages.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Comet.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "r"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/Stremio.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "s"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Chrome Apps.localized/Google AI Studio.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "t"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Users/arabshaptukaev/Applications/Edge Apps.localized/Ausy:Randstad AGIS-Portal.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "v"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open_app",
            "app": "/Applications/VLC.app"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485709253,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "b"
    },
    "to": [
      {
        "shell_command": "/opt/homebrew/bin/zsh -l -c 'open -a \"Arc\" \"https://jira01.com.stihlgroup.net/secure/RapidBoard.jspa?projectKey=CONN&rapidView=2654\"'"
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485712517,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485712517,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1485712517,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1485712517,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "a"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "t",
        "modifiers": [
          "left_command"
        ]
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1496369035,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1496369035,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "modifiers": {
        "mandatory": [
          "any"
        ]
      },
      "any": "key_code"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "shake"
        }
      },
      {
        "key_code": "vk_none"
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1496369035,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.mitchellh.ghostty"
        ]
      },
      {
        "name": "leader_state",
        "value": 1496369035,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_sticky",
        "value": 0,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  }
]`)
