/**
 * 재물운 (Wealth Fortune) Edge Function
 *
 * @description 사주와 설문 응답을 기반으로 종합적인 재물운을 분석합니다.
 *
 * @endpoint POST /fortune-wealth
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - goal: string - 재물 목표 (saving, house, expense, investment, income)
 * - concern: string - 주요 고민 (spending, loss, debt, returns, savings)
 * - income: string - 수입 상태 (increasing, stable, decreasing, irregular)
 * - expense: string - 지출 패턴 (frugal, balanced, spender, variable)
 * - risk: string - 투자 성향 (safe, balanced, aggressive)
 * - interests: string[] - 관심 분야 (stock, crypto, realestate, saving, business, side)
 * - urgency: string - 시급성 (urgent, thisYear, longTerm)
 * - sajuData?: SajuData - 사주 데이터 (선택)
 *
 * @response WealthFortuneResponse
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractWealthCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 사주 데이터 인터페이스
interface SajuData {
  yearPillar: string;
  monthPillar: string;
  dayPillar: string;
  hourPillar: string;
  dayMaster: string;
  fiveElements: {
    목: number;
    화: number;
    토: number;
    금: number;
    수: number;
  };
}

// 요청 인터페이스
interface WealthRequest {
  userId?: string;
  userName?: string;
  isPremium?: boolean;
  goal: string;
  concern: string;
  income: string;
  expense: string;
  risk: string;
  interests: string[];
  urgency: string;
  sajuData?: SajuData;
}

// 레이블 매핑
const GOAL_LABELS: Record<string, string> = {
  saving: '목돈 마련',
  house: '내집 마련',
  expense: '큰 지출 예정',
  investment: '투자 수익',
  income: '안정적 수입',
};

const CONCERN_LABELS: Record<string, string> = {
  spending: '지출 관리',
  loss: '투자 손실',
  debt: '빚/대출',
  returns: '수익률',
  savings: '저축',
};

const INCOME_LABELS: Record<string, string> = {
  increasing: '늘어나는 중',
  stable: '안정적',
  decreasing: '줄어드는 중',
  irregular: '불규칙',
};

const EXPENSE_LABELS: Record<string, string> = {
  frugal: '절약형',
  balanced: '균형형',
  spender: '소비 즐김',
  variable: '기복 있음',
};

const RISK_LABELS: Record<string, string> = {
  safe: '안전 최우선',
  balanced: '균형 추구',
  aggressive: '공격적',
};

const INTEREST_LABELS: Record<string, string> = {
  stock: '주식',
  crypto: '코인',
  realestate: '부동산',
  saving: '저축/예금',
  business: '사업',
  side: '부업/N잡',
};

const URGENCY_LABELS: Record<string, string> = {
  urgent: '급함',
  thisYear: '올해 안에',
  longTerm: '장기적으로',
};

/**
 * 오행과 재물운 분석
 */
