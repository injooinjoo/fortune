/**
 * 혈액형 운세 (Blood Type Fortune) Edge Function
 *
 * @description 사용자의 혈액형을 기반으로 AI 기반 성격 분석, 오늘의 운세, 궁합을 생성합니다.
 *
 * @endpoint POST /fortune-blood-type
 *
 * @requestBody
 * - userId?: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - bloodType / blood_type: string - 혈액형 (A/B/O/AB)
 * - birthDate / birth_date?: string - 생년월일 (YYYY-MM-DD)
 *
 * @response { success: true, data: BloodTypeFortuneData }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/* ------------------------------------------------------------------ */
/*  혈액형 카탈로그                                                      */
/* ------------------------------------------------------------------ */

const BLOOD_TYPE_TRAITS: Record<string, { label: string; keyword: string; element: string }> = {
  A: { label: 'A형', keyword: '성실과 배려', element: '흙(土)' },
  B: { label: 'B형', keyword: '자유와 열정', element: '바람(風)' },
  O: { label: 'O형', keyword: '리더십과 결단', element: '불(火)' },
  AB: { label: 'AB형', keyword: '직관과 균형', element: '물(水)' },
}

/* ------------------------------------------------------------------ */
/*  LLM prompt builder                                                 */
/* ------------------------------------------------------------------ */

