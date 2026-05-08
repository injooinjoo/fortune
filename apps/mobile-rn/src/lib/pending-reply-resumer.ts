/**
 * pending-reply-resumer — 콜드스타트/포그라운드 복귀 시점에 미응답 답장 재개.
 *
 * 문제 시나리오:
 *   1. 유저가 메시지 send → enqueue_pending_reply_job 으로 row INSERT (pending)
 *   2. chat-screen 이 character-chat Edge Function 을 fire-and-forget invoke
 *   3. 응답 도착 전에 유저가 앱 종료 (force-kill / 시스템 OOM)
 *   4. 다음 cold-start 또는 background→foreground 복귀
 *
 * 기존 동작:
 *   - process-pending-reply-jobs cron 이 30s grace + 1m polling 으로 픽업
 *   - 그래서 최악 1분 30초 + LLM latency = 사용자 인지 지연 ~2분
 *   - 게다가 채팅창에 들어가야 typing indicator 와 응답이 보이는 구조 (chat-screen
 *     로컬 state 의존) 로, "껐다 켰을 때 채팅창 열어야 답변이 도착하는 것처럼 보임"
 *
 * 해결:
 *   - 부트스트랩 / AppState active / 인증 변경 시점에 즉시 클라가 query →
 *     pending row 발견 시 character-chat 직접 invoke (jobId 동봉)
 *   - 서버 claim_pending_reply_job_by_id 가 atomic pending→processing UPDATE
 *     이라 cron 과 race 해도 한쪽만 LLM 호출 (다른쪽은 noop 응답)
 *   - 채팅창 진입 여부와 무관하게 응답 도착 — 서버가 character_conversations
 *     에 INSERT + push 발송 하므로 push 핸들러가 SQLite/MessageStore 에 반영
 *
 * 비-목표:
 *   - typing indicator 글로벌화 (chat-screen 3700줄 침습 큼) — 후속 작업
 *   - 클라가 자체적으로 LLM stream 받아서 typing 시각화 — 서버 단일 진입점 유지
 */

import { supabase } from './supabase';
import { captureError } from './error-reporting';
import { setTyping as setGlobalTyping } from './typing-store';

interface PendingReplyJobRow {
  id: string;
  user_id: string;
  character_id: string;
  character_name: string;
  user_message_id: string;
  user_message: string;
  request_payload: Record<string, unknown> | null;
  status: string;
  created_at: string;
}

// 동일 jobId 를 같은 세션 내 두 번 invoke 하지 않도록 in-flight set 추적.
// AppState change 가 빠르게 토글되어도 (active → inactive → active) 중복 호출 방지.
const inFlightJobIds = new Set<string>();
// invoke 결과 (성공/실패) 가 도착하면 timer 안 기다리고 즉시 해제. 그래야
// LLM 실패 직후 사용자가 다시 send 했을 때 같은 jobId 재시도가 가능.
const inFlightTimers = new Map<string, ReturnType<typeof setTimeout>>();
// safety net: 응답이 영영 안 와도 (네트워크 영구 끊김) 90초 뒤엔 풀어준다.
// Edge 함수 max timeout 60s + 여유 30s. 30s 는 LLM cold start 1회분도 못 버텨서 모자랐음.
const IN_FLIGHT_SAFETY_TIMEOUT_MS = 90_000;

function clearInFlight(jobId: string): void {
  inFlightJobIds.delete(jobId);
  const timer = inFlightTimers.get(jobId);
  if (timer) {
    clearTimeout(timer);
    inFlightTimers.delete(jobId);
  }
}

/**
 * 현재 로그인 사용자의 pending 잡을 모두 가져와 character-chat 직접 invoke.
 *
 * fire-and-forget 으로 호출하면 안전 — 실패해도 서버 cron 이 backup 으로 픽업.
 * 한 번에 모두 발사 (직렬화 X) — 보통 0~3개 라 부하 무시 가능.
 *
 * @returns 시도한 job id 배열. 디버깅/테스트용.
 */
export async function resumePendingReplies(): Promise<string[]> {
  if (!supabase) return [];

  const { data: sessionData } = await supabase.auth.getSession();
  const userId = sessionData.session?.user?.id;
  if (!userId) return [];

  // RLS: SELECT 정책으로 자기 row 만 조회 가능. status='pending' 만.
  const { data: jobs, error } = await supabase
    .from('pending_character_reply_jobs')
    .select(
      'id, user_id, character_id, character_name, user_message_id, user_message, request_payload, status, created_at',
    )
    .eq('user_id', userId)
    .eq('status', 'pending')
    .order('created_at', { ascending: true });

  if (error) {
    console.warn('[pending-resumer] 조회 실패:', error.message);
    return [];
  }
  if (!jobs || jobs.length === 0) return [];

  const attempted: string[] = [];
  for (const job of jobs as PendingReplyJobRow[]) {
    if (inFlightJobIds.has(job.id)) continue;
    inFlightJobIds.add(job.id);
    attempted.push(job.id);

    // request_payload 는 enqueue 시 클라가 저장한 character-chat body 그대로.
    // 거기에 jobId 를 동봉해 서버가 claim_pending_reply_job_by_id 로 atomic
    // 클레임하게 한다. (이미 다른 워커/cron 이 가져갔으면 noop 응답)
    const payload = {
      ...((job.request_payload as Record<string, unknown> | null) ?? {}),
      jobId: job.id,
    };

    // 90초 safety net — 응답이 영영 안 와도 풀어준다.
    const safetyTimer = setTimeout(() => {
      clearInFlight(job.id);
      setGlobalTyping(job.character_id, false);
    }, IN_FLIGHT_SAFETY_TIMEOUT_MS);
    inFlightTimers.set(job.id, safetyTimer);

    // 채팅 리스트 row 가 즉시 "입력 중…" 표시. invoke 결과 도착 시 unset.
    setGlobalTyping(job.character_id, true);

    void supabase.functions
      .invoke('character-chat', { body: payload })
      .then(({ error: invokeError }) => {
        if (invokeError) {
          console.warn(
            '[pending-resumer] character-chat invoke 실패:',
            job.id,
            invokeError.message ?? invokeError,
          );
        }
      })
      .catch((err) => {
        captureError(err, {
          surface: 'pending-resumer:invoke',
        }).catch(() => undefined);
      })
      .finally(() => {
        // 정상 응답 도착 시 즉시 해제 — 다음 resume 호출이 같은 id 를 재시도
        // 가능 (LLM 실패 후 유저가 재 send 한 케이스). 서버는 status 전이가
        // atomic 이라 이미 done/failed 면 noop.
        clearInFlight(job.id);
        setGlobalTyping(job.character_id, false);
      });
  }

  if (attempted.length > 0 && __DEV__) {
    console.log(
      `[pending-resumer] ${attempted.length} 개 pending reply 재개 시도`,
    );
  }
  return attempted;
}
