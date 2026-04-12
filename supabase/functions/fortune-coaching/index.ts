/**
 * 코칭운 (Coaching Fortune) Edge Function
 *
 * @description 사용자의 목표, 방해 요소, 가용 시간을 기반으로 AI 기반 실행력 코칭을 생성합니다.
 *
 * @endpoint POST /fortune-coaching
 *
 * @requestBody
 * - userId?: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - mbti?: string - MBTI 유형
 * - birthDate / birth_date?: string - 생년월일 (YYYY-MM-DD)
 * - currentGoal / current_goal: string - 집중하고 싶은 목표
 * - blocker: string - 실행을 방해하는 요소
 * - timeAvailable / time_available: string - 오늘 집중 가능한 시간
 *
 * @response { success: true, data: CoachingFortuneData }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/* ------------------------------------------------------------------ */
/*  목표 / 방해 요소 카탈로그                                             */
/* ------------------------------------------------------------------ */

const GOAL_LABELS: Record<string, string> = {
  work: '업무/프로젝트',
  study: '공부/자격증',
  health: '운동/건강',
  creative: '창작/사이드 프로젝트',
  habit: '습관 만들기',
  decision: '중요한 결정',
}

const BLOCKER_LABELS: Record<string, string> = {
  motivation: '동기 부족',
  overwhelm: '할 게 너무 많음',
  perfectionism: '완벽주의',
  time: '시간 부족',
  direction: '방향을 모르겠음',
  energy: '에너지 부족',
}

const TIME_LABELS: Record<string, string> = {
  '30min': '30분 이내',
  '1hr': '1시간',
  '2hr': '2~3시간',
  halfday: '반나절 이상',
}

/* ------------------------------------------------------------------ */
/*  LLM prompt builder                                                 */
/* ------------------------------------------------------------------ */

function buildPrompt(
  name: string,
  goal: string,
  blocker: string,
  timeAvailable: string,
  mbti?: string,
): string {
  const goalLabel = GOAL_LABELS[goal] ?? goal
  const blockerLabel = BLOCKER_LABELS[blocker] ?? blocker
  const timeLabel = TIME_LABELS[timeAvailable] ?? timeAvailable

  const today = new Date(
    new Date().toLocaleString('en-US', { timeZone: 'Asia/Seoul' }),
  )
  const dateStr = `${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일`
  const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]

  const mbtiLine = mbti ? `MBTI: ${mbti}` : ''

  return `당신은 실행력 코칭 전문가입니다. 동기부여가 아닌 구체적 행동 전략을 제시합니다.
오늘은 ${dateStr} ${dayOfWeek}요일입니다.
사용자 이름: ${name}
${mbtiLine}
집중 목표: ${goalLabel}
실행 방해 요소: ${blockerLabel}
가용 시간: ${timeLabel}

아래 JSON 형식으로 오늘의 코칭 분석을 작성해주세요. 반드시 JSON만 출력하세요.

{
  "overall_score": (1-100 정수, 오늘의 전체 실행력 점수),
  "summary": "(오늘의 코칭 요약 2-3문장)",
  "advice": "(핵심 조언 1문장)",
  "execution_metrics": {
    "execution": { "score": (1-100), "description": "(실행력 분석 1-2문장)" },
    "persistence": { "score": (1-100), "description": "(지속력 분석 1-2문장)" },
    "recovery": { "score": (1-100), "description": "(복구력 분석 1-2문장)" }
  },
  "action_plan": [
    { "title": "(1단계 제목)", "description": "(구체적 행동 1-2문장)" },
    { "title": "(2단계 제목)", "description": "(구체적 행동 1-2문장)" },
    { "title": "(3단계 제목)", "description": "(구체적 행동 1-2문장)" }
  ],
  "blocker_advice": "(${blockerLabel}에 특화된 구체적 극복 전략 2-3문장)",
  "mindset_tips": [
    "(마인드셋 팁 1)",
    "(마인드셋 팁 2)",
    "(마인드셋 팁 3)"
  ],
  "daily_routine": "(오늘 ${timeLabel} 안에 실행할 수 있는 추천 루틴 2-3문장)",
  "warning": "(오늘 피해야 할 함정 1-2문장)",
  "motivation": "(동기 부여 마무리 메시지 1-2문장)",
  "strengths": ["(실행 강점 1)", "(실행 강점 2)", "(실행 강점 3)"],
  "growth_areas": ["(성장 포인트 1)", "(성장 포인트 2)"],
  "highlights": [
    "(핵심 인사이트 1)",
    "(핵심 인사이트 2)",
    "(핵심 인사이트 3)"
  ]
}`
}

