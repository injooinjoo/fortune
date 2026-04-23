/**
 * Report Message Edge Function
 *
 * @description 사용자가 AI 캐릭터 응답을 신고하면 `message_reports` 테이블에
 *              row를 insert 한다. RLS 덕분에 reporter_id = auth.uid() 자동 강제.
 *              24h 이내 검토 대상.
 *
 * @endpoint POST /report-message
 *
 * @requestBody
 * - character_id: string (필수)
 * - message_id?: string (클라이언트 생성 ID, 옵션)
 * - message_text: string (신고된 메시지 본문, 최대 4000자)
 * - reason_code: 'sexual'|'violence'|'self_harm'|'minor'|'hate'|'spam'|'other'
 * - reason_note?: string (최대 500자)
 *
 * @auth Authorization: Bearer <access_token> 필수
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { authenticateUser } from '../_shared/auth.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const ALLOWED_REASON_CODES = new Set([
  'sexual',
  'violence',
  'self_harm',
  'minor',
  'hate',
  'spam',
  'other',
])

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  // JWT 필수 — reporter_id는 JWT에서 파생. body로 받지 않음.
  const { user, error: authError } = await authenticateUser(req)
  if (authError || !user) {
    return authError ?? jsonResponse({ error: 'Unauthorized' }, 401)
  }

  let body: Record<string, unknown>
  try {
    body = await req.json()
  } catch {
    return jsonResponse({ error: '요청 본문이 올바르지 않습니다.' }, 400)
  }

  const characterId = typeof body.character_id === 'string' ? body.character_id.trim() : ''
  const messageText = typeof body.message_text === 'string' ? body.message_text : ''
  const reasonCode = typeof body.reason_code === 'string' ? body.reason_code : ''
  const messageId =
    typeof body.message_id === 'string' && body.message_id.trim().length > 0
      ? body.message_id.trim().slice(0, 200)
      : null
  const reasonNote =
    typeof body.reason_note === 'string' && body.reason_note.trim().length > 0
      ? body.reason_note.trim().slice(0, 500)
      : null

  if (!characterId) {
    return jsonResponse({ error: 'character_id가 필요합니다.' }, 400)
  }
  if (!messageText || messageText.length === 0) {
    return jsonResponse({ error: 'message_text가 필요합니다.' }, 400)
  }
  if (messageText.length > 4000) {
    return jsonResponse({ error: 'message_text가 너무 깁니다.' }, 413)
  }
  if (!ALLOWED_REASON_CODES.has(reasonCode)) {
    return jsonResponse({ error: '지원하지 않는 reason_code 입니다.' }, 400)
  }

  // 사용자 JWT를 전달하여 RLS 가 적용되도록 한다 (service_role 사용 금지).
  const authHeader = req.headers.get('Authorization')!
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: { headers: { Authorization: authHeader } },
      auth: { autoRefreshToken: false, persistSession: false },
    }
  )

  const { error: insertError } = await supabase.from('message_reports').insert({
    reporter_id: user.id,
    character_id: characterId.slice(0, 200),
    message_id: messageId,
    message_text: messageText.slice(0, 4000),
    reason_code: reasonCode,
    reason_note: reasonNote,
  })

  if (insertError) {
    console.error('[report-message] insert 실패:', insertError)
    return jsonResponse({ error: '신고 저장에 실패했습니다.' }, 500)
  }

  return jsonResponse(
    { success: true, message: '신고가 접수되었어요. 24시간 이내 검토할게요.' },
    200
  )
})
