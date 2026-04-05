import { map } from '../../../src/config/from.ts'
import { ifVar } from '../../../src/config/condition.ts'
import { toSetVar, toSendUserCommand } from '../../../src/config/to.ts'
import { apple_built_in } from './devices.ts'

// Rule 1: "Caps layer (built-in, unless leader_mode)"
// Caps lock as layer key: hold = caps_lock-mode, tap = escape or reset leader state
export const description = 'Caps layer (built-in, unless leader_mode)'

const resetLeaderVars = [
  toSetVar('leaderkey_active', 0),
  toSetVar('lk_on', 0),
  toSetVar('lk_0', 0),
  toSetVar('lk_1', 0),
  toSetVar('lk_2', 0),
  toSetVar('lka_0', 0),
  toSetVar('lka_1', 0),
  toSetVar('lka_2', 0),
  toSetVar('lkst_0', 0),
  toSetVar('lkst_1', 0),
  toSetVar('lkst_2', 0),
  toSetVar('leaderkey_global', 0),
  toSetVar('leaderkey_fallback', 0),
  toSetVar('leader_mode', 0),
  toSetVar('leader_state', 0),
  toSendUserCommand('deactivate'),
]

export const manipulators = [
  // When leaderkey_active: tap caps = reset all leader state
  ...map('caps_lock')
    .toVar('caps_lock-mode', 1)
    .toIfAlone([
      ...resetLeaderVars,
      toSetVar('leaderkey_active', 0),
      toSetVar('leaderkey_global', 0),
      toSetVar('leaderkey_appspecific', 0),
      toSetVar('leaderkey_sticky', 0),
      toSetVar('leader_state', 0),
      toSendUserCommand('deactivate'),
    ])
    .toAfterKeyUp(toSetVar('caps_lock-mode', 0))
    .condition(ifVar('leaderkey_active', 1))
    .condition(apple_built_in)
    .build(),
  // When lk_on not active: tap caps = escape
  ...map('caps_lock')
    .toVar('caps_lock-mode', 1)
    .toIfAlone('escape')
    .toAfterKeyUp(toSetVar('caps_lock-mode', 0))
    .condition(ifVar('lk_on', 1).unless())
    .condition(apple_built_in)
    .build(),
]
