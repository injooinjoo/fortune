/**
 * 운동 운세 (Exercise Fortune) Edge Function
 *
 * @description 운동 종목별 전문 가이드를 제공합니다.
 *
 * @endpoint POST /fortune-exercise
 *
 * @requestBody
 * - exerciseGoal: string - 운동 목표 (flexibility|strength|endurance|diet|stress_relief)
 * - sportType: string - 운동 종목 (gym|yoga|running|swimming|cycling|climbing|martial_arts|tennis|golf|pilates|crossfit|dance)
 * - weeklyFrequency: number - 주당 운동 횟수 (1-7)
 * - experienceLevel: string - 운동 경력 (beginner|intermediate|advanced|expert)
 * - fitnessLevel: number - 체력 수준 (1-5)
 * - injuryHistory: string[] - 부상 이력
 * - preferredTime: string - 선호 시간대 (morning|afternoon|evening|night)
 * - isPremium: boolean - 프리미엄 사용자 여부
 *
 * @response ExerciseFortuneResponse
 * - score: number - 운동 컨디션 점수
 * - recommendedExercise: object - 추천 운동 (무료)
 * - todayRoutine: object - 오늘의 루틴 (프리미엄)
 * - weeklyPlan: object - 주간 계획 (프리미엄)
 * - injuryPrevention: object - 부상 예방 (프리미엄)
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  refundFortuneCharge,
  requirePaidFortuneCaller,
  storeFortuneResult,
  withTokenCharge,
} from '../_shared/fortune_charge.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

// 서버 차감 게이트 전용 클라이언트 (token RPC + fortune_result_cache 는 service_role 필요)
const fortuneChargeAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
)

// UTF-8 안전한 해시 생성 함수
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// ============================================================================
// 운동 종목별 데이터
// ============================================================================

type SportType = 'gym' | 'yoga' | 'running' | 'swimming' | 'cycling' | 'climbing' | 'martial_arts' | 'tennis' | 'golf' | 'pilates' | 'crossfit' | 'dance'
type ExerciseGoal = 'flexibility' | 'strength' | 'endurance' | 'diet' | 'stress_relief'
type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced' | 'expert'
type PreferredTime = 'morning' | 'afternoon' | 'evening' | 'night'

const SPORT_INFO: Record<SportType, {
  nameKo: string,
  emoji: string,
  category: 'gym' | 'yoga' | 'cardio' | 'sports',
  description: string
}> = {
  gym: { nameKo: '헬스/웨이트', emoji: '💪', category: 'gym', description: '근력 운동, 분할 루틴' },
  yoga: { nameKo: '요가', emoji: '🧘', category: 'yoga', description: '유연성, 마음 챙김' },
  running: { nameKo: '러닝', emoji: '🏃', category: 'cardio', description: '유산소, 페이스 관리' },
  swimming: { nameKo: '수영', emoji: '🏊', category: 'cardio', description: '전신 운동, 관절 부담 적음' },
  cycling: { nameKo: '자전거', emoji: '🚴', category: 'cardio', description: '하체 강화, 유산소' },
  climbing: { nameKo: '클라이밍', emoji: '🧗', category: 'sports', description: '전신 근력, 문제 해결' },
  martial_arts: { nameKo: '격투기', emoji: '🥊', category: 'sports', description: 'MMA, 복싱, 유도' },
  tennis: { nameKo: '테니스', emoji: '🎾', category: 'sports', description: '민첩성, 전신 운동' },
  golf: { nameKo: '골프', emoji: '⛳', category: 'sports', description: '집중력, 유연성' },
  pilates: { nameKo: '필라테스', emoji: '🤸', category: 'yoga', description: '코어, 자세 교정' },
  crossfit: { nameKo: '크로스핏', emoji: '🏋️', category: 'gym', description: '고강도, 기능성 운동' },
  dance: { nameKo: '댄스', emoji: '💃', category: 'cardio', description: '리듬감, 전신 유산소' }
}

const GOAL_INFO: Record<ExerciseGoal, { nameKo: string, description: string }> = {
  flexibility: { nameKo: '유연성', description: '스트레칭, 요가로 몸을 부드럽게' },
  strength: { nameKo: '근력', description: '근육을 키우고 힘을 강화' },
  endurance: { nameKo: '체력/지구력', description: '심폐 기능과 지구력 향상' },
  diet: { nameKo: '다이어트', description: '체중 감량과 체형 관리' },
  stress_relief: { nameKo: '스트레스 해소', description: '심리적 안정과 이완' }
}

const INJURY_INFO: Record<string, string> = {
  none: '부상 없음',
  knee: '무릎',
  shoulder: '어깨',
  back: '허리/등',
  wrist: '손목',
  ankle: '발목',
  neck: '목',
  hip: '고관절'
}

// ============================================================================
// 라벨 변환 헬퍼 함수
// ============================================================================

function getExperienceLabel(level: ExperienceLevel): string {
  const labels: Record<ExperienceLevel, string> = {
    beginner: '입문자 (0-6개월)',
    intermediate: '중급자 (6개월-2년)',
    advanced: '상급자 (2-5년)',
    expert: '전문가 (5년 이상)'
  }
  return labels[level] || '중급자'
}

function getFitnessLabel(level: number): string {
  const labels: Record<number, string> = {
    1: '매우 낮음 - 기초 체력 부족',
    2: '낮음 - 가벼운 운동만 가능',
    3: '보통 - 일반적인 체력',
    4: '좋음 - 활동적인 편',
    5: '매우 좋음 - 뛰어난 체력'
  }
  return labels[level] || '보통'
}

function getTimeLabel(time: PreferredTime): string {
  const labels: Record<PreferredTime, string> = {
    morning: '아침 (06-09시)',
    afternoon: '낮 (12-15시)',
    evening: '저녁 (17-20시)',
    night: '밤 (21시 이후)'
  }
  return labels[time] || '저녁'
}

function getInjuryLabel(injuries: string[]): string {
  if (!injuries || injuries.length === 0 || (injuries.length === 1 && injuries[0] === 'none')) {
    return '부상 이력 없음'
  }
  return injuries.map(i => INJURY_INFO[i] || i).join(', ')
}

// ============================================================================
// 종목별 프롬프트 생성
// ============================================================================

function getSportSpecificPrompt(sportType: SportType): string {
  const sport = SPORT_INFO[sportType]

  switch (sport.category) {
    case 'gym':
      return `
### 헬스/웨이트 전문 가이드
- **분할법 추천**: 사용자 경력/빈도에 맞는 분할 (초보: 전신, 중급: 3분할, 상급: 4-5분할)
- **세트/횟수/휴식**: 구체적 수치 필수 (예: 4세트 x 8-12회, 휴식 90초)
- **웜업/쿨다운**: 타겟 부위에 맞는 동적/정적 스트레칭
- **부상 부위 피하기**: 무릎 부상 → 레그 프레스 대신 힙 힌지 운동`

    case 'yoga':
      return `
### 요가/필라테스 전문 가이드
- **시퀀스 구성**: 목표에 맞는 포즈 순서 (예: 태양경배 → 전사 → 트위스트 → 샤바사나)
- **각 포즈 설명**: 산스크리트명 + 한글명 + 호흡법 + 유지 시간 + 수정 자세
- **호흡 가이드**: 우자이 호흡, 복식 호흡 등 구체적 안내
- **부상 부위 수정**: 무릎 부상 → 니폴드 사용, 허리 부상 → 코브라 대신 스핑크스`

    case 'cardio':
      return `
### 유산소 운동 전문 가이드
- **총 거리/시간**: 목표 거리 및 소요 시간 (예: 5km, 35분 목표)
- **페이스/강도**: 구간별 페이스 (예: 6:30/km → 6:00/km → 5:30/km)
- **인터벌 구성**: 워밍업 → 본운동 → 쿨다운 단계별 심박수 존
- **테크닉 팁**: 자세, 호흡, 케이던스 등 기술적 조언`

    case 'sports':
      return `
### 스포츠 종목 전문 가이드
- **드릴/연습 구성**: 기술 향상을 위한 단계별 연습 (워밍업 → 기술 드릴 → 실전 연습)
- **포커스 영역**: 오늘 집중할 기술/전략 (예: 포핸드 스트로크, 스윙 궤도)
- **장비/코트 활용**: 필요 장비 및 연습 환경
- **게임 시뮬레이션**: 실전 대비 포인트 연습`
  }
}

// ============================================================================
// 인터페이스 정의
// ============================================================================

interface ExerciseFortuneRequest {
  fortune_type?: string
  exerciseGoal: ExerciseGoal
  sportType: SportType
  weeklyFrequency: number
  experienceLevel: ExperienceLevel
  fitnessLevel: number
  injuryHistory: string[]
  preferredTime: PreferredTime
  isPremium?: boolean
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

  // 차감 후 생성이 실패하면 catch 에서 환불하기 위한 핸들
  let paidCharge: { userId: string; idempotencyKey: string } | null = null

  try {
    const requestData: ExerciseFortuneRequest = await req.json()
    const {
      exerciseGoal = 'strength',
      sportType = 'gym',
      weeklyFrequency = 3,
      experienceLevel = 'intermediate',
      fitnessLevel = 3,
      injuryHistory = [],
      preferredTime = 'evening',
      isPremium = false
    } = requestData

    // SECURITY: 서버에서 인증 + 토큰 차감. 클라 soul-consume 의존 제거.
    const paidCaller = await requirePaidFortuneCaller(
      req,
      fortuneChargeAdmin,
      'exercise',
      requestData,
    )
    if ('error' in paidCaller) {
      return paidCaller.error
    }
    if (paidCaller.replayed) {
      // TTL 안의 동일 요청 — LLM 재호출 없이 저장된 응답 그대로.
      return new Response(
        JSON.stringify(withTokenCharge(paidCaller.cached, paidCaller.tokenCharge)),
        {
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Access-Control-Allow-Origin': '*',
          },
        },
      )
    }
    paidCharge = paidCaller

    const sportInfo = SPORT_INFO[sportType]
    const goalInfo = GOAL_INFO[exerciseGoal]

    console.log('🏋️ [Exercise] 입력:', {
      exerciseGoal,
      sportType,
      weeklyFrequency,
      experienceLevel,
      fitnessLevel,
      injuryHistory,
      preferredTime,
      isPremium
    })

    // 캐시 키 생성
    const inputHash = `${exerciseGoal}_${sportType}_f${weeklyFrequency}_${experienceLevel}_l${fitnessLevel}_${injuryHistory.join(',')}_${preferredTime}`
    const hash = await createHash(inputHash)
    const cacheKey = `exercise_fortune_${hash}`

    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for exercise fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling LLM API')

      const llm = await LLMFactory.createFromConfigAsync('exercise')

      const sportSpecificPrompt = getSportSpecificPrompt(sportType)

      const systemPrompt = `당신은 운동 좋아하는 친근한 피트니스 버디예요! 💪✨
헬스장 선배처럼 재밌고 도움 되는 운동 꿀팁을 알려줘요!

## 스타일 가이드 🏋️
- 딱딱한 PT 선생님 NO! 같이 운동하는 친구처럼
- "~해봐!", "~거야!" 같은 응원하는 말투
- 뻔한 조언 말고 진짜 효과 있는 꿀팁!
- 힘들어도 재밌게 할 수 있도록 동기부여

## 톤 예시
❌ "근육 비대를 위해 점진적 과부하가 필요합니다"
✅ "어제보다 2.5kg만 더 들어봐! 그게 바로 성장이야 📈"

🚨 [최우선 규칙] 모든 응답은 반드시 한국어로 작성하세요!
- JSON 값: 반드시 한국어 문장 (영어 문장 절대 금지)
- 운동명, 설명, 조언 모두 한국어로 작성

🎯 **핵심 원칙**:
1. **종목 맞춤**: ${sportInfo.nameKo} 전문 루틴
2. **부상 조심!**: 다친 부위 피해가는 대체 운동 제안
3. **레벨 맞춤**: ${experienceLevel} 수준에 딱 맞게
4. **구체적으로**: "운동해" ❌ → "3세트 12회, 60초 쉬고!" ✅
5. **목표 달성**: ${goalInfo.nameKo} 위한 최적 루틴

${sportSpecificPrompt}

⚠️ **금지**:
- 막연한 조언 ("열심히 해요~")
- 아픈 부위 자극하는 운동
- 초보한테 고강도 추천`

      const userPrompt = `## 사용자 운동 프로필
- **운동 목표**: ${goalInfo.nameKo} (${goalInfo.description})
- **운동 종목**: ${sportInfo.emoji} ${sportInfo.nameKo} (${sportInfo.description})
- **주당 운동 횟수**: ${weeklyFrequency}회
- **운동 경력**: ${getExperienceLabel(experienceLevel)}
- **체력 수준**: ${fitnessLevel}/5점 (${getFitnessLabel(fitnessLevel)})
- **부상 이력**: ${getInjuryLabel(injuryHistory)}
- **선호 시간대**: ${getTimeLabel(preferredTime)}
- **분석 날짜**: ${new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric', weekday: 'long' })}

${injuryHistory.length > 0 && injuryHistory[0] !== 'none' ? `
⚠️ **부상 주의**: ${getInjuryLabel(injuryHistory)} 부상 이력이 있습니다.
- 해당 부위에 부담 주는 운동 제외
- 대체 운동 반드시 제안
- 재활 스트레칭 포함
` : ''}

---

## 요청 JSON 형식

\`\`\`json
{
  "score": 0-100,
  "summary": "오늘의 운동 한줄 요약 (20자 이내)",
  "content": "전반적인 운동 조언 (300자)",

  "recommendedExercise": {
    "primary": {
      "name": "추천 운동명",
      "category": "카테고리 (근력/유산소/유연성/기술)",
      "description": "운동 설명 (100자)",
      "duration": "소요 시간",
      "intensity": "low|medium|high",
      "benefits": ["효과1", "효과2", "효과3"],
      "precautions": ["주의사항1", "주의사항2"]
    },
    "alternatives": [
      { "name": "대체 운동1", "category": "카테고리", "reason": "추천 이유" },
      { "name": "대체 운동2", "category": "카테고리", "reason": "추천 이유" }
    ]
  },

  "todayRoutine": {
    ${sportInfo.category === 'gym' ? `
    "gymRoutine": {
      "splitType": "3split|4split|5split|fullbody",
      "todayFocus": "오늘 집중 부위 (예: 가슴/삼두)",
      "exercises": [
        {
          "order": 1,
          "name": "운동명",
          "targetMuscle": "타겟 근육",
          "sets": 4,
          "reps": "8-12",
          "restSeconds": 90,
          "tips": "자세 팁"
        }
      ],
      "warmup": { "duration": "10분", "activities": ["워밍업 활동1", "워밍업 활동2"] },
      "cooldown": { "duration": "5분", "activities": ["쿨다운 활동1", "쿨다운 활동2"] }
    }` : ''}
    ${sportInfo.category === 'yoga' ? `
    "yogaRoutine": {
      "sequenceName": "시퀀스 이름 (예: 아침 태양경배)",
      "duration": "총 소요 시간",
      "poses": [
        {
          "order": 1,
          "name": "포즈 한글명",
          "sanskritName": "산스크리트명 (선택)",
          "duration": "30초-2분",
          "benefits": "효과",
          "modification": "수정 자세 (부상 시)"
        }
      ],
      "breathingFocus": "호흡 가이드"
    }` : ''}
    ${sportInfo.category === 'cardio' ? `
    "cardioRoutine": {
      "type": "${sportType}",
      "totalDistance": "총 거리 (예: 5km)",
      "totalDuration": "총 시간",
      "targetPace": "목표 페이스 (예: 6:00/km)",
      "intervals": [
        {
          "phase": "워밍업|본운동|쿨다운",
          "duration": "소요 시간",
          "intensity": "강도 설명",
          "heartRateZone": 1-5
        }
      ],
      "technique": ["테크닉 팁1", "테크닉 팁2"]
    }` : ''}
    ${sportInfo.category === 'sports' ? `
    "sportsRoutine": {
      "sportName": "${sportInfo.nameKo}",
      "focusArea": "오늘 집중 영역",
      "drills": [
        {
          "order": 1,
          "name": "드릴 이름",
          "duration": "소요 시간",
          "purpose": "목적",
          "tips": "팁"
        }
      ]
    }` : ''}
  },

  "optimalTime": {
    "time": "추천 시간 (예: 오후 5-6시)",
    "reason": "이유"
  },

  "weeklyPlan": {
    "summary": "주간 계획 요약",
    "schedule": {
      "mon": "월요일 운동",
      "tue": "화요일 운동",
      "wed": "수요일 운동",
      "thu": "목요일 운동",
      "fri": "금요일 운동",
      "sat": "토요일 운동",
      "sun": "일요일 운동"
    }
  },

  "injuryPrevention": {
    "warnings": ["주의사항1", "주의사항2"],
    "stretches": ["스트레칭1", "스트레칭2"],
    "recoveryTips": ["회복 팁1", "회복 팁2"]
  },

  "nutritionTip": {
    "preworkout": "운동 전 식사 (시간, 음식)",
    "postworkout": "운동 후 식사 (시간, 음식)"
  },

  "exerciseKeyword": "오늘의 운동 키워드 2-3단어"
}
\`\`\`

---

## 작성 기준

### 1. score (운동 컨디션 점수)
- 체력(${fitnessLevel}/5) x 0.4 + 운동빈도(${weeklyFrequency}/7) x 0.3 + 경력 보너스 x 0.3 기반
- 부상 있으면 -10점
- 60-90 사이로 현실적 점수

### 2. recommendedExercise (추천 운동)
- ${goalInfo.nameKo} 목표에 최적화
- ${experienceLevel} 경력에 맞는 난이도
${injuryHistory.length > 0 && injuryHistory[0] !== 'none' ? `- ${getInjuryLabel(injuryHistory)} 부상 피하는 운동만 추천` : ''}

### 3. todayRoutine (오늘의 루틴)
- ${sportInfo.nameKo} 종목에 맞는 상세 루틴
- 웜업 → 본운동 → 쿨다운 순서
- 구체적 세트/횟수/시간/강도 필수

### 4. weeklyPlan (주간 계획)
- 주 ${weeklyFrequency}회 운동 기준
- 휴식일 포함 (연속 운동 금지)
- ${experienceLevel} 수준에 맞는 볼륨

### 5. injuryPrevention (부상 예방)
${injuryHistory.length > 0 && injuryHistory[0] !== 'none' ? `- ${getInjuryLabel(injuryHistory)} 관련 재활 스트레칭 필수 포함` : '- 일반적인 부상 예방 스트레칭'}

---

## 중요 지침
- 모든 조언에 **구체적 숫자** 포함
- ${sportInfo.nameKo} 전문 용어 사용
- ${experienceLevel} 수준에 맞는 난이도
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

      await UsageLogger.log({
        fortuneType: 'exercise',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          exerciseGoal,
          sportType,
          weeklyFrequency,
          experienceLevel,
          isPremium
        }
      })

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // 점수 계산 (입력 기반)
      const fitnessScore = fitnessLevel * 8 // 8-40
      const frequencyScore = Math.min(weeklyFrequency, 5) * 6 // 6-30
      const experienceBonus: Record<ExperienceLevel, number> = {
        beginner: 5,
        intermediate: 10,
        advanced: 15,
        expert: 20
      }
      const injuryDeduction = (injuryHistory.length > 0 && injuryHistory[0] !== 'none') ? 10 : 0
      const calculatedScore = Math.min(100, Math.max(40,
        30 + fitnessScore + frequencyScore + experienceBonus[experienceLevel] - injuryDeduction
      ))

      fortuneData = {
        fortuneType: 'exercise',
        score: parsedResponse.score || calculatedScore,
        content: parsedResponse.content || '오늘의 운동 조언입니다.',
        summary: parsedResponse.summary || parsedResponse.exerciseKeyword || '오늘의 운동',

        // 입력 데이터
        exerciseGoal,
        sportType,
        sportInfo: {
          nameKo: sportInfo.nameKo,
          emoji: sportInfo.emoji,
          category: sportInfo.category
        },
        weeklyFrequency,
        experienceLevel,
        fitnessLevel,
        injuryHistory,
        preferredTime,

        // 추천 운동 (무료)
        recommendedExercise: parsedResponse.recommendedExercise,

        // 오늘의 루틴 (프리미엄)
        todayRoutine: parsedResponse.todayRoutine,

        // 최적 시간
        optimalTime: parsedResponse.optimalTime,

        // 주간 계획 (프리미엄)
        weeklyPlan: parsedResponse.weeklyPlan,

        // 부상 예방 (프리미엄)
        injuryPrevention: parsedResponse.injuryPrevention,

        // 영양 팁
        nutritionTip: parsedResponse.nutritionTip,

        // 키워드
        exerciseKeyword: parsedResponse.exerciseKeyword,

        // 메타데이터
        timestamp: new Date().toISOString()
      }

      // 캐시 저장
      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'exercise',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })
    }

    // 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'exercise', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    const responsePayload = { success: true, data: fortuneDataWithPercentile }

    await storeFortuneResult(
      fortuneChargeAdmin,
      paidCaller.idempotencyKey,
      paidCaller.userId,
      'exercise',
      responsePayload,
    )

    return new Response(JSON.stringify(withTokenCharge(responsePayload, paidCaller.tokenCharge)), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Exercise Fortune Error:', error)

    // 차감 후 생성 실패 — 환불 후 에러 응답
    if (paidCharge) {
      await refundFortuneCharge(
        fortuneChargeAdmin,
        paidCharge.userId,
        paidCharge.idempotencyKey,
        'exercise',
      )
    }
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '운동 운세 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
