import { createHash } from 'node:crypto'
import { mkdirSync, writeFileSync } from 'node:fs'
import path from 'node:path'
import { spawnSync } from 'node:child_process'

const repoRoot = process.cwd()
const outputDir = path.join(repoRoot, 'configs', 'arabshapt')
mkdirSync(outputDir, { recursive: true })

const result = spawnSync('goku', ['--dry-run'], {
  cwd: repoRoot,
  env: {
    ...process.env,
    GOKU_EDN_CONFIG_FILE: path.join(process.env.HOME ?? '', '.config', 'karabiner.edn'),
  },
  encoding: 'utf8',
  maxBuffer: 64 * 1024 * 1024,
})

const stdout = result.stdout ?? ''
const stderr = result.stderr?.trim() ?? ''

if (!stdout.trim()) {
  throw new Error(stderr || `goku --dry-run failed with exit code ${result.status}`)
}

const parsedDryRun = JSON.parse(stdout)
const complexModifications =
  parsedDryRun?.complex_modifications ?? parsedDryRun

const profileName = 'Default'

const canonicalize = (value) => {
  if (Array.isArray(value)) {
    return value.map(canonicalize)
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, canonicalize(value[key])]),
    )
  }

  return value
}

const hash = createHash('sha256')
  .update(JSON.stringify(canonicalize(complexModifications)))
  .digest('hex')

const stats = {
  rules: complexModifications.rules.length,
  sendUserCommand: {
    string: 0,
    object: 0,
    types: {},
  },
}

for (const rule of complexModifications.rules) {
  for (const manipulator of rule.manipulators || []) {
    for (const bucket of ['to', 'to_if_alone', 'to_if_held_down', 'to_after_key_up']) {
      for (const event of manipulator[bucket] || []) {
        const payload = event?.send_user_command?.payload
        if (payload === undefined) {
          continue
        }

        if (typeof payload === 'string') {
          stats.sendUserCommand.string += 1
          continue
        }

        stats.sendUserCommand.object += 1
        const type = payload && typeof payload === 'object' ? payload.type : undefined
        if (typeof type === 'string') {
          stats.sendUserCommand.types[type] = (stats.sendUserCommand.types[type] || 0) + 1
        }
      }
    }
  }
}

