import { map } from '../../../../src/config/from.ts'
import { apple } from '../devices.ts'

// Rule 36: "apple"
// slash → left_command (tap: slash) on Apple keyboard
export const description = 'apple'

export const manipulators = [
  ...map('slash').to('left_command').toIfAlone('slash').condition(apple).build(),
]