function buildPrompt(bloodType: string, name: string): string {
  const traits = BLOOD_TYPE_TRAITS[bloodType] ?? BLOOD_TYPE_TRAITS['A']
  const today = new Date(
    new Date().toLocaleString('en-US', { timeZone: 'Asia/Seoul' }),
  )
  const dateStr = `${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일`
  const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]

  return `당신은 혈액형 성격학과 운세 전문가입니다.
오늘은 ${dateStr} ${dayOfWeek}요일입니다.
사용자 이름: ${name}
사용자 혈액형: ${traits.label} (핵심 기질: ${traits.keyword}, 기운: ${traits.element})

아래 JSON 형식으로 오늘의 혈액형 운세를 작성해주세요. 반드시 JSON만 출력하세요.

{
  "overall_score": (1-100 정수),
  "summary": "(${traits.label} 오늘의 운세 요약 2-3문장)",
  "advice": "(핵심 조언 1문장)",
  "personality_analysis": {
    "core_trait": "(${traits.label}의 핵심 성격 특성 1-2문장)",
    "strengths": ["(강점1)", "(강점2)", "(강점3)"],
    "watch_out": "(오늘 주의할 점 1문장)",
    "mood_keyword": "(오늘의 감정 키워드 한 단어)"
  },
  "daily_fortune": {
    "love": { "score": (1-100), "description": "(연애운 1-2문장)" },
    "work": { "score": (1-100), "description": "(직장운 1-2문장)" },
    "money": { "score": (1-100), "description": "(재물운 1-2문장)" },
    "health": { "score": (1-100), "description": "(건강운 1-2문장)" }
  },
  "compatibility": {
    "best_match": "(오늘 가장 잘 맞는 혈액형, 예: O형)",
    "best_reason": "(잘 맞는 이유 1문장)",
    "caution_match": "(오늘 주의할 혈액형, 예: B형)",
    "caution_reason": "(주의 이유 1문장)"
  },
  "lucky": {
    "color": "(행운의 색상)",
    "number": "(행운의 숫자)",
    "time": "(행운의 시간대)",
    "item": "(행운의 아이템)"
  },
  "highlights": [
    "(핵심 인사이트 1)",
    "(핵심 인사이트 2)",
    "(핵심 인사이트 3)"
  ],
  "special_note": "(${traits.label}만을 위한 특별 메시지 1-2문장)"
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
          fortuneType: 'blood-type',
          timestamp: new Date().toISOString(),
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 200,
        },
      )
    }

    const bloodType = request.bloodType || request.blood_type
    const rawName = request.name
    const invalidNames = ['undefined', 'null', 'Unknown', '']
    const name = rawName && !invalidNames.includes(rawName) ? rawName : '회원님'

    if (!bloodType || !['A', 'B', 'O', 'AB'].includes(bloodType)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '유효한 혈액형(A/B/O/AB)이 필요합니다.',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400,
        },
      )
    }

    const traits = BLOOD_TYPE_TRAITS[bloodType] ?? BLOOD_TYPE_TRAITS['A']
    console.log(`🩸 [blood-type] ${name} → ${traits.label} (${traits.keyword})`)

    // LLM 호출
    const llm = LLMFactory.createFromConfig('blood-type')
    const prompt = buildPrompt(bloodType, name)

    const llmResponse = await llm.generate([
      { role: 'system', content: '당신은 혈액형 성격학과 운세 전문가입니다. 반드시 유효한 JSON만 출력하세요.' },
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
      console.error('[blood-type] JSON 파싱 실패:', llmResponse.content.slice(0, 200))
      fortune = buildFallbackFortune(bloodType, name)
    }

    const score = Number(fortune.overall_score) || 75
    const personality = fortune.personality_analysis as {
      core_trait?: string
      strengths?: string[]
      watch_out?: string
      mood_keyword?: string
    } ?? {}
    const dailyFortune = fortune.daily_fortune as Record<string, { score: number; description: string }> ?? {}
    const compatibility = fortune.compatibility as {
      best_match?: string
      best_reason?: string
      caution_match?: string
      caution_reason?: string
    } ?? {}
    const lucky = fortune.lucky as Record<string, string> ?? {}

    const data = {
      fortuneType: 'blood-type' as const,
      score,
      content: `${traits.label} ${name}님의 오늘의 혈액형 운세입니다. ${fortune.summary || ''}`,
      summary: (fortune.summary as string) || `${traits.label}의 기질과 오늘의 에너지가 만나 흐름이 보입니다.`,
      advice: (fortune.advice as string) || '오늘의 흐름을 잘 읽고 기질에 맞는 선택을 하세요.',
      timestamp: new Date().toISOString(),

      // blood type info
      bloodType,
      bloodTypeLabel: traits.label,
      bloodTypeKeyword: traits.keyword,
      bloodTypeElement: traits.element,

      // personality analysis
      personalityAnalysis: {
        coreTrait: personality.core_trait ?? `${traits.label}의 핵심은 ${traits.keyword}입니다.`,
        strengths: personality.strengths ?? ['꼼꼼함', '배려심', '책임감'],
        watchOut: personality.watch_out ?? '완벽주의에 지치지 않도록 주의하세요.',
        moodKeyword: personality.mood_keyword ?? '차분',
      },

      // daily fortune categories
      categories: {
        love: { score: dailyFortune.love?.score ?? 72, description: dailyFortune.love?.description ?? '관계에서 여유를 가지면 좋습니다.' },
        work: { score: dailyFortune.work?.score ?? 78, description: dailyFortune.work?.description ?? '집중력이 높은 하루입니다.' },
        money: { score: dailyFortune.money?.score ?? 68, description: dailyFortune.money?.description ?? '충동적 지출을 조심하세요.' },
        health: { score: dailyFortune.health?.score ?? 74, description: dailyFortune.health?.description ?? '적당한 휴식이 필요합니다.' },
      },

      // compatibility
      compatibility: {
        bestMatch: compatibility.best_match ?? 'O형',
        bestReason: compatibility.best_reason ?? '서로 부족한 부분을 채워줄 수 있는 관계입니다.',
        cautionMatch: compatibility.caution_match ?? 'B형',
        cautionReason: compatibility.caution_reason ?? '의견 충돌이 생길 수 있으니 여유를 가지세요.',
      },

      // lucky items
      luckyItems: {
        color: lucky.color ?? '하늘색',
        number: lucky.number ?? '3',
        time: lucky.time ?? '오후 2시',
        item: lucky.item ?? '손수건',
      },

      highlights: (fortune.highlights as string[]) ?? [
        '오늘은 직감을 믿어보세요.',
        '가까운 사람에게 먼저 연락하면 좋은 기운이 옵니다.',
        '새로운 시도보다 익숙한 루틴이 더 안정적입니다.',
      ],

      specialNote: (fortune.special_note as string) ?? `${traits.label}의 특별한 하루가 될 것입니다.`,

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
    console.error('Error in fortune-blood-type:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: '혈액형 운세 생성 중 오류가 발생했습니다.',
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
  bloodType: string,
  name: string,
): Record<string, unknown> {
  const traits = BLOOD_TYPE_TRAITS[bloodType] ?? BLOOD_TYPE_TRAITS['A']

  const fallbacks: Record<string, Record<string, unknown>> = {
    A: {
      overall_score: 76,
      summary: `${traits.label} ${name}님, 오늘은 꼼꼼함이 빛나는 하루입니다. 계획대로 움직이되 유연함도 챙기세요.`,
      advice: '완벽하지 않아도 괜찮습니다. 80%의 완성도로 먼저 시작하세요.',
      personality_analysis: {
        core_trait: 'A형은 세심하고 책임감이 강하며, 다른 사람의 감정에 민감합니다.',
        strengths: ['꼼꼼함', '배려심', '계획성'],
        watch_out: '너무 완벽하려 하지 마세요.',
        mood_keyword: '신중',
      },
      daily_fortune: {
        love: { score: 74, description: '상대의 작은 배려에 감동받는 하루입니다.' },
        work: { score: 80, description: '디테일을 잡는 능력이 빛납니다.' },
        money: { score: 68, description: '계획에 없는 지출은 피하세요.' },
        health: { score: 72, description: '긴장을 풀어주는 스트레칭이 좋습니다.' },
      },
      compatibility: {
        best_match: 'O형',
        best_reason: 'O형의 대범함이 A형의 긴장을 풀어줍니다.',
        caution_match: 'B형',
        caution_reason: 'B형의 자유로움이 오늘은 부담이 될 수 있습니다.',
      },
      lucky: { color: '하늘색', number: '3', time: '오후 2시', item: '손수건' },
      highlights: [
        '오늘은 계획대로 움직이면 좋은 결과가 나옵니다.',
        '가까운 사람에게 감사를 표현해보세요.',
        '저녁에 혼자만의 시간이 에너지를 충전시켜줍니다.',
      ],
      special_note: 'A형의 성실함이 주변에 좋은 영향을 주는 날입니다.',
    },
    B: {
      overall_score: 78,
      summary: `${traits.label} ${name}님, 오늘은 직관이 빛나는 하루입니다. 감각을 믿고 행동하세요.`,
      advice: '호기심이 가는 방향으로 가되, 마무리까지 의식하세요.',
      personality_analysis: {
        core_trait: 'B형은 자유롭고 창의적이며, 관심 분야에 놀라운 집중력을 보입니다.',
        strengths: ['창의력', '적응력', '솔직함'],
        watch_out: '한 가지에 너무 몰입하면 주변이 보이지 않을 수 있습니다.',
        mood_keyword: '열정',
      },
      daily_fortune: {
        love: { score: 76, description: '솔직한 감정 표현이 관계를 깊게 만듭니다.' },
        work: { score: 72, description: '새로운 아이디어가 떠오르는 시간이 있습니다.' },
        money: { score: 70, description: '충동 구매보다 리스트를 먼저 만드세요.' },
        health: { score: 80, description: '활동적인 시간을 가지면 컨디션이 올라갑니다.' },
      },
      compatibility: {
        best_match: 'AB형',
        best_reason: 'AB형의 균형감이 B형의 에너지와 잘 어울립니다.',
        caution_match: 'A형',
        caution_reason: 'A형의 꼼꼼함이 오늘은 답답하게 느껴질 수 있습니다.',
      },
      lucky: { color: '주황색', number: '7', time: '오전 11시', item: '이어폰' },
      highlights: [
        '오늘은 새로운 시도가 좋은 결과를 가져옵니다.',
        '감각적인 선택이 이성적인 분석보다 나을 수 있습니다.',
        '오후에 예상치 못한 좋은 소식이 올 수 있습니다.',
      ],
      special_note: 'B형의 자유로운 에너지가 주변을 환하게 만드는 날입니다.',
    },
    O: {
      overall_score: 80,
      summary: `${traits.label} ${name}님, 오늘은 리더십이 빛나는 하루입니다. 결단력 있게 앞으로 나아가세요.`,
      advice: '주변의 의견도 듣되, 최종 결정은 자신의 직감을 믿으세요.',
      personality_analysis: {
        core_trait: 'O형은 결단력과 추진력이 강하며, 목표 지향적입니다.',
        strengths: ['리더십', '결단력', '낙관적'],
        watch_out: '독단적으로 보이지 않도록 소통에 신경 쓰세요.',
        mood_keyword: '자신감',
      },
      daily_fortune: {
        love: { score: 78, description: '적극적인 모습이 매력으로 느껴지는 날입니다.' },
        work: { score: 82, description: '추진하던 일에 진전이 있습니다.' },
        money: { score: 74, description: '투자보다 저축을 우선하면 안정적입니다.' },
        health: { score: 76, description: '체력이 좋은 날, 운동하기 좋습니다.' },
      },
      compatibility: {
        best_match: 'A형',
        best_reason: 'A형의 세심함이 O형의 추진력을 보완해줍니다.',
        caution_match: 'O형',
        caution_reason: '같은 O형끼리는 주도권 경쟁이 생길 수 있습니다.',
      },
      lucky: { color: '빨간색', number: '1', time: '오전 9시', item: '시계' },
      highlights: [
        '오늘은 먼저 행동하는 사람이 유리합니다.',
        '팀에서 주도적인 역할을 맡으면 좋습니다.',
        '저녁에는 긴장을 풀고 재충전하세요.',
      ],
      special_note: 'O형의 에너지가 최고조에 이르는 날입니다. 큰 결정을 내리기 좋습니다.',
    },
    AB: {
      overall_score: 74,
      summary: `${traits.label} ${name}님, 오늘은 직관과 분석이 조화를 이루는 하루입니다. 양면을 잘 활용하세요.`,
      advice: '복잡하게 생각하기보다 핵심만 잡으세요.',
      personality_analysis: {
        core_trait: 'AB형은 이성과 감성을 동시에 활용하며, 독특한 관점을 가지고 있습니다.',
        strengths: ['분석력', '균형감', '독창성'],
        watch_out: '결정을 미루지 말고, 적당한 시점에서 마무리하세요.',
        mood_keyword: '균형',
      },
      daily_fortune: {
        love: { score: 70, description: '감정을 솔직하게 표현하면 관계가 깊어집니다.' },
        work: { score: 76, description: '독창적인 아이디어가 인정받는 시간입니다.' },
        money: { score: 72, description: '균형 잡힌 소비 습관이 중요합니다.' },
        health: { score: 74, description: '충분한 수면이 내일의 컨디션을 좌우합니다.' },
      },
      compatibility: {
        best_match: 'B형',
        best_reason: 'B형의 열정이 AB형에게 활력을 불어넣어줍니다.',
        caution_match: 'O형',
        caution_reason: 'O형의 직선적인 방식이 오늘은 부담이 될 수 있습니다.',
      },
      lucky: { color: '보라색', number: '4', time: '오후 4시', item: '노트' },
      highlights: [
        '오늘은 관찰력이 뛰어난 날입니다.',
        '양쪽 의견을 조율하는 역할이 빛납니다.',
        '밤 시간에 좋은 아이디어가 떠오를 수 있습니다.',
      ],
      special_note: 'AB형의 독특한 감각이 주변에 신선한 에너지를 전하는 날입니다.',
    },
  }

  return fallbacks[bloodType] ?? fallbacks['A']
}
