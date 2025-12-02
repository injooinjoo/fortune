import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface FamilyRelationshipRequest {
  userId: string;
  name?: string;
  birthDate?: string;
  birthTime?: string;
  gender?: string;
  concern: string;
  concern_label: string;
  detailed_questions: string[];
  family_member_count: number;
  relationship: string;
  special_question?: string;
  isPremium?: boolean;
  sajuData?: {
    year_pillar?: string;
    month_pillar?: string;
    day_pillar?: string;
    hour_pillar?: string;
    day_master?: string;
    five_elements?: any;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData: FamilyRelationshipRequest = await req.json()
    const {
      userId,
      name,
      birthDate,
      birthTime,
      gender,
      concern,
      concern_label,
      detailed_questions,
      family_member_count,
      relationship,
      special_question,
      isPremium = false,
      sajuData
    } = requestData

    console.log('💜 [FamilyRelationship] User:', userId, '| Members:', family_member_count, '| Premium:', isPremium)

    // 관계 레이블 매핑
    const relationshipLabels: Record<string, string> = {
      'self': '본인',
      'parent': '부모님',
      'child': '자녀',
      'spouse': '배우자'
    }
    const relationshipLabel = relationshipLabels[relationship] || '가족'

    // 세부 질문 레이블 매핑
    const questionLabels: Record<string, string> = {
      'couple': '부부 관계',
      'parent_child': '부모-자녀',
      'siblings': '형제자매',
      'in_laws': '시댁/친정',
      'conflict': '갈등 해결'
    }
    const selectedQuestionLabels = detailed_questions.map(q => questionLabels[q] || q).join(', ')

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId}_family-relationship_${today}_${detailed_questions.sort().join('_')}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'family-relationship')
      .single()

    if (cachedResult) {
      console.log('📦 [FamilyRelationship] Cache hit')
      return new Response(
        JSON.stringify({
          fortune: cachedResult.result,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // LLM 호출
    const llm = await LLMFactory.createFromConfigAsync('family-relationship')

    const systemPrompt = `당신은 가족 관계운 전문 운세 상담사입니다.
한국의 전통적인 사주/운세 관점과 현대적인 가족 심리학을 결합하여 따뜻하고 실용적인 가족 관계 운세를 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (전체 관계운 점수),
  "content": "오늘의 가족 관계운 종합 분석 (150자 내외, 긍정적이고 따뜻한 톤으로)",
  "relationshipCategories": {
    "couple": {
      "score": 0-100,
      "title": "부부운",
      "description": "부부 사이의 사랑과 조화에 관한 운세 (50자 내외)"
    },
    "parentChild": {
      "score": 0-100,
      "title": "부모자녀운",
      "description": "부모와 자녀 간의 유대에 관한 운세 (50자 내외)"
    },
    "siblings": {
      "score": 0-100,
      "title": "형제운",
      "description": "형제자매 간의 우애에 관한 운세 (50자 내외)"
    },
    "harmony": {
      "score": 0-100,
      "title": "화목운",
      "description": "가족 전체의 화합에 관한 운세 (50자 내외)"
    }
  },
  "luckyElements": {
    "direction": "관계에 좋은 방향 (동/서/남/북 중 하나)",
    "color": "관계운을 높이는 색상",
    "number": 행운의 숫자 (1-9),
    "time": "가족과 대화하기 좋은 시간대"
  },
  "communicationAdvice": {
    "style": "추천하는 대화 스타일",
    "topic": "나누면 좋은 대화 주제",
    "avoid": "피하면 좋은 대화 주제"
  },
  "familyAdvice": {
    "title": "가족 화목을 위한 조언",
    "tips": ["가족 관계 개선을 위한 팁 3가지 (각 30자 내외)"]
  },
  "recommendations": ["긍정적인 관계 조언 3가지 (각 40자 내외)"],
  "warnings": ["관계 관련 주의사항 2가지 (각 30자 내외)"],
  "specialAnswer": "사용자 특별 질문에 대한 답변 (있는 경우, 100자 내외)"
}`

    const userPrompt = `[사용자 정보]
이름: ${name || '익명'}
생년월일: ${birthDate || '미제공'}
${birthTime ? `출생 시간: ${birthTime}` : ''}
성별: ${gender === 'male' ? '남성' : gender === 'female' ? '여성' : '미제공'}
${sajuData?.day_master ? `일주(日主): ${sajuData.day_master}` : ''}

[가족 정보]
가족 구성원 수: ${family_member_count}명
운세 대상: ${relationshipLabel}
관심 분야: ${selectedQuestionLabels}

[분석 요청일]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

${special_question ? `[특별 질문]\n${special_question}` : ''}

위 정보를 바탕으로 가족 관계운을 분석해주세요.
가족 간의 화목과 사랑을 위한 따뜻하고 실용적인 조언을 포함해주세요.
${special_question ? '특별 질문에 대한 답변도 specialAnswer에 포함해주세요.' : ''}`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 0.8,
      maxTokens: 4096,
      jsonMode: true
    })

    console.log(`✅ [FamilyRelationship] LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // LLM 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'family-relationship',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: {
        family_member_count,
        relationship,
        detailed_questions,
        isPremium
      }
    })

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['relationshipCategories', 'communicationAdvice', 'familyAdvice', 'recommendations', 'warnings', 'specialAnswer']
      : []

    const result = {
      id: `family-relationship-${Date.now()}`,
      type: 'family-relationship',
      userId: userId,
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      content: fortuneData.content,

      // 관계 카테고리 점수
      relationshipCategories: isBlurred ? {
        couple: { score: 0, title: '부부운', description: '🔒 프리미엄 결제 후 확인 가능합니다' },
        parentChild: { score: 0, title: '부모자녀운', description: '🔒 프리미엄 결제 후 확인 가능합니다' },
        siblings: { score: 0, title: '형제운', description: '🔒 프리미엄 결제 후 확인 가능합니다' },
        harmony: { score: 0, title: '화목운', description: '🔒 프리미엄 결제 후 확인 가능합니다' }
      } : fortuneData.relationshipCategories,

      // 행운의 요소
      luckyElements: fortuneData.luckyElements,
      lucky_items: fortuneData.luckyElements,

      // 소통 조언
      communicationAdvice: isBlurred ? {
        style: '🔒 프리미엄 결제 후 확인',
        topic: '🔒 프리미엄 결제 후 확인',
        avoid: '🔒 프리미엄 결제 후 확인'
      } : fortuneData.communicationAdvice,

      // 가족 조언
      familyAdvice: isBlurred ? {
        title: '가족 화목을 위한 조언',
        tips: ['🔒 프리미엄 결제 후 확인 가능합니다']
      } : fortuneData.familyAdvice,

      // 추천/경고
      recommendations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.recommendations,
      warnings: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.warnings,

      // 특별 질문 답변
      specialAnswer: isBlurred
        ? (special_question ? '🔒 프리미엄 결제 후 확인 가능합니다' : null)
        : fortuneData.specialAnswer,

      // 메타데이터
      metadata: {
        concern,
        concern_label,
        detailed_questions,
        family_member_count,
        relationship,
        relationshipLabel,
        special_question: special_question || null
      },

      created_at: new Date().toISOString(),
      isBlurred,
      blurredSections
    }

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'family-relationship', result.overallScore)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'family-relationship',
        user_id: userId,
        result: resultWithPercentile,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        fortune: resultWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('Error in fortune-family-relationship:', error)

    return new Response(
      JSON.stringify({
        error: error.message,
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
