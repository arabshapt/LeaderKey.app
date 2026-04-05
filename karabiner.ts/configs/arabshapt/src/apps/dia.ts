import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 25: "Leader Key - Dia"
// 194 manipulators
export const description = "Leader Key - Dia"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 218499191
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 218499191"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625258
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625258"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625265
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625265"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625267
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625267"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625269
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625269"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625272
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625272"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625274
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625274"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
          "value": 256625280
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 256625280"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
        "key_code": "e",
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
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
        "value": 75009,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 75009,
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
        "value": 207837220,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207837220,
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
        "value": 207837220,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207837220,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207839409,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207839409,
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
        "value": 207842673,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207842673,
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
        "value": 207842673,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 207842673,
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
        "value": 218499191,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 218499191,
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
        "value": 218499191,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 218499191,
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
      "key_code": "i"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "e",
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
        "value": 256625258,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625258,
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
        "value": 256625258,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625258,
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
        "value": 256625265,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625265,
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
        "value": 256625265,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625265,
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
        "value": 256625265,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625265,
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
        "value": 256625265,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625265,
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
        "value": 256625265,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625265,
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
          "value": 292041352
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292041352"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
          "value": 292041363
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292041363"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
          "value": 292041370
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292041370"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
          "value": 292041372
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292041372"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
        "value": 256625267,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625267,
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
          "value": 292043542
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292043542"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
          "value": 292043544
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292043544"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
          "value": 292043547
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292043547"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
          "value": 292043552
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292043552"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
          "value": 292043554
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292043554"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
        "value": 256625269,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625269,
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
          "value": 292046806
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292046806"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
          "value": 292046811
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292046811"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
          "value": 292046819
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 292046819"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625272,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625272,
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
        "value": 256625274,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625274,
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
        "value": 256625274,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625274,
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
        "value": 256625274,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625274,
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
        "value": 256625274,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625274,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 256625280,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 256625280,
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
        "value": 292041352,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041352,
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
        "value": 292041352,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041352,
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
        "value": 292041363,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041363,
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
        "value": 292041363,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041363,
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
          "payload": "stateid 205471909"
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
          "payload": "stateid 205471912"
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
          "payload": "stateid 205471913"
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
          "payload": "stateid 205471924"
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
          "payload": "stateid 205471928"
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
        "value": 292041370,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041370,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
        "value": 292041372,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292041372,
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
          "value": 207837220
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 207837220"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 292043542,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043542,
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
        "value": 292043542,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043542,
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
        "value": 292043542,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043542,
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
        "value": 292043542,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043542,
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
        "value": 292043542,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043542,
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
          "value": 207839409
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 207839409"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
          "payload": "stateid 604634031"
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
        "value": 292043544,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043544,
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
          "value": 207842673
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 207842673"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043547,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043547,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043552,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043552,
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
        "value": 292043554,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043554,
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
        "value": 292043554,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043554,
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
        "value": 292043554,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043554,
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
        "value": 292043554,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292043554,
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
        "value": 292046806,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046806,
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
        "value": 292046806,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046806,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046811,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046811,
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
        "value": 292046819,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046819,
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
        "value": 292046819,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046819,
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
        "value": 292046819,
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
          "company.thebrowser.dia"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "company.thebrowser.dia"
        ]
      },
      {
        "name": "leader_state",
        "value": 292046819,
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
