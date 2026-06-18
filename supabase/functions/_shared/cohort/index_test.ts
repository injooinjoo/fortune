import { assert, assertEquals, assertNotEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts'
import { extractDailyCohort, generateCohortHash } from './index.ts'

Deno.test('extractDailyCohort includes KST dateKey so daily pool results cannot cross days', async () => {
  const june11 = extractDailyCohort({
    birthDate: '1990-01-01',
    now: new Date('2026-06-11T03:00:00Z'),
  })
  const june18 = extractDailyCohort({
    birthDate: '1990-01-01',
    now: new Date('2026-06-18T03:00:00Z'),
  })

  assertEquals(june11.dateKey, '2026-06-11')
  assertEquals(june18.dateKey, '2026-06-18')
  assertEquals(june11.period, june18.period)
  assertEquals(june11.zodiac, june18.zodiac)
  assertEquals(june11.element, june18.element)

  assertNotEquals(await generateCohortHash(june11), await generateCohortHash(june18))
})

Deno.test('extractDailyCohort dateKey follows Asia/Seoul calendar day', () => {
  const cohort = extractDailyCohort({
    birthDate: '1990-01-01',
    now: new Date('2026-06-17T15:30:00Z'),
  })

  assert(cohort.dateKey === '2026-06-18')
})
