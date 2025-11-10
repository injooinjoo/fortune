import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

interface HealthFortuneRequest {
  fortune_type?: string
  current_condition: string
  concerned_body_parts: string[]
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
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
    const {
      current_condition = '',
      concerned_body_parts = [],
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    if (!current_condition) {
      throw new Error('현재 건강 상태를 입력해주세요.')
    }

    console.log('💎 [Health] Premium 상태:', isPremium)
    console.log('Health fortune request:', { current_condition, concerned_body_parts })

    const cacheKey = `health_fortune_${btoa(`${current_condition}_${concerned_body_parts.join(',')}`).slice(0, 50)}`
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
      console.log('Cache miss, calling LLM API')

      // ✅ LLM 모듈 사용 (Provider 자동 선택)
      const llm = LLMFactory.createFromConfig('health')

      const systemPrompt = `당신은 30년 경력의 전문 한의사이자 건강 컨설턴트입니다.
동양의학과 현대 의학을 결합하여 실용적이고 구체적인 건강 조언을 제공합니다.
응답은 반드시 유효한 JSON 형식이어야 하며, 한국의 건강 문화와 생활 패턴을 깊이 이해하고 있습니다.`

      const userPrompt = `당신은 30년 경력의 전문 한의사이자 건강 컨설턴트입니다.
다음 정보를 바탕으로 전문적이고 구체적인 건강운세를 JSON 형식으로 제공해주세요.

**현재 건강 상태:**
- 전반적 컨디션: ${current_condition}
- 관심/우려 부위: ${concerned_body_parts.length > 0 ? concerned_body_parts.join(', ') : '특별한 우려 사항 없음'}

**요청 사항:**

1. **전반적인 건강운 (overall_health):**
   - 현재 건강 상태에 대한 종합 평가 (3-4문장)
   - 체질적 특징과 계절/시기와의 관련성
   - 전반적인 에너지 레벨과 면역력 상태
   - 긍정적 측면과 주의가 필요한 측면 균형있게 서술

2. **부위별 건강 조언 (body_part_advice):**
   - 관심 부위에 대한 상세한 분석 (각 부위당 2-3문장)
   - 증상 예방 및 관리 방법
   - 일상생활에서 실천 가능한 셀프케어 방법
   - 관련 경혈(ツボ) 또는 스트레칭 제안

3. **주의사항 (cautions):**
   - 피해야 할 생활습관 3가지 (구체적으로)
   - 특정 음식이나 활동에 대한 경고
   - 스트레스 관리 포인트
   - 각 항목은 "이유"와 함께 명확하게 설명

4. **추천 활동 (recommended_activities):**
   - 현재 건강 상태에 최적화된 활동 3-5가지
   - 활동의 효과와 실천 방법 구체적으로 기술
   - 시간대별 추천 (아침/점심/저녁)
   - 초보자도 쉽게 시작할 수 있는 수준

5. **식습관 조언 (diet_advice):**
   - 현재 상태에 좋은 음식 5가지 (효능과 함께)
   - 피해야 할 음식 3가지 (이유와 함께)
   - 식사 시간과 양에 대한 조언
   - 계절/체질에 맞는 식단 팁
   - 최소 5-6문장의 상세한 설명

6. **운동 조언 (exercise_advice):**
   - 체력 수준별 맞춤 운동 프로그램
   - 주차별 운동 강도 조절 방법
   - 부상 예방을 위한 주의사항
   - 운동 시간대와 빈도 권장사항
   - 최소 5-6문장의 구체적인 가이드

7. **건강 키워드 (health_keyword):**
   - 오늘의 건강운을 상징하는 2-3단어
   - 긍정적이고 기억하기 쉬운 표현

**응답 형식:**
반드시 JSON 형태로 응답하되, 한국의 건강 문화와 현대인의 생활 패턴을 반영하여 작성해주세요.
의학적으로 근거가 있으면서도 실천 가능한 조언을 제공하되, 과도한 낙관론이나 의료적 진단은 피해주세요.
각 섹션은 충분히 상세하게 작성하여 사용자가 실질적인 도움을 받을 수 있도록 해주세요.`

      const response = await llm.generate([
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료:`)
      console.log(`  Provider: ${response.provider}`)
      console.log(`  Model: ${response.model}`)
      console.log(`  Latency: ${response.latency}ms`)
      console.log(`  Tokens: ${response.usage.totalTokens}`)

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // ✅ 항상 전체 데이터 반환 (Flutter에서 블러 처리)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['body_part_advice', 'cautions', 'recommended_activities', 'diet_advice', 'exercise_advice', 'health_keyword']
        : []

      // ✅ overall_health 타입 안정성 개선
      const overallHealthRaw = parsedResponse.전반적인건강운 || parsedResponse.overall_health || parsedResponse.overallHealth
      let overallHealth: string
      if (typeof overallHealthRaw === 'string') {
        overallHealth = overallHealthRaw
      } else if (typeof overallHealthRaw === 'object' && overallHealthRaw !== null) {
        // Map인 경우 값들을 조합
        overallHealth = Object.values(overallHealthRaw).join(' ')
      } else {
        overallHealth = '건강하십니다.'
      }

      fortuneData = {
        title: '건강운',
        fortune_type: 'health',
        current_condition,
        concerned_body_parts,
        score: Math.floor(Math.random() * 30) + 70, // 공개
        overall_health: overallHealth, // ✅ 타입 안정성 개선
        body_part_advice: parsedResponse.부위별건강 || parsedResponse.body_part_advice || '주의가 필요합니다.', // 블러 대상
        cautions: parsedResponse.주의사항 || parsedResponse.cautions || ['규칙적 생활', '충분한 휴식', '정기 검진'], // 블러 대상
        recommended_activities: parsedResponse.추천활동 || parsedResponse.recommended_activities || ['산책', '요가', '스트레칭'], // 블러 대상
        diet_advice: parsedResponse.식습관조언 || parsedResponse.diet_advice || '균형잡힌 식사를 하세요.', // 블러 대상
        exercise_advice: parsedResponse.운동조언 || parsedResponse.exercise_advice || '꾸준한 운동이 중요합니다.', // 블러 대상
        health_keyword: parsedResponse.건강키워드 || parsedResponse.health_keyword || '건강', // 블러 대상
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections // ✅ 블러된 섹션 목록
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
        'Content-Type': 'application/json; charset=utf-8',
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
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
