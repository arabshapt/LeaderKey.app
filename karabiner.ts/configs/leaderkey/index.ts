// Created once by Leader Key. You can import this path from your own karabiner.ts config.
// This file is not overwritten after creation.
import type { Rule } from '../../src/karabiner/karabiner-config.ts'
import leaderKeyRules from './leaderkey-generated.json'

export const leaderKeyDefaultProfileName = "Default"
export const leaderKeyManagedRules = leaderKeyRules as Rule[]
export default leaderKeyManagedRules