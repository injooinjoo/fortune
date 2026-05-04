/**
 * process-poster-jobs — pending poster-guide job 처리 워커.
 *
 * @description
 *   `scheduled_poster_jobs` 의 pending row 1개씩 픽업 → atomic claim →
 *   기존 `generate-poster-guide` Edge Function 호출 (재구현 X) → 결과
 *   카드 메시지 INSERT (character_conversations) → push 발송 →
 *   job status=done.
 *
 *   pg_cron 또는 외부 cron-job.org 가 매 분 호출. 1회 호출당 1 job 처리
 *   (gpt-image-2 동시 호출 → OpenAI rate limit 회피). 큐가 길면 다음 cron
 *   사이클에서 처리 — 사용자 wait time = ceil(큐 위치 × 1분).
 *
 * @endpoint POST /process-poster-jobs (Authorization: Bearer SUPABASE_SERVICE_ROLE_KEY)
 *
 * @response { processed: number, jobId: string | null, result: 'ok' | 'no_pending' | 'failed' }
 *
 * @env
 *   - SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (필수)
 *   - CRON_SECRET (옵션, 외부 cron-job.org 인증용)
 */

import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { sendPushToUser } from '../_shared/notification_push.ts';
import type { PosterType } from '../_shared/poster_registry.ts';

interface PosterJobRow {
  id: string;
  user_id: string;
  character_id: string;
  character_name: string;
  poster_type: PosterType;
  image_base64: string | null;
  context_text: string | null;
  retry_count: number;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  // 인증: deliver-due-replies 와 동일하게 --no-verify-jwt + 무인증 호출.
  // 함수 자체가 idempotent (atomic claim) 이라 외부 호출되어도 안전.

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(supabaseUrl, serviceKey);

  // Atomic claim: 가장 오래된 pending → processing.
  // FOR UPDATE SKIP LOCKED 으로 동시 cron 인스턴스 race 회피.
  const { data: claimed, error: claimError } = await admin.rpc(
    'claim_next_poster_job',
  );

  if (claimError) {
    console.error('[process-poster-jobs] claim RPC failed:', claimError);
    return jsonResponse({ processed: 0, jobId: null, result: 'failed' }, 500);
  }

  // RPC 가 RETURN scheduled_poster_jobs 라 row 없을 때 NULL 또는 모든 필드가
  // null 인 레코드를 반환할 수 있음. id 가 null 이면 pending job 없음.
  const claimedRow = Array.isArray(claimed) ? claimed[0] : claimed;
  if (!claimedRow || !claimedRow.id) {
    return jsonResponse({ processed: 0, jobId: null, result: 'no_pending' }, 200);
  }

  const job = claimedRow as PosterJobRow;
  console.log(
    `[process-poster-jobs] claimed job=${job.id} type=${job.poster_type} user=${job.user_id}`,
  );

  try {
    // 기존 generate-poster-guide Edge Function 호출 — 코드 중복 회피.
    const generateUrl = `${supabaseUrl}/functions/v1/generate-poster-guide`;
    const generateResponse = await fetch(generateUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        posterType: job.poster_type,
        userId: job.user_id,
        imageBase64: job.image_base64 ?? undefined,
        contextText: job.context_text ?? undefined,
      }),
    });

    if (!generateResponse.ok) {
      const errBody = await generateResponse.text();
      throw new Error(
        `generate-poster-guide returned ${generateResponse.status}: ${errBody.slice(0, 300)}`,
      );
    }

    const result = (await generateResponse.json()) as {
      success: boolean;
      imageUrl?: string;
      error?: string;
    };

    if (!result.success || !result.imageUrl) {
      throw new Error(result.error ?? 'generate-poster-guide returned no imageUrl');
    }

    const imageUrl = result.imageUrl;

    // 결과 카드 메시지 INSERT
    await insertResultCardMessage(admin, job, imageUrl);

    // Push 발송 (cardPayload 포함 → 클라가 hydrate 없이 즉시 INSERT)
    await sendCompletionPush(admin, job, imageUrl);

    // Job mark done
    await admin
      .from('scheduled_poster_jobs')
      .update({
        status: 'done',
        result_image_url: imageUrl,
        completed_at: new Date().toISOString(),
      })
      .eq('id', job.id);

    console.log(`[process-poster-jobs] done job=${job.id}`);
    return jsonResponse({ processed: 1, jobId: job.id, result: 'ok' }, 200);
  } catch (error) {
    const errMsg = error instanceof Error ? error.message : String(error);
    console.error(`[process-poster-jobs] job=${job.id} failed:`, errMsg);

    // failed 메시지 INSERT (사용자가 실패 사실 인지 가능)
    await insertFailureMessage(admin, job).catch((e) =>
      console.warn('[process-poster-jobs] failure message insert error:', e),
    );

    await admin
      .from('scheduled_poster_jobs')
      .update({
        status: 'failed',
        error_message: errMsg.slice(0, 500),
        completed_at: new Date().toISOString(),
      })
      .eq('id', job.id);

    return jsonResponse(
      { processed: 1, jobId: job.id, result: 'failed' },
      200, // cron 자체는 성공 — 다음 사이클 호출되어야 함
    );
  }
});

