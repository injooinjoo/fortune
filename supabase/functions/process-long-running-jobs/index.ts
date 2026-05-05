/**
 * process-long-running-jobs — long_running_jobs 큐 워커.
 *
 * @description
 *   `long_running_jobs` 의 pending row 1개씩 픽업 → atomic claim → job_type
 *   별 handler dispatch → 결과 카드 INSERT (character_conversations) →
 *   push 발송 → status=done.
 *
 *   scheduled_poster_jobs 의 process-poster-jobs 와 동일 패턴이지만 image-gen
 *   전용이 아닌 LLM-text 운세 (tarot/dream/compatibility/traditional-saju 등) 를
 *   처리한다. job_type 별 dispatcher 로 handler 가 등록 (Phase D 에서 추가).
 *
 * @endpoint POST /process-long-running-jobs (cron 자동 호출)
 *
 * @env SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 */

import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { sendPushToUser } from '../_shared/notification_push.ts';
import {
  JOB_HANDLERS,
  type LongRunningJobRow,
  type LongRunningJobOutcome,
} from './handlers.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceKey);

  // Atomic claim: pending → processing.
  const { data: claimed, error: claimError } = await admin.rpc(
    'claim_next_long_running_job',
  );

  if (claimError) {
    console.error('[process-long-running-jobs] claim RPC failed:', claimError);
    return jsonResponse({ processed: 0, jobId: null, result: 'failed' }, 500);
  }

  const claimedRow = Array.isArray(claimed) ? claimed[0] : claimed;
  if (!claimedRow || !claimedRow.id) {
    return jsonResponse({ processed: 0, jobId: null, result: 'no_pending' }, 200);
  }

  const job = claimedRow as LongRunningJobRow;
  console.log(
    `[process-long-running-jobs] claimed job=${job.id} type=${job.job_type} user=${job.user_id}`,
  );

  const handler = JOB_HANDLERS[job.job_type];
  if (!handler) {
    const msg = `no handler registered for job_type='${job.job_type}'`;
    console.error(`[process-long-running-jobs] job=${job.id} ${msg}`);
    // 사용자 채팅에 실패 안내 — 한 번이라도 INSERT 된 unknown job_type 은 (allowlist
    // 밖 직접 INSERT, 핸들러 정의 누락 등) 사용자 가시 피드백이 있어야 진행카드가
    // realtime status='failed' 로 정리된 뒤에도 그 이유를 알 수 있다.
    await insertFailureMessage(admin, job).catch((e) =>
      console.warn('[process-long-running-jobs] failure message insert error:', e),
    );
    await markJobFailed(admin, job, msg);
    return jsonResponse({ processed: 1, jobId: job.id, result: 'failed' }, 200);
  }

  try {
    // Phase: analyzing — LLM 호출 단계 (대부분의 시간이 여기).
    await updateJobPhase(admin, job.id, 'analyzing');

    const outcome = await handler({
      job,
      admin,
      supabaseUrl,
      serviceKey,
    });

    // Phase: finalizing — 결과 받음, 메시지 INSERT + push 직전.
    await updateJobPhase(admin, job.id, 'finalizing');

    await insertResultCardMessage(admin, job, outcome);
    await sendCompletionPush(admin, job, outcome);

    // 완료
    await admin
      .from('long_running_jobs')
      .update({
        status: 'done',
        phase: 'completed',
        phase_updated_at: new Date().toISOString(),
        result: outcome.result ?? null,
        completed_at: new Date().toISOString(),
      })
      .eq('id', job.id);

    console.log(`[process-long-running-jobs] done job=${job.id}`);
    return jsonResponse({ processed: 1, jobId: job.id, result: 'ok' }, 200);
  } catch (error) {
    const errMsg = error instanceof Error ? error.message : String(error);
    console.error(`[process-long-running-jobs] job=${job.id} failed:`, errMsg);

    await insertFailureMessage(admin, job).catch((e) =>
      console.warn('[process-long-running-jobs] failure message insert error:', e),
    );

    await markJobFailed(admin, job, errMsg);

    return jsonResponse(
      { processed: 1, jobId: job.id, result: 'failed' },
      200, // cron 자체는 성공 — 다음 사이클 호출되어야 함
    );
  }
});

