/**
 * 건강 운세 (Health Fortune) Edge Function
 *
 * @description 사주 오행을 기반으로 건강 운세와 양생법을 제공합니다.
 *
 * @endpoint POST /fortune-health
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간
 * - gender: string - 성별
 * - healthConcerns?: string[] - 관심 건강 분야
 *
 * @response HealthFortuneResponse
 * - overall_score: number - 건강운 점수
 * - element_balance: { wood, fire, earth, metal, water } - 오행 균형
 * - weak_organs: string[] - 취약 장기
 * - recommendations: { diet, exercise, lifestyle } - 양생 추천
 * - cautions: string[] - 주의사항
 * - seasonal_advice: string - 계절별 조언
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-health \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","birthDate":"1990-01-01","gender":"female"}'
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractHealthCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

interface HealthAppData {
  average_daily_steps?: number | null
  today_steps?: number | null
  average_daily_calories?: number | null
  today_calories?: number | null
  average_daily_distance_km?: string | null
  workout_count_week?: number | null
  average_sleep_hours?: string | null
  last_night_sleep_hours?: string | null
  average_heart_rate?: number | null
  resting_heart_rate?: number | null
  weight_kg?: string | null
  systolic_bp?: number | null
  diastolic_bp?: number | null
  blood_glucose?: string | null
  blood_oxygen?: string | null
  data_period?: string | null
}

interface HealthFortuneRequest {
  fortune_type?: string
  current_condition: string
  concerned_body_parts: string[]
  sleepQuality?: number // ✅ 수면 품질 (1-5)
  exerciseFrequency?: number // ✅ 운동 빈도 (1-5)
  stressLevel?: number // ✅ 스트레스 수준 (1-5)
  mealRegularity?: number // ✅ 식사 규칙성 (1-5)
  hasChronicCondition?: boolean // ✅ 기저질환 여부
  chronicCondition?: string // ✅ 기저질환 내용
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
  health_app_data?: HealthAppData | null // ✅ 프리미엄 건강앱 데이터
  // ✅ 신규: 사주 오행 분석용
  birthDate?: string // YYYY-MM-DD
  birthTime?: string // HH:MM 또는 "축시 (01:00-03:00)"
  sajuData?: {
    element_balance?: { 목: number, 화: number, 토: number, 금: number, 수: number }
    lacking_element?: string
    dominant_element?: string
  } | null
  // ✅ 신규: 이전 설문 비교용
  previousSurvey?: {
    sleep_quality?: number
    exercise_frequency?: number
    stress_level?: number
    meal_regularity?: number
    created_at?: string
  } | null
}

// ============================================================================
// 오행 분석 관련 (calculate-saju 패턴 참조)
// ============================================================================

const TIAN_GAN = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계']
const DI_ZHI = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해']

const TIAN_GAN_WUXING: Record<string, string> = {
  '갑': '목', '을': '목', '병': '화', '정': '화',
  '무': '토', '기': '토', '경': '금', '신': '금', '임': '수', '계': '수'
}

const DI_ZHI_WUXING: Record<string, string> = {
  '자': '수', '축': '토', '인': '목', '묘': '목', '진': '토', '사': '화',
  '오': '화', '미': '토', '신': '금', '유': '금', '술': '토', '해': '수'
}

// ✅ 오행-장부 대응 (건강 조언용)
const ELEMENT_ORGAN_MAP: Record<string, {
  organs: string[],
  symptoms: string[],
  foods: string[],
  season: string
}> = {
  '목': {
    organs: ['간', '담'],
    symptoms: ['눈 피로', '근육 경직', '신경과민', '두통'],
    foods: ['푸른 채소', '신맛 음식', '매실', '부추', '시금치'],
    season: '봄'
  },
  '화': {
    organs: ['심장', '소장'],
    symptoms: ['불면증', '가슴 두근거림', '혈액순환 저하', '안면홍조'],
    foods: ['붉은 음식', '토마토', '딸기', '파프리카', '고추'],
    season: '여름'
  },
  '토': {
    organs: ['비장', '위'],
    symptoms: ['소화불량', '피로감', '식욕부진', '부종'],
    foods: ['노란 음식', '호박', '고구마', '단맛 음식', '현미'],
    season: '환절기'
  },
  '금': {
    organs: ['폐', '대장'],
    symptoms: ['호흡기 문제', '피부 트러블', '면역력 저하', '기침'],
    foods: ['흰 음식', '무', '도라지', '배', '마늘'],
    season: '가을'
  },
  '수': {
    organs: ['신장', '방광'],
    symptoms: ['부종', '허리 통증', '빈뇨', '탈모', '이명'],
    foods: ['검은 음식', '검은콩', '미역', '다시마', '호두'],
    season: '겨울'
  }
}

// 간단한 오행 균형 계산 (birthDate 기반)
function calculateSimpleWuxingBalance(birthDate: string): {
  balance: Record<string, number>,
  lacking: string,
  dominant: string
} {
  const date = new Date(birthDate)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  // 년주 계산
  const yearGanIndex = (year - 4) % 10
  const yearZhiIndex = (year - 4) % 12
  const yearGan = TIAN_GAN[yearGanIndex < 0 ? yearGanIndex + 10 : yearGanIndex]
  const yearZhi = DI_ZHI[yearZhiIndex < 0 ? yearZhiIndex + 12 : yearZhiIndex]

  // 일주 계산 (1900.1.1 = 갑진일 기준)
  const baseDate = new Date(1900, 0, 1)
  const daysDiff = Math.floor((date.getTime() - baseDate.getTime()) / (1000 * 60 * 60 * 24))
  const dayGanIndex = ((0 + daysDiff) % 10 + 10) % 10
  const dayZhiIndex = ((4 + daysDiff) % 12 + 12) % 12
  const dayGan = TIAN_GAN[dayGanIndex]
  const dayZhi = DI_ZHI[dayZhiIndex]

  // 오행 카운트
  const balance: Record<string, number> = { 목: 0, 화: 0, 토: 0, 금: 0, 수: 0 }

  // 천간 오행
  if (TIAN_GAN_WUXING[yearGan]) balance[TIAN_GAN_WUXING[yearGan]] += 1
  if (TIAN_GAN_WUXING[dayGan]) balance[TIAN_GAN_WUXING[dayGan]] += 1

  // 지지 오행
  if (DI_ZHI_WUXING[yearZhi]) balance[DI_ZHI_WUXING[yearZhi]] += 1
  if (DI_ZHI_WUXING[dayZhi]) balance[DI_ZHI_WUXING[dayZhi]] += 1

  // 월지 보정 (대략적)
  const monthZhiIndex = (month + 1) % 12
  const monthZhi = DI_ZHI[monthZhiIndex]
  if (DI_ZHI_WUXING[monthZhi]) balance[DI_ZHI_WUXING[monthZhi]] += 0.5

  // 부족/강함 판단
  const entries = Object.entries(balance)
  const lacking = entries.reduce((a, b) => a[1] < b[1] ? a : b)[0]
  const dominant = entries.reduce((a, b) => a[1] > b[1] ? a : b)[0]

  return { balance, lacking, dominant }
}

// 이전 설문 비교 분석
function generatePreviousSurveyContext(
  current: { sleepQuality: number, exerciseFrequency: number, stressLevel: number, mealRegularity: number },
  previous: { sleep_quality?: number, exercise_frequency?: number, stress_level?: number, meal_regularity?: number, created_at?: string } | null
): { context: string, feedback: { improvements: string[], concerns: string[], encouragements: string[] } } {
  if (!previous) {
    return {
      context: '(최초 설문입니다. 이번 응답을 기준으로 맞춤 조언을 제공합니다.)',
      feedback: { improvements: [], concerns: [], encouragements: ['첫 건강 체크! 꾸준히 기록하면 맞춤 조언이 더 정확해집니다.'] }
    }
  }

  const sections: string[] = []
  const feedback = { improvements: [] as string[], concerns: [] as string[], encouragements: [] as string[] }

  // 수면 비교
  if (previous.sleep_quality !== undefined) {
    if (current.sleepQuality > previous.sleep_quality) {
      sections.push(`✅ 수면 품질 개선 (${previous.sleep_quality}→${current.sleepQuality}점)`)
      feedback.improvements.push('수면 품질이 지난번보다 좋아졌어요!')
    } else if (current.sleepQuality < previous.sleep_quality) {
      sections.push(`⚠️ 수면 품질 하락 (${previous.sleep_quality}→${current.sleepQuality}점)`)
      feedback.concerns.push('수면 품질이 떨어졌습니다. 취침 전 스마트폰 사용을 줄여보세요.')
    }
  }

  // 운동 비교
  if (previous.exercise_frequency !== undefined) {
    if (current.exerciseFrequency >= 4 && previous.exercise_frequency >= 4) {
      sections.push(`💪 운동 꾸준히 유지 중 (${current.exerciseFrequency}점)`)
      feedback.encouragements.push('운동을 꾸준히 하고 계시네요! 현재 페이스를 유지하세요.')
    } else if (current.exerciseFrequency > previous.exercise_frequency) {
      sections.push(`✅ 운동 빈도 증가 (${previous.exercise_frequency}→${current.exerciseFrequency}점)`)
      feedback.improvements.push('운동 빈도가 늘었어요! 좋은 습관입니다.')
    } else if (current.exerciseFrequency <= 2 && previous.exercise_frequency <= 2) {
      sections.push(`⚠️ 운동 부족 상태 지속 (${current.exerciseFrequency}점)`)
      feedback.concerns.push('운동 부족 상태가 지속되고 있습니다. 하루 15분 걷기부터 시작해보세요.')
    }
  }

  // 식사 비교
  if (previous.meal_regularity !== undefined) {
    if (current.mealRegularity <= 2) {
      sections.push(`⚠️ 식사 불규칙 (${current.mealRegularity}점)`)
      feedback.concerns.push('식사가 불규칙합니다. 아침 7:30, 점심 12:30, 저녁 18:30 식사를 권장합니다.')
    } else if (current.mealRegularity > previous.meal_regularity) {
      sections.push(`✅ 식사 규칙성 개선 (${previous.meal_regularity}→${current.mealRegularity}점)`)
      feedback.improvements.push('식사 습관이 좋아졌어요!')
    }
  }

  // 스트레스 비교
  if (previous.stress_level !== undefined) {
    if (current.stressLevel >= 4) {
      sections.push(`⚠️ 스트레스 높음 (${current.stressLevel}점)`)
      feedback.concerns.push('스트레스가 높습니다. 호흡 명상, 산책 등 이완 활동이 필요합니다.')
    } else if (current.stressLevel < previous.stress_level) {
      sections.push(`✅ 스트레스 감소 (${previous.stress_level}→${current.stressLevel}점)`)
      feedback.improvements.push('스트레스가 줄었어요! 좋은 신호입니다.')
    }
  }

  const daysSince = previous.created_at
    ? Math.floor((Date.now() - new Date(previous.created_at).getTime()) / (1000 * 60 * 60 * 24))
    : null

  const context = sections.length > 0
    ? `## 지난 설문(${daysSince ? `${daysSince}일 전` : '이전'}) 대비 분석\n${sections.join('\n')}`
    : '(이전 설문과 큰 변화가 없습니다.)'

  return { context, feedback }
}

// ✅ 건강 입력값을 설명 레이블로 변환하는 헬퍼 함수
function getSleepLabel(value: number): string {
  const labels: Record<number, string> = {
    1: '매우 나쁨 - 수면 부족이 심각함',
    2: '나쁨 - 자주 깨거나 숙면 어려움',
    3: '보통 - 적당한 수면',
    4: '좋음 - 숙면하는 편',
    5: '매우 좋음 - 깊은 수면, 상쾌한 기상'
  }
  return labels[value] || '보통'
}

function getExerciseLabel(value: number): string {
  const labels: Record<number, string> = {
    1: '거의 안함 - 운동 부족',
    2: '가끔 (주 1회 이하)',
    3: '보통 (주 2-3회)',
    4: '자주 (주 4-5회)',
    5: '매일 운동 - 활동적'
  }
  return labels[value] || '보통'
}

function getStressLabel(value: number): string {
  const labels: Record<number, string> = {
    1: '거의 없음 - 편안한 상태',
    2: '조금 있음 - 관리 가능',
    3: '보통 - 일상적인 스트레스',
    4: '많음 - 스트레스 관리 필요',
    5: '매우 많음 - 과도한 스트레스, 주의 필요'
  }
  return labels[value] || '보통'
}

function getMealLabel(value: number): string {
  const labels: Record<number, string> = {
    1: '매우 불규칙 - 식사 거르기 잦음',
    2: '불규칙 - 자주 거름',
    3: '보통 - 대체로 규칙적',
    4: '규칙적 - 정해진 시간에 식사',
    5: '매우 규칙적 - 균형 잡힌 식사'
  }
  return labels[value] || '보통'
}

serve(async (req) => {
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
    const requestData: HealthFortuneRequest = await req.json()
    const {
      current_condition = '',
      concerned_body_parts = [],
      sleepQuality = 3, // ✅ 수면 품질 (1-5, 기본값 3)
      exerciseFrequency = 3, // ✅ 운동 빈도 (1-5, 기본값 3)
      stressLevel = 3, // ✅ 스트레스 수준 (1-5, 기본값 3)
      mealRegularity = 3, // ✅ 식사 규칙성 (1-5, 기본값 3)
      hasChronicCondition = false, // ✅ 기저질환 여부
      chronicCondition = '', // ✅ 기저질환 내용
      isPremium = false, // ✅ 프리미엄 사용자 여부
      health_app_data = null, // ✅ 건강앱 데이터 (프리미엄 전용)
      // ✅ 신규: 사주 오행 분석용
      birthDate = null,
      sajuData = null,
      // ✅ 신규: 이전 설문 비교용
      previousSurvey = null
    } = requestData

    // ✅ 오행 분석 (sajuData 우선, 없으면 birthDate로 계산)
    let elementAnalysis: { balance: Record<string, number>, lacking: string, dominant: string } | null = null
    if (sajuData?.lacking_element && sajuData?.dominant_element) {
      elementAnalysis = {
        balance: sajuData.element_balance || { 목: 1, 화: 1, 토: 1, 금: 1, 수: 1 },
        lacking: sajuData.lacking_element,
        dominant: sajuData.dominant_element
      }
      console.log('🌿 [Health] 사주 데이터 사용:', elementAnalysis)
    } else if (birthDate) {
      elementAnalysis = calculateSimpleWuxingBalance(birthDate)
      console.log('🌿 [Health] birthDate로 오행 계산:', elementAnalysis)
    }

    // ✅ 이전 설문 비교 분석
    const { context: previousSurveyContext, feedback: personalizedFeedback } = generatePreviousSurveyContext(
      { sleepQuality, exerciseFrequency, stressLevel, mealRegularity },
      previousSurvey
    )
    console.log('📊 [Health] 이전 설문 비교:', previousSurveyContext)

    if (!current_condition) {
      throw new Error('현재 건강 상태를 입력해주세요.')
    }

    const hasHealthAppData = isPremium && health_app_data !== null
    console.log('💎 [Health] Premium 상태:', isPremium)
    console.log('📱 [Health] 건강앱 데이터:', hasHealthAppData ? '있음' : '없음')
    console.log('🏥 [Health] 건강 입력:', {
      current_condition,
      concerned_body_parts,
      sleepQuality,
      exerciseFrequency,
      stressLevel,
      mealRegularity,
      hasChronicCondition,
      chronicCondition
    })

    // ✅ Cohort Pool 조회 (API 비용 90% 절감)
    const cohortData = extractHealthCohort({
      birthDate: birthDate || '',
      gender: (requestData as any).gender,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[Health] Cohort: ${JSON.stringify(cohortData)} -> ${cohortHash.slice(0, 8)}...`)

    const poolResult = await getFromCohortPool(supabase, 'health', cohortHash)
    if (poolResult) {
      console.log('[Health] ✅ Cohort Pool 히트!')
      // 개인화
      const personalizedResult = personalize(poolResult, {
        userName: (requestData as any).userName || (requestData as any).name || '회원님',
        condition: current_condition,
        concernedParts: concerned_body_parts.join(', '),
      }) as Record<string, unknown>

      // 오행 분석 추가 (있는 경우)
      if (elementAnalysis) {
        personalizedResult.element_advice = {
          lacking_element: elementAnalysis.lacking,
          dominant_element: elementAnalysis.dominant,
          vulnerable_organs: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.organs || [],
          vulnerable_symptoms: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.symptoms || [],
          recommended_foods: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods || []
        }
      }

      // 퍼센타일 추가
      const score = (personalizedResult.score as number) || 75
      const percentileData = await calculatePercentile(supabase, 'health', score)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      // Blur 처리
      resultWithPercentile.isBlurred = !isPremium
      resultWithPercentile.blurredSections = !isPremium
        ? ['recommendations', 'cautions', 'element_advice', 'personalized_feedback']
        : []

      return new Response(JSON.stringify({ success: true, data: resultWithPercentile }), {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      })
    }
    console.log('[Health] Cohort Pool miss, LLM 호출 필요')

    // 모든 건강 입력을 캐시 키에 포함 (개인화된 결과)
    const healthInputs = `${current_condition}_${concerned_body_parts.join(',')}_s${sleepQuality}e${exerciseFrequency}t${stressLevel}m${mealRegularity}`
    const healthDataHash = hasHealthAppData ? `_healthapp_${JSON.stringify(health_app_data).slice(0, 50)}` : ''
    const hash = await createHash(`${healthInputs}${healthDataHash}`)
    const cacheKey = `health_fortune_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for health fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling LLM API')

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('health')

      // ✅ 오행 기반 프롬프트 섹션 생성
      const elementSection = elementAnalysis ? `
## 🌿 사주 오행 분석 (개인화 핵심!)
- **부족한 오행**: ${elementAnalysis.lacking} (${ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.organs.join(', ') || '장기'} 취약)
- **강한 오행**: ${elementAnalysis.dominant}
- **취약 증상**: ${ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.symptoms.join(', ') || '일반적 증상'}
- **보충 음식**: ${ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods.join(', ') || '균형 잡힌 식단'}

⚠️ **중요**: 위 오행 분석을 반드시 조언에 반영하세요!
- ${elementAnalysis.lacking} 기운이 부족하므로 ${ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.organs.join('/')} 건강에 특히 주의
- 식단에 ${ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods.slice(0, 3).join(', ')} 포함 권장
` : ''

      const systemPrompt = `당신은 친근한 건강 친구이자 웰니스 코치예요! 💪✨
어려운 의학 용어 대신 쉽고 재밌게, 친구처럼 건강 조언을 해줘요.

## 스타일 가이드 🏃‍♀️
- 딱딱한 의사 선생님 NO! 옆집 건강 덕후 친구처럼
- "~해요", "~거예요" 친근한 말투
- 무서운 경고보다 "이렇게 하면 좋아져요!" 희망 메시지
- 오늘 당장 할 수 있는 쉬운 것부터!

## 톤 예시
❌ "수면 부족으로 인한 피로 누적이 우려됩니다"
✅ "요즘 잠이 부족한 것 같아요! 😴 오늘 밤은 30분만 일찍 자보는 거 어때요?"

❌ "규칙적인 운동이 필요합니다"
✅ "점심 먹고 10분만 걸어봐요! 🚶 그것만으로도 오후가 달라질 거예요 ✨"

🚨 [최우선 규칙] 모든 응답은 반드시 한국어로 작성하세요!
- JSON 값: 반드시 한국어 문장 (영어 문장 절대 금지)
- 의학 용어는 쉽게 풀어서!
${elementSection}

📱 **가독성 규칙** (읽기 편하게!):
- 줄바꿈(\\n\\n)으로 숨 쉴 틈 주기
- 이모지로 포인트 강조 📊💡✨⚠️💪🍽️🎯
- 1문장 = 1포인트 (길게 늘어지지 않게)

🎯 **조언 원칙**:
1. **구체적으로**: "운동하세요" ❌ → "점심 후 회사 주변 10분 산책!" ✅
2. **이유도 같이**: 왜 좋은지 한 줄 설명
3. **오늘 바로 할 수 있는 것**: 거창한 계획 X, 소소한 실천 O
4. **격려 위주**: 잔소리보다 응원! 💪
${elementAnalysis ? `5. **오행 맞춤**: ${elementAnalysis.lacking} 기운 보충 음식 추천` : ''}

⚠️ **금지**:
- "~하십시오", "~해야 합니다" 같은 명령조
- 무서운 경고만 하기 (희망 메시지 필수!)
- 줄바꿈 없이 장문 쓰기`

      // 건강앱 데이터 섹션 생성
      const healthAppSection = hasHealthAppData ? `
## 📱 건강앱 연동 데이터 (실측치)
${health_app_data!.average_daily_steps ? `- **일평균 걸음 수**: ${health_app_data!.average_daily_steps.toLocaleString()}보` : ''}
${health_app_data!.today_steps ? `- **오늘 걸음 수**: ${health_app_data!.today_steps.toLocaleString()}보` : ''}
${health_app_data!.average_sleep_hours ? `- **일평균 수면**: ${health_app_data!.average_sleep_hours}시간` : ''}
${health_app_data!.last_night_sleep_hours ? `- **어젯밤 수면**: ${health_app_data!.last_night_sleep_hours}시간` : ''}
${health_app_data!.average_heart_rate ? `- **평균 심박수**: ${health_app_data!.average_heart_rate}bpm` : ''}
${health_app_data!.resting_heart_rate ? `- **안정시 심박수**: ${health_app_data!.resting_heart_rate}bpm` : ''}
${health_app_data!.weight_kg ? `- **체중**: ${health_app_data!.weight_kg}kg` : ''}
${health_app_data!.systolic_bp && health_app_data!.diastolic_bp ? `- **혈압**: ${health_app_data!.systolic_bp}/${health_app_data!.diastolic_bp}mmHg` : ''}
${health_app_data!.blood_glucose ? `- **혈당**: ${health_app_data!.blood_glucose}mg/dL` : ''}
${health_app_data!.blood_oxygen ? `- **산소포화도**: ${health_app_data!.blood_oxygen}%` : ''}
${health_app_data!.workout_count_week ? `- **주간 운동 횟수**: ${health_app_data!.workout_count_week}회` : ''}
${health_app_data!.average_daily_calories ? `- **일평균 소모 칼로리**: ${health_app_data!.average_daily_calories}kcal` : ''}
${health_app_data!.data_period ? `- **데이터 기간**: ${health_app_data!.data_period}` : ''}

⚠️ **중요**: 위 실측 데이터를 반드시 분석에 반영하세요. 일반적인 조언이 아닌, 이 사용자의 실제 건강 지표에 맞춤화된 조언을 제공해야 합니다.
` : ''

      const userPrompt = `## 사용자 건강 프로필
- **현재 컨디션**: ${current_condition}
- **관심 부위**: ${concerned_body_parts.length > 0 ? concerned_body_parts.join(', ') : '전신 컨디션'}
- **수면 품질**: ${sleepQuality}/5점 (${getSleepLabel(sleepQuality)})
- **운동 빈도**: ${exerciseFrequency}/5점 (${getExerciseLabel(exerciseFrequency)})
- **스트레스 수준**: ${stressLevel}/5점 (${getStressLabel(stressLevel)})
- **식사 규칙성**: ${mealRegularity}/5점 (${getMealLabel(mealRegularity)})
${hasChronicCondition ? `- **기저질환**: ${chronicCondition}` : ''}
- **분석 날짜**: ${new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric', weekday: 'long' })}
${healthAppSection}

${previousSurveyContext}

⚠️ **위 건강 입력 데이터를 반드시 분석에 반영하세요!**
- 수면 품질이 낮으면 → 수면 개선 조언 제공
- 운동 빈도가 낮으면 → 운동 권장 조언 제공
- 스트레스가 높으면 → 스트레스 관리 조언 제공
- 식사가 불규칙하면 → 식습관 개선 조언 제공
${elementAnalysis ? `- ${elementAnalysis.lacking} 오행 부족 → ${ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods.slice(0, 3).join(', ')} 섭취 권장` : ''}

---

## 요청 JSON 형식

⚠️ **가독성 필수 규칙**:
1. 모든 텍스트는 **줄바꿈(\\n\\n)**으로 문단 구분
2. 핵심 포인트마다 **이모지** 사용 (📊, 💪, 🍽️, ⚠️, ✅, 💡)
3. 긴 문장 금지 - **1문장 = 1포인트** 원칙
4. 불릿 포인트(•) 활용

\`\`\`json
{
  "overall_health": "📊 전반 분석\\n\\n현재 상태 요약 1문장.\\n\\n💡 원인 분석\\n• 포인트1\\n• 포인트2\\n\\n✨ 개선 방향\\n2주 실천 시 기대효과.",
  "body_part_advice": "🎯 부위별 조언\\n\\n• 증상 원인: 간단 설명\\n• 관리법: 구체적 방법\\n• 예방법: 일상 팁",
  "cautions": [
    "⚠️ 주의1\\n\\n위험 상황 설명.\\n\\n💡 대처법: 구체적 방법",
    "⚠️ 주의2\\n\\n설명.\\n\\n💡 대처법: 방법",
    "⚠️ 주의3\\n\\n설명.\\n\\n💡 대처법: 방법"
  ],
  "recommended_activities": [
    "🏃 활동1\\n\\n⏰ 시간: 오후 3시\\n⏱️ 시간: 15분\\n✨ 효과: 세로토닌 분비",
    "🧘 활동2\\n\\n⏰ 시간: 저녁 9시\\n⏱️ 시간: 10분\\n✨ 효과: 수면 유도",
    "🚶 활동3\\n\\n⏰ 시간: 아침 7시\\n⏱️ 시간: 20분\\n✨ 효과: 각성 효과"
  ],
  "element_foods": [
    {"item": "음식명", "reason": "오행 기반 이유 (예: 수 기운 보충, 신장 강화)", "timing": "아침/점심/저녁/간식"},
    {"item": "음식명2", "reason": "오행 기반 이유", "timing": "추천 시간"},
    {"item": "음식명3", "reason": "오행 기반 이유", "timing": "추천 시간"}
  ],
  "diet_advice": "🍽️ 식습관 조언\\n\\n【추천】\\n• ①음식1: 효능 설명\\n• ②음식2: 효능 설명\\n• ③음식3: 효능 설명\\n\\n【피할 것】\\n• ①음식1: 이유\\n• ②음식2: 이유\\n\\n【식사 시간표】\\n• 아침 7:30 / 점심 12:30 / 저녁 18:30",
  "exercise_advice": {
    "morning": { "time": "07:00", "title": "운동명", "description": "설명", "duration": "10분", "intensity": "가벼움|중간|높음", "tip": "💡 팁" },
    "afternoon": { "time": "17:30", "title": "운동명", "description": "설명", "duration": "30분", "intensity": "가벼움|중간|높음", "tip": "💡 팁" },
    "weekly": { "summary": "주간 요약", "schedule": { "mon": "활동", "tue": "활동", "wed": "활동", "thu": "활동", "fri": "활동", "sat": "활동", "sun": "활동" } },
    "overall_tip": "💪 전체 조언 1문장"
  },
  "health_keyword": "오늘의 건강 키워드 2-3단어"
}
\`\`\`

---

## 각 필드 작성 기준 (상세)

### 1. overall_health (전반적인 건강운) - 가독성 중심
**필수 형식** (줄바꿈 \\n\\n 필수!):
\`\`\`
📊 전반 건강 분석

현재 수면의 질(2/5)과 식사 규칙성(2/5)이 낮아 전반적인 피로감(fatigue)을 유발하고 있습니다.

💡 원인 분석
• 수면 부족 → 성장호르몬 분비 저하 → 회복력 감소
• 불규칙한 식사 → 혈당 변동 → 집중력 저하

✨ 2주 실천 시 기대효과
• 22시 취침 유지 → 아침 컨디션 30% 개선
• 규칙적 식사 → 에너지 레벨 안정화
\`\`\`

**금지**: 줄바꿈 없이 긴 문장으로 이어쓰기

### 2. body_part_advice (부위별 건강 조언) - 가독성 중심
**필수 형식**:
\`\`\`
🎯 부위별 맞춤 조언

피로감(fatigue)은 신체적, 정신적 스트레스, 수면 부족, 영양 불균형 등 다양한 원인에 의해 발생합니다.

📌 일상 관리법
• 취침 전 스마트폰 사용 자제
• 미지근한 물로 샤워하여 몸 이완
• 아침 기상 후 10분 스트레칭

🛡️ 장기적 예방법
• 규칙적인 수면 패턴 유지
• 충분한 영양 섭취 + 스트레스 관리
\`\`\`

### 3. cautions (주의사항) - 가독성 중심
**필수 형식** (각 항목에 줄바꿈 필수!):
\`\`\`
⚠️ 카페인 섭취 주의

오후 4시 이후 카페인 섭취 시 수면 잠복기가 평균 30분 늘어납니다.

💡 대처법
• 점심 식후 1시까지만 커피
• 이후에는 보리차/루이보스 티로 대체
• 이미 마셨다면 가벼운 산책으로 카페인 대사 촉진
\`\`\`

### 4. recommended_activities (추천 활동) - 가독성 중심
**필수 형식**:
\`\`\`
🚶 야외 걷기

⏰ 시간: 오후 3-4시
⏱️ 소요: 15분
📍 장소: 공원, 나무 있는 곳

✨ 효과
• 햇볕 → 세로토닌 분비 촉진
• 밤 수면 유도 호르몬(멜라토닌) 생성 도움

💡 Tip: 빠른 걷기 ❌, 대화 가능한 속도 ✅
\`\`\`

### 5. diet_advice (식습관 조언) - 가독성 중심
**필수 형식**:
\`\`\`
🍽️ 식습관 조언

【추천】
• ①바나나: 트립토판 → 수면 호르몬 생성, 저녁 간식
• ②시금치: 마그네슘 → 근육 이완, 저녁 반찬
• ③아몬드 10알: 멜라토닌 함유, 취침 2시간 전

【피할 것】
• ①라면/짠 음식: 나트륨 → 야간 각성 유발
• ②매운 음식: 위산 분비 → 숙면 방해

【식사 시간표】
• 아침 7:30 / 점심 12:30 / 저녁 18:30
• 취침 4시간 전 마무리
\`\`\`

### 6. exercise_advice (운동 조언) - JSON 객체
**구조** (반드시 아래 JSON 형식으로 반환):
\`\`\`json
{
  "morning": {
    "time": "07:00",
    "title": "아침 스트레칭",
    "description": "햇볕 쬐며 가벼운 전신 스트레칭으로 코르티솔 각성",
    "duration": "10분",
    "intensity": "가벼움",
    "tip": "유튜브 '10분 아침 스트레칭' 참고"
  },
  "afternoon": {
    "time": "17:30",
    "title": "유산소 운동",
    "description": "수영이나 자전거로 관절 부담 줄이기",
    "duration": "30분",
    "intensity": "중간",
    "tip": "심박수 120-140 유지"
  },
  "weekly": {
    "summary": "주 3회 유산소 + 휴식 중심",
    "schedule": {
      "mon": "유산소 30분",
      "tue": "휴식",
      "wed": "유산소 30분",
      "thu": "스트레칭",
      "fri": "유산소 30분",
      "sat": "등산/걷기",
      "sun": "완전 휴식"
    }
  },
  "overall_tip": "현재 운동 빈도가 좋으니 강도보다 '회복'에 집중하세요"
}
\`\`\`
**필드 설명**:
- morning/afternoon: 시간대별 운동 추천 (time, title, description, duration, intensity, tip)
- weekly.schedule: 요일별 운동 계획 (mon~sun)
- overall_tip: 전체 핵심 조언
- **intensity 값**: "가벼움" | "중간" | "높음" 중 하나

### 7. health_keyword
2-3단어의 긍정적이고 기억하기 쉬운 표현
예: "수면 회복", "균형 찾기", "활력 충전", "몸 돌보기"

---

## 중요 지침

### 🎯 가독성 필수 (최우선!)
- 모든 텍스트에 **줄바꿈(\\n\\n)** 필수! 긴 문장 한 덩어리 금지!
- 핵심 포인트마다 **이모지** 사용 (📊💡✨⚠️💪🍽️)
- **불릿 포인트(•)** 적극 활용
- 1문장 = 1포인트 원칙

### 📝 내용 작성
- 모든 조언에 **구체적 숫자/시간/횟수** 포함 (예: "30분", "3회", "오후 4시")
- **"왜"**를 반드시 설명 (의학적 근거 간단히)
- **실천 가능한 액션** 위주로 작성 (바로 따라할 수 있게)
- 막연한 표현 사용 금지: "좋습니다", "주의하세요", "건강합니다"
- **희망적 메시지**로 마무리 (실천 시 기대 효과)

### ❌ 금지 패턴 (반드시 피하기)
- 줄바꿈 없이 500자 이상 이어쓰기
- 이모지 없는 긴 텍스트 블록
- 불릿 포인트 없이 나열

- JSON만 반환 (마크다운 코드블록 없이)`

      const response = await llm.generate([
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // ✅ LLM 사용량 로깅 (비용/성능 분석용)
      await UsageLogger.log({
        fortuneType: 'health',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          current_condition,
          concerned_body_parts,
          isPremium,
          hasHealthAppData
        }
      })

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // ✅ 항상 전체 데이터 반환 (Flutter에서 블러 처리)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['body_part_advice', 'cautions', 'recommended_activities', 'diet_advice', 'exercise_advice', 'health_keyword']
        : []

      // ✅ 표준화된 필드명 사용
      const overallHealthText = parsedResponse.전반적인건강운 || parsedResponse.overall_health || '건강하십니다.'

      // ✅ 입력 기반 점수 계산 (랜덤 제거)
      // 기본 점수 50 + 각 항목별 보너스/감점
      const sleepBonus = (sleepQuality - 1) * 5      // 0~20점 (수면 좋으면 가산)
      const exerciseBonus = (exerciseFrequency - 1) * 5 // 0~20점 (운동 많으면 가산)
      const stressDeduct = (stressLevel - 1) * 3    // 0~12점 (스트레스 높으면 감점)
      const mealBonus = (mealRegularity - 1) * 3    // 0~12점 (식사 규칙적이면 가산)
      const calculatedScore = Math.min(100, Math.max(30, 50 + sleepBonus + exerciseBonus + mealBonus - stressDeduct))
      console.log('📊 [Health] 점수 계산:', {
        base: 50,
        sleepBonus,
        exerciseBonus,
        stressDeduct,
        mealBonus,
        finalScore: calculatedScore
      })

      // ✅ exercise_advice가 객체일 경우 overall_tip 추출
      const exerciseAdvice = parsedResponse.운동조언 || parsedResponse.exercise_advice
      const adviceText = typeof exerciseAdvice === 'object' && exerciseAdvice?.overall_tip
        ? exerciseAdvice.overall_tip
        : (typeof exerciseAdvice === 'string' ? exerciseAdvice : '규칙적인 운동을 하세요')

      // ✅ 오행 기반 음식 추천 (LLM 응답 또는 기본값)
      const elementFoods = parsedResponse.element_foods || (elementAnalysis ? [
        { item: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods[0] || '균형 잡힌 식단', reason: `${elementAnalysis.lacking} 기운 보충`, timing: '아침' },
        { item: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods[1] || '제철 음식', reason: `${elementAnalysis.lacking} 기운 보충`, timing: '점심' },
        { item: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.foods[2] || '가벼운 음식', reason: `${elementAnalysis.lacking} 기운 보충`, timing: '간식' }
      ] : [])

      fortuneData = {
        // ✅ 표준화된 필드명: score, content, summary, advice
        fortuneType: 'health',
        score: calculatedScore,
        content: overallHealthText,
        summary: parsedResponse.건강키워드 || parsedResponse.health_keyword || '건강 관리',
        advice: adviceText,
        // 기존 필드 유지 (하위 호환성)
        title: '건강운',
        fortune_type: 'health',
        current_condition,
        concerned_body_parts,
        // ✅ 건강 입력 데이터 저장 (히스토리용)
        healthInputs: {
          sleepQuality,
          exerciseFrequency,
          stressLevel,
          mealRegularity,
          hasChronicCondition,
          chronicCondition
        },
        overall_health: overallHealthText,
        body_part_advice: parsedResponse.부위별건강 || parsedResponse.body_part_advice, // 블러 대상
        cautions: parsedResponse.주의사항 || parsedResponse.cautions || [], // 블러 대상
        recommended_activities: parsedResponse.추천활동 || parsedResponse.recommended_activities || [], // 블러 대상
        diet_advice: parsedResponse.식습관조언 || parsedResponse.diet_advice, // 블러 대상
        exercise_advice: parsedResponse.운동조언 || parsedResponse.exercise_advice, // 블러 대상
        health_keyword: parsedResponse.건강키워드 || parsedResponse.health_keyword || '건강', // 블러 대상
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections, // ✅ 블러된 섹션 목록
        hasHealthAppData, // ✅ 건강앱 데이터 사용 여부
        healthAppDataSummary: hasHealthAppData ? {
          steps: health_app_data!.today_steps,
          sleep: health_app_data!.average_sleep_hours,
          heartRate: health_app_data!.average_heart_rate,
          weight: health_app_data!.weight_kg
        } : null,
        // ✅ 신규: 오행 기반 개인화 조언
        element_advice: elementAnalysis ? {
          lacking_element: elementAnalysis.lacking,
          dominant_element: elementAnalysis.dominant,
          vulnerable_organs: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.organs || [],
          vulnerable_symptoms: ELEMENT_ORGAN_MAP[elementAnalysis.lacking]?.symptoms || [],
          recommended_foods: elementFoods
        } : null,
        // ✅ 신규: 이전 설문 비교 기반 개인화 피드백
        personalized_feedback: personalizedFeedback
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'health',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })

      // ✅ Cohort Pool에 저장 (fire-and-forget)
      saveToCohortPool(supabase, 'health', cohortHash, cohortData, fortuneData)
        .catch(e => console.error('[Health] Cohort 저장 오류:', e))
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'health', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    return new Response(JSON.stringify({ success: true, data: fortuneDataWithPercentile }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Health Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '건강운 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
