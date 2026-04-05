import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { kinesis, apple_built_in } from '../devices.ts'

// Rule 73: "leader_local to apps"
// Key remaps for leader local activation across devices
export const description = 'leader_local to apps'

export const manipulators = [
  // tilde-mode + open_bracket → semicolon (on apple built-in)
  ...map('open_bracket')
    .to('semicolon')
    .condition(ifVar('tilde-mode', 1))
    .condition(apple_built_in)
    .build(),
  // hyper + keypad_4 → Cmd+Shift+Ctrl+F11 (on kinesis)
  ...map('keypad_4', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('f11', ['command', 'shift', 'control'])
    .toNone()
    .condition(kinesis)
    .build(),
  // open_bracket → f20 (on apple built-in)
  ...map('open_bracket').to('f20').condition(apple_built_in).build(),
]
