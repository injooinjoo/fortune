/**
 * 가족 관계 운세 (Family Relationship Fortune) Edge Function
 *
 * @description 가족 구성원 간의 관계 운세와 소통 조언을 제공합니다.
 *
 * @endpoint POST /fortune-family-relationship
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - birthDate?: string - 생년월일
 * - birthTime?: string - 출생 시간
 * - gender?: string - 성별
 * - concern: string - 관계 고민 내용
 * - concern_label: string - 고민 레이블
 * - detailed_questions: string[] - 상세 질문 목록
 * - family_member_count: number - 가족 구성원 수
 * - relationship: string - 관계 유형
 * - special_question?: string - 특별 질문
 * - isPremium?: boolean - 프리미엄 사용자 여부
 * - sajuData?: object - 사주 데이터
 *
 * @response FamilyRelationshipResponse
 * - overallScore: number - 관계 운세 점수 (0-100)
 * - relationshipAnalysis: object - 관계 분석
 * - communicationTips: string[] - 소통 팁
 * - conflictResolution: object - 갈등 해결 가이드
 * - bondingActivities: string[] - 유대감 강화 활동
 * - warnings: string[] - 주의사항
 * - advice: string - 종합 조언
 * - isBlurred: boolean - 블러 상태
 * - blurredSections: string[] - 블러된 섹션 목록
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "concern": "부모님과의 관계",
 *   "concern_label": "parent_relationship",
 *   "relationship": "parent",
 *   "isPremium": false
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface FamilyMember {
  name?: string;
  birthDate?: string;
  birthTime?: string;
  gender?: string;
  isLunar?: boolean;
  relation?: string;
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
  familyMember?: FamilyMember;
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
      familyMember,
      sajuData
    } = requestData

    console.log('💜 [FamilyRelationship] User:', userId, '| Members:', family_member_count, '| Premium:', isPremium)
    if (familyMember) {
      console.log('👨‍👩‍👧 [FamilyRelationship] FamilyMember:', familyMember.name, '|', familyMember.relation)
    }

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
    const safeDetailedQuestions = detailed_questions || []
    const selectedQuestionLabels = safeDetailedQuestions.map(q => questionLabels[q] || q).join(', ') || '전체'

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId}_family-relationship_${today}_${safeDetailedQuestions.sort().join('_')}`

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

    const systemPrompt = `당신은 가족 관계 인사이트 전문 상담사입니다.
한국의 전통적인 사주 관점과 현대적인 가족 심리학을 결합하여 따뜻하고 실용적인 가족 관계 인사이트를 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (전체 관계운 점수),
  "content": "오늘의 가족 관계운 종합 분석 (400자 내외, 사주 분석과 육친론(六親論) 관점으로 상세하게, 긍정적이고 따뜻한 톤으로)",
  "relationshipCategories": {
    "couple": {
      "score": 0-100,
      "title": "부부운",
      "description": "부부 사이의 사랑과 조화에 관한 운세, 부부 관계 개선 방법 (120자 내외)"
    },
    "parentChild": {
      "score": 0-100,
      "title": "부모자녀운",
      "description": "부모와 자녀 간의 유대에 관한 운세, 소통과 이해의 방법 (120자 내외)"
    },
    "siblings": {
      "score": 0-100,
      "title": "형제운",
      "description": "형제자매 간의 우애에 관한 운세, 협력과 화합의 방법 (120자 내외)"
    },
    "harmony": {
      "score": 0-100,
      "title": "화목운",
      "description": "가족 전체의 화합에 관한 운세, 가정 분위기 개선 방법 (120자 내외)"
    }
  },
  "luckyElements": {
    "direction": "관계에 좋은 방향 (동/서/남/북 중 하나)",
    "color": "관계운을 높이는 색상",
    "number": 행운의 숫자 (1-9),
    "time": "가족과 대화하기 좋은 시간대"
  },
  "communicationAdvice": {
    "style": "추천하는 대화 스타일과 구체적 표현법 (100자 내외)",
    "topic": "나누면 좋은 대화 주제와 접근법 (80자 내외)",
    "avoid": "피하면 좋은 대화 주제와 이유 (80자 내외)"
  },
  "familySynergy": {
    "title": "가족 관계 조화 분석",
    "compatibility": "가족 구성원 간 성격 궁합과 서로 이해하는 방법 (200자 내외)",
    "strengthPoints": ["가족 관계의 강점 3가지 (각 60자 내외)"],
    "improvementAreas": ["개선하면 좋을 소통 방법 2가지 (각 60자 내외)"]
  },
  "monthlyFlow": {
    "current": "이번 달 가족 관계운 흐름과 주의점 (100자 내외)",
    "next": "다음 달 관계운 전망 (80자 내외)",
    "advice": "시기별 가족 화합 조언 (80자 내외)"
  },
  "familyAdvice": {
    "title": "가족 화목을 위한 조언",
    "tips": ["가족 관계 개선을 위한 구체적 팁 3가지 (각 80자 내외)"]
  },
  "recommendations": ["긍정적인 관계 조언과 실천 방법 3가지 (각 100자 내외)"],
  "warnings": ["관계 관련 주의사항과 갈등 해소법 2가지 (각 80자 내외)"],
  "specialAnswer": "사용자 특별 질문에 대한 상세한 답변 (있는 경우, 250자 내외)"
}`

    // 가족 구성원 관계 한글화
    const familyRelationLabels: Record<string, string> = {
      'parents': '부모님',
      'spouse': '배우자',
      'children': '자녀',
      'siblings': '형제자매'
    }
    const familyMemberRelationLabel = familyMember?.relation
      ? familyRelationLabels[familyMember.relation] || familyMember.relation
      : null

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
${familyMember ? `
[운세 대상 가족 구성원]
이름: ${familyMember.name || '미제공'}
관계: ${familyMemberRelationLabel || '가족'}
생년월일: ${familyMember.birthDate || '미제공'}${familyMember.isLunar ? ' (음력)' : ''}
${familyMember.birthTime ? `출생 시간: ${familyMember.birthTime}` : ''}
성별: ${familyMember.gender === 'male' ? '남성' : familyMember.gender === 'female' ? '여성' : '미제공'}

위 가족 구성원의 사주를 분석하여 관계운을 함께 봐주세요.
` : ''}
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
      ? ['relationshipCategories', 'communicationAdvice', 'familySynergy', 'monthlyFlow', 'familyAdvice', 'recommendations', 'warnings', 'specialAnswer']
      : []

    const result = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'family-relationship',
      score: fortuneData.overallScore,
      content: fortuneData.content,
      summary: `오늘의 가족 관계운 점수는 ${fortuneData.overallScore}점입니다.`,
      advice: fortuneData.recommendations?.[0] || '가족과 소통하는 시간을 가져보세요.',

      // 기존 필드 유지 (하위 호환성)
      id: `family-relationship-${Date.now()}`,
      type: 'family-relationship',
      userId: userId,
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      relationship_content: fortuneData.content,

      // 관계 카테고리 점수
      relationshipCategories: fortuneData.relationshipCategories,

      // 행운의 요소
      luckyElements: fortuneData.luckyElements,
      lucky_items: fortuneData.luckyElements,

      // 소통 조언
      communicationAdvice: fortuneData.communicationAdvice,

      // 가족 관계 조화 분석 (신규)
      familySynergy: fortuneData.familySynergy,

      // 월별 관계운 흐름 (신규)
      monthlyFlow: fortuneData.monthlyFlow,

      // 가족 조언
      familyAdvice: fortuneData.familyAdvice,

      // 추천/경고
      recommendations: fortuneData.recommendations,
      warnings: fortuneData.warnings,

      // 특별 질문 답변
      specialAnswer: fortuneData.specialAnswer,

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
        success: true,
        data: resultWithPercentile,
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
