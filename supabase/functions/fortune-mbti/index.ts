/**
 * MBTI 운세 (MBTI Fortune) Edge Function - 4차원 분리 버전
 *
 * @description MBTI 4차원(E/I, N/S, T/F, J/P)별 운세를 생성합니다.
 * 하루 1회 8차원 모두 생성 후 캐싱하여 모든 사용자가 공유합니다.
 *
 * @endpoint POST /fortune-mbti
 *
 * @requestBody
 * - mbti: string - MBTI 유형 (예: "INTJ", "ENFP")
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - userId?: string - 사용자 ID
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response MbtiFortuneResponse
 * - dimensions: DimensionFortune[] - 4개 차원별 운세
 * - overallScore: number - 종합 점수
 * - todayFortune: string - 종합 운세
 * - ...
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

// ==================== 타입 정의 ====================

interface MbtiFortuneRequest {
  mbti: string;
  name: string;
  birthDate: string;
  userId?: string;
  isPremium?: boolean;
  category?: 'overall' | 'love' | 'career' | 'all';  // 카테고리 선택
}

interface DimensionFortune {
  dimension: string;      // "E" | "I" | "N" | "S" | "T" | "F" | "J" | "P"
  title: string;          // "외향형 에너지"
  fortune: string;        // 운세 텍스트 (50자 이내)
  tip: string;            // 조언 (30자 이내)
  score: number;          // 0-100
  warning: string;        // 경고 메시지 (30-50자) - 위기감/긴장감 유발
}

interface MbtiFortuneResponse {
  success: boolean;
  data: {
    // 새로운 4차원 데이터
    dimensions: DimensionFortune[];
    overallScore: number;
    todayTrap: string;    // 오늘의 함정 (위기감 유발 메시지)

    // 기존 호환성 필드
    todayFortune: string;
    loveFortune: string;
    careerFortune: string;
    moneyFortune: string;
    healthFortune: string;
    luckyColor: string;
    luckyNumber: number;
    advice: string;
    compatibility: string[];
    energyLevel: number;
    cognitiveStrengths: string[];
    challenges: string[];
    mbtiDescription: string;
    timestamp: string;
  };
  error?: string;
}

// ==================== 차원별 메타데이터 ====================

const DIMENSION_META: Record<string, { title: string; description: string }> = {
  'E': {
    title: '외향형 에너지',
    description: '사회적 상호작용과 외부 활동에서 에너지를 얻는 성향'
  },
  'I': {
    title: '내향형 에너지',
    description: '독립적 시간과 내면 성찰에서 에너지를 충전하는 성향'
  },
  'N': {
    title: '직관의 영역',
    description: '미래 가능성, 패턴 인식, 큰 그림을 보는 성향'
  },
  'S': {
    title: '감각의 영역',
    description: '현재 순간, 구체적 사실, 실용성을 중시하는 성향'
  },
  'T': {
    title: '사고의 힘',
    description: '논리적 분석, 객관적 판단, 효율성을 추구하는 성향'
  },
  'F': {
    title: '감정의 흐름',
    description: '가치 기반 결정, 공감, 조화를 중시하는 성향'
  },
  'J': {
    title: '계획의 날',
    description: '체계적 계획, 결정, 완료를 선호하는 성향'
  },
  'P': {
    title: '유연의 날',
    description: '유연성, 적응력, 열린 가능성을 선호하는 성향'
  }
}

// MBTI별 특성 (기존 호환성 유지)
const MBTI_CHARACTERISTICS: Record<string, {
  description: string;
  cognitiveStrengths: string[];
  compatibility: string[];
  challenges: string[];
}> = {
  'INTJ': {
    description: '전략가 - 상상력이 풍부하고 전략적인 사고를 하는 계획가',
    cognitiveStrengths: ['전략적 사고', '체계적 계획', '독립적 판단', '미래 지향적'],
    compatibility: ['ENFP', 'ENTP', 'INFJ', 'ISFJ'],
    challenges: ['감정 표현', '즉흥성 부족', '완벽주의']
  },
  'INTP': {
    description: '논리술사 - 지적 호기심이 많고 창의적인 사색가',
    cognitiveStrengths: ['논리적 분석', '창의적 사고', '개념적 이해', '객관적 판단'],
    compatibility: ['ENFJ', 'ESTJ', 'INTJ', 'ISFJ'],
    challenges: ['실행력 부족', '일상 관리', '감정 무시']
  },
  'ENTJ': {
    description: '통솔자 - 대담하고 상상력이 풍부한 강력한 리더',
    cognitiveStrengths: ['리더십', '목표 지향', '전략적 사고', '효율성'],
    compatibility: ['INFP', 'INTP', 'ENFP', 'ISFP'],
    challenges: ['참을성 부족', '타인 감정 무시', '과도한 경쟁심']
  },
  'ENTP': {
    description: '변론가 - 똑똑하고 호기심이 많은 사색가',
    cognitiveStrengths: ['창의적 아이디어', '논리적 토론', '적응력', '열정'],
    compatibility: ['INFJ', 'INTJ', 'ENFJ', 'ISFJ'],
    challenges: ['지속력 부족', '루틴 회피', '세부사항 간과']
  },
  'INFJ': {
    description: '옹호자 - 선의의 옹호자이며 창의적이고 통찰력 있는 이상주의자',
    cognitiveStrengths: ['직관적 통찰', '공감 능력', '계획성', '이상주의'],
    compatibility: ['ENFP', 'ENTP', 'INTJ', 'ISFP'],
    challenges: ['완벽주의', '번아웃', '갈등 회피']
  },
  'INFP': {
    description: '중재자 - 항상 선을 행할 준비가 되어 있는 부드럽고 선량한 이타주의자',
    cognitiveStrengths: ['공감 능력', '창의성', '진정성', '가치 중시'],
    compatibility: ['ENFJ', 'ENTJ', 'ISFJ', 'ESFJ'],
    challenges: ['결정 어려움', '비판 민감', '현실 회피']
  },
  'ENFJ': {
    description: '선도자 - 카리스마 있고 영감을 주는 지도자',
    cognitiveStrengths: ['리더십', '소통 능력', '동기 부여', '공감'],
    compatibility: ['INFP', 'ISFP', 'INTP', 'ISTP'],
    challenges: ['자기희생', '비판 민감', '번아웃']
  },
  'ENFP': {
    description: '활동가 - 열정적이고 창의적인 자유로운 영혼',
    cognitiveStrengths: ['열정', '창의성', '소통', '적응력'],
    compatibility: ['INTJ', 'INFJ', 'ISTJ', 'ISFJ'],
    challenges: ['집중력 부족', '루틴 회피', '감정 기복']
  },
  'ISTJ': {
    description: '현실주의자 - 사실에 근거하여 신뢰할 수 있고 성실한 실용주의자',
    cognitiveStrengths: ['책임감', '신뢰성', '체계성', '세심함'],
    compatibility: ['ESFP', 'ESTP', 'ENFP', 'ISFP'],
    challenges: ['변화 적응', '융통성 부족', '감정 표현']
  },
  'ISFJ': {
    description: '수호자 - 마음이 따뜻하고 성실하며 항상 타인을 보호할 준비가 된 사람',
    cognitiveStrengths: ['배려심', '세심함', '충성심', '실용성'],
    compatibility: ['ESFP', 'ESTP', 'ENFP', 'ENTP'],
    challenges: ['자기주장 부족', '변화 거부', '스트레스 내재화']
  },
  'ESTJ': {
    description: '경영자 - 우수한 관리자이며 계획을 관리하고 사람을 통솔하는 데 탁월함',
    cognitiveStrengths: ['조직력', '리더십', '효율성', '현실감각'],
    compatibility: ['ISFP', 'ISTP', 'INTP', 'INFP'],
    challenges: ['융통성 부족', '감정 경시', '권위주의']
  },
  'ESFJ': {
    description: '집정관 - 매우 충성스럽고 따뜻하며 배려심이 넘치는 협력자',
    cognitiveStrengths: ['협력', '배려', '조화', '실용성'],
    compatibility: ['ISFP', 'ISTP', 'INFP', 'INTP'],
    challenges: ['비판 민감', '갈등 회피', '자기소홀']
  },
  'ISTP': {
    description: '만능재주꾼 - 대담하고 실용적인 실험정신이 풍부한 문제 해결사',
    cognitiveStrengths: ['문제해결', '실용성', '적응력', '독립성'],
    compatibility: ['ESFJ', 'ESTJ', 'ENFJ', 'ESFP'],
    challenges: ['감정 표현', '장기 계획', '타인과의 깊은 관계']
  },
  'ISFP': {
    description: '모험가 - 유연하고 매력적인 예술가 기질의 탐험가',
    cognitiveStrengths: ['예술적 감각', '공감', '유연성', '진정성'],
    compatibility: ['ESFJ', 'ESTJ', 'ENFJ', 'ENTJ'],
    challenges: ['스트레스 관리', '계획성 부족', '갈등 회피']
  },
  'ESTP': {
    description: '사업가 - 영리하고 에너지 넘치며 인식이 뛰어난 사람',
    cognitiveStrengths: ['실행력', '에너지', '사교성', '현실감각'],
    compatibility: ['ISFJ', 'ISTJ', 'INFJ', 'ISFP'],
    challenges: ['장기 계획', '세부사항', '감정 처리']
  },
  'ESFP': {
    description: '연예인 - 자발적이고 열정적이며 사교적인 자유로운 영혼',
    cognitiveStrengths: ['사교성', '열정', '즉흥성', '낙천성'],
    compatibility: ['ISFJ', 'ISTJ', 'INFJ', 'INTJ'],
    challenges: ['집중력', '비판 처리', '장기 목표']
  }
}

// ==================== 헬퍼 함수 ====================

/**
 * MBTI 유형에서 4개 차원 추출
 * @example "ENTJ" → ["E", "N", "T", "J"]
 */
