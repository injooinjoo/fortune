import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface TalentRequest {
  talentArea: string; // '예술', '스포츠', '학문', '비즈니스', '기술' 등
  currentSkills: string[]; // 현재 보유 스킬 목록
  goals: string; // 목표
  experience: string; // 경험 수준
  timeAvailable: string; // 투자 가능한 시간
  challenges: string[]; // 현재 직면한 어려움
  userId?: string;
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData: TalentRequest = await req.json()
    const {
      talentArea,
      currentSkills,
      goals,
      experience,
      timeAvailable,
      challenges,
      userId,
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    console.log('💎 [Talent] Premium 상태:', isPremium)

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_talent_${today}_${JSON.stringify({talentArea, goals})}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'talent')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          fortune: cachedResult.result,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // OpenAI API 호출
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000)

    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('talent')

    const response = await llm.generate([
      {
        role: 'system',
        content: `당신은 재능 발견 및 개발 전문가입니다. 사용자의 현재 상태와 목표를 분석하여 재능 개발 운세와 구체적인 실행 계획을 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (재능 개발 운세 점수),
  "content": "재능 분석 (300자 내외, 현재 상태와 잠재력 분석)",
  "description": "상세 분석 (500자 내외, 강점, 약점, 개선 방향)",
  "luckyItems": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "집중해야 할 방향",
    "tool": "도움이 될 도구나 리소스"
  },
  "hexagonScores": {
    "creativity": 0-100 (창의성 점수),
    "technique": 0-100 (기술력 점수),
    "passion": 0-100 (열정 점수),
    "discipline": 0-100 (훈련 점수),
    "uniqueness": 0-100 (독창성 점수),
    "marketValue": 0-100 (시장 가치 점수)
  },
  "talentInsights": [
    {
      "talent": "발견된 재능명",
      "potential": 0-100 (잠재력 점수),
      "description": "재능 설명",
      "developmentPath": "개발 방법"
    }
  ],
  "weeklyPlan": [
    {
      "day": "월요일",
      "focus": "집중 영역",
      "activities": ["활동 1", "활동 2"],
      "timeNeeded": "필요 시간"
    }
  ],
  "recommendations": [
    "실행 가능한 추천 사항 3-5가지"
  ],
  "warnings": [
    "주의해야 할 함정 3가지"
  ],
  "advice": "종합 조언 (200자 내외, 동기부여와 실용적 팁)"
}`
      },
      {
        role: 'user',
        content: `재능 분야: ${talentArea}
현재 스킬: ${currentSkills.join(', ')}
목표: ${goals}
경험 수준: ${experience}
가능 시간: ${timeAvailable}
어려움: ${challenges.join(', ')}
오늘 날짜: ${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

위 정보를 바탕으로 재능 개발 운세를 JSON 형식으로 분석하고, 구체적인 주간 실행 계획을 제공해주세요. 현실적이면서도 동기부여가 되는 조언을 부탁드립니다.`
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['description', 'hexagonScores', 'talentInsights', 'weeklyPlan', 'recommendations', 'warnings', 'advice']
      : []

    const result = {
      id: `talent-${Date.now()}`,
      type: 'talent',
      userId: userId,
      talentArea: talentArea,
      goals: goals,
      overallScore: fortuneData.overallScore, // ✅ 무료: 공개
      overall_score: fortuneData.overallScore, // ✅ 무료: 공개
      content: fortuneData.content, // ✅ 무료: 공개 (재능 분석)
      description: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.description, // 🔒 유료
      luckyItems: fortuneData.luckyItems, // ✅ 무료: 공개
      lucky_items: fortuneData.luckyItems, // ✅ 무료: 공개
      hexagonScores: isBlurred ? {
        creativity: 0,
        technique: 0,
        passion: 0,
        discipline: 0,
        uniqueness: 0,
        marketValue: 0
      } : fortuneData.hexagonScores, // 🔒 유료
      talentInsights: isBlurred ? [{
        talent: '🔒 프리미엄 전용',
        potential: 0,
        description: '🔒 프리미엄 결제 후 확인 가능합니다',
        developmentPath: '🔒 프리미엄 결제 후 확인 가능합니다'
      }] : fortuneData.talentInsights, // 🔒 유료
      weeklyPlan: isBlurred ? [{
        day: '🔒',
        focus: '🔒 프리미엄 전용',
        activities: ['🔒 프리미엄 결제 후 확인 가능합니다'],
        timeNeeded: '🔒'
      }] : fortuneData.weeklyPlan, // 🔒 유료
      recommendations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.recommendations, // 🔒 유료
      warnings: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.warnings, // 🔒 유료
      advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.advice, // 🔒 유료
      created_at: new Date().toISOString(),
      metadata: {
        currentSkills,
        experience,
        timeAvailable,
        challenges
      },
      isBlurred, // ✅ 블러 상태
      blurredSections // ✅ 블러된 섹션 목록
    }

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'talent',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        fortune: result,
        cached: false,
        tokensUsed: openaiResult.usage?.total_tokens || 0
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('Error in fortune-talent:', error)

    return new Response(
      JSON.stringify({
        error: error.message,
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
