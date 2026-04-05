import { map } from '../../../../src/config/from.ts'
import { ifApp, ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 56: "warp apple_built_in"
// Warp terminal shortcuts on Apple built-in keyboard
export const description = 'warp apple_built_in'

const warp = ifApp('dev.warp.Warp-Stable')
const capsMode = ifVar('caps_lock-mode', 1)

export const manipulators = [
  // Cmd+j → Ctrl+a, Shift+t (tmux select)
  ...map('j', ['command'])
    .to('a', 'left_control')
    .to('t', 'left_shift')
    .condition(warp)
    .condition(apple_built_in)
    .build(),
  // Cmd+g → Ctrl+a, g (tmux status)
  ...map('g', ['command'])
    .to('a', 'left_control')
    .to('g')
    .condition(warp)
    .condition(apple_built_in)
    .build(),
  // caps+comma → Cmd+Shift+] (next pane)
  ...map('comma')
    .to('close_bracket', ['left_command', 'left_shift'])
    .condition(capsMode)
    .condition(warp)
    .condition(apple_built_in)
    .build(),
  // caps+t → Ctrl+t
  ...map('t')
    .to('t', 'left_control')
    .condition(capsMode)
    .condition(warp)
    .condition(apple_built_in)
    .build(),
  // caps+a → Ctrl+a
  ...map('a')
    .to('a', 'left_control')
    .condition(capsMode)
    .condition(warp)
    .condition(apple_built_in)
    .build(),
]
