import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

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

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_avoid-people_${today}_${JSON.stringify({environment, moodLevel, stressLevel})}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'avoid-people')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult.result
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('avoid-people')

    const systemPrompt = `당신은 심리학과 대인관계 전문가입니다. 사용자의 현재 상태와 일정을 분석하여 오늘 주의해야 할 사람 유형을 3-5가지 제시하고, 각 유형별로 구체적인 대처 방법을 알려주세요.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (오늘의 대인관계 운세),
  "content": "전체적인 분석 (200자 내외)",
  "avoidTypes": [
    {
      "type": "유형명 (예: 과도한 요구를 하는 사람)",
      "description": "왜 피해야 하는지 설명 (100자 내외)",
      "coping": "대처 방법 (100자 내외)",
      "warningSign": "주의 신호 (50자 내외)"
    }
  ],
  "safeTypes": ["오늘 도움이 될 사람 유형 3가지"],
  "advice": "종합 조언 (150자 내외)"
}`

    const userPrompt = `환경: ${environment}
중요 일정: ${importantSchedule}
기분 상태: ${moodLevel}/5
스트레스 레벨: ${stressLevel}/5
사회적 피로도: ${socialFatigue}/5
중요한 결정: ${hasImportantDecision ? '있음' : '없음'}
민감한 대화: ${hasSensitiveConversation ? '있음' : '없음'}
팀 프로젝트: ${hasTeamProject ? '있음' : '없음'}
날짜: ${new Date().toLocaleDateString('ko-KR')}

위 정보를 바탕으로 오늘 주의해야 할 사람 유형을 JSON 형식으로 분석해주세요.`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['avoidTypes', 'safeTypes', 'advice']
      : []

    const result = {
      overallScore: fortuneData.overallScore, // ✅ 무료: 공개
      content: fortuneData.content, // ✅ 무료: 공개
      avoidTypes: isBlurred ? [{ type: '🔒 프리미엄 전용', description: '🔒 프리미엄 결제 후 확인 가능합니다', coping: '🔒 프리미엄 전용', warningSign: '🔒 프리미엄 전용' }] : fortuneData.avoidTypes, // 🔒 유료
      safeTypes: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.safeTypes, // 🔒 유료
      advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.advice, // 🔒 유료
      timestamp: new Date().toISOString(),
      isBlurred, // ✅ 블러 상태
      blurredSections // ✅ 블러된 섹션 목록
    }

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'avoid-people',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        data: result
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
