import type { ChatShellProgressMessage } from './chat-shell';
import { deleteMessages, updateMessage } from './message-store';
import { captureError } from './error-reporting';
import { supabase } from './supabase';

/**
 * Long-running job (poster-guide / 사주 / 타로 등 30s+ Edge Function) 의
 * 진행상황을 채팅창의 `progress` 카드와 동기화하는 클라이언트-사이드 추적기.
 *
 * 흐름:
 *   1. RN 이 job 큐에 등록 (start-poster-job → jobId 반환).
 *   2. 채팅에 progress 카드 메시지 INSERT.
 *   3. `trackJob(jobId, characterId, messageId)` 등록.
 *   4. Realtime 구독 (use-long-running-jobs-realtime hook) 이 row UPDATE 수신
 *      → `applyJobPhaseUpdate(jobId, phase)` 호출 → progress 카드의 phase 갱신.
 *   5. 완료/실패 시 push 또는 realtime status 변경 → `finalizeJob(jobId, ...)`
 *      → progress 카드 제거 (성공) 또는 error 표시 (실패).
 *
 * 메모리 only — 앱 재시작 시 트래커 비워짐. 재시작 시점에 활성 job 이 있으면
 * 별도 hydration 흐름 (Phase B+ 의 활성 job 쿼리) 으로 progress 카드 재생성.
 */

/** job 의 phase descriptor 매핑 함수. 테이블 종류별로 다른 라벨 사용. */
type PhaseDescriber = (phase: LongRunningJobPhase) => PhaseDescriptor;

interface TrackedJob {
  characterId: string;
  messageId: string;
  describePhase: PhaseDescriber;
}

const trackedJobs = new Map<string, TrackedJob>();

export function trackJob(
  jobId: string,
  characterId: string,
  messageId: string,
  options: { describePhase?: PhaseDescriber } = {},
): void {
  trackedJobs.set(jobId, {
    characterId,
    messageId,
    describePhase: options.describePhase ?? describePosterPhase,
  });
}

export function untrackJob(jobId: string): TrackedJob | null {
  const tracked = trackedJobs.get(jobId);
  if (!tracked) return null;
  trackedJobs.delete(jobId);
  return tracked;
}

export function getTrackedJob(jobId: string): TrackedJob | null {
  return trackedJobs.get(jobId) ?? null;
}

/**
 * scheduled_poster_jobs.phase 와 long_running_jobs.phase 둘 다 커버하는 union.
 * 두 테이블 phase enum 의 합집합 — image-gen (rendering) 과 LLM-text (analyzing)
 * 메인 단계가 다르지만 worker 패턴은 동일.
 */
export type LongRunningJobPhase =
  | 'queued'
  | 'preparing'
  | 'rendering'
  | 'analyzing'
  | 'finalizing'
  | 'completed'
  | 'failed';

/** Image-gen (poster-guide) 진행 도트 라벨 */
export const POSTER_PHASE_STEPS = [
  '준비',
  '분석',
  '마무리',
  '완료',
] as const;

/** LLM-text (tarot/dream/compatibility/saju) 진행 도트 라벨 */
export const LLM_TEXT_PHASE_STEPS = [
  '준비',
  '해석',
  '마무리',
  '완료',
] as const;

interface PhaseDescriptor {
  /** progress 카드 phase 텍스트 */
  label: string;
  /** phaseSteps 도트의 active 인덱스 (0-based). null = 도트 미표시 */
  stepIndex: number | null;
}

export function describePosterPhase(phase: LongRunningJobPhase): PhaseDescriptor {
  switch (phase) {
    case 'queued':
      return { label: '대기 중', stepIndex: 0 };
    case 'preparing':
      return { label: '분석 준비 중', stepIndex: 0 };
    case 'rendering':
      return { label: '결과 이미지 생성 중', stepIndex: 1 };
    case 'analyzing':
      return { label: '결과 이미지 생성 중', stepIndex: 1 };
    case 'finalizing':
      return { label: '마무리 중', stepIndex: 2 };
    case 'completed':
      return { label: '완료', stepIndex: 3 };
    case 'failed':
      return { label: '실패', stepIndex: null };
  }
}

export function describeLlmTextPhase(phase: LongRunningJobPhase): PhaseDescriptor {
  switch (phase) {
    case 'queued':
      return { label: '대기 중', stepIndex: 0 };
    case 'preparing':
      return { label: '준비 중', stepIndex: 0 };
    case 'analyzing':
      return { label: '해석 작성 중', stepIndex: 1 };
    case 'rendering':
      return { label: '해석 작성 중', stepIndex: 1 };
    case 'finalizing':
      return { label: '마무리 중', stepIndex: 2 };
    case 'completed':
      return { label: '완료', stepIndex: 3 };
    case 'failed':
      return { label: '실패', stepIndex: null };
  }
}

