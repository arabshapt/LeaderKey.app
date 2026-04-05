import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 69: "emacs"
// Emacs-style shortcuts in caps_lock-mode on Apple built-in keyboard
export const description = 'emacs'

const capsMode = ifVar('caps_lock-mode', 1)
const emacsVar = ifVar('emacs', 1)

export const manipulators = [
  // d → Ctrl+d (delete forward)
  ...map('d').to('d', 'left_control').condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // u → Ctrl+u (kill line backward)
  ...map('u').to('u', 'left_control').condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // i → Ctrl+i (tab)
  ...map('i').to('i', 'left_control').condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // o → Ctrl+o (open line)
  ...map('o').to('o', 'left_control').condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // p → Ctrl+p (up)
  ...map('p').to('p', 'left_control').condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // 7 → Cmd+Opt+Left (prev tab)
  ...map('7').to('left_arrow', ['left_command', 'left_option']).condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // 8 → Cmd+Opt+Right (next tab)
  ...map('8').to('right_arrow', ['left_command', 'left_option']).condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // m → Cmd+Opt+Left (prev tab alt)
  ...map('m').to('left_arrow', ['left_command', 'left_option']).condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
  // comma → Cmd+Opt+Right (next tab alt)
  ...map('comma').to('right_arrow', ['left_command', 'left_option']).condition(capsMode).condition(emacsVar).condition(apple_built_in).build(),
]
