import { map } from '../../../../src/config/from.ts'
import { ifApp, ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 42: "right cmd -> right control in terminals; rcmd to local palette"
// right_cmd+a → ctrl+a in Warp, Alacritty, Hyperterm on built-in keyboard
export const description =
  'right cmd -> right control in terminals; rcmd to local palette'

export const manipulators = [
  ...map('a', ['right_command'])
    .to('a', 'right_control')
    .condition(ifApp('dev.warp.Warp-Stable'))
    .condition(apple_built_in)
    .build(),
  ...map('a', ['right_command'])
    .to('a', 'right_control')
    .condition(ifVar('alacritty', 1))
    .condition(apple_built_in)
    .build(),
  ...map('a', ['right_command'])
    .to('a', 'right_control')
    .condition(ifVar('hyperterm', 1))
    .condition(apple_built_in)
    .build(),
]
