import { map } from '../../../../src/config/from.ts'
import { kinesis } from '../devices.ts'
import { km, shell, alfred, openApp } from '../helpers.ts'

export const description = "Global shortcuts on kinesis"

const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const
const rctrl_roption_lcmd_rshift = ['right_option', 'right_command', 'left_option', 'left_command', 'left_control'] as const
const lshift_rcmd_lctrl_rshift = ['left_shift', 'right_command', 'left_control', 'right_shift'] as const
const lshift_rcmd_loption_roption = ['left_shift', 'right_command', 'left_option', 'right_option'] as const
const lcmd_loption_lctrl_rshift = ['left_command', 'left_option', 'left_control', 'right_shift'] as const
const rctrl_rshift_loption_lshift_lctrl = ['right_control', 'right_shift', 'left_option', 'left_shift', 'left_control'] as const
const rctrl_rshift_lshift_lcmd_lctrl = ['right_control', 'right_shift', 'left_shift', 'left_command', 'left_control'] as const
const roption_rcmd_rshift_loption_lcmd = ['right_option', 'right_command', 'right_shift', 'left_option', 'left_command'] as const
const rctrl_loption_lshift_lcmd_lctrl = ['right_control', 'left_option', 'left_shift', 'left_command', 'left_control'] as const
const roption_rcmd_rshift_loption_lshift = ['right_option', 'right_command', 'right_shift', 'left_option', 'left_shift'] as const
const lshift_rcmd_roption_rctrl = ['left_shift', 'right_command', 'right_option', 'right_control'] as const
const rcmd_roption_rctrl_rshift = ['right_command', 'right_option', 'right_control', 'right_shift'] as const
const rctrl_rcmd_rshift_lshift_lcmd_lctrl = ['right_control', 'right_command', 'right_shift', 'left_shift', 'left_command', 'left_control'] as const
const rctrl_roption_rcmd_rshift_loption_lshift = ['right_control', 'right_option', 'right_command', 'right_shift', 'left_option', 'left_shift'] as const
const lshift_roption_rctrl_rshift = ['left_shift', 'right_option', 'right_control', 'right_shift'] as const
const rctrl_roption_rshift_loption_lshift_lcmd = ['right_control', 'right_option', 'right_shift', 'left_option', 'left_shift', 'left_command'] as const
const roption_rcmd_loption_lshift_lcmd = ['right_option', 'right_command', 'left_option', 'left_shift', 'left_command'] as const
const rcmd_rshift_loption_lshift_lctrl = ['right_command', 'right_shift', 'left_option', 'left_shift', 'left_control'] as const
const rctrl_rcmd_roption_loption_lcmd = ['right_control', 'right_command', 'right_option', 'left_option', 'left_command'] as const
const lshift_rcmd_lcmd_rshift = ['left_shift', 'right_command', 'left_command', 'right_shift'] as const
const rctrl_rcmd_rshift_loption_lcmd = ['right_control', 'right_command', 'right_shift', 'left_option', 'left_command'] as const
const roption_rcmd_rshift_lshift_lcmd = ['right_option', 'right_command', 'right_shift', 'left_shift', 'left_command'] as const
const rcmd_roption_lctrl_rshift = ['right_command', 'right_option', 'left_control', 'right_shift'] as const

