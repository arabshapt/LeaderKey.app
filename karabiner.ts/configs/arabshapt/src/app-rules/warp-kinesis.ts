import { map } from '../../../../src/config/from.ts'
import { ifApp } from '../../../../src/config/condition.ts'
import { kinesis } from '../devices.ts'

// Rule 45: "warp kinesis"
// Warp terminal shortcuts on Kinesis keyboards
export const description = 'warp kinesis'

const warp = ifApp('dev.warp.Warp-Stable')

export const manipulators = [
  // Ctrl+RCtrl+Shift+Opt + spacebar → Ctrl+spacebar
  ...map('spacebar', ['control', 'right_control', 'shift', 'option'])
    .to('spacebar', 'left_control')
    .condition(warp)
    .condition(kinesis)
    .build(),
  // Ctrl+RCtrl + escape → Ctrl+spacebar
  ...map('escape', ['control', 'right_control'])
    .to('spacebar', 'left_control')
    .condition(warp)
    .condition(kinesis)
    .build(),
  // RCmd+j → Ctrl+a, Shift+t (tmux select)
  ...map('j', ['right_command'])
    .to('a', 'left_control')
    .to('t', 'left_shift')
    .condition(warp)
    .condition(kinesis)
    .build(),
  // LCmd+g → Ctrl+a, g (tmux status)
  ...map('g', ['left_command'])
    .to('a', 'left_control')
    .to('g')
    .condition(warp)
    .condition(kinesis)
    .build(),
  // hyper29 (LS+LC+LC+RS) + t → Cmd+Shift+] (next pane)
  ...map('t', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('close_bracket', ['left_command', 'left_shift'])
    .condition(warp)
    .condition(kinesis)
    .build(),
  // hyper29 + h → Cmd+Shift+[ (prev pane)
  ...map('h', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('open_bracket', ['left_command', 'left_shift'])
    .condition(warp)
    .condition(kinesis)
    .build(),
]
