import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 17: "Leader Key - Bitwarden"
// 203 manipulators
export const description = "Leader Key - Bitwarden"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 877563256
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 877563256"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175025
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175025"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175023
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175023"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175022
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175022"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175021
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175021"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175018
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175018"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
        "set_variable": {
          "name": "leader_state",
          "value": 84175017
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175017"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175016
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175016"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175012
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175012"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175010
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175010"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
          "value": 84175008
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 84175008"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
        "value": 66305,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 66305,
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
        "value": 84175008,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175008,
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
        "value": 84175008,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175008,
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
        "value": 84175008,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175008,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
        "value": 84175010,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175010,
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
      "key_code": "u"
    },
    "to": [
      {
        "send_user_command": {
          "payload": {
            "v": 1,
            "type": "open",
            "background": true,
            "target": "kmtrigger://macro=Anything"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175012,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175012,
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
        "value": 84175012,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175012,
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
        "value": 84175016,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175016,
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
        "value": 84175016,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175016,
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
        "value": 84175016,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175016,
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
        "value": 84175016,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175016,
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
          "payload": "stateid 1472266894"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175017,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175017,
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
        "value": 84175017,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175017,
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
          "value": 1472267992
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472267992"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
          "value": 1472267987
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472267987"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
          "value": 1472267979
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472267979"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
        "value": 84175018,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175018,
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
          "value": 1472271256
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472271256"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
          "value": 1472271254
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472271254"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
          "value": 1472271251
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472271251"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
          "value": 1472271246
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472271246"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
          "value": 1472271244
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472271244"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
        "value": 84175021,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175021,
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
        "value": 84175022,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175022,
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
        "value": 84175022,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175022,
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
          "value": 1472273446
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472273446"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
          "value": 1472273435
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472273435"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
          "value": 1472273428
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472273428"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
          "value": 1472273426
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1472273426"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175023,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175023,
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
        "value": 84175025,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175025,
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
        "value": 84175025,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175025,
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
        "value": 84175025,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175025,
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
        "value": 84175025,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175025,
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
        "value": 84175025,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 84175025,
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
        "value": 866901285,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866901285,
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
        "value": 866901285,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866901285,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866903474,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866903474,
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
        "value": 866906738,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866906738,
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
        "value": 866906738,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 866906738,
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
        "value": 877563256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 877563256,
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
        "value": 877563256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 877563256,
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
        "value": 1472267979,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267979,
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
        "value": 1472267979,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267979,
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
        "value": 1472267979,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267979,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267987,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267987,
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
        "value": 1472267992,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267992,
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
        "value": 1472267992,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472267992,
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
        "value": 1472271244,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271244,
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
        "value": 1472271244,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271244,
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
        "value": 1472271244,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271244,
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
        "value": 1472271244,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271244,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
        "value": 1472271246,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271246,
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
          "value": 866906738
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 866906738"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
        "value": 1472271251,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271251,
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
          "value": 866903474
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 866903474"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
          "payload": "stateid 1296745203"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
        "value": 1472271254,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271254,
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
          "value": 866901285
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 866901285"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472271256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271256,
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
        "value": 1472271256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271256,
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
        "value": 1472271256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271256,
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
        "value": 1472271256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271256,
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
        "value": 1472271256,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472271256,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
        "value": 1472273426,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273426,
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
          "payload": "stateid 864535974"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
          "payload": "stateid 864535977"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
          "payload": "stateid 864535978"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
          "payload": "stateid 864535989"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
          "payload": "stateid 864535993"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
        "value": 1472273428,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273428,
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
        "value": 1472273435,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273435,
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
        "value": 1472273435,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273435,
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
        "value": 1472273446,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273446,
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
        "value": 1472273446,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.bitwarden.desktop"
        ]
      },
      {
        "name": "leader_state",
        "value": 1472273446,
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
