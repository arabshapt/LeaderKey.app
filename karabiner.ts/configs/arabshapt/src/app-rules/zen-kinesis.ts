import { map, mapPointingButton } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'
import { kinesis } from '../devices.ts'
import { km } from '../helpers.ts'

// Rule 61: "Zen kinesis"
// 41 manipulators
export const description = 'Zen kinesis'

const zen = ifVar('zen', 1)
const hyperFn = ['fn', 'left_command', 'left_option', 'left_control', 'left_shift'] as const
const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const
const hyper29 = ['left_shift', 'left_command', 'left_control', 'right_shift'] as const
const rightNav = ['right_control', 'right_option', 'right_shift', 'left_option', 'left_command'] as const
const leftRightCmd = ['left_shift', 'left_command', 'left_control', 'right_command'] as const
const rightShiftNav = ['left_shift', 'right_command', 'left_control', 'right_shift'] as const
const rightCmdHyper = ['right_control', 'right_command', 'left_shift', 'left_command', 'left_control'] as const
const mouseNav = ['right_option', 'right_command', 'right_shift', 'left_option', 'left_shift'] as const
const leftOptRightCmd = ['left_shift', 'left_command', 'left_option', 'right_command'] as const
const leftOptCtrlRightCmd = ['left_command', 'left_option', 'left_control', 'right_command'] as const
const rightCmdOptCtrl = ['right_control', 'right_command', 'right_option', 'left_option', 'left_control'] as const
const rightCmdOptLCmd = ['right_control', 'right_command', 'right_option', 'left_option', 'left_command'] as const
const rightNavCtrl = ['right_control', 'right_option', 'right_shift', 'left_command', 'left_control'] as const

