/**
 * 모든 캐릭터 대화 스레드 일괄 불러오기 Edge Function
 *
 * @description 로그인 후 사용자의 모든 캐릭터 대화를 한 번에 불러옵니다.
 *
 * @endpoint POST /character-conversations-load-all
 *
 * @requestBody (optional)
 * - characterIds?: string[] - 특정 캐릭터만 불러오기 (없으면 전체)
 *
 * @response
 * - success: boolean
 * - conversations: Record<characterId, { messages, lastMessageAt }>
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

interface ConversationData {
  messages: ChatMessage[]
  lastMessageAt: string | null
}

interface LoadAllRequest {
  characterIds?: string[]
}

interface LoadAllResponse {
  success: boolean
  conversations: Record<string, ConversationData>
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
          conversations: {},
          error: 'Missing authorization header'
        } as LoadAllResponse),
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
          conversations: {},
          error: 'Invalid token'
        } as LoadAllResponse),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 요청 파싱 (빈 body 허용)
    let characterIds: string[] | undefined
    try {
      const body = await req.json()
      characterIds = body?.characterIds
    } catch {
      // 빈 body인 경우 전체 조회
    }

    // 대화 스레드 조회 (전체 또는 특정 캐릭터)
    let query = supabase
      .from('character_conversations')
      .select('character_id, messages, last_message_at')
      .eq('user_id', user.id)

    if (characterIds && characterIds.length > 0) {
      query = query.in('character_id', characterIds)
    }

    const { data, error: selectError } = await query

    if (selectError) {
      console.error('Select error:', selectError)
      return new Response(
        JSON.stringify({
          success: false,
          conversations: {},
          error: selectError.message
        } as LoadAllResponse),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 결과를 characterId 기준 맵으로 변환
    const conversations: Record<string, ConversationData> = {}

    for (const row of (data || [])) {
      conversations[row.character_id] = {
        messages: (row.messages || []) as ChatMessage[],
        lastMessageAt: row.last_message_at || null
      }
    }

    const conversationCount = Object.keys(conversations).length
    const totalMessages = Object.values(conversations).reduce(
      (sum, conv) => sum + conv.messages.length, 0
    )

    console.log(`[character-conversations-load-all] User ${user.id} loaded ${conversationCount} conversations (${totalMessages} messages total)`)

    return new Response(
      JSON.stringify({
        success: true,
        conversations
      } as LoadAllResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('character-conversations-load-all error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        conversations: {},
        error: error instanceof Error ? error.message : 'Unknown error'
      } as LoadAllResponse),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
