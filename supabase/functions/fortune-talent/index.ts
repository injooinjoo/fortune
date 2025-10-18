import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
    const { talentArea, currentSkills, goals, experience, timeAvailable, challenges, userId } = requestData

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

위 정보를 바탕으로 재능 개발 운세를 분석하고, 구체적인 주간 실행 계획을 제공해주세요. 현실적이면서도 동기부여가 되는 조언을 부탁드립니다.`
            }
          ],
          response_format: { type: "json_object" },
          temperature: 0.8,
          max_tokens: 2500
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
      id: `talent-${Date.now()}`,
      type: 'talent',
      userId: userId,
      talentArea: talentArea,
      goals: goals,
      ...fortuneData,
      overall_score: fortuneData.overallScore,
      lucky_items: fortuneData.luckyItems,
      created_at: new Date().toISOString(),
      metadata: {
        currentSkills,
        experience,
        timeAvailable,
        challenges
      }
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
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in fortune-talent:', error)

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