/**
 * 성공 결과 카드 메시지 (embedded-result kind) 를 character_conversations 에 INSERT.
 *
 * **CRITICAL — 영속화 envelope 필수**:
 *   클라이언트 `loadCharacterConversation` → `fromPersistedStoryMessages` 파서는
 *   메시지를 `{id, type, content, timestamp}` (text) 또는
 *   `{id, type, content, timestamp, cardKind, cardPayload}` (card) shape 으로
 *   기대한다. 만약 클라 in-memory `ChatShellMessage` 원형(`{id, kind, sender,
 *   payload}`) 을 그대로 INSERT 하면 두 분기 모두 reject → silently DROP.
 *
 *   그 결과 손금가이드 결과 카드가 채팅창에 절대 등장하지 않거나, 부분 hydrate
 *   된 payload 로 "결과를 불러오지 못했어요" fallback 노출. (1.0.11 production
 *   에서 사용자가 결과를 끝까지 못 보던 버그 — 영속화 envelope 미사용이 원인.)
 */
function buildCardPayload(job: PosterJobRow, imageUrl: string) {
  const messageId = `result-${job.id}`;
  const generatedAt = new Date().toISOString();
  const label = posterTypeLabel(job.poster_type);

  // 클라이언트 in-memory ChatShellEmbeddedResultMessage 형식 — `cardPayload` 에
  // 통째로 박는다. 클라 `tryRestoreCardMessage` 가 이 객체를 그대로 복원.
  return {
    id: messageId,
    kind: 'embedded-result' as const,
    sender: 'assistant' as const,
    embeddedWidgetType: 'fortune_result_card' as const,
    fortuneType: job.poster_type,
    resultKind: job.poster_type, // poster-guide types 는 fortuneType == resultKind
    title: label,
    payload: {
      kind: job.poster_type,
      fortuneType: job.poster_type,
      resultKind: job.poster_type,
      // poster-guide.tsx 가 rawApiResponse.imageUrl 을 읽음. 동일 shape 으로
      // INSERT 하기 위해 rawApiResponse 미러링 + payload 최상단에도 imageUrl 보존.
      imageUrl,
      generatedAt,
      rawApiResponse: {
        success: true,
        posterType: job.poster_type,
        imageUrl,
        generatedAt,
      },
    },
  };
}

async function insertResultCardMessage(
  admin: SupabaseClient,
  job: PosterJobRow,
  imageUrl: string,
  // cardPayload 를 caller 가 build → 본 함수 INSERT + sendCompletionPush 가 동일
  // cardPayload 를 push data 로 전송하여 클라이언트가 hydrate 없이 즉시 INSERT.
): Promise<void> {
  const cardPayload = buildCardPayload(job, imageUrl);
  const generatedAt = new Date().toISOString();

  // 영속화 envelope (PersistedStoryMessage) — `cardKind` sentinel + `cardPayload`
  // 본체. `content` 는 옛 클라 fallback 용 미리보기 텍스트 (`extractCardPreviewText`
  // 와 동일 형식 유지).
  const persisted = {
    id: cardPayload.id,
    type: 'character',
    content: `[운세 결과 — ${job.poster_type}]`,
    timestamp: generatedAt,
    cardKind: 'embedded-result',
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

/**
 * 실패 시 사용자에게 보일 텍스트 메시지.
 *
 * 영속화 envelope (`{id, type, content, timestamp}`) 형식 — 클라
 * `fromPersistedStoryMessages` 의 text 분기가 이 shape 을 요구.
 * (이전: `{id, kind:'text', sender, text}` 클라 in-memory 형식 → DROP.)
 */
async function insertFailureMessage(
  admin: SupabaseClient,
  job: PosterJobRow,
): Promise<void> {
  const message = {
    id: `text-fail-${job.id}`,
    type: 'character',
    content:
      `${posterTypeLabel(job.poster_type)} 분석에 실패했어. 잠시 후 다시 시도해줘. ` +
      `같은 사진으로 계속 실패하면 다른 사진으로 부탁해!`,
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

/**
 * 완료 push 발송. cardPayload 를 push data 에 JSON-stringify 해서 포함 →
 * 클라이언트 push handler 가 받자마자 카드를 MessageStore 에 INSERT 가능
 * (extra fetch 0, hydrate 없이 즉시 등장).
 *
 * sendCharacterDmPush 가 아닌 sendPushToUser (lower-level) 를 써서 custom
 * data field (`card_payload_json`) 를 박는다. 일반 텍스트 chat reply 와 다른
 * 새 push 종류 (`type: 'poster_result'`).
 */
async function sendCompletionPush(
  admin: SupabaseClient,
  job: PosterJobRow,
  imageUrl: string,
): Promise<void> {
  const label = posterTypeLabel(job.poster_type);
  const cardPayload = buildCardPayload(job, imageUrl);

  // `card_payload_json` 키로 JSON-stringify 해서 박는다. push data 는
  // Record<string, string> 만 허용. 클라가 detect 후 JSON.parse → ChatShellMessage 로 INSERT.
  const pushData: Record<string, string> = {
    type: 'poster_result',
    channel: 'character_dm',
    character_id: job.character_id,
    characterId: job.character_id,
    title: job.character_name,
    body: `${label} 분석 결과 도착! 확인해봐 👀`,
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

function posterTypeLabel(t: PosterType): string {
  const labels: Record<PosterType, string> = {
    'palm-reading': '손금가이드',
    'beauty-simulation': '뷰티 시뮬레이션',
    'hair-style-guide': '헤어스타일 가이드',
    'face-reading-guide': '얼굴 인상 리포트',
    'ootd-guide': 'OOTD 가이드',
    'blind-date-guide': '소개팅 가이드',
    'past-life-guide': '전생 리포트',
  };
  return labels[t];
}

function jsonResponse(data: unknown, status: number) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