/**
 * Realtime/poll 로 받은 phase 갱신을 progress 카드에 in-place 반영.
 * 추적되지 않은 jobId 면 no-op (다른 디바이스 / 만료된 추적).
 */
export function applyJobPhaseUpdate(
  jobId: string,
  phase: LongRunningJobPhase,
): void {
  const tracked = trackedJobs.get(jobId);
  if (!tracked) return;
  const desc = tracked.describePhase(phase);
  updateMessage(tracked.characterId, tracked.messageId, (current) => {
    if (current.kind !== 'progress') return current;
    const next: ChatShellProgressMessage = {
      ...current,
      phase: desc.label,
    };
    if (desc.stepIndex !== null) {
      next.currentStepIndex = desc.stepIndex;
    }
    return next;
  });
}

/**
 * 완료/실패 시 progress 카드 정리.
 *
 * - 성공 (`status='done'`): 결과 카드가 push/hydrate 로 별도 등장하므로 progress
 *   카드는 제거한다. 두 카드가 함께 보이는 어수선함을 방지.
 * - 실패 (`status='failed'`): process-poster-jobs 가 별도 텍스트 메시지로 실패
 *   안내문 ("잠시 후 다시 시도해줘...") 을 INSERT 하므로 progress 카드는 제거.
 *   카드 안에서 또 다른 에러를 보여주면 같은 사고를 두 번 알리는 셈.
 *
 * `outcome.error` 는 디버깅용 (텔레메트리/로그) 으로만 사용.
 */
export function finalizeJob(
  jobId: string,
  outcome: { status: 'done' } | { status: 'failed'; error?: string },
): void {
  const tracked = untrackJob(jobId);
  if (!tracked) return;
  if (outcome.status === 'failed' && outcome.error) {
    console.warn(
      `[long-running-jobs] job=${jobId} failed: ${outcome.error.slice(0, 200)}`,
    );
  }
  deleteMessages(tracked.characterId, [tracked.messageId]);
}

/**
 * Realtime 구독 시작. 현재 user 의 `scheduled_poster_jobs` row 변경을 수신.
 *
 * - INSERT 는 무시 (RN 이 직접 INSERT 한 직후 trackJob 으로 추적 시작).
 * - UPDATE 는 phase / status 변화 → applyJobPhaseUpdate 또는 finalizeJob 호출.
 * - status='done' 인 경우 cron 이 push 로 결과 카드를 별도 발송하므로 여기서는
 *   progress 카드만 제거.
 *
 * 반환된 unsubscribe 를 cleanup 에서 호출. 세션 변경 시 재구독.
 */
/**
 * 두 큐 테이블 (`scheduled_poster_jobs`, `long_running_jobs`) 의 row UPDATE 를
 * 동일 트래커로 라우팅. 같은 row shape (id, phase, status, error_message) 을
 * 갖도록 두 테이블이 의도적으로 정렬돼 있어 하나의 핸들러로 처리 가능.
 */
function handleJobRowUpdate(payload: {
  new: Record<string, unknown> | null;
}): void {
  try {
    const row = payload.new as {
      id?: string;
      phase?: LongRunningJobPhase;
      status?: 'pending' | 'processing' | 'done' | 'failed';
      error_message?: string | null;
    } | null;
    if (!row || typeof row.id !== 'string') return;
    if (row.status === 'done') {
      finalizeJob(row.id, { status: 'done' });
      return;
    }
    if (row.status === 'failed') {
      finalizeJob(row.id, {
        status: 'failed',
        error: row.error_message ?? undefined,
      });
      return;
    }
    if (row.phase) {
      applyJobPhaseUpdate(row.id, row.phase);
    }
  } catch (error) {
    captureError(error, {
      surface: 'long-running-jobs:realtime-handler',
    }).catch(() => undefined);
  }
}

/**
 * 두 큐 테이블의 user-owned row UPDATE 이벤트를 한 번에 구독.
 * 단일 채널에 두 테이블 listener 를 attach — connection / heartbeat 1회만 사용.
 */
export function subscribeToPosterJobs(userId: string): () => void {
  if (!supabase) return () => undefined;
  const client = supabase;
  const channel = client
    .channel(`long-running-jobs:${userId}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'scheduled_poster_jobs',
        filter: `user_id=eq.${userId}`,
      },
      handleJobRowUpdate,
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'long_running_jobs',
        filter: `user_id=eq.${userId}`,
      },
      handleJobRowUpdate,
    )
    .subscribe();

  return () => {
    void client.removeChannel(channel);
  };
}
