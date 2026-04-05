import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 64: "backslash-mode apple_built_in"
// Backslash layer: key → hyper+key (for Raycast/global shortcuts)
export const description = 'backslash-mode apple_built_in'

const bsMode = ifVar('backslash-mode', 1)
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const

export const manipulators = [
  // g (no optional any)
  ...map('g').to('g', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  // Letters with optional any → hyper+key
  ...map('n', null, 'any').to('b', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('u', null, 'any').to('u', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('i', null, 'any').to('i', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('o', null, 'any').to('o', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('s', null, 'any').to('s', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('d', null, 'any').to('d', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('y', null, 'any').to('f', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('g', null, 'any').to('g', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('h', null, 'any').to('h', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('j', null, 'any').to('j', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('k', null, 'any').to('k', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('l', null, 'any').to('l', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  ...map('p', null, 'any').to('p', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  // v → Cmd+Shift+v (paste without formatting)
  ...map('v', null, 'any').to('v', ['command', 'shift']).condition(bsMode).condition(apple_built_in).build(),
  // semicolon → hyper+semicolon
  ...map('semicolon', null, 'any').to('semicolon', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  // equal_sign → hyper+equal_sign
  ...map('equal_sign', null, 'any').to('equal_sign', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
  // spacebar → hyper+equal_sign
  ...map('spacebar', null, 'any').to('equal_sign', [...hyper]).condition(bsMode).condition(apple_built_in).build(),
]
