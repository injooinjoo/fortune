/**
 * 시간 운세 (Time Fortune) Edge Function - LLM 기반 경계대상 패턴 적용
 *
 * @description 사용자의 사주와 오늘의 천기를 기반으로 시간대별 운세를 LLM으로 분석합니다.
 * 한국 전통 역학(12시진, 오행, 일진)과 경계대상 패턴(8개 카테고리)을 적용합니다.
 *
 * @endpoint POST /fortune-time
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (ISO 8601)
 * - birthTime?: string - 출생 시간
 * - gender: string - 성별
 * - isLunar?: boolean - 음력 여부
 * - mbtiType?: string - MBTI 유형
 * - bloodType?: string - 혈액형
 * - zodiacSign?: string - 별자리
 * - zodiacAnimal?: string - 띠
 * - userLocation?: object - 사용자 위치 정보
 * - period?: string - 기간 ('today' 기본값)
 * - date?: string - 특정 날짜
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response TimeFortuneResponse (경계대상 패턴 적용)
 * - score: number - 전체 점수 (0-100)
 * - content: string - 핵심 내용
 * - summary: string - 요약
 * - advice: string - 조언
 * - timeSlots: object[] - 시간대별 운세 (12시진 기반)
 * - cautionTimes: object[] - 주의 시간대
 * - cautionActivities: object[] - 주의 활동
 * - cautionPeople: object[] - 주의 인물 유형 (띠 기반)
 * - cautionDirections: object[] - 주의 방향
 * - luckyElements: object - 행운 요소 (색상, 숫자, 방향, 아이템)
 * - timeStrategy: object - 시간대별 전략 (오전/오후/저녁)
 * - traditionalElements: object - 전통 요소 (오행, 일진, 12시진)
 *
 * @example
 * // Response
 * {
 *   "fortune": {
 *     "score": 78,
 *     "cautionTimes": [{ "time": "오후 2-4시", "reason": "...", "severity": "warning" }],
 *     "luckyElements": { "colors": ["파란색"], "numbers": [3, 7], "direction": "동쪽" },
 *     "timeStrategy": { "morning": { "caution": "...", "advice": "...", "luckyAction": "..." } }
 *   }
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

/**
 * 다중 날짜 운세 처리 함수
 */