export const manipulators = [
  // hyperFn+comma → Cmd+R
  ...map('comma', [...hyperFn]).to('r', 'left_command').condition(zen).condition(kinesis).build(),
  // hyper+keypad_1 → Cmd+T
  ...map('keypad_1', [...hyper]).to('t', 'left_command').condition(zen).condition(kinesis).build(),
  // rightNav+p → Ctrl+Tab
  ...map('p', [...rightNav]).to('tab', 'left_control').condition(zen).condition(kinesis).build(),
  // leftRightCmd+o → Cmd+R
  ...map('o', [...leftRightCmd]).to('r', 'left_command').condition(zen).condition(kinesis).build(),
  // rightNav+s → Cmd+Shift+=
  ...map('s', [...rightNav]).to('equal_sign', ['left_command', 'left_shift']).condition(zen).condition(kinesis).build(),
  // hyper29+p → Ctrl+Tab
  ...map('p', [...hyper29]).to('tab', 'left_control').condition(zen).condition(kinesis).build(),
  // hyper29+e → Ctrl+Shift+[
  ...map('e', [...hyper29]).to('open_bracket', ['left_control', 'left_shift']).condition(zen).condition(kinesis).build(),
  // hyper29+u → Ctrl+Shift+]
  ...map('u', [...hyper29]).to('close_bracket', ['left_control', 'left_shift']).condition(zen).condition(kinesis).build(),
  // hyper29+o → Ctrl+Shift+=
  ...map('o', [...hyper29]).to('equal_sign', ['left_control', 'left_shift']).condition(zen).condition(kinesis).build(),
  // hyper29+a → Cmd+T
  ...map('a', [...hyper29]).to('t', 'left_command').condition(zen).condition(kinesis).build(),
  // rightShiftNav+h → Cmd+[
  ...map('h', [...rightShiftNav]).to('open_bracket', 'left_command').condition(zen).condition(kinesis).build(),
  // rightShiftNav+s → Cmd+]
  ...map('s', [...rightShiftNav]).to('close_bracket', 'left_command').condition(zen).condition(kinesis).build(),
  // rightShiftNav+t → Cmd+Opt+Up
  ...map('t', [...rightShiftNav]).to('up_arrow', ['left_command', 'left_option']).condition(zen).condition(kinesis).build(),
  // rightShiftNav+n → Cmd+Opt+Down
  ...map('n', [...rightShiftNav]).to('down_arrow', ['left_command', 'left_option']).condition(zen).condition(kinesis).build(),
  // rightShiftNav+r → Cmd+R
  ...map('r', [...rightShiftNav]).to('r', 'left_command').condition(zen).condition(kinesis).build(),
  // rightShiftNav+c → Cmd+W
  ...map('c', [...rightShiftNav]).to('w', 'left_command').condition(zen).condition(kinesis).build(),
  // rightShiftNav+l → Cmd+L
  ...map('l', [...rightShiftNav]).to('l', 'left_command').condition(zen).condition(kinesis).build(),
  // rightCmdHyper+f → km "Search with Claude"
  ...map('f', [...rightCmdHyper]).to(km('Search with Claude')).condition(zen).condition(kinesis).build(),
  // mouseNav+button1 → Cmd+Opt+Up
  ...mapPointingButton('button1', [...mouseNav])
    .to('up_arrow', ['left_command', 'left_option'])
    .condition(zen)
    .condition(kinesis)
    .build(),
  // mouseNav+button2 → Cmd+Opt+Down
  ...mapPointingButton('button2', [...mouseNav])
    .to('down_arrow', ['left_command', 'left_option'])
    .condition(zen)
    .condition(kinesis)
    .build(),
  // hyper+7 → Cmd+T
  ...map('7', [...hyper]).to('t', 'left_command').condition(zen).condition(kinesis).build(),
  // rightShiftNav+m → Cmd+Opt+Shift+F1
  ...map('m', [...rightShiftNav]).to('f1', ['left_command', 'left_option', 'left_shift']).condition(zen).condition(kinesis).build(),
  // rightShiftNav+w → Cmd+Opt+Shift+F2
  ...map('w', [...rightShiftNav]).to('f2', ['left_command', 'left_option', 'left_shift']).condition(zen).condition(kinesis).build(),
  // rightShiftNav+v → Cmd+Opt+Shift+F3
  ...map('v', [...rightShiftNav]).to('f3', ['left_command', 'left_option', 'left_shift']).condition(zen).condition(kinesis).build(),
  // hyper+f7 → Cmd+[
  ...map('f7', [...hyper]).to('open_bracket', 'left_command').condition(zen).condition(kinesis).build(),
  // hyper+f8 → Cmd+]
  ...map('f8', [...hyper]).to('close_bracket', 'left_command').condition(zen).condition(kinesis).build(),
  // hyper+f9 → Cmd+[
  ...map('f9', [...hyper]).to('open_bracket', 'left_command').condition(zen).condition(kinesis).build(),
  // hyper+f11 → Cmd+]
  ...map('f11', [...hyper]).to('close_bracket', 'left_command').condition(zen).condition(kinesis).build(),
  // hyper+f1 → km "Arc: Ask perplexity"
  ...map('f1', [...hyper]).to(km('Arc: Ask perplexity')).condition(zen).condition(kinesis).build(),
  // hyper+f6 → Cmd+R
  ...map('f6', [...hyper]).to('r', 'left_command').condition(zen).condition(kinesis).build(),
  // rightNav+p (duplicate) → Ctrl+Tab
  ...map('p', [...rightNav]).to('tab', 'left_control').condition(zen).condition(kinesis).build(),
  // hyper+keypad_8 → Ctrl+Tab
  ...map('keypad_8', [...hyper]).to('tab', 'left_control').condition(zen).condition(kinesis).build(),
  // rightNav+d → Opt+Shift+D
  ...map('d', [...rightNav]).to('d', ['left_option', 'left_shift']).condition(zen).condition(kinesis).build(),
  // rightNav+s (duplicate) → Cmd+Shift+=
  ...map('s', [...rightNav]).to('equal_sign', ['left_command', 'left_shift']).condition(zen).condition(kinesis).build(),
  // rightNav+f → km "Arc: Separate Page from Split View"
  ...map('f', [...rightNav]).to(km('Arc: Separate Page from Split View')).condition(zen).condition(kinesis).build(),
  // leftOptRightCmd+y → Cmd+Shift+C
  ...map('y', [...leftOptRightCmd]).to('c', ['left_command', 'left_shift']).condition(zen).condition(kinesis).build(),
  // leftOptCtrlRightCmd+f → km "Search with Claude"
  ...map('f', [...leftOptCtrlRightCmd]).to(km('Search with Claude')).condition(zen).condition(kinesis).build(),
  // rightCmdOptCtrl+c → km "Arc extension EditThisCookie" + Ctrl+F1
  ...map('c', [...rightCmdOptCtrl])
    .to(km('Arc extension EditThisCookie'))
    .to('f1', 'left_control')
    .condition(zen)
    .condition(kinesis)
    .build(),
  // rightCmdOptCtrl+h → km "Arc extension ModHeader" + Ctrl+F1
  ...map('h', [...rightCmdOptCtrl])
    .to(km('Arc extension ModHeader'))
    .to('f1', 'left_control')
    .condition(zen)
    .condition(kinesis)
    .build(),
  // rightCmdOptLCmd+h → km "Arc Archive View History" + Ctrl+F1
  ...map('h', [...rightCmdOptLCmd])
    .to(km('Arc Archive View History'))
    .to('f1', 'left_control')
    .condition(zen)
    .condition(kinesis)
    .build(),
  // rightNavCtrl+q → km "Arc File Archive Tab" + Ctrl+F1
  ...map('q', [...rightNavCtrl])
    .to(km('Arc File Archive Tab'))
    .to('f1', 'left_control')
    .condition(zen)
    .condition(kinesis)
    .build(),
]
