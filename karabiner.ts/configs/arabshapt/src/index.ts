// Modular arabshapt config. 76 rules organized by domain.
// Parity-tested against Goku snapshot in default-profile.ts.

import type { Rule } from '../../../src/karabiner/karabiner-config.ts'

// Infrastructure
import { description as desc_00, manipulators as manip_00 } from './auto-layers'
import { description as desc_01, manipulators as manip_01 } from './caps-layer'
import { description as desc_02, manipulators as manip_02 } from './global-start'

// Leader Key
import { description as desc_03, manipulators as manip_03 } from './leaderkey/activation'
import { description as desc_04, manipulators as manip_04 } from './leaderkey/modifier-passthrough'

// Leader Key Apps
import { description as desc_05, manipulators as manip_05 } from './apps/antigravity'
import { description as desc_06, manipulators as manip_06 } from './apps/intellij'
import { description as desc_07, manipulators as manip_07 } from './apps/karabiner-event'
import { description as desc_08, manipulators as manip_08 } from './apps/vscode'
import { description as desc_09, manipulators as manip_09 } from './apps/ghostty'
import { description as desc_10, manipulators as manip_10 } from './apps/arc'
import { description as desc_11, manipulators as manip_11 } from './apps/comet'
import { description as desc_12, manipulators as manip_12 } from './apps/calendar'
import { description as desc_13, manipulators as manip_13 } from './apps/email-randstad'
import { description as desc_14, manipulators as manip_14 } from './apps/vlc'
import { description as desc_15, manipulators as manip_15 } from './apps/imessages'
import { description as desc_16, manipulators as manip_16 } from './apps/warp'
import { description as desc_17, manipulators as manip_17 } from './apps/bitwarden'
import { description as desc_18, manipulators as manip_18 } from './apps/raycast'
import { description as desc_19, manipulators as manip_19 } from './apps/kiro'
import { description as desc_20, manipulators as manip_20 } from './apps/wezterm'
import { description as desc_21, manipulators as manip_21 } from './apps/finder'
import { description as desc_22, manipulators as manip_22 } from './apps/zed'
import { description as desc_23, manipulators as manip_23 } from './apps/google-chrome-dev'
import { description as desc_24, manipulators as manip_24 } from './apps/ms-teams-web'
import { description as desc_25, manipulators as manip_25 } from './apps/dia'
import { description as desc_26, manipulators as manip_26 } from './apps/cursor'
import { description as desc_27, manipulators as manip_27 } from './apps/xcode'
import { description as desc_28, manipulators as manip_28 } from './apps/codex'
import { description as desc_29, manipulators as manip_29 } from './apps/pathfinder'
import { description as desc_30, manipulators as manip_30 } from './apps/gemini-chrome'
import { description as desc_31, manipulators as manip_31 } from './apps/google-chrome'
import { description as desc_32, manipulators as manip_32 } from './apps/notion'

// Leader Key Global/Fallback
import { description as desc_33, manipulators as manip_33 } from './leaderkey/global-mode'
import { description as desc_34, manipulators as manip_34 } from './leaderkey/fallback-mode'

// Device Rules
import { description as desc_35, manipulators as manip_35 } from './device-rules/global-all-keyboards'
import { description as desc_36, manipulators as manip_36 } from './device-rules/apple'
import { description as desc_37, manipulators as manip_37 } from './device-rules/kinesis'
import { description as desc_38, manipulators as manip_38 } from './device-rules/kinesis-layer-mouse'
import { description as desc_39, manipulators as manip_39 } from './device-rules/kinesis-layer'
import { description as desc_40, manipulators as manip_40 } from './device-rules/global-kinesis-shortcuts'
import { description as desc_41, manipulators as manip_41 } from './device-rules/global-apple-shortcuts'
import { description as desc_42, manipulators as manip_42 } from './device-rules/terminal-rcmd'

// Misc
import { description as desc_43, manipulators as manip_43 } from './test-rule'

// Device Rules
import { description as desc_44, manipulators as manip_44 } from './device-rules/kinesis-modifiers'

// App-Specific Keyboard Rules
import { description as desc_45, manipulators as manip_45 } from './app-rules/warp-kinesis'

// Device Rules
import { description as desc_46, manipulators as manip_46 } from './device-rules/appswitcher-kinesis'

// Modes
import { description as desc_47, manipulators as manip_47 } from './modes/quote-mode'
import { description as desc_48, manipulators as manip_48 } from './modes/tab-mode'
import { description as desc_49, manipulators as manip_49 } from './modes/slash-mode'
import { description as desc_50, manipulators as manip_50 } from './modes/tilde-mode'
import { description as desc_51, manipulators as manip_51 } from './modes/o-mode'
import { description as desc_52, manipulators as manip_52 } from './modes/spacebar-mode'
import { description as desc_53, manipulators as manip_53 } from './modes/d-mode'
import { description as desc_54, manipulators as manip_54 } from './modes/f-mode'
import { description as desc_55, manipulators as manip_55 } from './modes/a-mode'

// App-Specific Keyboard Rules (cont)
import { description as desc_56, manipulators as manip_56 } from './app-rules/warp-apple'
import { description as desc_57, manipulators as manip_57 } from './app-rules/chrome-kinesis'
import { description as desc_58, manipulators as manip_58 } from './app-rules/arc-apple'
import { description as desc_59, manipulators as manip_59 } from './app-rules/arc-kinesis'
import { description as desc_60, manipulators as manip_60 } from './app-rules/dia-kinesis'
import { description as desc_61, manipulators as manip_61 } from './app-rules/zen-kinesis'
import { description as desc_62, manipulators as manip_62 } from './app-rules/intellij-kinesis'