async function handleMultipleDates(params: {
  req: Request,
  supabaseClient: any,
  requestData: any,
  targetDatesParam: string[],
  eventsPerDateParam: Record<string, any[]>,
  calendarEvents: any[],
  calendarSynced: boolean,
  isPremium: boolean,
  name: string,
  birthDate: string,
  birthTime: string,
  gender: string,
  isLunar: boolean,
  zodiacSign: string,
  zodiacAnimal: string,
  mbtiType: string,
  userId: string,
  processedLocation: string,
  corsHeaders: Record<string, string>
}) {
  const {
    supabaseClient, targetDatesParam, eventsPerDateParam, calendarEvents,
    calendarSynced, isPremium, name, birthDate, birthTime, gender, isLunar,
    zodiacSign, zodiacAnimal, mbtiType, userId, processedLocation, corsHeaders: headers
  } = params

  console.log(`[fortune-time] 📅 다중 날짜 모드 시작: ${targetDatesParam.length}개 날짜`)

  // 날짜별 정보 구성
  const datesInfo = targetDatesParam.map(dateStr => {
    const date = new Date(dateStr)
    const events = eventsPerDateParam?.[dateStr] || []
    const dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일']

    return {
      date,
      dateStr,
      displayStr: `${date.getMonth() + 1}월 ${date.getDate()}일 ${dayNames[date.getDay()]}`,
      events
    }
  })

  // 첫 날짜와 마지막 날짜
  const firstDate = datesInfo[0]
  const lastDate = datesInfo[datesInfo.length - 1]
  const periodStr = datesInfo.length === 1
    ? firstDate.displayStr
    : `${firstDate.date.getMonth() + 1}/${firstDate.date.getDate()} ~ ${lastDate.date.getMonth() + 1}/${lastDate.date.getDate()} (${datesInfo.length}일)`

  // LLM 모듈 사용
  const llm = await LLMFactory.createFromConfigAsync('fortune-time')

  // 날짜별 일정 포맷팅
  const formatMultipleDatesEvents = () => {
    if (datesInfo.every(d => d.events.length === 0)) return ''

    const sections = datesInfo
      .filter(d => d.events.length > 0)
      .map(d => {
        const eventList = d.events.map((e: any, i: number) => {
          const title = e.title || '일정'
          const isAllDay = e.is_all_day || e.isAllDay
          const location = e.location ? ` (장소: ${e.location})` : ''
          const time = isAllDay ? '종일' : e.start_time ? new Date(e.start_time).toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' }) : ''
          return `    ${i + 1}. ${title}${time ? ` - ${time}` : ''}${location}`
        }).join('\n')

        return `  📅 ${d.displayStr} (${d.events.length}개):\n${eventList}`
      }).join('\n\n')

    return `
**📆 선택한 날짜별 일정**:
${sections}

⚠️ 중요: 각 날짜별 일정을 반드시 해당 날짜 운세 분석에 반영해주세요!`
  }

  // 시스템 프롬프트
  const systemPrompt = `당신은 한국 전통 역학(易學)과 현대 시간 관리론을 결합한 시간 인사이트 전문가입니다.
사용자의 사주(生年月日時)와 선택한 기간의 천기(天氣)를 분석하여 날짜별 인사이트를 제공합니다.

**분석 기준**:
1. 사주팔자의 오행(五行) 균형 분석
2. 각 날짜의 일진(日辰)과 사용자 사주의 상호작용
3. 날짜간 기운의 흐름과 변화
4. 띠 궁합 기반 대인관계 조언
5. 방위별 길흉 판단

**경계대상 패턴 적용**:
- 주의 시간대/날짜: 피해야 할 활동과 이유
- 행운 요소: 색상, 숫자, 방향, 아이템

**응답 규칙**:
- 각 날짜별로 구분하여 분석
- 일정이 있는 날은 일정에 맞는 구체적 조언
- 전체 기간의 흐름과 패턴 분석
- 가장 좋은 날과 주의할 날 명시`

  // 사용자 프롬프트
  const calendarSection = formatMultipleDatesEvents()
  const hasEvents = datesInfo.some(d => d.events.length > 0)
  const totalEvents = datesInfo.reduce((sum, d) => sum + d.events.length, 0)

  const userPrompt = `다음 정보를 기반으로 선택한 기간(${periodStr})의 운세를 분석해주세요:

**기본 정보**:
- 이름: ${name}
- 생년월일: ${birthDate}${isLunar ? ' (음력)' : ''}
${birthTime ? `- 출생 시간: ${birthTime}` : ''}
${gender ? `- 성별: ${gender === 'male' ? '남성' : '여성'}` : ''}
${zodiacAnimal ? `- 띠: ${zodiacAnimal}` : ''}
${zodiacSign ? `- 별자리: ${zodiacSign}` : ''}
${mbtiType ? `- MBTI: ${mbtiType}` : ''}

**분석 기간**: ${periodStr}
**분석할 날짜들**:
${datesInfo.map(d => `  - ${d.displayStr}`).join('\n')}
${calendarSection}

**응답 형식** (반드시 JSON, 절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요):
\`\`\`json
{
  "overallScore": 기간 전체 평균 점수 (0-100),
  "summary": "기간 전체 운세 한 줄 요약",
  "periodAdvice": "기간 전체에 대한 종합 조언",

  "bestDate": {
    "date": "YYYY-MM-DD",
    "reason": "가장 좋은 날인 이유"
  },
  "worstDate": {
    "date": "YYYY-MM-DD",
    "reason": "주의할 날인 이유"
  },

  "dailyFortunes": [
    {
      "date": "YYYY-MM-DD",
      "displayDate": "M월 D일 요일",
      "score": 점수 (0-100),
      "summary": "하루 요약",
      "content": "상세 내용",
      "advice": "하루 조언",
      "luckyElements": {
        "colors": ["색상1", "색상2"],
        "numbers": [숫자1, 숫자2],
        "direction": "방향",
        "items": ["아이템1"]
      },
      "cautionTimes": [
        {
          "time": "시간대",
          "reason": "주의 이유",
          "severity": "high/warning/low"
        }
      ],
      "calendarAdvice": [
        {
          "eventTitle": "일정 제목 (해당 날짜에 일정이 있는 경우)",
          "advice": "일정에 대한 조언",
          "luckyTip": "행운 팁"
        }
      ]
    }
  ],

  "periodTheme": "이 기간의 전체 테마/의미",
  "specialMessage": "기간에 대한 특별 메시지 (100자 이상)"
}
\`\`\`

**주의**:
- dailyFortunes 배열에 선택한 모든 날짜(${datesInfo.length}일)의 운세를 포함해주세요
- 반드시 유효한 JSON 형식으로만 응답하세요`

  console.log(`[fortune-time] 🔄 다중 날짜 LLM 호출 시작...`)

  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userPrompt }
  ], {
    temperature: 1,
    maxTokens: 12000,  // 다중 날짜는 더 많은 토큰 필요
    jsonMode: true
  })

  console.log(`[fortune-time] ✅ 다중 날짜 LLM 응답 수신 (${response.latency}ms, ${response.usage?.totalTokens || 0} tokens)`)

  // LLM 사용량 로깅
  await UsageLogger.log({
    fortuneType: 'time_multiple',
    userId: userId,
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: { name, birthDate, gender, zodiacAnimal, datesCount: datesInfo.length, isPremium }
  })

  // JSON 파싱
  let fortuneData: any
  try {
    fortuneData = typeof response.content === 'string'
      ? JSON.parse(response.content)
      : response.content
  } catch (parseError) {
    console.error(`[fortune-time] ❌ 다중 날짜 JSON 파싱 실패:`, parseError)
    throw new Error('다중 날짜 LLM 응답을 파싱할 수 없습니다')
  }

  const overallScore = fortuneData.overallScore || 75

  // 응답 구성
  const fortune = {
    fortuneType: 'time_multiple',
    score: overallScore,
    content: fortuneData.summary || '',
    summary: fortuneData.summary || '',
    advice: fortuneData.periodAdvice || '',

    // 다중 날짜 전용 필드
    isMultipleDates: true,
    dateCount: datesInfo.length,
    periodStr: periodStr,
    dailyFortunes: fortuneData.dailyFortunes || [],
    bestDate: fortuneData.bestDate || null,
    worstDate: fortuneData.worstDate || null,
    periodTheme: fortuneData.periodTheme || '',
    specialMessage: fortuneData.specialMessage || '',

    // 메시지
    message: `${name}님, ${periodStr} 기간의 인사이트입니다. ✨`,
    greeting: `${name}님, 선택하신 ${periodStr} 기간의 인사이트를 확인해보세요. 🎯`,

    // 메타데이터
    metadata: {
      targetDates: targetDatesParam,
      eventsPerDate: eventsPerDateParam,
      totalEvents: totalEvents,
      generatedAt: new Date().toISOString()
    }
  }

  // Percentile 계산
  const percentileData = await calculatePercentile(supabaseClient, 'time', overallScore)
  const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

  console.log(`[fortune-time] ✅ 다중 날짜 응답 생성 완료`)

  return new Response(
    JSON.stringify({
      fortune: fortuneWithPercentile,
      cached: false,
      tokensUsed: response.usage?.totalTokens || 0
    }),
    {
      headers: { ...headers, 'Content-Type': 'application/json; charset=utf-8' },
      status: 200
    }
  )
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const requestData = await req.json()
    const {
      userId,
      name,
      birthDate,
      birthTime,
      gender,
      isLunar,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal,
      location,
      userLocation,
      period = 'today',
      date,
      targetDate: targetDateParam,
      targetDates: targetDatesParam,  // 다중 날짜 배열
      eventsPerDate: eventsPerDateParam,  // 날짜별 이벤트 맵
      isMultipleDates = false,  // 다중 날짜 모드
      calendarEvents = [],
      calendarSynced = false,
      hasCalendarEvents = false,
      isPremium = false
    } = requestData

    console.log('💎 [Time] Premium 상태:', isPremium)
    console.log(`[fortune-time] 🎯 Request received:`, { userId, name, birthDate, period, isMultipleDates })
    console.log(`[fortune-time] 📅 Calendar info:`, { calendarSynced, hasCalendarEvents, eventsCount: calendarEvents?.length || 0 })
    if (isMultipleDates) {
      console.log(`[fortune-time] 📅 Multiple dates mode:`, { datesCount: targetDatesParam?.length || 0 })
    }

    // 한국 시간대로 현재 날짜 생성 (targetDateParam 우선)
    let targetDate: Date
    let eventsForDate: any[] = []

    // targetDateParam 디버깅
    console.log(`[fortune-time] 📅 targetDateParam raw:`, JSON.stringify(targetDateParam))
    console.log(`[fortune-time] 📅 date raw:`, date)
    console.log(`[fortune-time] 📅 calendarEvents raw:`, JSON.stringify(calendarEvents))

    // targetDateParam이 문자열인 경우 (ISO string으로 전송된 경우)
    if (typeof targetDateParam === 'string') {
      targetDate = new Date(targetDateParam)
      eventsForDate = calendarEvents || []
      console.log(`[fortune-time] 📅 Using targetDateParam as string:`, targetDateParam)
    }
    // targetDateParam이 객체이고 date 필드가 있는 경우
    else if (targetDateParam?.date) {
      // date가 문자열인 경우
      if (typeof targetDateParam.date === 'string') {
        targetDate = new Date(targetDateParam.date)
      } else {
        targetDate = new Date(targetDateParam.date)
      }
      eventsForDate = targetDateParam.events || calendarEvents || []
      console.log(`[fortune-time] 📅 Using targetDateParam.date:`, { date: targetDateParam.date, eventsCount: eventsForDate.length })
    }
    // date 필드가 직접 전달된 경우
    else if (date) {
      targetDate = new Date(date)
      eventsForDate = calendarEvents || []
      console.log(`[fortune-time] 📅 Using date field:`, date)
    }
    // calendarEvents에서 날짜 추출 (fallback)
    else if (calendarEvents?.length > 0 && calendarEvents[0]?.start_time) {
      targetDate = new Date(calendarEvents[0].start_time)
      eventsForDate = calendarEvents
      console.log(`[fortune-time] 📅 Extracted date from calendarEvents:`, calendarEvents[0].start_time)
    }
    // 기본값: 오늘 날짜
    else {
      targetDate = new Date(new Date().toLocaleString("en-US", {timeZone: "Asia/Seoul"}))
      eventsForDate = calendarEvents || []
      console.log(`[fortune-time] 📅 Using today's date (default)`)
    }

    console.log(`[fortune-time] 📅 Final targetDate:`, targetDate.toISOString())

    const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][targetDate.getDay()]
    const dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일']
    const currentDayName = dayNames[targetDate.getDay()]

    // 오늘 날짜인지 확인
    const todayKST = new Date(new Date().toLocaleString("en-US", {timeZone: "Asia/Seoul"}))
    const isToday = targetDate.getFullYear() === todayKST.getFullYear() &&
                    targetDate.getMonth() === todayKST.getMonth() &&
                    targetDate.getDate() === todayKST.getDate()

    // 날짜 표시 문자열 생성
    const dateDisplayStr = isToday
      ? '오늘'
      : `${targetDate.getMonth() + 1}월 ${targetDate.getDate()}일`

    console.log(`[fortune-time] 📅 isToday:`, isToday, `dateDisplayStr:`, dateDisplayStr)

    // 지역 정보 처리
    const processedLocation = userLocation || location || '서울'

    // ✅ 다중 날짜 모드 처리
    if (isMultipleDates && targetDatesParam && targetDatesParam.length > 0) {
      return await handleMultipleDates({
        req,
        supabaseClient,
        requestData,
        targetDatesParam,
        eventsPerDateParam,
        calendarEvents,
        calendarSynced,
        isPremium,
        name,
        birthDate,
        birthTime,
        gender,
        isLunar,
        zodiacSign,
        zodiacAnimal,
        mbtiType,
        userId,
        processedLocation,
        corsHeaders
      })
    }

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('fortune-time')

    // ✅ 경계대상 패턴 적용 - systemPrompt
    const systemPrompt = `당신은 한국 전통 역학(易學)과 현대 시간 관리론을 결합한 시간 운세 전문가입니다.
사용자의 사주(生年月日時)와 오늘의 천기(天氣)를 분석하여 시간대별 운세를 제공합니다.

**분석 기준**:
1. 사주팔자의 오행(五行) 균형 분석
2. 오늘의 일진(日辰)과 사용자 사주의 상호작용
3. 12시진(十二時辰) 기반 시간대별 기운 흐름
4. 띠 궁합 기반 대인관계 조언
5. 방위별 길흉 판단

**시간대 구분 (12시진 기반)**:
- 자시(子時): 23:00-01:00 - 수(水)의 시작
- 축시(丑時): 01:00-03:00 - 토(土)의 안정
- 인시(寅時): 03:00-05:00 - 목(木)의 시작
- 묘시(卯時): 05:00-07:00 - 목(木)의 활력
- 진시(辰時): 07:00-09:00 - 토(土)의 변화
- 사시(巳時): 09:00-11:00 - 화(火)의 상승
- 오시(午時): 11:00-13:00 - 화(火)의 절정
- 미시(未時): 13:00-15:00 - 토(土)의 조화
- 신시(申時): 15:00-17:00 - 금(金)의 시작
- 유시(酉時): 17:00-19:00 - 금(金)의 수확
- 술시(戌時): 19:00-21:00 - 토(土)의 마무리
- 해시(亥時): 21:00-23:00 - 수(水)의 휴식

**경계대상 패턴 적용**:
- 주의 시간대: 특정 시간에 피해야 할 활동과 이유
- 주의 활동: 오늘 피해야 할 행동 (중요 결정, 계약, 여행 등)
- 주의 인물: 오늘 조심해야 할 띠, 연령대, 성격 유형
- 주의 방향: 피해야 할 방위와 이유
- 행운 요소: 색상, 숫자, 방향, 아이템으로 균형 있게 제공

**응답 규칙**:
- 시간대는 반드시 구체적으로 (예: "오후 2시-4시", "신시(15:00-17:00)")
- 각 조언에 전통적 근거 제시 (예: "오행상 화(火)의 기운이...")
- 행운 요소와 주의 요소를 균형 있게 제공
- 모든 시간 표기는 24시간제와 한국어 병기
- severity: "high" (매우 주의), "warning" (주의), "low" (참고)`

    // 캘린더 이벤트 포맷팅
    const formatCalendarEvents = (events: any[]): string => {
      if (!events || events.length === 0) return ''

      const eventList = events.map((e, i) => {
        const title = e.title || '일정'
        const isAllDay = e.is_all_day || e.isAllDay
        const location = e.location ? ` (장소: ${e.location})` : ''
        const time = isAllDay ? '종일' : e.start_time ? new Date(e.start_time).toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' }) : ''
        return `  ${i + 1}. ${title}${time ? ` - ${time}` : ''}${location}`
      }).join('\n')

      return `
**📅 해당 날짜의 일정** (${events.length}개):
${eventList}

⚠️ 중요: 위 일정들을 반드시 운세 분석에 반영해주세요!
- 각 일정에 맞는 구체적인 조언 제공
- 일정 시간대의 운세 특별히 분석
- 일정과 관련된 행운/주의사항 포함`
    }

    // ✅ userPrompt 구성
    const calendarSection = eventsForDate.length > 0 ? formatCalendarEvents(eventsForDate) : ''
    const hasEvents = eventsForDate.length > 0

    const userPrompt = `다음 정보를 기반으로 ${dateDisplayStr}의 시간 운세를 분석해주세요:

**기본 정보**:
- 이름: ${name}
- 생년월일: ${birthDate}${isLunar ? ' (음력)' : ''}
${birthTime ? `- 출생 시간: ${birthTime}` : ''}
${gender ? `- 성별: ${gender === 'male' ? '남성' : '여성'}` : ''}
${zodiacAnimal ? `- 띠: ${zodiacAnimal}` : ''}
${zodiacSign ? `- 별자리: ${zodiacSign}` : ''}
${mbtiType ? `- MBTI: ${mbtiType}` : ''}

**분석 날짜**: ${targetDate.getFullYear()}년 ${targetDate.getMonth() + 1}월 ${targetDate.getDate()}일 ${currentDayName}${isToday ? ' (오늘)' : ''}
**분석 기간**: ${dateDisplayStr} 하루
${calendarSection}

**응답 형식** (반드시 JSON, 절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요):
\`\`\`json
{
  "score": 점수 (0-100),
  "summary": "${dateDisplayStr} 시간 운세 한 줄 요약",
  "content": "상세 분석 내용",
  "advice": "종합 조언",

  "timeSlots": [
    {
      "period": "오전 (06:00-12:00)",
      "traditionalName": "묘시~사시",
      "score": 점수,
      "element": "오행 (목/화/토/금/수)",
      "description": "시간대 설명",
      "activities": ["추천 활동 1", "추천 활동 2"],
      "caution": "주의사항"
    }
  ],

  "cautionTimes": [
    {
      "time": "구체적 시간대",
      "reason": "주의해야 하는 이유 (전통적 근거 포함)",
      "severity": "high/warning/low",
      "avoidActivities": ["피해야 할 활동"]
    }
  ],

  "cautionActivities": [
    {
      "activity": "피해야 할 활동",
      "reason": "이유 (오행/일진 근거)",
      "severity": "high/warning/low",
      "alternativeTime": "대안 시간대"
    }
  ],

  "cautionPeople": [
    {
      "type": "유형 (띠/연령대/성격)",
      "description": "구체적 설명",
      "zodiac": "해당 띠 (있는 경우)",
      "reason": "전통적 근거"
    }
  ],

  "cautionDirections": [
    {
      "direction": "방향 (동/서/남/북/동남/동북/서남/서북)",
      "reason": "피해야 하는 이유",
      "severity": "high/warning/low"
    }
  ],

  "luckyElements": {
    "colors": ["행운의 색상 1", "행운의 색상 2"],
    "numbers": [행운의 숫자1, 행운의 숫자2, 행운의 숫자3],
    "direction": "행운의 방향",
    "zodiacMatch": ["궁합 좋은 띠 1", "궁합 좋은 띠 2"],
    "items": ["행운의 아이템 1", "행운의 아이템 2"],
    "bestTime": "가장 좋은 시간대"
  },

  "timeStrategy": {
    "morning": {
      "caution": "오전 주의사항",
      "advice": "오전 조언",
      "luckyAction": "오전 행운 행동"
    },
    "afternoon": {
      "caution": "오후 주의사항",
      "advice": "오후 조언",
      "luckyAction": "오후 행운 행동"
    },
    "evening": {
      "caution": "저녁 주의사항",
      "advice": "저녁 조언",
      "luckyAction": "저녁 행운 행동"
    }
  },

  "traditionalElements": {
    "element": "주 오행 (목/화/토/금/수)",
    "dailyGan": "오늘의 천간",
    "dailyJi": "오늘의 지지",
    "seasonalAdvice": "계절에 맞는 조언",
    "twelveTimePeriod": "12시진 중 가장 좋은 시간"
  },

  "bestTime": {
    "period": "가장 좋은 시간대",
    "score": 점수,
    "reason": "이유"
  },

  "worstTime": {
    "period": "가장 주의할 시간대",
    "score": 점수,
    "reason": "이유"
  }${hasEvents ? `,

  "calendarAdvice": [
    {
      "eventTitle": "일정 제목",
      "advice": "해당 일정에 대한 구체적 조언 (50자 이상)",
      "luckyTip": "일정을 더 잘 보내기 위한 행운 팁",
      "cautionTip": "주의해야 할 점",
      "bestPreparation": "추천 준비사항"
    }
  ],

  "dayTheme": "이 날의 테마/의미 (일정을 고려한 날의 전체 테마, 예: '새로운 시작의 날', '도약의 기회')",
  "specialMessage": "일정을 고려한 특별 메시지 (100자 이상, 격려와 조언 포함)"` : ''}
}
\`\`\`
${hasEvents ? `
**⚠️ 캘린더 일정이 있으므로 반드시**:
1. "summary"와 "content"에 일정 내용을 언급해주세요
2. "calendarAdvice"에 각 일정별 구체적 조언을 제공해주세요
3. "dayTheme"에 이 날의 특별한 의미를 담아주세요
4. "specialMessage"에 격려와 구체적 조언을 담아주세요
` : ''}
**주의**: 반드시 유효한 JSON 형식으로만 응답하세요. 다른 텍스트는 포함하지 마세요.`

    console.log(`[fortune-time] 🔄 LLM 호출 시작...`)

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`[fortune-time] ✅ LLM 응답 수신 (${response.latency}ms, ${response.usage?.totalTokens || 0} tokens)`)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'time',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { name, birthDate, gender, zodiacAnimal, period, isPremium }
    })

    // JSON 파싱
    let fortuneData: any
    try {
      fortuneData = typeof response.content === 'string'
        ? JSON.parse(response.content)
        : response.content
    } catch (parseError) {
      console.error(`[fortune-time] ❌ JSON 파싱 실패:`, parseError)
      throw new Error('LLM 응답을 파싱할 수 없습니다')
    }

    const overallScore = fortuneData.score || 75

    // 기간별 제목 생성 (선택 날짜 반영)
    const getPeriodTitle = () => {
      // 캘린더에서 특정 날짜를 선택한 경우
      if (eventsForDate.length > 0 || !isToday) {
        return `${dateDisplayStr} 인사이트`
      }

      const titles: { [key: string]: string } = {
        today: '오늘의 인사이트',
        tomorrow: '내일의 인사이트',
        weekly: '이번 주 인사이트',
        monthly: '이번 달 인사이트',
        yearly: '올해 인사이트',
        hourly: '시간대별 인사이트'
      }
      return titles[period] || `${dateDisplayStr} 인사이트`
    }

    // ✅ 운세 데이터 구성 (경계대상 패턴 적용)
    const fortune = {
      // 표준화된 필드명: score, content, summary, advice
      fortuneType: 'daily-calendar',
      score: overallScore,
      content: fortuneData.content || '시간대별 인사이트를 확인하세요.',
      summary: fortuneData.summary || '',
      advice: fortuneData.advice || '',

      // 기존 필드 유지 (하위 호환성)
      id: `${Date.now()}-${period}`,
      userId: userId,
      type: 'daily-calendar',
      period: period,
      overall_score: overallScore,
      message: eventsForDate.length > 0
        ? `${name}님, ${eventsForDate.map(e => e.title).join(', ')} 일정이 있는 특별한 날이에요! ✨`
        : `${name}님의 ${dateDisplayStr} 인사이트입니다.`,
      description: fortuneData.content || '',
      greeting: eventsForDate.length > 0
        ? `${name}님, ${targetDate.getFullYear()}년 ${targetDate.getMonth() + 1}월 ${targetDate.getDate()}일 ${currentDayName}! ${eventsForDate.map(e => e.title).join(', ')} 일정과 함께하는 특별한 날의 인사이트를 확인해보세요. 🎯`
        : `${name}님, ${targetDate.getFullYear()}년 ${targetDate.getMonth() + 1}월 ${targetDate.getDate()}일 ${currentDayName}의 인사이트를 확인해보세요.`,

      // ✅ 경계대상 패턴 - 시간대별 운세 (12시진 기반)
      timeSlots: fortuneData.timeSlots || [],

      // ✅ 경계대상 패턴 - 4개 주의 카테고리
      cautionTimes: fortuneData.cautionTimes || [],
      cautionActivities: fortuneData.cautionActivities || [],
      cautionPeople: fortuneData.cautionPeople || [],
      cautionDirections: fortuneData.cautionDirections || [],

      // ✅ 경계대상 패턴 - 행운 요소 (균형)
      luckyElements: fortuneData.luckyElements || {
        colors: [],
        numbers: [],
        direction: '',
        zodiacMatch: [],
        items: [],
        bestTime: ''
      },

      // ✅ 경계대상 패턴 - 시간대별 전략
      timeStrategy: fortuneData.timeStrategy || {
        morning: { caution: '', advice: '', luckyAction: '' },
        afternoon: { caution: '', advice: '', luckyAction: '' },
        evening: { caution: '', advice: '', luckyAction: '' }
      },

      // ✅ 한국 전통 요소 (12시진, 오행, 일진)
      traditionalElements: fortuneData.traditionalElements || {
        element: '',
        dailyGan: '',
        dailyJi: '',
        seasonalAdvice: '',
        twelveTimePeriod: ''
      },

      // 최고/최악 시간대
      bestTime: fortuneData.bestTime || { period: '', score: 0, reason: '' },
      worstTime: fortuneData.worstTime || { period: '', score: 0, reason: '' },

      // 하위 호환성 - 행운 아이템
      luckyItems: {
        color: fortuneData.luckyElements?.colors?.[0] || '',
        number: fortuneData.luckyElements?.numbers?.[0] || 0,
        direction: fortuneData.luckyElements?.direction || '',
        time: fortuneData.luckyElements?.bestTime || ''
      },
      lucky_items: {
        color: fortuneData.luckyElements?.colors?.[0] || '',
        number: fortuneData.luckyElements?.numbers?.[0] || 0,
        direction: fortuneData.luckyElements?.direction || '',
        time: fortuneData.luckyElements?.bestTime || ''
      },
      luckyColor: fortuneData.luckyElements?.colors?.[0] || '',
      luckyNumber: fortuneData.luckyElements?.numbers?.[0] || 0,
      luckyDirection: fortuneData.luckyElements?.direction || '',

      // 하위 호환성 - timeSpecificFortunes
      timeSpecificFortunes: fortuneData.timeSlots || [],

      // 주의사항 (하위 호환성)
      caution: fortuneData.cautionTimes?.[0]?.reason || '시간대별 에너지를 활용하세요.',
      specialTip: fortuneData.timeStrategy?.morning?.advice || '',
      special_tip: fortuneData.timeStrategy?.morning?.advice || '',

      // 메타데이터
      metadata: {
        period: period,
        targetDate: targetDate.toISOString(),
        location: processedLocation,
        generatedAt: new Date().toISOString(),
        hasCalendarEvents: eventsForDate.length > 0,
        calendarEventsCount: eventsForDate.length
      },

      // ✅ 캘린더 일정 연동 정보
      calendarAdvice: fortuneData.calendarAdvice || [],
      dayTheme: fortuneData.dayTheme || '',
      specialMessage: fortuneData.specialMessage || '',
      calendarEvents: eventsForDate
    }

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabaseClient, 'time', overallScore)
    const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

    console.log(`[fortune-time] ✅ 응답 생성 완료`)

    return new Response(
      JSON.stringify({
        fortune: fortuneWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error generating time-based fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate time-based fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500 
      }
    )
  }
})
