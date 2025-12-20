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

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('avoid-people')
    const dayOfWeek = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'][now.getDay()]
    const hour = now.getHours()
    const timeOfDay = hour < 12 ? '오전' : hour < 18 ? '오후' : '저녁'
    const season = [12, 1, 2].includes(now.getMonth() + 1) ? '겨울' :
                   [3, 4, 5].includes(now.getMonth() + 1) ? '봄' :
                   [6, 7, 8].includes(now.getMonth() + 1) ? '여름' : '가을'
    const isWeekend = now.getDay() === 0 || now.getDay() === 6

    const systemPrompt = `당신은 심리학과 대인관계 전문가입니다. 사용자의 현재 상태, 일정, 그리고 오늘의 날짜/시간 정보를 종합하여 오늘 피해야 할 사람 유형을 분석하고 구체적인 전략을 제시하세요.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (오늘의 대인관계 운세),
  "content": "오늘의 대인관계 운세 요약 (100자 이내)",
  "criticalAvoidTypes": [
    {
      "type": "유형명",
      "reason": "왜 오늘 특히 피해야하는지 (100자)",
      "warningSign": "주의 신호 (50자)",
      "coping": "대처법 (100자)",
      "severity": "high|medium|low"
    }
  ],
  "personalityTypes": [
    {
      "type": "과도한 요구를 하는 사람 등",
      "description": "특징 설명 (80자)",
      "example": "구체적 예시 (60자)",
      "boundary": "경계선 설정법 (80자)"
    }
  ],
  "situationTypes": [
    {
      "situation": "중요한 결정이 있을 때 등",
      "avoidType": "피해야할 유형",
      "impact": "영향 (60자)"
    }
  ],
  "safeTypes": [
    {
      "type": "도움될 사람 유형",
      "benefit": "어떤 도움 (60자)",
      "approach": "접근법 (60자)"
    }
  ],
  "dailyStrategy": {
    "morning": "오전 전략 (80자)",
    "afternoon": "오후 전략 (80자)",
    "evening": "저녁 전략 (80자)"
  },
  "emotionalTips": {
    "stress": "스트레스 대처 (80자)",
    "conflict": "갈등 회피법 (80자)",
    "energy": "에너지 보존 (80자)"
  },
  "advice": "종합 조언 (150자 내외)"
}

criticalAvoidTypes는 3개, personalityTypes는 5개, situationTypes는 사용자 상황에 맞게 2-3개, safeTypes는 3개를 제공하세요.`

    const userPrompt = `📅 날짜 정보:
- 날짜: ${now.toLocaleDateString('ko-KR')}
- 요일: ${dayOfWeek} (${isWeekend ? '주말' : '평일'})
- 시간대: ${timeOfDay}
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

💡 컨텍스트 힌트:
${isWeekend ? '- 주말이므로 가족/친구 관계에 더 집중해주세요.' : '- 평일이므로 직장/학교 내 대인관계에 초점을 맞춰주세요.'}
${hour < 9 ? '- 아침 시간이므로 출근길/등교길에서 마주칠 수 있는 사람들에 대한 조언을 포함하세요.' : ''}
${hour >= 18 ? '- 퇴근 시간 이후이므로 개인 시간 보호 및 저녁 모임에 대한 조언을 포함하세요.' : ''}
${stressLevel >= 4 ? '- 스트레스가 높으므로 감정적 갈등이 발생할 수 있는 유형을 중점적으로 다뤄주세요.' : ''}
${moodLevel <= 2 ? '- 기분이 좋지 않으므로 에너지를 소모시키는 사람을 특히 주의하세요.' : ''}
${socialFatigue >= 4 ? '- 사회적 피로도가 높으므로 혼자 있는 시간 확보 전략을 포함하세요.' : ''}
${environment === '대중교통' ? '- 대중교통 이용 시 마주칠 수 있는 불편한 상황과 대처법을 포함하세요.' : ''}
${environment === '카페' ? '- 공공장소에서의 대인관계 경계 및 프라이버시 보호 전략을 포함하세요.' : ''}

⚠️ 주의상황 범주 (반드시 포함):
- 직장/학교: 상사, 동료, 후배, 거래처 담당자, 선배, 동기
- 가정/친척: 부모, 배우자, 자녀, 시댁/처가, 친척
- 사회적 관계: 이웃, 지인, 온라인 친구, 낯선 사람
- 서비스 관계: 고객, 판매원, 배달원, 서비스 제공자

위 정보를 바탕으로 오늘 피해야 할 사람 유형을 JSON 형식으로 분석해주세요. 일반적이고 현실적인 상황을 기반으로 구체적인 조언을 제공하세요.`

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
    console.log(`[AvoidPeople]   📊 대인관계 운세 점수: ${fortuneData.overallScore}점`)
    console.log(`[AvoidPeople]   🚫 Critical 유형: ${fortuneData.criticalAvoidTypes?.length || 0}개`)
    console.log(`[AvoidPeople]   👥 성격 유형: ${fortuneData.personalityTypes?.length || 0}개`)
    console.log(`[AvoidPeople]   📍 상황 유형: ${fortuneData.situationTypes?.length || 0}개`)
    console.log(`[AvoidPeople]   ✅ Safe 유형: ${fortuneData.safeTypes?.length || 0}개`)

    // ✅ Blur 로직 적용 (실제 데이터 저장, UnifiedBlurWrapper가 블러 처리)
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? [
          'criticalAvoidTypes_extended',  // [1,2]만 블러 ([0]은 무료 공개)
          'personalityTypes',
          'situationTypes',
          'safeTypes',
          'dailyStrategy',
          'emotionalTips',
          'advice'
        ]
      : []

    console.log(`[AvoidPeople] 💎 Premium 상태: ${isPremium ? '프리미엄' : '일반'}`)
    console.log(`[AvoidPeople] 🔒 Blur 적용: ${isBlurred ? 'YES' : 'NO'}`)
    console.log(`[AvoidPeople] 🔒 Blurred Sections: ${blurredSections.join(', ')}`)

    const result = {
      overallScore: fortuneData.overallScore || 70,
      content: fortuneData.content || '오늘의 대인관계 운세를 확인하세요.',

      // ✅ 실제 데이터 저장 (프리미엄 메시지 제거)
      criticalAvoidTypes: fortuneData.criticalAvoidTypes || [],
      personalityTypes: fortuneData.personalityTypes || [],
      situationTypes: fortuneData.situationTypes || [],
      safeTypes: fortuneData.safeTypes || [],
      dailyStrategy: fortuneData.dailyStrategy || { morning: '', afternoon: '', evening: '' },
      emotionalTips: fortuneData.emotionalTips || { stress: '', conflict: '', energy: '' },
      advice: fortuneData.advice || '오늘 하루 대인관계에 주의하세요.',

      timestamp: new Date().toISOString(),
      isBlurred,
      blurredSections
    }

    console.log(`[AvoidPeople] ✅ 최종 결과 구조화 완료`)

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
        error: '운세 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        details: errorMessage
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