const rawJson = JSON.stringify(complexModifications, null, 2)
  .replace(/`/g, '\\`')
  .replace(/\$\{/g, '\\${')

const defaultProfileSource = [
  "import type { ComplexModifications } from '../../src/karabiner/karabiner-config.ts'",
  '',
  `export const defaultProfileName = ${JSON.stringify(profileName)}`,
  `export const defaultComplexModificationsSha256 = ${JSON.stringify(hash)}`,
  '',
  'export type KarabinerConfigLike = {',
  '  profiles: Array<{',
  '    name: string',
  '    [key: string]: unknown',
  '  }>',
  '  [key: string]: unknown',
  '}',
  '',
  'export const defaultComplexModifications = JSON.parse(',
  `  String.raw\`${rawJson}\`,`,
  ') as ComplexModifications',
  '',
  'export function replaceProfileComplexModifications<T extends KarabinerConfigLike>(',
  '  config: T,',
  '  profileName = defaultProfileName,',
  '): T {',
  '  let found = false',
  '',
  '  const profiles = config.profiles.map((profile) => {',
  '    if (profile.name !== profileName) {',
  '      return profile',
  '    }',
  '',
  '    found = true',
  '    return {',
  '      ...profile,',
  '      complex_modifications: defaultComplexModifications,',
  '    }',
  '  })',
  '',
  '  if (!found) {',
  '    throw new Error(`Profile ${profileName} not found`)',
  '  }',
  '',
  '  return {',
  '    ...config,',
  '    profiles,',
  '  } as T',
  '}',
  '',
].join('\n')

const testSource = [
  "import { createHash } from 'node:crypto'",
  '',
  "import { describe, expect, test } from 'vitest'",
  '',
  'import {',
  '  defaultComplexModifications,',
  '  defaultComplexModificationsSha256,',
  '  defaultProfileName,',
  '  replaceProfileComplexModifications,',
  "} from './default-profile'",
  '',
  'function canonicalize(value: unknown): unknown {',
  '  if (Array.isArray(value)) {',
  '    return value.map(canonicalize)',
  '  }',
  '',
  "  if (value && typeof value === 'object') {",
  '    return Object.fromEntries(',
  '      Object.keys(value)',
  '        .sort()',
  '        .map((key) => [key, canonicalize((value as Record<string, unknown>)[key])]),',
  '    )',
  '  }',
  '',
  '  return value',
  '}',
  '',
  "describe('arabshapt Default profile migration', () => {",
  "  test('matches the current Goku dry-run output', () => {",
  `    expect(defaultProfileName).toBe(${JSON.stringify(profileName)})`,
  `    expect(defaultComplexModifications.parameters).toEqual(${JSON.stringify(
    complexModifications.parameters,
    null,
    2,
  )})`,
  `    expect(defaultComplexModifications.rules).toHaveLength(${stats.rules})`,
  '',
  "    const digest = createHash('sha256')",
  '      .update(JSON.stringify(canonicalize(defaultComplexModifications)))',
  "      .digest('hex')",
  '',
  '    expect(digest).toBe(defaultComplexModificationsSha256)',
  `    expect(digest).toBe(${JSON.stringify(hash)})`,
  '  })',
  '',
  "  test('preserves send_user_command payload shapes', () => {",
  '    const counts = {',
  '      string: 0,',
  '      object: 0,',
  '      types: {} as Record<string, number>,',
  '    }',
  '',
  '    for (const rule of defaultComplexModifications.rules) {',
  '      for (const manipulator of rule.manipulators || []) {',
  "        if (manipulator.type !== 'basic') continue",
  "        for (const bucket of ['to', 'to_if_alone', 'to_if_held_down', 'to_after_key_up'] as const) {",
  '          for (const event of manipulator[bucket] || []) {',
  "            if (!('send_user_command' in event)) continue",
  '            const payload = event.send_user_command.payload',
  '',
  "            if (typeof payload === 'string') {",
  '              counts.string += 1',
  '              continue',
  '            }',
  '',
  '            counts.object += 1',
  "            if (payload && typeof payload === 'object' && 'type' in payload) {",
  '              const type = payload.type',
  "              if (typeof type === 'string') {",
  '                counts.types[type] = (counts.types[type] || 0) + 1',
  '              }',
  '            }',
  '          }',
  '        }',
  '      }',
  '    }',
  '',
  `    expect(counts).toEqual(${JSON.stringify(stats.sendUserCommand, null, 2)})`,
  '  })',
  '',
  "  test('replaces only the requested profile', () => {",
  '    const original = {',
  '      global: { show_in_menu_bar: true },',
  '      profiles: [',
  '        {',
  "          name: 'Other',",
  '          selected: false,',
  '          complex_modifications: { parameters: {}, rules: [] },',
  '        },',
  '        {',
  '          name: defaultProfileName,',
  '          selected: true,',
  '          complex_modifications: { parameters: {}, rules: [] },',
  '        },',
  '      ],',
  '    }',
  '',
  '    const next = replaceProfileComplexModifications(original)',
  '',
  '    expect(next).not.toBe(original)',
  '    expect(next.profiles[0]).toBe(original.profiles[0])',
  '    expect(next.profiles[1]).not.toBe(original.profiles[1])',
  '    expect(next.profiles[1].complex_modifications).toBe(defaultComplexModifications)',
  '    expect(original.profiles[1].complex_modifications.rules).toEqual([])',
  '  })',
  '})',
  '',
].join('\n')

const applySource = [
  "import { defaultProfileName, replaceProfileComplexModifications } from './default-profile.ts'",
  '',
  'declare const Deno: {',
  '  env: { get(name: string): string | undefined }',
  '  readTextFile(path: string): Promise<string>',
  '  writeTextFile(path: string, data: string): Promise<void>',
  '}',
  '',
  "const home = Deno.env.get('HOME')",
  'if (!home) {',
  "  throw new Error('HOME is not set')",
  '}',
  '',
  'const karabinerJsonPath = `${home}/.config/karabiner/karabiner.json`',
  'const currentConfig = JSON.parse(await Deno.readTextFile(karabinerJsonPath))',
  'const nextConfig = replaceProfileComplexModifications(currentConfig)',
  '',
  'await Deno.writeTextFile(',
  '  karabinerJsonPath,',
  '  `${JSON.stringify(nextConfig, null, 2)}\\n`,',
  ')',
  '',
  'console.log(`Updated ${defaultProfileName} in ${karabinerJsonPath}`)',
  '',
].join('\n')

writeFileSync(path.join(outputDir, 'default-profile.ts'), defaultProfileSource)
writeFileSync(path.join(outputDir, 'default-profile.test.ts'), testSource)
writeFileSync(path.join(outputDir, 'apply-default-profile.ts'), applySource)

console.log(JSON.stringify({ outputDir, hash, stats }, null, 2))
