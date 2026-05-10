/**
 * 가족 건강 운세 (Family Health Fortune) Edge Function
 *
 * @description 가족 구성원의 건강 운세와 건강 관리 조언을 제공합니다.
 *
 * @endpoint POST /fortune-family-health
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - birthDate?: string - 생년월일
 * - birthTime?: string - 출생 시간
 * - gender?: string - 성별
 * - concern: string - 건강 고민 내용
 * - concern_label: string - 고민 레이블
 * - detailed_questions: string[] - 상세 질문 목록
 * - family_member_count: number - 가족 구성원 수
 * - relationship: string - 관계
 * - special_question?: string - 특별 질문
 * - isPremium?: boolean - 프리미엄 사용자 여부
 * - sajuData?: object - 사주 데이터
 *
 * @response FamilyHealthResponse
 * - overallScore: number - 건강 운세 점수 (0-100)
 * - healthAnalysis: object - 건강 분석
 * - preventionTips: string[] - 예방 조언
 * - dietRecommendations: object - 식단 추천
 * - exerciseGuide: object - 운동 가이드
 * - warnings: string[] - 주의사항
 * - advice: string - 종합 조언
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "concern": "가족 건강관리",
 *   "concern_label": "health",
 *   "family_member_count": 4,
 *   "isPremium": true
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import { withFortuneSafetyGuard } from '../_shared/fortune_safety_guard.ts'
import {
  extractFamilyCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

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
  relation?: string;  // parents, spouse, children, siblings
}

interface FamilyHealthRequest {
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
  familyMember?: FamilyMember;  // 선택된 가족 구성원 정보
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

    const requestData: FamilyHealthRequest = await req.json()
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

    console.log('💚 [FamilyHealth] User:', userId, '| Members:', family_member_count, '| Premium:', isPremium)
    if (familyMember) {
      console.log('👨‍👩‍👧 [FamilyHealth] FamilyMember:', familyMember.name, '|', familyMember.relation)
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
      'family_health': '가족 건강 전반',
      'elderly_health': '어르신 건강',
      'children_health': '자녀 건강',
      'pregnancy': '임신/출산',
      'surgery': '수술/치료'
    }
    const safeDetailedQuestions = detailed_questions || []
    const selectedQuestionLabels = safeDetailedQuestions.map(q => questionLabels[q] || q).join(', ') || '전체'

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId}_family-health_${today}_${safeDetailedQuestions.sort().join('_')}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'family-health')
      .single()

    if (cachedResult) {
      console.log('📦 [FamilyHealth] Cache hit')
      return new Response(
        JSON.stringify({
          fortune: cachedResult.result,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ===== Cohort Pool 조회 (API 비용 90% 절감) =====
    const cohortData = extractFamilyCohort({
      relationship,
      detailed_questions,
      concern_label,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`🎯 [FamilyHealth] Cohort: ${JSON.stringify(cohortData)}`)

    const poolResult = await getFromCohortPool(supabaseClient, 'family-health', cohortHash)

    if (poolResult) {
      console.log('✅ [FamilyHealth] Cohort Pool 히트! LLM 호출 생략')

      const personalized = personalize(poolResult, {
        userName: name || '회원님',
        relationship: relationshipLabel,
      })

      const percentileData = await calculatePercentile(supabaseClient, 'family-health', (personalized as any).overallScore || 75)
      const resultWithPercentile = addPercentileToResult(personalized, percentileData)

      return new Response(
        JSON.stringify({
          success: true,
          data: resultWithPercentile,
          cohortHit: true,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }
    // ===== Cohort Pool 미스 - LLM 호출 진행 =====

    // LLM 호출
    const llm = await LLMFactory.createFromConfigAsync('family-health')

    const systemPrompt = `당신은 가족 건강 인사이트 전문 상담사입니다.
한국의 전통적인 사주 관점과 현대적인 건강 조언을 결합하여 따뜻하고 실용적인 가족 건강 인사이트를 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (전체 건강운 점수),
  "content": "오늘의 가족 건강운 종합 분석 (400자 내외, 사주 분석 기반으로 상세하게, 긍정적이고 따뜻한 톤으로)",
  "healthCategories": {
    "physical": {
      "score": 0-100,
      "title": "신체 건강",
      "description": "가족의 신체적 건강에 관한 운세와 구체적 관리법 (120자 내외)"
    },
    "mental": {
      "score": 0-100,
      "title": "정신 건강",
      "description": "마음의 안정과 정서에 관한 운세, 가족 간 정서적 지지 방법 (120자 내외)"
    },
    "vitality": {
      "score": 0-100,
      "title": "활력 운",
      "description": "기력과 에너지에 관한 운세, 활력을 높이는 실천 방법 (120자 내외)"
    },
    "immunity": {
      "score": 0-100,
      "title": "면역력",
      "description": "건강 유지와 회복력에 관한 운세, 면역력 강화 조언 (120자 내외)"
    }
  },
  "luckyElements": {
    "direction": "건강에 좋은 방향 (동/서/남/북 중 하나)",
    "color": "건강운을 높이는 색상",
    "number": 행운의 숫자 (1-9),
    "time": "건강 관리하기 좋은 시간대"
  },
  "seasonalAdvice": {
    "current_season": "현재 계절에 맞는 상세한 건강 조언 (100자 내외)",
    "caution_period": "건강 관리 특별히 주의해야 할 시기와 이유 (80자 내외)",
    "best_activity": "추천 건강 활동과 효과 (80자 내외)"
  },
  "familySynergy": {
    "title": "가족 건강 조화 분석",
    "compatibility": "가족 구성원 간 건강 관리 궁합과 서로 도울 수 있는 방법 (200자 내외)",
    "strengthPoints": ["가족 건강의 강점 3가지 (각 60자 내외)"],
    "improvementAreas": ["개선하면 좋을 건강 습관 2가지 (각 60자 내외)"]
  },
  "monthlyFlow": {
    "current": "이번 달 가족 건강운 흐름과 주의점 (100자 내외)",
    "next": "다음 달 건강운 전망 (80자 내외)",
    "advice": "시기별 건강 관리 조언 (80자 내외)"
  },
  "familyAdvice": {
    "title": "가족과 함께하는 건강 관리",
    "tips": ["가족과 함께 실천할 수 있는 구체적인 건강 팁 3가지 (각 80자 내외)"]
  },
  "recommendations": ["긍정적인 건강 조언과 실천 방법 3가지 (각 100자 내외)"],
  "warnings": ["건강 관련 주의사항과 예방법 2가지 (각 80자 내외)"],
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

위 가족 구성원의 사주를 분석하여 건강운을 함께 봐주세요.
` : ''}
[분석 요청일]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

${special_question ? `[특별 질문]\n${special_question}` : ''}

위 정보를 바탕으로 가족의 건강운을 분석해주세요.
가족 모두의 건강과 안녕을 위한 따뜻하고 실용적인 조언을 포함해주세요.
${special_question ? '특별 질문에 대한 답변도 specialAnswer에 포함해주세요.' : ''}`

    const response = await llm.generate([
      { role: 'system', content: withFortuneSafetyGuard(systemPrompt, { category: 'health' }) },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 0.8,
      maxTokens: 4096,
      jsonMode: true
    })

    console.log(`✅ [FamilyHealth] LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // LLM 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'family-health',
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

    const result = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'family-health',
      score: fortuneData.overallScore,
      content: fortuneData.content,
      summary: `오늘의 가족 건강운 점수는 ${fortuneData.overallScore}점입니다.`,
      advice: fortuneData.recommendations?.[0] || '가족과 함께 건강을 챙기세요.',

      // 기존 필드 유지 (하위 호환성)
      id: `family-health-${Date.now()}`,
      type: 'family-health',
      userId: userId,
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      health_content: fortuneData.content,

      // 건강 카테고리 점수
      healthCategories: fortuneData.healthCategories,

      // 행운의 요소
      luckyElements: fortuneData.luckyElements,
      lucky_items: fortuneData.luckyElements,

      // 계절별 조언
      seasonalAdvice: fortuneData.seasonalAdvice,

      // 가족 조화 분석 (신규)
      familySynergy: fortuneData.familySynergy,

      // 월별 운세 흐름 (신규)
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

      created_at: new Date().toISOString()
    }

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'family-health', result.overallScore)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // ===== Cohort Pool 저장 (fire-and-forget) =====
    saveToCohortPool(supabaseClient, 'family-health', cohortHash, cohortData, result)
      .catch(e => console.error('[FamilyHealth] Cohort 저장 오류:', e))

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'family-health',
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
    const errorMessage = error instanceof Error ? error.message : String(error)
    console.error('Error in fortune-family-health:', error)

    return new Response(
      JSON.stringify({
        error: errorMessage,
        details: String(error)
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
