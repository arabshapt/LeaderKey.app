import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { kinesis } from '../devices.ts'
import { km } from '../helpers.ts'

// Rule 57: "Chrome kinesis"
// Chrome shortcuts on Kinesis keyboards
export const description = 'Chrome kinesis'

const chromeVar = ifVar('chrome', 1)
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const
const hyper29 = ['left_shift', 'left_command', 'left_control', 'right_shift'] as const

export const manipulators = [
  // hyper+left → Ctrl+- (zoom out)
  ...map('left_arrow', [...hyper]).to('hyphen', 'left_control').condition(chromeVar).condition(kinesis).build(),
  // hyper+right → Ctrl+Shift+- (zoom in)
  ...map('right_arrow', [...hyper]).to('hyphen', ['left_control', 'left_shift']).condition(chromeVar).condition(kinesis).build(),
  // hyper+m → Cmd+Shift+[ (prev tab)
  ...map('m', [...hyper]).to('open_bracket', ['left_command', 'left_shift']).condition(chromeVar).condition(kinesis).build(),
  // hyper+comma → Cmd+Shift+] (next tab)
  ...map('comma', [...hyper]).to('close_bracket', ['left_command', 'left_shift']).condition(chromeVar).condition(kinesis).build(),
  // hyper29+u → Cmd+] (forward)
  ...map('u', [...hyper29]).to('close_bracket', 'left_command').condition(chromeVar).condition(kinesis).build(),
  // hyper29+e → Cmd+[ (back)
  ...map('e', [...hyper29]).to('open_bracket', 'left_command').condition(chromeVar).condition(kinesis).build(),
  // RCtrl+RCmd+LShift+LCmd+LCtrl + f → Cmd+Shift+o (bookmarks)
  ...map('f', ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'])
    .to('o', ['left_command', 'left_shift'])
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // RCtrl+RCmd+LOpt+LShift+LCtrl + f → Cmd+Shift+o (bookmarks alt)
  ...map('f', ['right_control', 'right_command', 'left_option', 'left_shift', 'left_control'])
    .to('o', ['left_command', 'left_shift'])
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // ROpt+LOpt+LShift+LCmd+LCtrl + s → Cmd+Shift+n (incognito)
  ...map('s', ['right_option', 'left_option', 'left_shift', 'left_command', 'left_control'])
    .to('n', ['left_command', 'left_shift'])
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // ROpt+RShift+LOpt+LShift+LCmd + g → Cmd+Ctrl+Opt+2
  ...map('g', ['right_option', 'right_shift', 'left_option', 'left_shift', 'left_command'])
    .to('2', ['left_command', 'left_control', 'left_option'])
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // hyper29+a → km "Search tabs"
  ...map('a', [...hyper29]).to(km('s Search tabs')).condition(chromeVar).condition(kinesis).build(),
  // RCtrl+RCmd+LOpt+LShift+LCtrl + t → km "Switch to previous tab"
  ...map('t', ['right_control', 'right_command', 'left_option', 'left_shift', 'left_control'])
    .to(km('pt Switch to previous tab'))
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // hyper29+p → km "Switch to previous tab"
  ...map('p', [...hyper29]).to(km('pt Switch to previous tab')).condition(chromeVar).condition(kinesis).build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + p → km "Switch to previous tab"
  ...map('p', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to(km('pt Switch to previous tab'))
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + d → km "Duplicate Tab"
  ...map('d', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to(km('tdp Duplicate Tab'))
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
  // hyper29+q → Cmd+Ctrl+Opt+1
  ...map('q', [...hyper29]).to('1', ['left_command', 'left_control', 'left_option']).condition(chromeVar).condition(kinesis).build(),
  // hyper29+t → Cmd+Opt+Right (next space)
  ...map('t', [...hyper29]).to('right_arrow', ['left_command', 'left_option']).condition(chromeVar).condition(kinesis).build(),
  // hyper29+h → Cmd+Opt+Left (prev space)
  ...map('h', [...hyper29]).to('left_arrow', ['left_command', 'left_option']).condition(chromeVar).condition(kinesis).build(),
  // hyper29+up → Cmd+Ctrl+Opt+Up
  ...map('up_arrow', [...hyper29]).to('up_arrow', ['left_command', 'left_control', 'left_option']).condition(chromeVar).condition(kinesis).build(),
  // hyper29+down → Cmd+Ctrl+Opt+Down
  ...map('down_arrow', [...hyper29]).to('down_arrow', ['left_command', 'left_control', 'left_option']).condition(chromeVar).condition(kinesis).build(),
  // hyper29+escape → Shift+Escape
  ...map('escape', [...hyper29]).to('escape', 'left_shift').condition(chromeVar).condition(kinesis).build(),
  // RCmd+ROpt+RCtrl+RShift + 9 → Cmd+Ctrl+9
  ...map('9', ['right_command', 'right_option', 'right_control', 'right_shift'])
    .to('9', ['left_command', 'left_control'])
    .condition(chromeVar)
    .condition(kinesis)
    .build(),
]
