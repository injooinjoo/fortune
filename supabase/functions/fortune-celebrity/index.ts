/**
 * 유명인 운세 (Celebrity Fortune) Edge Function
 *
 * @description 사용자와 유명인의 사주 궁합을 분석합니다.
 *
 * @endpoint POST /fortune-celebrity
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - celebrity_id: string - 유명인 ID
 * - celebrity_name: string - 유명인 이름
 * - connection_type: string - 연결 유형 (ideal_match, compatibility, career_advice)
 * - question_type: string - 질문 유형 (love, etc)
 * - category: string - 카테고리
 * - name: string - 사용자 이름
 * - birthDate: string - 사용자 생년월일
 * - isPremium?: boolean - 프리미엄 여부
 *
 * @response CelebrityFortuneResponse
 * - score: number (1-100) - 궁합 점수
 * - content: string - 운세 내용
 * - recommendations: string[] - 추천 조언
 * - isBlurred: boolean - 블러 상태
 * - blurredSections: string[] - 블러 처리된 섹션
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 유명인 운세 응답 스키마
interface CelebrityFortuneResponse {
  overall_score: number
  compatibility_grade: string
  main_message: string
  detailed_analysis: {
    personality_match: string
    energy_compatibility: string
    life_path_connection: string
  }
  strengths: string[]
  challenges: string[]
  recommendations: string[]
  lucky_factors: {
    best_time_to_connect: string
    lucky_activity: string
    shared_interest: string
  }
  special_message: string
}

// 캐시 키 생성
async function generateCacheKey(
  userId: string,
  celebrityId: string,
  connectionType: string,
  questionType: string
): Promise<string> {
  const today = new Date().toISOString().split('T')[0]
  const data = `${today}_${userId}_${celebrityId}_${connectionType}_${questionType}`
  const encoder = new TextEncoder()
  const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(data))
  const hashArray = new Uint8Array(hashBuffer)
  return `celebrity_fortune_${Array.from(hashArray).map(b => b.toString(16).padStart(2, '0')).join('').substring(0, 16)}`
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    const requestData = await req.json()
    const {
      userId,
      celebrity_id,
      celebrity_name,
      connection_type = 'ideal_match',
      question_type = 'love',
      category = '',
      name = '사용자',
      birthDate,
      isPremium = false,
    } = requestData

    console.log('🌟 [CelebrityFortune] 요청 시작')
    console.log(`   - 사용자: ${name}`)
    console.log(`   - 유명인: ${celebrity_name} (${celebrity_id})`)
    console.log(`   - 연결 유형: ${connection_type}`)
    console.log(`   - 질문 유형: ${question_type}`)
    console.log(`   - Premium: ${isPremium}`)

    // 캐시 체크
    const cacheKey = await generateCacheKey(userId, celebrity_id, connection_type, question_type)
    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    if (cachedResult) {
      console.log('📦 [CelebrityFortune] 캐시 히트!')
      const fortune = cachedResult.result
      const processedFortune = applyBlurring(fortune, isPremium)
      return new Response(
        JSON.stringify({ fortune: processedFortune, tokensUsed: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // 유명인 정보 조회 (선택적)
    let celebrityInfo = { name: celebrity_name, birthDate: null as string | null, profession: '' }
    if (celebrity_id) {
      const { data: celeb, error: celebError } = await supabaseClient
        .from('celebrities')
        .select('name, birth_date, celebrity_type, profession_data, notes')
        .eq('id', celebrity_id)
        .single()

      if (celebError) {
        console.warn('⚠️ [CelebrityFortune] 유명인 조회 실패:', celebError.message)
      }

      if (celeb) {
        // profession_data에서 직업 정보 추출 (jsonb)
        const professionData = celeb.profession_data as Record<string, any> | null
        const profession = professionData?.profession || professionData?.role || celeb.celebrity_type || ''

        celebrityInfo = {
          name: celeb.name,
          birthDate: celeb.birth_date,
          profession: profession,
        }
      }
    }

    // LLM 호출
    const llm = LLMFactory.createFromConfig('fortune-celebrity')
    const today = new Date()

    const connectionTypeText = {
      ideal_match: '이상형 매치',
      compatibility: '전체 궁합',
      career_advice: '조언 구하기',
    }[connection_type] || '궁합 분석'

    const questionTypeText = {
      love: '사랑/연애',
      career: '커리어/성공',
      life: '인생/삶의 방향',
      friendship: '친구/인맥',
    }[question_type] || '전체'

    const systemPrompt = `당신은 사주 전문가이자 운명 분석가입니다.
사용자와 유명인 사이의 사주적 인연과 궁합을 분석합니다.

분석 관점:
1. 에너지 궁합: 두 사람의 기운이 어떻게 조화를 이루는지
2. 성격 매칭: 성격적 특성이 어떻게 맞닿는지
3. 인생 경로: 삶의 방향과 가치관의 공통점
4. 시너지: 만났을 때 발생할 수 있는 긍정적 에너지

톤 가이드:
- 긍정적이고 희망적인 메시지
- 구체적이고 실용적인 조언
- 팬심을 존중하면서도 현실적인 인사이트
- ${name}님의 이름을 자연스럽게 사용

응답은 반드시 JSON 형식으로만 해주세요.`

    const userPrompt = `오늘 날짜: ${today.toLocaleDateString('ko-KR')}

👤 사용자 정보:
- 이름: ${name}
${birthDate ? `- 생년월일: ${birthDate}` : ''}

⭐ 유명인 정보:
- 이름: ${celebrityInfo.name}
${celebrityInfo.birthDate ? `- 생년월일: ${celebrityInfo.birthDate}` : ''}
${celebrityInfo.profession ? `- 직업: ${celebrityInfo.profession}` : ''}

📋 분석 요청:
- 연결 유형: ${connectionTypeText}
- 관심 분야: ${questionTypeText}
${category ? `- 카테고리: ${category}` : ''}

위 정보를 바탕으로 ${name}님과 ${celebrityInfo.name}의 궁합을 분석해주세요.

응답 JSON 스키마:
{
  "overall_score": (50-100 숫자, 궁합 점수),
  "compatibility_grade": "천생연분" | "좋음" | "보통" | "노력필요" 중 택일,
  "main_message": "${name}님과 ${celebrityInfo.name}의 궁합에 대한 핵심 메시지 (80-120자)",
  "detailed_analysis": {
    "personality_match": "성격 궁합 분석 (60-80자)",
    "energy_compatibility": "에너지 궁합 분석 (60-80자)",
    "life_path_connection": "인생 경로 연결점 (60-80자)"
  },
  "strengths": ["장점1 (40자)", "장점2 (40자)", "장점3 (40자)"],
  "challenges": ["도전과제1 (40자)", "도전과제2 (40자)"],
  "recommendations": ["추천 조언1 (50자)", "추천 조언2 (50자)", "추천 조언3 (50자)"],
  "lucky_factors": {
    "best_time_to_connect": "연결하기 좋은 시간대",
    "lucky_activity": "행운의 활동",
    "shared_interest": "공유할 만한 관심사"
  },
  "special_message": "${celebrityInfo.name}가 ${name}님에게 전하는 메시지 컨셉 (60-80자)"
}`

    console.log('🤖 [CelebrityFortune] LLM 호출 시작...')
    const startTime = Date.now()
    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], { jsonMode: true })
    const endTime = Date.now()
    console.log(`✅ [CelebrityFortune] LLM 응답 완료 (${endTime - startTime}ms)`)

    // JSON 파싱
    let fortuneData: CelebrityFortuneResponse
    try {
      fortuneData = JSON.parse(response.content)
    } catch (parseError) {
      console.error('❌ [CelebrityFortune] JSON 파싱 실패:', parseError)
      fortuneData = generateFallbackFortune(name, celebrityInfo.name, connection_type)
    }

    // 토큰 사용량 로깅
    const usageLogger = new UsageLogger(supabaseClient)
    await usageLogger.log({
      userId,
      functionName: 'fortune-celebrity',
      model: response.model || 'gpt-4o-mini',
      promptTokens: response.usage?.prompt_tokens || 0,
      completionTokens: response.usage?.completion_tokens || 0,
      totalTokens: response.usage?.total_tokens || 0
    })

    // 전체 운세 데이터 구성
    const fortune = {
      id: `celebrity-${Date.now()}`,
      userId: userId,
      type: 'celebrity',
      content: fortuneData.main_message,
      summary: fortuneData.main_message,
      score: fortuneData.overall_score,
      overallScore: fortuneData.overall_score,
      compatibilityGrade: fortuneData.compatibility_grade,

      celebrity_info: {
        id: celebrity_id,
        name: celebrityInfo.name,
        profession: celebrityInfo.profession,
      },

      detailed_analysis: fortuneData.detailed_analysis,
      strengths: fortuneData.strengths,
      challenges: fortuneData.challenges,
      recommendations: fortuneData.recommendations,
      lucky_factors: fortuneData.lucky_factors,
      special_message: fortuneData.special_message,

      // 육각형 차트용 점수
      hexagonScores: {
        '궁합': fortuneData.overall_score,
        '에너지': Math.round(fortuneData.overall_score * 0.9 + Math.random() * 10),
        '성격': Math.round(fortuneData.overall_score * 0.85 + Math.random() * 15),
        '가치관': Math.round(fortuneData.overall_score * 0.88 + Math.random() * 12),
        '운명': Math.round(fortuneData.overall_score * 0.92 + Math.random() * 8),
        '시너지': Math.round(fortuneData.overall_score * 0.95 + Math.random() * 5),
      },

      createdAt: new Date().toISOString()
    }

    // 캐시 저장 (24시간 TTL)
    try {
      await supabaseClient
        .from('fortune_cache')
        .upsert({
          cache_key: cacheKey,
          result: fortune,
          created_at: new Date().toISOString(),
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
        })
      console.log('💾 [CelebrityFortune] 캐시 저장 완료')
    } catch (cacheError) {
      console.warn('⚠️ [CelebrityFortune] 캐시 저장 실패:', cacheError)
    }

    // 블러 처리 적용
    const processedFortune = applyBlurring(fortune, isPremium)

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'celebrity', fortune.score)
    const fortuneWithPercentile = addPercentileToResult(processedFortune, percentileData)

    return new Response(
      JSON.stringify({
        fortune: fortuneWithPercentile,
        tokensUsed: response.usage?.total_tokens || 0
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200
      }
    )

  } catch (error) {
    console.error('❌ [CelebrityFortune] 에러:', error)

    return new Response(
      JSON.stringify({
        error: 'Failed to generate celebrity fortune',
        message: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})

// 블러 처리 함수
function applyBlurring(fortune: any, isPremium: boolean): any {
  if (isPremium) {
    return {
      ...fortune,
      isBlurred: false,
      blurredSections: []
    }
  }

  // 프리미엄 섹션 블러 처리
  const blurredSections = ['detailed_analysis', 'lucky_factors', 'special_message']

  return {
    ...fortune,
    isBlurred: true,
    blurredSections,

    // 프리미엄 섹션을 블러 메시지로 대체
    detailed_analysis: {
      personality_match: '🔒 프리미엄 결제 후 확인 가능합니다',
      energy_compatibility: '🔒 프리미엄 결제 후 확인 가능합니다',
      life_path_connection: '🔒 프리미엄 결제 후 확인 가능합니다'
    },
    lucky_factors: {
      best_time_to_connect: '🔒 프리미엄',
      lucky_activity: '🔒 프리미엄',
      shared_interest: '🔒 프리미엄'
    },
    special_message: '🔒 프리미엄 결제 후 확인 가능합니다'
  }
}

// Fallback 운세 생성
function generateFallbackFortune(userName: string, celebrityName: string, connectionType: string): CelebrityFortuneResponse {
  const baseScore = 70 + Math.floor(Math.random() * 20)

  return {
    overall_score: baseScore,
    compatibility_grade: baseScore >= 80 ? '좋음' : '보통',
    main_message: `${userName}님과 ${celebrityName}님의 에너지가 서로 조화롭게 어우러지는 인연입니다. 비슷한 감성과 가치관을 공유하고 있어요.`,
    detailed_analysis: {
      personality_match: `${userName}님의 섬세한 성격이 ${celebrityName}님의 카리스마와 잘 어울립니다.`,
      energy_compatibility: '두 분의 에너지가 만나면 긍정적인 시너지가 발생할 수 있어요.',
      life_path_connection: '삶의 방향성에서 공통된 가치를 발견할 수 있는 인연입니다.'
    },
    strengths: [
      '감성적 교감이 뛰어난 궁합',
      '서로의 장점을 인정하는 관계',
      '성장을 자극하는 긍정적 영향'
    ],
    challenges: [
      '현실과 이상 사이의 균형 필요',
      '각자의 시간과 공간 존중하기'
    ],
    recommendations: [
      `${celebrityName}님의 작품이나 활동을 통해 영감을 얻어보세요`,
      '비슷한 관심사를 가진 사람들과 교류해보세요',
      '자신만의 특별한 매력을 발전시켜보세요'
    ],
    lucky_factors: {
      best_time_to_connect: '저녁 7-9시',
      lucky_activity: '음악 감상 또는 영화 관람',
      shared_interest: '예술과 창작 활동'
    },
    special_message: `${userName}님, 당신만의 빛나는 매력을 믿으세요. 우리는 모두 연결되어 있어요.`
  }
}
