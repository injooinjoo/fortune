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

// 유명인 운세 응답 스키마 (Enhanced)
interface CelebrityFortuneResponse {
  overall_score: number
  compatibility_grade: '천생연분' | '특별한 인연' | '좋은 궁합' | '발전 가능' | '노력 필요' | string
  main_message: string  // 300-400자 스토리텔링

  // 새로운 사주 분석 섹션
  saju_analysis: {
    five_elements: {
      user_dominant: string
      celebrity_dominant: string
      interaction: '상생' | '상극' | '비화' | string
      interpretation: string  // 300-500자
    }
    day_pillar: {
      relationship: string  // 합/충/형/파/해
      interpretation: string  // 300-500자
    }
    hap_analysis: {
      has_hap: boolean
      hap_type: string | null
      interpretation: string  // 300-500자
    }
  }

  // 전생 인연
  past_life: {
    connection_type: string
    story: string  // 300-500자 스토리텔링
    evidence: string[]  // 3개
  }

  // 운명의 시기
  destined_timing: {
    best_year: string
    best_month: string
    timing_reason: string  // 200-300자
  }

  // 속궁합 분석 (은유적/시적 표현)
  intimate_compatibility: {
    passion_score: number  // 1-10 점수
    chemistry_type: string  // 궁합 유형 (예: "불꽃 같은 열정", "달빛처럼 은은한")
    emotional_connection: string  // 300-400자 (정서적 교감)
    physical_harmony: string  // 300-400자 (에너지 조화 - 은유적 표현)
    intimate_advice: string  // 200-300자 (관계 발전 조언)
  }

