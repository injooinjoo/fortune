import type { Stage, StageId, TurnInfo } from '../types'

export const STAGE_LABEL: Record<StageId, string> = {
  'session-start': '세션 시작',
  test: '테스트',
  'local-ci': 'local CI',
  push: 'push',
  pr: 'PR',
  merge: 'merge',
  attest: 'attest/release',
  ios: 'iOS 빌드',
  deploy: '배포',
  'session-close': '세션 종료',
}

// Order matters: the more specific command wins.
const RULES: Array<[RegExp, StageId]> = [
  [/release_governance\.py\s+session-close\b/, 'session-close'],
  [/release_governance\.py\s+session-start\b/, 'session-start'],
  [/release_governance\.py\s+merge-run\b|\bgh\s+pr\s+merge\b/, 'merge'],
  [/release_governance\.py\s+(attest\S*|release-run)\b|ios_release_local\.py/, 'attest'],
  [/\bxcodebuild\b|\bxcrun\s+altool\b|\bdevicectl\b/, 'ios'],
  [/\bsupabase\s+functions\s+deploy\b|\bsupabase\s+db\s+push\b|\bgcloud\s+run\s+deploy\b/, 'deploy'],
  [/\bgh\s+pr\s+create\b/, 'pr'],
  [/\bgit\s+push\b/, 'push'],
  [/\blocal_ci\.py\b/, 'local-ci'],
  [/\bpytest\b|\bnode\s+--test\b|\b(npm|pnpm|yarn)\s+(run\s+)?test\b|\bjest\b|\btsc\b.*--noEmit|\bdeno\s+check\b|\bplaywright\s+test\b/, 'test'],
]

export function classify(command: string): StageId | undefined {
  for (const [pattern, id] of RULES) {
    if (pattern.test(command)) return id
  }
  return undefined
}

const BLOCKED = /\bBLOCKED\b|lock (is )?held|queue (is )?frozen|waiting for (the )?(lock|release|attest)/i

export function blockedLine(text: string): string | undefined {
  const line = text.split('\n').find(one => BLOCKED.test(one))
  return line?.trim().slice(0, 120)
}

export function lastErrorLine(text: string): string | undefined {
  const lines = text.split('\n').map(one => one.trim()).filter(Boolean)
  const hit = [...lines].reverse().find(one => /error|fail|FAIL|✗/.test(one))
  return (hit ?? lines[lines.length - 1])?.slice(0, 120)
}

export function prNumber(text: string): number | undefined {
  const all = [...text.matchAll(/\/pull\/(\d+)/g)]
  const last = all[all.length - 1]
  return last ? Number(last[1]) : undefined
}

export function startStage(stages: Stage[], id: StageId, now: number): Stage[] {
  const old = stages.find(one => one.id === id)
  const next: Stage = { id, status: 'running', startedAt: now, runs: (old?.runs ?? 0) + 1 }
  return old ? stages.map(one => (one.id === id ? next : one)) : [...stages, next]
}

export function endStage(
  stages: Stage[],
  id: StageId,
  now: number,
  outcome: { status: 'ok' | 'fail' | 'blocked'; note?: string },
): Stage[] {
  return stages.map(one =>
    one.id === id && one.status === 'running'
      ? { ...one, status: outcome.status, endedAt: now, note: outcome.note }
      : one,
  )
}

export function minutes(ms: number): string {
  const m = Math.floor(ms / 60000)
  if (m < 1) return `${Math.max(0, Math.round(ms / 1000))}초`
  if (m < 60) return `${m}분`
  return `${Math.floor(m / 60)}시간 ${m % 60}분`
}

const MARK = { running: '…', ok: '✓', fail: '✗', blocked: '⏸' } as const

export function stageText(stage: Stage, now: number): string {
  const label = STAGE_LABEL[stage.id]
  const times = stage.runs > 1 ? ` ×${stage.runs}` : ''
  const time =
    stage.status === 'running' ? ` ${minutes(now - stage.startedAt)}째` : ''
  return `${label}${times} ${MARK[stage.status]}${time}`
}

export type Snapshot = { stages: Stage[]; pr: number | null; turn: TurnInfo }

// One plain-text report: the band, /pulse and the progress-question context all use it.
export function summarize(s: Snapshot, now: number): string[] {
  const lines: string[] = []
  const turn = s.turn.isWorking && s.turn.startedAt !== undefined
    ? `작업 중 ${minutes(now - s.turn.startedAt)}째`
    : s.turn.lastEndedAt !== undefined
      ? `대기 중 (마지막 턴 ${minutes(s.turn.lastDurationMs ?? 0)}, ${minutes(now - s.turn.lastEndedAt)} 전 종료)`
      : '아직 턴 없음'
  lines.push(s.pr === null ? turn : `${turn} · PR #${s.pr}`)
  if (s.stages.length > 0) {
    lines.push(s.stages.map(one => stageText(one, now)).join(' → '))
  }
  for (const one of s.stages) {
    if ((one.status === 'fail' || one.status === 'blocked') && one.note) {
      lines.push(`${STAGE_LABEL[one.id]}: ${one.note}`)
    }
  }
  return lines
}

const PROGRESS_QUESTION =
  /(다\s*한\s*거|다\s*했|진행\s*상황|끝\s*났|끝\s*낫|얼마나\s*남|어디\s*까지|다\s*된\s*거)/

export function isProgressQuestion(text: string): boolean {
  return text.trim().length <= 40 && PROGRESS_QUESTION.test(text)
}

export type Switch = { model?: string; effort?: string }

const MODELS: Array<[RegExp, string]> = [
  [/fable|페이블/i, 'fable'],
  [/opus|오퍼스/i, 'opus'],
  [/sonnet|소넷/i, 'sonnet'],
  [/haiku|하이쿠/i, 'haiku'],
]

// xhigh before high, since "xhigh" contains "high".
const EFFORTS: Array<[RegExp, string]> = [
  [/xhigh|엑스\s*하이|매우\s*높/i, 'xhigh'],
  [/\bmax\b|최대|맥스/i, 'max'],
  [/high|높음|높게|높은/i, 'high'],
  [/medium|중간|보통/i, 'medium'],
  [/\blow\b|낮음|낮게|낮은/i, 'low'],
]

const CONTINUE = /이어서|계속|써요?$|쓰자|로\s*해|로\s*가|진행/

// Only short messages that are nothing but a switch request, e.g.
// "fable 낮음으로 이어서", "Opus5 xhigh로 이어서하자", "오퍼스써".
export function parseSwitch(text: string): Switch | undefined {
  const t = text.trim()
  if (t.length === 0 || t.length > 40 || t.startsWith('/')) return undefined
  if (!CONTINUE.test(t)) return undefined
  const model = MODELS.find(([pattern]) => pattern.test(t))?.[1]
  const effort = EFFORTS.find(([pattern]) => pattern.test(t))?.[1]
  if (model === undefined && effort === undefined) return undefined
  return { model, effort }
}
