import { createHash } from 'node:crypto'

import { describe, expect, test } from 'vitest'

import {
  defaultComplexModifications,
  defaultComplexModificationsSha256,
} from '../default-profile'

import { allRules, profileParameters } from './index'

function canonicalize(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(canonicalize)
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, canonicalize((value as Record<string, unknown>)[key])]),
    )
  }

  return value
}

describe('modular arabshapt config parity', () => {
  test('has same number of rules as snapshot', () => {
    expect(allRules.length).toBe(defaultComplexModifications.rules.length)
  })

  test('rule descriptions match snapshot in order', () => {
    const modularDescs = allRules.map((r) => r.description)
    const snapshotDescs = defaultComplexModifications.rules.map(
      (r) => r.description,
    )
    expect(modularDescs).toEqual(snapshotDescs)
  })

  test('parameters match snapshot', () => {
    expect(profileParameters).toEqual(defaultComplexModifications.parameters)
  })

  test('each rule has same manipulator count as snapshot', () => {
    for (let i = 0; i < allRules.length; i++) {
      const modular = allRules[i]
      const snapshot = defaultComplexModifications.rules[i]
      expect(
        modular.manipulators.length,
        `Rule ${i} "${modular.description}": expected ${snapshot.manipulators.length} manipulators, got ${modular.manipulators.length}`,
      ).toBe(snapshot.manipulators.length)
    }
  })

  test('full SHA-256 hash matches snapshot', () => {
    const modularOutput = {
      parameters: profileParameters,
      rules: allRules,
    }

    const modularHash = createHash('sha256')
      .update(JSON.stringify(canonicalize(modularOutput)))
      .digest('hex')

    const snapshotHash = createHash('sha256')
      .update(JSON.stringify(canonicalize(defaultComplexModifications)))
      .digest('hex')

    expect(modularHash).toBe(snapshotHash)
    expect(modularHash).toBe(defaultComplexModificationsSha256)
  })

  test('per-rule parity: each rule matches snapshot exactly', () => {
    const mismatches: string[] = []

    for (let i = 0; i < allRules.length; i++) {
      const modularRule = canonicalize(allRules[i])
      const snapshotRule = canonicalize(defaultComplexModifications.rules[i])

      const modularJson = JSON.stringify(modularRule)
      const snapshotJson = JSON.stringify(snapshotRule)

      if (modularJson !== snapshotJson) {
        mismatches.push(
          `Rule ${i} "${allRules[i].description}" differs`,
        )
      }
    }

    expect(mismatches).toEqual([])
  })

  test('preserves send_user_command payload shapes', () => {
    const counts = {
      string: 0,
      object: 0,
      types: {} as Record<string, number>,
    }

    for (const rule of allRules) {
      for (const manipulator of rule.manipulators || []) {
        if (manipulator.type !== 'basic') continue
        for (const bucket of [
          'to',
          'to_if_alone',
          'to_if_held_down',
          'to_after_key_up',
        ] as const) {
          for (const event of manipulator[bucket] || []) {
            if (!('send_user_command' in event)) continue
            const payload = event.send_user_command.payload

            if (typeof payload === 'string') {
              counts.string += 1
              continue
            }

            counts.object += 1
            if (payload && typeof payload === 'object' && 'type' in payload) {
              const type = payload.type
              if (typeof type === 'string') {
                counts.types[type] = (counts.types[type] || 0) + 1
              }
            }
          }
        }
      }
    }

    // Count from snapshot for comparison
    const snapshotCounts = {
      string: 0,
      object: 0,
      types: {} as Record<string, number>,
    }

    for (const rule of defaultComplexModifications.rules) {
      for (const manipulator of rule.manipulators || []) {
        if (manipulator.type !== 'basic') continue
        for (const bucket of [
          'to',
          'to_if_alone',
          'to_if_held_down',
          'to_after_key_up',
        ] as const) {
          for (const event of manipulator[bucket] || []) {
            if (!('send_user_command' in event)) continue
            const payload = event.send_user_command.payload

            if (typeof payload === 'string') {
              snapshotCounts.string += 1
              continue
            }

            snapshotCounts.object += 1
            if (payload && typeof payload === 'object' && 'type' in payload) {
              const type = payload.type
              if (typeof type === 'string') {
                snapshotCounts.types[type] =
                  (snapshotCounts.types[type] || 0) + 1
              }
            }
          }
        }
      }
    }

    expect(counts).toEqual(snapshotCounts)
  })
})
