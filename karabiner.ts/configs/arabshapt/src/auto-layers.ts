import { map } from '../../../src/config/from.ts'
import { toSetVar } from '../../../src/config/to.ts'

// Rule 0: "Auto generated layer conditions"
// Layer activation keys: hold = activate layer, tap = original key
export const description = 'Auto generated layer conditions'

export const manipulators = [
  ...map('grave_accent_and_tilde')
    .toVar('tilde-mode', 1)
    .toAfterKeyUp(toSetVar('tilde-mode', 0))
    .toIfAlone('grave_accent_and_tilde')
    .build(),
  ...map('tab')
    .toVar('tab-mode', 1)
    .toAfterKeyUp(toSetVar('tab-mode', 0))
    .toIfAlone('tab')
    .build(),
  ...map('slash')
    .toVar('slash-mode', 1)
    .toAfterKeyUp(toSetVar('slash-mode', 0))
    .toIfAlone('slash')
    .build(),
  ...map('backslash')
    .toVar('backslash-mode', 1)
    .toAfterKeyUp(toSetVar('backslash-mode', 0))
    .toIfAlone('backslash')
    .build(),
  ...map('keypad_hyphen')
    .toVar('kinesis-amps-mode', 1)
    .toAfterKeyUp(toSetVar('kinesis-amps-mode', 0))
    .toIfAlone('vk_none')
    .build(),
]
