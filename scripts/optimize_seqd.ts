#!/usr/bin/env -S deno run --allow-read --allow-write
/**
 * Post-processor: replaces app-opening shell_commands with seqd socket_command
 * in karabiner.json's Default (goku) profile.
 *
 * Run this AFTER Goku compiles karabiner.json to route app opens through seqd
 * instead of spawning shell processes.
 *
 * Usage:
 *   deno run --allow-read --allow-write scripts/optimize_seqd.ts [--dry-run] [--profile Default]
 */

const KARABINER_JSON = `${Deno.env.get("HOME")}/.config/karabiner/karabiner.json`
const SEQD_SOCK = "/tmp/seqd.sock"

const args = new Set(Deno.args)
const dryRun = args.has("--dry-run")
const profileName = Deno.args.includes("--profile")
  ? Deno.args[Deno.args.indexOf("--profile") + 1]
  : "Default"

/** Extract app name from path: /System/Applications/Utilities/Activity Monitor.app -> Activity Monitor */
function appName(appPath: string): string {
  const basename = appPath.split("/").pop() || appPath
  return basename.replace(/\.app\/?$/, "")
}

function seqOpen(appPath: string): Record<string, unknown> {
  return { socket_command: { endpoint: SEQD_SOCK, command: `OPEN_APP ${appName(appPath)}` } }
}

function seqOpenToggle(appPath: string): Record<string, unknown> {
  return { socket_command: { endpoint: SEQD_SOCK, command: `OPEN_APP_TOGGLE ${appName(appPath)}` } }
}

function transformToEvent(event: Record<string, unknown>): Record<string, unknown>[] {
  if (typeof event !== "object" || event === null) return [event]

  const shell = event.shell_command as string | undefined
  if (!shell) return [event]

  // Pattern: "open '/path/to/App.app'"
  const openMatch = shell.match(/^open\s+'([^']+)'$/)
    || shell.match(/^open\s+"([^"]+)"$/)
    || shell.match(/^open\s+(\S+)$/)

  if (openMatch) {
    const target = openMatch[1]
    if (target.endsWith(".app") || target.endsWith(".app/")) {
      return [seqOpen(target)]
    }
  }

  // Pattern: "open -g '/path/to/App.app'"
  const openBgMatch = shell.match(/^open\s+-g\s+'([^']+)'$/)
    || shell.match(/^open\s+-g\s+"([^"]+)"$/)
    || shell.match(/^open\s+-g\s+(\S+)$/)

  if (openBgMatch) {
    const target = openBgMatch[1]
    if (target.endsWith(".app") || target.endsWith(".app/")) {
      return [seqOpen(target)]
    }
  }

  return [event]
}

function transformList(list: unknown[]): unknown[] {
  const result: unknown[] = []
  for (const item of list) {
    if (typeof item === "object" && item !== null && "shell_command" in (item as Record<string, unknown>)) {
      result.push(...transformToEvent(item as Record<string, unknown>))
    } else {
      result.push(item)
    }
  }
  return result
}

// --- Main ---

console.log(`Reading ${KARABINER_JSON}...`)
const t0 = performance.now()
const raw = await Deno.readTextFile(KARABINER_JSON)
const t1 = performance.now()
console.log(`  Read ${(raw.length / 1e6).toFixed(1)}MB in ${(t1 - t0).toFixed(0)}ms`)

const data = JSON.parse(raw)
const t2 = performance.now()
console.log(`  Parsed in ${(t2 - t1).toFixed(0)}ms`)

const profile = data.profiles?.find((p: { name: string }) => p.name === profileName)
if (!profile) {
  console.error(`Profile "${profileName}" not found`)
  console.log(`Available profiles: ${data.profiles?.map((p: { name: string }) => p.name).join(", ")}`)
  Deno.exit(1)
}

let modified = 0
const rules = profile.complex_modifications?.rules ?? []
console.log(`\n  Profile "${profileName}" has ${rules.length} rules`)

for (const rule of rules) {
  for (const m of rule.manipulators ?? []) {
    for (const field of ["to", "to_if_alone", "to_if_held_down", "to_after_key_up"]) {
      const toList = m[field]
      if (!Array.isArray(toList)) continue

      const newList = transformList(toList)
      if (JSON.stringify(newList) !== JSON.stringify(toList)) {
        m[field] = newList
        modified++
      }
    }

    // Handle to_delayed_action
    const delayed = m.to_delayed_action
    if (delayed) {
      for (const sub of ["invoked", "canceled"]) {
        const subList = delayed[sub]
        if (!Array.isArray(subList)) continue
        const newSub = transformList(subList)
        if (JSON.stringify(newSub) !== JSON.stringify(subList)) {
          delayed[sub] = newSub
          modified++
        }
      }
    }
  }
}

console.log(`\n=== Results ===`)
console.log(`Profile: ${profileName}`)
console.log(`Manipulators modified: ${modified}`)

if (modified === 0) {
  console.log("\nNo app-opening shell_commands found to convert.")
  Deno.exit(0)
}

if (dryRun) {
  console.log(`\n[DRY RUN] Would modify ${modified} manipulators. Run without --dry-run to apply.`)
  Deno.exit(0)
}

// Backup
const backup = KARABINER_JSON + ".bak"
console.log(`\nBacking up to ${backup}`)
await Deno.writeTextFile(backup, raw)

// Write
console.log(`Writing optimized karabiner.json...`)
const t3 = performance.now()
const output = JSON.stringify(data, null, 2)
await Deno.writeTextFile(KARABINER_JSON, output)
const t4 = performance.now()
console.log(`  Written ${(output.length / 1e6).toFixed(1)}MB in ${(t4 - t3).toFixed(0)}ms`)
console.log(`\nDone! ${modified} manipulators converted: shell_command (open) -> socket_command (seqd)`)
console.log(`Total time: ${(t4 - t0).toFixed(0)}ms`)