/* ------------------------------------------------------------------ */
/*  Handler                                                            */
/* ------------------------------------------------------------------ */

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const request = await req.json()

    // health check
    if (request.healthCheck === true) {
      return new Response(
        JSON.stringify({
          success: true,
          status: 'healthy',
          fortuneType: 'coaching',
          timestamp: new Date().toISOString(),
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 200,
        },
      )
    }

    const currentGoal = request.currentGoal || request.current_goal
    const blocker = request.blocker
    const timeAvailable = request.timeAvailable || request.time_available
    const rawName = request.name
    const invalidNames = ['undefined', 'null', 'Unknown', '']
    const name = rawName && !invalidNames.includes(rawName) ? rawName : '회원님'
    const mbti = request.mbti

    if (!currentGoal) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '집중 목표(currentGoal)가 필요합니다.',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400,
        },
      )
    }

    const goalLabel = GOAL_LABELS[currentGoal] ?? currentGoal
    const blockerLabel = BLOCKER_LABELS[blocker] ?? blocker ?? '없음'
    console.log(`🎯 [coaching] ${name} → 목표: ${goalLabel}, 방해: ${blockerLabel}`)

    // LLM 호출
    const llm = LLMFactory.createFromConfig('coaching')
    const prompt = buildPrompt(name, currentGoal, blocker, timeAvailable, mbti)

    const llmResponse = await llm.generate([
      { role: 'system', content: '당신은 실행력 코칭 전문가입니다. 동기부여가 아닌 구체적 행동 전략을 제시합니다. 반드시 유효한 JSON만 출력하세요.' },
      { role: 'user', content: prompt },
    ], {
      temperature: 0.8,
      maxTokens: 2500,
      jsonMode: true,
    })

    let fortune: Record<string, unknown>
    try {
      fortune = JSON.parse(llmResponse.content)
    } catch {
      console.error('[coaching] JSON 파싱 실패:', llmResponse.content.slice(0, 200))
      fortune = buildFallbackFortune(name, currentGoal, blocker, timeAvailable)
    }

    const score = Number(fortune.overall_score) || 78
    const executionMetrics = fortune.execution_metrics as Record<string, { score: number; description: string }> ?? {}
    const actionPlanArr = (fortune.action_plan as Array<{ title: string; description: string }>) ?? []
    const mindsetTips = (fortune.mindset_tips as string[]) ?? []
    const strengths = (fortune.strengths as string[]) ?? []
    const growthAreas = (fortune.growth_areas as string[]) ?? []
    const highlights = (fortune.highlights as string[]) ?? []

    const data = {
      fortuneType: 'coaching' as const,
      score,
      content: `${name}님의 오늘의 코칭 분석입니다. ${fortune.summary || ''}`,
      summary: (fortune.summary as string) || '오늘의 실행력을 분석하고 맞춤 전략을 준비했습니다.',
      advice: (fortune.advice as string) || '작게 시작하되, 끝까지 완수하세요.',
      timestamp: new Date().toISOString(),

      // survey inputs
      currentGoal,
      currentGoalLabel: goalLabel,
      blocker,
      blockerLabel,
      timeAvailable,
      timeAvailableLabel: TIME_LABELS[timeAvailable] ?? timeAvailable,

      // execution metrics (3 core scores)
      executionScore: executionMetrics.execution?.score ?? 85,
      executionDescription: executionMetrics.execution?.description ?? '시작 버튼이 빠른 편입니다.',
      persistenceScore: executionMetrics.persistence?.score ?? 72,
      persistenceDescription: executionMetrics.persistence?.description ?? '중간 이탈을 경계해야 합니다.',
      recoveryScore: executionMetrics.recovery?.score ?? 80,
      recoveryDescription: executionMetrics.recovery?.description ?? '흔들려도 복귀가 빠릅니다.',

      // action plan (3 steps)
      actionPlan: actionPlanArr.length > 0
        ? actionPlanArr.slice(0, 3).map((step, i) => ({
            title: step.title ?? `${i + 1}단계`,
            description: step.description ?? '',
          }))
        : [
            { title: '목표 정의', description: '오늘 끝낼 목표를 한 문장으로 적습니다.' },
            { title: '분해', description: '10분 안에 시작할 수 있을 만큼 작게 쪼갭니다.' },
            { title: '확인', description: '마무리 후 바로 다음 행동을 하나 예약합니다.' },
          ],

      // blocker-specific advice
      blockerAdvice: (fortune.blocker_advice as string) || `${blockerLabel}을 극복하려면 환경부터 바꿔보세요.`,

      // mindset tips
      mindsetTips: mindsetTips.length > 0
        ? mindsetTips.slice(0, 5)
        : ['완벽하지 않아도 시작하세요.', '작은 성공이 큰 동력이 됩니다.', '비교보다 어제의 나와 경쟁하세요.'],

      // daily routine
      dailyRoutine: (fortune.daily_routine as string) || '가장 중요한 일을 아침에 먼저 처리하고, 나머지는 흐름에 맡기세요.',

      // warning / trap to avoid
      warning: (fortune.warning as string) || '완벽하게 준비하려다 시작 자체를 미루는 함정에 빠지지 마세요.',

      // motivational closing
      motivation: (fortune.motivation as string) || '오늘 한 걸음이 내일의 자신감이 됩니다. 시작한 것만으로 이미 앞서가고 있어요.',

      // strengths & growth areas
      strengths: strengths.length > 0
        ? strengths.slice(0, 4)
        : ['빠른 실행력', '높은 적응력', '문제 해결 감각'],
      growthAreas: growthAreas.length > 0
        ? growthAreas.slice(0, 4)
        : ['완벽주의 내려놓기', '지속력 강화'],

      highlights: highlights.length > 0
        ? highlights.slice(0, 5)
        : [
            '오늘은 의욕보다 순서가 중요합니다.',
            '작은 체크 표시가 동력을 유지해 줍니다.',
            '70% 상태로 바로 시작하는 게 핵심입니다.',
          ],

      // detailed analysis for raw rendering
      detailedAnalysis: (fortune.blocker_advice as string) || '',

      name,
      userId: request.userId ?? null,
      isPremium: request.isPremium ?? false,

      // LLM usage metadata
      tokensUsed: llmResponse.usage?.totalTokens ?? 0,
      provider: llmResponse.provider ?? 'unknown',
    }

    return new Response(
      JSON.stringify({ success: true, data }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error in fortune-coaching:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: '코칭 분석 중 오류가 발생했습니다.',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500,
      },
    )
  }
})

