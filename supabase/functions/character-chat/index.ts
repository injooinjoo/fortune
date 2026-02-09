/**
 * 캐릭터 롤플레이 채팅 Edge Function
 *
 * @description AI 캐릭터와의 1:1 롤플레이 채팅을 처리합니다.
 * 캐릭터별 고유한 시스템 프롬프트와 OOC 지시사항을 활용합니다.
 *
 * @endpoint POST /character-chat
 *
 * @requestBody
 * - characterId: string - 캐릭터 ID
 * - systemPrompt: string - 캐릭터 시스템 프롬프트
 * - messages: Array<{role, content}> - 대화 히스토리
 * - userMessage: string - 사용자 메시지
 * - userName?: string - 사용자 이름
 * - userDescription?: string - 사용자 설명
 * - oocInstructions?: string - OOC 상태창 포맷 지시
 *
 * @response CharacterChatResponse
 * - success: boolean
 * - response: string - AI 캐릭터 응답
 * - meta: { provider, model, latencyMs }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { corsHeaders, handleCors } from '../_shared/cors.ts'

interface ChatMessage {
  role: 'user' | 'assistant' | 'system'
  content: string
}

interface CharacterChatRequest {
  characterId: string
  systemPrompt: string
  messages: ChatMessage[]
  userMessage: string
  userName?: string
  userDescription?: string
  oocInstructions?: string
}

interface CharacterChatResponse {
  success: boolean
  response: string
  emotionTag: string
  delaySec: number
  meta: {
    provider: string
    model: string
    latencyMs: number
  }
  error?: string
}

// 감정 설정: { keywords, minDelay(초), maxDelay(초) }
const EMOTION_CONFIG: Record<string, { keywords: string[]; minDelay: number; maxDelay: number }> = {
  '당황': { keywords: ['어?', '뭐?', '어라?', '...?!', '헉', '에?', '뭐라고'], minDelay: 60, maxDelay: 300 },
  '고민': { keywords: ['음...', '흠...', '생각해보니', '글쎄', '어떻게', '모르겠'], minDelay: 40, maxDelay: 180 },
  '분노': { keywords: ['뭐하는', '화가', '짜증', '싫어', '나가', '꺼져'], minDelay: 30, maxDelay: 120 },
  '애정': { keywords: ['좋아', '사랑', '소중', '예쁘', '귀여', '보고싶'], minDelay: 15, maxDelay: 60 },
  '기쁨': { keywords: ['하하', 'ㅋㅋ', '재밌', '신나', '좋겠', '대박'], minDelay: 10, maxDelay: 25 },
  '일상': { keywords: [], minDelay: 10, maxDelay: 30 },
}

// OOC 상태 블록 제거 (사용자에게 보이지 않도록)
// 기존 대화 히스토리에서 로드된 메타 정보 제거용 안전장치
function removeOocBlock(text: string): string {
  const oocPatterns = [
    // 범용: [ 로 시작하는 상태 블록 (위치/시간/날씨 등)
    /\n*\[\s*(?:현재\s*)?(?:위치|날씨|계절|시간|Weather|Location).*$/si,

    // 캐릭터 상태: "캐릭터명: 의상/자세/기분" 형태
    /\n*[가-힣A-Za-z]+:\s*(?:후드티|정장|캐주얼|교복|드레스).*$/s,

    // Guest 상태
    /\n*Guest:\s*\(.*\).*$/s,

    // 구분선 + 게이지 블록 (호감도, 진행도 등)
    /\n*━+\n*(?:💕|🎮|❤️|🖤|⚡|🌙|☀️|🔥|💔|🎭|📊|🎯).*$/s,

    // 한줄 일기 / 숨기고 있는 것
    /\n*[가-힣A-Za-z]+의\s*한줄\s*일기.*$/s,
    /\n*[가-힣A-Za-z]+(?:가|이)\s*숨기고\s*있는\s*것.*$/s,

    // 구분선만 있는 경우
    /\n*━{3,}.*$/s,

    // 레거시 패턴 (기존 유지)
    /\n*[A-Za-z가-힣]+:\s*\d+\/.*상황\s*\|.*$/s,
    /\n*상황\s*\|.*AI\s*코멘트.*$/s,
  ]

  let cleaned = text
  for (const pattern of oocPatterns) {
    cleaned = cleaned.replace(pattern, '')
  }

  return cleaned.trim()
}

// 응답 텍스트에서 감정 추출
function extractEmotion(text: string): { emotionTag: string; delaySec: number } {
  // 우선순위: 당황 > 고민 > 분노 > 애정 > 기쁨 > 일상
  const priorities = ['당황', '고민', '분노', '애정', '기쁨']

  for (const emotion of priorities) {
    const config = EMOTION_CONFIG[emotion]
    const found = config.keywords.some((kw) => text.includes(kw))
    if (found) {
      const delaySec = Math.floor(Math.random() * (config.maxDelay - config.minDelay + 1)) + config.minDelay
      return { emotionTag: emotion, delaySec }
    }
  }

  // 기본: 일상
  const defaultConfig = EMOTION_CONFIG['일상']
  const delaySec = Math.floor(Math.random() * (defaultConfig.maxDelay - defaultConfig.minDelay + 1)) + defaultConfig.minDelay
  return { emotionTag: '일상', delaySec }
}

// 시스템 프롬프트 조합
function buildFullSystemPrompt(
  basePrompt: string,
  userName?: string,
  userDescription?: string,
  oocInstructions?: string
): string {
  const parts: string[] = [basePrompt]

  // 사용자 정보 추가
  if (userName || userDescription) {
    parts.push('\n\n[USER INFO]')
    if (userName) parts.push(`- User's name: ${userName} (call them "Guest" unless they introduce themselves)`)
    if (userDescription) parts.push(`- User description: ${userDescription}`)
  }

  // OOC 지시사항은 AI 프롬프트에 포함하지 않음
  // AI가 순수하게 캐릭터로서만 자연스럽게 대화하도록 함
  // (메타 정보 출력 방지)

  return parts.join('\n')
}

// 메시지 히스토리 제한 (최근 20개)
function limitMessages(messages: ChatMessage[], limit: number = 20): ChatMessage[] {
  if (messages.length <= limit) return messages
  return messages.slice(-limit)
}

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  const startTime = Date.now()

  try {
    const {
      characterId,
      systemPrompt,
      messages,
      userMessage,
      userName,
      userDescription,
      oocInstructions,
    }: CharacterChatRequest = await req.json()

    // 유효성 검사
    if (!characterId || !systemPrompt || !userMessage) {
      return new Response(
        JSON.stringify({
          success: false,
          response: '',
          error: 'characterId, systemPrompt, userMessage는 필수입니다',
        } as CharacterChatResponse),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // 시스템 프롬프트 조합
    const fullSystemPrompt = buildFullSystemPrompt(
      systemPrompt,
      userName,
      userDescription,
      oocInstructions
    )

    // 메시지 히스토리 준비
    const limitedHistory = limitMessages(messages || [])
    const chatMessages: ChatMessage[] = [
      { role: 'system', content: fullSystemPrompt },
      ...limitedHistory,
      { role: 'user', content: userMessage },
    ]

    // LLM 호출 (free-chat 설정 사용, 높은 temperature)
    const llm = LLMFactory.createFromConfig('free-chat')

    const response = await llm.generate(chatMessages, {
      temperature: 0.9, // 높은 창의성
      maxTokens: 2048,  // 긴 응답 허용
    })

    const latencyMs = Date.now() - startTime
    const responseText = removeOocBlock(response.content.trim())

    // 감정 추출 및 딜레이 계산
    const { emotionTag, delaySec } = extractEmotion(responseText)

    return new Response(
      JSON.stringify({
        success: true,
        response: responseText,
        emotionTag,
        delaySec,
        meta: {
          provider: 'gemini',
          model: 'gemini-2.0-flash-lite',
          latencyMs,
        },
      } as CharacterChatResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('character-chat 에러:', error)

    return new Response(
      JSON.stringify({
        success: false,
        response: '',
        emotionTag: '일상',
        delaySec: 0,
        error: error instanceof Error ? error.message : 'Unknown error',
        meta: {
          provider: 'gemini',
          model: 'gemini-2.0-flash-lite',
          latencyMs: Date.now() - startTime,
        },
      } as CharacterChatResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
