import { describe, expect, mock, test } from 'claude-code/testing'

import { classify, isProgressQuestion, parseSwitch } from '../hooks/pulse'

const presentation = { isFullscreen: false, columns: 120 }
const composer = { kind: 'composer' } as const

describe('classify', () => {
  test('maps the sidekick governance commands to stages', () => {
    expect(classify('python3 scripts/release_governance.py session-start --slug x')).toBe('session-start')
    expect(classify('python3 scripts/release_governance.py merge-run --pr 1910')).toBe('merge')
    expect(classify('python3 scripts/release_governance.py attest-main')).toBe('attest')
    expect(classify('python3 scripts/local_ci.py changed')).toBe('local-ci')
    expect(classify('git push -u origin feat/x')).toBe('push')
    expect(classify('gh pr create --fill')).toBe('pr')
    expect(classify('cd apps/mobile-rn && npx tsc --noEmit')).toBe('test')
    expect(classify('supabase functions deploy fortune-daily')).toBe('deploy')
    expect(classify('ls -la')).toBe(undefined)
    expect(classify('gh pr view 1910')).toBe(undefined)
  })
})

describe('parseSwitch', () => {
  test('reads the switch phrases from past sessions', () => {
    expect(parseSwitch('fable 낮음으로 이어서')).toEqual({ model: 'fable', effort: 'low' })
    expect(parseSwitch('Opus5 xhigh로 이어서하자')).toEqual({ model: 'opus', effort: 'xhigh' })
    expect(parseSwitch('이거 opus로 이어서')).toEqual({ model: 'opus', effort: undefined })
    expect(parseSwitch('오퍼스써')).toEqual({ model: 'opus', effort: undefined })
  })

  test('leaves ordinary prompts alone', () => {
    expect(parseSwitch('이어서 진행해')).toBe(undefined)
    expect(parseSwitch('/model opus')).toBe(undefined)
    expect(parseSwitch('opus 모델 가격표를 표로 정리하고 high/low 시나리오별 비용을 계산해서 문서로 만들어줘')).toBe(undefined)
  })
})

describe('isProgressQuestion', () => {
  test('matches the progress questions from past sessions', () => {
    for (const text of ['다한거야?', '여기할거 다한거야?', '진행상황 알려줘', '뭐야그래서 이건끝낫어?', '얼마나남은거야']) {
      expect({ text, hit: isProgressQuestion(text) }).toEqual({ text, hit: true })
    }
    expect(isProgressQuestion('다크모드 색상 고쳐줘')).toBe(false)
  })
})

describe('session-pulse hooks', () => {
  test('records stages and the PR number from Bash calls', async ($, on) => {
    mock.clock(on, { now: 1_000_000 })
    on('tool.call', { tool: 'Bash' }, ($, e) => {
      const text = e.command.startsWith('gh pr create')
        ? 'https://github.com/injooinjoo/sidekick/pull/1910'
        : 'BLOCKED: release lock held by native-ios'
      return { result: { stdout: text, stderr: '', interrupted: false }, text }
    })

    await $.tool.call({ tool: 'Bash', tool_use_id: 't1', command: 'gh pr create --fill' })
    await $.tool.call({ tool: 'Bash', tool_use_id: 't2', command: 'python3 scripts/release_governance.py merge-run --pr 1910' })

    const out = await $.command.run({ command: 'pulse', args: '', origin: composer, presentation })
    expect(out.text).toContain('PR #1910')
    expect(out.text).toContain('PR ✓')
    expect(out.text).toContain('merge ⏸')
    expect(out.text).toContain('release lock held')
  })

  test('a switch phrase is dropped and handled locally', async ($, on) => {
    mock.clock(on)
    const out = await $.prompt.submit({ text: 'fable 낮음으로 이어서', origin: composer, wait: false })
    expect(out.drop).toContain('fable · low')
  })

  test('a progress question carries the stage record as context', async ($, on) => {
    mock.clock(on, { now: 1_000_000 })
    on('prompt.submit', ($, e) => ({ text: e.text, context: e.context }))
    on('tool.call', { tool: 'Bash' }, () => ({
      result: { stdout: 'ok', stderr: '', interrupted: false },
      text: 'ok',
    }))
    await $.tool.call({ tool: 'Bash', tool_use_id: 't3', command: 'python3 scripts/local_ci.py changed' })

    const out = await $.prompt.submit({ text: '다한거야?', origin: composer, wait: false })
    expect(out.text).toBe('다한거야?')
    expect((out.context ?? []).join('\n')).toContain('local CI ✓')
  })
})
