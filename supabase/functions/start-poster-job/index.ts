/**
 * start-poster-job — Async poster-guide 시작 (메신저 패턴).
 *
 * @description
 *   palm-reading 등 gpt-image-2 기반 무거운 운세를 비동기 큐에 등록한다.
 *   기존 `generate-poster-guide` 와 달리 즉시 반환 (~200ms) — OpenAI 호출은
 *   `process-poster-jobs` cron worker 가 백그라운드에서 처리.
 *
 *   클라이언트 흐름:
 *     1. 사용자 사진 업로드 → start-poster-job 호출
 *     2. 즉시 jobId 반환 + character_conversations 에 placeholder text 메시지
 *        ("분석 시작했어! 끝나면 푸시로 알려줄게.") INSERT
 *     3. 사용자 자유롭게 다른 채팅 / 앱 종료 가능
 *     4. cron 이 완료 시 결과 카드 INSERT + push 발송
 *
 * @endpoint POST /start-poster-job
 *
 * @requestBody
 *   {
 *     posterType: PosterType,         // palm-reading 등
 *     characterId: string,            // 채팅 중인 캐릭터
 *     characterName: string,
 *     imageBase64?: string,           // 사용자 사진 (필요 시)
 *     contextText?: string,
 *   }
 *
 * @response 성공 (200)
 *   { success: true, jobId, status: 'pending', estimatedSeconds: 60 }
 *
 * @response 실패 (400/401/500)
 *   { success: false, error: string }
 */

import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  ALL_POSTER_TYPES,
  type PosterType,
} from '../_shared/poster_registry.ts';

interface StartPosterJobRequest {
  posterType: PosterType;
  characterId: string;
  characterName: string;
  imageBase64?: string;
  contextText?: string;
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

  try {
    // Auth 검증 — JWT 에서 user_id 추출
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return jsonError(401, '인증이 필요합니다.');
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return jsonError(401, '세션이 만료되었습니다.');
    }

    // 요청 body 검증
    const body = (await req.json()) as StartPosterJobRequest;
    if (!body.posterType || !ALL_POSTER_TYPES.includes(body.posterType)) {
      return jsonError(400, '지원하지 않는 운세 종류입니다.');
    }
    if (!body.characterId || !body.characterName) {
      return jsonError(400, '캐릭터 정보가 누락되었습니다.');
    }

    // 동시 큐 제한: 같은 user 가 pending/processing 인 job 5개 초과면 거절.
    // (사용자가 무한 큐잉으로 API quota 소진하는 abuse 방지)
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);
    const { count: activeCount } = await adminClient
      .from('scheduled_poster_jobs')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .in('status', ['pending', 'processing']);

    if ((activeCount ?? 0) >= 5) {
      return jsonError(
        429,
        '진행 중인 운세가 너무 많습니다. 끝난 후 다시 시도해주세요.',
      );
    }

    // INSERT job
    const { data: job, error: insertError } = await adminClient
      .from('scheduled_poster_jobs')
      .insert({
        user_id: user.id,
        character_id: body.characterId,
        character_name: body.characterName,
        poster_type: body.posterType,
        image_base64: body.imageBase64 ?? null,
        context_text: body.contextText ?? null,
        status: 'pending',
      })
      .select('id')
      .single();

    if (insertError || !job) {
      console.error('[start-poster-job] INSERT failed:', insertError);
      return jsonError(500, '요청 등록에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }

    // Placeholder 메시지 INSERT — 캐릭터가 "분석 시작했어!" 라고 채팅창에 즉시 답변
    await insertPlaceholderMessage(
      adminClient,
      user.id,
      body.characterId,
      body.posterType,
    );

    return new Response(
      JSON.stringify({
        success: true,
        jobId: job.id,
        status: 'pending',
        estimatedSeconds: 60,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    );
  } catch (error) {
    console.error('[start-poster-job] unexpected error:', error);
    return jsonError(500, '예상치 못한 오류가 발생했습니다.');
  }
});

/**
 * Placeholder 텍스트 메시지를 character_conversations 에 INSERT.
 * 사용자가 즉시 채팅창에서 "분석 시작했어!" 라는 응답을 본다.
 *
 * 영속화 envelope (`{id, type, content, timestamp}`) 형식 — 클라
 * `fromPersistedStoryMessages` 의 text 분기가 이 shape 을 요구.
 * (이전: `{id, kind:'text', sender, text}` 클라 in-memory 형식 → 파서가
 * reject 해 silently DROP. 클라 측은 chat-screen 의 local appendMessages
 * 가 동일 placeholder 를 별도로 push 하므로 사용자 가시 영향은 없었지만,
 * 다른 디바이스/콜드스타트 시 재진입하면 placeholder 가 사라지는 문제가
 * 있었다.)
 */
async function insertPlaceholderMessage(
  client: SupabaseClient,
  userId: string,
  characterId: string,
  posterType: PosterType,
): Promise<void> {
  const placeholderText = buildPlaceholderText(posterType);
  const messageId = `text-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

  const placeholder = {
    id: messageId,
    type: 'character',
    content: placeholderText,
    timestamp: new Date().toISOString(),
  };

  const { error } = await client.rpc('merge_character_conversation_messages', {
    p_user_id: userId,
    p_character_id: characterId,
    p_incoming_messages: [placeholder],
    p_runtime_state: null,
    p_max_messages: 200,
  });

  if (error) {
    // 부수효과 실패는 치명적 아님 — 결과 카드는 cron 이 별도로 INSERT
    console.warn('[start-poster-job] placeholder merge failed:', error);
  }
}

/**
 * posterType 별 placeholder 메시지 (한국어, 캐릭터 톤).
 */
function buildPlaceholderText(posterType: PosterType): string {
  const labels: Record<PosterType, string> = {
    'palm-reading': '손금',
    'beauty-simulation': '뷰티 시뮬레이션',
    'hair-style-guide': '헤어스타일',
    'face-reading-guide': '얼굴 인상',
    'ootd-guide': 'OOTD',
    'blind-date-guide': '소개팅',
    'past-life-guide': '전생',
  };
  const label = labels[posterType];
  return (
    `${label} 분석 시작했어! 보통 30초~1분 정도 걸려.\n` +
    `끝나면 푸시 알림으로 알려줄게. 그동안 다른 얘기 자유롭게 해도 돼!`
  );
}

function jsonError(status: number, message: string) {
  return new Response(JSON.stringify({ success: false, error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
