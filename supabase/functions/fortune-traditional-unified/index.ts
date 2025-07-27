import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'
import { getSoulAmount, isPremiumFortune, SoulActionType, getSoulActionType } from '../_shared/soul-rates.ts'

interface TraditionalUnifiedRequest extends FortuneRequest {
  name: string
  birthDate: string
  birthTime?: string
  gender: 'male' | 'female'
  isLunar: boolean
}

const FORTUNE_TYPE = 'traditional-unified'
const SOUL_COST = 15 // 통합 운세는 더 많은 내용을 포함하므로 비용 증가

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: TraditionalUnifiedRequest = await req.json()

    // Check soul balance
    const { hasBalance, balance, error: balanceError } = await checkTokenBalance(
      user!.id,
      Math.abs(SOUL_COST)
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
          error: 'Insufficient soul balance',
          required: Math.abs(SOUL_COST),
          current: balance
        }),
        { 
          status: 402, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check cache first
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${today}`
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: cached } = await supabase
      .from('fortune_cache')
      .select('fortune_data')
      .eq('cache_key', cacheKey)
      .single()

    if (cached) {
      return new Response(
        JSON.stringify({
          ...cached.fortune_data,
          cached: true,
          tokensUsed: 0
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate unified traditional fortune
    const systemPrompt = getUnifiedSystemPrompt()
    const userPrompt = createUnifiedUserPrompt(body)
    
    const fortune = await generateUnifiedFortune(
      FORTUNE_TYPE, 
      body, 
      systemPrompt,
      userPrompt
    )

    // Deduct souls
    const { success: deductSuccess, error: deductError } = await deductTokens(
      user!.id,
      Math.abs(SOUL_COST),
      `Traditional unified fortune generation`
    )

    if (!deductSuccess) {
      return new Response(
        JSON.stringify({ error: deductError || 'Failed to deduct souls' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Cache the result
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: { fortune },
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: fortune,
        tokens_used: Math.abs(SOUL_COST)
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: Math.abs(SOUL_COST),
      generatedAt: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
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

function getUnifiedSystemPrompt(): string {
  return `당신은 50년 경력의 동양철학 대가이자 사주명리학, 주역, 토정비결의 전문가입니다.
  전통적인 지혜를 현대적으로 해석하여 실용적이고 희망적인 조언을 제공합니다.
  
  중요 원칙:
  1. 전통적 해석의 깊이를 유지하면서도 현대인이 이해하기 쉽게 설명
  2. 부정적인 내용도 긍정적 발전 가능성과 함께 제시
  3. 구체적이고 실천 가능한 조언 포함
  4. 매번 다른 구성으로 다양한 인사이트 제공
  
  다음 JSON 형식으로 응답하되, 각 섹션은 풍부하고 다양한 내용을 포함해주세요:
  {
    "greeting": "사용자의 생년월일과 현재 날짜를 반영한 개인화된 인사말",
    "todayTheme": {
      "title": "오늘의 주제 (예: 인내의 날, 도약의 시기, 성찰의 때 등)",
      "description": "주제에 대한 설명",
      "element": "오늘의 주도 오행 (목/화/토/금/수)",
      "hexagram": {
        "name": "오늘의 주역 괘 이름",
        "symbol": "괘 기호",
        "meaning": "괘의 의미"
      }
    },
    "coreReading": {
      "saju": {
        "yearPillar": {
          "stem": "천간",
          "branch": "지지",
          "element": "오행",
          "meaning": "년주가 나타내는 의미"
        },
        "monthPillar": {
          "stem": "천간",
          "branch": "지지",
          "element": "오행",
          "meaning": "월주가 나타내는 의미"
        },
        "dayPillar": {
          "stem": "천간",
          "branch": "지지",
          "element": "오행",
          "meaning": "일주가 나타내는 의미 (가장 중요)"
        },
        "hourPillar": {
          "stem": "천간",
          "branch": "지지",
          "element": "오행",
          "meaning": "시주가 나타내는 의미"
        },
        "dominantElement": "주도하는 오행",
        "lackingElement": "부족한 오행",
        "balance": {
          "wood": 0-100,
          "fire": 0-100,
          "earth": 0-100,
          "metal": 0-100,
          "water": 0-100
        }
      },
      "tojeong": {
        "upperGua": "상괘 이름",
        "lowerGua": "하괘 이름",
        "combinedMeaning": "상하괘 조합의 의미",
        "monthlyMessage": "이번 달의 토정비결 메시지",
        "yearlyTrend": "올해의 전반적 흐름"
      },
      "synthesis": "사주와 토정비결을 종합한 핵심 메시지 (3-4문장)"
    },
    "lifeAspects": [
      // 다음 중 랜덤하게 3-5개 선택하여 포함
      {
        "category": "재물운",
        "reading": "재물운에 대한 상세 해석",
        "currentEnergy": "현재 기운 (상/중/하)",
        "advice": "구체적 조언",
        "luckyFactors": ["행운 요소 1", "행운 요소 2"],
        "timing": "좋은 시기"
      },
      {
        "category": "건강운",
        "reading": "건강운에 대한 상세 해석",
        "vulnerableAreas": ["주의할 신체 부위"],
        "preventiveMeasures": ["예방법"],
        "energyLevel": "에너지 수준"
      },
      {
        "category": "인연운",
        "reading": "인간관계와 인연에 대한 해석",
        "relationshipTheme": "관계의 주제",
        "compatibleTypes": ["잘 맞는 사람 유형"],
        "advice": "인간관계 조언"
      },
      {
        "category": "사업/직업운",
        "reading": "일과 경력에 대한 해석",
        "opportunities": ["기회 요소"],
        "challenges": ["도전 과제"],
        "strategy": "성공 전략"
      },
      {
        "category": "학업/성장운",
        "reading": "배움과 성장에 대한 해석",
        "learningStyle": "효과적인 학습 방법",
        "growthAreas": ["성장 가능 분야"],
        "mentorType": "도움될 스승/멘토 유형"
      }
    ],
    "wisdomOfAncients": {
      // 랜덤하게 고전에서 하나 선택
      "source": "출처 (논어/맹자/주역/명심보감/채근담 중 하나)",
      "originalQuote": "원문",
      "translation": "한글 번역",
      "modernInterpretation": "현대적 해석과 적용",
      "personalApplication": "개인적 적용 방법"
    },
    "seasonalGuidance": {
      "currentSeason": "현재 계절",
      "seasonalEnergy": "계절의 기운 설명",
      "alignment": "계절과 사주의 조화도",
      "recommendations": [
        "계절에 맞는 추천사항 1",
        "계절에 맞는 추천사항 2",
        "계절에 맞는 추천사항 3"
      ]
    },
    "specialInsights": [
      // 랜덤하게 2-3개 선택
      {
        "type": "십신 (비견/겁재/식신/상관/정재/편재/정관/편관/정인/편인 중)",
        "meaning": "십신의 의미",
        "influence": "현재 영향력",
        "guidance": "활용 방법"
      },
      {
        "type": "신살 (천을귀인/문창귀인/역마살/도화살 등)",
        "meaning": "신살의 의미",
        "manifestation": "발현 방식",
        "usage": "활용 또는 주의사항"
      },
      {
        "type": "용신",
        "element": "용신 오행",
        "strengthening": "용신 강화 방법",
        "benefits": "강화시 이점"
      }
    ],
    "traditionalRemedies": {
      "colors": {
        "lucky": ["길한 색상 1", "길한 색상 2"],
        "supportive": ["보조 색상"],
        "avoid": ["피해야 할 색상"]
      },
      "directions": {
        "auspicious": ["길한 방향"],
        "growth": ["성장의 방향"],
        "avoid": ["피해야 할 방향"]
      },
      "numbers": {
        "lucky": [행운의 숫자들],
        "meaningful": [의미있는 숫자들]
      },
      "activities": [
        "추천 활동 1",
        "추천 활동 2",
        "추천 활동 3"
      ],
      "foods": ["몸에 좋은 음식"],
      "avoidances": ["피해야 할 것들"]
    },
    "dailyRitual": {
      "morningPractice": "아침 실천사항",
      "focusMantra": "오늘의 집중 문구",
      "eveningReflection": "저녁 성찰 주제",
      "gratitude": "감사할 것"
    },
    "mysticalElements": {
      // 신비로운 요소 추가 (랜덤)
      "spiritAnimal": "수호 동물",
      "gemstone": "행운의 보석",
      "herb": "도움이 되는 약초",
      "talisman": "부적 또는 상징"
    },
    "weeklyOutlook": {
      "monday": "월요일 운세 한 줄",
      "tuesday": "화요일 운세 한 줄",
      "wednesday": "수요일 운세 한 줄",
      "thursday": "목요일 운세 한 줄",
      "friday": "금요일 운세 한 줄",
      "saturday": "토요일 운세 한 줄",
      "sunday": "일요일 운세 한 줄"
    },
    "closingMessage": "희망적이고 격려하는 마무리 메시지"
  }`
}

function createUnifiedUserPrompt(request: TraditionalUnifiedRequest): string {
  const parts = [`${request.name}님의 전통운세 종합 분석을 요청합니다.`]
  
  parts.push(`\n[기본 정보]`)
  parts.push(`이름: ${request.name}`)
  parts.push(`성별: ${request.gender === 'male' ? '남성' : '여성'}`)
  parts.push(`생년월일: ${request.birthDate} (${request.isLunar ? '음력' : '양력'})`)
  if (request.birthTime) {
    parts.push(`생시: ${request.birthTime}`)
  }
  
  const today = new Date()
  const age = today.getFullYear() - new Date(request.birthDate).getFullYear()
  parts.push(`현재 나이: 만 ${age}세`)
  
  parts.push(`\n오늘 날짜: ${today.toLocaleDateString('ko-KR')}`)
  parts.push(`현재 계절: ${getCurrentSeason()}`)
  
  parts.push(`\n위 정보를 바탕으로 사주명리학, 토정비결, 주역을 종합하여`)
  parts.push(`깊이 있고 실용적인 전통운세를 제공해주세요.`)
  parts.push(`각 섹션은 풍부한 내용을 담되, 현대인이 이해하고 적용하기 쉽게 설명해주세요.`)
  parts.push(`매번 조금씩 다른 구성과 내용으로 신선한 인사이트를 제공해주세요.`)
  
  return parts.join('\n')
}

function getCurrentSeason(): string {
  const month = new Date().getMonth() + 1
  if (month >= 3 && month <= 5) return '봄'
  if (month >= 6 && month <= 8) return '여름'
  if (month >= 9 && month <= 11) return '가을'
  return '겨울'
}

async function generateUnifiedFortune(
  fortuneType: string,
  request: TraditionalUnifiedRequest,
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
        temperature: 0.85, // 약간 높여서 다양성 증가
        max_tokens: 3000, // 충분한 토큰으로 풍부한 내용 생성
        response_format: { type: 'json_object' }
      }),
    })

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.status}`)
    }

    const data = await response.json()
    const content = data.choices[0].message.content
    
    return JSON.parse(content)
  } catch (error) {
    console.error('OpenAI generation error:', error)
    throw new Error('Failed to generate unified fortune')
  }
}