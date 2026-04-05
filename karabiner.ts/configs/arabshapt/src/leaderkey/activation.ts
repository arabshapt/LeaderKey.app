import type { BasicManipulator } from '../../../../src/karabiner/karabiner-config.ts'
import { map } from '../../../../src/config/from.ts'
import { ifVar, ifApp } from '../../../../src/config/condition.ts'
import { kinesis, apple_built_in } from '../devices.ts'

// Rule 3: "Leader Key - Activation Shortcuts"
// 56 manipulators
export const description = "Leader Key - Activation Shortcuts"

const hyper = ['left_command', 'left_option', 'left_control', 'left_shift'] as const

const noModes = [
  ifVar('caps_lock-mode', 1).unless(),
  ifVar('f-mode', 1).unless(),
  ifVar('tilde-mode', 1).unless(),
]

export const manipulators: BasicManipulator[] = [
  // ── Kinesis: app-specific activations (keypad_4 + hyper) ──

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 92584)
    .toSendUserCommand('activate com.jetbrains.intellij')
    .condition(ifApp('com.jetbrains.intellij'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 11081)
    .toSendUserCommand('activate com.google.antigravity')
    .condition(ifApp('com.google.antigravity'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 56841)
    .toSendUserCommand('activate com.microsoft.VSCode')
    .condition(ifApp('com.microsoft.VSCode'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 72041)
    .toSendUserCommand('activate company.thebrowser.Browser')
    .condition(ifApp('company.thebrowser.Browser'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 81761)
    .toSendUserCommand('activate ai.perplexity.comet')
    .condition(ifApp('ai.perplexity.comet'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 63366)
    .toSendUserCommand('activate com.apple.iCal')
    .condition(ifApp('com.apple.iCal'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 81673)
    .toSendUserCommand('activate com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm')
    .condition(ifApp('com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 94712)
    .toSendUserCommand('activate org.videolan.vlc')
    .condition(ifApp('org.videolan.vlc'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 28048)
    .toSendUserCommand('activate dev.warp.Warp-Stable')
    .condition(ifApp('dev.warp.Warp-Stable'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 66305)
    .toSendUserCommand('activate com.bitwarden.desktop')
    .condition(ifApp('com.bitwarden.desktop'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 54581)
    .toSendUserCommand('activate dev.kiro.desktop')
    .condition(ifApp('dev.kiro.desktop'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 15780)
    .toSendUserCommand('activate com.github.wez.wezterm')
    .condition(ifApp('com.github.wez.wezterm'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 75310)
    .toSendUserCommand('activate com.mitchellh.ghostty')
    .condition(ifApp('com.mitchellh.ghostty'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 39965)
    .toSendUserCommand('activate com.apple.finder')
    .condition(ifApp('com.apple.finder'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 98838)
    .toSendUserCommand('activate dev.zed.Zed')
    .condition(ifApp('dev.zed.Zed'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 59912)
    .toSendUserCommand('activate com.google.Chrome.app.cifhbcnohmdccbgoicgdjpfamggdegmo')
    .condition(ifApp('com.google.Chrome.app.cifhbcnohmdccbgoicgdjpfamggdegmo'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 75009)
    .toSendUserCommand('activate company.thebrowser.dia')
    .condition(ifApp('company.thebrowser.dia'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 94679)
    .toSendUserCommand('activate com.todesktop.230313mzl4w4u92')
    .condition(ifApp('com.todesktop.230313mzl4w4u92'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 59534)
    .toSendUserCommand('activate com.apple.dt.Xcode')
    .condition(ifApp('com.apple.dt.Xcode'))
    .condition(kinesis)
    .build(),

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 41996)
    .toSendUserCommand('activate com.cocoatech.PathFinder')
    .condition(ifApp('com.cocoatech.PathFinder'))
    .condition(kinesis)
    .build(),

  // ── Kinesis: global activation (keypad_7 + hyper) ──

  ...map('keypad_7', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_global', 1)
    .toVar('leaderkey_appspecific', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 1)
    .toSendUserCommand('activate')
    .condition(kinesis)
    .build(),

  // ── Kinesis: fallback activation (keypad_4 + hyper, no app condition) ──

  ...map('keypad_4', [...hyper])
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 2)
    .toSendUserCommand('activate __FALLBACK__')
    .condition(kinesis)
    .build(),

  // ── Kinesis: escape deactivation ──

  ...map('escape')
    .toVar('leaderkey_active', 0)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_appspecific', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 0)
    .toSendUserCommand('deactivate')
    .condition(ifVar('leaderkey_active', 1))
    .condition(kinesis)
    .build(),

  // ── Kinesis: settings (cmd+comma while active) ──

  ...map('comma', ['command'])
    .toVar('leaderkey_active', 0)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_appspecific', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 0)
    .toSendUserCommand('deactivate')
    .toSendUserCommand('settings')
    .condition(ifVar('leaderkey_active', 1))
    .condition(kinesis)
    .build(),

  // ── Apple built-in: semicolon app-specific activations ──

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 81673)
    .toSendUserCommand('activate com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.google.Chrome.dev.app.fmgjjmmmlfnkbppncabfkddbjimcfncm'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 59912)
    .toSendUserCommand('activate com.google.Chrome.app.cifhbcnohmdccbgoicgdjpfamggdegmo')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.google.Chrome.app.cifhbcnohmdccbgoicgdjpfamggdegmo'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 95885)
    .toSendUserCommand('activate com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.google.Chrome.app.gdfaincndogidkdcdkhapmbffkckdkhn'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 52839)
    .toSendUserCommand('activate org.pqrs.Karabiner-EventViewer')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('org.pqrs.Karabiner-EventViewer'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 94679)
    .toSendUserCommand('activate com.todesktop.230313mzl4w4u92')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.todesktop.230313mzl4w4u92'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 72041)
    .toSendUserCommand('activate company.thebrowser.Browser')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('company.thebrowser.Browser'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 41996)
    .toSendUserCommand('activate com.cocoatech.PathFinder')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.cocoatech.PathFinder'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 15780)
    .toSendUserCommand('activate com.github.wez.wezterm')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.github.wez.wezterm'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 11081)
    .toSendUserCommand('activate com.google.antigravity')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.google.antigravity'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 92584)
    .toSendUserCommand('activate com.jetbrains.intellij')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.jetbrains.intellij'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 75009)
    .toSendUserCommand('activate company.thebrowser.dia')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('company.thebrowser.dia'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 66305)
    .toSendUserCommand('activate com.bitwarden.desktop')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.bitwarden.desktop'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 29333)
    .toSendUserCommand('activate com.google.Chrome.dev')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.google.Chrome.dev'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 75310)
    .toSendUserCommand('activate com.mitchellh.ghostty')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.mitchellh.ghostty'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 56841)
    .toSendUserCommand('activate com.microsoft.VSCode')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.microsoft.VSCode'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 28048)
    .toSendUserCommand('activate dev.warp.Warp-Stable')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('dev.warp.Warp-Stable'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 81761)
    .toSendUserCommand('activate ai.perplexity.comet')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('ai.perplexity.comet'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 29371)
    .toSendUserCommand('activate com.apple.MobileSMS')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.apple.MobileSMS'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 59534)
    .toSendUserCommand('activate com.apple.dt.Xcode')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.apple.dt.Xcode'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 62338)
    .toSendUserCommand('activate com.google.Chrome')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.google.Chrome'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 96428)
    .toSendUserCommand('activate com.raycast.macos')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.raycast.macos'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 39965)
    .toSendUserCommand('activate com.apple.finder')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.apple.finder'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 91558)
    .toSendUserCommand('activate com.openai.codex')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.openai.codex'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 54581)
    .toSendUserCommand('activate dev.kiro.desktop')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('dev.kiro.desktop'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 94712)
    .toSendUserCommand('activate org.videolan.vlc')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('org.videolan.vlc'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 63366)
    .toSendUserCommand('activate com.apple.iCal')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('com.apple.iCal'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 98838)
    .toSendUserCommand('activate dev.zed.Zed')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('dev.zed.Zed'))
    .condition(apple_built_in)
    .build(),

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 82902)
    .toSendUserCommand('activate notion.id')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifApp('notion.id'))
    .condition(apple_built_in)
    .build(),

  // ── Apple built-in: global activation (right_command) ──

  ...map('right_command')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_global', 1)
    .toVar('leaderkey_appspecific', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 1)
    .toSendUserCommand('activate')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(apple_built_in)
    .build(),

  // ── Apple built-in: fallback activation (semicolon, no app condition) ──

  ...map('semicolon')
    .toVar('leaderkey_active', 1)
    .toVar('leaderkey_appspecific', 1)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 2)
    .toSendUserCommand('activate __FALLBACK__')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(apple_built_in)
    .build(),

  // ── Apple built-in: escape deactivation ──

  ...map('escape')
    .toVar('leaderkey_active', 0)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_appspecific', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 0)
    .toSendUserCommand('deactivate')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifVar('leaderkey_active', 1))
    .condition(apple_built_in)
    .build(),

  // ── Apple built-in: settings (cmd+comma while active) ──

  ...map('comma', ['command'])
    .toVar('leaderkey_active', 0)
    .toVar('leaderkey_global', 0)
    .toVar('leaderkey_appspecific', 0)
    .toVar('leaderkey_sticky', 0)
    .toVar('leader_state', 0)
    .toSendUserCommand('deactivate')
    .toSendUserCommand('settings')
    .condition(ifVar('caps_lock-mode', 1).unless())
    .condition(ifVar('f-mode', 1).unless())
    .condition(ifVar('tilde-mode', 1).unless())
    .condition(ifVar('leaderkey_active', 1))
    .condition(apple_built_in)
    .build(),
]
