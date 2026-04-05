import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule 30: "Leader Key - Gemini Chrome"
// 271 manipulators
export const description = "Leader Key - Gemini Chrome"

export const manipulators: Manipulator[] = JSON.parse(String.raw`[
  {
    "from": {
      "key_code": "spacebar"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 243076147
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 243076147"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264117
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264117"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264119
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264119"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264120
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264120"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
        "set_variable": {
          "name": "leader_state",
          "value": 940264121
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264121"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264122
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264122"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264123
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264123"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264124
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264124"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264125
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264125"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264126
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264126"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264127
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264127"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264129
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264129"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264131
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264131"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264132
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264132"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264133
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264133"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
        "set_variable": {
          "name": "leader_state",
          "value": 940264134
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264134"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264135
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264135"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "value": 940264137
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264137"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
        "set_variable": {
          "name": "leader_state",
          "value": 940264138
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 940264138"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
      "key_code": "2"
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
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
          "payload": "stateid 219365436"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
        "value": 95885,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 95885,
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
        "value": 232414176,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232414176,
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
        "value": 232414176,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232414176,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232416365,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232416365,
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
        "value": 232419629,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232419629,
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
        "value": 232419629,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 232419629,
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
            "target": "raycast://extensions/erics118/change-case/change-case?context=%7B%22case%22%3A%22Upper%20Case%22%7D"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 243076147,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 243076147,
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
        "value": 243076147,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 243076147,
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
      "key_code": "g"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1745406002
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745406002"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264117,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264117,
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
        "value": 940264117,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264117,
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
        "value": 940264117,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264117,
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
        "key_code": "y",
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
        "value": 940264119,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264119,
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
        "key_code": "n",
        "modifiers": [
          "left_command",
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
        "value": 940264119,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264119,
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
        "key_code": "l",
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
        "value": 940264119,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264119,
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
        "value": 940264119,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264119,
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
        "value": 940264119,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264119,
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
        "value": 940264120,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264120,
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
        "value": 940264120,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264120,
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
        "value": 940264120,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264120,
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
        "value": 940264120,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264120,
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
        "value": 940264120,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264120,
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
          "payload": "deactivate"
        }
      },
      {
        "key_code": "8",
        "modifiers": [
          "left_command",
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
        "value": 940264121,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264121,
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
        "value": 940264121,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264121,
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
          "value": 1745411441
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745411441"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
          "value": 1745411452
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745411452"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
          "value": 1745411459
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745411459"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
          "value": 1745411461
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745411461"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
        "value": 940264122,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264122,
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
          "payload": "deactivate"
        }
      },
      {
        "key_code": "l",
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
        "value": 940264123,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264123,
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
        "value": 940264123,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264123,
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
        "value": 940264123,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264123,
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
        "key_code": "r",
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
        "value": 940264123,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264123,
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
        "value": 940264123,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264123,
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
        "value": 940264123,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264123,
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
          "value": 1745413631
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745413631"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
          "value": 1745413633
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745413633"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
          "value": 1745413636
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745413636"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
          "value": 1745413641
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745413641"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
          "value": 1745413643
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745413643"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
        "value": 940264124,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264124,
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
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "d",
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
        "value": 940264125,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264125,
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
        "value": 940264125,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264125,
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
      "key_code": "comma"
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
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
            "type": "menu",
            "app": "Google Chrome",
            "path": "Tab > Duplicate Tab"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "payload": "deactivate"
        }
      },
      {
        "key_code": "d",
        "modifiers": [
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
      "key_code": "d"
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "key_code": "o",
        "modifiers": [
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "key_code": "open_bracket",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "key_code": "spacebar"
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "key_code": "spacebar",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "key_code": "close_bracket",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "payload": "deactivate"
        }
      },
      {
        "key_code": "left_arrow",
        "modifiers": [
          "left_command",
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
        "value": 940264126,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264126,
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
          "value": 1745416895
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745416895"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
          "value": 1745416900
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745416900"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
          "value": 1745416908
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745416908"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264127,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264127,
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
        "value": 940264129,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264129,
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
        "value": 940264129,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264129,
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
        "value": 940264129,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264129,
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
        "value": 940264129,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264129,
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
        "key_code": "y",
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
        "value": 940264131,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264131,
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
          "left_command",
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
        "value": 940264131,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264131,
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
            "target": "raycast://extensions/the-browser-company/arc/search-tabs"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264131,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264131,
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
        "value": 940264131,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264131,
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
      "key_code": "d"
    },
    "to": [
      {
        "shell_command": "/opt/homebrew/bin/zsh -l -c ' menu click Chrome \"Tab > Duplicate Tab\" --no-visual'"
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264132,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264132,
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
          "left_command",
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
        "value": 940264132,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264132,
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
        "value": 940264132,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264132,
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
          "payload": "stateid 1745422346"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264132,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264132,
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
        "key_code": "r",
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
        "value": 940264132,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264132,
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
        "value": 940264132,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264132,
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
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "key_code": "s",
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
        "value": 940264133,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264133,
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
            "target": "kmtrigger://macro=Cs"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264133,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264133,
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
        "value": 940264133,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264133,
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
          "payload": "deactivate"
        }
      },
      {
        "key_code": "equal_sign",
        "modifiers": [
          "left_control",
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
        "value": 940264134,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264134,
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
            "target": "kmtrigger://macro=SeparatePagefromSplitView"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264134,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264134,
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
        "value": 940264134,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264134,
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
      "key_code": "w"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1745425620
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745425620"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
        "value": 940264135,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264135,
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
            "target": "kmtrigger://macro=exportToPdfConfluence"
          }
        }
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264137,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264137,
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
        "shell_command": "/opt/homebrew/bin/zsh -l -c 'osascript -e '\\''tell application \"Google Chrome\" to return URL of active tab of front window'\\'' | pbcopy'"
      },
      {
        "send_user_command": {
          "payload": "deactivate"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264137,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264137,
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
        "value": 940264137,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264137,
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
      "key_code": "g"
    },
    "to": [
      {
        "set_variable": {
          "name": "leader_state",
          "value": 1745428871
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 1745428871"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 940264138,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264138,
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
        "value": 940264138,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264138,
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
        "value": 940264138,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 940264138,
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
        "value": 1745406002,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745406002,
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
        "value": 1745406002,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745406002,
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
        "value": 1745411441,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411441,
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
        "value": 1745411441,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411441,
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
        "value": 1745411452,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411452,
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
        "value": 1745411452,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411452,
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
          "payload": "stateid 230048865"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
          "payload": "stateid 230048868"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
          "payload": "stateid 230048869"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
          "payload": "stateid 230048880"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
          "payload": "stateid 230048884"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
        "value": 1745411459,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411459,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
        "value": 1745411461,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745411461,
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
          "value": 232414176
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 232414176"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745413631,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413631,
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
        "value": 1745413631,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413631,
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
        "value": 1745413631,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413631,
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
        "value": 1745413631,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413631,
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
        "value": 1745413631,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413631,
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
          "value": 232416365
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 232416365"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
          "payload": "stateid 2081910788"
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_active",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_global",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leaderkey_appspecific",
          "value": 0
        }
      },
      {
        "set_variable": {
          "name": "leader_state",
          "value": 0
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
        "value": 1745413633,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413633,
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
          "value": 232419629
        }
      },
      {
        "send_user_command": {
          "payload": "stateid 232419629"
        }
      }
    ],
    "conditions": [
      {
        "name": "leader_state",
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413636,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413636,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413641,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413641,
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
        "value": 1745413643,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413643,
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
        "value": 1745413643,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413643,
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
        "value": 1745413643,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413643,
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
        "value": 1745413643,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745413643,
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
        "value": 1745416895,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416895,
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
        "value": 1745416895,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416895,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416900,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416900,
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
        "value": 1745416908,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416908,
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
        "value": 1745416908,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416908,
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
        "value": 1745416908,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745416908,
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
        "value": 1745425620,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745425620,
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
        "value": 1745425620,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745425620,
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
        "value": 1745425620,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745425620,
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
        "value": 1745425620,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745425620,
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
        "value": 1745428871,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745428871,
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
        "value": 1745428871,
        "type": "variable_if"
      },
      {
        "name": "leaderkey_global",
        "value": 1,
        "type": "variable_unless"
      },
      {
        "name": "leaderkey_appspecific",
        "value": 1,
        "type": "variable_if"
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "type": "frontmost_application_if",
        "bundle_identifiers": [
          "com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn"
        ]
      },
      {
        "name": "leader_state",
        "value": 1745428871,
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
