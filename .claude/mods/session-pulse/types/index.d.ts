export type StageId =
  | 'session-start'
  | 'test'
  | 'local-ci'
  | 'push'
  | 'pr'
  | 'merge'
  | 'attest'
  | 'ios'
  | 'deploy'
  | 'session-close'

export type StageStatus = 'running' | 'ok' | 'fail' | 'blocked'

export type Stage = {
  id: StageId
  status: StageStatus
  startedAt: number
  endedAt?: number
  runs: number
  note?: string
}

export type TurnInfo = {
  isWorking: boolean
  startedAt?: number
  lastDurationMs?: number
  lastEndedAt?: number
}

declare module 'claude-code' {
  interface PluginState {
    'session-pulse': {
      stages: Stage[]
      pr: number | null
      turn: TurnInfo
      isHidden: boolean
    }
  }
}
