/**
 * 새해 운세 (New Year Fortune) Edge Function
 *
 * @description 사용자의 사주 정보와 새해 목표(희망사항)를 바탕으로 2026년 연간 운세를 생성합니다.
 *
 * @endpoint POST /fortune-new-year
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간 (예: "축시 (01:00 - 03:00)")
 * - gender: 'male' | 'female' - 성별
 * - zodiacSign?: string - 별자리
 * - zodiacAnimal?: string - 띠
 * - goal?: string - 새해 목표 ID (success, love, wealth, health, growth, travel, peace)
 * - goalLabel?: string - 새해 목표 레이블 (성공/성취, 사랑/만남 등)
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response NewYearFortuneResponse
 * - overall_score: number (1-100) - 종합 운세 점수
 * - summary: string - 새해 운세 요약
 * - content: string - 상세 내용
 * - greeting: string - 인사말
 * - goalFortune: object - 목표별 맞춤 운세
 * - monthlyHighlights: array - 월별 하이라이트
 * - luckyItems: object - 행운 요소
 * - recommendations: array - 추천 사항
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Goal 매핑 정보
const GOAL_MAPPING: Record<string, { label: string; emoji: string; focus: string }> = {
  'success': { label: '성공/성취', emoji: '🏆', focus: '커리어, 목표 달성, 성취감' },
  'love': { label: '사랑/만남', emoji: '💘', focus: '연애, 인연, 관계 발전' },
  'wealth': { label: '부자되기', emoji: '💎', focus: '재물, 투자, 경제적 안정' },
  'health': { label: '건강/운동', emoji: '🏃', focus: '건강 관리, 체력 증진, 활력' },
  'growth': { label: '자기계발', emoji: '📖', focus: '학습, 성장, 새로운 기술 습득' },
  'travel': { label: '여행/경험', emoji: '✈️', focus: '새로운 경험, 모험, 시야 확장' },
  'peace': { label: '마음의 평화', emoji: '🧘', focus: '정서적 안정, 스트레스 해소, 내면 성장' },
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData = await req.json()
    const {
      userId,
      name = '사용자',
      birthDate,
      birthTime,
      gender,
      isLunar = false,
      zodiacSign,
      zodiacAnimal,
      goal,
      goalLabel,
      isPremium = false
    } = requestData

    console.log('🎊 [NewYear] 요청 수신:', { userId, name, goal, goalLabel, isPremium })

    // 현재 연도 계산
    const currentYear = new Date().getFullYear()
    const targetYear = currentYear // 또는 currentYear + 1 (새해 직전이면)

    // Goal 정보 가져오기
    const goalInfo = goal ? GOAL_MAPPING[goal] : null
    const displayGoalLabel = goalLabel || goalInfo?.label || '새해 목표'
    const goalFocus = goalInfo?.focus || '전반적인 운세'
    const goalEmoji = goalInfo?.emoji || '🎊'

    // LLM 모듈 생성
    const llm = await LLMFactory.createFromConfigAsync('fortune-new-year')

    // 시스템 프롬프트
    const systemPrompt = `당신은 한국 전통 역학(易學)과 현대 운세를 결합한 새해 인사이트 전문가입니다.
사용자의 사주(四柱)와 새해 목표를 분석하여 ${targetYear}년 연간 인사이트를 제공합니다.

**핵심 원칙**:
1. 사용자가 선택한 **새해 목표/희망사항**을 중심으로 분석
2. 목표 달성을 위한 구체적이고 실용적인 조언 제공
3. 월별 중요 시기와 행운의 시기 안내
4. 긍정적이고 희망적인 메시지 전달
5. 친근하고 따뜻한 존댓말 사용

**응답 규칙**:
- 부드러운 존댓말 (~해보세요, ~거예요, ~좋아요)
- 한문/고어/딱딱한 표현 금지
- 적절한 이모지로 포인트 (✨💫🌟💪❤️ 등)
- 구체적이고 실행 가능한 조언 포함`

    // 사용자 프롬프트 - 목표 반영 + 오행 분석 추가
    const userPrompt = `다음 정보를 기반으로 ${targetYear}년 새해 인사이트를 분석해주세요:

**기본 정보**:
- 이름: ${name}
- 생년월일: ${birthDate}${isLunar ? ' (음력)' : ''}
${birthTime ? `- 출생 시간: ${birthTime}` : ''}
${gender ? `- 성별: ${gender === 'male' ? '남성' : '여성'}` : ''}
${zodiacAnimal ? `- 띠: ${zodiacAnimal}` : ''}
${zodiacSign ? `- 별자리: ${zodiacSign}` : ''}

**🎯 새해 목표/희망사항**: ${displayGoalLabel} ${goalEmoji}
- 관련 분야: ${goalFocus}

⚠️ 중요: 위 **새해 목표**를 중심으로 ${targetYear}년 운세를 분석해주세요!
사용자가 "${displayGoalLabel}"을 선택했으므로, 이 목표와 관련된 구체적인 조언과 예측을 반드시 포함해주세요.

**응답 형식** (반드시 JSON):
\`\`\`json
{
  "overallScore": ${targetYear}년 종합 점수 (60-95 사이),
  "summary": "${targetYear}년 한 줄 요약",
  "content": "상세 분석 내용",
  "greeting": "${name}님을 위한 인사말",

  "goalFortune": {
    "goalId": "${goal || 'general'}",
    "goalLabel": "${displayGoalLabel}",
    "emoji": "${goalEmoji}",
    "title": "${displayGoalLabel} 관련 ${targetYear}년 전망 제목",
    "prediction": "${displayGoalLabel}에 대한 구체적인 예측과 조언 (200자 이상)",
    "deepAnalysis": "${displayGoalLabel} 달성을 위한 심화 분석 - 심리학적/전략적 관점 (200자 이상)",
    "bestMonths": ["가장 좋은 월 (예: 3월)", "두번째 좋은 월", "세번째 좋은 월"],
    "cautionMonths": ["주의할 월 1", "주의할 월 2"],
    "quarterlyMilestones": ["1분기 목표/마일스톤", "2분기 목표/마일스톤", "3분기 목표/마일스톤", "4분기 목표/마일스톤"],
    "riskAnalysis": "${displayGoalLabel} 달성 시 주의해야 할 점과 예상되는 어려움 (100자 이상)",
    "successFactors": ["성공 요소 1", "성공 요소 2", "성공 요소 3"],
    "actionItems": [
      "${displayGoalLabel} 달성을 위한 구체적 행동 1 (50자 이상)",
      "${displayGoalLabel} 달성을 위한 구체적 행동 2 (50자 이상)",
      "${displayGoalLabel} 달성을 위한 구체적 행동 3 (50자 이상)"
    ]${goal === 'travel' ? `,
    "travelRecommendations": {
      "domestic": [
        {
          "city": "추천 국내 여행지 1 (예: 제주도, 부산, 경주 등)",
          "reason": "사주/오행 기반으로 이 도시가 좋은 이유 (100자 이상, 기운/에너지 관점)",
          "bestSeason": "추천 여행 시기 (예: 5월-7월, 봄철)"
        },
        {
          "city": "추천 국내 여행지 2",
          "reason": "사주 기반 추천 이유 (100자 이상)",
          "bestSeason": "추천 여행 시기"
        }
      ],
      "international": [
        {
          "city": "추천 해외 여행지 1 (예: 도쿄, 방콕, 파리 등)",
          "reason": "사주/오행 기반으로 이 도시가 좋은 이유 (100자 이상)",
          "bestSeason": "추천 여행 시기"
        },
        {
          "city": "추천 해외 여행지 2",
          "reason": "사주 기반 추천 이유 (100자 이상)",
          "bestSeason": "추천 여행 시기"
        }
      ],
      "travelStyle": "사용자의 사주에 어울리는 여행 스타일 (예: 휴양형, 모험형, 문화탐방형 등)",
      "travelTips": [
        "여행 시 도움이 될 팁 1 (사주 기반)",
        "여행 시 도움이 될 팁 2",
        "여행 시 도움이 될 팁 3"
      ]
    }` : ''}
  },

  "sajuAnalysis": {
    "dominantElement": "사용자의 주요 오행 (목/화/토/금/수 중 하나)",
    "yearElement": "${targetYear}년의 오행 기운",
    "compatibility": "높음/보통/주의 중 하나",
    "compatibilityReason": "왜 궁합이 좋은지/주의해야 하는지 설명 (100자 이상)",
    "elementalAdvice": "오행 기반 ${targetYear}년 조언 (150자 이상)",
    "balanceElements": ["보완해야 할 오행 1", "보완해야 할 오행 2"],
    "strengthenTips": ["오행 강화 방법 1", "오행 강화 방법 2", "오행 강화 방법 3"]
  },

  "monthlyHighlights": [
    {
      "month": "1월",
      "theme": "이달의 테마 (4-6자)",
      "score": 점수 (60-95),
      "advice": "이달 조언 (50자 이상)",
      "energyLevel": "High/Medium/Low 중 하나",
      "bestDays": ["5일", "15일", "25일"],
      "recommendedAction": "${displayGoalLabel} 관련 이달 추천 행동",
      "avoidAction": "이달 피해야 할 것"
    }
  ],

  "luckyItems": {
    "color": "행운의 색상",
    "number": "행운의 숫자",
    "direction": "행운의 방향",
    "item": "행운의 아이템",
    "food": "행운의 음식"
  },

  "actionPlan": {
    "immediate": ["1-2주 내 실천할 것 1 (50자 이상)", "1-2주 내 실천할 것 2 (50자 이상)"],
    "shortTerm": ["1-3개월 내 달성할 것 1 (50자 이상)", "1-3개월 내 달성할 것 2 (50자 이상)"],
    "longTerm": ["6-12개월 목표 1 (50자 이상)", "6-12개월 목표 2 (50자 이상)"]
  },

  "recommendations": [
    "${displayGoalLabel} 관련 구체적 추천 1 (50자 이상)",
    "${displayGoalLabel} 관련 구체적 추천 2 (50자 이상)",
    "${displayGoalLabel} 관련 구체적 추천 3 (50자 이상)"
  ],

  "specialMessage": "${targetYear}년을 맞이하는 ${name}님께 드리는 특별 메시지 (150자 이상, ${displayGoalLabel} 격려 포함)"
}
\`\`\`

**주의**:
- 반드시 유효한 JSON 형식으로만 응답하세요
- monthlyHighlights는 1월부터 12월까지 **12개 모두** 포함해주세요
- 모든 내용에 **${displayGoalLabel}** 목표를 반영해주세요
- 각 필드의 최소 글자수를 반드시 지켜주세요`

    console.log(`[fortune-new-year] 🔄 LLM 호출 시작... (goal: ${goal})`)

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`[fortune-new-year] ✅ LLM 응답 수신 (${response.latency}ms, ${response.usage?.totalTokens || 0} tokens)`)

    // LLM 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'new_year',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { name, birthDate, gender, zodiacAnimal, goal, goalLabel, isPremium }
    })

    // JSON 파싱
    let fortuneData: any
    try {
      fortuneData = typeof response.content === 'string'
        ? JSON.parse(response.content)
        : response.content
    } catch (parseError) {
      console.error(`[fortune-new-year] ❌ JSON 파싱 실패:`, parseError)
      throw new Error('LLM 응답을 파싱할 수 없습니다')
    }

    const overallScore = fortuneData.overallScore || 75

    // Blur 로직 (프리미엄 전용 섹션)
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['goalFortune', 'sajuAnalysis', 'actionPlan', 'recommendations', 'specialMessage']
      : []

    // 월별 운세: 1-3월 무료, 4-12월 프리미엄
    const freeMonths = [1, 2, 3]
    const blurredMonthIndices = isBlurred ? [3, 4, 5, 6, 7, 8, 9, 10, 11] : [] // 4-12월 (0-indexed: 3-11)

    // 운세 데이터 구성
    const fortune = {
      // 표준 필드
      id: `new_year_${userId}_${targetYear}`,
      userId: userId,
      type: 'new_year',
      fortuneType: 'new_year',

      // 점수 및 요약
      score: overallScore,
      overall_score: overallScore,
      overallScore: overallScore,
      summary: fortuneData.summary || '',
      content: fortuneData.content || '',
      greeting: fortuneData.greeting || `${name}님, ${targetYear}년 새해 복 많이 받으세요! 🎊`,
      advice: fortuneData.recommendations?.[0] || '',

      // 목표별 맞춤 운세 (핵심!)
      goalFortune: fortuneData.goalFortune || {
        goalId: goal || 'general',
        goalLabel: displayGoalLabel,
        emoji: goalEmoji,
        title: `${displayGoalLabel} 인사이트`,
        prediction: '',
        deepAnalysis: '',
        bestMonths: [],
        cautionMonths: [],
        quarterlyMilestones: [],
        riskAnalysis: '',
        successFactors: [],
        actionItems: []
      },

      // 사주 오행 분석 (NEW)
      sajuAnalysis: fortuneData.sajuAnalysis || {
        dominantElement: '',
        yearElement: '',
        compatibility: '보통',
        compatibilityReason: '',
        elementalAdvice: '',
        balanceElements: [],
        strengthenTips: []
      },

      // 월별 하이라이트
      monthlyHighlights: fortuneData.monthlyHighlights || [],

      // 행운 요소
      luckyItems: fortuneData.luckyItems || {
        color: '',
        number: '',
        direction: '',
        item: '',
        food: ''
      },
      lucky_items: fortuneData.luckyItems || {},

      // 추천 사항
      recommendations: fortuneData.recommendations || [],

      // 시간별 행동 계획 (NEW)
      actionPlan: fortuneData.actionPlan || {
        immediate: [],
        shortTerm: [],
        longTerm: []
      },

      // 특별 메시지
      specialMessage: fortuneData.specialMessage || '',

      // 메타데이터
      metadata: {
        year: targetYear,
        goal: goal,
        goalLabel: displayGoalLabel,
        generatedAt: new Date().toISOString()
      },

      // 블러 상태
      isBlurred,
      blurredSections,
      blurredMonthIndices, // 4-12월 블러 (0-indexed: 3-11)
      freeMonthCount: 3 // 무료 공개 월 수 (1-3월)
    }

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'new_year', overallScore)
    const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

    console.log(`[fortune-new-year] ✅ 응답 생성 완료 (score: ${overallScore}, goal: ${goal})`)

    return new Response(
      JSON.stringify({
        fortune: fortuneWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200
      }
    )

  } catch (error) {
    console.error('[fortune-new-year] ❌ Error:', error)

    return new Response(
      JSON.stringify({
        error: 'Failed to generate new year fortune',
        message: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
