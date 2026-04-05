import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 48: "tab-mode"
// Number layer: tab + key → number/symbol on Apple built-in keyboard
export const description = 'tab-mode'

const tabMode = ifVar('tab-mode', 1)

export const manipulators = [
  // Number row (right hand)
  ...map('m', null, 'any').to('1').condition(tabMode).condition(apple_built_in).build(),
  ...map('comma', null, 'any').to('2').condition(tabMode).condition(apple_built_in).build(),
  ...map('period', null, 'any').to('3').condition(tabMode).condition(apple_built_in).build(),
  ...map('j', null, 'any').to('4').condition(tabMode).condition(apple_built_in).build(),
  ...map('k', null, 'any').to('5').condition(tabMode).condition(apple_built_in).build(),
  ...map('l', null, 'any').to('6').condition(tabMode).condition(apple_built_in).build(),
  ...map('u', null, 'any').to('7').condition(tabMode).condition(apple_built_in).build(),
  ...map('i', null, 'any').to('8').condition(tabMode).condition(apple_built_in).build(),
  ...map('o', null, 'any').to('9').condition(tabMode).condition(apple_built_in).build(),
  ...map('spacebar', null, 'any').to('0').condition(tabMode).condition(apple_built_in).build(),
  // Symbols
  ...map('n', null, 'any').to('8', 'left_shift').condition(tabMode).condition(apple_built_in).build(),
  ...map('h', null, 'any').to('period').condition(tabMode).condition(apple_built_in).build(),
  ...map('y', null, 'any').to('5', 'left_shift').condition(tabMode).condition(apple_built_in).build(),
  ...map('p', null, 'any').to('semicolon', 'left_shift').condition(tabMode).condition(apple_built_in).build(),
  ...map('semicolon', null, 'any').to('hyphen').condition(tabMode).condition(apple_built_in).build(),
  ...map('slash', null, 'any').to('slash').condition(tabMode).condition(apple_built_in).build(),
  ...map('quote', null, 'any').to('return_or_enter').condition(tabMode).condition(apple_built_in).build(),
  ...map('open_bracket', null, 'any').to('delete_or_backspace').condition(tabMode).condition(apple_built_in).build(),
  // Modifier keys
  ...map('e', null, 'any').to('left_shift').condition(tabMode).condition(apple_built_in).build(),
  ...map('w', null, 'any').to('left_option').condition(tabMode).condition(apple_built_in).build(),
  ...map('q', null, 'any').to('left_control').condition(tabMode).condition(apple_built_in).build(),
]
