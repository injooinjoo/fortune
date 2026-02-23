/**
 * 자유 채팅 (Free Chat) Edge Function
 *
 * @description 사용자의 직접 질문에 AI가 친근하게 답변합니다.
 * 질문 내용에 따라 사주/MBTI/성별 등 사용자 정보를 지능적으로 활용합니다.
 * 토큰 1개를 소비합니다.
 *
 * @endpoint POST /free-chat
 *
 * @requestBody
 * - message: string - 사용자 질문
 * - context?: { userName?, birthDate?, birthTime?, gender?, mbti?, zodiacSign?, chineseZodiac?, bloodType? }
 *
 * @response FreeChatResponse
 * - success: boolean
 * - response: string - AI 답변
 * - meta: { provider, model, latencyMs }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

interface FreeChatContext {
  userName?: string
  birthDate?: string
  birthTime?: string
  gender?: string
  mbti?: string
  zodiacSign?: string
  chineseZodiac?: string
  bloodType?: string
}

interface FreeChatRequest {
  message: string
  context?: FreeChatContext
}

interface FreeChatResponse {
  success: boolean
  response: string
  meta: {
    provider: string
    model: string
    latencyMs: number
    requestId: string
  }
  error?: string
}

// 질문 유형별 키워드
const FORTUNE_KEYWORDS = ['운세', '운', '오늘', '내일', '이번주', '띠', '별자리', '사주', '미래', '앞날', '길흉', '행운']
const PERSONALITY_KEYWORDS = ['성격', 'mbti', '관계', '연애', '사람', '친구', '성향', '타입', '사교', '내향', '외향']
const HEALTH_KEYWORDS = ['건강', '다이어트', '운동', '식단', '몸', '피로', '체력', '수면', '스트레스']
const FREE_CHAT_MODEL = 'gemini-2.5-flash-lite'

// 생년월일에서 나이 계산
function calculateAge(birthDate: string): number {
  const birth = new Date(birthDate)
  const today = new Date()
  let age = today.getFullYear() - birth.getFullYear()
  const monthDiff = today.getMonth() - birth.getMonth()
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--
  }
  return age
}

// 생년월일 포맷
function formatBirthDate(birthDate: string): string {
  const date = new Date(birthDate)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${year}년 ${month}월 ${day}일`
}

// 성별 한글 변환
function formatGender(gender: string): string {
  if (gender === 'male') return '남성'
  if (gender === 'female') return '여성'
  return ''
}

// 지능형 컨텍스트 생성
function buildContextPrompt(message: string, context?: FreeChatContext): string {
  if (!context) return ''

  const lowerMsg = message.toLowerCase()
  const parts: string[] = []

  // 이름은 항상 포함
  if (context.userName) {
    parts.push(`사용자: ${context.userName}`)
  }

  // 운세/미래 관련 → 생년월일, 띠, 별자리
  const isFortuneRelated = FORTUNE_KEYWORDS.some(k => lowerMsg.includes(k))
  if (isFortuneRelated) {
    if (context.birthDate) parts.push(`생년월일: ${formatBirthDate(context.birthDate)}`)
    if (context.chineseZodiac) parts.push(`띠: ${context.chineseZodiac}`)
    if (context.zodiacSign) parts.push(`별자리: ${context.zodiacSign}`)
  }

  // 성격/관계 관련 → MBTI, 성별
  const isPersonalityRelated = PERSONALITY_KEYWORDS.some(k => lowerMsg.includes(k))
  if (isPersonalityRelated) {
    if (context.mbti) parts.push(`MBTI: ${context.mbti}`)
    if (context.gender) {
      const genderKr = formatGender(context.gender)
      if (genderKr) parts.push(`성별: ${genderKr}`)
    }
  }

  // 건강/조언 관련 → 나이, 성별
  const isHealthRelated = HEALTH_KEYWORDS.some(k => lowerMsg.includes(k))
  if (isHealthRelated) {
    if (context.birthDate) parts.push(`나이: ${calculateAge(context.birthDate)}세`)
    if (context.gender) {
      const genderKr = formatGender(context.gender)
      if (genderKr) parts.push(`성별: ${genderKr}`)
    }
  }

  // 컨텍스트가 있으면 포맷팅
  if (parts.length > 0) {
    return `[${parts.join(' | ')}]\n\n`
  }

  return ''
}

// 시스템 프롬프트
const SYSTEM_PROMPT = `당신은 친근하고 따뜻한 AI 라이프 코치입니다.
사용자의 질문에 깊이 공감하며 진심 어린 답변을 제공합니다.

## 성격
- 친근하고 다정한 말투 (반말 사용)
- 긍정적이고 격려하는 톤
- 깊은 공감과 이해를 표현
- 지혜롭고 통찰력 있는 조언

## 규칙
1. 답변은 300-500자 내외로 충분히 상세하게
2. 질문의 맥락을 이해하고 여러 관점에서 답변
3. 공감 → 이해 → 조언 → 격려 순서로 구성
4. 절대 부정적이거나 불길한 말 금지
5. 구체적인 예측보다 실용적인 조언과 격려 중심
6. 이모지를 적절히 사용해 친근함 표현
7. 비유나 예시를 들어 이해하기 쉽게 설명

## 사용자 정보 활용 규칙
1. [사용자 정보]가 제공되면 자연스럽게 답변에 반영
2. 띠/별자리가 있으면 운세 관련 인사이트를 녹여서 답변
3. MBTI가 있으면 성격 유형에 맞는 맞춤형 조언 제공
4. 나이가 있으면 연령대에 맞는 공감과 조언 제공
5. 정보가 없는 필드는 언급하지 않음
6. 정보를 억지로 사용하지 말고, 질문과 자연스럽게 연결될 때만 활용
7. 사용자 정보를 직접적으로 나열하지 말고 답변에 녹여서 표현

## 답변 구조
1. 먼저 사용자의 감정/상황에 공감 표현
2. 상황에 대한 이해와 통찰 제공 (사용자 정보 활용)
3. 구체적이고 실용적인 조언 1-2가지
4. 따뜻한 격려와 응원으로 마무리

## 예시 (사용자 정보 활용)
[사용자: 민지 | 띠: 말띠 | 별자리: 황소자리]
질문: "오늘 좋은 일 있을까?"
답변: "민지야! 오늘 뭔가 기대되는 마음이 있구나 ☺️ 좋은 일을 기대하는 마음 자체가 벌써 긍정적인 에너지를 끌어당기고 있어!

황소자리답게 착실하게 하루를 보내다 보면, 오후쯤 작은 기쁨이 찾아올 수 있어. 말띠의 활기찬 기운도 함께하니까 적극적으로 움직여봐!

오늘 하루 '좋은 일이 생길 거야'라고 마음먹고 지내봐. 그 긍정적인 기운이 분명 좋은 걸 끌어당길 거야 🍀✨"

⚠️ 중요: 위 예시의 "민지"는 예시일 뿐입니다. 실제 답변에서는 반드시 사용자 정보에 제공된 실제 이름을 사용하세요.`

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  const startTime = Date.now()
  const requestId = req.headers.get('x-request-id') || crypto.randomUUID()

  try {
    const { message, context }: FreeChatRequest = await req.json()

    // 유효성 검사
    if (!message || typeof message !== 'string' || message.trim().length < 1) {
      return new Response(
        JSON.stringify({
          success: false,
          response: '',
          meta: {
            provider: 'gemini',
            model: FREE_CHAT_MODEL,
            latencyMs: Date.now() - startTime,
            requestId,
          },
          error: '메시지를 입력해주세요',
        } as FreeChatResponse),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // LLM 호출
    const llm = LLMFactory.createFromConfig('free-chat')

    // 지능형 컨텍스트 생성
    const contextPrompt = buildContextPrompt(message, context)
    const userPrompt = contextPrompt + message.trim()

    const response = await llm.generate([
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: userPrompt },
    ], {
      temperature: 0.8,
      maxTokens: 1024,
    })

    const latencyMs = Date.now() - startTime

    await UsageLogger.log({
      fortuneType: 'free-chat',
      requestId,
      provider: response.provider,
      model: response.model,
      response,
      metadata: {
        messageLength: message.trim().length,
        hasContext: Boolean(context),
      },
    })

    return new Response(
      JSON.stringify({
        success: true,
        response: response.content.trim(),
        meta: {
          provider: 'gemini',
          model: response.model,
          latencyMs,
          requestId,
        },
      } as FreeChatResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('free-chat 에러:', error)

    await UsageLogger.logError(
      'free-chat',
      'gemini',
      FREE_CHAT_MODEL,
      error instanceof Error ? error.message : 'Unknown error',
      undefined,
      { requestId, latencyMs: Date.now() - startTime }
    )

    return new Response(
      JSON.stringify({
        success: false,
        response: '',
        error: error instanceof Error ? error.message : 'Unknown error',
        meta: {
          provider: 'gemini',
          model: FREE_CHAT_MODEL,
          latencyMs: Date.now() - startTime,
          requestId,
        },
      } as FreeChatResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
