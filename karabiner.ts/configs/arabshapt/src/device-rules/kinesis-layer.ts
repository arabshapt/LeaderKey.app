import { map } from '../../../../src/config/from.ts'
import { kinesis } from '../devices.ts'

// Rule 39: "kinesis kinesis-layer-right-cmd-hyper-kp-ast layer"
// kp_asterisk + right_cmd_hyper → held: Cmd+C, alone: Cmd+V
export const description = 'kinesis kinesis-layer-right-cmd-hyper-kp-ast layer'

export const manipulators = [
  ...map('keypad_asterisk', ['right_command', 'shift', 'control', 'option'])
    .toIfAlone('v', 'left_command')
    .toIfHeldDown('c', 'left_command')
    .condition(kinesis)
    .build(),
]
