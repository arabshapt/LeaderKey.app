import { toSendUserCommand } from '../../../src/config/to.ts'
import { toSetVar } from '../../../src/config/to.ts'

// Leader Key send_user_command helpers

export const deactivate = toSendUserCommand('deactivate')
export const shake = toSendUserCommand('shake')
export const settingsCmd = toSendUserCommand('settings')

export function activate(bundleId?: string) {
  return toSendUserCommand(bundleId ? `activate ${bundleId}` : 'activate')
}

export function activateFallback() {
  return toSendUserCommand('activate __FALLBACK__')
}

export function stateid(id: number) {
  return toSendUserCommand(`stateid ${id}`)
}

// Reset all leader key variables to their default (inactive) state
export const resetLeaderVars = [
  toSetVar('leaderkey_active', 0),
  toSetVar('leaderkey_global', 0),
  toSetVar('leaderkey_appspecific', 0),
  toSetVar('leaderkey_sticky', 0),
  toSetVar('leader_state', 0),
]