async function markJobFailed(
  admin: SupabaseClient,
  job: LongRunningJobRow,
  errorMessage: string,
): Promise<void> {
  await admin
    .from('long_running_jobs')
    .update({
      status: 'failed',
      phase: 'failed',
      phase_updated_at: new Date().toISOString(),
      error_message: errorMessage.slice(0, 500),
      completed_at: new Date().toISOString(),
    })
    .eq('id', job.id);
}

async function updateJobPhase(
  admin: SupabaseClient,
  jobId: string,
  phase: 'analyzing' | 'finalizing',
): Promise<void> {
  const { error } = await admin
    .from('long_running_jobs')
    .update({ phase, phase_updated_at: new Date().toISOString() })
    .eq('id', jobId);
  if (error) {
    console.warn(
      `[process-long-running-jobs] phase update failed (job=${jobId} phase=${phase}):`,
      error.message,
    );
  }
}

/**
 * 결과 카드 메시지 INSERT — handler 가 반환한 cardPayload 를 영속화 envelope
 * (cardKind + cardPayload) 로 감싸 character_conversations 에 INSERT.
 *
 * 영속화 envelope 가 필요한 이유는 process-poster-jobs 의 동일 함수 주석 참고.
 */
async function insertResultCardMessage(
  admin: SupabaseClient,
  job: LongRunningJobRow,
  outcome: LongRunningJobOutcome,
): Promise<void> {
  const cardPayload = outcome.cardPayload;
  const generatedAt = new Date().toISOString();

  const persisted = {
    id: cardPayload.id,
    type: 'character',
    content: outcome.previewText ?? `[운세 결과 — ${job.job_type}]`,
    timestamp: generatedAt,
    cardKind: cardPayload.kind,
    cardPayload,
  };

  const { error } = await admin.rpc('merge_character_conversation_messages', {
    p_user_id: job.user_id,
    p_character_id: job.character_id,
    p_incoming_messages: [persisted],
    p_runtime_state: null,
    p_max_messages: 200,
  });

  if (error) {
    throw new Error(`merge failed: ${error.message}`);
  }
}

async function insertFailureMessage(
  admin: SupabaseClient,
  job: LongRunningJobRow,
): Promise<void> {
  const message = {
    id: `text-fail-${job.id}`,
    type: 'character',
    content:
      `${jobTypeLabel(job.job_type)} 분석에 실패했어. 잠시 후 다시 시도해줘.`,
    timestamp: new Date().toISOString(),
  };

  const { error } = await admin.rpc('merge_character_conversation_messages', {
    p_user_id: job.user_id,
    p_character_id: job.character_id,
    p_incoming_messages: [message],
    p_runtime_state: null,
    p_max_messages: 200,
  });

  if (error) {
    throw new Error(error.message);
  }
}

async function sendCompletionPush(
  admin: SupabaseClient,
  job: LongRunningJobRow,
  outcome: LongRunningJobOutcome,
): Promise<void> {
  const label = jobTypeLabel(job.job_type);
  const cardPayload = outcome.cardPayload;

  const pushData: Record<string, string> = {
    type: 'long_running_result',
    channel: 'character_dm',
    character_id: job.character_id,
    characterId: job.character_id,
    title: job.character_name,
    body: outcome.pushBody ?? `${label} 분석 결과 도착! 확인해봐 👀`,
    route: `/chat?characterId=${encodeURIComponent(job.character_id)}`,
    message_id: cardPayload.id,
    messageId: cardPayload.id,
    scheduled_id: job.id,
    scheduledId: job.id,
    card_payload_json: JSON.stringify(cardPayload),
  };

  await sendPushToUser(admin, job.user_id, {
    userId: job.user_id,
    title: job.character_name,
    body: pushData.body,
    data: pushData,
  });
}

function jobTypeLabel(jobType: string): string {
  // 한국어 라벨 — handler 가 별도로 라벨 반환 안 한 경우 fallback.
  const labels: Record<string, string> = {
    tarot: '타로',
    dream: '꿈 해몽',
    compatibility: '궁합',
    'traditional-saju': '전통 사주',
  };
  return labels[jobType] ?? jobType;
}

function jsonResponse(data: unknown, status: number) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
