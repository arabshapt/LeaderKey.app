import { ifApp, ifVar } from '../../../src/config/condition.ts'

// Application conditions — match EDN :applications section (LEADERKEY_APPLICATIONS)

export const antigravity = ifApp('com.google.antigravity')
export const intellij = ifApp('com.jetbrains.intellij')
export const karabinerEvent = ifApp('org.pqrs.Karabiner-EventViewer')
export const vscode = ifApp('com.microsoft.VSCode')
export const ghostty = ifApp('com.mitchellh.ghostty')
export const arc = ifApp('company.thebrowser.Browser')
export const comet = ifApp('ai.perplexity.comet')
export const calendar = ifApp('com.apple.iCal')
export const emailRandstad = ifApp('com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm')
export const vlc = ifApp('org.videolan.vlc')
export const imessages = ifApp('com.apple.MobileSMS')
export const warp = ifApp('dev.warp.Warp-Stable')
export const bitwarden = ifApp('com.bitwarden.desktop')
export const raycast = ifApp('com.raycast.macos')
export const kiro = ifApp('dev.kiro.desktop')
export const wezterm = ifApp('com.github.wez.wezterm')
export const finder = ifApp('com.apple.finder')
export const zed = ifApp('dev.zed.Zed')
export const googleChromeDev = ifApp('com.google.Chrome.dev')
export const msTeamsWeb = ifApp('com.google.Chrome.app.cifhbcnohmdccbgoicgdjpfamggdegmo')
export const dia = ifApp('company.thebrowser.dia')
export const cursor = ifApp('com.todesktop.230313mzl4w4u92')
export const xcode = ifApp('com.apple.dt.Xcode')
export const codex = ifApp('com.openai.codex')
export const pathfinder = ifApp('com.cocoatech.PathFinder')
export const geminiChrome = ifApp('com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn')
export const googleChrome = ifApp('com.google.Chrome')
export const notion = ifApp('notion.id')

// Leader Key state conditions

export const lk_active = ifVar('leaderkey_active', 1)
export const lk_not_active = ifVar('leaderkey_active', 0)
export const lk_appspecific = ifVar('leaderkey_appspecific', 1)
export const lk_global = ifVar('leaderkey_global', 1)
export const lk_not_global = ifVar('leaderkey_global', 0)
export const lk_sticky = ifVar('leaderkey_sticky', 1)
export const lk_not_sticky = ifVar('leaderkey_sticky', 0)

export function leaderState(id: number) {
  return ifVar('leader_state', id)
}
