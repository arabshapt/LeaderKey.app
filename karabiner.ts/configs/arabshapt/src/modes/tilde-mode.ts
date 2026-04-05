import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 50: "tilde-mode symbols"
// Tilde layer: key → symbol on Apple built-in keyboard
export const description = 'tilde-mode symbols'

const tildeMode = ifVar('tilde-mode', 1)

export const manipulators = [
  ...map('tab', null, 'any').to('9', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('spacebar').to('spacebar', 'control').condition(tildeMode).condition(apple_built_in).build(),
  ...map('q', null, 'any').to('2', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('w', null, 'any').to('hyphen', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('e', null, 'any').to('open_bracket').condition(tildeMode).condition(apple_built_in).build(),
  ...map('r', null, 'any').to('close_bracket').condition(tildeMode).condition(apple_built_in).build(),
  ...map('t', null, 'any').to('6', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('y', null, 'any').to('1', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('u', null, 'any').to('comma', 'shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('i', null, 'any').to('period', 'shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('o', null, 'any').to('equal_sign').condition(tildeMode).condition(apple_built_in).build(),
  ...map('p', null, 'any').to('7', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('a', null, 'any').to('backslash').condition(tildeMode).condition(apple_built_in).build(),
  ...map('s', null, 'any').to('slash').condition(tildeMode).condition(apple_built_in).build(),
  ...map('d', null, 'any').to('open_bracket', 'shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('f', null, 'any').to('close_bracket', 'shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('g', null, 'any').to('8', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('h', null, 'any').to('slash', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('j', null, 'any').to('9', 'shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('k', null, 'any').to('0', 'shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('l', null, 'any').to('hyphen').condition(tildeMode).condition(apple_built_in).build(),
  ...map('semicolon', null, 'any').to('semicolon', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('quote', null, 'any').to('quote').condition(tildeMode).condition(apple_built_in).build(),
  ...map('z', null, 'any').to('3', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('x', null, 'any').to('4', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('c', null, 'any').to('backslash', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('v', null, 'any').to('grave_accent_and_tilde', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('b', null, 'any').to('grave_accent_and_tilde').condition(tildeMode).condition(apple_built_in).build(),
  ...map('n', null, 'any').to('equal_sign', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('m', null, 'any').to('5', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('comma', null, 'any').to('quote', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('period', null, 'any').to('hyphen', 'left_shift').condition(tildeMode).condition(apple_built_in).build(),
  ...map('slash', null, 'any').to('semicolon').condition(tildeMode).condition(apple_built_in).build(),
  ...map('open_bracket', null, 'any').to('semicolon').condition(tildeMode).condition(apple_built_in).build(),
]
