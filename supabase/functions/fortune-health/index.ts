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
      health_app_data = null // ✅ 건강앱 데이터 (프리미엄 전용)
    } = requestData

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

      const systemPrompt = `당신은 **현대의학 + 한의학 통합 건강코치**입니다.
삼성서울병원 가정의학과 15년, 한방내과 10년 경력을 보유하고 있습니다.

🎯 **핵심 원칙**:
1. **구체적 수치와 시간 제시**: "운동하세요" ❌ → "오후 3시, 15분간 걷기" ✅
2. **이유 설명 필수**: 모든 조언에 "왜"를 포함
3. **실천 가능한 액션**: 바로 따라할 수 있는 구체적 방법
4. **경고와 격려 균형**: 무서운 경고만 ❌, 희망적 조언과 함께

⚠️ **절대 금지**: "건강하십니다", "좋습니다", "주의하세요" 같은 막연한 표현`

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

⚠️ **위 건강 입력 데이터를 반드시 분석에 반영하세요!**
- 수면 품질이 낮으면 → 수면 개선 조언 제공
- 운동 빈도가 낮으면 → 운동 권장 조언 제공
- 스트레스가 높으면 → 스트레스 관리 조언 제공
- 식사가 불규칙하면 → 식습관 개선 조언 제공

---

## 요청 JSON 형식

\`\`\`json
{
  "overall_health": "전반 건강 분석 (500자) - 현재 상태 진단 + 원인 분석 + 개선 방향 + 기대 효과",
  "body_part_advice": "부위별 맞춤 조언 (400자) - 증상 원인 + 관리법 + 예방법",
  "cautions": ["주의사항1 (150자: 위험 + 조건 + 대처법)", "주의사항2", "주의사항3"],
  "recommended_activities": ["활동1 (150자: 시간+방법+효과+주의점)", "활동2", "활동3"],
  "diet_advice": "식습관 조언 (350자) - 추천 음식 3개 + 피할 음식 2개 + 식사 시간표",
  "exercise_advice": {
    "morning": { "time": "07:00", "title": "운동명", "description": "설명", "duration": "10분", "intensity": "가벼움|중간|높음", "tip": "팁" },
    "afternoon": { "time": "17:30", "title": "운동명", "description": "설명", "duration": "30분", "intensity": "가벼움|중간|높음", "tip": "팁" },
    "weekly": { "summary": "주간 요약", "schedule": { "mon": "활동", "tue": "활동", "wed": "활동", "thu": "활동", "fri": "활동", "sat": "활동", "sun": "활동" } },
    "overall_tip": "전체 조언 (50자 이내)"
  },
  "health_keyword": "오늘의 건강 키워드 2-3단어"
}
\`\`\`

---

## 각 필드 작성 기준 (상세)

### 1. overall_health (전반적인 건강운) - 500자
**구성**:
- **첫 문단**: 현재 상태 진단 (수면/운동/스트레스/식사 점수 기반 분석)
- **둘째 문단**: 가장 주의해야 할 점과 의학적 이유
- **셋째 문단**: 개선 시 기대 효과 + 희망적 메시지

**예시**: "수면 품질 2점, 운동 빈도 4점으로 볼 때 현재 '운동은 열심히 하지만 회복이 안 되는' 전형적인 과훈련 패턴입니다. 수면 중 성장호르몬이 분비되어 근육 회복이 이뤄지는데, 현재 수면 부족으로 운동 효과의 40%만 얻고 있을 가능성이 높습니다. 22시 취침 + 6시간 이상 수면을 2주간 유지하면 같은 운동량으로도 근육통 감소, 체력 향상, 아침 컨디션 개선을 체감하실 수 있습니다."

### 2. body_part_advice (부위별 건강 조언) - 400자
**구성**:
- **증상 원인 분석**: 관심 부위와 현재 건강 상태 연결
- **일상 관리법**: 스트레칭, 자세 교정, 찜질 등 바로 할 수 있는 방법
- **장기적 예방법**: 습관 개선, 정기 검진 등

### 3. cautions (주의사항) - 각 150자
**구성**: 구체적 위험 + 발생 조건 + 대처법
**예시**: "오후 4시 이후 카페인 섭취 시 수면 잠복기가 평균 30분 늘어납니다. 커피가 필요하다면 점심 식후 1시까지만, 이후에는 따뜻한 보리차나 루이보스 티로 대체하세요. 이미 마셨다면 저녁 가벼운 산책으로 카페인 대사를 촉진할 수 있습니다."

### 4. recommended_activities (추천 활동) - 각 150자
**구성**: 시간 + 방법 + 효과 + 주의점
**예시**: "오후 3-4시 15분 야외 걷기: 햇볕이 세로토닌 분비를 촉진해 밤 수면 유도 호르몬(멜라토닌) 생성에 도움. 빠른 걷기가 아닌 대화 가능한 속도로, 가능하면 공원이나 나무 있는 곳. 비 오는 날은 실내 계단 오르기로 대체."

### 5. diet_advice (식습관 조언) - 350자
**구성**:
- **추천 음식 3가지**: 음식명 + 효능 + 섭취 방법
- **피해야 할 음식 2가지**: 음식명 + 피해야 하는 이유
- **식사 시간표 예시**: 아침/점심/저녁 권장 시간

**예시**: "【추천】 ①바나나: 트립토판이 수면 호르몬 생성 도움, 저녁 간식으로 ②시금치: 마그네슘 풍부해 근육 이완, 저녁 반찬 ③아몬드 10알: 멜라토닌 함유, 취침 2시간 전 【피할 것】 ①라면/짠 음식: 나트륨이 수분 배출해 야간 각성 유발 ②매운 음식: 위산 분비 증가로 숙면 방해 【시간표】 아침 7:30 / 점심 12:30 / 저녁 18:30 (취침 4시간 전 마무리)"

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
- overall_tip: 전체 핵심 조언 (50자 이내)
- **intensity 값**: "가벼움" | "중간" | "높음" 중 하나

### 7. health_keyword
2-3단어의 긍정적이고 기억하기 쉬운 표현
예: "수면 회복", "균형 찾기", "활력 충전", "몸 돌보기"

---

## 중요 지침
- 모든 조언에 **구체적 숫자/시간/횟수** 포함 (예: "30분", "3회", "오후 4시")
- **"왜"**를 반드시 설명 (의학적 근거 간단히)
- **실천 가능한 액션** 위주로 작성 (바로 따라할 수 있게)
- 막연한 표현 사용 금지: "좋습니다", "주의하세요", "건강합니다"
- **희망적 메시지**로 마무리 (실천 시 기대 효과)
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

      fortuneData = {
        // ✅ 표준화된 필드명: score, content, summary, advice
        fortuneType: 'health',
        score: calculatedScore,
        content: overallHealthText,
        summary: parsedResponse.건강키워드 || parsedResponse.health_keyword || '건강 관리',
        advice: parsedResponse.운동조언 || parsedResponse.exercise_advice || '규칙적인 운동을 하세요',
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
        } : null
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'health',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })
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
