/**
 * 캐릭터 대화 스레드 불러오기 Edge Function
 *
 * @description 유저-캐릭터 조합의 기존 대화 스레드를 불러옵니다.
 *
 * @endpoint POST /character-conversation-load
 *
 * @requestBody
 * - characterId: string - 캐릭터 ID
 *
 * @response
 * - success: boolean
 * - messages: Array<{id, type, content, timestamp}> - 메시지 배열 (없으면 빈 배열)
 * - lastMessageAt: string | null - 마지막 메시지 시간
 * - error?: string
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'

interface ChatMessage {
  id: string
  type: 'user' | 'character' | 'system' | 'narration'
  content: string
  timestamp: string
}

interface LoadRequest {
  characterId: string
}

interface LoadResponse {
  success: boolean
  messages: ChatMessage[]
  lastMessageAt: string | null
  error?: string
}

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({
          success: false,
          messages: [],
          lastMessageAt: null,
          error: 'Missing authorization header'
        } as LoadResponse),
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
        JSON.stringify({
          success: false,
          messages: [],
          lastMessageAt: null,
          error: 'Invalid token'
        } as LoadResponse),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 요청 파싱
    const { characterId }: LoadRequest = await req.json()

    if (!characterId) {
      return new Response(
        JSON.stringify({
          success: false,
          messages: [],
          lastMessageAt: null,
          error: 'characterId is required'
        } as LoadResponse),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 대화 스레드 조회
    const { data, error: selectError } = await supabase
      .from('character_conversations')
      .select('messages, last_message_at')
      .eq('user_id', user.id)
      .eq('character_id', characterId)
      .single()

    // 없으면 빈 배열 반환 (에러가 아님)
    if (selectError?.code === 'PGRST116') {
      // PGRST116 = "The result contains 0 rows"
      console.log(`[character-conversation-load] No conversation found for user ${user.id}, character ${characterId}`)
      return new Response(
        JSON.stringify({
          success: true,
          messages: [],
          lastMessageAt: null
        } as LoadResponse),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (selectError) {
      console.error('Select error:', selectError)
      return new Response(
        JSON.stringify({
          success: false,
          messages: [],
          lastMessageAt: null,
          error: selectError.message
        } as LoadResponse),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const messages = (data?.messages || []) as ChatMessage[]

    console.log(`[character-conversation-load] User ${user.id} loaded ${messages.length} messages for character ${characterId}`)

    return new Response(
      JSON.stringify({
        success: true,
        messages,
        lastMessageAt: data?.last_message_at || null
      } as LoadResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('character-conversation-load error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        messages: [],
        lastMessageAt: null,
        error: error instanceof Error ? error.message : 'Unknown error'
      } as LoadResponse),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
