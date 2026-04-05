import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { kinesis, apple_built_in } from '../devices.ts'

// Rule 71: "code"
// VS Code shortcuts on Kinesis and Apple built-in keyboards
export const description = 'code'

const codeVar = ifVar('code', 1)
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const
const capsMode = ifVar('caps_lock-mode', 1)

export const manipulators = [
  // --- Kinesis shortcuts ---
  // superhyper+1 → Ctrl+spacebar (suggestions)
  ...map('1', [...hyper, 'fn']).to('spacebar', 'left_control').condition(codeVar).condition(kinesis).build(),
  // Opt+up → Cmd+Ctrl+Shift+Right (expand selection)
  ...map('up_arrow', ['left_option']).to('right_arrow', ['left_command', 'left_control', 'left_shift']).condition(codeVar).condition(kinesis).build(),
  // Opt+down → Cmd+Ctrl+Shift+Left (shrink selection)
  ...map('down_arrow', ['left_option']).to('left_arrow', ['left_command', 'left_control', 'left_shift']).condition(codeVar).condition(kinesis).build(),
  // hyper+f7 → Cmd+[ (outdent)
  ...map('f7', [...hyper]).to('open_bracket', 'left_command').condition(codeVar).condition(kinesis).build(),
  // hyper+f8 → Cmd+] (indent)
  ...map('f8', [...hyper]).to('close_bracket', 'left_command').condition(codeVar).condition(kinesis).build(),
  // hyper+7 → f12 (go to definition)
  ...map('7', [...hyper]).to('f12').condition(codeVar).condition(kinesis).build(),
  // hyper+f7 → Cmd+[ (duplicate)
  ...map('f7', [...hyper]).to('open_bracket', 'left_command').condition(codeVar).condition(kinesis).build(),
  // hyper+f8 → Cmd+] (duplicate)
  ...map('f8', [...hyper]).to('close_bracket', 'left_command').condition(codeVar).condition(kinesis).build(),
  // hyper+f9 → Cmd+[ (back nav)
  ...map('f9', [...hyper]).to('open_bracket', 'left_command').condition(codeVar).condition(kinesis).build(),
  // hyper+f11 → Cmd+] (forward nav)
  ...map('f11', [...hyper]).to('close_bracket', 'left_command').condition(codeVar).condition(kinesis).build(),
  // hyper+kp1 → f20
  ...map('keypad_1', [...hyper]).to('f20').condition(codeVar).condition(kinesis).build(),

  // --- Apple built-in caps_lock-mode shortcuts ---
  // d → Ctrl+d
  ...map('d').to('d', 'left_control').condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // u → Ctrl+u
  ...map('u').to('u', 'left_control').condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // i → Ctrl+i
  ...map('i').to('i', 'left_control').condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // o → Ctrl+o
  ...map('o').to('o', 'left_control').condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // p → Ctrl+p
  ...map('p').to('p', 'left_control').condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // 7 → Cmd+Opt+Left (prev tab)
  ...map('7').to('left_arrow', ['left_command', 'left_option']).condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // 8 → Cmd+Opt+Right (next tab)
  ...map('8').to('right_arrow', ['left_command', 'left_option']).condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // m → Cmd+Opt+Left (prev tab alt)
  ...map('m').to('left_arrow', ['left_command', 'left_option']).condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
  // comma → Cmd+Opt+Right (next tab alt)
  ...map('comma').to('right_arrow', ['left_command', 'left_option']).condition(capsMode).condition(codeVar).condition(apple_built_in).build(),
]
