import { map } from '../../../../src/config/from.ts'
import { ifApp } from '../../../../src/config/condition.ts'
import { kinesis } from '../devices.ts'
import { km } from '../helpers.ts'

// Rule 62: "intellij kinesis"
// 86 manipulators
export const description = 'intellij kinesis'

const intellijApp = ifApp('com.jetbrains.intellij')

// Modifier combos used across manipulators
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const
const hyper29 = ['left_shift', 'left_command', 'left_control', 'right_shift'] as const

export const manipulators = [
  // 1: LShift+LOpt+LCtrl+RCtrl + u → left_control, left_control
  ...map('u', ['left_shift', 'left_option', 'left_control', 'right_control'])
    .to('left_control')
    .to('left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 2: RCtrl+RCmd+LOpt+LShift+LCtrl + f → Cmd+Shift+o
  ...map('f', ['right_control', 'right_command', 'left_option', 'left_shift', 'left_control'])
    .to('o', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 3: RCtrl+RCmd+LOpt+LShift+LCtrl + p → Cmd+Ctrl+Opt+4
  ...map('p', ['right_control', 'right_command', 'left_option', 'left_shift', 'left_control'])
    .to('4', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 4: ROpt+LOpt+LShift+LCmd+LCtrl + s → Cmd+Shift+n
  ...map('s', ['right_option', 'left_option', 'left_shift', 'left_command', 'left_control'])
    .to('n', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 5: ROpt+RCmd+LOpt+LCmd+LCtrl + period → Opt+F1, 1
  ...map('period', ['right_option', 'right_command', 'left_option', 'left_command', 'left_control'])
    .to('f1', 'left_option')
    .to('1')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 6: hyper29 + a → Cmd+Shift+a
  ...map('a', [...hyper29])
    .to('a', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 7: hyper29 + o → Cmd+Shift+o
  ...map('o', [...hyper29])
    .to('o', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 8: hyper29 + e → km "intellij double shift"
  ...map('e', [...hyper29])
    .to(km('intellij double shift'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 9: RCtrl+RShift+LOpt+LShift+LCmd + period → km "Compare Current Branch"
  ...map('period', ['right_control', 'right_shift', 'left_option', 'left_shift', 'left_command'])
    .to(km('Compare Current Branch'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 10: RCtrl+RCmd+ROpt+LOpt+RShift + period → km "Compare Current Branch"
  ...map('period', ['right_control', 'right_command', 'right_option', 'left_option', 'right_shift'])
    .to(km('Compare Current Branch'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 11: RCtrl+RShift+LOpt+LShift+LCmd + b → km "GitBranchCheckout"
  ...map('b', ['right_control', 'right_shift', 'left_option', 'left_shift', 'left_command'])
    .to(km('GitBranchCheckout'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 12: ROpt+RCmd+RShift+LOpt+LCtrl + c → km "Tool window changes"
  ...map('c', ['right_option', 'right_command', 'right_shift', 'left_option', 'left_control'])
    .to(km('Tool window changes'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 13: ROpt+RCmd+RShift+LOpt+LCtrl + p → km "Tool window project"
  ...map('p', ['right_option', 'right_command', 'right_shift', 'left_option', 'left_control'])
    .to(km('Tool window project'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 14: ROpt+RCmd+RShift+LOpt+LCtrl + t → Opt+F12
  ...map('t', ['right_option', 'right_command', 'right_shift', 'left_option', 'left_control'])
    .to('f12', 'left_option')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 15: hyper29 + k → km "Hover Info"
  ...map('k', [...hyper29])
    .to(km('Hover Info'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 16: hyper29 + escape → km "Show Context Menu"
  ...map('escape', [...hyper29])
    .to(km('Show Context Menu'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 17: hyper29 + q → Cmd+Ctrl+Opt+1
  ...map('q', [...hyper29])
    .to('1', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 18: LShift+RCmd+LCmd+RShift + h → km "Goto harpoon file 1" + Ctrl+F2
  ...map('h', ['left_shift', 'right_command', 'left_command', 'right_shift'])
    .to(km('Goto harpoon file 1'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 19: LShift+RCmd+LCmd+RShift + t → km "Goto harpoon file 2" + Ctrl+F2
  ...map('t', ['left_shift', 'right_command', 'left_command', 'right_shift'])
    .to(km('Goto harpoon file 2'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 20: LShift+RCmd+LCmd+RShift + n → km "Goto harpoon file 3" + Ctrl+F2
  ...map('n', ['left_shift', 'right_command', 'left_command', 'right_shift'])
    .to(km('Goto harpoon file 3'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 21: LShift+RCmd+LCmd+RShift + s → km "Goto harpoon file 4" + Ctrl+F2
  ...map('s', ['left_shift', 'right_command', 'left_command', 'right_shift'])
    .to(km('Goto harpoon file 4'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 22: LShift+ROpt+LCtrl+RCtrl + h → km "Goto harpoon file 1" + Ctrl+F2
  ...map('h', ['left_shift', 'right_option', 'left_control', 'right_control'])
    .to(km('Goto harpoon file 1'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 23: LShift+ROpt+LCtrl+RCtrl + t → km "Goto harpoon file 2" + Ctrl+F2
  ...map('t', ['left_shift', 'right_option', 'left_control', 'right_control'])
    .to(km('Goto harpoon file 2'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 24: LShift+ROpt+LCtrl+RCtrl + n → km "Goto harpoon file 3" + Ctrl+F2
  ...map('n', ['left_shift', 'right_option', 'left_control', 'right_control'])
    .to(km('Goto harpoon file 3'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 25: LShift+ROpt+LCtrl+RCtrl + s → km "Goto harpoon file 4" + Ctrl+F2
  ...map('s', ['left_shift', 'right_option', 'left_control', 'right_control'])
    .to(km('Goto harpoon file 4'))
    .to('f2', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 26: LShift+LCmd+LOpt+RShift + t → Ctrl+Opt+Up
  ...map('t', ['left_shift', 'left_command', 'left_option', 'right_shift'])
    .to('up_arrow', ['left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 27: LShift+LCmd+LOpt+RShift + n → Ctrl+Opt+Down
  ...map('n', ['left_shift', 'left_command', 'left_option', 'right_shift'])
    .to('down_arrow', ['left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 28: LShift+LCmd+LOpt+RShift + h → Ctrl+Opt+Left
  ...map('h', ['left_shift', 'left_command', 'left_option', 'right_shift'])
    .to('left_arrow', ['left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 29: LShift+LCmd+LOpt+RShift + s → Ctrl+Opt+Right
  ...map('s', ['left_shift', 'left_command', 'left_option', 'right_shift'])
    .to('right_arrow', ['left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 30: LShift+RCmd+LCtrl+RShift + c → Ctrl+Shift+c
  ...map('c', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('c', ['left_control', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 31: LShift+RCmd+LOpt+RShift + e → Cmd+Ctrl+Opt+9
  ...map('e', ['left_shift', 'right_command', 'left_option', 'right_shift'])
    .to('9', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 32: LShift+RCmd+LOpt+RShift + o → Cmd+Ctrl+Opt+0
  ...map('o', ['left_shift', 'right_command', 'left_option', 'right_shift'])
    .to('0', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 33: hyper29 + up → Cmd+Ctrl+Opt+Up
  ...map('up_arrow', [...hyper29])
    .to('up_arrow', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 34: hyper29 + down → Cmd+Ctrl+Opt+Down
  ...map('down_arrow', [...hyper29])
    .to('down_arrow', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 35: hyper29 + escape → Shift+Escape
  ...map('escape', [...hyper29])
    .to('escape', 'left_shift')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 36: RCtrl+RCmd+ROpt+LOpt+LCtrl + x → F7
  ...map('x', ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'])
    .to('f7')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 37: hyper + keypad_1 → F20
  ...map('keypad_1', [...hyper])
    .to('f20')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 38: RCtrl+ROpt+LOpt+LShift+LCmd + s → Cmd+Opt+o
  ...map('s', ['right_control', 'right_option', 'left_option', 'left_shift', 'left_command'])
    .to('o', ['left_command', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 39: RCtrl+ROpt+LOpt+LShift+LCmd + e → Cmd+F12
  ...map('e', ['right_control', 'right_option', 'left_option', 'left_shift', 'left_command'])
    .to('f12', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 40: hyper + b → Cmd+b
  ...map('b', [...hyper])
    .to('b', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 41: hyper + t → Cmd+b
  ...map('t', [...hyper])
    .to('b', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 42: hyper + 2 → Cmd+Shift+f
  ...map('2', [...hyper])
    .to('f', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 43: LShift+RCmd+LCtrl+RShift + t → Ctrl+Shift+Up
  ...map('t', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('up_arrow', ['left_control', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 44: LShift+RCmd+LCtrl+RShift + n → Ctrl+Shift+Down
  ...map('n', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('down_arrow', ['left_control', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 45: LShift+RCmd+LCtrl+RShift + h → Ctrl+Opt+Up
  ...map('h', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('up_arrow', ['left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 46: LShift+RCmd+LCtrl+RShift + s → Ctrl+Opt+Down
  ...map('s', ['left_shift', 'right_command', 'left_control', 'right_shift'])
    .to('down_arrow', ['left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 47: hyper + f7 → Cmd+[
  ...map('f7', [...hyper])
    .to('open_bracket', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 48: hyper + f8 → Cmd+]
  ...map('f8', [...hyper])
    .to('close_bracket', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 49: hyper + f9 → Cmd+[
  ...map('f9', [...hyper])
    .to('open_bracket', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 50: hyper + f11 → Cmd+]
  ...map('f11', [...hyper])
    .to('close_bracket', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 51: hyper + f1 → Cmd+b
  ...map('f1', [...hyper])
    .to('b', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 52: hyper + 7 → Cmd+b
  ...map('7', [...hyper])
    .to('b', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 53: RCtrl+ROpt+RShift+LShift+LCmd + s → Cmd+Shift+f
  ...map('s', ['right_control', 'right_option', 'right_shift', 'left_shift', 'left_command'])
    .to('f', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 54: LCmd+LOpt+LCtrl+RCmd + f → km "GoToFile"
  ...map('f', ['left_command', 'left_option', 'left_control', 'right_command'])
    .to(km('GoToFile'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 55: LCmd+LOpt+LCtrl+RCmd + r → Cmd+e
  ...map('r', ['left_command', 'left_option', 'left_control', 'right_command'])
    .to('e', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 56: RCtrl+ROpt+LShift+LCmd+LCtrl + b → Cmd+e
  ...map('b', ['right_control', 'right_option', 'left_shift', 'left_command', 'left_control'])
    .to('e', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 57: RCtrl+ROpt+LShift+LCmd+LCtrl + s → Cmd+Shift+n
  ...map('s', ['right_control', 'right_option', 'left_shift', 'left_command', 'left_control'])
    .to('n', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 58: RCtrl+ROpt+LShift+LCmd+LCtrl + p → Ctrl+Tab
  ...map('p', ['right_control', 'right_option', 'left_shift', 'left_command', 'left_control'])
    .to('tab', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 59: hyper + keypad_8 → Ctrl+Tab
  ...map('keypad_8', [...hyper])
    .to('tab', 'left_control')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 60: RCtrl+ROpt+RShift+LCmd+LCtrl + q → km "closeProject"
  ...map('q', ['right_control', 'right_option', 'right_shift', 'left_command', 'left_control'])
    .to(km('closeProject'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 61: RCtrl+ROpt+RShift+LCmd+LCtrl + o → km "closeOtherProjects"
  ...map('o', ['right_control', 'right_option', 'right_shift', 'left_command', 'left_control'])
    .to(km('closeOtherProjects'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 62: RCtrl+ROpt+RShift+LCmd+LCtrl + a → km "closeAllProjects"
  ...map('a', ['right_control', 'right_option', 'right_shift', 'left_command', 'left_control'])
    .to(km('closeAllProjects'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 63: LShift+LCmd+LCtrl+RCmd + p → Cmd+Ctrl+Opt+4
  ...map('p', ['left_shift', 'left_command', 'left_control', 'right_command'])
    .to('4', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 64: hyper + 4 → Cmd+Ctrl+Opt+4
  ...map('4', [...hyper])
    .to('4', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 65: LShift+LCmd+LCtrl+RCmd + f → Cmd+Shift+o
  ...map('f', ['left_shift', 'left_command', 'left_control', 'right_command'])
    .to('o', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 66: hyper + f → Cmd+Shift+f
  ...map('f', [...hyper])
    .to('f', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 67: hyper + p → Cmd+Shift+o
  ...map('p', [...hyper])
    .to('o', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 68: RCtrl+RCmd+ROpt+LOpt+RShift + period → km "Compare Current Branch"
  ...map('period', ['right_control', 'right_command', 'right_option', 'left_option', 'right_shift'])
    .to(km('Compare Current Branch'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 69: RCtrl+RCmd+ROpt+LOpt+RShift + b → km "GitBranchCheckout"
  ...map('b', ['right_control', 'right_command', 'right_option', 'left_option', 'right_shift'])
    .to(km('GitBranchCheckout'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 70: RCtrl+RCmd+ROpt+LShift+LCmd + c → km "Tool window changes"
  ...map('c', ['right_control', 'right_command', 'right_option', 'left_shift', 'left_command'])
    .to(km('Tool window changes'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 71: RCtrl+RCmd+ROpt+LShift+LCmd + p → km "Tool window project"
  ...map('p', ['right_control', 'right_command', 'right_option', 'left_shift', 'left_command'])
    .to(km('Tool window project'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 72: RCtrl+RCmd+ROpt+LShift+LCmd + e → km "Tool window project"
  ...map('e', ['right_control', 'right_command', 'right_option', 'left_shift', 'left_command'])
    .to(km('Tool window project'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 73: RCtrl+RCmd+ROpt+LShift+LCmd + f → Cmd+1
  ...map('f', ['right_control', 'right_command', 'right_option', 'left_shift', 'left_command'])
    .to('1', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 74: hyper29 + p → km "Tool window project"
  ...map('p', [...hyper29])
    .to(km('Tool window project'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 75: RCtrl+RCmd+ROpt+LShift+LCmd + t → Opt+F12
  ...map('t', ['right_control', 'right_command', 'right_option', 'left_shift', 'left_command'])
    .to('f12', 'left_option')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 76: RCtrl+RCmd+ROpt+LShift+LCmd + h → Cmd+Shift+F12
  ...map('h', ['right_control', 'right_command', 'right_option', 'left_shift', 'left_command'])
    .to('f12', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 77: RCtrl+RCmd+ROpt+LOpt+LCtrl + e → km "Hover Info"
  ...map('e', ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'])
    .to(km('Hover Info'))
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 78: RCtrl+RCmd+ROpt+LOpt+LCtrl + n → F2
  ...map('n', ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'])
    .to('f2')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 79: RCtrl+RCmd+ROpt+LOpt+LCtrl + p → Shift+F2
  ...map('p', ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'])
    .to('f2', 'left_shift')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 80: RCtrl+RCmd+LShift+LCmd+LCtrl + b → Cmd+F3
  ...map('b', ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'])
    .to('f3', 'left_command')
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 81: RCtrl+RCmd+LShift+LCmd+LCtrl + f → Cmd+Shift+o
  ...map('f', ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'])
    .to('o', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 82: RCtrl+RCmd+LShift+LCmd+LCtrl + r → Cmd+Ctrl+Opt+3
  ...map('r', ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'])
    .to('3', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 83: RCtrl+RCmd+LShift+LCmd+LCtrl + y → Cmd+Shift+c
  ...map('y', ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'])
    .to('c', ['left_command', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 84: RCmd+RShift+LOpt+LShift+LCtrl + right → Cmd+Opt+`
  ...map('right_arrow', ['right_command', 'right_shift', 'left_option', 'left_shift', 'left_control'])
    .to('grave_accent_and_tilde', ['left_command', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 85: RCmd+RShift+LOpt+LShift+LCtrl + left → Cmd+Opt+Shift+`
  ...map('left_arrow', ['right_command', 'right_shift', 'left_option', 'left_shift', 'left_control'])
    .to('grave_accent_and_tilde', ['left_command', 'left_option', 'left_shift'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),

  // 86: RCtrl+RCmd+LOpt+LShift+LCtrl + p → Cmd+Ctrl+Opt+4
  ...map('p', ['right_control', 'right_command', 'left_option', 'left_shift', 'left_control'])
    .to('4', ['left_command', 'left_control', 'left_option'])
    .condition(intellijApp)
    .condition(kinesis)
    .build(),
]
