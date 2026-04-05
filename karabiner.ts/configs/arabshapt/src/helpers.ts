import { to$ } from '../../../src/config/to.ts'

// Shell command helpers — correspond to Goku :templates section

export const openApp = (appPath: string) => to$(`open -a '${appPath}'`)
export const openUrl = (url: string) => to$(`open "${url}"`)
export const openUrlBg = (url: string) => to$(`open -g "${url}"`)
export const launch = (app: string) =>
  to$(`osascript -e 'tell application "${app}" to activate'`)

export const km = (macro: string) =>
  to$(
    `osascript -e 'tell application "Keyboard Maestro Engine" to do script "${macro}"'`,
  )

export const alfred = (trigger: string, workflow: string, arg = '') =>
  to$(
    `osascript -e 'tell application "Alfred 5" to run trigger "${trigger}" in workflow "${workflow}" with argument "${arg}"'`,
  )

export const shell = (cmd: string) => to$(cmd)

export const kit = (script: string) => to$(`~/.kit/kar "${script}"`)
export const focus = (app: string) => to$(`~/.kit/kar focus "${app}"`)
export const paste = (input: string) => to$(`~/.simple/bin/paste-input ${input}`)
