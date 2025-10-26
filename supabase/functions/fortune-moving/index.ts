import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// 요청 인터페이스
interface MovingFortuneRequest {
  fortune_type?: string
  current_area?: string  // snake_case (호환성)
  target_area?: string   // snake_case (호환성)
  currentArea?: string   // camelCase (Flutter)
  targetArea?: string    // camelCase (Flutter)
  moving_period?: string // snake_case (호환성)
  movingPeriod?: string  // camelCase (Flutter)
  purpose: string
  isPremium?: boolean    // ✅ 프리미엄 사용자 여부
}

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
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
    // 요청 데이터 파싱
    const requestData: MovingFortuneRequest = await req.json()

    // camelCase 또는 snake_case 모두 지원
    const current_area = requestData.current_area || requestData.currentArea || ''
    const target_area = requestData.target_area || requestData.targetArea || ''
    const moving_period = requestData.moving_period || requestData.movingPeriod || ''
    const purpose = requestData.purpose || ''
    const isPremium = requestData.isPremium || false // ✅ 프리미엄 사용자 여부

    if (!current_area || !target_area) {
      throw new Error('현재 지역과 이사갈 지역을 입력해주세요.')
    }

    console.log('💎 [Moving] Premium 상태:', isPremium)
    console.log('Moving fortune request:', {
      current_area: current_area.substring(0, 50),
      target_area: target_area.substring(0, 50),
      moving_period,
      purpose
    })

    // 캐시 확인 (UTF-8 안전한 해시 사용)
    const cacheKey = `moving_fortune_${await createHash(`${current_area}_${target_area}_${moving_period}_${purpose}`)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('✅ Cache hit for moving fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('🔄 Cache miss, calling LLM API')

      // ✅ LLM 모듈 사용 (Provider 자동 선택)
      const llm = LLMFactory.createFromConfig('moving')

      // 프롬프트 생성
      const systemPrompt = '당신은 한국의 전문 이사운세 전문가입니다. 항상 한국어로 JSON 형식으로 응답하며, 실용적이고 긍정적인 조언을 제공합니다.'

      const userPrompt = `당신은 한국의 전문 이사운세 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 이사 조언을 JSON 형식으로 제공해주세요.

현재 거주지: "${current_area}"
이사 예정지: "${target_area}"
이사 시기: ${moving_period}
이사 목적: ${purpose}

다음 정보를 포함하여 상세한 이사운을 JSON 형식으로 제공해주세요:

1. 전반적인 운세: 이사의 길흉과 전체적인 운
2. 방위 분석: 현재 위치에서 이사갈 곳의 방위와 의미
3. 시기 분석: 이사 시기의 적절성과 주의사항
4. 주의사항: 이사할 때 특히 조심해야 할 점 3가지
5. 추천사항: 이사를 성공적으로 마치기 위한 조언 3가지
6. 행운의 날: 이사하기 좋은 날짜 추천
7. 정리 키워드: 이사운을 한 줄로 요약

긍정적이면서도 현실적인 관점으로 조언해주세요.`

      // ✅ LLM 호출 (Provider 무관)
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

      // JSON 파싱
      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('❌ JSON parsing error:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // ✅ Blur 로직 적용
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['direction_analysis', 'timing_analysis', 'cautions', 'recommendations', 'lucky_dates', 'summary_keyword']
        : []

      // 응답 데이터 구조화
      fortuneData = {
        title: `${current_area} → ${target_area} 이사운`,
        fortune_type: 'moving',
        current_area,
        target_area,
        moving_period,
        purpose,
        score: Math.floor(Math.random() * 30) + 70, // ✅ 무료: 공개
        overall_fortune: parsedResponse.전반적인운세 || parsedResponse.overall_fortune || '길한 이사입니다.', // ✅ 무료: 공개
        direction_analysis: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.방위분석 || parsedResponse.direction_analysis || '좋은 방향입니다.'), // 🔒 유료
        timing_analysis: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.시기분석 || parsedResponse.timing_analysis || '적절한 시기입니다.'), // 🔒 유료
        cautions: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.주의사항 || parsedResponse.cautions || ['이사 전 청소', '풍수 확인', '날짜 선택']), // 🔒 유료
        recommendations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.추천사항 || parsedResponse.recommendations || ['긍정적 마음', '계획적 준비', '이웃 인사']), // 🔒 유료
        lucky_dates: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.행운의날 || parsedResponse.lucky_dates || ['주말', '오전 시간대']), // 🔒 유료
        summary_keyword: isBlurred ? '🔒' : (parsedResponse.정리키워드 || parsedResponse.summary_keyword || '길한 이사'), // 🔒 유료
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections, // ✅ 블러된 섹션 목록
        // 메타데이터 추가
        llm_provider: response.provider,
        llm_model: response.model,
        llm_latency: response.latency
      }

      // 결과 캐싱
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'moving',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })
    }

    // 성공 응답
    const responseData = {
      success: true,
      data: fortuneData
    }

    return new Response(JSON.stringify(responseData), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  } catch (error) {
    console.error('❌ Error in fortune-moving function:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || '운세 생성 중 오류가 발생했습니다.',
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
