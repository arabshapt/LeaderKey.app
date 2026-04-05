/**
 * Extract rules from the arabshapt default-profile snapshot into individual files.
 *
 * Usage: node scripts/extract-arabshapt-rules.mjs
 *
 * Reads the Goku-generated snapshot JSON, splits it into one TypeScript file
 * per rule in configs/arabshapt/src/rules/. Each file exports a Rule object
 * with description and raw manipulator array.
 */
import { mkdirSync, writeFileSync } from 'node:fs'
import path from 'node:path'

const repoRoot = process.cwd()

// Read the snapshot by evaluating the TypeScript file
// The snapshot stores JSON in a String.raw template - we need to extract it
import { readFileSync } from 'node:fs'

const snapshotPath = path.join(
  repoRoot,
  'configs',
  'arabshapt',
  'default-profile.ts',
)
const snapshotSource = readFileSync(snapshotPath, 'utf8')

// Extract the JSON by finding String.raw`{...}` boundaries
const startMarker = 'String.raw`{'
const startIdx = snapshotSource.indexOf(startMarker)
if (startIdx === -1) {
  throw new Error('Could not find String.raw template start in snapshot')
}
const jsonStart = startIdx + 'String.raw`'.length
const endMarker = '}`,'
const endIdx = snapshotSource.lastIndexOf(endMarker)
if (endIdx === -1) {
  throw new Error('Could not find String.raw template end in snapshot')
}
const rawJson = snapshotSource.substring(jsonStart, endIdx + 1)
const complexModifications = JSON.parse(rawJson)

const rules = complexModifications.rules
const parameters = complexModifications.parameters

console.log(`Found ${rules.length} rules`)
console.log(
  `Parameters: ${JSON.stringify(parameters, null, 2)}`,
)

// Create output directory
const rulesDir = path.join(repoRoot, 'configs', 'arabshapt', 'src', 'rules')
mkdirSync(rulesDir, { recursive: true })

// Categorize rules for better file naming
function slugify(description) {
  return description
    .toLowerCase()
    .replace(/^leader key - /, 'lk-')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

// Generate one file per rule
const ruleIndex = []

for (let i = 0; i < rules.length; i++) {
  const rule = rules[i]
  const desc = rule.description || `rule-${i}`
  const slug = slugify(desc)
  const filename = `${String(i).padStart(2, '0')}-${slug}.ts`
  const manipulatorCount = (rule.manipulators || []).length

  console.log(
    `  [${String(i).padStart(2, '0')}] ${desc} (${manipulatorCount} manipulators) -> ${filename}`,
  )

  const jsonStr = JSON.stringify(rule.manipulators || [], null, 2)
    .replace(/`/g, '\\`')
    .replace(/\$\{/g, '\\${')

  // Use JSON.parse with String.raw for the manipulators (avoids TS type issues with deep objects)
  const source = `import type { Manipulator } from '../../../../src/karabiner/karabiner-config.ts'

// Rule ${i}: "${desc}"
// ${manipulatorCount} manipulators
export const description = ${JSON.stringify(desc)}

export const manipulators: Manipulator[] = JSON.parse(String.raw\`${jsonStr}\`)
`

  writeFileSync(path.join(rulesDir, filename), source)
  ruleIndex.push({ index: i, description: desc, filename, manipulatorCount })
}

// Write the rule index file
const indexLines = [
  `// Auto-generated rule index. ${rules.length} rules from Goku snapshot.`,
  `// Re-run 'node scripts/extract-arabshapt-rules.mjs' to regenerate.`,
  '',
  `import type { Rule } from '../../../src/karabiner/karabiner-config.ts'`,
  '',
]

for (const r of ruleIndex) {
  const importName = `rule_${String(r.index).padStart(2, '0')}`
  indexLines.push(
    `import { description as desc_${String(r.index).padStart(2, '0')}, manipulators as manip_${String(r.index).padStart(2, '0')} } from './rules/${r.filename.replace('.ts', '')}'`,
  )
}

indexLines.push('')
indexLines.push('export const allRules: Rule[] = [')
for (const r of ruleIndex) {
  const idx = String(r.index).padStart(2, '0')
  indexLines.push(
    `  { description: desc_${idx}, manipulators: manip_${idx} },`,
  )
}
indexLines.push(']')
indexLines.push('')

// Also export the parameters
indexLines.push(
  `export const profileParameters = ${JSON.stringify(parameters, null, 2)}`,
)
indexLines.push('')

const srcDir = path.join(repoRoot, 'configs', 'arabshapt', 'src')
mkdirSync(srcDir, { recursive: true })
writeFileSync(path.join(srcDir, 'index.ts'), indexLines.join('\n'))

// Print summary
console.log(`\n--- Summary ---`)
console.log(`Total rules: ${rules.length}`)
console.log(
  `Total manipulators: ${rules.reduce((s, r) => s + (r.manipulators || []).length, 0)}`,
)
console.log(`Output: ${rulesDir}/`)
console.log(`Index: ${srcDir}/index.ts`)
