/**
 * Cron / 내부 worker 함수 인증 헬퍼.
 *
 * 외부 호출자가 worker 엔드포인트(process-poster-jobs, process-long-running-jobs,
 * deliver-due-replies, proactive-message-dispatch 등)를 직접 때려서 OpenAI/Gemini
 * 비용을 폭주시키거나 무한 큐를 돌리지 못하도록 Authorization 헤더 검증.
 *
 * 허용 토큰:
 *  1) `Bearer <SUPABASE_SERVICE_ROLE_KEY>` — pg_cron 의 `current_setting('app.settings.service_role_key', true)` 가 보내는 토큰
 *  2) `Bearer <CRON_SECRET>` — 외부 cron-job.org / GitHub Actions 등 별도 비밀로 호출할 때 (옵션)
 *
 * 둘 다 환경에 없으면 (개발 환경) 모든 호출 차단 (fail-closed).
 *
 * /ultrareview PR#199 SRE P0 #6 fix.
 */

export function requireWorkerAuth(req: Request): Response | null {
  const authHeader = req.headers.get('Authorization') ?? '';
  const presented = authHeader.startsWith('Bearer ')
    ? authHeader.slice('Bearer '.length).trim()
    : '';

  if (!presented) {
    return unauthorized('missing_authorization_header');
  }

  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const ondoServiceRoleKey = Deno.env.get('ONDO_SERVICE_ROLE_JWT') ?? '';
  const cronSecret = Deno.env.get('CRON_SECRET') ?? '';

  // constant-time 비교는 Deno 표준 라이브러리에 없음. 여기선 하나-하나 비교
  // 후 빠른 reject 정도. service_role_key/CRON_SECRET 은 secret 이므로
  // timing attack 표면 적음.
  const acceptableTokens: string[] = [];
  if (serviceRoleKey) acceptableTokens.push(serviceRoleKey);
  if (ondoServiceRoleKey) acceptableTokens.push(ondoServiceRoleKey);
  if (cronSecret) acceptableTokens.push(cronSecret);

  if (acceptableTokens.length === 0) {
    console.error(
      '[worker_auth] SUPABASE_SERVICE_ROLE_KEY 와 CRON_SECRET 모두 미설정 — 모든 호출 차단',
    );
    return unauthorized('worker_auth_misconfigured');
  }

  if (!acceptableTokens.includes(presented)) {
    return unauthorized('invalid_token');
  }

  return null; // OK
}

function unauthorized(reason: string): Response {
  return new Response(
    JSON.stringify({ success: false, error: 'Unauthorized', reason }),
    {
      status: 401,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    },
  );
}
