import { map } from '../../../../src/config/from.ts'
import { ifVar } from '../../../../src/config/condition.ts'

// Rule 4: "Leader Key - Modifier Pass-Through"
// Pass modifier keys through when leader key is active
export const description = 'Leader Key - Modifier Pass-Through'

const leaderActive = ifVar('leaderkey_active', 1)

export const manipulators = [
  ...map('left_shift', null, 'any').to('left_shift').condition(leaderActive).build(),
  ...map('right_shift', null, 'any').to('right_shift').condition(leaderActive).build(),
  ...map('left_command', null, 'any').to('left_command').condition(leaderActive).build(),
  ...map('right_command', null, 'any').to('right_command').condition(leaderActive).build(),
  ...map('left_option', null, 'any').to('left_option').condition(leaderActive).build(),
  ...map('right_option', null, 'any').to('right_option').condition(leaderActive).build(),
  ...map('left_control', null, 'any').to('left_control').condition(leaderActive).build(),
  ...map('right_control', null, 'any').to('right_control').condition(leaderActive).build(),
]
