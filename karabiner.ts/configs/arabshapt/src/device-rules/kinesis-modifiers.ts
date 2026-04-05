import { map } from '../../../../src/config/from.ts'
import { km } from '../helpers.ts'

// Rule 44: "modifiers on kinesis"
// hyper_04 (LS+LO+LC+RO) + a → Keyboard Maestro "open: Books"
export const description = 'modifiers on kinesis'

export const manipulators = [
  ...map('a', ['left_shift', 'left_option', 'left_control', 'right_option'])
    .to(km('open: Books'))
    .build(),
]
