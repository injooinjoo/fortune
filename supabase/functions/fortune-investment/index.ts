import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface InvestmentRequest {
  investmentType: 'stock' | 'crypto' | 'real_estate' | 'startup' | 'fund';
  targetName: string;
  amount: number;
  timeframe: string; // '단기 (1개월 이내)', '중기 (3-6개월)', '장기 (1년 이상)'
  riskTolerance: 'conservative' | 'moderate' | 'aggressive';
  purpose: string; // '수익 창출', '자산 증식', '노후 대비' 등
  experience: 'beginner' | 'intermediate' | 'expert';
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

    const requestData: InvestmentRequest = await req.json()
    const {
      investmentType,
      targetName,
      amount,
      timeframe,
      riskTolerance,
      purpose,
      experience,
      userId,
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    console.log('💎 [Investment] Premium 상태:', isPremium)

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_investment_${today}_${JSON.stringify({investmentType, targetName})}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'investment')
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
    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('investment')

    const systemPrompt = `당신은 투자 운세 전문가입니다. 사용자의 투자 계획을 분석하여 운세와 실용적인 조언을 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (투자 운세 점수),
  "content": "투자 운세 분석 (300자 내외, 현재 시장 상황과 투자자 상태를 고려한 종합 분석)",
  "description": "상세 분석 (500자 내외, 투자 시점, 목표가, 위험 요소 등)",
  "luckyItems": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "timing": "최적 투자 시점"
  },
  "hexagonScores": {
    "timing": 0-100 (투자 타이밍 점수),
    "value": 0-100 (가치 평가 점수),
    "risk": 0-100 (리스크 관리 점수),
    "trend": 0-100 (시장 트렌드 점수),
    "emotion": 0-100 (감정 통제 점수),
    "knowledge": 0-100 (정보력 점수)
  },
  "recommendations": [
    "긍정적인 추천 사항 3가지"
  ],
  "warnings": [
    "주의해야 할 사항 3가지"
  ],
  "advice": "종합 투자 조언 (200자 내외)"
}`

    const userPrompt = `투자 유형: ${investmentType}
대상: ${targetName}
투자 금액: ${amount.toLocaleString()}원
투자 기간: ${timeframe}
위험 감수도: ${riskTolerance}
투자 목적: ${purpose}
경험 수준: ${experience}
오늘 날짜: ${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

위 정보를 바탕으로 투자 운세를 JSON 형식으로 분석해주세요. 긍정적이면서도 현실적인 조언을 제공하고, 구체적인 실행 가이드를 포함해주세요.`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
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
      ? ['description', 'hexagonScores', 'recommendations', 'warnings', 'advice']
      : []

    const result = {
      id: `investment-${Date.now()}`,
      type: 'investment',
      userId: userId,
      targetName: targetName,
      investmentType: investmentType,
      amount: amount,
      overallScore: fortuneData.overallScore, // ✅ 무료: 공개
      overall_score: fortuneData.overallScore, // ✅ 무료: 공개
      content: fortuneData.content, // ✅ 무료: 공개 (종합 분석)
      description: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.description, // 🔒 유료
      luckyItems: fortuneData.luckyItems, // ✅ 무료: 공개
      lucky_items: fortuneData.luckyItems, // ✅ 무료: 공개
      hexagonScores: isBlurred ? {
        timing: 0,
        value: 0,
        risk: 0,
        trend: 0,
        emotion: 0,
        knowledge: 0
      } : fortuneData.hexagonScores, // 🔒 유료
      recommendations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.recommendations, // 🔒 유료
      warnings: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.warnings, // 🔒 유료
      advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.advice, // 🔒 유료
      created_at: new Date().toISOString(),
      metadata: {
        timeframe,
        riskTolerance,
        purpose,
        experience
      },
      isBlurred, // ✅ 블러 상태
      blurredSections // ✅ 블러된 섹션 목록
    }

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'investment',
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
    console.error('Error in fortune-investment:', error)

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
