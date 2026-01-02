/**
 * 피해야 할 사람 운세 (Avoid People Fortune) Edge Function
 *
 * @description 사주 기반으로 오늘 피해야 할 띠/유형의 사람을 분석합니다.
 *
 * @endpoint POST /fortune-avoid-people
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간
 * - gender: string - 성별
 *
 * @response AvoidPeopleResponse
 * - avoid_zodiac: string[] - 피해야 할 띠
 * - avoid_types: string[] - 피해야 할 유형
 * - reason: string - 이유
 * - good_zodiac: string[] - 좋은 띠
 * - advice: string - 조언
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

interface AvoidPeopleRequest {
  environment: string;
  importantSchedule: string;
  moodLevel: number;
  stressLevel: number;
  socialFatigue: number;
  hasImportantDecision: boolean;
  hasSensitiveConversation: boolean;
  hasTeamProject: boolean;
  userId?: string;
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
}

// ✅ 성씨-오행 매핑 (일간이 극을 받는 오행의 성씨)
const SURNAME_ELEMENT_MAP: Record<string, string[]> = {
  // 木 일간 (갑, 을) → 金이 극함 → 金 성씨 조심
  '갑': ['김', '신', '백', '유', '장'],
  '을': ['김', '신', '백', '유', '장'],
  // 火 일간 (병, 정) → 水가 극함 → 水 성씨 조심
  '병': ['한', '허', '홍', '함', '현'],
  '정': ['한', '허', '홍', '함', '현'],
  // 土 일간 (무, 기) → 木이 극함 → 木 성씨 조심
  '무': ['이', '임', '엄', '안', '양'],
  '기': ['이', '임', '엄', '안', '양'],
  // 金 일간 (경, 신) → 火가 극함 → 火 성씨 조심
  '경': ['남', '노', '나', '류', '도'],
  '신': ['남', '노', '나', '류', '도'],
  // 水 일간 (임, 계) → 土가 극함 → 土 성씨 조심
  '임': ['황', '오', '우', '원', '위'],
  '계': ['황', '오', '우', '원', '위'],
};

// 일간-오행 매핑
const DAY_STEM_ELEMENT: Record<string, string> = {
  '갑': '木', '을': '木',
  '병': '火', '정': '火',
  '무': '土', '기': '土',
  '경': '金', '신': '金',
  '임': '水', '계': '水',
};

// 극 관계 설명
const CLASH_EXPLANATION: Record<string, string> = {
  '갑': '甲木 일간에 庚金이 충돌하는 기운',
  '을': '乙木 일간에 辛金이 충돌하는 기운',
  '병': '丙火 일간에 壬水가 충돌하는 기운',
  '정': '丁火 일간에 癸水가 충돌하는 기운',
  '무': '戊土 일간에 甲木이 충돌하는 기운',
  '기': '己土 일간에 乙木이 충돌하는 기운',
  '경': '庚金 일간에 丙火가 충돌하는 기운',
  '신': '辛金 일간에 丁火가 충돌하는 기운',
  '임': '壬水 일간에 戊土가 충돌하는 기운',
  '계': '癸水 일간에 己土가 충돌하는 기운',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData: AvoidPeopleRequest = await req.json()
    const { environment, importantSchedule, moodLevel, stressLevel, socialFatigue,
            hasImportantDecision, hasSensitiveConversation, hasTeamProject, userId, isPremium = false } = requestData

    console.log('💎 [AvoidPeople] Premium 상태:', isPremium)

    // 날짜 컨텍스트 분석
    const now = new Date()
    const today = now.toISOString().split('T')[0]

    // 캐시 확인
    const cacheKey = `${userId || 'anonymous'}_avoid-people_${today}_${JSON.stringify({environment, moodLevel, stressLevel})}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'avoid-people')
      .single()

    if (cachedResult) {
      console.log('[AvoidPeople] ✅ 캐시된 결과 반환')
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult.result
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ✅ 사용자 사주 정보 조회 (성씨 분석용)
    let dayStem = ''
    let cautionSurnames: string[] = []
    let surnameReason = ''

    if (userId) {
      const { data: sajuData } = await supabaseClient
        .from('user_saju')
        .select('day_stem')
        .eq('user_id', userId)
        .single()

      if (sajuData?.day_stem) {
        dayStem = sajuData.day_stem
        cautionSurnames = SURNAME_ELEMENT_MAP[dayStem] || []
        surnameReason = CLASH_EXPLANATION[dayStem] || ''
        console.log(`[AvoidPeople] 🔮 일간: ${dayStem}, 경계 성씨: ${cautionSurnames.join(', ')}`)
      }
    }

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('avoid-people')
    const dayOfWeek = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'][now.getDay()]
    const hour = now.getHours()
    const timeOfDay = hour < 12 ? '오전' : hour < 18 ? '오후' : '저녁'
    const season = [12, 1, 2].includes(now.getMonth() + 1) ? '겨울' :
                   [3, 4, 5].includes(now.getMonth() + 1) ? '봄' :
                   [6, 7, 8].includes(now.getMonth() + 1) ? '여름' : '가을'
    const isWeekend = now.getDay() === 0 || now.getDay() === 6

    const systemPrompt = `당신은 한국 전통 지혜와 현대 심리학을 결합한 경계대상 분석 전문가입니다.
사용자의 현재 상태, 일정, 오늘의 날짜/시간/계절을 종합하여 오늘 조심해야 할 모든 것들을 8가지 카테고리로 상세 분석하세요.

⚠️ 핵심: 단순히 "사람"만이 아니라, 사물, 색상, 숫자, 동물, 장소, 시간대, 방향까지 모두 분석!

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 경계 지수 (높을수록 주의 필요),
  "summary": "오늘의 경계대상 핵심 요약 (80자 이내)",

  "cautionPeople": [
    {
      "type": "구체적인 행동 패턴 (예: 의견을 3번 이상 반복하며 고집하는 사람)",
      "reason": "사주 근거 + 왜 오늘 특히 피해야 하는지 (60자)",
      "sign": "구체적 신호 (예: 목소리 톤이 갑자기 높아지면, 2초 이상 노려보면)",
      "tip": "구체적 대처법 (예: '네, 검토해보겠습니다' 한 마디 후 2분 내 자리 이동)",
      "severity": "high|medium|low",
      "cautionSurnames": ["성씨1", "성씨2"],
      "surnameReason": "사주 기반 성씨 경계 이유 (예: 甲木 일간에 庚金 충돌)"
    }
  ],

  "cautionObjects": [
    {
      "item": "조심해야 할 사물 (예: 날카로운 도구, 유리잔, 전자기기)",
      "reason": "왜 조심해야 하는지 (50자)",
      "situation": "특히 이런 상황에서 (40자)",
      "tip": "예방법 (50자)"
    }
  ],

  "cautionColors": [
    {
      "color": "불길한 색상 (예: 빨간색)",
      "avoid": "피해야 할 곳 (예: 옷, 액세서리, 인테리어)",
      "reason": "왜 피해야 하는지 (40자)",
      "alternative": "대신 추천하는 색상"
    }
  ],

  "cautionNumbers": [
    {
      "number": "피해야 할 숫자 (예: 4, 13)",
      "avoid": "피해야 할 상황 (예: 4층, 4번 자리, 4시)",
      "reason": "왜 피해야 하는지 (40자)",
      "luckyNumber": "대신 좋은 숫자"
    }
  ],

  "cautionAnimals": [
    {
      "animal": "조심해야 할 동물 또는 띠 (예: 개, 뱀띠 사람)",
      "context": "어떤 상황에서 (40자)",
      "reason": "왜 조심해야 하는지 (40자)",
      "tip": "대처법 (40자)"
    }
  ],

  "cautionPlaces": [
    {
      "place": "피해야 할 장소 (예: 지하 주차장, 물가, 높은 곳)",
      "timeSlot": "특히 이 시간에 (예: 저녁, 야간)",
      "reason": "왜 피해야 하는지 (50자)",
      "alternative": "대신 추천 장소"
    }
  ],

  "cautionTimes": [
    {
      "time": "조심해야 할 시간대 (예: 10:00-11:00)",
      "activity": "이 시간에 피해야 할 활동 (예: 중요한 결정, 계약)",
      "reason": "왜 조심해야 하는지 (40자)",
      "betterTime": "대신 좋은 시간"
    }
  ],

  "cautionDirections": [
    {
      "direction": "피해야 할 방향/방위 (예: 서쪽, 북동쪽)",
      "avoid": "피해야 할 행동 (예: 서쪽으로 출근, 북동쪽 여행)",
      "reason": "왜 피해야 하는지 (40자)",
      "goodDirection": "오늘 좋은 방향"
    }
  ],

  "luckyElements": {
    "color": "오늘 행운의 색상",
    "number": "오늘 행운의 숫자",
    "direction": "오늘 좋은 방향",
    "time": "오늘 최고의 시간대",
    "item": "오늘 행운의 아이템",
    "person": "오늘 만나면 좋은 사람 유형"
  },

  "timeStrategy": {
    "morning": {
      "caution": "오전 주의사항 (60자)",
      "advice": "오전 조언 (60자)"
    },
    "afternoon": {
      "caution": "오후 주의사항 (60자)",
      "advice": "오후 조언 (60자)"
    },
    "evening": {
      "caution": "저녁 주의사항 (60자)",
      "advice": "저녁 조언 (60자)"
    }
  },

  "dailyAdvice": "오늘 하루를 위한 종합 조언 (100자 내외)"
}

📌 각 카테고리별 항목 수:
- cautionPeople: 3-4개 (심각도 다양하게)
- cautionObjects: 3-4개 (일상에서 마주치는 물건)
- cautionColors: 2-3개 (구체적인 상황과 함께)
- cautionNumbers: 2-3개 (차량번호, 층수, 시간 등 다양하게)
- cautionAnimals: 2-3개 (실제 동물 + 띠 조합)
- cautionPlaces: 3-4개 (구체적인 장소)
- cautionTimes: 2-3개 (구체적인 시간대)
- cautionDirections: 2-3개 (방위 + 이동 방향)

📌 중요 규칙:
1. 각 항목은 사용자의 오늘 상황(장소, 일정, 기분)과 연결되어야 함
2. severity는 상황의 심각도를 반영 (high: 반드시 피해야 함, medium: 주의, low: 참고)
3. 한국 전통 운세 요소(띠, 방위, 숫자)와 현대적 요소(사물, 장소)를 조화롭게
4. luckyElements는 반드시 포함하여 균형 잡힌 결과 제공
5. 모든 내용은 구체적이고 실용적이어야 함 (추상적 표현 금지)

🚫 절대 금지 표현 (이런 표현 사용 시 무효):
- "조심하세요", "주의하세요", "피하세요" 단독 사용 금지
- "~한 사람", "~한 유형" 같은 추상적 표현 금지
- "좋지 않습니다", "불리합니다" 같은 막연한 평가 금지
- "오늘은 조용히 지내세요" 같은 당연한 조언 금지

✅ 필수 개인화 요소 (모든 항목에 적용):
- 구체적 신호: "목소리 톤이 갑자기 높아지면", "같은 말 3번 반복하면"
- 구체적 시간: "오전 10시~11시 회의 중", "점심 직후 30분간"
- 구체적 대처법: "'네, 검토해보겠습니다' 한 마디 후 2분 내 자리 이동"
- 사주 근거: cautionPeople의 경우 반드시 cautionSurnames와 surnameReason 포함`

    const userPrompt = `📅 날짜 정보:
- 날짜: ${now.toLocaleDateString('ko-KR')}
- 요일: ${dayOfWeek} (${isWeekend ? '주말' : '평일'})
- 시간대: ${timeOfDay} (${hour}시)
- 계절: ${season}

👤 사용자 상태:
- 주요 장소: ${environment}
- 중요 일정: ${importantSchedule}
- 기분: ${moodLevel}/5
- 스트레스: ${stressLevel}/5
- 사회적 피로도: ${socialFatigue}/5
- 중요한 결정: ${hasImportantDecision ? '있음' : '없음'}
- 민감한 대화: ${hasSensitiveConversation ? '있음' : '없음'}
- 팀 프로젝트: ${hasTeamProject ? '있음' : '없음'}

🔮 사주 정보 (성씨 분석용):
- 일간(日干): ${dayStem || '정보 없음'}
- 일간 오행: ${dayStem ? DAY_STEM_ELEMENT[dayStem] : '정보 없음'}
- 경계 성씨: ${cautionSurnames.length > 0 ? cautionSurnames.join(', ') + '씨' : '정보 없음'}
- 성씨 경계 이유: ${surnameReason || '정보 없음'}

⚠️ 성씨 필수 지침:
${cautionSurnames.length > 0 ? `- cautionPeople의 각 항목에 cautionSurnames: ${JSON.stringify(cautionSurnames.slice(0, 2))} 포함 필수
- surnameReason: "${surnameReason}" 포함 필수` : '- 사주 정보 없음: 성씨 필드는 빈 배열로 처리'}

💡 컨텍스트 힌트 (각 카테고리에 반영해주세요):
${isWeekend ? '- 주말: 가족/친구 관계, 외출/쇼핑 관련 경계대상 포함' : '- 평일: 직장/학교 관련 경계대상 포함'}
${hour < 9 ? '- 아침: 출근길/등교길 관련 경계대상 포함' : ''}
${hour >= 18 ? '- 저녁: 퇴근길/야간 활동 관련 경계대상 포함' : ''}
${stressLevel >= 4 ? '- 스트레스 높음: 감정적 갈등 유발 요소 강조' : ''}
${moodLevel <= 2 ? '- 기분 저조: 에너지 소모 요소 강조' : ''}
${socialFatigue >= 4 ? '- 사회적 피로: 혼자 있는 시간 확보 전략 포함' : ''}

🎯 장소별 맞춤 힌트:
${environment === '직장' ? '- 직장: 상사/동료/거래처 관련 경계인물, 사무용품 관련 경계사물' : ''}
${environment === '학교' ? '- 학교: 선배/후배/교수 관련 경계인물, 시험/과제 관련 시간대' : ''}
${environment === '대중교통' ? '- 대중교통: 붐비는 시간대, 분실물 관련 사물, 특정 노선 방향' : ''}
${environment === '카페' ? '- 카페: 공공장소 프라이버시, 디지털 기기 관련 주의' : ''}
${environment === '집' ? '- 집: 가족 관계, 가전제품/가구 관련 사물' : ''}
${environment === '모임' ? '- 모임: 술자리 주의, 충동적 약속 경계' : ''}

📌 8가지 경계대상 카테고리를 모두 채워서 JSON으로 응답해주세요:
1. cautionPeople (사람): ${environment} 환경에서 만날 수 있는 구체적 유형
2. cautionObjects (사물): 오늘 조심해야 할 물건 (전자기기, 날카로운 것, 깨지기 쉬운 것 등)
3. cautionColors (색상): 오늘 피해야 할 색상과 착용/사용 상황
4. cautionNumbers (숫자): 차량번호, 층수, 좌석번호, 시간 등에서 피해야 할 숫자
5. cautionAnimals (동물/띠): 실제 동물 + 띠가 맞지 않는 사람
6. cautionPlaces (장소): ${environment} 근처에서 피해야 할 구체적 장소
7. cautionTimes (시간): 중요한 활동을 피해야 할 시간대
8. cautionDirections (방향): 이동 시 피해야 할 방위

+ luckyElements (행운 요소): 오늘 도움이 되는 색상, 숫자, 방향, 시간, 아이템
+ timeStrategy (시간대별 전략): 오전/오후/저녁별 주의사항과 조언`

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
      fortuneType: 'avoid-people',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { environment, moodLevel, stressLevel, socialFatigue, isPremium }
    })

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    console.log(`[AvoidPeople] ✅ 응답 데이터 파싱 완료`)
    console.log(`[AvoidPeople]   📊 경계 지수: ${fortuneData.overallScore}점`)
    console.log(`[AvoidPeople]   👤 경계인물: ${fortuneData.cautionPeople?.length || 0}개`)
    console.log(`[AvoidPeople]   📦 경계사물: ${fortuneData.cautionObjects?.length || 0}개`)
    console.log(`[AvoidPeople]   🎨 경계색상: ${fortuneData.cautionColors?.length || 0}개`)
    console.log(`[AvoidPeople]   🔢 경계숫자: ${fortuneData.cautionNumbers?.length || 0}개`)
    console.log(`[AvoidPeople]   🐾 경계동물: ${fortuneData.cautionAnimals?.length || 0}개`)
    console.log(`[AvoidPeople]   📍 경계장소: ${fortuneData.cautionPlaces?.length || 0}개`)
    console.log(`[AvoidPeople]   ⏰ 경계시간: ${fortuneData.cautionTimes?.length || 0}개`)
    console.log(`[AvoidPeople]   🧭 경계방향: ${fortuneData.cautionDirections?.length || 0}개`)

    // ✅ Blur 로직 적용 (실제 데이터 저장, UnifiedBlurWrapper가 블러 처리)
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? [
          'cautionPeople',
          'cautionObjects',
          'cautionColors',
          'cautionNumbers',
          'cautionAnimals',
          'cautionPlaces',
          'cautionTimes',
          'cautionDirections',
          'luckyElements',
          'timeStrategy',
          'dailyAdvice'
        ]
      : []

    console.log(`[AvoidPeople] 💎 Premium 상태: ${isPremium ? '프리미엄' : '일반'}`)
    console.log(`[AvoidPeople] 🔒 Blur 적용: ${isBlurred ? 'YES' : 'NO'}`)
    console.log(`[AvoidPeople] 🔒 Blurred Sections: ${blurredSections.join(', ')}`)

    const result = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'avoid-people',
      score: fortuneData.overallScore || 70,
      content: fortuneData.summary || '오늘의 경계대상을 확인하세요.',
      summary: `오늘의 경계 지수는 ${fortuneData.overallScore || 70}점입니다.`,
      advice: fortuneData.dailyAdvice || '오늘 하루 경계대상에 주의하세요.',

      // 기존 필드 유지 (하위 호환성)
      overallScore: fortuneData.overallScore || 70,
      avoid_summary: fortuneData.summary || '오늘의 경계대상을 확인하세요.',

      // ✅ 8가지 경계대상 카테고리
      cautionPeople: fortuneData.cautionPeople || [],
      cautionObjects: fortuneData.cautionObjects || [],
      cautionColors: fortuneData.cautionColors || [],
      cautionNumbers: fortuneData.cautionNumbers || [],
      cautionAnimals: fortuneData.cautionAnimals || [],
      cautionPlaces: fortuneData.cautionPlaces || [],
      cautionTimes: fortuneData.cautionTimes || [],
      cautionDirections: fortuneData.cautionDirections || [],

      // ✅ 행운 요소 & 시간대별 전략
      luckyElements: fortuneData.luckyElements || {
        color: '파란색',
        number: '8',
        direction: '동쪽',
        time: '14:00-16:00',
        item: '동전',
        person: '차분한 성격의 사람'
      },
      timeStrategy: fortuneData.timeStrategy || {
        morning: { caution: '', advice: '' },
        afternoon: { caution: '', advice: '' },
        evening: { caution: '', advice: '' }
      },
      dailyAdvice: fortuneData.dailyAdvice || '오늘 하루 경계대상에 주의하세요.',

      timestamp: new Date().toISOString(),
      isBlurred,
      blurredSections
    }

    console.log(`[AvoidPeople] ✅ 최종 결과 구조화 완료 (8개 카테고리 + 행운요소)`)

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabaseClient, 'avoid-people', result.overallScore)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'avoid-people',
        user_id: userId || null,
        result: resultWithPercentile,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        data: resultWithPercentile
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('Avoid People Fortune API Error:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '분석 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        details: errorMessage
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
