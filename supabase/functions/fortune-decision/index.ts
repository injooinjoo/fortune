/**
 * 결정 코치 (Decision Coach) Edge Function
 *
 * @description 사용자의 고민을 듣고 개인화된 선택지별 장단점 분석과 AI 추천을 제공합니다.
 * ZPZG Decision Coach Pivot - 개인화 지원 추가
 *
 * @endpoint POST /fortune-decision
 *
 * @requestBody
 * - userId: string - 사용자 ID (개인화 설정 조회용)
 * - question: string - 고민하는 질문
 * - decisionType?: string - 결정 유형 (dating, career, money, wellness, lifestyle, relationship)
 * - options?: string[] - 선택지 (옵션)
 * - isPremium?: boolean - 프리미엄 사용자 여부
 * - saveReceipt?: boolean - 결정 기록 저장 여부
 *
 * @response DecisionResponse
 * - question: string - 원본 질문
 * - options: { option, pros, cons }[] - 선택지별 분석
 * - recommendation: string - AI 추천
 * - decisionReceiptId?: string - 저장된 결정 기록 ID (saveReceipt=true인 경우)
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)
const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

// 코치 설정 인터페이스
interface CoachPreferences {
  tone_preference: 'friendly' | 'professional' | 'adaptive'
  response_length: 'concise' | 'balanced' | 'detailed'
  decision_style: 'logic' | 'empathy' | 'balanced'
  relationship_status?: string
  age_group?: string
}

// 요청 인터페이스
interface DecisionRequest {
  userId?: string
  question: string
  decisionType?: 'dating' | 'career' | 'money' | 'wellness' | 'lifestyle' | 'relationship'
  options?: string[]
  isPremium?: boolean
  saveReceipt?: boolean
}

// 선택지 분석 인터페이스
interface OptionAnalysis {
  option: string
  pros: string[]
  cons: string[]
}

// 응답 인터페이스
interface DecisionResponse {
  success: boolean
  data?: {
    fortuneType: string
    decisionType: string
    question: string
    options: OptionAnalysis[]
    recommendation: string
    confidenceFactors?: string[]
    nextSteps?: string[]
    timestamp: string
    isBlurred: boolean
    blurredSections: string[]
    decisionReceiptId?: string
  }
  error?: string
}

// 기본 코치 설정
const DEFAULT_PREFERENCES: CoachPreferences = {
  tone_preference: 'adaptive',
  response_length: 'balanced',
  decision_style: 'balanced'
}

// 사용자 코치 설정 조회
async function getCoachPreferences(userId?: string): Promise<CoachPreferences> {
  if (!userId) return DEFAULT_PREFERENCES

  try {
    const { data, error } = await supabaseAdmin
      .from('user_coach_preferences')
      .select('tone_preference, response_length, decision_style, relationship_status, age_group')
      .eq('user_id', userId)
      .single()

    if (error || !data) {
      console.log('No preferences found, using defaults')
      return DEFAULT_PREFERENCES
    }

    return data as CoachPreferences
  } catch (error) {
    console.error('Error fetching preferences:', error)
    return DEFAULT_PREFERENCES
  }
}

// 톤 스타일 가이드 생성
function getToneGuide(preferences: CoachPreferences): string {
  const toneGuides = {
    friendly: `## 스타일 가이드 (친구 모드) 🤝
- 친한 친구처럼 편하고 따뜻한 말투
- "~해봐", "~하는 게 좋을 것 같아", "솔직히 말하면" 같은 친근한 표현
- 이모지를 적절히 사용해서 친밀감 표현
- 판단보다는 함께 고민하는 느낌`,

    professional: `## 스타일 가이드 (컨설턴트 모드) 📊
- 전문적이고 객관적인 분석 톤
- "~를 권장드립니다", "~를 고려해보시기 바랍니다" 같은 정중한 표현
- 데이터와 논리에 기반한 조언
- 명확한 근거와 구조화된 분석`,

    adaptive: `## 스타일 가이드 (적응형)
- 질문의 성격에 맞게 톤 조절
- 연애/감정 관련: 공감적이고 따뜻하게
- 커리어/재정 관련: 분석적이고 실용적으로
- 사용자가 편하게 결정할 수 있도록 균형 잡힌 접근`
  }

  return toneGuides[preferences.tone_preference] || toneGuides.adaptive
}

// 결정 스타일 가이드 생성
function getDecisionStyleGuide(preferences: CoachPreferences): string {
  const styleGuides = {
    logic: `- 객관적 데이터와 논리적 분석 중심
- 장단점을 명확한 수치나 비교로 제시
- 감정보다는 실용성과 결과에 초점`,

    empathy: `- 감정과 가치관을 우선 고려
- "어떤 선택이 마음 편할까?"에 초점
- 관계와 감정적 영향 분석 포함`,

    balanced: `- 논리와 감정 모두 균형있게 고려
- 객관적 분석과 함께 감정적 측면도 언급
- 사용자의 가치관에 맞는 맞춤 조언`
  }

  return styleGuides[preferences.decision_style] || styleGuides.balanced
}

// 응답 길이 가이드
function getResponseLengthGuide(preferences: CoachPreferences): string {
  const lengthGuides = {
    concise: '(각 항목 50자 이내, 핵심만 간결하게)',
    balanced: '(각 항목 100자 이내, 적절한 설명 포함)',
    detailed: '(각 항목 150자 이내, 상세한 분석과 예시 포함)'
  }

  return lengthGuides[preferences.response_length] || lengthGuides.balanced
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
    const requestData: DecisionRequest = await req.json()
    const {
      userId,
      question,
      decisionType = 'lifestyle',
      options = [],
      isPremium = false,
      saveReceipt = false
    } = requestData

    if (!question || question.trim().length < 5) {
      throw new Error('고민하는 질문을 5자 이상 입력해주세요.')
    }

    // 사용자 코치 설정 조회
    const preferences = await getCoachPreferences(userId)

    console.log('Decision request:', {
      userId,
      questionLength: question.length,
      decisionType,
      optionsCount: options.length,
      isPremium,
      preferences: preferences.tone_preference,
    })

    // 선택지 텍스트 생성
    const optionsText = options.length > 0
      ? `제시된 선택지: ${options.join(', ')}`
      : '선택지가 명확하지 않다면, 가능한 선택지를 2-3개 추론해서 분석해주세요.'

    // 결정 유형별 컨텍스트
    const decisionTypeContext: Record<string, string> = {
      dating: '연애/관계 고민입니다. 감정적 측면과 실질적 조언을 균형있게 제공해주세요.',
      career: '커리어/직장 관련 고민입니다. 장기적 성장과 현실적 요소를 고려해주세요.',
      money: '재정/소비 관련 결정입니다. 실용적이고 객관적인 분석을 제공해주세요.',
      wellness: '건강/웰빙 관련 고민입니다. 지속가능하고 현실적인 조언을 해주세요.',
      lifestyle: '일상/라이프스타일 결정입니다. 삶의 질과 만족도를 고려해주세요.',
      relationship: '대인관계 고민입니다. 관계의 건강함과 개인의 행복을 함께 고려해주세요.'
    }

    // 개인화된 프롬프트 생성
    const toneGuide = getToneGuide(preferences)
    const decisionStyleGuide = getDecisionStyleGuide(preferences)
    const lengthGuide = getResponseLengthGuide(preferences)

    const prompt = `당신은 사용자의 결정을 돕는 AI 코치입니다.

${toneGuide}

## 결정 스타일
${decisionStyleGuide}

## 고민 유형
${decisionTypeContext[decisionType] || decisionTypeContext.lifestyle}

## 사용자 고민
${question}

${optionsText}

다음 JSON 형식으로 결정 코칭 응답을 제공해주세요 ${lengthGuide}:

\`\`\`json
{
  "options": [
    {
      "option": "선택지 1 이름",
      "pros": ["장점1", "장점2"],
      "cons": ["단점1", "단점2"]
    },
    {
      "option": "선택지 2 이름",
      "pros": ["장점1", "장점2"],
      "cons": ["단점1", "단점2"]
    }
  ],
  "recommendation": "종합적인 코칭 의견과 추천 (최종 결정은 사용자에게 맡기는 톤)",
  "confidenceFactors": ["이 결정에 확신을 가질 수 있는 포인트 1-3개"],
  "nextSteps": ["결정 후 실천할 수 있는 다음 단계 1-3개"]
}
\`\`\`

선택지는 2-4개 사이로 분석해주세요.
반드시 한국어로 작성하고, JSON 형식으로만 응답하세요.`

    // LLM 호출
    const llm = await LLMFactory.createFromConfigAsync('decision')

    const response = await llm.generate([
      {
        role: 'system',
        content: '당신은 객관적이고 분석적인 AI 결정 도우미입니다. 사용자가 더 나은 결정을 내릴 수 있도록 균형 잡힌 정보를 제공합니다.'
      },
      {
        role: 'user',
        content: prompt
      }
    ], {
      temperature: 0.7,
      maxTokens: 2048,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // LLM 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'decision',
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: {
        questionLength: question.length,
        optionsCount: options.length,
        isPremium
      }
    })

    // JSON 파싱
    let parsedResponse: any
    try {
      parsedResponse = JSON.parse(response.content)
    } catch (error) {
      console.error('JSON parsing error:', error)
      // Fallback 응답
      parsedResponse = {
        options: [
          {
            option: '선택지 A',
            pros: ['익숙함', '안정성'],
            cons: ['변화 없음', '새로운 기회 제한']
          },
          {
            option: '선택지 B',
            pros: ['새로운 가능성', '성장 기회'],
            cons: ['불확실성', '적응 필요']
          }
        ],
        recommendation: '두 선택지 모두 장단점이 있어요. 현재 상황과 장기적 목표를 고려해서 결정해보세요.',
        confidenceFactors: ['충분히 고민한 후의 결정은 대부분 옳습니다'],
        nextSteps: ['선택한 후에는 뒤돌아보지 말고 전진하세요']
      }
    }

    // Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred ? ['options', 'recommendation', 'nextSteps'] : []

    // 결정 기록 저장 (saveReceipt=true인 경우)
    let decisionReceiptId: string | undefined
    if (saveReceipt && userId) {
      try {
        const { data: receiptData, error: receiptError } = await supabaseAdmin
          .from('decision_receipts')
          .insert({
            user_id: userId,
            decision_type: decisionType,
            question,
            chosen_option: parsedResponse.options?.[0]?.option || '',  // 첫 번째 옵션 기본 저장
            options_analyzed: parsedResponse.options,
            ai_recommendation: parsedResponse.recommendation,
            follow_up_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),  // 7일 후
            metadata: {
              preferences_used: preferences.tone_preference,
              options_count: options.length
            }
          })
          .select('id')
          .single()

        if (!receiptError && receiptData) {
          decisionReceiptId = receiptData.id
          console.log('Decision receipt saved:', decisionReceiptId)
        }
      } catch (receiptError) {
        console.error('Failed to save decision receipt:', receiptError)
        // 저장 실패해도 응답은 반환
      }
    }

    // 응답 데이터 구조화
    const decisionData = {
      fortuneType: 'decision',
      decisionType,
      question,
      options: parsedResponse.options || [],
      recommendation: parsedResponse.recommendation || '신중하게 고려해보세요.',
      confidenceFactors: parsedResponse.confidenceFactors || [],
      nextSteps: parsedResponse.nextSteps || [],
      timestamp: new Date().toISOString(),
      isBlurred,
      blurredSections,
      ...(decisionReceiptId && { decisionReceiptId })
    }

    // 성공 응답
    const successResponse: DecisionResponse = {
      success: true,
      data: decisionData
    }

    return new Response(JSON.stringify(successResponse), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Decision Error:', error)

    const errorResponse: DecisionResponse = {
      success: false,
      error: error instanceof Error ? error.message : '결정 분석 중 오류가 발생했습니다.'
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