function extractDimensions(mbti: string): string[] {
  return [mbti[0], mbti[1], mbti[2], mbti[3]]
}

/**
 * 8차원 데이터에서 사용자 MBTI에 맞는 4개 추출
 */
function extractUserDimensions(
  mbti: string,
  allDimensions: Record<string, { fortune: string; tip: string; score: number; warning?: string }>
): DimensionFortune[] {
  const userDims = extractDimensions(mbti)

  // 차원별 기본 경고 메시지
  const defaultWarnings: Record<string, string> = {
    'E': '즉흥적인 약속이 중요한 일정과 충돌할 수 있어요',
    'I': '혼자만의 시간에 빠져 중요한 기회를 놓칠 수 있어요',
    'N': '가능성에만 몰두하면 현실적 준비를 놓칠 수 있어요',
    'S': '세부사항에만 집착하면 큰 흐름을 놓칠 수 있어요',
    'T': '논리만 앞세우다 중요한 사람의 마음을 잃을 수 있어요',
    'F': '감정에 휩쓸리면 객관적 판단을 놓칠 수 있어요',
    'J': '분석적으로 고민만 하다가는 큰 기회를 놓칠 수 있어요',
    'P': '즉흥적인 결정이 나중에 후회로 돌아올 수 있어요'
  }

  return userDims.map(dim => ({
    dimension: dim,
    title: DIMENSION_META[dim].title,
    fortune: allDimensions[dim]?.fortune || '오늘은 새로운 가능성이 열리는 날입니다.',
    tip: allDimensions[dim]?.tip || '자신을 믿으세요',
    score: allDimensions[dim]?.score || 70,
    warning: allDimensions[dim]?.warning || defaultWarnings[dim]
  }))
}

