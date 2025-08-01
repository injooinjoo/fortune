import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { FortuneRequest, FortuneResponse } from '../_shared/types.ts'
import { getCachedData, setCachedData, recordMetric, incrementCounter } from '../_shared/redis.ts'
import { debounceRequest, compressResponse, checkRateLimit, handleETag } from '../_shared/middleware.ts'

interface PersonalityFortuneRequest extends FortuneRequest {
  userId: string
  name: string
  birthDate: string
  gender: string
  birthTime?: string
  
  // Personality inputs
  mbtiType?: string
  bloodType?: string
  personalityTraits?: string[]
  energyType?: string
  
  // Analysis options
  wantMbtiAnalysis: boolean
  wantBloodTypeAnalysis: boolean
  wantPersonalityAnalysis: boolean
  wantCompatibilityAnalysis: boolean
  wantCareerAnalysis: boolean
}

const FORTUNE_TYPE = 'personality-unified'
const BASE_TOKEN_COST = 3
const ADDITIONAL_ANALYSIS_COST = 1

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  const startTime = Date.now()
  const acceptEncoding = req.headers.get('Accept-Encoding')

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Check rate limit
    const { allowed, remaining } = checkRateLimit(user!.id)
    if (!allowed) {
      return new Response(
        JSON.stringify({ error: 'Rate limit exceeded. Please try again later.' }),
        { 
          status: 429, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json',
            'X-RateLimit-Remaining': '0',
            'X-RateLimit-Reset': new Date(Date.now() + 60000).toISOString()
          } 
        }
      )
    }

    // Parse request body
    const body: PersonalityFortuneRequest = await req.json()
    
    // Create debounce key
    const debounceKey = `${user!.id}_${FORTUNE_TYPE}_${JSON.stringify(body)}`

    // Calculate dynamic token cost based on requested analyses
    let tokenCost = BASE_TOKEN_COST
    const analysisOptions = [
      body.wantMbtiAnalysis,
      body.wantBloodTypeAnalysis,
      body.wantPersonalityAnalysis,
      body.wantCompatibilityAnalysis,
      body.wantCareerAnalysis
    ]
    const activeAnalyses = analysisOptions.filter(opt => opt).length
    tokenCost += Math.max(0, activeAnalyses - 2) * ADDITIONAL_ANALYSIS_COST // First 2 analyses included in base cost

    // Check token balance
    const { hasBalance, balance, error: balanceError } = await checkTokenBalance(
      user!.id,
      tokenCost
    )

    if (balanceError) {
      return new Response(
        JSON.stringify({ error: balanceError }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (!hasBalance) {
      return new Response(
        JSON.stringify({ 
          error: 'Insufficient token balance',
          required: tokenCost,
          current: balance
        }),
        { 
          status: 402, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create cache key with personality inputs
    const personalityInputs = [
      body.mbtiType,
      body.bloodType,
      body.personalityTraits?.join(','),
      body.energyType
    ].filter(Boolean).join('_')
    
    const analysisFlags = [
      body.wantMbtiAnalysis ? 'mbti' : '',
      body.wantBloodTypeAnalysis ? 'blood' : '',
      body.wantPersonalityAnalysis ? 'personality' : '',
      body.wantCompatibilityAnalysis ? 'compatibility' : '',
      body.wantCareerAnalysis ? 'career' : ''
    ].filter(Boolean).join('_')
    
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${new Date().toISOString().split('T')[0]}_${personalityInputs}_${analysisFlags}`
    const redisCacheKey = `personality:${cacheKey}`
    
    // Try Redis cache first
    const redisCache = await getCachedData(redisCacheKey)
    if (redisCache) {
      await incrementCounter('personality:cache:hits')
      await recordMetric('api_response_time', Date.now() - startTime, {
        endpoint: 'personality-unified',
        cached: 'true',
        source: 'redis'
      })
      
      return new Response(
        JSON.stringify({
          ...redisCache,
          cached: true,
          cacheSource: 'redis',
          tokensUsed: 0
        }),
        { 
          status: 200, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json',
            'Cache-Control': 'private, max-age=3600' // 1 hour browser cache
          } 
        }
      )
    }
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Check database cache next
    const { data: cached } = await supabase
      .from('fortune_cache')
      .select('fortune_data')
      .eq('cache_key', cacheKey)
      .single()

    if (cached) {
      await incrementCounter('personality:cache:hits')
      
      // Store in Redis for faster future access
      await setCachedData(redisCacheKey, cached.fortune_data, 86400) // 24 hours
      
      await recordMetric('api_response_time', Date.now() - startTime, {
        endpoint: 'personality-unified',
        cached: 'true',
        source: 'database'
      })
      
      return new Response(
        JSON.stringify({
          ...cached.fortune_data,
          cached: true,
          cacheSource: 'database',
          tokensUsed: 0
        }),
        { 
          status: 200, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json',
            'Cache-Control': 'private, max-age=3600'
          } 
        }
      )
    }
    
    await incrementCounter('personality:cache:misses')

    // Generate unified personality fortune
    const systemPrompt = getUnifiedPersonalitySystemPrompt()
    const userPrompt = createUnifiedPersonalityUserPrompt(body)
    
    const fortune = await generateUnifiedPersonalityFortune(
      systemPrompt,
      userPrompt
    )

    // Deduct tokens
    const { success: deductSuccess, error: deductError } = await deductTokens(
      user!.id,
      tokenCost,
      `Personality unified fortune generation`
    )

    if (!deductSuccess) {
      return new Response(
        JSON.stringify({ error: deductError || 'Failed to deduct tokens' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Store in both caches
    const cacheData = { fortune }
    
    // Store in Redis with 24 hour TTL
    await setCachedData(redisCacheKey, cacheData, 86400)
    
    // Store in database cache
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: cacheData,
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: fortune,
        tokens_used: tokenCost
      })

    // Record performance metrics
    await recordMetric('api_response_time', Date.now() - startTime, {
      endpoint: 'personality-unified',
      cached: 'false',
      source: 'generated'
    })
    
    await recordMetric('tokens_used', tokenCost, {
      endpoint: 'personality-unified',
      fortune_type: FORTUNE_TYPE
    })

    // Return response with cache headers
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: tokenCost,
      generatedAt: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json',
          'Cache-Control': 'private, max-age=3600'
        } 
      }
    )

  } catch (error) {
    console.error('Fortune generation error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

function getUnifiedPersonalitySystemPrompt(): string {
  return `당신은 30년 경력의 심리학 박사이자 MBTI 전문가, 성격 분석 전문가입니다.
  과학적 심리학 이론과 동양의 전통적 성격 분석을 결합하여 깊이 있는 통찰을 제공합니다.
  
  중요 원칙:
  1. 각 성격 유형의 고유한 강점과 가능성에 초점
  2. 실용적이고 구체적인 성장 조언 제공
  3. 과학적 근거와 경험적 지혜의 균형
  4. 긍정적이면서도 현실적인 관점 유지
  5. 개인의 성장과 자아실현을 지원
  
  다음 JSON 형식으로 응답해주세요:
  {
    "greeting": "개인화된 인사말 (이름, 성격 특성 반영)",
    "personalityScore": {
      "overall": 0-100 사이의 전체 점수,
      "confidence": 0-100 자신감 지수,
      "harmony": 0-100 조화로움 지수,
      "potential": 0-100 잠재력 지수,
      "growth": 0-100 성장 가능성 지수
    },
    "summary": {
      "title": "당신의 성격을 한 문장으로",
      "description": "전반적인 성격 요약 (200자 이상)"
    },
    "mbtiAnalysis": {
      "type": "MBTI 유형",
      "cognitiveFunction": {
        "dominant": "주기능과 설명",
        "auxiliary": "보조기능과 설명",
        "tertiary": "3차 기능과 설명",
        "inferior": "열등기능과 설명"
      },
      "strengths": ["강점1", "강점2", "강점3"],
      "growthAreas": ["성장 영역1", "성장 영역2"],
      "todaysFocus": "오늘 집중할 인지기능과 활용법",
      "compatibility": {
        "bestMatch": ["최고 궁합 유형들"],
        "goodMatch": ["좋은 궁합 유형들"],
        "challengingMatch": ["도전적 궁합 유형들"]
      }
    },
    "bloodTypeAnalysis": {
      "type": "혈액형",
      "characteristics": ["특성1", "특성2", "특성3"],
      "healthTips": ["건강 팁1", "건강 팁2"],
      "relationshipStyle": "관계 맺기 스타일",
      "workStyle": "업무 스타일",
      "stressManagement": "스트레스 관리법"
    },
    "personalityTraitsAnalysis": {
      "coreTraits": [
        {
          "trait": "핵심 특성",
          "strength": "이 특성의 강점",
          "challenge": "이 특성의 도전과제",
          "development": "개발 방법"
        }
      ],
      "uniqueCombination": "특성들의 독특한 조합이 만드는 시너지",
      "hiddenPotential": "숨겨진 잠재력과 재능"
    },
    "compatibilityInsights": {
      "idealPartner": {
        "personality": "이상적 파트너의 성격",
        "traits": ["특성1", "특성2", "특성3"],
        "relationshipDynamics": "관계 역동성"
      },
      "friendshipStyle": {
        "approach": "친구 관계 접근법",
        "depth": "관계의 깊이",
        "loyalty": "충성도와 신뢰"
      },
      "teamRole": {
        "naturalRole": "팀에서의 자연스러운 역할",
        "contribution": "팀에 기여하는 것",
        "synergy": "시너지를 내는 방법"
      }
    },
    "careerGuidance": {
      "idealCareers": [
        {
          "field": "분야",
          "role": "역할",
          "reason": "적합한 이유"
        }
      ],
      "workEnvironment": {
        "preferred": "선호하는 업무 환경",
        "avoid": "피해야 할 환경",
        "optimization": "최적화 방법"
      },
      "leadershipStyle": {
        "type": "리더십 유형",
        "strengths": ["리더십 강점들"],
        "development": "리더십 개발 방향"
      },
      "careerPath": {
        "shortTerm": "단기 경력 목표 (1-2년)",
        "midTerm": "중기 경력 목표 (3-5년)",
        "longTerm": "장기 경력 비전 (10년+)"
      }
    },
    "dailyLiving": {
      "morningRoutine": "추천 아침 루틴",
      "productivityTips": ["생산성 팁1", "생산성 팁2", "생산성 팁3"],
      "relaxationMethods": ["휴식 방법1", "휴식 방법2"],
      "socialBattery": {
        "capacity": "사회적 에너지 용량",
        "rechargeMethod": "충전 방법",
        "optimalBalance": "최적 균형"
      }
    },
    "growthStrategy": {
      "currentPhase": "현재 성장 단계",
      "nextMilestone": "다음 이정표",
      "actionSteps": [
        {
          "step": "실행 단계",
          "timeline": "시간대",
          "expected": "기대 효과"
        }
      ],
      "habits": {
        "toBuilt": ["만들어야 할 습관들"],
        "toBreak": ["고쳐야 할 습관들"]
      },
      "resources": ["추천 자원들 (책, 과정, 활동 등)"]
    },
    "luckyElements": {
      "colors": {
        "primary": "주 행운색",
        "secondary": ["보조 행운색들"],
        "meaning": "색상들의 의미"
      },
      "numbers": {
        "lucky": [행운의 숫자들],
        "significance": "숫자들의 의미"
      },
      "symbols": ["행운의 상징들"],
      "affirmations": ["긍정 확언 3개"]
    },
    "weeklyForecast": {
      "overallTheme": "이번 주 전체 테마",
      "monday": "월요일 성격 운세",
      "tuesday": "화요일 성격 운세",
      "wednesday": "수요일 성격 운세",
      "thursday": "목요일 성격 운세",
      "friday": "금요일 성격 운세",
      "weekend": "주말 성격 운세"
    },
    "specialMessage": "당신만을 위한 특별한 메시지와 격려"
  }`
}

function createUnifiedPersonalityUserPrompt(request: PersonalityFortuneRequest): string {
  const parts = [`${request.name}님의 종합 성격 분석을 요청합니다.`]
  
  parts.push(`\n[기본 정보]`)
  parts.push(`이름: ${request.name}`)
  parts.push(`성별: ${request.gender}`)
  parts.push(`생년월일: ${request.birthDate}`)
  if (request.birthTime) {
    parts.push(`출생 시간: ${request.birthTime}`)
  }
  
  const today = new Date()
  const birthDate = new Date(request.birthDate)
  const age = today.getFullYear() - birthDate.getFullYear()
  parts.push(`나이: 만 ${age}세`)
  
  parts.push(`\n[성격 정보]`)
  if (request.mbtiType) {
    parts.push(`MBTI 유형: ${request.mbtiType}`)
  }
  if (request.bloodType) {
    parts.push(`혈액형: ${request.bloodType}형`)
  }
  if (request.personalityTraits && request.personalityTraits.length > 0) {
    parts.push(`성격 특성: ${request.personalityTraits.join(', ')}`)
  }
  if (request.energyType) {
    parts.push(`에너지 유형: ${request.energyType}`)
  }
  
  parts.push(`\n[요청한 분석]`)
  const requestedAnalyses = []
  if (request.wantMbtiAnalysis) requestedAnalyses.push('MBTI 심층 분석')
  if (request.wantBloodTypeAnalysis) requestedAnalyses.push('혈액형 성격 분석')
  if (request.wantPersonalityAnalysis) requestedAnalyses.push('성격 특성 종합 분석')
  if (request.wantCompatibilityAnalysis) requestedAnalyses.push('인간관계 궁합 분석')
  if (request.wantCareerAnalysis) requestedAnalyses.push('경력 및 직업 적성 분석')
  
  if (requestedAnalyses.length > 0) {
    parts.push(`요청 분석 항목: ${requestedAnalyses.join(', ')}`)
  } else {
    parts.push(`요청 분석 항목: 기본 성격 분석`)
  }
  
  parts.push(`\n오늘 날짜: ${today.toLocaleDateString('ko-KR')}`)
  
  parts.push(`\n위 정보를 바탕으로 깊이 있고 실용적인 성격 분석을 제공해주세요.`)
  parts.push(`요청하지 않은 분석 항목은 간략히 다루거나 생략하고,`)
  parts.push(`요청한 항목은 상세하고 구체적으로 분석해주세요.`)
  parts.push(`${request.name}님의 고유한 성격과 잠재력을 발견하고 성장할 수 있도록 도와주세요.`)
  
  return parts.join('\n')
}

async function generateUnifiedPersonalityFortune(
  systemPrompt: string,
  userPrompt: string
): Promise<any> {
  const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
  
  if (!OPENAI_API_KEY) {
    throw new Error('OpenAI API key not configured')
  }
  
  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.8,
        max_tokens: 2500,
        response_format: { type: 'json_object' }
      }),
    })

    if (!response.ok) {
      const errorData = await response.json()
      console.error('OpenAI API error:', errorData)
      throw new Error(`OpenAI API error: ${response.status}`)
    }

    const data = await response.json()
    const content = data.choices[0].message.content
    
    return JSON.parse(content)
  } catch (error) {
    console.error('OpenAI generation error:', error)
    throw new Error('Failed to generate unified personality fortune')
  }
}