function analyzeWealthElements(
  fiveElements: Record<string, number> | undefined,
  dayMaster: string
): { dominantElement: string; wealthElement: string; compatibility: number; insight: string } {
  if (!fiveElements) {
    return {
      dominantElement: '알 수 없음',
      wealthElement: '알 수 없음',
      compatibility: 50,
      insight: '사주 정보가 없어 기본 분석만 제공됩니다.',
    };
  }

  // 가장 강한 오행 찾기
  const elements = ['목', '화', '토', '금', '수'];
  let dominantElement = '토';
  let maxValue = 0;
  for (const el of elements) {
    if ((fiveElements[el] || 0) > maxValue) {
      maxValue = fiveElements[el];
      dominantElement = el;
    }
  }

  // 일간 기반 재물(財)의 오행 찾기
  // 재성: 일간이 극하는 오행 (목→토, 화→금, 토→수, 금→목, 수→화)
  const wealthElementMap: Record<string, string> = {
    '갑': '토', '을': '토',
    '병': '금', '정': '금',
    '무': '수', '기': '수',
    '경': '목', '신': '목',
    '임': '화', '계': '화',
  };
  const wealthElement = wealthElementMap[dayMaster] || '토';

  // 재물 오행 강도로 궁합 점수 계산
  const wealthStrength = fiveElements[wealthElement] || 1.0;
  const compatibility = Math.min(100, Math.round(50 + wealthStrength * 15));

  // 인사이트 생성
  const elementInsights: Record<string, string> = {
    '목': '성장과 발전의 기운이 강해요. 새로운 투자 기회에 눈이 밝습니다.',
    '화': '열정과 추진력이 뛰어나요. 과감한 결정이 재물을 부를 수 있어요.',
    '토': '안정과 축적의 기운이 강해요. 꾸준한 저축이 복을 가져옵니다.',
    '금': '금융과 재테크에 인연이 있어요. 분석적 접근이 유리합니다.',
    '수': '유연하고 변화에 강해요. 다양한 수입원을 만들기 좋아요.',
  };

  return {
    dominantElement,
    wealthElement,
    compatibility,
    insight: elementInsights[dominantElement] || '균형 잡힌 재물 운을 가지고 있어요.',
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

    const requestData: WealthRequest = await req.json()
    const {
      userId,
      userName = '회원',
      isPremium = false,
      goal,
      concern,
      income,
      expense,
      risk,
      interests = [],
      urgency,
      sajuData,
    } = requestData

    console.log('💰 [Wealth Fortune] Premium:', isPremium, '| Goal:', goal, '| Interests:', interests)

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_wealth_${today}_${goal}_${concern}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'wealth')
      .maybeSingle()

    if (cachedResult) {
      const cachedFortune = { ...cachedResult.result }
      if (isPremium && cachedFortune.isBlurred) {
        cachedFortune.isBlurred = false
        cachedFortune.blurredSections = []
      }
      return new Response(
        JSON.stringify({
          fortune: cachedFortune,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ===== Cohort Pool 조회 =====
    const cohortData = extractWealthCohort({ goal, risk, urgency })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`🔍 [Wealth] Cohort: ${cohortHash.slice(0, 8)}...`, cohortData)

    const poolResult = await getFromCohortPool(supabaseClient, 'wealth', cohortHash)

    if (poolResult) {
      console.log(`✅ [Wealth] Cohort Pool HIT - 개인화 적용`)
      const personalizedResult = personalize(poolResult, {
        userName: userName || '회원님',
        goal: GOAL_LABELS[goal] || goal,
        concern: CONCERN_LABELS[concern] || concern,
        income: INCOME_LABELS[income] || income,
        expense: EXPENSE_LABELS[expense] || expense,
        risk: RISK_LABELS[risk] || risk,
        urgency: URGENCY_LABELS[urgency] || urgency,
        interests: interests.map(i => INTEREST_LABELS[i] || i).join(', '),
      })

      // 사주 분석 결과 (로컬 계산)
      const elementAnalysisLocal = analyzeWealthElements(
        sajuData?.fiveElements,
        sajuData?.dayMaster || ''
      )

      // Percentile 계산
      const percentileData = await calculatePercentile(supabaseClient, 'wealth', personalizedResult.overallScore || personalizedResult.score || 70)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      // 블러 로직
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['goalAdvice', 'cashflowInsight', 'concernResolution', 'investmentInsights', 'monthlyFlow', 'actionItems']
        : []

      const finalResult = {
        ...resultWithPercentile,
        elementAnalysis: {
          ...elementAnalysisLocal,
          ...resultWithPercentile.elementAnalysis,
        },
        userId,
        userName,
        surveyData: { goal, concern, income, expense, risk, interests, urgency },
        isBlurred,
        blurredSections,
        created_at: new Date().toISOString(),
      }

      // 결과 캐싱
      await supabaseClient
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          fortune_type: 'wealth',
          user_id: userId || null,
          result: finalResult,
          created_at: new Date().toISOString()
        })

      return new Response(
        JSON.stringify({
          fortune: finalResult,
          cached: false,
          fromCohortPool: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    console.log(`🔄 [Wealth] Cohort Pool MISS - LLM 호출`)

    // LLM 호출
    const llm = await LLMFactory.createFromConfigAsync('wealth')

    // 관심 분야 텍스트 변환
    const interestLabels = interests.map(i => INTEREST_LABELS[i] || i).join(', ')

    const systemPrompt = `당신은 재물운 전문가입니다. 사주 분석과 설문 응답을 바탕으로 개인 맞춤형 재물 인사이트를 제공합니다.

## 사용자 프로필
- 이름: ${userName}
- 재물 목표: ${GOAL_LABELS[goal] || goal}
- 주요 고민: ${CONCERN_LABELS[concern] || concern}
- 수입 상태: ${INCOME_LABELS[income] || income}
- 지출 패턴: ${EXPENSE_LABELS[expense] || expense}
- 투자 성향: ${RISK_LABELS[risk] || risk}
- 관심 분야: ${interestLabels || '미선택'}
- 시급성: ${URGENCY_LABELS[urgency] || urgency}

## 핵심 개인화 원칙 (반드시 준수)
1. **관심 분야 필수 반영**: "${interestLabels}" 각각에 대해 구체적인 분석과 조언을 제공
2. **목표 맞춤 전략**: "${GOAL_LABELS[goal] || goal}" 달성을 위한 실질적인 단계별 전략 제시
3. **성향 차별화**: "${RISK_LABELS[risk] || risk}" 성향에 맞게 보수적/적극적 조언 차별화
4. **시급성 고려**: "${URGENCY_LABELS[urgency] || urgency}" 기준으로 단기/장기 전략 구분
5. **고민 해결**: "${CONCERN_LABELS[concern] || concern}" 우려에 대한 구체적 해결책 포함

## 안전 원칙
- ${userName}님의 이름을 자연스럽게 사용
- 구체적인 투자 종목, 매매 타이밍, 목표가는 절대 언급 금지
- 마음가짐, 재정 습관, 운의 흐름 중심으로 조언
- 모든 재정 결정은 본인의 선택과 책임임을 명시
- 부드러운 표현 사용 ("~하세요" 대신 "~해보시는 건 어떨까요")

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 (종합 재물운 점수),
  "wealthPotential": "상승 기운 | 안정 기운 | 주의 필요",
  "content": "${userName}님을 위한 종합 재물 요약 (200자 내외)",

  "elementAnalysis": {
    "dominantElement": "가장 강한 오행",
    "wealthElement": "재물의 오행",
    "compatibility": 0-100,
    "insight": "오행 기반 재물 인사이트 (100자)",
    "advice": "오행 보충 조언 (80자)"
  },

  "goalAdvice": {
    "primaryGoal": "${GOAL_LABELS[goal] || goal}",
    "timeline": "사주 분석 기반 권장 기간 (예: 1~2년 내)",
    "strategy": "${GOAL_LABELS[goal] || goal} 달성을 위한 구체적 3단계 전략 (200자)",
    "monthlyTarget": "월별 권장 저축/투자액 (사주 기반)",
    "luckyTiming": "유리한 시기와 이유 (예: 3월, 7월 - 금 기운 상승기)",
    "cautionPeriod": "피해야 할 시기 (예: 5월 중순)",
    "sajuAnalysis": "사주에서 본 ${GOAL_LABELS[goal] || goal} 운세 분석 (100자)"
  },

  "cashflowInsight": {
    "incomeEnergy": "상승 | 안정 | 주의",
    "incomeDetail": "수입 흐름 분석 (${INCOME_LABELS[income] || income} 상태 기반, 80자)",
    "expenseWarning": "${EXPENSE_LABELS[expense] || expense} 패턴 기반 지출 주의사항 (80자)",
    "savingTip": "저축 팁 (50자)"
  },

  "concernResolution": {
    "primaryConcern": "${CONCERN_LABELS[concern] || concern}",
    "analysis": "${CONCERN_LABELS[concern] || concern} 우려에 대한 사주 분석 (100자)",
    "solution": "구체적 해결 방안 3가지",
    "mindset": "마음가짐 조언 (50자)",
    "sajuPerspective": "사주 관점에서 본 해결 시기"
  },

  "investmentInsights": {
    ${interests.map(i => {
      if (i === 'realestate') return `"realestate": { "score": 0-100, "analysis": "부동산 운세 분석 (100자)", "recommendedType": "아파트|오피스텔|토지|상가 중 추천", "timing": "매수/계약 유리한 시기", "direction": "사주 기반 추천 방향 (동/서/남/북)", "caution": "부동산 투자 시 주의사항 (80자)", "sajuMatch": "사주와 부동산운 궁합 한 줄" }`;
      if (i === 'side') return `"side": { "score": 0-100, "analysis": "부업운 분석 (100자)", "recommendedAreas": "추천 부업 분야 3가지 (성향 기반)", "incomeExpectation": "예상 월 부수입 범위", "startTiming": "시작하기 좋은 시기", "caution": "부업 시 주의사항", "sajuMatch": "사주와 부업운 궁합 한 줄" }`;
      if (i === 'stock') return `"stock": { "score": 0-100, "analysis": "주식운 분석 (100자)", "style": "추천 투자 스타일 (가치투자|성장주|배당주)", "timing": "진입 유리한 시기", "caution": "주의사항", "sajuMatch": "사주와 주식운 궁합" }`;
      if (i === 'crypto') return `"crypto": { "score": 0-100, "analysis": "코인운 분석 (100자)", "riskLevel": "적정 투자 비중 (%)", "timing": "진입 시기 조언", "caution": "주의사항", "sajuMatch": "사주와 코인운 궁합" }`;
      if (i === 'saving') return `"saving": { "score": 0-100, "analysis": "저축운 분석 (100자)", "recommendedProduct": "추천 저축 유형", "monthlyAmount": "권장 월 저축액", "caution": "주의사항", "sajuMatch": "사주와 저축운 궁합" }`;
      if (i === 'business') return `"business": { "score": 0-100, "analysis": "사업운 분석 (100자)", "recommendedField": "추천 사업 분야", "timing": "창업 적기", "caution": "주의사항", "sajuMatch": "사주와 사업운 궁합" }`;
      return `"${i}": { "score": 0-100, "analysis": "분석 (100자)", "timing": "유리한 시기", "caution": "주의사항", "sajuMatch": "사주 궁합" }`;
    }).join(',\n    ')}
  },

  "luckyElements": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "day": "행운의 요일",
    "time": "행운의 시간대",
    "item": "행운의 아이템",
    "avoid": "피해야 할 것"
  },

  "monthlyFlow": [
    { "week": 1, "energy": "축적기 | 성장기 | 주의기 | 수확기", "advice": "주간 조언" },
    { "week": 2, "energy": "...", "advice": "..." },
    { "week": 3, "energy": "...", "advice": "..." },
    { "week": 4, "energy": "...", "advice": "..." }
  ],

  "actionItems": [
    "✅ 구체적인 실천 항목 1",
    "✅ 구체적인 실천 항목 2",
    "✅ 구체적인 실천 항목 3",
    "⚠️ 피해야 할 행동"
  ],

  "disclaimer": "재정 결정은 본인의 선택과 책임입니다. 이 내용은 재미로 참고하시기 바랍니다."
}`

    // 사주 정보 문자열 생성
    const sajuInfoText = sajuData ? `
[사용자 사주 정보]
일간(Day Master): ${sajuData.dayMaster}
사주: ${sajuData.yearPillar} ${sajuData.monthPillar} ${sajuData.dayPillar} ${sajuData.hourPillar}
오행 분포: 목${sajuData.fiveElements?.목 || 0} 화${sajuData.fiveElements?.화 || 0} 토${sajuData.fiveElements?.토 || 0} 금${sajuData.fiveElements?.금 || 0} 수${sajuData.fiveElements?.수 || 0}
` : '[사주 정보 없음]';

    const userPrompt = `${sajuInfoText}

[오늘]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

## ${userName}님의 재물운 분석 요청

### 반드시 반영해야 할 선택 사항:
1. **주요 목표**: ${GOAL_LABELS[goal] || goal} ← 이 목표 달성 전략이 핵심!
2. **가장 큰 고민**: ${CONCERN_LABELS[concern] || concern} ← 이 우려 해소 방안 필수!
3. **관심 분야**: ${interestLabels || '미선택'} ← 각각에 대한 상세 분석 필수!
4. **투자 성향**: ${RISK_LABELS[risk] || risk} ← 이 성향에 맞는 조언으로!
5. **시급성**: ${URGENCY_LABELS[urgency] || urgency} ← 이 기간에 맞는 전략으로!

### 현재 재정 상태:
- 수입: ${INCOME_LABELS[income] || income}
- 지출: ${EXPENSE_LABELS[expense] || expense}

### 요청 사항:
- "${interestLabels}"에 대해 각각 구체적인 점수와 분석을 제공해주세요
- "${GOAL_LABELS[goal] || goal}" 목표를 위한 실질적인 3단계 전략을 제시해주세요
- "${CONCERN_LABELS[concern] || concern}" 우려에 대한 명확한 해결책을 포함해주세요
- "${RISK_LABELS[risk] || risk}" 성향에 맞게 보수적/적극적 조언을 차별화해주세요
- 사주 정보가 있다면 적극 활용해주세요`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 4096,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'wealth',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: {
        goal,
        concern,
        interests,
        isPremium,
        version: 'v1'
      }
    })

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // 사주 분석 결과 (로컬 계산)
    const elementAnalysisLocal = analyzeWealthElements(
      sajuData?.fiveElements,
      sajuData?.dayMaster || ''
    )

    // 블러 로직
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['goalAdvice', 'cashflowInsight', 'concernResolution', 'investmentInsights', 'monthlyFlow', 'actionItems']
      : []

    const result = {
      // 표준화된 필드
      fortuneType: 'wealth',
      score: fortuneData.overallScore,
      content: fortuneData.content,
      summary: `${userName}님의 재물운 ${fortuneData.overallScore}점`,
      advice: fortuneData.actionItems?.[0] || '신중한 재정 관리를 추천드려요.',

      // 기본 정보
      id: `wealth-${Date.now()}`,
      type: 'wealth',
      version: 'v1',
      userId: userId,
      userName: userName,

      // 점수 및 요약
      overallScore: fortuneData.overallScore,
      wealthPotential: fortuneData.wealthPotential,

      // 오행 분석 (무료)
      elementAnalysis: {
        ...elementAnalysisLocal,
        ...fortuneData.elementAnalysis,
      },

      // 목표 조언 (프리미엄)
      goalAdvice: fortuneData.goalAdvice,

      // 캐시플로우 인사이트 (프리미엄)
      cashflowInsight: fortuneData.cashflowInsight,

      // 고민 해결책 (프리미엄)
      concernResolution: fortuneData.concernResolution,

      // 투자 분야별 분석 (프리미엄)
      investmentInsights: fortuneData.investmentInsights,

      // 행운 요소 (무료)
      luckyElements: fortuneData.luckyElements,

      // 월간 흐름 (프리미엄)
      monthlyFlow: fortuneData.monthlyFlow,

      // 실천 항목 (프리미엄)
      actionItems: fortuneData.actionItems,

      // 면책 문구
      disclaimer: fortuneData.disclaimer || '재정 결정은 본인의 선택과 책임입니다.',

      // 메타데이터
      surveyData: {
        goal,
        concern,
        income,
        expense,
        risk,
        interests,
        urgency,
      },
      created_at: new Date().toISOString(),
      isBlurred,
      blurredSections,
    }

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'wealth', result.overallScore)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // ===== Cohort Pool 저장 (fire-and-forget) =====
    saveToCohortPool(supabaseClient, 'wealth', cohortHash, cohortData, result)
      .catch(e => console.error('[Wealth] Cohort 저장 오류:', e))

    // 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'wealth',
        user_id: userId || null,
        result: result,
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
    console.error('Error in fortune-wealth:', error)

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
