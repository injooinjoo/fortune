/**
 * 시험운 인사이트 (Exam Fortune) Edge Function
 *
 * @description 사주와 시험 정보를 기반으로 합격 운세를 분석합니다.
 *
 * 🔥 프리미엄/블러 로직 완전 제거 - 모든 데이터 무조건 노출
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractExamCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
const supabase = createClient(supabaseUrl, supabaseKey)

async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

const examTypeLabels: Record<string, string> = {
  'csat': '수능',
  'license': '자격증 시험',
  'job': '취업/입사 시험',
  'promotion': '승진/진급 시험',
  'school': '입시/편입 시험',
  'language': '어학 시험',
  'other': '기타 시험'
}

const preparationLabels: Record<string, string> = {
  'perfect': '완벽하게 준비됨',
  'good': '잘 준비되고 있음',
  'normal': '보통 수준',
  'worried': '걱정됨'
}

function calculateDaysRemaining(examDate: string): number {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const exam = new Date(examDate)
  exam.setHours(0, 0, 0, 0)
  const diffTime = exam.getTime() - today.getTime()
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24))
}

function getDdayStage(daysRemaining: number): string {
  if (daysRemaining <= 0) return 'exam_day'
  if (daysRemaining <= 3) return 'final_sprint'
  if (daysRemaining <= 7) return 'last_week'
  if (daysRemaining <= 14) return 'two_weeks'
  if (daysRemaining <= 30) return 'one_month'
  if (daysRemaining <= 60) return 'two_months'
  return 'long_term'
}

interface ExamFortuneRequest {
  userId?: string
  birthDate?: string
  birthTime?: string
  gender?: string
  // camelCase (legacy)
  examType?: string
  examDate?: string
  preparation?: string
  // snake_case (Flutter client)
  exam_category?: string
  exam_date?: string
  preparation_status?: string
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
    const requestData: ExamFortuneRequest = await req.json()

    // snake_case (Flutter) 우선, camelCase (legacy) 폴백
    const examType = requestData.exam_category || requestData.examType || 'other'
    const examDate = requestData.exam_date || requestData.examDate
    const preparation = requestData.preparation_status || requestData.preparation || 'normal'
    const { birthDate, birthTime, gender } = requestData

    if (!examDate) {
      throw new Error('시험 날짜를 입력해주세요.')
    }

    const daysRemaining = calculateDaysRemaining(examDate)
    const ddayStage = getDdayStage(daysRemaining)
    const examTypeLabel = examTypeLabels[examType] || '시험'
    const preparationLabel = preparationLabels[preparation] || '보통'

    console.log('Exam fortune request:', { examType, examDate, daysRemaining, ddayStage, preparation })

    const hash = await createHash(`exam_${examType}_${examDate}_${preparation}_${birthDate || ''}`)
    const cacheKey = `exam_fortune_v3_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    // ===== Cohort Pool 조회 =====
    const cohortData = extractExamCohort({ examType, birthDate })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[fortune-exam] 🔍 Cohort: ${JSON.stringify(cohortData)}, hash: ${cohortHash.slice(0, 8)}...`)

    if (cachedResult?.result) {
      console.log('Cache hit for exam fortune')
      fortuneData = cachedResult.result
    } else {
      // Cohort Pool 조회
      const cohortResult = await getFromCohortPool(supabase, 'exam', cohortHash)

      if (cohortResult) {
        console.log(`[fortune-exam] ✅ Cohort Pool HIT!`)

        // Personalize
        const personalizedResult = personalize(cohortResult, {
          '{{examType}}': examTypeLabel,
          '{{examDate}}': examDate,
          '{{daysRemaining}}': String(daysRemaining),
          '{{preparation}}': preparationLabel,
        })

        fortuneData = typeof personalizedResult === 'string'
          ? JSON.parse(personalizedResult)
          : personalizedResult

        // 동적 필드 업데이트
        fortuneData.exam_type = examTypeLabel
        fortuneData.exam_date = examDate
        fortuneData.days_remaining = daysRemaining
        fortuneData.dday_stage = ddayStage
        fortuneData.preparation_status = preparationLabel
        fortuneData.timestamp = new Date().toISOString()
      } else {
        console.log('[fortune-exam] 💨 Cohort Pool MISS - LLM 호출 필요')

      const ddayLabel = daysRemaining > 0 ? `D-${daysRemaining}` : daysRemaining === 0 ? 'D-Day' : `D+${Math.abs(daysRemaining)}`

      const prompt = `당신은 20년 경력의 시험운 전문 상담가입니다.
교육심리학, 스트레스 관리, 학습 효율화 전문가로서 수험생에게 실질적이고 구체적인 조언을 제공합니다.
뻔한 위로가 아닌, 합격의 기운을 불어넣는 구체적인 암시와 멘탈 관리 실전 팁을 제공하세요.

🎯 수험생 정보:
- 시험 종류: ${examTypeLabel}
- 시험 날짜: ${examDate} (${ddayLabel})
- 현재 단계: ${ddayStage}
- 준비 상태: ${preparationLabel}
${birthDate ? `- 생년월일: ${birthDate}` : ''}
${birthTime ? `- 출생 시간: ${birthTime}` : ''}
${gender ? `- 성별: ${gender === 'male' ? '남성' : '여성'}` : ''}

다음 JSON 형식으로 응답해주세요. 모든 필드는 필수입니다:

{
  "score": 92,
  "statusMessage": "합격 가시권 진입! 정답을 낚아챌 준비가 되었습니다.",
  "passGrade": "A",

  "examStats": {
    "answerIntuition": 95,
    "answerIntuitionDesc": "모르는 문제도 정답으로 유도하는 운의 흐름",
    "mentalDefense": 82,
    "mentalDefenseDesc": "시험장의 소음과 긴장감을 차단하는 집중력",
    "memoryAcceleration": "UP",
    "memoryAccelerationDesc": "지금 보는 오답 노트가 머릿속에 바로 각인되는 상태"
  },

  "todayStrategy": {
    "mainAction": "가장 헷갈렸던 오답 노트를 딱 10분만 다시 훑어보세요",
    "actionReason": "그 10분이 시험장에서 1점을 결정합니다",
    "luckyFood": "다크 초콜릿 한 조각",
    "luckyFoodReason": "두뇌 회전을 돕는 오늘의 행운 아이템"
  },

  "spiritAnimal": {
    "animal": "호랑이",
    "message": "호랑이의 눈매처럼 날카로운 통찰력이 당신에게 깃듭니다",
    "direction": "남쪽",
    "directionTip": "남쪽 향해 공부하면 막힌 아이디어가 호랑이 기세처럼 터져 나옵니다"
  },

  "hashtags": ["#집중력_치트키", "#정답만_보이는_눈", "#합격기원"],

  "luckyInfo": {
    "luckyTime": "오전 10시-11시",
    "unluckyTime": "오후 3시-4시",
    "luckyColor": "파란색",
    "luckyColorReason": "집중력과 안정감을 높여줍니다",
    "luckyItem": "파란색 볼펜",
    "luckyItemReason": "마음을 차분하게 해주는 아이템",
    "luckyFood": "바나나와 견과류",
    "luckyFoodReason": "두뇌 활성화와 집중력에 좋습니다",
    "luckyDirection": "동쪽",
    "luckyDirectionTip": "시험장에 동쪽 문으로 입장하면 좋은 기운"
  },

  "ddayAdvice": [
    "${ddayLabel} 맞춤 핵심 조언",
    "구체적인 실천 방법",
    "마음가짐 조언"
  ],

  "studyTips": {
    "todayTip": "오늘의 학습 전략",
    "focusMethod": "집중력 향상 방법",
    "bestStudyTime": "오전 9시-12시",
    "memoryTip": "암기력 향상 팁"
  },

  "warnings": [
    "첫 번째 주의사항",
    "두 번째 주의사항"
  ],

  "mentalCare": {
    "anxietyTip": "불안 해소 방법",
    "affirmation": "나는 충분히 준비했다. 내 실력을 믿는다!",
    "confidenceTip": "자신감 키우는 방법"
  },

  "sajuAnalysis": {
    "elementStrength": "현재 기운 분석",
    "studyElement": "학업에 유리한 기운",
    "examDayEnergy": "시험일 에너지 분석"
  },

  "summary": "합격 운이 강한 시기입니다!",
  "detailedMessage": "상세한 종합 메시지"
}

⚠️ 중요 규칙:
1. 모든 텍스트는 한국어로 작성
2. 절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요
3. examStats의 answerIntuition, mentalDefense는 60-100 사이 정수
4. memoryAcceleration은 "UP", "DOWN", "STABLE" 중 하나
5. spiritAnimal.animal은 "호랑이", "용", "봉황", "거북이", "백호" 중 하나
6. hashtags는 3개의 해시태그 배열 (# 포함)
7. 구체적이고 실용적인 조언 제공
8. ${preparationLabel} 상태를 고려하여 조언 톤 조절
9. ${ddayLabel}에 맞는 시기적절한 조언
10. 뻔한 "노력하면 좋은 결과" 대신 합격 기운을 불어넣는 구체적인 암시 사용`

      const llm = await LLMFactory.createFromConfigAsync('exam')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 한국의 전문 시험 운세 상담가입니다. 사주, 풍수, 오행을 기반으로 시험 합격 운세를 제공합니다. 항상 한국어로 응답하며, 구체적이고 실용적인 조언을 제공합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 1,
        maxTokens: 4096,
        jsonMode: true
      })

      console.log(`LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      await UsageLogger.log({
        fortuneType: 'exam',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: { examType, examDate, daysRemaining, preparation }
      })

      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('JSON parsing error:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // 🔥 블러 로직 완전 제거 - 모든 데이터 무조건 노출
      // Flutter UI 필드명 매핑 (snake_case)
      const luckyInfo = parsedResponse.luckyInfo || {
        luckyTime: '오전 9시-10시',
        unluckyTime: '오후 2시-3시',
        luckyColor: '파란색',
        luckyColorReason: '집중력 향상에 좋습니다',
        luckyItem: '손목시계',
        luckyItemReason: '시간 관리의 상징',
        luckyFood: '바나나',
        luckyFoodReason: '두뇌 활성화에 좋습니다',
        luckyDirection: '동쪽',
        luckyDirectionTip: '동쪽으로 입장하세요'
      }

      const studyTips = parsedResponse.studyTips || {
        todayTip: '핵심 개념 정리에 집중하세요',
        focusMethod: '25분 집중, 5분 휴식',
        bestStudyTime: '오전 9시-12시',
        memoryTip: '반복보다 이해 위주로'
      }

      const ddayAdviceArr = parsedResponse.ddayAdvice || [
        '차분하게 준비하세요',
        '수면을 충분히 취하세요',
        '자신감을 가지세요'
      ]

      const mentalCare = parsedResponse.mentalCare || {
        anxietyTip: '심호흡으로 긴장을 풀어주세요',
        affirmation: '나는 충분히 준비했다!',
        confidenceTip: '지금까지의 노력을 믿으세요'
      }

      const sajuAnalysis = parsedResponse.sajuAnalysis || {
        elementStrength: '학업운이 좋은 시기입니다',
        studyElement: '집중력이 높아지는 기운입니다',
        examDayEnergy: '실력 발휘에 유리한 날입니다'
      }

      const warnings = parsedResponse.warnings || ['무리한 밤샘 공부 금지', '카페인 과다 섭취 주의']

      // 새로운 필드들 파싱
      const examStats = parsedResponse.examStats || {
        answerIntuition: 85,
        answerIntuitionDesc: '모르는 문제도 정답으로 유도하는 운의 흐름',
        mentalDefense: 80,
        mentalDefenseDesc: '시험장의 소음과 긴장감을 차단하는 집중력',
        memoryAcceleration: 'UP',
        memoryAccelerationDesc: '지금 보는 오답 노트가 머릿속에 바로 각인되는 상태'
      }

      const todayStrategy = parsedResponse.todayStrategy || {
        mainAction: '가장 헷갈렸던 오답 노트를 딱 10분만 다시 훑어보세요',
        actionReason: '그 10분이 시험장에서 1점을 결정합니다',
        luckyFood: '다크 초콜릿 한 조각',
        luckyFoodReason: '두뇌 회전을 돕는 오늘의 행운 아이템'
      }

      const spiritAnimal = parsedResponse.spiritAnimal || {
        animal: '호랑이',
        message: '호랑이의 눈매처럼 날카로운 통찰력이 당신에게 깃듭니다',
        direction: '남쪽',
        directionTip: '남쪽 향해 공부하면 막힌 아이디어가 호랑이 기세처럼 터져 나옵니다'
      }

      const hashtags = parsedResponse.hashtags || ['#집중력_치트키', '#정답만_보이는_눈', '#합격기원']

      fortuneData = {
        fortuneType: 'exam',
        title: `${examTypeLabel} 시험운`,
        exam_type: examTypeLabel,
        exam_date: examDate,
        days_remaining: daysRemaining,
        dday_stage: ddayStage,
        preparation_status: preparationLabel,

        // 합격 운세 (Flutter UI 필드명)
        score: parsedResponse.score || 78,
        status_message: parsedResponse.statusMessage || parsedResponse.passMessage || '합격 가능성이 좋습니다!',
        pass_possibility: parsedResponse.statusMessage || parsedResponse.passMessage || '합격 가능성이 좋습니다!',
        pass_grade: parsedResponse.passGrade || 'B+',
        overall_fortune: parsedResponse.summary || '합격 운이 강한 시기입니다!',

        // 🆕 시험 스탯 (Flutter UI: exam_stats)
        exam_stats: {
          answer_intuition: examStats.answerIntuition,
          answer_intuition_desc: examStats.answerIntuitionDesc,
          mental_defense: examStats.mentalDefense,
          mental_defense_desc: examStats.mentalDefenseDesc,
          memory_acceleration: examStats.memoryAcceleration,
          memory_acceleration_desc: examStats.memoryAccelerationDesc
        },

        // 🆕 오늘의 1점 전략 (Flutter UI: today_strategy)
        today_strategy: {
          main_action: todayStrategy.mainAction,
          action_reason: todayStrategy.actionReason,
          lucky_food: todayStrategy.luckyFood,
          lucky_food_reason: todayStrategy.luckyFoodReason
        },

        // 🆕 영물의 기개 (Flutter UI: spirit_animal)
        spirit_animal: {
          animal: spiritAnimal.animal,
          message: spiritAnimal.message,
          direction: spiritAnimal.direction,
          direction_tip: spiritAnimal.directionTip
        },

        // 🆕 해시태그 (Flutter UI: hashtags)
        hashtags: hashtags,

        // 행운 정보 (Flutter UI 필드명: snake_case)
        lucky_hours: luckyInfo.luckyTime || '오전 9시-10시',
        unlucky_hours: luckyInfo.unluckyTime || '오후 2시-3시',
        lucky_color: luckyInfo.luckyColor || '파란색',
        lucky_item: luckyInfo.luckyItem || '손목시계',
        lucky_food: luckyInfo.luckyFood || '바나나',
        lucky_direction: luckyInfo.luckyDirection || '동쪽',
        focus_subject: studyTips.todayTip || '핵심 개념 정리',
        exam_keyword: parsedResponse.passGrade || 'A',

        // D-day 조언 (Flutter UI: dday_advice)
        dday_advice: ddayAdviceArr.join(' | '),

        // 공부법 (Flutter UI: study_methods 배열)
        study_methods: [
          studyTips.todayTip,
          studyTips.focusMethod,
          studyTips.memoryTip
        ].filter(Boolean),
        best_study_time: studyTips.bestStudyTime || '오전 9시-12시',

        // 주의사항 (Flutter UI: cautions 배열)
        cautions: warnings,

        // 멘탈 관리 (Flutter UI 필드명)
        mental_tip: mentalCare.anxietyTip || '심호흡으로 긴장을 풀어주세요',
        affirmation: mentalCare.affirmation || '나는 충분히 준비했다!',
        confidence_tip: mentalCare.confidenceTip || '지금까지의 노력을 믿으세요',
        mentalCare: mentalCare,

        // 사주 분석 (Flutter UI에서 sajuAnalysis 객체 사용)
        sajuAnalysis: sajuAnalysis,

        // 요약
        summary: parsedResponse.summary || '합격 운이 좋은 시기입니다!',
        content: parsedResponse.detailedMessage || parsedResponse.statusMessage || parsedResponse.passMessage || '시험 준비가 잘 되고 있습니다.',
        advice: mentalCare.affirmation || '자신감을 가지세요!',

        timestamp: new Date().toISOString()
      }

      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'exam',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
        })

      // ===== Cohort Pool 저장 (Fire-and-forget) =====
      saveToCohortPool(supabase, 'exam', cohortHash, fortuneData)
        .then(() => console.log(`[fortune-exam] 💾 Cohort Pool 저장 완료`))
        .catch((err) => console.error(`[fortune-exam] ⚠️ Cohort Pool 저장 실패:`, err))
      } // Close cohort miss else block
    }

    const percentileData = await calculatePercentile(supabase, 'exam', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    return new Response(JSON.stringify({
      success: true,
      data: fortuneDataWithPercentile
    }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Exam Fortune Error:', error)

    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '시험운 분석 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
