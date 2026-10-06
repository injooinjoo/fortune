import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Stage, TurnInfo } from '../types'
import {
  blockedLine,
  classify,
  endStage,
  isProgressQuestion,
  lastErrorLine,
  parseSwitch,
  prNumber,
  startStage,
  summarize,
} from './pulse'

const stages = atom({ plugin: 'session-pulse', key: 'stages' } as const, [] as Stage[])
const pr = atom({ plugin: 'session-pulse', key: 'pr' } as const, null as number | null)
const turn = atom({ plugin: 'session-pulse', key: 'turn' } as const, { isWorking: false } as TurnInfo)
const isHidden = atom({ plugin: 'session-pulse', key: 'isHidden' } as const, false)

const HUMAN_ORIGINS = new Set(['composer', 'bridge', 'sdk'])

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'pulse',
      description: '이 세션의 진행 단계 요약 (pulse hide | show | reset)',
      argumentHint: '[hide|show|reset]',
      immediate: true,
    })
    // Elapsed times in the band go stale while a step runs; redraw twice a minute.
    $.clock.every(30_000, () => $.ui.invalidate('ui.render'))

    return next(e)
  })

  on('command.run', { command: 'pulse' }, async ($, e) => {
    const arg = e.args.trim()
    if (arg === 'hide' || arg === 'show') {
      await update($, isHidden, () => arg === 'hide')
      return { text: arg === 'hide' ? '진행 띠를 숨겼습니다.' : '진행 띠를 다시 표시합니다.' }
    }
    if (arg === 'reset') {
      await update($, stages, () => [])
      await update($, pr, () => null)
      return { text: '진행 기록을 비웠습니다.' }
    }
    const now = await $.clock.now()
    const lines = summarize(
      { stages: await read($, stages), pr: await read($, pr), turn: await read($, turn) },
      now,
    )
    return { text: lines.join('\n') }
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const id = classify(e.command)
    if (id === undefined) return next(e)

    const startedAt = await $.clock.now()
    await update($, stages, list => startStage(list, id, startedAt))
    const ran = await next(e)
    const now = await $.clock.now()

    if (ran.deny !== undefined) {
      await update($, stages, list => endStage(list, id, now, { status: 'fail', note: `거부됨: ${ran.deny.slice(0, 100)}` }))
      return ran
    }
    if (e.run_in_background === true) {
      // The command keeps running after this call returns; leave the stage open.
      return ran
    }

    const text = ran.text ?? ''
    const blocked = blockedLine(text)
    const outcome = ran.isError === true
      ? { status: 'fail' as const, note: lastErrorLine(text) }
      : blocked !== undefined
        ? { status: 'blocked' as const, note: blocked }
        : { status: 'ok' as const }
    await update($, stages, list => endStage(list, id, now, outcome))

    const found = prNumber(text) ?? prNumber(e.command)
    if (found !== undefined && (id === 'pr' || id === 'merge' || id === 'push')) {
      await update($, pr, () => found)
    }

    return ran
  })

  on('turn.start', async ($, e, next) => {
    const now = await $.clock.now()
    await update($, turn, old => ({ ...old, isWorking: true, startedAt: now }))
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined) {
      const now = await $.clock.now()
      await update($, turn, old => ({
        isWorking: false,
        startedAt: old.startedAt,
        lastDurationMs: e.durationMs,
        lastEndedAt: now,
      }))
    }
    return next(e)
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.origin !== undefined && !HUMAN_ORIGINS.has(e.origin.kind)) return next(e)

    const wanted = parseSwitch(e.text)
    if (wanted !== undefined) {
      const said = [wanted.model, wanted.effort].filter(Boolean).join(' · ')
      // Both commands and the follow-up prompt queue behind each other once the session is idle.
      $.clock.after(0, async () => {
        if (wanted.model !== undefined) await $.command.run({ command: 'model', args: wanted.model })
        if (wanted.effort !== undefined) await $.command.run({ command: 'effort', args: wanted.effort })
        await $.prompt.submit({ text: '이어서 진행해', asUser: true })
      })
      return { drop: `session-pulse: ${said}(으)로 전환한 뒤 "이어서 진행해"를 보냅니다.` }
    }

    if (isProgressQuestion(e.text)) {
      const now = await $.clock.now()
      const lines = summarize(
        { stages: await read($, stages), pr: await read($, pr), turn: await read($, turn) },
        now,
      )
      $.ui.toast(lines.join(' | '), { timeoutMs: 8000 })
      const note = [
        '[session-pulse] 이 세션에서 실제로 실행된 단계 기록입니다 (Bash 명령 기준, ✓ 성공 ✗ 실패 ⏸ 잠금/대기 … 실행 중):',
        ...lines,
        '남은 단계가 있으면 "완료"라고 하지 말고 무엇이 남았는지, 무엇을 기다리는지 구체적으로 답하세요.',
      ].join('\n')
      return next({ ...e, context: [...(e.context ?? []), note] })
    }

    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey || (await read($, isHidden))) return next(e)

    const list = await read($, stages)
    if (list.length === 0) return next(e)

    const now = await $.clock.now()
    const lines = summarize({ stages: list, pr: await read($, pr), turn: await read($, turn) }, now)
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column">
        {lines.slice(0, Math.max(1, e.props.maxRows - 1)).map((line, index) => (
          <Text key={`l${index}`} dimColor={index > 0} wrap="truncate-end">
            {line}
          </Text>
        ))}
      </Box>
    )
  })
}