export const manipulators = [
  // hyper+keypad_0 → f19
  ...map('keypad_0', [...hyper]).to('f19').condition(kinesis).build(),
  // hyper+6 → Cmd+spacebar
  ...map('6', [...hyper]).to('spacebar', 'left_command').condition(kinesis).build(),
  // hyper+8 → Cmd+tab
  ...map('8', [...hyper]).to('tab', 'left_command').condition(kinesis).build(),
  // hyper+keypad_2 → f19 with Cmd+Opt+Shift
  ...map('keypad_2', [...hyper]).to('f19', ['left_command', 'left_option', 'left_shift']).condition(kinesis).build(),
  // hyper+1 → f19 with Cmd+Ctrl+Shift
  ...map('1', [...hyper]).to('f19', ['left_command', 'left_control', 'left_shift']).condition(kinesis).build(),
  // ropt+lopt+lctrl+rctrl+backspace → Opt+backspace
  ...map('delete_or_backspace', ['right_option', 'left_option', 'left_control', 'right_control']).to('delete_or_backspace', 'left_option').condition(kinesis).build(),
  // lshift+rcmd+lctrl+rshift+spacebar → Ctrl+spacebar
  ...map('spacebar', [...lshift_rcmd_lctrl_rshift]).to('spacebar', 'left_control').condition(kinesis).build(),
  // lshift+rcmd+lctrl+rshift+return → Cmd+return
  ...map('return_or_enter', [...lshift_rcmd_lctrl_rshift]).to('return_or_enter', 'left_command').condition(kinesis).build(),
  // lshift+rcmd+loption+roption+quote → Cmd+z
  ...map('quote', [...lshift_rcmd_loption_roption]).to('z', 'left_command').condition(kinesis).build(),
  // lshift+rcmd+loption+roption+q → Cmd+x
  ...map('q', [...lshift_rcmd_loption_roption]).to('x', 'left_command').condition(kinesis).build(),
  // lshift+rcmd+loption+roption+j → Cmd+c
  ...map('j', [...lshift_rcmd_loption_roption]).to('c', 'left_command').condition(kinesis).build(),
  // lshift+rcmd+loption+roption+k → Cmd+v
  ...map('k', [...lshift_rcmd_loption_roption]).to('v', 'left_command').condition(kinesis).build(),
  // lshift+rcmd+loption+roption+x → Cmd+Shift+z
  ...map('x', [...lshift_rcmd_loption_roption]).to('z', ['left_command', 'left_shift']).condition(kinesis).build(),
  // lshift+rcmd+loption+roption+right_arrow → Cmd+Shift+v
  ...map('right_arrow', [...lshift_rcmd_loption_roption]).to('v', ['left_command', 'left_shift']).condition(kinesis).build(),
  // lshift+rcmd+loption+roption+left_arrow → return
  ...map('left_arrow', [...lshift_rcmd_loption_roption]).to('return_or_enter').condition(kinesis).build(),
  // lcmd+loption+lctrl+rshift+h → harpoon position 1
  ...map('h', [...lcmd_loption_lctrl_rshift]).to(shell('open "raycast://extensions/brian_wang/harpoon/openApplicationByPosition?arguments=%7B%22position%22%3A%221%22%7D"')).condition(kinesis).build(),
  // lcmd+loption+lctrl+rshift+t → harpoon position 2
  ...map('t', [...lcmd_loption_lctrl_rshift]).to(shell('open "raycast://extensions/brian_wang/harpoon/openApplicationByPosition?arguments=%7B%22position%22%3A%222%22%7D"')).condition(kinesis).build(),
  // lcmd+loption+lctrl+rshift+n → harpoon position 3
  ...map('n', [...lcmd_loption_lctrl_rshift]).to(shell('open "raycast://extensions/brian_wang/harpoon/openApplicationByPosition?arguments=%7B%22position%22%3A%223%22%7D"')).condition(kinesis).build(),
  // lcmd+loption+lctrl+rshift+s → harpoon position 4
  ...map('s', [...lcmd_loption_lctrl_rshift]).to(shell('open "raycast://extensions/brian_wang/harpoon/openApplicationByPosition?arguments=%7B%22position%22%3A%224%22%7D"')).condition(kinesis).build(),
  // rctrl_roption_lcmd_rshift+t → tmux sessioner
  ...map('t', [...rctrl_roption_lcmd_rshift]).to(shell('open "raycast://extensions/louishuyng/tmux-sessioner/index"')).condition(kinesis).build(),
  // rctrl_roption_lcmd_rshift+o → obsidian search
  ...map('o', [...rctrl_roption_lcmd_rshift]).to(shell('open "raycast://extensions/KevinBatdorf/obsidian/searchNoteCommand?arguments=%7B%22tagArgument%22%3A%22%22%2C%22searchArgument%22%3A%22%22%7D"')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lcmd+s → smiley emoji
  ...map('s', [...roption_rcmd_rshift_loption_lcmd]).to(shell("echo -n '\u{1F642}' | pbcopy; pbpaste")).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lcmd+e → emoji search
  ...map('e', [...roption_rcmd_rshift_loption_lcmd]).to(shell('open "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"')).condition(kinesis).build(),
  // rctrl_rshift_loption_lshift_lctrl+g → goku
  ...map('g', [...rctrl_rshift_loption_lshift_lctrl]).to(shell('open "raycast://script-commands/goku"')).condition(kinesis).build(),
  // rctrl_rshift_loption_lshift_lctrl+r → file search
  ...map('r', [...rctrl_rshift_loption_lshift_lctrl]).to(shell('open "raycast://extensions/raycast/file-search/search-files"')).condition(kinesis).build(),
  // rctrl_rshift_loption_lshift_lctrl+q → close raycast
  ...map('q', [...rctrl_rshift_loption_lshift_lctrl]).to(km('closeRaycast')).condition(kinesis).build(),
  // rctrl_roption_lcmd_rshift+a → open arc tab
  ...map('a', [...rctrl_roption_lcmd_rshift]).to(alfred('open arc tab', 'www.Arc_Tabs_Spaces.com')).condition(kinesis).build(),
  // roption_rcmd_rshift_lshift_lcmd+t → hyper+0
  ...map('t', [...roption_rcmd_rshift_lshift_lcmd]).to('0', ['left_command', 'left_control', 'left_option', 'left_shift']).condition(kinesis).build(),
  // rctrl_roption_lcmd_rshift+p → Cmd+Ctrl+4
  ...map('p', [...rctrl_roption_lcmd_rshift]).to('4', ['left_command', 'left_control']).condition(kinesis).build(),
  // rctrl_rshift_lshift_lcmd_lctrl+o → open Anki
  ...map('o', [...rctrl_rshift_lshift_lcmd_lctrl]).to(openApp('/Applications/Anki.app/Contents/MacOS/anki')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+left_arrow → Cmd+Ctrl+4
  ...map('left_arrow', [...roption_rcmd_rshift_loption_lshift]).to('4', ['left_command', 'left_control']).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+right_arrow → open Anki
  ...map('right_arrow', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Anki.app/Contents/MacOS/anki')).condition(kinesis).build(),
  // rctrl_loption_lshift_lcmd_lctrl+p → aws codepipeline
  ...map('p', [...rctrl_loption_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/Falcon/aws/codepipeline"')).condition(kinesis).build(),
  // rctrl_loption_lshift_lcmd_lctrl+r → aws codecommit
  ...map('r', [...rctrl_loption_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/Falcon/aws/codecommit"')).condition(kinesis).build(),
  // rctrl_loption_lshift_lcmd_lctrl+s → aws secrets
  ...map('s', [...rctrl_loption_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/Falcon/aws/secrets"')).condition(kinesis).build(),
  // rctrl_loption_lshift_lcmd_lctrl+d → aws dynamodb
  ...map('d', [...rctrl_loption_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/Falcon/aws/dynamodb"')).condition(kinesis).build(),
  // rctrl_loption_lshift_lcmd_lctrl+l → aws lambda
  ...map('l', [...rctrl_loption_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/Falcon/aws/lambda"')).condition(kinesis).build(),
  // rctrl_rshift_lshift_lcmd_lctrl+y → youtube search
  ...map('y', [...rctrl_rshift_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/tonka3000/youtube/search-videos?arguments=%7B%22query%22%3A%22%22%7D"')).condition(kinesis).build(),
  // rctrl_rshift_lshift_lcmd_lctrl+g → ollama chat
  ...map('g', [...rctrl_rshift_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/massimiliano_pasquini/raycast-ollama/ollama-chat"')).condition(kinesis).build(),
  // hyper+keypad_6 → gemini chat
  ...map('keypad_6', [...hyper]).to(shell('open "raycast://extensions/EvanZhouDev/raycast-gemini/aiChat"')).condition(kinesis).build(),
  // lshift_rcmd_roption_rctrl+n → dictionary define word
  ...map('n', [...lshift_rcmd_roption_rctrl]).to(shell('open "raycast://extensions/raycast/dictionary/define-word"')).condition(kinesis).build(),
  // hyper+f10 → dictionary define word
  ...map('f10', [...hyper]).to(shell('open "raycast://extensions/raycast/dictionary/define-word"')).condition(kinesis).build(),
  // rctrl_rcmd_rshift_lshift_lcmd_lctrl+m → menu bar search
  ...map('m', [...rctrl_rcmd_rshift_lshift_lcmd_lctrl]).to(alfred('menu-bar-search', 'com.folded-paper.menu-bar-search')).condition(kinesis).build(),
  // lshift_rcmd_roption_rctrl+m → menu bar search
  ...map('m', [...lshift_rcmd_roption_rctrl]).to(alfred('menu-bar-search', 'com.folded-paper.menu-bar-search')).condition(kinesis).build(),
  // lshift_rcmd_roption_rctrl+d → dash search
  ...map('d', [...lshift_rcmd_roption_rctrl]).to(alfred('dash-search', 'com.kapeli.dash.workflow')).condition(kinesis).build(),
  // lshift_rcmd_roption_rctrl+c → chrome tab search
  ...map('c', [...lshift_rcmd_roption_rctrl]).to(alfred('chrome-tab-search', 'com.epilande.browser-tabs')).condition(kinesis).build(),
  // lshift_rcmd_roption_rctrl+s → google search
  ...map('s', [...lshift_rcmd_roption_rctrl]).to(shell('open "raycast://extensions/mblode/google-search/index"')).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+8 → menu bar search
  ...map('8', [...rcmd_roption_rctrl_rshift]).to(alfred('menu-bar-search', 'com.folded-paper.menu-bar-search')).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+7 → arc search
  ...map('7', [...rcmd_roption_rctrl_rshift]).to(shell('open "raycast://extensions/the-browser-company/arc/search"')).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+2 → Cmd+Opt+Shift+2
  ...map('2', [...rcmd_roption_rctrl_rshift]).to('2', ['left_command', 'left_option', 'left_shift']).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+3 → Cmd+Shift+7
  ...map('3', [...rcmd_roption_rctrl_rshift]).to('7', ['left_command', 'left_shift']).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+4 → Cmd+Shift+4
  ...map('4', [...rcmd_roption_rctrl_rshift]).to('4', ['left_command', 'left_shift']).condition(kinesis).build(),
  // rctrl_roption_rcmd_rshift_loption_lshift+keypad_0 → Cmd+spacebar
  ...map('keypad_0', ['right_control', 'right_option', 'right_command', 'right_shift', 'left_option', 'left_shift']).to('spacebar', 'left_command').condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+keypad_7 → hyper+f11
  ...map('keypad_7', [...rcmd_roption_rctrl_rshift]).to('f11', [...hyper]).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+keypad_plus → f13
  ...map('keypad_plus', [...rcmd_roption_rctrl_rshift]).to('f13').condition(kinesis).build(),
  // rctrl_roption_rcmd_rshift_lshift_lctrl+f → f13
  ...map('f', ['right_control', 'right_option', 'right_command', 'right_shift', 'left_shift', 'left_control']).to('f13').condition(kinesis).build(),
  // rcmd_roption_lctrl_rshift+g → f13
  ...map('g', [...rcmd_roption_lctrl_rshift]).to('f13').condition(kinesis).build(),
  // rcmd_roption_lctrl_rshift+c → f16
  ...map('c', [...rcmd_roption_lctrl_rshift]).to('f16').condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+c → Chrome og
  ...map('c', [...rctrl_roption_rshift_loption_lshift_lcmd]).to(km('Chrome - og')).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+i → jetbrains recent
  ...map('i', [...rctrl_roption_rshift_loption_lshift_lcmd]).to(shell('open "raycast://extensions/gdsmith/jetbrains/recent"')).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+b → Obsidian
  ...map('b', [...rctrl_roption_rshift_loption_lshift_lcmd]).to(km('Obsidian')).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+v → VS Code
  ...map('v', [...rctrl_roption_rshift_loption_lshift_lcmd]).to(km('VS Code')).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+t → hyper+equal_sign
  ...map('t', [...rctrl_roption_rshift_loption_lshift_lcmd]).to('equal_sign', [...hyper]).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+backspace → hyper+fn+spacebar
  ...map('delete_or_backspace', [...rctrl_roption_rshift_loption_lshift_lcmd]).to('spacebar', ['left_command', 'left_option', 'left_control', 'left_shift', 'fn']).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+f → F Path Finder
  ...map('f', [...rctrl_roption_rshift_loption_lshift_lcmd]).to(km('F Path Finder')).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+g → gptChat
  ...map('g', [...rctrl_roption_rshift_loption_lshift_lcmd]).to(km('gptChat')).condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+r → Cmd+spacebar
  ...map('r', [...rctrl_roption_rshift_loption_lshift_lcmd]).to('spacebar', 'left_command').condition(kinesis).build(),
  // rctrl_roption_rshift_loption_lshift_lcmd+a → hyper+f11
  ...map('a', [...rctrl_roption_rshift_loption_lshift_lcmd]).to('f11', [...hyper]).condition(kinesis).build(),
  // rctrl_rcmd_rshift_lshift_lcmd_lctrl+c → chrome tab search
  ...map('c', [...rctrl_rcmd_rshift_lshift_lcmd_lctrl]).to(alfred('chrome-tab-search', 'com.epilande.browser-tabs')).condition(kinesis).build(),
  // rctrl_rcmd_rshift_lshift_lcmd_lctrl+d → dictionary define word
  ...map('d', [...rctrl_rcmd_rshift_lshift_lcmd_lctrl]).to(shell('open "raycast://extensions/raycast/dictionary/define-word"')).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+p → umlaut U (Opt+u, Shift+u)
  ...map('p', [...lshift_roption_rctrl_rshift]).to('u', 'left_option').to('u', 'left_shift').condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+semicolon → umlaut A (Opt+u, Shift+a)
  ...map('semicolon', [...lshift_roption_rctrl_rshift]).to('u', 'left_option').to('a', 'left_shift').condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+comma → umlaut O (Opt+u, Shift+o)
  ...map('comma', [...lshift_roption_rctrl_rshift]).to('u', 'left_option').to('o', 'left_shift').condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+u → umlaut u (Opt+u, u)
  ...map('u', [...lshift_roption_rctrl_rshift]).to('u', 'left_option').to('u').condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+a → umlaut a (Opt+u, a)
  ...map('a', [...lshift_roption_rctrl_rshift]).to('u', 'left_option').to('a').condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+o → umlaut o (Opt+u, o)
  ...map('o', [...lshift_roption_rctrl_rshift]).to('u', 'left_option').to('o').condition(kinesis).build(),
  // rctrl_rcmd_roption_loption_lcmd+a → hyper+f11
  ...map('a', [...rctrl_rcmd_roption_loption_lcmd]).to('f11', [...hyper]).condition(kinesis).build(),
  // lcmd_loption_lctrl_rshift+spacebar → hyper+5
  ...map('spacebar', [...lcmd_loption_lctrl_rshift]).to('5', ['left_command', 'left_control', 'left_option', 'left_shift']).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+h → left half window
  ...map('h', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://extensions/raycast/window-management/left-half'")).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+s → right half window
  ...map('s', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://extensions/raycast/window-management/right-half'")).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+m → maximize window
  ...map('m', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://extensions/raycast/window-management/maximize'")).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+c → center three fourths
  ...map('c', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://extensions/raycast/window-management/center-three-fourths'")).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+d → next fullscreen display
  ...map('d', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://script-commands/next-fullscreen-display'")).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+b → previous display
  ...map('b', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://extensions/raycast/window-management/previous-display'")).condition(kinesis).build(),
  // lshift_roption_rctrl_rshift+f → toggle fullscreen
  ...map('f', [...lshift_roption_rctrl_rshift]).to(shell("open -g 'raycast://extensions/raycast/window-management/toggle-fullscreen'")).condition(kinesis).build(),
  // rcmd_rshift_loption_lshift_lctrl+w → Cmd+tab
  ...map('w', [...rcmd_rshift_loption_lshift_lctrl]).to('tab', 'left_command').condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+a → Arcbrowser
  ...map('a', [...roption_rcmd_rshift_loption_lshift]).to(km('Arcbrowser')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+z → open Zen
  ...map('z', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Zen.app/Contents/MacOS/zen')).condition(kinesis).build(),
  // rctrl_roption_lcmd_rshift+s → Wooshy window
  ...map('s', [...rctrl_roption_lcmd_rshift]).to(alfred('start', 'mo.com.sleeplessmind.WooshyWindowToTheForeground')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+h → open Chrome Dev
  ...map('h', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Google Chrome Dev.app/Contents/MacOS/Google Chrome Dev')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+e → open PDF Expert
  ...map('e', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/PDF Expert.app')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+l → open intellij applicationapi
  ...map('l', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij applicationapi')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+g → open intellij userapi
  ...map('g', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij userapi')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+n → open intellij notificationapi
  ...map('n', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij notificationapi')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+m → open intellij myapplications
  ...map('m', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij myapplications')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+s → open intellij nscworkbasket
  ...map('s', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij nscworkbasket')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+w → open intellij workbasket
  ...map('w', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij workbasket')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+9 → open intellij fe-role-reg
  ...map('9', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij fe-role-reg')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+8 → open intellij fe-company-reg
  ...map('8', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij fe-company-reg')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+7 → open intellij fe-comp-admin-reg
  ...map('7', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij fe-comp-admin-reg')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+c → open VS Code
  ...map('c', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Visual Studio Code.app/Contents/MacOS/Electron')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+r → open intellij marketconfig
  ...map('r', [...roption_rcmd_rshift_loption_lshift]).to(km('open: intellij marketconfig')).condition(kinesis).build(),
  // roption_rcmd_loption_lshift_lcmd+t → open arc tab BMW Teams
  ...map('t', [...roption_rcmd_loption_lshift_lcmd]).to(shell('open "raycast://extensions/the-browser-company/arc/open-tab-named?launchType=background&arguments=%7B%22tabName%22%3A%22BMW%20Teams%20(BT)%22%7D"')).condition(kinesis).build(),
  // roption_rcmd_loption_lshift_lcmd+c → open arc tab Randstad Calendar
  ...map('c', [...roption_rcmd_loption_lshift_lcmd]).to(shell('open "raycast://extensions/the-browser-company/arc/open-tab-named?launchType=background&arguments=%7B%22tabName%22%3A%22Randstad%20Google%20Calendar%20(RGC)%22%7D"')).condition(kinesis).build(),
  // roption_rcmd_loption_lshift_lcmd+m → open arc tab Randstad Gmail
  ...map('m', [...roption_rcmd_loption_lshift_lcmd]).to(shell('open "raycast://extensions/the-browser-company/arc/open-tab-named?launchType=background&arguments=%7B%22tabName%22%3A%22Randstad%20Google%20Gmail%20(RGG)%22%7D"')).condition(kinesis).build(),
  // roption_rcmd_loption_lshift_lcmd+d → open arc tab
  ...map('d', [...roption_rcmd_loption_lshift_lcmd]).to(alfred('open arc tab', 'www.Arc_Tabs_Spaces.com')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+i → jetbrains recent
  ...map('i', [...roption_rcmd_rshift_loption_lshift]).to(shell('open "raycast://extensions/gdsmith/jetbrains/recent"')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+o → open Notion
  ...map('o', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Notion.app/Contents/MacOS/Notion')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+v → open VS Code
  ...map('v', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Visual Studio Code.app/Contents/MacOS/Electron')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+d → hyper+equal_sign
  ...map('d', [...roption_rcmd_rshift_loption_lshift]).to('equal_sign', [...hyper]).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+semicolon → open Ausy Gmail
  ...map('semicolon', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Users/arabshaptukaev/Applications/Edge Apps.localized/Ausy:Randstad Gmail.app/Contents/MacOS/app_mode_loader')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+comma → open Ausy Calendar
  ...map('comma', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Users/arabshaptukaev/Applications/Edge Apps.localized/Ausy:Randstad Google Calendar.app/Contents/MacOS/app_mode_loader')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+period → open Gemini
  ...map('period', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Users/arabshaptukaev/Applications/Chrome Apps.localized/Gemini.app/Contents/MacOS/app_mode_loader')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+p → open AGIS Portal
  ...map('p', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Users/arabshaptukaev/Applications/Edge Apps.localized/Ausy:Randstad AGIS-Portal.app/Contents/MacOS/app_mode_loader')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+y → open Microsoft Teams
  ...map('y', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Users/arabshaptukaev/Applications/Chrome Apps.localized/Microsoft Teams.app/Contents/MacOS/app_mode_loader')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+k → open Postman
  ...map('k', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Postman.app/Contents/MacOS/Postman')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+q → open VS Code
  ...map('q', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Visual Studio Code.app/Contents/MacOS/Electron')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+j → open Perplexity
  ...map('j', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Perplexity.app/Contents/MacOS/Perplexity')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+u → IntelliJ IDEA og
  ...map('u', [...roption_rcmd_rshift_loption_lshift]).to(km('IntelliJ IDEA - og')).condition(kinesis).build(),
  // lshift_rcmd_lcmd_rshift+spacebar → hyper+fn+spacebar
  ...map('spacebar', [...lshift_rcmd_lcmd_rshift]).to('spacebar', ['left_command', 'left_option', 'left_control', 'left_shift', 'fn']).condition(kinesis).build(),
  // rcmd_roption_rctrl_rshift+end → open Warp
  ...map('end', [...rcmd_roption_rctrl_rshift]).to(openApp('/Applications/Warp.app/Contents/MacOS/stable')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+quote → open Warp
  ...map('quote', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Warp.app/Contents/MacOS/stable')).condition(kinesis).build(),
  // roption_rcmd_rshift_loption_lshift+f → open Path Finder
  ...map('f', [...roption_rcmd_rshift_loption_lshift]).to(openApp('/Applications/Path Finder.app/Contents/MacOS/Path Finder')).condition(kinesis).build(),
  // rctrl_rcmd_rshift_loption_lcmd+semicolon → clear notification
  ...map('semicolon', [...rctrl_rcmd_rshift_loption_lcmd]).toNotificationMessage('92', '').condition(kinesis).build(),
]
