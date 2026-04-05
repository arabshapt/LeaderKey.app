import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'

// Rule 37: "kinesis"
// hyper_29 (LS+RC+LC+RS) + keys → Cmd+bracket navigation in Chrome
export const description = 'kinesis'

const hyper29 = ['left_shift', 'right_command', 'left_command', 'right_shift'] as const
const chrome = ifVar('chrome', 1)

export const manipulators = [
  // period → Cmd+[ (back)
  ...map('period', [...hyper29])
    .to('open_bracket', 'left_command')
    .condition(chrome)
    .build(),
  // p → Cmd+] (forward)
  ...map('p', [...hyper29])
    .to('close_bracket', 'left_command')
    .condition(chrome)
    .build(),
  // j → Cmd+Shift+[ (prev tab)
  ...map('j', [...hyper29])
    .to('open_bracket', ['left_command', 'left_shift'])
    .condition(chrome)
    .build(),
  // k → Cmd+Shift+] (next tab)
  ...map('k', [...hyper29])
    .to('close_bracket', ['left_command', 'left_shift'])
    .condition(chrome)
    .build(),
]