/**
 * 4개 차원 점수의 평균 계산
 */
function calculateOverallScore(dimensions: DimensionFortune[]): number {
  const total = dimensions.reduce((sum, d) => sum + d.score, 0)
  return Math.round(total / dimensions.length)
}

/**
 * 4차원 운세를 조합하여 종합 운세 텍스트 생성
 */
function generateCombinedFortune(mbti: string, dimensions: DimensionFortune[]): string {
  const dimMap = Object.fromEntries(dimensions.map(d => [d.dimension, d]))

  // 가장 높은 점수의 차원 찾기
  const bestDim = dimensions.reduce((best, current) =>
    current.score > best.score ? current : best
  )

  return `오늘 ${mbti}의 가장 빛나는 영역은 '${bestDim.title}'입니다. ${bestDim.fortune}`
}

/**
 * 카테고리별 상세 인사이트 생성
 */
function generateCategoryInsight(
  mbti: string,
  category: string,
  dimensions: DimensionFortune[],
  characteristics: typeof MBTI_CHARACTERISTICS[string]
): {
  title: string;
  content: string;
  tips: string[];
  score: number;
} {
  const dimMap = Object.fromEntries(dimensions.map(d => [d.dimension, d]))
  const avgScore = Math.round(dimensions.reduce((sum, d) => sum + d.score, 0) / dimensions.length)

  // 첫 번째 글자 (E/I), 네 번째 글자 (J/P) 차원 활용
  const energyDim = dimMap[mbti[0]] // E or I
  const lifestyleDim = dimMap[mbti[3]] // J or P
  const perceivingDim = dimMap[mbti[1]] // N or S
  const judgingDim = dimMap[mbti[2]] // T or F

  switch (category) {
    case 'overall':
      return {
        title: '오늘의 종합 인사이트',
        content: `${mbti}인 당신의 오늘은 '${energyDim.title}'의 기운이 강하게 작용합니다. ${energyDim.fortune} 특히 '${lifestyleDim.title}' 영역에서 ${lifestyleDim.tip}`,
        tips: [
          energyDim.tip,
          perceivingDim.tip,
          judgingDim.tip
        ],
        score: avgScore
      }

    case 'love':
      return {
        title: '연애/관계 인사이트',
        content: `${mbti}의 연애 스타일은 '${judgingDim.title}'의 영향을 받습니다. 오늘은 ${judgingDim.fortune} 상대방과의 관계에서 ${characteristics.cognitiveStrengths[1]}를 발휘해보세요. 잘 맞는 유형: ${characteristics.compatibility.slice(0, 2).join(', ')}`,
        tips: [
          judgingDim.tip,
          `${characteristics.compatibility[0]} 유형과의 대화를 시도해보세요`,
          '상대방의 관점에서 생각해보세요'
        ],
        score: judgingDim.score
      }

    case 'career':
      return {
        title: '직장/커리어 인사이트',
        content: `${mbti}의 업무 스타일은 '${perceivingDim.title}'와 '${lifestyleDim.title}'의 조합입니다. ${perceivingDim.fortune} 오늘 업무에서는 ${characteristics.cognitiveStrengths[0]}을 활용해보세요.`,
        tips: [
          perceivingDim.tip,
          lifestyleDim.tip,
          `${characteristics.challenges[0]}에 주의하세요`
        ],
        score: Math.round((perceivingDim.score + lifestyleDim.score) / 2)
      }

    case 'all':
    default:
      return {
        title: '전체 상세 인사이트',
        content: `${mbti} 유형의 오늘은 전반적으로 ${avgScore}점입니다.\n\n` +
          `💫 에너지: ${energyDim.fortune}\n` +
          `💡 인식: ${perceivingDim.fortune}\n` +
          `🧠 판단: ${judgingDim.fortune}\n` +
          `📋 생활: ${lifestyleDim.fortune}`,
        tips: dimensions.map(d => d.tip),
        score: avgScore
      }
  }
}

