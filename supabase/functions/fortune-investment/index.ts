import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
    const { investmentType, targetName, amount, timeframe, riskTolerance, purpose, experience, userId } = requestData

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
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // OpenAI API 호출
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000)

    let openaiResponse
    try {
      openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-5-nano-2025-08-07',
          messages: [
            {
              role: 'system',
              content: `당신은 투자 운세 전문가입니다. 사용자의 투자 계획을 분석하여 운세와 실용적인 조언을 제공합니다.

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
            },
            {
              role: 'user',
              content: `투자 유형: ${investmentType}
대상: ${targetName}
투자 금액: ${amount.toLocaleString()}원
투자 기간: ${timeframe}
위험 감수도: ${riskTolerance}
투자 목적: ${purpose}
경험 수준: ${experience}
오늘 날짜: ${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

위 정보를 바탕으로 투자 운세를 분석해주세요. 긍정적이면서도 현실적인 조언을 제공하고, 구체적인 실행 가이드를 포함해주세요.`
            }
          ],
          response_format: { type: "json_object" },
          temperature: 0.7,
          max_tokens: 2000
        }),
        signal: controller.signal
      })
    } catch (fetchError) {
      clearTimeout(timeoutId)
      console.error('OpenAI API fetch error:', fetchError)
      throw new Error(`OpenAI API 연결 실패: ${fetchError.message}`)
    } finally {
      clearTimeout(timeoutId)
    }

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text()
      console.error('OpenAI API error response:', errorText)
      throw new Error(`OpenAI API 오류 (${openaiResponse.status}): ${errorText}`)
    }

    const openaiResult = await openaiResponse.json()
    const fortuneData = JSON.parse(openaiResult.choices[0].message.content)

    const result = {
      id: `investment-${Date.now()}`,
      type: 'investment',
      userId: userId,
      targetName: targetName,
      investmentType: investmentType,
      amount: amount,
      ...fortuneData,
      overall_score: fortuneData.overallScore,
      lucky_items: fortuneData.luckyItems,
      created_at: new Date().toISOString(),
      metadata: {
        timeframe,
        riskTolerance,
        purpose,
        experience
      }
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
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in fortune-investment:', error)

    return new Response(
      JSON.stringify({
        error: error.message,
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