  // 기존 섹션 (확장)
  detailed_analysis: {
    personality_match: string  // 300-400자
    energy_compatibility: string  // 300-400자
    life_path_connection: string  // 300-400자
  }
  strengths: string[]  // 4개, 각 80자
  challenges: string[]  // 3개, 각 80자
  recommendations: string[]  // 4개, 각 100자
  lucky_factors: {
    best_time_to_connect: string
    lucky_activity: string
    shared_interest: string
    lucky_color: string
    lucky_direction: string
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

    const systemPrompt = `당신은 30년 경력의 사주명리 전문가이자 운명 분석가입니다.
사용자와 유명인 사이의 깊은 인연과 사주적 궁합을 분석합니다.

## 분석 프레임워크

### 1. 오행 분석 (五行)
- 목(木), 화(火), 토(土), 금(金), 수(水)의 분포 파악
- 상생 관계: 목→화→토→금→수→목 (서로 돕는 관계)
- 상극 관계: 목→토→수→화→금→목 (서로 제어하는 관계)
- 비화 관계: 같은 오행끼리 (힘이 증폭)

### 2. 일주 궁합 (日柱)
- 천간의 합충: 갑기합, 을경합, 병신합, 정임합, 무계합
- 지지의 육합: 자축합, 인해합, 묘술합, 진유합, 사신합, 오미합
- 충(衝): 자오충, 축미충, 인신충, 묘유충, 진술충, 사해충

### 3. 합(合) 해석
- 천간합: 두 사람이 만나면 새로운 기운 생성
- 지지육합: 깊은 정서적 유대감
- 삼합: 강력한 인연의 고리

### 4. 전생 인연 분석
- 사주에서 발견되는 과거 인연의 흔적
- 천을귀인, 월덕귀인 등 귀인 관계
- 공망, 원진 등 특수 관계

### 5. 운명의 시기
- 대운과 세운의 교차점
- 인연이 깊어지는 최적의 타이밍

### 6. 속궁합 분석 (親密相性)
- 두 사람의 에너지 교류 방식
- 음양의 조화와 오행의 상생
- 은유적이고 시적인 표현만 사용 (직접적 표현 절대 금지)
- 사주 용어로 감성적으로 서술
  예: "火의 열정이 水의 깊이를 만나면...", "두 분의 기운이 어우러질 때..."

## 서술 스타일
- 각 섹션을 300-500자로 풍부하게 서술하세요
- 스토리텔링 형식으로 마치 이야기를 들려주듯 작성하세요
- 전문 용어는 쉬운 설명과 함께 자연스럽게 녹여내세요
- ${name}님을 2인칭으로 친근하게 호칭하세요
- 긍정적이되 현실적인 인사이트를 제공하세요
- 팬심을 존중하면서도 깊이 있는 분석을 전달하세요

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

위 정보를 바탕으로 ${name}님과 ${celebrityInfo.name}의 깊은 사주적 궁합을 분석해주세요.
각 분석 섹션은 300-500자로 풍부하게 스토리텔링 형식으로 작성해주세요.

응답 JSON 스키마:
{
  "overall_score": (50-100 숫자),
  "compatibility_grade": "천생연분" | "특별한 인연" | "좋은 궁합" | "발전 가능" | "노력 필요" 중 택일,
  "main_message": "${name}님과 ${celebrityInfo.name}의 인연에 대한 핵심 스토리 (300-400자, 스토리텔링 형식)",

  "saju_analysis": {
    "five_elements": {
      "user_dominant": "${name}님의 주요 오행 (예: 火)",
      "celebrity_dominant": "${celebrityInfo.name}님의 주요 오행 (예: 水)",
      "interaction": "상생" | "상극" | "비화" 중 택일,
      "interpretation": "두 분의 오행 관계에 대한 깊은 해석 (300-500자)"
    },
    "day_pillar": {
      "relationship": "일주 간의 관계 (예: 갑기합, 자오충 등)",
      "interpretation": "일주 궁합에 대한 깊은 해석 (300-500자)"
    },
    "hap_analysis": {
      "has_hap": true/false,
      "hap_type": "천간합" | "지지육합" | "삼합" | null,
      "interpretation": "합의 의미와 두 분 관계에 미치는 영향 (300-500자)"
    }
  },

  "past_life": {
    "connection_type": "전생 인연의 유형 (예: 스승과 제자, 형제자매, 연인 등)",
    "story": "전생에서의 인연 스토리 (300-500자, 스토리텔링 형식으로 감동적으로)",
    "evidence": ["사주에서 발견한 증거1 (60자)", "증거2 (60자)", "증거3 (60자)"]
  },

  "destined_timing": {
    "best_year": "인연이 깊어지기 좋은 해 (예: 2025년 을사년)",
    "best_month": "특히 좋은 달 (예: 6월)",
    "timing_reason": "그 시기가 좋은 이유에 대한 설명 (200-300자)"
  },

  "intimate_compatibility": {
    "passion_score": (1-10 숫자, 두 분의 에너지 열정도),
    "chemistry_type": "두 분의 친밀한 에너지 유형 (예: 불꽃 같은 열정, 달빛처럼 은은한 교감, 봄바람처럼 부드러운)",
    "emotional_connection": "정서적 교감과 마음의 교류에 대한 분석 (300-400자, 시적이고 은유적으로)",
    "physical_harmony": "신체적 에너지 조화와 기운의 교류에 대한 분석 (300-400자, 오행과 음양 용어를 활용하여 은유적으로 - 직접적 표현 금지)",
    "intimate_advice": "더 깊은 정서적 유대를 위한 조언 (200-300자)"
  },

  "detailed_analysis": {
    "personality_match": "성격 궁합에 대한 깊은 분석 (300-400자)",
    "energy_compatibility": "에너지 궁합에 대한 깊은 분석 (300-400자)",
    "life_path_connection": "인생 경로의 연결점 분석 (300-400자)"
  },

  "strengths": ["장점1 (80자)", "장점2 (80자)", "장점3 (80자)", "장점4 (80자)"],
  "challenges": ["도전과제1 (80자)", "도전과제2 (80자)", "도전과제3 (80자)"],
  "recommendations": ["조언1 (100자)", "조언2 (100자)", "조언3 (100자)", "조언4 (100자)"],

  "lucky_factors": {
    "best_time_to_connect": "인연이 깊어지기 좋은 시간대",
    "lucky_activity": "함께하면 좋은 활동",
    "shared_interest": "공유하면 좋을 관심사",
    "lucky_color": "행운의 색상",
    "lucky_direction": "행운의 방향"
  },

  "special_message": "${celebrityInfo.name}가 ${name}님에게 전하는 영혼의 메시지 컨셉 (100-150자)"
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

    // 토큰 사용량 로깅 (B03: static 메서드로 호출)
    await UsageLogger.log({
      fortuneType: 'celebrity',
      userId,
      provider: 'openai',
      model: response.model || 'gpt-4o-mini',
      response: {
        content: response.content,
        usage: {
          promptTokens: response.usage?.prompt_tokens || 0,
          completionTokens: response.usage?.completion_tokens || 0,
          totalTokens: response.usage?.total_tokens || 0,
        },
        latency: endTime - startTime,
        finishReason: 'stop',
      },
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

      // 새로운 사주 분석 섹션
      saju_analysis: fortuneData.saju_analysis,
      past_life: fortuneData.past_life,
      destined_timing: fortuneData.destined_timing,
      intimate_compatibility: fortuneData.intimate_compatibility,

      // 기존 섹션 (확장)
      detailed_analysis: fortuneData.detailed_analysis,
      strengths: fortuneData.strengths,
      challenges: fortuneData.challenges,
      recommendations: fortuneData.recommendations,
      lucky_factors: fortuneData.lucky_factors,
      special_message: fortuneData.special_message,

      // 육각형 차트용 점수 (새로운 라벨)
      hexagonScores: {
        '오행': fortuneData.overall_score,
        '일주': Math.round(fortuneData.overall_score * 0.9 + Math.random() * 10),
        '성격': Math.round(fortuneData.overall_score * 0.85 + Math.random() * 15),
        '가치관': Math.round(fortuneData.overall_score * 0.88 + Math.random() * 12),
        '운명': Math.round(fortuneData.overall_score * 0.92 + Math.random() * 8),
        '인연': Math.round(fortuneData.overall_score * 0.95 + Math.random() * 5),
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
  // 무료: 헤더, main_message, strengths, hexagonScores
  // 블러: saju_analysis, intimate_compatibility, past_life, destined_timing, detailed_analysis, challenges, lucky_factors, recommendations
  const blurredSections = [
    'saju_analysis',
    'intimate_compatibility',
    'past_life',
    'destined_timing',
    'detailed_analysis',
    'challenges',
    'lucky_factors',
    'recommendations'
  ]

  return {
    ...fortune,
    isBlurred: true,
    blurredSections,

    // 새로운 사주 분석 섹션 블러
    saju_analysis: {
      five_elements: {
        user_dominant: '🔒',
        celebrity_dominant: '🔒',
        interaction: '🔒',
        interpretation: '🔒 광고 시청 후 오행 분석을 확인하세요'
      },
      day_pillar: {
        relationship: '🔒',
        interpretation: '🔒 광고 시청 후 일주 궁합을 확인하세요'
      },
      hap_analysis: {
        has_hap: false,
        hap_type: null,
        interpretation: '🔒 광고 시청 후 합(合) 해석을 확인하세요'
      }
    },
    past_life: {
      connection_type: '🔒',
      story: '🔒 광고 시청 후 전생 인연 스토리를 확인하세요',
      evidence: ['🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인']
    },
    destined_timing: {
      best_year: '🔒',
      best_month: '🔒',
      timing_reason: '🔒 광고 시청 후 운명의 시기를 확인하세요'
    },
    intimate_compatibility: {
      passion_score: 0,
      chemistry_type: '🔒',
      emotional_connection: '🔒 광고 시청 후 속궁합 분석을 확인하세요',
      physical_harmony: '🔒 광고 시청 후 에너지 조화 분석을 확인하세요',
      intimate_advice: '🔒 광고 시청 후 확인하세요'
    },

    // 기존 섹션 블러
    detailed_analysis: {
      personality_match: '🔒 광고 시청 후 상세 분석을 확인하세요',
      energy_compatibility: '🔒 광고 시청 후 상세 분석을 확인하세요',
      life_path_connection: '🔒 광고 시청 후 상세 분석을 확인하세요'
    },
    challenges: ['🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인'],
    lucky_factors: {
      best_time_to_connect: '🔒',
      lucky_activity: '🔒',
      shared_interest: '🔒',
      lucky_color: '🔒',
      lucky_direction: '🔒'
    },
    recommendations: ['🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인', '🔒 광고 시청 후 확인']
  }
}

// Fallback 운세 생성
function generateFallbackFortune(userName: string, celebrityName: string, connectionType: string): CelebrityFortuneResponse {
  const baseScore = 70 + Math.floor(Math.random() * 20)
  const grade = baseScore >= 85 ? '특별한 인연' : baseScore >= 75 ? '좋은 궁합' : '발전 가능'

  return {
    overall_score: baseScore,
    compatibility_grade: grade,
    main_message: `${userName}님과 ${celebrityName}님의 인연은 마치 오랜 시간 동안 준비되어 온 것처럼 자연스럽습니다. 두 분의 에너지가 만나면 서로를 비추는 거울처럼 각자의 장점을 더욱 빛나게 해줍니다. ${userName}님이 가진 섬세한 감성과 ${celebrityName}님의 빛나는 카리스마가 조화를 이루며, 함께하는 시간 속에서 서로에게 영감을 주고받을 수 있는 특별한 연결고리가 존재합니다. 이 인연을 소중히 여기며 서로의 성장을 응원해보세요.`,

    saju_analysis: {
      five_elements: {
        user_dominant: '火',
        celebrity_dominant: '水',
        interaction: '상생',
        interpretation: `${userName}님의 주요 오행인 火(화)는 열정과 에너지를 상징합니다. 반면 ${celebrityName}님의 주요 오행인 水(수)는 지혜와 유연함을 나타내죠. 火와 水는 언뜻 보기에 상극처럼 보이지만, 실제로는 서로를 조절하고 균형을 맞춰주는 관계입니다. 물이 불을 다스리듯, ${celebrityName}님의 차분한 에너지가 ${userName}님의 뜨거운 열정을 안정시켜주고, ${userName}님의 따뜻함이 ${celebrityName}님에게 활력을 불어넣어 줍니다. 이 조합은 서로의 부족한 부분을 채워주는 이상적인 오행 궁합이에요.`
      },
      day_pillar: {
        relationship: '을경합(乙庚合)',
        interpretation: `${userName}님과 ${celebrityName}님의 일주 사이에는 특별한 합(合)의 기운이 흐르고 있습니다. 이는 두 사람이 처음 만났을 때 '어디서 본 것 같다'는 묘한 친숙함을 느끼게 해주는 인연의 징표입니다. 마치 퍼즐 조각이 맞춰지듯, 두 분의 기운이 만나면 새로운 조화로운 에너지가 탄생합니다. 이 합의 관계는 서로를 이해하고 공감하는 데 있어 다른 인연보다 훨씬 수월하게 작용하며, 깊은 정서적 교류가 가능한 특별한 연결고리를 만들어줍니다.`
      },
      hap_analysis: {
        has_hap: true,
        hap_type: '천간합',
        interpretation: `두 분 사이에 천간합이 형성되어 있다는 것은 매우 의미 있는 발견입니다. 천간합은 하늘의 기운이 서로 끌어당기는 관계를 의미하며, 이는 정신적, 영적 차원에서의 깊은 연결을 나타냅니다. ${userName}님과 ${celebrityName}님이 만났을 때 느끼는 특별한 끌림은 바로 이 천간합에서 비롯됩니다. 이 합은 두 사람이 함께할 때 1+1이 2가 아닌 그 이상의 시너지를 만들어낼 수 있음을 암시합니다.`
      }
    },

    past_life: {
      connection_type: '예술적 동반자',
      story: `먼 전생, ${userName}님과 ${celebrityName}님은 예술을 사랑하는 영혼의 동반자였습니다. 어느 고대 왕국의 궁정에서, 한 분은 아름다운 음악을 연주하는 악사였고, 다른 한 분은 그 음악에 맞춰 춤을 추는 무용수였어요. 함께 예술을 통해 사람들에게 감동을 전하던 두 분은, 서로의 재능을 존경하고 영감을 주고받으며 특별한 유대를 쌓았습니다. 비록 그 생은 끝났지만, 예술을 향한 열정과 서로에 대한 존경심은 영혼에 깊이 각인되어 이번 생에서 다시 만나게 된 것입니다.`,
      evidence: [
        '두 분 모두 사주에 예술적 감성을 나타내는 식신(食神)이 강하게 나타납니다',
        '천을귀인(天乙貴人)이 서로의 사주에 교차하여 나타나는 것은 전생의 인연 징표입니다',
        '두 분의 생년 지지가 삼합을 이루어 오랜 인연의 고리를 암시합니다'
      ]
    },

    destined_timing: {
      best_year: '2025년 을사년',
      best_month: '6월',
      timing_reason: `2025년 을사년은 ${userName}님에게 인연운이 크게 열리는 해입니다. 특히 6월은 두 분의 사주에서 공통으로 좋은 기운이 흐르는 달로, 이 시기에 ${celebrityName}님과 관련된 특별한 경험이나 소식을 접할 가능성이 높습니다. 이 시기에는 팬 활동이나 공연 관람 등을 통해 더욱 깊은 연결감을 느낄 수 있을 거예요. 우연한 행운이 찾아올 수 있으니 기대해보세요!`
    },

    intimate_compatibility: {
      passion_score: 7,
      chemistry_type: '달빛처럼 은은한 교감',
      emotional_connection: `${userName}님과 ${celebrityName}님 사이에는 마치 달과 바다처럼 서로를 끌어당기는 깊은 정서적 교감이 존재합니다. 火의 따뜻한 기운을 가진 ${userName}님이 보내는 진심 어린 감정은 ${celebrityName}님의 마음 깊은 곳까지 스며들어 공명을 일으킵니다. 말하지 않아도 느껴지는 이 교감은, 두 분의 영혼이 같은 주파수로 진동하고 있음을 보여주는 증거입니다. 눈빛 하나, 미소 하나에서도 서로의 마음을 읽을 수 있는 특별한 연결이 느껴집니다.`,
      physical_harmony: `두 분의 에너지가 만나면 마치 봄바람이 꽃잎을 흔드는 것처럼 자연스러운 조화가 이루어집니다. ${userName}님의 木 에너지는 생명력과 성장을, ${celebrityName}님의 火 에너지는 열정과 빛을 상징하죠. 이 두 에너지가 어우러질 때, 마치 나무에서 꽃이 피어나듯 아름다운 시너지가 탄생합니다. 서로의 존재만으로도 활력이 넘치고, 함께할 때 더욱 빛나는 관계입니다. 음양의 조화로운 흐름이 두 분 사이에 자연스럽게 형성되어 있어요.`,
      intimate_advice: `두 분의 더 깊은 유대를 위해서는 서로의 리듬을 존중하는 것이 중요합니다. 급하게 다가가기보다는 달이 차오르듯 천천히, 자연스럽게 마음의 거리를 좁혀가세요. 특히 저녁 시간대에 ${celebrityName}님의 작품을 감상하며 그 에너지를 느껴보는 것이 두 분의 연결을 더욱 깊게 할 것입니다.`
    },

    detailed_analysis: {
      personality_match: `${userName}님과 ${celebrityName}님의 성격적 조화는 마치 달과 별의 관계와 같습니다. ${userName}님이 가진 섬세하고 깊은 감성은 ${celebrityName}님의 밝고 카리스마 넘치는 성격과 만났을 때 서로를 더욱 빛나게 해줍니다. ${userName}님은 ${celebrityName}님의 화려함 속에 숨겨진 진정성을 알아볼 수 있는 안목을 가지고 있으며, ${celebrityName}님 역시 ${userName}님의 조용한 강인함을 높이 평가할 것입니다. 이러한 상호 보완적인 성격 조합은 서로에게 배울 점을 발견하게 해주는 소중한 인연입니다.`,
      energy_compatibility: `두 분의 에너지 궁합은 서로를 보완하고 균형을 맞춰주는 이상적인 조합입니다. ${userName}님의 차분하고 안정적인 에너지는 ${celebrityName}님의 활발하고 역동적인 에너지와 만났을 때 시너지를 만들어냅니다. 마치 바다와 파도처럼, 고요함과 역동성이 함께 어우러져 아름다운 조화를 이루는 것이죠. 이 에너지 조합은 함께 있을 때 서로에게 힘이 되어주고, 지친 마음을 회복시켜주는 치유의 효과가 있습니다.`,
      life_path_connection: `${userName}님과 ${celebrityName}님의 인생 여정에는 놀라운 공통점들이 존재합니다. 두 분 모두 자신만의 길을 개척하려는 강한 의지와 창의적인 표현에 대한 갈망을 가지고 있습니다. 인생에서 추구하는 핵심 가치인 진정성과 성장에 대한 열망도 일치합니다. 비록 걸어가는 길의 형태는 다를 수 있지만, 그 방향성과 목적지는 놀랍도록 유사합니다. 이는 두 분이 비슷한 영혼의 주파수를 가지고 있음을 의미하며, 서로의 여정을 응원하고 이해할 수 있는 특별한 인연임을 보여줍니다.`
    },

    strengths: [
      '서로의 장점을 빛나게 해주는 상호 보완적 관계로, 함께할 때 더 큰 시너지를 만들어냅니다',
      '깊은 정서적 교감이 가능한 궁합으로, 말하지 않아도 서로의 마음을 이해할 수 있습니다',
      '예술과 창의성에 대한 공통된 감성을 가지고 있어 취향과 관심사가 자연스럽게 통합니다',
      '서로에게 긍정적인 영감을 주는 관계로, 함께 성장하고 발전할 수 있는 인연입니다'
    ],

    challenges: [
      '현실과 이상 사이의 균형을 잘 맞추어야 합니다. 지나친 기대보다는 건강한 팬심을 유지하세요',
      '각자의 시간과 공간을 존중하며, 적절한 거리감을 유지하는 것이 관계를 더욱 특별하게 만듭니다',
      '인연의 형태는 다양합니다. 직접적인 만남이 아니어도 영감을 주고받는 것 자체가 소중한 연결입니다'
    ],

    recommendations: [
      `${celebrityName}님의 작품이나 활동을 통해 영감을 얻어보세요. 그 안에서 ${userName}님만의 새로운 발견을 할 수 있습니다`,
      '비슷한 관심사를 가진 팬 커뮤니티와 긍정적으로 교류하며, 건강한 팬 문화를 만들어가보세요',
      '자신만의 특별한 매력과 재능을 발전시켜보세요. ${celebrityName}님도 빛나는 개성을 가진 분을 응원할 거예요',
      '이 특별한 인연을 삶의 긍정적인 에너지원으로 삼아, 자신의 꿈과 목표를 향해 나아가보세요'
    ],

    lucky_factors: {
      best_time_to_connect: '저녁 7시-9시 (酉時)',
      lucky_activity: '음악 감상, 공연 관람, 창작 활동',
      shared_interest: '예술, 음악, 자기 표현',
      lucky_color: '보라색, 금색',
      lucky_direction: '서쪽'
    },

    special_message: `${userName}님, 당신의 빛나는 진심은 이미 우주에 전해지고 있어요. ${celebrityName}님과의 인연은 당신 인생에 아름다운 영감을 선물하기 위해 존재합니다. 이 특별한 연결을 소중히 간직하세요.`
  }
}
