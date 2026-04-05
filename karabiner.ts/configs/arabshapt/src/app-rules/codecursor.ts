import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { kinesis } from '../devices.ts'

// Rule 70: "codecursor"
// Cursor/VS Code shortcuts on Kinesis keyboards
export const description = 'codecursor'

const cc = ifVar('codecursor', 1)
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const

export const manipulators = [
  // superhyper+1 → Ctrl+spacebar (suggestions)
  ...map('1', [...hyper, 'fn']).to('spacebar', 'left_control').condition(cc).condition(kinesis).build(),
  // Opt+up → Cmd+Ctrl+Shift+Right (expand selection)
  ...map('up_arrow', ['left_option']).to('right_arrow', ['left_command', 'left_control', 'left_shift']).condition(cc).condition(kinesis).build(),
  // Opt+down → Cmd+Ctrl+Shift+Left (shrink selection)
  ...map('down_arrow', ['left_option']).to('left_arrow', ['left_command', 'left_control', 'left_shift']).condition(cc).condition(kinesis).build(),
  // hyper+f7 → Cmd+[ (outdent)
  ...map('f7', [...hyper]).to('open_bracket', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+f8 → Cmd+] (indent)
  ...map('f8', [...hyper]).to('close_bracket', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+kp1 → f20
  ...map('keypad_1', [...hyper]).to('f20').condition(cc).condition(kinesis).build(),
  // hyper+f7 → Cmd+[ (duplicate for another layer)
  ...map('f7', [...hyper]).to('open_bracket', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+f8 → Cmd+] (duplicate for another layer)
  ...map('f8', [...hyper]).to('close_bracket', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+f9 → Cmd+[ (back nav)
  ...map('f9', [...hyper]).to('open_bracket', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+f11 → Cmd+] (forward nav)
  ...map('f11', [...hyper]).to('close_bracket', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+f1 → Cmd+b (toggle sidebar)
  ...map('f1', [...hyper]).to('b', 'left_command').condition(cc).condition(kinesis).build(),
  // hyper+7 → Cmd+b (toggle sidebar alt)
  ...map('7', [...hyper]).to('b', 'left_command').condition(cc).condition(kinesis).build(),
  // RCtrl+ROpt+RShift+LShift+LCmd + s → Cmd+Shift+f (find in files)
  ...map('s', ['right_control', 'right_option', 'right_shift', 'left_shift', 'left_command'])
    .to('f', ['left_command', 'left_shift'])
    .condition(cc)
    .condition(kinesis)
    .build(),
]
