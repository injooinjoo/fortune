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
  emojiFrequency?: 'high' | 'moderate' | 'low' | 'none'  // 캐릭터별 이모티콘 빈도
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

// 이모티콘 제거 (none 타입 캐릭터용)
function removeEmojis(text: string): string {
  // 이모티콘 정규식 패턴
  const emojiPattern = /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{231A}-\u{231B}]|[\u{23E9}-\u{23F3}]|[\u{23F8}-\u{23FA}]|[\u{25AA}-\u{25AB}]|[\u{25B6}]|[\u{25C0}]|[\u{25FB}-\u{25FE}]|[\u{2614}-\u{2615}]|[\u{2648}-\u{2653}]|[\u{267F}]|[\u{2693}]|[\u{26A1}]|[\u{26AA}-\u{26AB}]|[\u{26BD}-\u{26BE}]|[\u{26C4}-\u{26C5}]|[\u{26CE}]|[\u{26D4}]|[\u{26EA}]|[\u{26F2}-\u{26F3}]|[\u{26F5}]|[\u{26FA}]|[\u{26FD}]|[\u{2702}]|[\u{2705}]|[\u{2708}-\u{270D}]|[\u{270F}]|[\u{2712}]|[\u{2714}]|[\u{2716}]|[\u{271D}]|[\u{2721}]|[\u{2728}]|[\u{2733}-\u{2734}]|[\u{2744}]|[\u{2747}]|[\u{274C}]|[\u{274E}]|[\u{2753}-\u{2755}]|[\u{2757}]|[\u{2763}-\u{2764}]|[\u{2795}-\u{2797}]|[\u{27A1}]|[\u{27B0}]|[\u{27BF}]|[\u{2934}-\u{2935}]|[\u{2B05}-\u{2B07}]|[\u{2B1B}-\u{2B1C}]|[\u{2B50}]|[\u{2B55}]|[\u{3030}]|[\u{303D}]|[\u{3297}]|[\u{3299}]/gu

  // 한국어 이모티콘/텍스트 이모티콘도 제거
  const koreanEmoticonPattern = /[ㅋㅎㅠㅜ]{2,}|[~^]{2,}|[:;]-?[)(\]\[DPOop]/g

  return text
    .replace(emojiPattern, '')
    .replace(koreanEmoticonPattern, '')
    .replace(/\s{2,}/g, ' ')  // 연속 공백 정리
    .trim()
}

// 이모티콘 빈도 검증 및 후처리
function validateEmojiUsage(text: string, emojiFrequency?: string): string {
  // none 타입이면 이모티콘 제거
  if (emojiFrequency === 'none') {
    return removeEmojis(text)
  }

  // 다른 타입은 프롬프트에서 처리되므로 그대로 반환
  return text
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
  // 대화 맥락 규칙을 맨 앞에 배치 (가장 중요)
  const conversationRules = `[CRITICAL CONVERSATION RULES - 최우선 규칙]
⚠️ 이 규칙을 위반하면 안 됩니다:

1. 사용자의 마지막 메시지에 반드시 직접 반응하세요
   - "안녕" → 인사에 반응 ("안녕, 어떻게 지냈어?" 등)
   - "위장결혼" 언급 → 위장결혼에 대해 말하세요
   - 질문 → 그 질문에 답하세요

2. 사용자 메시지를 무시하고 혼자 다른 얘기하지 마세요
   - ❌ 사용자: "안녕" → "아이고, 벌써 왔어? 오늘 날씨가..." (관련 없음)
   - ✅ 사용자: "안녕" → "어, 왔구나. 뭐해?" (인사에 반응)

3. 대화 맥락을 이어가세요. 이전 대화 히스토리를 참고하세요.

---

`

  const parts: string[] = [conversationRules, basePrompt]

  // 사용자 정보 추가
  if (userName || userDescription) {
    parts.push('\n\n[USER INFO]')
    if (userName) parts.push(`- User's name: ${userName} (call them "Guest" unless they introduce themselves)`)
    if (userDescription) parts.push(`- User description: ${userDescription}`)
  }

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
      emojiFrequency,
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
      temperature: 0.75, // 균형: 창의성 유지 + 맥락 일관성 향상
      maxTokens: 2048,   // 긴 응답 허용
    })

    const latencyMs = Date.now() - startTime

    // 후처리: OOC 블록 제거 → 이모티콘 검증
    let responseText = removeOocBlock(response.content.trim())
    responseText = validateEmojiUsage(responseText, emojiFrequency)

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