/* ------------------------------------------------------------------ */
/*  Fallback (LLM 실패 시)                                             */
/* ------------------------------------------------------------------ */

function buildFallbackFortune(
  name: string,
  currentGoal: string,
  blocker: string,
  timeAvailable: string,
): Record<string, unknown> {
  const goalLabel = GOAL_LABELS[currentGoal] ?? currentGoal
  const blockerLabel = BLOCKER_LABELS[blocker] ?? blocker ?? '없음'
  const timeLabel = TIME_LABELS[timeAvailable] ?? timeAvailable ?? '1시간'

  return {
    overall_score: 78,
    summary: `${name}님, 오늘은 ${goalLabel}에 집중하기 좋은 에너지가 있습니다. ${blockerLabel}을 의식하면서 ${timeLabel} 안에 핵심만 끝내는 전략이 효과적입니다.`,
    advice: '완벽한 계획보다 즉시 실행이 더 나은 결과를 만듭니다.',
    execution_metrics: {
      execution: { score: 85, description: '시작 속도가 빠르고 행동력이 좋습니다.' },
      persistence: { score: 72, description: '중반 이후 집중력이 흔들릴 수 있으니 짧은 주기로 확인하세요.' },
      recovery: { score: 80, description: '실패 후 복귀가 빠른 편입니다. 자책보다 다음 행동에 집중하세요.' },
    },
    action_plan: [
      { title: '목표 선언', description: `${goalLabel} 중에서 오늘 끝낼 수 있는 한 가지를 골라 적습니다.` },
      { title: '시간 블록', description: `${timeLabel} 중 처음 25분을 가장 중요한 작업에 배정합니다.` },
      { title: '완료 확인', description: '마무리 후 완료 표시를 하고, 내일 할 일을 한 줄 적습니다.' },
    ],
    blocker_advice: `${blockerLabel}이 발목을 잡고 있다면, 환경을 먼저 바꿔보세요. 물리적으로 자리를 옮기거나, 방해 요소를 눈에 안 보이는 곳에 치우는 것만으로도 실행력이 올라갑니다.`,
    mindset_tips: [
      '완벽하지 않아도 시작하는 것이 실력입니다.',
      '작은 완료가 모여 큰 자신감이 됩니다.',
      '어제의 나보다 1% 나아지면 충분합니다.',
    ],
    daily_routine: `아침에 가장 중요한 한 가지를 먼저 처리하고, ${timeLabel} 안에 핵심 작업을 끝낸 후 가볍게 정리하세요.`,
    warning: '모든 것을 한 번에 하려는 욕심이 가장 큰 적입니다. 오늘은 하나만 끝내세요.',
    motivation: '시작한 것만으로 이미 절반은 끝났습니다. 나머지 절반은 관성이 해줄 거예요.',
    strengths: ['빠른 판단력', '실행 속도', '유연한 적응력'],
    growth_areas: ['지속력 강화', '완벽주의 내려놓기'],
    highlights: [
      '오늘은 의욕보다 순서가 중요합니다.',
      '작은 체크 표시가 동력을 유지해 줍니다.',
      '70% 상태로 바로 시작하는 게 핵심입니다.',
    ],
  }
}
