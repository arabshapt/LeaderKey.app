import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'
import { km } from '../helpers.ts'

// Rule 67: "chrome"
// Chrome shortcuts in caps_lock-mode on Apple built-in keyboard
export const description = 'chrome'

const capsMode = ifVar('caps_lock-mode', 1)
const chromeVar = ifVar('chrome', 1)

export const manipulators = [
  // u → Cmd+[ (back)
  ...map('u').to('open_bracket', 'left_command').condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // i → Cmd+] (forward)
  ...map('i').to('close_bracket', 'left_command').condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // 7 → Cmd+Opt+Left (prev tab)
  ...map('7').to('left_arrow', ['left_command', 'left_option']).condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // 8 → Cmd+Opt+Right (next tab)
  ...map('8').to('right_arrow', ['left_command', 'left_option']).condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // m → Cmd+Opt+Left (prev tab alt)
  ...map('m').to('left_arrow', ['left_command', 'left_option']).condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // comma → Cmd+Opt+Right (next tab alt)
  ...map('comma').to('right_arrow', ['left_command', 'left_option']).condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // o → km "Search tabs"
  ...map('o').to(km('ts Search tabs')).condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
  // k → Shift+Ctrl+Opt+keypad_hyphen
  ...map('k').to('keypad_hyphen', ['shift', 'control', 'option']).condition(capsMode).condition(chromeVar).condition(apple_built_in).build(),
]
