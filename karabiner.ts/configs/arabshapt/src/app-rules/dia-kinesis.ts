import { map, mapPointingButton } from '../../../../src/config/from.ts'
import { ifApp } from '../../../../src/config/condition.ts'
import { kinesis } from '../devices.ts'
import { km } from '../helpers.ts'

// Rule 60: "Dia kinesis"
// 41 manipulators
export const description = 'Dia kinesis'

const diaApp = ifApp('company.thebrowser.dia')

export const manipulators = [
  // fn+hyper+comma → Cmd+r (reload)
  ...map('comma', ['fn', 'left_command', 'left_option', 'left_control', 'left_shift'])
    .to('r', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+keypad_1 → Cmd+t (new tab)
  ...map('keypad_1', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('t', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + p → Ctrl+tab (next tab)
  ...map('p', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to('tab', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+LCmd+LCtrl+RCmd + o → Cmd+r (reload)
  ...map('o', ['left_shift', 'left_command', 'left_control', 'right_command'])
    .to('r', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + s → Cmd+Shift+= (zoom in)
  ...map('s', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to('equal_sign', ['left_command', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper29 + p → Ctrl+tab (next tab)
  ...map('p', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('tab', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper29 + e → Ctrl+Shift+[ (prev tab group)
  ...map('e', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('open_bracket', ['left_control', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper29 + u → Ctrl+Shift+] (next tab group)
  ...map('u', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('close_bracket', ['left_control', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper29 + o → Ctrl+Shift+= (zoom)
  ...map('o', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('equal_sign', ['left_control', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper29 + a → Cmd+t (new tab)
  ...map('a', ['left_shift', 'left_command', 'left_control', 'right_shift'])
    .to('t', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + h → Cmd+[ (back)
  ...map('h', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('open_bracket', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + s → Cmd+] (forward)
  ...map('s', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('close_bracket', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + t → Cmd+Opt+Up (move tab up)
  ...map('t', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('up_arrow', ['left_command', 'left_option'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + n → Cmd+Opt+Down (move tab down)
  ...map('n', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('down_arrow', ['left_command', 'left_option'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + r → Cmd+r (reload)
  ...map('r', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('r', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + c → Cmd+w (close tab)
  ...map('c', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('w', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + l → Cmd+l (address bar)
  ...map('l', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('l', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+RCmd+LShift+LCmd+LCtrl + f → km "Search with Claude"
  ...map('f', ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'])
    .to(km('Search with Claude'))
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // ROpt+RCmd+RShift+LOpt+LShift + button1 → Cmd+Opt+Up (move tab up)
  ...mapPointingButton('button1', ['right_option', 'right_command', 'right_shift', 'left_option', 'left_shift'])
    .to('up_arrow', ['left_command', 'left_option'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // ROpt+RCmd+RShift+LOpt+LShift + button2 → Cmd+Opt+Down (move tab down)
  ...mapPointingButton('button2', ['right_option', 'right_command', 'right_shift', 'left_option', 'left_shift'])
    .to('down_arrow', ['left_command', 'left_option'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+7 → Cmd+t (new tab)
  ...map('7', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('t', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + m → Cmd+Opt+Shift+f1
  ...map('m', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('f1', ['left_command', 'left_option', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + w → Cmd+Opt+Shift+f2
  ...map('w', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('f2', ['left_command', 'left_option', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+RCmd+LCtrl+RShift + v → Cmd+Opt+Shift+f3
  ...map('v', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('f3', ['left_command', 'left_option', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+f7 → Cmd+[ (back)
  ...map('f7', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('open_bracket', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+f8 → Cmd+] (forward)
  ...map('f8', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('close_bracket', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+f9 → Cmd+[ (back)
  ...map('f9', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('open_bracket', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+f11 → Cmd+] (forward)
  ...map('f11', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('close_bracket', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+f1 → km "Arc: Ask perplexity"
  ...map('f1', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to(km('Arc: Ask perplexity'))
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+f6 → Cmd+r (reload)
  ...map('f6', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('r', 'left_command')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + p → Ctrl+tab (duplicate)
  ...map('p', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to('tab', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // hyper+keypad_8 → Ctrl+tab (next tab)
  ...map('keypad_8', ['left_command', 'left_option', 'left_control', 'left_shift'])
    .to('tab', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + d → Opt+Shift+d
  ...map('d', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to('d', ['left_option', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + s → Cmd+Shift+= (zoom in)
  ...map('s', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to('equal_sign', ['left_command', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LOpt+LCmd + f → km "Arc: Separate Page from Split View"
  ...map('f', ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'])
    .to(km('Arc: Separate Page from Split View'))
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LShift+LCmd+LOpt+RCmd + y → Cmd+Shift+c (copy URL)
  ...map('y', ['left_shift', 'left_command', 'left_option', 'right_command'])
    .to('c', ['left_command', 'left_shift'])
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // LCmd+LOpt+LCtrl+RCmd + f → km "Search with Claude"
  ...map('f', ['left_command', 'left_option', 'left_control', 'right_command'])
    .to(km('Search with Claude'))
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+RCmd+ROpt+LOpt+LCtrl + c → km "Arc extension EditThisCookie" + Ctrl+f1
  ...map('c', ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'])
    .to(km('Arc extension EditThisCookie'))
    .to('f1', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+RCmd+ROpt+LOpt+LCtrl + h → km "Arc extension ModHeader" + Ctrl+f1
  ...map('h', ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'])
    .to(km('Arc extension ModHeader'))
    .to('f1', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+RCmd+ROpt+LOpt+LCmd + h → km "Arc Archive View History" + Ctrl+f1
  ...map('h', ['right_control', 'right_command', 'right_option', 'left_option', 'left_command'])
    .to(km('Arc Archive View History'))
    .to('f1', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
  // RCtrl+ROpt+RShift+LCmd+LCtrl + q → km "ArcFileArchiveTab" + Ctrl+f1
  ...map('q', ['right_control', 'right_option', 'right_shift', 'left_command', 'left_control'])
    .to(km('ArcFileArchiveTab'))
    .to('f1', 'left_control')
    .condition(diaApp)
    .condition(kinesis)
    .build(),
]
