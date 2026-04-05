import { map } from '../../../../src/config/from.ts'
import { kinesis } from '../devices.ts'
import { shell } from '../helpers.ts'

// Rule 46: "appswitcher-kin-hyper applications :hyper_44"
// App launcher shortcuts on Kinesis keyboards
export const description = 'appswitcher-kin-hyper applications :hyper_44'

const hyper44 = ['right_option', 'left_option', 'left_control', 'right_control'] as const

export const manipulators = [
  // c → Chrome
  ...map('c', [...hyper44]).to(shell("open -a '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'")).condition(kinesis).build(),
  // h → Chrome Dev
  ...map('h', [...hyper44]).to(shell("open -a '/Applications/Google Chrome Dev.app/Contents/MacOS/Google Chrome Dev'")).condition(kinesis).build(),
  // e → Edge
  ...map('e', [...hyper44]).to(shell("open -a '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge'")).condition(kinesis).build(),
  // i → IntelliJ
  ...map('i', [...hyper44]).to(shell("open -a '/Applications/IntelliJ IDEA Ultimate.app/Contents/MacOS/idea'")).condition(kinesis).build(),
  // o → Obsidian
  ...map('o', [...hyper44]).to(shell("open -a '/Applications/Obsidian.app/Contents/MacOS/Obsidian'")).condition(kinesis).build(),
  // v → VS Code
  ...map('v', [...hyper44]).to(shell("open -a '/Applications/Visual Studio Code.app/Contents/MacOS/Electron'")).condition(kinesis).build(),
  // d → hyper+equal_sign (desktop)
  ...map('d', [...hyper44]).to('equal_sign', ['left_command', 'left_option', 'left_control', 'left_shift']).condition(kinesis).build(),
  // 1 → Gmail
  ...map('1', [...hyper44]).to(shell("open -a '/Users/arabshaptukaev/Applications/Edge Apps.localized/Gmail.app/Contents/MacOS/app_mode_loader'")).condition(kinesis).build(),
  // hyper29 + spacebar → superhyper+spacebar
  ...map('spacebar', ['left_shift', 'right_command', 'left_command', 'right_shift'])
    .to('spacebar', ['left_command', 'left_option', 'left_control', 'left_shift', 'fn'])
    .condition(kinesis)
    .build(),
  // f → Path Finder
  ...map('f', [...hyper44]).to(shell("open -a '/Applications/Path Finder.app/Contents/MacOS/Path Finder'")).condition(kinesis).build(),
  // g → MacGPT
  ...map('g', [...hyper44]).to(shell("open -a '/Applications/MacGPT.app/Contents/MacOS/MacGPT'")).condition(kinesis).build(),
  // h → Cmd+spacebar (spotlight, duplicate key with different action)
  ...map('h', [...hyper44]).to('spacebar', 'left_command').condition(kinesis).build(),
]
