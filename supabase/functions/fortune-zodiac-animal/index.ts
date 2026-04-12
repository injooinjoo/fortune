/**
 * 띠별 운세 (Zodiac Animal Fortune) Edge Function
 *
 * @description 사용자의 생년월일을 기반으로 12지신 띠별 운세를 생성합니다.
 *
 * @endpoint POST /fortune-zodiac-animal
 *
 * @requestBody
 * - userId?: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - birthDate?: string - 생년월일 (YYYY-MM-DD)
 * - birthMonth?: number - 생월
 * - birth_date?: string - 생년월일 (alias)
 * - birth_month?: number - 생월 (alias)
 * - isPremium?: boolean - 프리미엄 여부
 *
 * @response { success: true, data: ZodiacAnimalFortuneData }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/* ------------------------------------------------------------------ */
/*  12지신 카탈로그                                                     */
/* ------------------------------------------------------------------ */

const ZODIAC_ANIMALS = [
  { emoji: '🐭', name: '쥐', branch: '자', element: '수(水)' },
  { emoji: '🐄', name: '소', branch: '축', element: '토(土)' },
  { emoji: '🐯', name: '호랑이', branch: '인', element: '목(木)' },
  { emoji: '🐰', name: '토끼', branch: '묘', element: '목(木)' },
  { emoji: '🐉', name: '용', branch: '진', element: '토(土)' },
  { emoji: '🐍', name: '뱀', branch: '사', element: '화(火)' },
  { emoji: '🐴', name: '말', branch: '오', element: '화(火)' },
  { emoji: '🐑', name: '양', branch: '미', element: '토(土)' },
  { emoji: '🐵', name: '원숭이', branch: '신', element: '금(金)' },
  { emoji: '🐓', name: '닭', branch: '유', element: '금(金)' },
  { emoji: '🐶', name: '개', branch: '술', element: '토(土)' },
  { emoji: '🐷', name: '돼지', branch: '해', element: '수(水)' },
] as const

function deriveZodiacAnimal(year: number) {
  const index = ((year - 4) % 12 + 12) % 12
  return { ...ZODIAC_ANIMALS[index], index }
}

/* ------------------------------------------------------------------ */
/*  LLM prompt builder                                                 */
/* ------------------------------------------------------------------ */

function buildPrompt(animal: typeof ZODIAC_ANIMALS[number], name: string): string {
  const today = new Date(
    new Date().toLocaleString('en-US', { timeZone: 'Asia/Seoul' }),
  )
  const dateStr = `${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일`
  const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]

  return `당신은 동양 사주와 띠별 운세 전문가입니다.
오늘은 ${dateStr} ${dayOfWeek}요일입니다.
사용자 이름: ${name}
사용자의 띠: ${animal.emoji} ${animal.name}띠 (${animal.branch}, ${animal.element})

아래 JSON 형식으로 오늘의 띠별 운세를 작성해주세요. 반드시 JSON만 출력하세요.

{
  "overall_score": (1-100 정수),
  "summary": "(오늘의 띠별 운세 요약 2-3문장)",
  "advice": "(핵심 조언 1문장)",
  "categories": {
    "interpersonal": { "score": (1-100), "description": "(대인운 설명)" },
    "action": { "score": (1-100), "description": "(실행운 설명)" },
    "emotion": { "score": (1-100), "description": "(감정운 설명)" },
    "timing": { "score": (1-100), "description": "(타이밍운 설명)" }
  },
  "compatibility": {
    "best": ["(궁합이 좋은 띠 이름1)", "(궁합이 좋은 띠 이름2)"],
    "caution": ["(주의해야 할 띠 이름1)", "(주의해야 할 띠 이름2)"]
  },
  "lucky": {
    "time": "(행운의 시간대)",
    "color": "(행운의 색상)",
    "direction": "(행운의 방위)",
    "number": "(행운의 숫자)"
  },
  "highlights": [
    "(핵심 인사이트 1)",
    "(핵심 인사이트 2)",
    "(핵심 인사이트 3)"
  ],
  "timing_tip": "(오늘 타이밍 관련 팁 1-2문장)",
  "special_note": "(${animal.name}띠만을 위한 특별 메시지)"
}`
}

