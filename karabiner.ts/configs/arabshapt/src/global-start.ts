import { map } from '../../../src/config/from.ts'
import { ifDevice, ifVar } from '../../../src/config/condition.ts'
import { apple_built_in } from './devices.ts'

// Rule 2: "global start apple_built_in"
// Global escape/deactivate shortcuts on Apple built-in keyboard
export const description = 'global start apple_built_in'

// Goku generates duplicate identifiers in some conditions
const appleDouble = ifDevice([
  { product_id: 0, vendor_id: 0 },
  { product_id: 0, vendor_id: 0 },
])

export const manipulators = [
  // caps_lock → escape + reset all leader key state + deactivate
  ...map('caps_lock')
    .to('escape')
    .toVar('leaderkey_active', 0)
    .toVar('lk_on', 0)
    .toVar('lk_0', 0)
    .toVar('lk_1', 0)
    .toVar('lk_2', 0)
    .toVar('lka_0', 0)
    .toVar('lka_1', 0)
    .toVar('lka_2', 0)
    .toVar('lkst_0', 0)
    .toVar('lkst_1', 0)
    .toVar('lkst_2', 0)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_fallback', 0)
    .toVar('leader_mode', 0)
    .toVar('leader_state', 0)
    .toSendUserCommand('deactivate')
    .condition(appleDouble)
    .build(),
  // quote → Cmd+Shift+Ctrl+F10 (unless in tilde-mode or caps-mode)
  ...map('quote')
    .to('f10', ['command', 'shift', 'control'])
    .toNone()
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(appleDouble)
    .build(),
  // escape → escape + reset leader_state + deactivate
  ...map('escape')
    .to('escape')
    .toVar('leader_state', 0)
    .toSendUserCommand('deactivate')
    .condition(apple_built_in)
    .build(),
  // Cmd+escape → reset leader_mode + deactivate
  ...map('escape', ['left_command'])
    .toVar('leader_mode', 0)
    .toSendUserCommand('deactivate')
    .condition(apple_built_in)
    .build(),
]
