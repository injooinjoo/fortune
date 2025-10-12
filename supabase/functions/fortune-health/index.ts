import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import OpenAI from 'https://esm.sh/openai@4.28.0'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
const openaiApiKey = Deno.env.get('OPENAI_API_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)
const openai = new OpenAI({ apiKey: openaiApiKey })

interface HealthFortuneRequest {
  fortune_type?: string
  current_condition: string
  concerned_body_parts: string[]
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const requestData: HealthFortuneRequest = await req.json()
    const { current_condition = '', concerned_body_parts = [] } = requestData

    if (!current_condition) {
      throw new Error('현재 건강 상태를 입력해주세요.')
    }

    console.log('Health fortune request:', { current_condition, concerned_body_parts })

    const cacheKey = `health_fortune_${Buffer.from(`${current_condition}_${concerned_body_parts.join(',')}`).toString('base64').slice(0, 50)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for health fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      const prompt = `당신은 한국의 전문 건강운세 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 건강 조언을 제공해주세요.

현재 건강 상태: "${current_condition}"
관심 부위: ${concerned_body_parts.join(', ')}

다음 정보를 포함하여 상세한 건강운을 제공해주세요:

1. 전반적인 건강운: 전체적인 건강 상태와 운
2. 부위별 건강: 관심 부위에 대한 건강 조언
3. 주의사항: 건강 관리 시 주의할 점 3가지
4. 추천 활동: 건강에 도움이 되는 활동 3가지
5. 식습관 조언: 건강에 좋은 식습관
6. 운동 조언: 추천하는 운동 방법
7. 건강 키워드: 건강운을 한 단어로 표현

긍정적이면서도 현실적인 관점으로 조언해주세요.`

      const completion = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: '당신은 한국의 전문 건강운세 전문가입니다. 항상 한국어로 응답하며, 실용적이고 긍정적인 조언을 제공합니다.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        response_format: { type: 'json_object' },
        temperature: 0.7,
        max_tokens: 2000,
      })

      const responseContent = completion.choices[0]?.message?.content
      if (!responseContent) throw new Error('OpenAI API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(responseContent)

      fortuneData = {
        title: '건강운',
        fortune_type: 'health',
        current_condition,
        concerned_body_parts,
        overall_health: parsedResponse.전반적인건강운 || parsedResponse.overall_health || '건강하십니다.',
        body_part_advice: parsedResponse.부위별건강 || parsedResponse.body_part_advice || '주의가 필요합니다.',
        cautions: parsedResponse.주의사항 || parsedResponse.cautions || ['규칙적 생활', '충분한 휴식', '정기 검진'],
        recommended_activities: parsedResponse.추천활동 || parsedResponse.recommended_activities || ['산책', '요가', '스트레칭'],
        diet_advice: parsedResponse.식습관조언 || parsedResponse.diet_advice || '균형잡힌 식사를 하세요.',
        exercise_advice: parsedResponse.운동조언 || parsedResponse.exercise_advice || '꾸준한 운동이 중요합니다.',
        health_keyword: parsedResponse.건강키워드 || parsedResponse.health_keyword || '건강',
        score: Math.floor(Math.random() * 30) + 70,
        timestamp: new Date().toISOString()
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'health',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })
    }

    return new Response(JSON.stringify({ success: true, data: fortuneData }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Health Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '건강운 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
