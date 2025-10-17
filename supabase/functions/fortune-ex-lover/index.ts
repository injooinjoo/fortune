import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import OpenAI from 'https://esm.sh/openai@4.28.0'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
const openaiApiKey = Deno.env.get('OPENAI_API_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)
const openai = new OpenAI({ apiKey: openaiApiKey })

interface ExLoverFortuneRequest {
  fortune_type?: string
  name: string
  birth_date?: string
  gender?: string
  mbti?: string
  relationship_duration: string
  breakup_reason: string
  time_since_breakup?: string
  current_feeling?: string
  still_in_contact?: boolean
  has_unresolved_feelings?: boolean
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
    const requestData: ExLoverFortuneRequest = await req.json()
    const {
      name = '',
      relationship_duration = '',
      breakup_reason = '',
      time_since_breakup = '',
      current_feeling = '',
      still_in_contact = false
    } = requestData

    if (!name || !breakup_reason) {
      throw new Error('이름과 이별 이유를 입력해주세요.')
    }

    console.log('Ex-lover fortune request:', { name, relationship_duration })

    const cacheKey = `ex_lover_fortune_${btoa(`${name}_${relationship_duration}_${breakup_reason}`).slice(0, 50)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for ex-lover fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      const prompt = `당신은 한국의 전문 연애운세 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 헤어진 애인 운세를 제공해주세요.

전 애인 이름: "${name}"
교제 기간: ${relationship_duration}
이별 이유: ${breakup_reason}
이별 후 경과: ${time_since_breakup}
현재 감정: ${current_feeling}
연락 여부: ${still_in_contact ? '있음' : '없음'}

다음 정보를 포함하여 상세한 전 애인 운세를 제공해주세요:

1. 전반적인 운세: 전 애인과의 관계에 대한 전체적인 운
2. 재회 가능성: 다시 만날 가능성과 조건
3. 감정 정리: 감정 정리를 위한 조언
4. 주의사항: 전 애인과 관련하여 주의할 점 3가지
5. 추천사항: 앞으로 나아가기 위한 조언 3가지
6. 새로운 시작: 새로운 만남을 위한 조언
7. 운세 키워드: 상황을 한 단어로 표현

현실적이면서도 위로가 되는 관점으로 조언해주세요.`

      const completion = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: '당신은 한국의 전문 연애운세 전문가입니다. 항상 한국어로 응답하며, 위로와 현실적인 조언을 제공합니다.'
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
        title: `${name}과의 인연`,
        fortune_type: 'ex_lover',
        name,
        relationship_duration,
        breakup_reason,
        overall_fortune: parsedResponse.전반적인운세 || parsedResponse.overall_fortune || '시간이 해결해줄 것입니다.',
        reunion_possibility: parsedResponse.재회가능성 || parsedResponse.reunion_possibility || '시간을 가지세요.',
        emotion_healing: parsedResponse.감정정리 || parsedResponse.emotion_healing || '천천히 치유하세요.',
        cautions: parsedResponse.주의사항 || parsedResponse.cautions || ['급하게 연락 금지', '감정 정리 우선', '새로운 시작 준비'],
        recommendations: parsedResponse.추천사항 || parsedResponse.recommendations || ['자기 계발', '새로운 취미', '친구 만남'],
        new_beginning: parsedResponse.새로운시작 || parsedResponse.new_beginning || '새로운 만남이 기다립니다.',
        fortune_keyword: parsedResponse.운세키워드 || parsedResponse.fortune_keyword || '치유',
        score: Math.floor(Math.random() * 30) + 70,
        timestamp: new Date().toISOString()
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'ex_lover',
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
    console.error('Ex-Lover Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '전 애인 운세 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
