import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { generateFortune } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'
import { getSoulAmount, isPremiumFortune, SoulActionType, getSoulActionType } from '../_shared/soul-rates.ts'

interface ExLoverEnhancedRequest extends FortuneRequest {
  // 기본 정보 (Step 1)
  name: string
  birthDate: string
  gender: 'male' | 'female'
  mbtiType?: string
  
  // 관계 정보 (Step 2)
  relationshipDuration: string
  breakupReason: string
  timeSinceBreakup: string
  currentFeeling: string
  stillInContact: boolean
  hasUnresolvedFeelings: boolean
  lessonsLearned?: string[]
  currentStatus: string
  readyForNewRelationship: boolean
  
  // 추가 분석 (Step 3)
  useImageAnalysis?: boolean
  uploadedImages?: string[] // Base64 encoded images
  useInstagramAnalysis?: boolean
  instagramLink?: string
  useStoryConsultation?: boolean
  detailedStory?: string
}

const FORTUNE_TYPE = 'ex-lover'
const BASE_SOUL_COST = 12 // 기본 분석 비용

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: ExLoverEnhancedRequest = await req.json()

    // Calculate total soul cost
    let totalSoulCost = BASE_SOUL_COST
    if (body.useImageAnalysis) totalSoulCost += 10
    if (body.useInstagramAnalysis) totalSoulCost += 15
    if (body.useStoryConsultation) totalSoulCost += 30

    // Check soul balance (영혼은 마이너스이므로 절대값으로 체크)
    const { hasBalance, balance, error: balanceError } = await checkTokenBalance(
      user!.id,
      Math.abs(totalSoulCost)
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
          required: Math.abs(totalSoulCost),
          current: balance
        }),
        { 
          status: 402, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check cache first for basic analysis
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${FORTUNE_TYPE}_enhanced_${user!.id}_${today}`
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Generate fortune with enhanced features
    const systemPrompt = getEnhancedSystemPrompt(body)
    const userPrompt = createEnhancedUserPrompt(body)
    
    let analysisResults: any = {}
    
    // 이미지 분석
    if (body.useImageAnalysis && body.uploadedImages) {
      analysisResults.imageAnalysis = await analyzeImages(body.uploadedImages)
    }
    
    // 인스타그램 분석 (실제 구현에서는 프록시 서버 필요)
    if (body.useInstagramAnalysis && body.instagramLink) {
      analysisResults.instagramAnalysis = await analyzeInstagram(body.instagramLink)
    }
    
    // AI 운세 생성
    const fortune = await generateEnhancedFortune(
      FORTUNE_TYPE, 
      body, 
      systemPrompt,
      userPrompt,
      analysisResults
    )

    // Deduct souls (영혼은 마이너스로 소비)
    const { success: deductSuccess, error: deductError } = await deductTokens(
      user!.id,
      Math.abs(totalSoulCost),
      `Ex-lover enhanced fortune generation`
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
        fortune_type: `${FORTUNE_TYPE}_enhanced`,
        fortune_data: { fortune, analysisResults },
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: `${FORTUNE_TYPE}_enhanced`,
        fortune_data: fortune,
        tokens_used: Math.abs(totalSoulCost)
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString(),
        analysisResults // 추가 분석 결과 포함
      },
      tokensUsed: Math.abs(totalSoulCost),
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

function getEnhancedSystemPrompt(request: ExLoverEnhancedRequest): string {
  const basePrompt = `당신은 헤어진 애인 관련 운세와 상담을 전문으로 하는 30년 경력의 전문 상담사이자 심리학 박사입니다.
  깊은 공감 능력과 전문적인 심리 분석 능력을 갖추고 있으며, 개인의 감정을 섬세하게 이해합니다.
  
  중요 원칙:
  1. 사용자의 감정을 깊이 이해하고 공감하며, 판단하지 않습니다
  2. 현실적이면서도 희망적인 관점을 균형있게 제시합니다
  3. 구체적이고 실행 가능한 조언을 제공합니다
  4. 심리학적 통찰을 바탕으로 한 전문적인 분석을 제공합니다
  5. MBTI 성격 유형을 고려한 맞춤형 조언을 제공합니다
  
  다음 JSON 형식으로 응답해주세요:
  {
    "greeting": "개인화된 따뜻한 인사말 (이름과 현재 감정 상태를 반영)",
    "emotionalState": {
      "current": "현재 감정 상태에 대한 깊이 있는 분석 (최소 3문장)",
      "healing": "치유 단계 (1-5단계: 1=부정, 2=분노, 3=타협, 4=우울, 5=수용)",
      "progress": 0-100 퍼센트 (세밀하게 계산),
      "emotionalPattern": "감정의 패턴과 변화 양상 분석",
      "hiddenFeelings": "표면에 드러나지 않은 숨겨진 감정들"
    },
    "relationshipAnalysis": {
      "whyItEnded": "이별의 근본 원인에 대한 심층 분석 (표면적 이유와 심층적 이유 구분)",
      "lessonsLearned": "관계에서 배운 점들 (성장의 관점에서 구체적으로)",
      "unfinishedBusiness": "미해결된 감정들과 그 원인",
      "attachmentStyle": "애착 유형 분석과 관계 패턴",
      "growthOpportunities": "이 경험을 통한 성장 기회들"
    },
    "reunionPossibility": {
      "percentage": 0-100,
      "factors": [
        ["긍정적 요인 3-5개 (구체적으로)"],
        ["부정적 요인 3-5개 (구체적으로)"]
      ],
      "advice": "재회에 대한 현실적이고 균형잡힌 조언",
      "timing": "재회를 고려할 수 있는 적절한 시기",
      "conditions": "건강한 재회를 위한 전제 조건들"
    },
    "exPartnerAnalysis": {
      "currentState": "상대방의 현재 예상 감정 상태",
      "likelyThoughts": "상대방이 가질 법한 생각들",
      "movingOnStatus": "상대방의 회복 진행 상황 추정"
    },
    "movingForward": {
      "readiness": 0-100,
      "nextSteps": ["구체적이고 실행 가능한 단계별 행동 5-7개"],
      "timeline": "예상 회복 기간 (개인차 고려한 범위로)",
      "milestones": ["회복 과정의 주요 이정표들"],
      "selfCareStrategies": ["자기 돌봄 전략들"]
    },
    "todaysFocus": {
      "action": "오늘 반드시 해야 할 구체적인 행동",
      "avoid": "오늘 피해야 할 행동이나 생각",
      "affirmation": "오늘의 개인화된 긍정 확언",
      "miniGoal": "오늘 달성할 수 있는 작은 목표",
      "selfCompassion": "자신에게 보내는 위로의 메시지"
    },
    "personalizedInsights": {
      "mbtiAdvice": "MBTI 성격 유형에 맞는 구체적 조언",
      "ageSpecificGuidance": "연령대를 고려한 조언",
      "uniqueStrengths": "이 사람만의 강점과 활용법"
    },
    "specialAdvice": "이 사람의 상황을 깊이 이해한 특별하고 구체적인 조언 (최소 3문장)",
    "healingActivities": ["개인 맞춤형 치유 활동 5-7개 (구체적인 방법 포함)"],
    "warningSign": "주의해야 할 감정적/행동적 신호들과 대처법",
    "weeklyForecast": {
      "emotionalWeather": "이번 주 감정 날씨 예보",
      "challenges": "예상되는 어려움들",
      "opportunities": "성장의 기회들"
    }
  }`
  
  let additionalContext = ''
  
  if (request.useStoryConsultation && request.detailedStory) {
    additionalContext += `\n\n사연 상담 모드: 사용자가 공유한 상세한 사연을 깊이 있게 분석하고, 
    전문 심리상담사의 관점에서 공감하며 실질적인 조언을 제공하세요.
    사연에서 드러나는 감정의 뉘앙스를 놓치지 말고, 숨겨진 욕구와 두려움을 파악하세요.`
  }
  
  if (request.useImageAnalysis) {
    additionalContext += `\n\n이미지 분석 모드: 제공된 사진 분석 결과를 바탕으로 
    두 사람의 관계 역학과 감정 상태를 해석하세요.`
  }
  
  if (request.useInstagramAnalysis) {
    additionalContext += `\n\n소셜미디어 분석 모드: 상대방의 현재 상태와 마음가짐을 
    공개된 정보를 통해 조심스럽게 해석하세요.`
  }
  
  return basePrompt + additionalContext
}

function createEnhancedUserPrompt(request: ExLoverEnhancedRequest): string {
  const parts = [`${request.name}님의 헤어진 애인 관련 상담 요청입니다.`]
  
  // 기본 정보
  parts.push(`\n[기본 정보]`)
  parts.push(`이름: ${request.name}`)
  parts.push(`성별: ${request.gender === 'male' ? '남성' : '여성'}`)
  parts.push(`생년월일: ${request.birthDate}`)
  if (request.mbtiType) parts.push(`MBTI: ${request.mbtiType}`)
  
  // 관계 정보
  parts.push(`\n[관계 정보]`)
  parts.push(`교제 기간: ${request.relationshipDuration}`)
  parts.push(`이별 이유: ${request.breakupReason}`)
  parts.push(`이별 후 시간: ${request.timeSinceBreakup}`)
  parts.push(`현재 감정: ${request.currentFeeling}`)
  parts.push(`연락 여부: ${request.stillInContact ? '연락 중' : '연락 안 함'}`)
  parts.push(`미련 여부: ${request.hasUnresolvedFeelings ? '미련 있음' : '미련 없음'}`)
  parts.push(`현재 상태: ${request.currentStatus}`)
  parts.push(`새로운 연애 준비: ${request.readyForNewRelationship ? '준비됨' : '아직'}`)
  
  if (request.lessonsLearned && request.lessonsLearned.length > 0) {
    parts.push(`배운 점: ${request.lessonsLearned.join(', ')}`)
  }
  
  // 추가 정보
  if (request.detailedStory) {
    parts.push(`\n[상세 사연]`)
    parts.push(request.detailedStory)
  }
  
  parts.push(`\n위 정보를 바탕으로 공감하고 치유적인 상담을 제공해주세요.`)
  parts.push(`${request.name}님의 아픔을 이해하고, 희망적이지만 현실적인 조언을 해주세요.`)
  
  return parts.join('\n')
}

async function analyzeImages(images: string[]): Promise<any> {
  // OpenAI Vision API를 사용한 이미지 분석 로직
  // 실제 구현에서는 Vision API 호출
  return {
    emotionalState: "분석된 감정 상태",
    bodyLanguage: "바디랭귀지 분석",
    relationshipDynamic: "관계 역학 분석",
    overallMood: "전반적인 분위기"
  }
}

async function analyzeInstagram(instagramLink: string): Promise<any> {
  // 인스타그램 공개 정보 분석 로직
  // 실제 구현에서는 프록시 서버를 통한 크롤링 필요
  return {
    currentMood: "현재 기분 상태",
    recentActivity: "최근 활동 패턴",
    socialEngagement: "소셜 참여도",
    lifestyleChanges: "라이프스타일 변화"
  }
}

async function generateEnhancedFortune(
  fortuneType: string,
  request: ExLoverEnhancedRequest,
  systemPrompt: string,
  userPrompt: string,
  analysisResults: any
): Promise<any> {
  const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
  
  if (!OPENAI_API_KEY) {
    throw new Error('OpenAI API key not configured')
  }
  
  // 분석 결과를 프롬프트에 포함
  let enhancedUserPrompt = userPrompt
  
  if (analysisResults.imageAnalysis) {
    enhancedUserPrompt += `\n\n[이미지 분석 결과]\n${JSON.stringify(analysisResults.imageAnalysis, null, 2)}`
  }
  
  if (analysisResults.instagramAnalysis) {
    enhancedUserPrompt += `\n\n[인스타그램 분석 결과]\n${JSON.stringify(analysisResults.instagramAnalysis, null, 2)}`
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
          { role: 'user', content: enhancedUserPrompt }
        ],
        temperature: 0.8,
        max_tokens: 2000,
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
    throw new Error('Failed to generate enhanced fortune')
  }
}