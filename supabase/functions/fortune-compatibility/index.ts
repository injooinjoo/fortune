import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// 요청 인터페이스
interface CompatibilityFortuneRequest {
  fortune_type?: string
  person1_name: string
  person1_birth_date: string
  person2_name: string
  person2_birth_date: string
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
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
    const requestData: CompatibilityFortuneRequest = await req.json()
    const {
      person1_name = '',
      person1_birth_date = '',
      person2_name = '',
      person2_birth_date = '',
      isPremium = false
    } = requestData

    console.log(`[Compatibility] Request - Premium: ${isPremium}`)

    if (!person1_name || !person2_name) {
      throw new Error('두 사람의 이름을 모두 입력해주세요.')
    }

    console.log('Compatibility fortune request:', {
      person1_name,
      person2_name
    })

    // 캐시 확인 (Deno 네이티브 btoa 사용)
    const cacheKey = `compatibility_fortune_${btoa(`${person1_name}_${person1_birth_date}_${person2_name}_${person2_birth_date}`).slice(0, 50)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for compatibility fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      // OpenAI API 호출을 위한 프롬프트 생성
      const prompt = `당신은 한국의 전문 궁합 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 궁합 분석을 제공해주세요.

첫 번째 사람: "${person1_name}" (생년월일: ${person1_birth_date})
두 번째 사람: "${person2_name}" (생년월일: ${person2_birth_date})

다음 정보를 포함하여 상세한 궁합 분석을 제공해주세요:

1. 전반적인 궁합: 두 사람의 전체적인 궁합과 궁합 점수 (0-100)
2. 성격 궁합: 성격적 조화와 차이점
3. 애정 궁합: 연애 및 애정 관계에서의 궁합
4. 결혼 궁합: 결혼 생활에서의 조화
5. 소통 궁합: 의사소통과 이해도
6. 강점: 두 사람 관계의 강점 3가지
7. 주의점: 관계에서 주의해야 할 점 3가지
8. 조언: 더 좋은 관계를 위한 조언 3가지
9. 궁합 키워드: 관계를 한 단어로 표현

긍정적이면서도 현실적인 관점으로 조언해주세요.`

      // ✅ LLM 모듈 사용 (Provider 자동 선택)
      const llm = LLMFactory.createFromConfig('compatibility')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 한국의 전문 궁합 전문가입니다. 항상 한국어로 응답하며, 실용적이고 긍정적인 조언을 제공합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
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

      if (!response.content) {
        throw new Error('LLM API 응답을 받을 수 없습니다.')
      }

      // JSON 파싱
      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('JSON parsing error:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // ✅ Premium 여부에 따라 Blur 처리
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['personality_match', 'love_match', 'marriage_match', 'communication_match', 'strengths', 'cautions', 'advice']
        : []

      // 응답 데이터 구조화
      fortuneData = {
        title: `${person1_name}♥${person2_name} 궁합`,
        fortune_type: 'compatibility',
        person1: { name: person1_name, birth_date: person1_birth_date },
        person2: { name: person2_name, birth_date: person2_birth_date },
        overall_compatibility: parsedResponse.전반적인궁합 || parsedResponse.overall_compatibility || '좋은 궁합입니다.', // ✅ 무료: 공개
        personality_match: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.성격궁합 || parsedResponse.personality_match || '성격이 잘 맞습니다.'), // 🔒 유료
        love_match: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.애정궁합 || parsedResponse.love_match || '애정이 깊습니다.'), // 🔒 유료
        marriage_match: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.결혼궁합 || parsedResponse.marriage_match || '결혼에 적합합니다.'), // 🔒 유료
        communication_match: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.소통궁합 || parsedResponse.communication_match || '소통이 원활합니다.'), // 🔒 유료
        strengths: isBlurred ? ['🔒 프리미엄 전용'] : (parsedResponse.강점 || parsedResponse.strengths || ['서로 이해', '존중', '배려']), // 🔒 유료
        cautions: isBlurred ? ['🔒 프리미엄 전용'] : (parsedResponse.주의점 || parsedResponse.cautions || ['작은 갈등 주의', '대화 중요', '서로 존중']), // 🔒 유료
        advice: isBlurred ? ['🔒 프리미엄 전용'] : (parsedResponse.조언 || parsedResponse.advice || ['서로 배려', '대화 자주', '함께 시간']), // 🔒 유료
        compatibility_keyword: parsedResponse.궁합키워드 || parsedResponse.compatibility_keyword || '천생연분', // ✅ 무료: 공개
        score: parsedResponse.궁합점수 || Math.floor(Math.random() * 30) + 70, // ✅ 무료: 공개 (70-100)
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ Blur 상태
        blurredSections, // ✅ Blur 처리된 섹션 목록
      }

      console.log(`[Compatibility] Result generated - Blurred: ${isBlurred}, Sections: ${blurredSections.length}`)

      // 결과 캐싱
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'compatibility',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })
    }

    // 성공 응답
    const response = {
      success: true,
      data: fortuneData
    }

    return new Response(JSON.stringify(response), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Compatibility Fortune Error:', error)

    const errorResponse = {
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '궁합 운세 생성 중 오류가 발생했습니다.'
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
