import { map } from '../../../../src/config/from.ts'
import { apple_built_in } from '../devices.ts'

// Rule 75: "global end apple_built_in"
// quote → Cmd+Shift+Ctrl+F10 + vk_none, right_option → hyper+5
export const description = 'global end apple_built_in'

export const manipulators = [
  ...map('quote')
    .to('f10', ['command', 'shift', 'control'])
    .toNone()
    .condition(apple_built_in)
    .build(),
  ...map('right_option')
    .to('5', ['left_command', 'left_control', 'left_option', 'left_shift'])
    .build(),
]
