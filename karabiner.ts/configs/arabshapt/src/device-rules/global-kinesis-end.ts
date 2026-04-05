import { map } from '../../../../src/config/from.ts'
import { kinesis } from '../devices.ts'

// Rule 74: "global kinesis"
// Navigation shortcuts on Kinesis keyboards
export const description = 'global kinesis'

const hyper29 = ['left_shift', 'right_command', 'left_control', 'right_shift'] as const
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const

export const manipulators = [
  // hyper29 + h → Cmd+[ (back)
  ...map('h', [...hyper29]).to('open_bracket', 'left_command').condition(kinesis).build(),
  // hyper29 + s → Cmd+] (forward)
  ...map('s', [...hyper29]).to('close_bracket', 'left_command').condition(kinesis).build(),
  // hyper29 + t → Cmd+Shift+[ (prev tab)
  ...map('t', [...hyper29])
    .to('open_bracket', ['left_command', 'left_shift'])
    .condition(kinesis)
    .build(),
  // hyper29 + n → Cmd+Shift+] (next tab)
  ...map('n', [...hyper29])
    .to('close_bracket', ['left_command', 'left_shift'])
    .condition(kinesis)
    .build(),
  // hyper + f9 → Cmd+[ (back)
  ...map('f9', [...hyper]).to('open_bracket', 'left_command').condition(kinesis).build(),
  // hyper + f11 → Cmd+] (forward)
  ...map('f11', [...hyper]).to('close_bracket', 'left_command').condition(kinesis).build(),
]
