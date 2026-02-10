/**
 * 일반 채팅 대화 저장 Edge Function
 *
 * @description Chat Home의 대화 내용을 저장/업데이트합니다.
 * 최근 100개 메시지만 저장합니다.
 *
 * @endpoint POST /chat-conversation-save
 *
 * @requestBody
 * - messages: Array<{id, type, content, timestamp, ...}> - 저장할 메시지 배열
 *
 * @response
 * - success: boolean
 * - messageCount: number - 저장된 메시지 수
 * - error?: string
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'

interface ChatMessage {
  id: string
  type: string
  content?: string
  timestamp: string
  [key: string]: unknown
}

interface SaveRequest {
  messages: ChatMessage[]
}

interface SaveResponse {
  success: boolean
  messageCount: number
  error?: string
}

const MAX_MESSAGES = 100

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ success: false, messageCount: 0, error: 'Missing authorization header' } as SaveResponse),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const token = authHeader.replace('Bearer ', '')

    // Supabase 클라이언트 (사용자 컨텍스트)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    // 사용자 확인
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, messageCount: 0, error: 'Invalid token' } as SaveResponse),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 요청 파싱
    const { messages }: SaveRequest = await req.json()

    if (!messages || !Array.isArray(messages)) {
      return new Response(
        JSON.stringify({ success: false, messageCount: 0, error: 'messages array is required' } as SaveResponse),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 저장 가능한 메시지만 필터링 (user, ai, system 타입)
    const persistableMessages = messages.filter(m =>
      ['user', 'ai', 'system'].includes(m.type)
    )

    // 최근 100개만 저장 (오래된 메시지 제거)
    const limitedMessages = persistableMessages.slice(-MAX_MESSAGES)

    // UPSERT: 기존 대화 업데이트 또는 새로 생성
    const { error: upsertError } = await supabase
      .from('chat_conversations')
      .upsert(
        {
          user_id: user.id,
          messages: limitedMessages,
          last_message_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'user_id' }
      )

    if (upsertError) {
      console.error('Upsert error:', upsertError)
      return new Response(
        JSON.stringify({ success: false, messageCount: 0, error: upsertError.message } as SaveResponse),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`[chat-conversation-save] User ${user.id} saved ${limitedMessages.length} messages`)

    return new Response(
      JSON.stringify({ success: true, messageCount: limitedMessages.length } as SaveResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('chat-conversation-save error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        messageCount: 0,
        error: error instanceof Error ? error.message : 'Unknown error'
      } as SaveResponse),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