// ==================== 메인 핸들러 ====================

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const { mbti, name, birthDate, userId, isPremium, category = 'overall' }: MbtiFortuneRequest = await req.json()

    console.log(`[MBTI-v2] Request - User: ${userId}, Premium: ${isPremium}, MBTI: ${mbti}, Category: ${category}`)

    // 입력 데이터 검증
    if (!mbti || !name || !birthDate) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'MBTI, 이름, 생년월일이 모두 필요합니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400
        }
      )
    }

    // MBTI 유효성 검증
    const upperMbti = mbti.toUpperCase()
    if (!MBTI_CHARACTERISTICS[upperMbti]) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '유효하지 않은 MBTI 타입입니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400
        }
      )
    }

    const today = new Date().toISOString().split('T')[0]

    // ==================== 1. 전역 차원 캐시 확인 ====================
    const dimensionCacheKey = `mbti_dimensions_${today}`

    const { data: cachedDimensions } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', dimensionCacheKey)
      .eq('fortune_type', 'mbti_dimensions')
      .single()

    let allDimensions: Record<string, { fortune: string; tip: string; score: number; warning?: string }>

    if (cachedDimensions?.result) {
      console.log(`[MBTI-v2] ✅ 캐시 히트 (전역 차원)`)
      allDimensions = cachedDimensions.result as typeof allDimensions
    } else {
      // ==================== 2. 8차원 모두 LLM 생성 ====================
      console.log(`[MBTI-v2] 📡 캐시 미스 - LLM으로 8차원 생성`)

      const llm = await LLMFactory.createFromConfigAsync('mbti')

      const systemPrompt = `당신은 MBTI 인사이트 전문가입니다.
오늘의 인사이트를 MBTI 8개 차원별로 생성해주세요.
특히 각 차원의 약점을 경고하는 "warning" 메시지로 사용자에게 긴장감을 주세요.

각 차원별 특성과 경고 예시:
- E(외향): 사회적 상호작용, 에너지 충전, 활동적 모임
  → 경고: "즉흥적인 약속이 중요한 일정과 충돌할 수 있어요"
- I(내향): 독립적 시간, 깊은 사고, 에너지 보존
  → 경고: "혼자만의 시간에 빠져 중요한 기회를 놓칠 수 있어요"
- N(직관): 미래 가능성, 패턴 인식, 큰 그림, 영감
  → 경고: "가능성에만 몰두하면 현실적 준비를 놓칠 수 있어요"
- S(감각): 현재 순간, 구체적 사실, 실용적 행동
  → 경고: "세부사항에만 집착하면 큰 흐름을 놓칠 수 있어요"
- T(사고): 논리적 분석, 객관적 판단, 효율성
  → 경고: "논리만 앞세우다 중요한 사람의 마음을 잃을 수 있어요"
- F(감정): 가치 기반 결정, 공감, 조화, 인간관계
  → 경고: "감정에 휩쓸리면 객관적 판단을 놓칠 수 있어요"
- J(판단): 계획성, 결정, 완료, 체계적 접근
  → 경고: "분석적으로 고민만 하다가는 큰 기회를 놓칠 수 있어요"
- P(인식): 유연성, 적응, 열린 가능성, 즉흥적 기회
  → 경고: "즉흥적인 결정이 나중에 후회로 돌아올 수 있어요"

다음 JSON 형식으로 정확히 응답해주세요:
{
  "E": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 75, "warning": "30-50자 경고" },
  "I": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 68, "warning": "30-50자 경고" },
  "N": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 82, "warning": "30-50자 경고" },
  "S": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 71, "warning": "30-50자 경고" },
  "T": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 79, "warning": "30-50자 경고" },
  "F": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 85, "warning": "30-50자 경고" },
  "J": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 73, "warning": "30-50자 경고" },
  "P": { "fortune": "50자 이내 운세", "tip": "30자 이내 조언", "score": 77, "warning": "30-50자 경고" },
  "todayTrap": "오늘 가장 피해야 할 함정 (50자 이내, 위기감 있게)",
  "luckyColor": "색상 이름",
  "luckyNumber": 1부터 99 사이 숫자
}

규칙:
- score는 50-95 사이로 설정 (너무 극단적인 점수 피하기)
- fortune은 해당 차원의 특성을 반영한 구체적인 오늘의 운세
- tip은 실행 가능한 짧은 조언
- warning은 해당 차원의 약점/함정을 경고하는 메시지 (위기감+긴장감)
- todayTrap은 오늘 하루 MBTI 성향으로 인해 피해야 할 가장 큰 함정
- fortune/tip은 따뜻하게, warning/todayTrap은 긴장감 있게`

      const userPrompt = `오늘 날짜: ${new Date().toLocaleDateString('ko-KR')}

오늘 하루 MBTI 8개 차원별 운세를 JSON 형식으로 생성해주세요.`

      const response = await llm.generate([
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ], {
        temperature: 0.9,
        maxTokens: 4096,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // LLM 사용량 로깅
      await UsageLogger.log({
        fortuneType: 'mbti_dimensions',
        userId: 'system', // 전역 캐시용이므로 시스템
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: { type: 'daily_dimensions', date: today }
      })

      if (!response.content) {
        throw new Error('LLM API 응답 없음')
      }

      let parsedResponse: typeof allDimensions & { luckyColor?: string; luckyNumber?: number; todayTrap?: string }
      try {
        parsedResponse = JSON.parse(response.content)
      } catch {
        console.error('JSON 파싱 실패:', response.content)
        throw new Error('LLM 응답 JSON 파싱 실패')
      }

      // 기본값 보장 (warning 포함)
      const defaultDim = { fortune: '오늘은 새로운 가능성이 열리는 날입니다.', tip: '자신을 믿으세요', score: 70, warning: '오늘 하루 자신의 성향을 의식해보세요.' }
      allDimensions = {
        E: parsedResponse.E || { ...defaultDim, warning: '즉흥적인 약속이 중요한 일정과 충돌할 수 있어요' },
        I: parsedResponse.I || { ...defaultDim, warning: '혼자만의 시간에 빠져 중요한 기회를 놓칠 수 있어요' },
        N: parsedResponse.N || { ...defaultDim, warning: '가능성에만 몰두하면 현실적 준비를 놓칠 수 있어요' },
        S: parsedResponse.S || { ...defaultDim, warning: '세부사항에만 집착하면 큰 흐름을 놓칠 수 있어요' },
        T: parsedResponse.T || { ...defaultDim, warning: '논리만 앞세우다 중요한 사람의 마음을 잃을 수 있어요' },
        F: parsedResponse.F || { ...defaultDim, warning: '감정에 휩쓸리면 객관적 판단을 놓칠 수 있어요' },
        J: parsedResponse.J || { ...defaultDim, warning: '분석적으로 고민만 하다가는 큰 기회를 놓칠 수 있어요' },
        P: parsedResponse.P || { ...defaultDim, warning: '즉흥적인 결정이 나중에 후회로 돌아올 수 있어요' },
        // 추가 데이터
        _meta: {
          luckyColor: parsedResponse.luckyColor || '파란색',
          luckyNumber: parsedResponse.luckyNumber || 7,
          todayTrap: parsedResponse.todayTrap || '오늘은 자신의 MBTI 성향에 따른 편향된 결정을 주의하세요.'
        } as any
      }

      // ==================== 3. 전역 캐시 저장 ====================
      await supabaseClient
        .from('fortune_cache')
        .insert({
          cache_key: dimensionCacheKey,
          fortune_type: 'mbti_dimensions',
          user_id: null, // 전역 캐시
          result: allDimensions,
          created_at: new Date().toISOString()
        })

      console.log(`[MBTI-v2] ✅ 8차원 캐시 저장 완료`)
    }

    // ==================== 4. 사용자별 4차원 추출 ====================
    const userDimensions = extractUserDimensions(upperMbti, allDimensions)
    const overallScore = calculateOverallScore(userDimensions)
    const todayFortune = generateCombinedFortune(upperMbti, userDimensions)

    // MBTI 특성 정보
    const mbtiCharacteristics = MBTI_CHARACTERISTICS[upperMbti]
    const meta = (allDimensions as any)._meta || { luckyColor: '파란색', luckyNumber: 7 }

    // ==================== 5. 카테고리별 인사이트 생성 ====================
    const categoryInsight = generateCategoryInsight(
      upperMbti,
      category,
      userDimensions,
      mbtiCharacteristics
    )

    console.log(`[MBTI-v2] Category: ${category}, Insight: ${categoryInsight.title}`)

    // ==================== 6. 응답 구성 ====================
    const result = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'mbti',
      score: overallScore,
      content: todayFortune,
      summary: `${upperMbti}의 오늘 종합 점수는 ${overallScore}점입니다.`,
      advice: `오늘의 조언: ${userDimensions.find(d => d.score === Math.max(...userDimensions.map(x => x.score)))?.tip || '자신을 믿으세요.'}`,

      // ✅ 카테고리별 상세 인사이트 (NEW)
      requestedCategory: category,
      categoryInsight,

      // 새로운 4차원 데이터
      dimensions: userDimensions,
      overallScore,
      todayTrap: meta.todayTrap || '오늘은 자신의 MBTI 성향에 따른 편향된 결정을 주의하세요.',

      // 기존 호환성 필드
      todayFortune,
      loveFortune: `${upperMbti}의 연애 운세: ${userDimensions[0].fortune}`, // F/T 차원 기반
      careerFortune: `${upperMbti}의 직장 운세: ${userDimensions[2].fortune}`, // T/F 차원 기반
      moneyFortune: `${upperMbti}의 금전 운세: 안정적인 재정 관리가 필요한 날입니다.`,
      healthFortune: `${upperMbti}의 건강 운세: 무리하지 말고 충분한 휴식을 취하세요.`,
      luckyColor: meta.luckyColor,
      luckyNumber: meta.luckyNumber,
      mbti_advice: `오늘의 조언: ${userDimensions.find(d => d.score === Math.max(...userDimensions.map(x => x.score)))?.tip || '자신을 믿으세요.'}`,
      compatibility: mbtiCharacteristics.compatibility,
      energyLevel: overallScore,
      cognitiveStrengths: mbtiCharacteristics.cognitiveStrengths,
      challenges: mbtiCharacteristics.challenges,
      mbtiDescription: mbtiCharacteristics.description,
      timestamp: new Date().toISOString()
    }

    console.log(`[MBTI-v2] ✅ ${upperMbti} 결과 생성 완료 - 점수: ${overallScore}`)

    // 퍼센타일 계산
    const percentileData = await calculatePercentile(supabaseClient, 'mbti', result.energyLevel)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    return new Response(
      JSON.stringify({
        success: true,
        data: resultWithPercentile
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('MBTI Fortune API Error:', error)

    const errorMessage = error instanceof Error ? error.message : String(error)
    console.error('Error details:', {
      message: errorMessage,
      stack: error instanceof Error ? error.stack : undefined,
    })

    return new Response(
      JSON.stringify({
        success: false,
        error: 'MBTI 인사이트 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        details: Deno.env.get('ENVIRONMENT') === 'development' ? errorMessage : undefined
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
