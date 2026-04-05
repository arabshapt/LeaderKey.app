import { map } from '../../../src/config/from.ts'
import { apple_built_in } from './devices.ts'
import { km } from './helpers.ts'

// Rule 43: "test"
// hyper (LC+LS+LO+LC) + spacebar → km macros on built-in keyboard
export const description = 'test'

export const manipulators = [
  ...map('spacebar', ['left_command', 'left_shift', 'left_option', 'left_control'])
    .to(km('open: Chrome'))
    .condition(apple_built_in)
    .build(),
  ...map('spacebar', [
    'left_command',
    'right_command',
    'right_option',
    'left_shift',
    'left_option',
    'left_control',
  ])
    .to(km('open: VS Code'))
    .condition(apple_built_in)
    .build(),
]
