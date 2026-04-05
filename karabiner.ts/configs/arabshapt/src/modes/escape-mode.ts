import { map } from '../../../../src/config/from.ts'
import { ifVar, ifApp } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 63: "escape-mode caps_lock-mode"
// Caps lock layer: vim navigation, home row modifiers, editing shortcuts
export const description = 'escape-mode caps_lock-mode'

const capsMode = ifVar('caps_lock-mode', 1)

export const manipulators = [
  // Home row modifiers (optional any)
  ...map('s', null, 'any').to('left_option').condition(capsMode).condition(apple_built_in).build(),
  ...map('a', null, 'any').to('left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('d', null, 'any').to('left_shift').condition(capsMode).condition(apple_built_in).build(),
  // Number row → Ctrl+number
  ...map('1').to('1', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('2').to('2', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('3').to('3', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('4').to('4', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('5').to('5', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('6').to('6', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('7').to('7', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('8').to('8', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('9').to('9', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('0').to('0', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('open_bracket').to('open_bracket', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  // Cmd+key → Cmd+Ctrl+key
  ...map('u', ['left_command']).to('u', ['left_command', 'left_control']).condition(capsMode).condition(apple_built_in).build(),
  ...map('i', ['left_command']).to('i', ['left_command', 'left_control']).condition(capsMode).condition(apple_built_in).build(),
  // Vim navigation (optional any)
  ...map('h', null, 'any').to('left_arrow').condition(capsMode).condition(apple_built_in).build(),
  ...map('j', null, 'any').to('down_arrow').condition(capsMode).condition(apple_built_in).build(),
  ...map('k', null, 'any').to('up_arrow').condition(capsMode).condition(apple_built_in).build(),
  ...map('l', null, 'any').to('right_arrow').condition(capsMode).condition(apple_built_in).build(),
  // Editing shortcuts
  ...map('r').to('r', 'left_control').condition(capsMode).condition(apple_built_in).build(),
  ...map('p').to('tab', 'left_command').to('vk_none').condition(capsMode).condition(apple_built_in).build(),
  ...map('o').to('tab', 'left_control').to('vk_none').condition(capsMode).condition(apple_built_in).build(),
  ...map('n').to('delete_or_backspace', 'left_option').condition(capsMode).condition(apple_built_in).build(),
  ...map('m').to('delete_or_backspace').condition(capsMode).condition(apple_built_in).build(),
  ...map('comma').to('tab', 'left_shift').condition(capsMode).condition(apple_built_in).build(),
  ...map('period').to('tab').condition(capsMode).condition(apple_built_in).build(),
  ...map('u').to('z', 'left_command').condition(capsMode).condition(apple_built_in).build(),
  ...map('i').to('z', ['left_command', 'left_shift']).condition(capsMode).condition(apple_built_in).build(),
  ...map('w').to('open_bracket', 'left_command').condition(capsMode).condition(apple_built_in).build(),
  ...map('e').to('close_bracket', 'left_command').condition(capsMode).condition(apple_built_in).build(),
  // superhyper+spacebar
  ...map('spacebar').to('spacebar', ['left_command', 'left_option', 'left_control', 'left_shift', 'fn']).condition(capsMode).condition(apple_built_in).build(),
  // semicolon → return (optional any)
  ...map('semicolon', null, 'any').to('return_or_enter').condition(capsMode).condition(apple_built_in).build(),
  // y → Cmd+Shift+v
  ...map('y').to('v', ['left_command', 'left_shift']).condition(capsMode).condition(apple_built_in).build(),
  // f, g → Cmd+Shift+Opt+key (optional any, shorthand modifiers)
  ...map('f', null, 'any').to('f', ['command', 'shift', 'option']).condition(capsMode).condition(apple_built_in).build(),
  ...map('g', null, 'any').to('g', ['command', 'shift', 'option']).condition(capsMode).condition(apple_built_in).build(),
  // return → Cmd+return
  ...map('return_or_enter').to('return_or_enter', 'command').condition(capsMode).condition(apple_built_in).build(),
  // left_shift → Cmd+Shift+Ctrl+right
  ...map('left_shift').to('right_arrow', ['command', 'shift', 'control']).condition(capsMode).condition(apple_built_in).build(),
  // c → Ctrl+c (Warp only)
  ...map('c').to('c', 'left_control').condition(capsMode).condition(ifApp('dev.warp.Warp-Stable')).condition(apple_built_in).build(),
]