/* ------------------------------------------------------------------ */
/*  Handler                                                            */
/* ------------------------------------------------------------------ */

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const request = await req.json()

    // health check
    if (request.healthCheck === true) {
      return new Response(
        JSON.stringify({
          success: true,
          status: 'healthy',
          fortuneType: 'zodiac-animal',
          timestamp: new Date().toISOString(),
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 200,
        },
      )
    }

    // Parse birth year from birthDate or birth_date
    const birthDateStr = request.birthDate || request.birth_date
    const rawName = request.name
    const invalidNames = ['undefined', 'null', 'Unknown', '']
    const name = rawName && !invalidNames.includes(rawName) ? rawName : '회원님'

    if (!birthDateStr) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '생년월일(birthDate)이 필요합니다.',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400,
        },
      )
    }

    const birthYear = new Date(birthDateStr).getFullYear()
    if (Number.isNaN(birthYear)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '유효하지 않은 생년월일 형식입니다.',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400,
        },
      )
    }

    const animal = deriveZodiacAnimal(birthYear)
    console.log(`🐾 [zodiac-animal] ${name} → ${animal.emoji} ${animal.name}띠 (${birthYear}년생)`)

    // LLM 호출
    const llm = LLMFactory.createFromConfig('zodiac-animal')
    const prompt = buildPrompt(animal, name)

    const llmResponse = await llm.generate([
      { role: 'system', content: '당신은 동양 사주와 띠별 운세 전문가입니다. 반드시 유효한 JSON만 출력하세요.' },
      { role: 'user', content: prompt },
    ], {
      temperature: 0.8,
      maxTokens: 2000,
      jsonMode: true,
    })

    let fortune: Record<string, unknown>
    try {
      fortune = JSON.parse(llmResponse.content)
    } catch {
      console.error('[zodiac-animal] JSON 파싱 실패:', llmResponse.content.slice(0, 200))
      // fallback: 정적 데이터 반환
      fortune = buildFallbackFortune(animal, name)
    }

    const score = Number(fortune.overall_score) || 75
    const categories = fortune.categories as Record<string, { score: number; description: string }> ?? {}
    const compatibility = fortune.compatibility as { best?: string[]; caution?: string[] } ?? {}
    const lucky = fortune.lucky as Record<string, string> ?? {}

    const data = {
      fortuneType: 'zodiac-animal' as const,
      score,
      content: `${animal.emoji} ${animal.name}띠 ${name}님의 오늘의 운세입니다. ${fortune.summary || ''}`,
      summary: (fortune.summary as string) || `${animal.name}띠의 기질과 오늘의 운세가 겹치며 흐름이 보입니다.`,
      advice: (fortune.advice as string) || '오늘의 흐름을 잘 읽고 타이밍을 놓치지 마세요.',
      timestamp: new Date().toISOString(),

      // zodiac animal info
      zodiacAnimal: animal.name,
      zodiacEmoji: animal.emoji,
      zodiacBranch: animal.branch,
      zodiacElement: animal.element,
      birthYear,

      // categories
      categories: {
        interpersonal: { score: categories.interpersonal?.score ?? 75, description: categories.interpersonal?.description ?? '대인 관계가 원만합니다.' },
        action: { score: categories.action?.score ?? 70, description: categories.action?.description ?? '실행력이 좋은 하루입니다.' },
        emotion: { score: categories.emotion?.score ?? 72, description: categories.emotion?.description ?? '감정 조절이 중요합니다.' },
        timing: { score: categories.timing?.score ?? 78, description: categories.timing?.description ?? '타이밍을 잘 잡으면 좋습니다.' },
      },

      // compatibility
      compatibility: {
        best: compatibility.best ?? ['원숭이', '용'],
        caution: compatibility.caution ?? ['말', '토끼'],
      },

      // lucky items
      luckyItems: {
        time: lucky.time ?? '오후 2시',
        color: lucky.color ?? '파란색',
        direction: lucky.direction ?? '동쪽',
        number: lucky.number ?? '7',
      },

      highlights: (fortune.highlights as string[]) ?? [
        '오늘은 적극적인 자세가 행운을 부릅니다.',
        '주변 사람들의 조언에 귀 기울이세요.',
        '저녁 시간에 좋은 기운이 들어옵니다.',
      ],

      timingTip: (fortune.timing_tip as string) ?? '서두르지 말고 때를 기다리세요.',
      specialNote: (fortune.special_note as string) ?? `${animal.name}띠의 특별한 하루가 될 것입니다.`,

      name,
      userId: request.userId ?? null,
      isPremium: request.isPremium ?? false,

      // LLM usage metadata
      tokensUsed: llmResponse.usage?.totalTokens ?? 0,
      provider: llmResponse.provider ?? 'unknown',
    }

    return new Response(
      JSON.stringify({ success: true, data }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error in fortune-zodiac-animal:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: '띠별 운세 생성 중 오류가 발생했습니다.',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500,
      },
    )
  }
})

/* ------------------------------------------------------------------ */
/*  Fallback (LLM 실패 시)                                             */
/* ------------------------------------------------------------------ */

function buildFallbackFortune(
  animal: typeof ZODIAC_ANIMALS[number],
  name: string,
): Record<string, unknown> {
  return {
    overall_score: 75,
    summary: `${animal.name}띠 ${name}님, 오늘은 차분하게 주변을 살피며 기회를 잡는 하루입니다.`,
    advice: '급한 결정보다 한 발짝 물러서서 전체를 보는 눈이 필요합니다.',
    categories: {
      interpersonal: { score: 78, description: '사람 사이에서 존재감이 커집니다.' },
      action: { score: 72, description: '시작은 좋지만 마무리를 의식해야 합니다.' },
      emotion: { score: 68, description: '과한 해석은 피하는 게 좋습니다.' },
      timing: { score: 80, description: '한 번 더 기다리면 더 좋습니다.' },
    },
    compatibility: {
      best: ['원숭이', '용'],
      caution: ['말', '토끼'],
    },
    lucky: {
      time: '오후 3시',
      color: '연두색',
      direction: '남동쪽',
      number: '8',
    },
    highlights: [
      '오늘은 비슷한 속도의 사람보다, 나를 한 번 더 잡아주는 사람이 잘 맞습니다.',
      '대화가 빠르게 이어지는 상대와 궁합이 좋습니다.',
      '감정이 크게 출렁이는 상대와는 잠시 템포를 늦추세요.',
    ],
    timing_tip: '승부를 보려면 오전보다 오후가 더 낫습니다.',
    special_note: `${animal.name}띠의 꾸준한 에너지가 빛을 발하는 하루입니다.`,
  }
}
