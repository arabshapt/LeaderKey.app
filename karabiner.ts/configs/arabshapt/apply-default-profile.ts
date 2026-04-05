import { defaultProfileName, replaceProfileComplexModifications } from './default-profile.ts'

declare const Deno: {
  env: { get(name: string): string | undefined }
  readTextFile(path: string): Promise<string>
  writeTextFile(path: string, data: string): Promise<void>
}

const home = Deno.env.get('HOME')
if (!home) {
  throw new Error('HOME is not set')
}

const karabinerJsonPath = `${home}/.config/karabiner/karabiner.json`
const currentConfig = JSON.parse(await Deno.readTextFile(karabinerJsonPath))
const nextConfig = replaceProfileComplexModifications(currentConfig)

await Deno.writeTextFile(
  karabinerJsonPath,
  `${JSON.stringify(nextConfig, null, 2)}\n`,
)

console.log(`Updated ${defaultProfileName} in ${karabinerJsonPath}`)
