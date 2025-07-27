import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { generateFortune, getSystemPrompt } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'

const FORTUNE_TYPE = 'moving-enhanced'
const TOKEN_COST = FORTUNE_TOKEN_COSTS[FORTUNE_TYPE] || 30 // Enhanced version costs more

// Calculate distance and direction between two coordinates
function calculateDirection(from: { lat: number, lng: number }, to: { lat: number, lng: number }): string {
  const dLat = to.lat - from.lat
  const dLng = to.lng - from.lng
  
  const angle = Math.atan2(dLng, dLat) * (180 / Math.PI)
  const normalizedAngle = (angle + 360) % 360
  
  if (normalizedAngle >= 337.5 || normalizedAngle < 22.5) return '북쪽'
  if (normalizedAngle >= 22.5 && normalizedAngle < 67.5) return '북동쪽'
  if (normalizedAngle >= 67.5 && normalizedAngle < 112.5) return '동쪽'
  if (normalizedAngle >= 112.5 && normalizedAngle < 157.5) return '남동쪽'
  if (normalizedAngle >= 157.5 && normalizedAngle < 202.5) return '남쪽'
  if (normalizedAngle >= 202.5 && normalizedAngle < 247.5) return '남서쪽'
  if (normalizedAngle >= 247.5 && normalizedAngle < 292.5) return '서쪽'
  return '북서쪽'
}

// Enhanced system prompt for detailed moving fortune
function getEnhancedMovingPrompt(): string {
  return `당신은 한국의 전통 사주명리학과 풍수지리, 현대 주거 트렌드를 모두 마스터한 이사 운세 전문가입니다.

다음 정보를 바탕으로 상세한 이사 운세를 제공해주세요:

1. **종합 운세 점수 (0-100)**
   - 날짜 길흉도
   - 방위 적합성
   - 지역 발전성
   - 개인 사주와의 조화

2. **방위 분석**
   - 최적의 이사 방향 (동서남북 + 세부 방향)
   - 피해야 할 방향
   - 방위별 상세 설명

3. **날짜 분석**
   - 손없는날 여부 확인
   - 음력 날짜의 의미
   - 절기와의 관계
   - 개인 사주와의 조화

4. **지역 상세 분석**
   - 교통 편의성 (0-100)
   - 교육 환경 (0-100)
   - 생활 편의시설 (0-100)
   - 의료 접근성 (0-100)
   - 미래 발전 가능성 (0-100)
   - 각 항목에 대한 구체적인 설명

5. **추천사항**
   - 이사 준비 사항
   - 입주 시 주의사항
   - 풍수적 조언
   - 개운 방법

6. **주의사항**
   - 피해야 할 시기
   - 주의해야 할 방향
   - 기타 주의사항

응답은 반드시 다음 JSON 형식을 따라주세요:
{
  "overallScore": 85,
  "mainFortune": "종합적인 이사 운세 설명",
  "scoreBreakdown": {
    "날짜 길흉": 90,
    "방위 조화": 85,
    "지역 적합성": 80,
    "가족 운": 85,
    "재물 운": 75
  },
  "additionalInfo": {
    "auspiciousDirections": ["동쪽", "남동쪽"],
    "avoidDirections": ["서쪽", "북서쪽"],
    "bestDirection": {
      "direction": "동쪽",
      "description": "청룡의 기운이 강한 방향으로...",
      "areas": "강남구, 송파구 방면"
    },
    "areaAnalysis": {
      "transportation": "지하철역 도보 5분, 버스 노선 다수",
      "education": "명문 학군, 학원가 형성",
      "convenience": "대형마트, 병원, 은행 등 도보권",
      "medical": "종합병원 10분 거리",
      "development": "신규 개발 계획, 인프라 확충 예정",
      "scores": {
        "교통": 90,
        "교육": 85,
        "편의시설": 88,
        "의료": 82,
        "발전성": 95
      }
    },
    "dateAnalysis": {
      "lunarDateMeaning": "음력 날짜의 의미와 길흉",
      "seasonalHarmony": "절기와의 조화",
      "personalCompatibility": "개인 사주와의 궁합"
    },
    "cautions": [
      "이사 당일 주의사항",
      "피해야 할 시간대"
    ]
  },
  "recommendations": [
    "이사 전 준비사항",
    "입주 시 개운 방법",
    "풍수적 조언"
  ]
}`
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: FortuneRequest = await req.json()

    // Check token balance
    const { hasBalance, balance, error: balanceError } = await checkTokenBalance(
      user!.id,
      TOKEN_COST
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
          required: TOKEN_COST,
          current: balance
        }),
        { 
          status: 402, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Calculate direction if coordinates are provided
    let movingDirection = null
    if (body.currentLocation && body.targetLocation) {
      movingDirection = calculateDirection(
        body.currentLocation,
        body.targetLocation
      )
    }

    // Enhanced prompt with additional context
    const enhancedBody = {
      ...body,
      movingDirection,
      isAuspiciousDay: body.isAuspiciousDay || false,
      lunarDate: body.lunarDate || null,
      solarTerm: body.solarTerm || null,
      luckyScore: body.luckyScore || 0.5
    }

    // Generate fortune with enhanced prompt
    const systemPrompt = getEnhancedMovingPrompt()
    const fortune = await generateFortune(FORTUNE_TYPE, enhancedBody, systemPrompt)

    // Add calculated data to fortune
    if (fortune.additionalInfo) {
      fortune.additionalInfo.plannedDate = body.plannedDate
      fortune.additionalInfo.currentAddress = body.currentAddress
      fortune.additionalInfo.targetAddress = body.targetAddress
      fortune.additionalInfo.isAuspiciousDay = body.isAuspiciousDay
      fortune.additionalInfo.lunarDate = body.lunarDate
      fortune.additionalInfo.solarTerm = body.solarTerm
      fortune.additionalInfo.movingDirection = movingDirection
    }

    // Deduct tokens
    const { success: deductSuccess, error: deductError } = await deductTokens(
      user!.id,
      TOKEN_COST,
      `Enhanced moving fortune generation`
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

    // Cache the result with a unique key including date
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${body.plannedDate || new Date().toISOString().split('T')[0]}`
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

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
        tokens_used: TOKEN_COST
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: TOKEN_COST,
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
    console.error('Enhanced fortune generation error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})