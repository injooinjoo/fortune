/**
 * 가족 변화 운세 (Family Change Fortune) Edge Function
 *
 * @description 가족 내 변화(이사, 결혼, 출산 등)에 대한 운세와 조언을 제공합니다.
 *
 * @endpoint POST /fortune-family-change
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - birthDate?: string - 생년월일
 * - birthTime?: string - 출생 시간
 * - gender?: string - 성별
 * - concern: string - 고민 내용
 * - concern_label: string - 고민 레이블
 * - detailed_questions: string[] - 상세 질문 목록
 * - family_member_count: number - 가족 구성원 수
 * - relationship: string - 관계
 * - special_question?: string - 특별 질문
 * - isPremium?: boolean - 프리미엄 사용자 여부
 * - sajuData?: object - 사주 데이터 (년주, 월주, 일주, 시주)
 *
 * @response FamilyChangeResponse
 * - overallScore: number - 종합 점수 (0-100)
 * - changeAnalysis: object - 변화 분석
 * - timing: object - 시기 분석
 * - recommendations: string[] - 추천사항
 * - warnings: string[] - 주의사항
 * - advice: string - 종합 조언
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "concern": "이사",
 *   "concern_label": "moving",
 *   "detailed_questions": ["이사 시기는 언제가 좋을까요?"],
 *   "family_member_count": 4,
 *   "isPremium": true
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractFamilyCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'
import {
  refundFortuneCharge,
  requirePaidFortuneCaller,
  storeFortuneResult,
  withTokenCharge,
} from '../_shared/fortune_charge.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 서버 차감 게이트 전용 클라이언트 (token RPC + fortune_result_cache 는 service_role 필요)
const fortuneChargeAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
)

interface FamilyMember {
  name?: string;
  birthDate?: string;
  birthTime?: string;
  gender?: string;
  isLunar?: boolean;
  relation?: string;
}

interface FamilyChangeRequest {
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

  // 차감 후 생성이 실패하면 catch 에서 환불하기 위한 핸들
  let paidCharge: { userId: string; idempotencyKey: string } | null = null

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData: FamilyChangeRequest = await req.json()
    const {
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

    // SECURITY: 서버에서 인증 + 토큰 차감. 클라 soul-consume 의존 제거.
    const paidCaller = await requirePaidFortuneCaller(
      req,
      fortuneChargeAdmin,
      'family-change',
      requestData,
    )
    if ('error' in paidCaller) {
      return paidCaller.error
    }
    if (paidCaller.replayed) {
      // TTL 안의 동일 요청 — LLM 재호출 없이 저장된 응답 그대로.
      return new Response(
        JSON.stringify(withTokenCharge(paidCaller.cached, paidCaller.tokenCharge)),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } },
      )
    }
    paidCharge = paidCaller
    // SECURITY: body.userId 는 더 이상 신뢰하지 않는다. JWT 파생 값만 사용.
    const userId = paidCaller.userId

    console.log('🔄 [FamilyChange] User:', userId, '| Members:', family_member_count, '| Premium:', isPremium)
    if (familyMember) {
      console.log('👨‍👩‍👧 [FamilyChange] FamilyMember:', familyMember.name, '|', familyMember.relation)
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
      'moving': '이사/이주',
      'job_change': '직장 변화',
      'family_change': '가족 구성 변화',
      'lifestyle': '생활 방식 변화',
      'timing': '변화 시기'
    }
    const safeDetailedQuestions = detailed_questions || []
    const selectedQuestionLabels = safeDetailedQuestions.map(q => questionLabels[q] || q).join(', ') || '전체'

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId}_family-change_${today}_${safeDetailedQuestions.sort().join('_')}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'family-change')
      .single()

    if (cachedResult) {
      console.log('📦 [FamilyChange] Cache hit')
      const cachedPayload = {
        fortune: cachedResult.result,
        cached: true,
        tokensUsed: 0
      }

      await storeFortuneResult(
        fortuneChargeAdmin,
        paidCaller.idempotencyKey,
        paidCaller.userId,
        'family-change',
        cachedPayload,
      )

      return new Response(
        JSON.stringify(withTokenCharge(cachedPayload, paidCaller.tokenCharge)),
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
    console.log(`🎯 [FamilyChange] Cohort: ${JSON.stringify(cohortData)}`)

    const poolResult = await getFromCohortPool(supabaseClient, 'family-change', cohortHash)

    if (poolResult) {
      console.log('✅ [FamilyChange] Cohort Pool 히트! LLM 호출 생략')

      const personalized = personalize(poolResult, {
        userName: name || '회원님',
        relationship: relationshipLabel,
      })

      const percentileData = await calculatePercentile(supabaseClient, 'family-change', (personalized as any).overallScore || 75)
      const resultWithPercentile = addPercentileToResult(personalized, percentileData)

      const cohortPayload = {
        success: true,
        data: resultWithPercentile,
        cohortHit: true,
      }

      await storeFortuneResult(
        fortuneChargeAdmin,
        paidCaller.idempotencyKey,
        paidCaller.userId,
        'family-change',
        cohortPayload,
      )

      return new Response(
        JSON.stringify(withTokenCharge(cohortPayload, paidCaller.tokenCharge)),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }
    // ===== Cohort Pool 미스 - LLM 호출 진행 =====

    // LLM 호출
    const llm = await LLMFactory.createFromConfigAsync('family-change')

    const systemPrompt = `당신은 가족 변화 인사이트 전문 상담사입니다.
한국의 전통적인 사주 관점과 현대적인 변화 관리 조언을 결합하여 따뜻하고 실용적인 변화 인사이트를 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (전체 변화운 점수),
  "content": "오늘의 변화운 종합 분석 (400자 내외, 사주 분석 기반으로 상세하게, 긍정적이고 따뜻한 톤으로)",
  "changeCategories": {
    "moving": {
      "score": 0-100,
      "title": "이사운",
      "description": "주거지 이동과 관련된 운세, 좋은 방향과 시기 (120자 내외)"
    },
    "career": {
      "score": 0-100,
      "title": "전직운",
      "description": "직장 변화와 관련된 운세, 이직/전직 적합성 (120자 내외)"
    },
    "environment": {
      "score": 0-100,
      "title": "환경변화운",
      "description": "생활 환경 변화에 관한 운세, 적응과 안정 방법 (120자 내외)"
    },
    "timing": {
      "score": 0-100,
      "title": "타이밍운",
      "description": "변화의 적절한 시기에 관한 운세, 최적의 결정 시점 (120자 내외)"
    }
  },
  "luckyElements": {
    "direction": "변화에 좋은 방향 (동/서/남/북 중 하나)",
    "color": "변화운을 높이는 색상",
    "number": 행운의 숫자 (1-9),
    "time": "중요한 결정하기 좋은 시간대"
  },
  "timingAdvice": {
    "best_month": "변화에 가장 좋은 달과 그 이유 (80자 내외)",
    "caution_period": "변화 시 주의할 시기와 대처법 (80자 내외)",
    "preparation": "변화 전 반드시 준비할 것들 (100자 내외)"
  },
  "familySynergy": {
    "title": "가족 변화 조화 분석",
    "compatibility": "가족 구성원 간 변화 대응 궁합과 협력 방법 (200자 내외)",
    "strengthPoints": ["가족의 변화 대응 강점 3가지 (각 60자 내외)"],
    "improvementAreas": ["변화 시 개선하면 좋을 점 2가지 (각 60자 내외)"]
  },
  "monthlyFlow": {
    "current": "이번 달 변화운 흐름과 기회 (100자 내외)",
    "next": "다음 달 변화운 전망 (80자 내외)",
    "advice": "시기별 변화 대응 조언 (80자 내외)"
  },
  "familyAdvice": {
    "title": "가족과 함께하는 변화 준비",
    "tips": ["변화에 대비하는 구체적 가족 팁 3가지 (각 80자 내외)"]
  },
  "recommendations": ["긍정적인 변화 조언과 실천 방법 3가지 (각 100자 내외)"],
  "warnings": ["변화 관련 주의사항과 대비법 2가지 (각 80자 내외)"],
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

위 가족 구성원의 사주를 분석하여 변화운을 함께 봐주세요.
` : ''}
[분석 요청일]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

${special_question ? `[특별 질문]\n${special_question}` : ''}

위 정보를 바탕으로 가족의 변화운을 분석해주세요.
변화에 대한 불안을 해소하고 긍정적인 방향으로 안내하는 따뜻한 조언을 포함해주세요.
${special_question ? '특별 질문에 대한 답변도 specialAnswer에 포함해주세요.' : ''}`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 0.8,
      maxTokens: 4096,
      jsonMode: true
    })

    console.log(`✅ [FamilyChange] LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // LLM 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'family-change',
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
      fortuneType: 'family-change',
      score: fortuneData.overallScore,
      content: fortuneData.content,
      summary: `오늘의 가족 변화운 점수는 ${fortuneData.overallScore}점입니다.`,
      advice: fortuneData.recommendations?.[0] || '변화를 두려워하지 말고 가족과 함께 준비하세요.',

      // 기존 필드 유지 (하위 호환성)
      id: `family-change-${Date.now()}`,
      type: 'family-change',
      userId: userId,
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      change_content: fortuneData.content,

      // 변화 카테고리 점수
      changeCategories: fortuneData.changeCategories,

      // 행운의 요소
      luckyElements: fortuneData.luckyElements,
      lucky_items: fortuneData.luckyElements,

      // 타이밍 조언
      timingAdvice: fortuneData.timingAdvice,

      // 가족 변화 조화 분석 (신규)
      familySynergy: fortuneData.familySynergy,

      // 월별 변화운 흐름 (신규)
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
    const percentileData = await calculatePercentile(supabaseClient, 'family-change', result.overallScore)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // ===== Cohort Pool 저장 (fire-and-forget) =====
    saveToCohortPool(supabaseClient, 'family-change', cohortHash, cohortData, result)
      .catch(e => console.error('[FamilyChange] Cohort 저장 오류:', e))

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'family-change',
        user_id: userId,
        result: resultWithPercentile,
        created_at: new Date().toISOString()
      })

    const responsePayload = {
      success: true,
      data: resultWithPercentile,
      cached: false,
      tokensUsed: response.usage?.totalTokens || 0
    }

    await storeFortuneResult(
      fortuneChargeAdmin,
      paidCaller.idempotencyKey,
      paidCaller.userId,
      'family-change',
      responsePayload,
    )

    return new Response(
      JSON.stringify(withTokenCharge(responsePayload, paidCaller.tokenCharge)),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('Error in fortune-family-change:', error)

    // 차감 후 생성 실패 — 환불 후 에러 응답
    if (paidCharge) {
      await refundFortuneCharge(
        fortuneChargeAdmin,
        paidCharge.userId,
        paidCharge.idempotencyKey,
        'family-change',
      )
    }

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
