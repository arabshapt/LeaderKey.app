import { createHash } from 'node:crypto'

import { describe, expect, test } from 'vitest'

import {
  defaultComplexModifications,
  defaultComplexModificationsSha256,
  defaultProfileName,
  replaceProfileComplexModifications,
} from './default-profile'

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

describe('arabshapt Default profile migration', () => {
  test('matches the current Goku dry-run output', () => {
    expect(defaultProfileName).toBe("Default")
    expect(defaultComplexModifications.parameters).toEqual({
  "basic.simultaneous_threshold_milliseconds": 100,
  "basic.to_delayed_action_delay_milliseconds": 0,
  "basic.to_if_alone_timeout_milliseconds": 260,
  "basic.to_if_held_down_threshold_milliseconds": 50
})
    expect(defaultComplexModifications.rules).toHaveLength(74)

    const digest = createHash('sha256')
      .update(JSON.stringify(canonicalize(defaultComplexModifications)))
      .digest('hex')

    expect(digest).toBe(defaultComplexModificationsSha256)
    expect(digest).toBe("ab481e7bdd9aaeb3397d2157e78cc649f9ee61922ec154ed0dfd5a7a2546b3b8")
  })

  test('preserves send_user_command payload shapes', () => {
    const counts = {
      string: 0,
      object: 0,
      types: {} as Record<string, number>,
    }

    for (const rule of defaultComplexModifications.rules) {
      for (const manipulator of rule.manipulators || []) {
        if (manipulator.type !== 'basic') continue
        for (const bucket of ['to', 'to_if_alone', 'to_if_held_down', 'to_after_key_up'] as const) {
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

    expect(counts).toEqual({
  "string": 1353,
  "object": 373,
  "types": {
    "open": 229,
    "menu": 7,
    "intellij": 1,
    "open_app": 133,
    "keystroke": 3
  }
})
  })

  test('replaces only the requested profile', () => {
    const original = {
      global: { show_in_menu_bar: true },
      profiles: [
        {
          name: 'Other',
          selected: false,
          complex_modifications: { parameters: {}, rules: [] },
        },
        {
          name: defaultProfileName,
          selected: true,
          complex_modifications: { parameters: {}, rules: [] },
        },
      ],
    }

    const next = replaceProfileComplexModifications(original)

    expect(next).not.toBe(original)
    expect(next.profiles[0]).toBe(original.profiles[0])
    expect(next.profiles[1]).not.toBe(original.profiles[1])
    expect(next.profiles[1].complex_modifications).toBe(defaultComplexModifications)
    expect(original.profiles[1].complex_modifications.rules).toEqual([])
  })
})
