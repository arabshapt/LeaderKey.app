import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'

// Rule 38: "kinesis kinesis-layer-right-cmd-hyper-kp-ast layer mouse"
// u → return_or_enter in mouse-mode
export const description = 'kinesis kinesis-layer-right-cmd-hyper-kp-ast layer mouse'

export const manipulators = [
  ...map('u').to('return_or_enter').condition(ifVar('mouse-mode')).build(),
]
