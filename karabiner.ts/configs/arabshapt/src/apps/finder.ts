import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 21: "Leader Key - Finder"
// 240 manipulators
export const description = "Leader Key - Finder"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1516293513
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1516293513"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
        "set_variable": {
          "name": "leader_state",
          "value": 957662702
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662702"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
        "set_variable": {
          "name": "leader_state",
          "value": 957662703
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662703"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "3"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 957662704
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662704"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      }
    ],
    "type": "basic"
  },
  {
    "from": {
      "key_code": "4"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 957662705
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662705"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662757
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662757"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662759
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662759"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662760
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662760"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662761
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662761"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662764
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662764"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662766
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662766"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
          "value": 957662772
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 957662772"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
        "value": 39965,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 39965,
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
      "key_code": "e"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1365114096
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365114096"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
          "value": 1365114108
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365114108"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
          "value": 1365114109
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365114109"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
          "value": 1365114110
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365114110"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
          "value": 1365114111
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365114111"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
          "value": 1365114116
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365114116"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
        "value": 957662702,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662702,
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
      "key_code": "spacebar"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=f20"
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
        "value": 957662703,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662703,
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
        "value": 957662703,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662703,
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
        "value": 957662703,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662703,
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
      "key_code": "f"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1365116275
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365116275"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662704,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662704,
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
        "set_variable": {
          "name": "leader_state",
          "value": 1365116276
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365116276"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662704,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662704,
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
          "value": 1365116288
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365116288"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662704,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662704,
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
          "value": 1365116290
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365116290"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662704,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662704,
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
        "value": 957662704,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662704,
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
        "value": 957662705,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662705,
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
        "value": 957662705,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662705,
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
        "value": 957662757,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662757,
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
        "value": 957662757,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662757,
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
        "value": 957662757,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662757,
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
        "value": 957662757,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662757,
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
        "value": 957662757,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662757,
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
          "value": 1365176165
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365176165"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
          "value": 1365176176
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365176176"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
          "value": 1365176183
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365176183"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
          "value": 1365176185
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365176185"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
        "value": 957662759,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662759,
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
      "key_code": "k"
    },
    "to": [
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "return_or_enter"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662760,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662760,
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
        "value": 957662760,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662760,
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
          "value": 1365178355
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365178355"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
          "value": 1365178357
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365178357"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
          "value": 1365178360
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365178360"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
          "value": 1365178365
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365178365"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
          "value": 1365178367
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365178367"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
        "value": 957662761,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662761,
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
          "value": 1365181619
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365181619"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
          "value": 1365181624
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365181624"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
          "value": 1365181632
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1365181632"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662764,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662764,
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
        "value": 957662766,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662766,
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
        "value": 957662766,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662766,
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
        "value": 957662766,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662766,
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
        "value": 957662766,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662766,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
        "value": 957662772,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 957662772,
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
      "key_code": "p"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=CS8"
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
        "value": 1365114096,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114096,
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
        "value": 1365114096,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114096,
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
      "key_code": "q"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=ArcFileArchiveTab"
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
        "value": 1365114108,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114108,
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
        "value": 1365114108,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114108,
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
      "key_code": "semicolon"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": ""
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
        "value": 1365114110,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114110,
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
            "target": "kmtrigger://macro=COSf1"
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
        "value": 1365114110,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114110,
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
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=COSf2"
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
        "value": 1365114110,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114110,
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
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=COSf3"
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
        "value": 1365114110,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114110,
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
            "target": ""
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
        "value": 1365114110,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114110,
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
        "value": 1365114110,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114110,
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
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=ArcDuplicateTab"
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
        "value": 1365114111,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114111,
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
            "target": "kmtrigger://macro=ArcPreviousTab"
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
        "value": 1365114111,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114111,
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
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=Cr"
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
        "value": 1365114111,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114111,
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
        "value": 1365114111,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114111,
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
      "key_code": "y"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=CSc"
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
        "value": 1365114116,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114116,
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
        "value": 1365114116,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365114116,
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
      "key_code": "f"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=GoToFile"
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
        "value": 1365116275,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116275,
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
        "value": 1365116275,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116275,
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
      "key_code": "period"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=Compare%20Current%20Branch"
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
        "value": 1365116276,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116276,
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
        "value": 1365116276,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116276,
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
            "target": "kmtrigger://macro=CSf"
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
        "value": 1365116288,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116288,
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
        "value": 1365116288,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116288,
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
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=CSf12"
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
        "value": 1365116290,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116290,
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
            "target": "kmtrigger://macro=optionf12"
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
        "value": 1365116290,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116290,
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
        "value": 1365116290,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365116290,
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
        "value": 1365176165,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176165,
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
        "value": 1365176165,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176165,
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
        "value": 1365176176,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176176,
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
        "value": 1365176176,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176176,
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
          "payload": "stateid 1529320795"
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
          "payload": "stateid 1529320792"
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
          "payload": "stateid 1529320791"
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
          "payload": "stateid 1529320780"
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
          "payload": "stateid 1529320776"
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
        "value": 1365176183,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176183,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
        "value": 1365176185,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365176185,
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
          "value": 1526955484
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1526955484"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1365178355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178355,
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
        "value": 1365178355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178355,
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
        "value": 1365178355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178355,
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
        "value": 1365178355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178355,
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
        "value": 1365178355,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178355,
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
          "value": 1526953295
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1526953295"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
          "payload": "stateid 1850794590"
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
        "value": 1365178357,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178357,
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
          "value": 1526950031
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1526950031"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178360,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178360,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178365,
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
        "value": 1365178367,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178367,
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
        "value": 1365178367,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178367,
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
        "value": 1365178367,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178367,
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
        "value": 1365178367,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365178367,
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
        "value": 1365181619,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181619,
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
        "value": 1365181619,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181619,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181624,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181624,
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
        "value": 1365181632,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181632,
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
        "value": 1365181632,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181632,
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
        "value": 1365181632,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1365181632,
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
        "value": 1516293513,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1516293513,
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
        "value": 1516293513,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1516293513,
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
        "value": 1526950031,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526950031,
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
        "value": 1526950031,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526950031,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526953295,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526953295,
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
        "value": 1526955484,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526955484,
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
        "value": 1526955484,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.apple.finder"
        ]
      },
      {
        "name": "leader_state",
        "value": 1526955484,
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
