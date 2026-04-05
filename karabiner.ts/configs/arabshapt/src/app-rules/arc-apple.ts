import { map } from '../../../../src/config/from.ts'
import { ifApp, ifVar } from '../../../../src/config/condition.ts'
import { apple_built_in } from '../devices.ts'

// Rule 58: "Arc apple builtin"
// Arc browser shortcuts with multitouch on Apple built-in keyboard
export const description = 'Arc apple builtin'

const arcApp = ifApp('company.thebrowser.Browser')
const twoFingers = ifVar('multitouch_extension_finger_count_total', 2)
const oneFingerUpper = ifVar('multitouch_extension_finger_count_upper_half_area', 1)

export const manipulators = [
  // 2-finger + k → Cmd+Opt+Right (next space)
  ...map('k')
    .to('right_arrow', ['left_command', 'left_option'])
    .condition(arcApp)
    .condition(twoFingers)
    .condition(apple_built_in)
    .build(),
  // 2-finger + j → Cmd+Opt+Left (prev space)
  ...map('j')
    .to('left_arrow', ['left_command', 'left_option'])
    .condition(arcApp)
    .condition(twoFingers)
    .condition(apple_built_in)
    .build(),
  // 1-finger-upper + k → Cmd+] (forward)
  ...map('k')
    .to('close_bracket', 'left_command')
    .condition(arcApp)
    .condition(oneFingerUpper)
    .condition(apple_built_in)
    .build(),
  // 1-finger-upper + j → Cmd+[ (back)
  ...map('j')
    .to('open_bracket', 'left_command')
    .condition(arcApp)
    .condition(oneFingerUpper)
    .condition(apple_built_in)
    .build(),
  // 1-finger-upper + d → Cmd+Opt+Up (scroll up spaces)
  ...map('d')
    .to('up_arrow', ['left_command', 'left_option'])
    .condition(arcApp)
    .condition(oneFingerUpper)
    .condition(apple_built_in)
    .build(),
  // 1-finger-upper + f → Cmd+Opt+Down (scroll down spaces)
  ...map('f')
    .to('down_arrow', ['left_command', 'left_option'])
    .condition(arcApp)
    .condition(oneFingerUpper)
    .condition(apple_built_in)
    .build(),
]
