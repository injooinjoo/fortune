import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

/**
 * chat-insight-followup: 분석 결과 기반 후속 상담 답변
 * 비난/단정 금지, 감정 배려, 위험 상황 전문가 안내
 */

interface FollowupRequest {
  analysis_result: {
    followup_memory: {
      safe_notes: string
      user_questions: string[]
    }
    scores: Record<string, unknown>
    guidance: Record<string, unknown>
  }
  user_question: string
  conversation_history: Array<{ role: string; content: string }>
}

const SYSTEM_PROMPT = `당신은 사용자의 관계 고민을 돕는 "대화 상담사"입니다. 이전 분석 결과를 바탕으로 따뜻하고 실용적인 조언을 제공합니다.

## 안전 규칙
- 특정인을 비난하거나 단정 짓지 마세요
- 사용자의 감정을 먼저 공감한 후 조언
- "정답"이 아닌 "선택지"를 제시
- 위험 상황(자해/폭력/스토킹) 감지 시 전문가 안내 우선 (정신건강 위기상담 1577-0199)

## 톤 가이드
- 친구같지만 전문적인 톤 (반말X, 존댓말O)
- "~해보는 건 어떨까요?", "~일 수 있어요" 형태
- 구체적 행동 제안 포함 (추상적 조언 금지)
- 한 번에 3-5문장 이내로 답변 (긴 설교 금지)

## 출력 포맷
plain text (한국어), 3-5문장. 필요시 "💡 팁:" 접두어로 실용적 행동 제안 추가.`

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
    const requestData: FollowupRequest = await req.json()
    const { analysis_result, user_question, conversation_history = [] } = requestData

    if (!user_question || user_question.trim().length === 0) {
      throw new Error('질문을 입력해주세요.')
    }

    const llm = await LLMFactory.createFromConfigAsync('chat-insight')

    const contextPrompt = `## 이전 분석 요약
${analysis_result.followup_memory?.safe_notes || '분석 결과 없음'}

## 주요 점수
${JSON.stringify(analysis_result.scores || {})}

## 행동 가이드
${JSON.stringify(analysis_result.guidance || {})}

## 이전 대화
${conversation_history.slice(-10).map(m => `${m.role}: ${m.content}`).join('\n')}

## 사용자 질문
${user_question}`

    const response = await llm.generate([
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: contextPrompt },
    ], {
      temperature: 0.8,
      maxTokens: 1024,
    })

    console.log(`✅ chat-insight-followup 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    await UsageLogger.log({
      fortuneType: 'chat-insight-followup',
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { question_length: user_question.length },
    })

    return new Response(JSON.stringify({
      success: true,
      data: {
        answer: response.content,
        timestamp: new Date().toISOString(),
      },
    }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  } catch (error) {
    console.error('❌ chat-insight-followup 에러:', error)
    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : '상담 중 오류가 발생했습니다',
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