// Modes (cont)
import { description as desc_63, manipulators as manip_63 } from './modes/escape-mode'
import { description as desc_64, manipulators as manip_64 } from './modes/backslash-mode'
import { description as desc_65, manipulators as manip_65 } from './modes/tilde-mode-kinesis'
import { description as desc_66, manipulators as manip_66 } from './modes/kinesis-amps-mode'

// App-Specific Global Rules
import { description as desc_67, manipulators as manip_67 } from './app-rules/chrome'
import { description as desc_68, manipulators as manip_68 } from './app-rules/safari'
import { description as desc_69, manipulators as manip_69 } from './app-rules/emacs'
import { description as desc_70, manipulators as manip_70 } from './app-rules/codecursor'
import { description as desc_71, manipulators as manip_71 } from './app-rules/code'
import { description as desc_72, manipulators as manip_72 } from './app-rules/jsim'

// Leader Key Ending
import { description as desc_73, manipulators as manip_73 } from './leaderkey/leader-local-to-apps'

// Device Rules (ending)
import { description as desc_74, manipulators as manip_74 } from './device-rules/global-kinesis-end'
import { description as desc_75, manipulators as manip_75 } from './device-rules/global-end-apple'

export const allRules: Rule[] = [
  { description: desc_00, manipulators: manip_00 },
  { description: desc_01, manipulators: manip_01 },
  { description: desc_02, manipulators: manip_02 },
  { description: desc_03, manipulators: manip_03 },
  { description: desc_04, manipulators: manip_04 },
  { description: desc_05, manipulators: manip_05 },
  { description: desc_06, manipulators: manip_06 },
  { description: desc_07, manipulators: manip_07 },
  { description: desc_08, manipulators: manip_08 },
  { description: desc_09, manipulators: manip_09 },
  { description: desc_10, manipulators: manip_10 },
  { description: desc_11, manipulators: manip_11 },
  { description: desc_12, manipulators: manip_12 },
  { description: desc_13, manipulators: manip_13 },
  { description: desc_14, manipulators: manip_14 },
  { description: desc_15, manipulators: manip_15 },
  { description: desc_16, manipulators: manip_16 },
  { description: desc_17, manipulators: manip_17 },
  { description: desc_18, manipulators: manip_18 },
  { description: desc_19, manipulators: manip_19 },
  { description: desc_20, manipulators: manip_20 },
  { description: desc_21, manipulators: manip_21 },
  { description: desc_22, manipulators: manip_22 },
  { description: desc_23, manipulators: manip_23 },
  { description: desc_24, manipulators: manip_24 },
  { description: desc_25, manipulators: manip_25 },
  { description: desc_26, manipulators: manip_26 },
  { description: desc_27, manipulators: manip_27 },
  { description: desc_28, manipulators: manip_28 },
  { description: desc_29, manipulators: manip_29 },
  { description: desc_30, manipulators: manip_30 },
  { description: desc_31, manipulators: manip_31 },
  { description: desc_32, manipulators: manip_32 },
  { description: desc_33, manipulators: manip_33 },
  { description: desc_34, manipulators: manip_34 },
  { description: desc_35, manipulators: manip_35 },
  { description: desc_36, manipulators: manip_36 },
  { description: desc_37, manipulators: manip_37 },
  { description: desc_38, manipulators: manip_38 },
  { description: desc_39, manipulators: manip_39 },
  { description: desc_40, manipulators: manip_40 },
  { description: desc_41, manipulators: manip_41 },
  { description: desc_42, manipulators: manip_42 },
  { description: desc_43, manipulators: manip_43 },
  { description: desc_44, manipulators: manip_44 },
  { description: desc_45, manipulators: manip_45 },
  { description: desc_46, manipulators: manip_46 },
  { description: desc_47, manipulators: manip_47 },
  { description: desc_48, manipulators: manip_48 },
  { description: desc_49, manipulators: manip_49 },
  { description: desc_50, manipulators: manip_50 },
  { description: desc_51, manipulators: manip_51 },
  { description: desc_52, manipulators: manip_52 },
  { description: desc_53, manipulators: manip_53 },
  { description: desc_54, manipulators: manip_54 },
  { description: desc_55, manipulators: manip_55 },
  { description: desc_56, manipulators: manip_56 },
  { description: desc_57, manipulators: manip_57 },
  { description: desc_58, manipulators: manip_58 },
  { description: desc_59, manipulators: manip_59 },
  { description: desc_60, manipulators: manip_60 },
  { description: desc_61, manipulators: manip_61 },
  { description: desc_62, manipulators: manip_62 },
  { description: desc_63, manipulators: manip_63 },
  { description: desc_64, manipulators: manip_64 },
  { description: desc_65, manipulators: manip_65 },
  { description: desc_66, manipulators: manip_66 },
  { description: desc_67, manipulators: manip_67 },
  { description: desc_68, manipulators: manip_68 },
  { description: desc_69, manipulators: manip_69 },
  { description: desc_70, manipulators: manip_70 },
  { description: desc_71, manipulators: manip_71 },
  { description: desc_72, manipulators: manip_72 },
  { description: desc_73, manipulators: manip_73 },
  { description: desc_74, manipulators: manip_74 },
  { description: desc_75, manipulators: manip_75 },
]

export const profileParameters = {
  "basic.simultaneous_threshold_milliseconds": 100,
  "basic.to_delayed_action_delay_milliseconds": 0,
  "basic.to_if_alone_timeout_milliseconds": 260,
  "basic.to_if_held_down_threshold_milliseconds": 50
}
