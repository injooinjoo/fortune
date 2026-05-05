/**
 * start-long-running-job — long_running_jobs 큐에 generic enqueue.
 *
 * @description
 *   tarot/dream/compatibility/traditional-saju 등 30s+ LLM 운세를 비동기
 *   처리하기 위해 클라이언트가 호출하는 enqueue endpoint.
 *
 *   start-poster-job (image-gen 전용) 와 분리한 이유:
 *   - poster-jobs 테이블이 image_base64 / poster_type 등 image-gen 전용 컬럼을
 *     갖고 있어 텍스트 운세에는 부적합.
 *   - long_running_jobs 는 payload JSONB 로 임의 입력 받음 — 운세별 다양한
 *     서베이 답변 구조를 그대로 직렬화 가능.
 *
 *   처리:
 *     1. JWT 검증 → user_id 추출.
 *     2. 동일 user 의 active job (pending/processing) 5개 초과면 거절.
 *     3. INSERT row → return jobId.
 *     4. (worker 가 cron 사이클에 처리 + 결과 push)
 *
 * @endpoint POST /start-long-running-job
 *
 * @requestBody
 *   {
 *     jobType: 'tarot' | 'dream' | 'compatibility' | 'traditional-saju' | ...,
 *     characterId: string,
 *     characterName: string,
 *     payload: Record<string, unknown>,  // 운세별 서베이 답변
 *   }
 *
 * @response 성공 (200) { success: true, jobId, status: 'pending', estimatedSeconds: 45 }
 * @response 실패 (400/401/429/500) { success: false, error: string }
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

interface StartLongRunningJobRequest {
  jobType: string;
  characterId: string;
  characterName: string;
  payload?: Record<string, unknown>;
  /** 클라가 추정한 소요시간 (초). 미지정 시 worker default 45 사용. */
  estimatedSeconds?: number;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

// Phase D 에서 추가될 job_type 화이트리스트. 이 목록 외 값은 INSERT 거절.
// (워커가 unknown job_type 을 failed 처리하므로 한 번 더 게이트하는 격이지만,
// quota / abuse 측면에서 클라이언트 검증을 사전 차단하는 편이 안전.)
const ALLOWED_JOB_TYPES = new Set<string>([
  'tarot',
  'dream',
  'compatibility',
  'traditional-saju',
]);

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
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

    const body = (await req.json()) as StartLongRunningJobRequest;
    if (!body.jobType || !ALLOWED_JOB_TYPES.has(body.jobType)) {
      return jsonError(400, '지원하지 않는 운세 종류입니다.');
    }
    if (!body.characterId || !body.characterName) {
      return jsonError(400, '캐릭터 정보가 누락되었습니다.');
    }

    // payload 크기 가드 — 큐/realtime broadcast 부풀어 다른 사용자 영향 방지.
    // 운세 답변은 작은 객체 (수십 KB 이내) 라 16KB 상한이 안전 마진.
    if (body.payload) {
      const serialized = JSON.stringify(body.payload);
      if (serialized.length > 16_000) {
        return jsonError(413, '요청 데이터가 너무 큽니다.');
      }
    }

    const adminClient = createClient(supabaseUrl, supabaseServiceKey);
    const { count: activeCount } = await adminClient
      .from('long_running_jobs')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .in('status', ['pending', 'processing']);

    if ((activeCount ?? 0) >= 5) {
      return jsonError(
        429,
        '진행 중인 운세가 너무 많습니다. 끝난 후 다시 시도해주세요.',
      );
    }

    const { data: job, error: insertError } = await adminClient
      .from('long_running_jobs')
      .insert({
        user_id: user.id,
        character_id: body.characterId,
        character_name: body.characterName,
        job_type: body.jobType,
        payload: body.payload ?? {},
        status: 'pending',
      })
      .select('id')
      .single();

    if (insertError || !job) {
      console.error('[start-long-running-job] INSERT failed:', insertError);
      return jsonError(500, '요청 등록에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }

    return new Response(
      JSON.stringify({
        success: true,
        jobId: job.id,
        status: 'pending',
        estimatedSeconds: body.estimatedSeconds ?? 45,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    );
  } catch (error) {
    console.error('[start-long-running-job] unexpected error:', error);
    return jsonError(500, '예상치 못한 오류가 발생했습니다.');
  }
});

function jsonError(status: number, message: string) {
  return new Response(JSON.stringify({ success: false, error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
