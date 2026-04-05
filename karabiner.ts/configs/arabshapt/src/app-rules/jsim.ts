import { map } from '../../../../src/config/from.ts'
import { apple_built_in } from '../devices.ts'

// Rule 72: "jsim"
// f19 → hyper+spacebar on built-in keyboard
export const description = 'jsim'

export const manipulators = [
  ...map('f19')
    .to('spacebar', ['left_command', 'left_control', 'left_option', 'left_shift'])
    .condition(apple_built_in)
    .build(),
]
