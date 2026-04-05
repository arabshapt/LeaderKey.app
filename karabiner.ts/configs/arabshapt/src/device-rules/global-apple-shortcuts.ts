import { map } from '../../../../src/config/from.ts'
import { apple_built_in } from '../devices.ts'

// Rule 41: "Global shortcuts on apple_built_in"
// F-key remappings: bare = media/system, fn+F = raw F-key
export const description = 'Global shortcuts on apple_built_in'

export const manipulators = [
  // --- Bare F-keys → media/system ---
  // f1 → brightness down
  ...map('f1').toConsumerKey('display_brightness_decrement').condition(apple_built_in).build(),
  // f2 → brightness up
  ...map('f2').toConsumerKey('display_brightness_increment').condition(apple_built_in).build(),
  // f3 → mission control
  ...map('f3').to('mission_control').condition(apple_built_in).build(),
  // f4 → fn+f4
  ...map('f4').to('f4', 'fn').condition(apple_built_in).build(),
  // f5 → fn+f5
  ...map('f5').to('f5', 'fn').condition(apple_built_in).build(),
  // f6 → fn+f6
  ...map('f6').to('f6', 'fn').condition(apple_built_in).build(),
  // f7 → fn+f7
  ...map('f7').to('f7', 'fn').condition(apple_built_in).build(),
  // f8 → play/pause
  ...map('f8').toConsumerKey('play_or_pause').condition(apple_built_in).build(),
  // f9 → fn+f9
  ...map('f9').to('f9', 'fn').condition(apple_built_in).build(),
  // f10 → mute
  ...map('f10').toConsumerKey('mute').condition(apple_built_in).build(),
  // f11 → volume down
  ...map('f11').toConsumerKey('volume_decrement').condition(apple_built_in).build(),
  // f12 → volume up
  ...map('f12').toConsumerKey('volume_increment').condition(apple_built_in).build(),

  // --- fn+F-keys → raw F-keys ---
  ...map('f1', ['fn']).to('f1').condition(apple_built_in).build(),
  ...map('f2', ['fn']).to('f2').condition(apple_built_in).build(),
  ...map('f3', ['fn']).to('f3').condition(apple_built_in).build(),
  ...map('f4', ['fn']).to('f4').condition(apple_built_in).build(),
  ...map('f5', ['fn']).to('f5').condition(apple_built_in).build(),
  ...map('f6', ['fn']).to('f6').condition(apple_built_in).build(),
  ...map('f7', ['fn']).to('f7').condition(apple_built_in).build(),
  ...map('f8', ['fn']).to('f8').condition(apple_built_in).build(),
  ...map('f9', ['fn']).to('f9').condition(apple_built_in).build(),
  ...map('f10', ['fn']).to('f10').condition(apple_built_in).build(),
  ...map('f11', ['fn']).to('f11').condition(apple_built_in).build(),
  ...map('f12', ['fn']).to('f12').condition(apple_built_in).build(),

  // --- Other shortcuts ---
  // Cmd+right_command → superhyper+spacebar
  ...map('right_command', ['left_command'])
    .to('spacebar', ['left_command', 'left_option', 'left_control', 'left_shift', 'fn'])
    .condition(apple_built_in)
    .build(),
  // Cmd+caps_lock → Cmd+escape
  ...map('caps_lock', ['left_command']).to('escape', 'left_command').condition(apple_built_in).build(),
]
