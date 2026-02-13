import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

/**
 * chat-insight-suggest: 상대에게 보낼 추천 문장 3개 생성
 * 조종/가스라이팅 금지, 진심 기반, 상대 배려
 */

interface SuggestRequest {
  situation: string
  tone: 'casual' | 'warm' | 'careful' | 'playful'
  relation_type: 'lover' | 'crush' | 'friend' | 'family' | 'boss' | 'other'
  analysis_context: {
    do_items: Array<{ text: string; expected_effect: string }>
    dont_items: Array<{ text: string; expected_effect: string }>
  }
}

const SYSTEM_PROMPT = `사용자가 상대에게 보낼 메시지를 추천합니다. 분석 결과의 guidance를 바탕으로 자연스러운 한국어 문장을 생성합니다.

## 안전 규칙
- 조종/가스라이팅 의도의 문장 생성 금지
- 거짓말이나 과장 포함 금지
- 사용자의 진심을 담되, 상대의 감정도 배려

## 출력 포맷
JSON만 출력하세요:
{
  "suggestions": [
    { "text": "추천 문장 1", "tone_note": "이 문장의 뉘앙스 설명" },
    { "text": "추천 문장 2", "tone_note": "이 문장의 뉘앙스 설명" },
    { "text": "추천 문장 3", "tone_note": "이 문장의 뉘앙스 설명" }
  ],
  "avoid_example": "이런 표현은 피해주세요: ..."
}`

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
    const requestData: SuggestRequest = await req.json()
    const { situation, tone = 'warm', relation_type, analysis_context } = requestData

    if (!situation || situation.trim().length === 0) {
      throw new Error('상황을 입력해주세요.')
    }

    const llm = await LLMFactory.createFromConfigAsync('chat-insight')

    const userPrompt = `상황: ${situation}
톤: ${tone}
관계: ${relation_type}

추천 행동:
${(analysis_context?.do_items || []).map(d => `- ${d.text}`).join('\n')}

주의 행동:
${(analysis_context?.dont_items || []).map(d => `- ${d.text}`).join('\n')}`

    const response = await llm.generate([
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: userPrompt },
    ], {
      temperature: 0.9,
      maxTokens: 1024,
      jsonMode: true,
    })

    console.log(`✅ chat-insight-suggest 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    await UsageLogger.log({
      fortuneType: 'chat-insight-suggest',
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { tone, relation_type },
    })

    let parsedResponse: Record<string, unknown>
    try {
      parsedResponse = JSON.parse(response.content)
    } catch {
      throw new Error('AI 응답 형식이 올바르지 않습니다.')
    }

    return new Response(JSON.stringify({
      success: true,
      data: parsedResponse,
    }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  } catch (error) {
    console.error('❌ chat-insight-suggest 에러:', error)
    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : '추천 문장 생성 중 오류가 발생했습니다',
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
