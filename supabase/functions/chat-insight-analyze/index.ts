import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

/**
 * chat-insight-analyze: 익명화된 카카오톡 대화 → ChatInsightResult JSON
 * 안전 규칙 포함 (비난 금지, 단정 금지, 위험 상황 전문가 안내)
 */

interface AnalyzeRequest {
  anonymized_messages: Array<{
    sender: 'A' | 'B'
    text: string
    timestamp: string
  }>
  relation_type: 'lover' | 'crush' | 'friend' | 'family' | 'boss' | 'other'
  date_range: 'all' | '7d' | '30d'
  intensity: 'light' | 'standard' | 'deep'
  user_is: 'A' | 'B'
}

const SYSTEM_PROMPT = `당신은 "관계 인사이트 분석가"입니다. 익명화된 카카오톡 대화 데이터를 분석하여 관계 인사이트를 제공합니다.

## 안전 규칙 (절대 위반 금지)
- 특정인을 비난하거나 단정 짓지 마세요
- "이별할 것 같다", "바람피고 있다" 등 단정적 판단 금지
- 항상 "~일 수 있어요", "~패턴이 보여요" 형태로 표현
- 자해/폭력/학대 징후 발견 시: 전문 상담 안내 포함 (정신건강 위기상담 1577-0199)
- 원문을 결과에 포함하지 마세요. masked_quote는 반드시 이름을 A/B로 치환
- 개인정보(전화번호, 주소, 직장명 등)가 결과에 포함되면 안 됩니다

## 분석 수행
1. 대화 빈도 및 시간대 분석
2. 응답 속도 비대칭 측정
3. 감정 표현(이모지, 애칭, 감사/사과) 빈도 추적
4. 대화 주도율 (먼저 연락, 화제 전환)
5. 갈등 패턴 및 해소 방식
6. 시계열 감정 변화 (주 단위)

## 출력 포맷
아래 JSON 스키마를 정확히 따라 출력하세요. JSON만 출력하고 다른 텍스트는 포함하지 마세요.

{
  "scores": {
    "temperature": { "value": 0-100, "label": "string", "trend": "up|down|stable" },
    "stability": { "value": 0-100, "label": "string", "trend": "up|down|stable" },
    "initiative": { "value": 0-100, "label": "string", "trend": "up|down|stable" },
    "risk": { "value": 0-100, "label": "string", "trend": "up|down|stable" }
  },
  "highlights": {
    "summary_bullets": ["string (최대 5개)"],
    "red_flags": [{ "text": "string", "severity": "low|medium|high" }],
    "green_flags": [{ "text": "string", "strength": "low|medium|high" }]
  },
  "timeline": {
    "points": [{ "t": "ISO date", "sentiment": -1.0~1.0 }],
    "dips": [{ "t": "ISO date", "label": "string" }],
    "spikes": [{ "t": "ISO date", "label": "string" }]
  },
  "patterns": {
    "items": [{ "tag": "string", "evidence_count": number, "description": "string" }]
  },
  "triggers": {
    "items": [{ "masked_quote": "string", "why_it_matters": "string", "time": "ISO date (optional)" }]
  },
  "guidance": {
    "do": [{ "text": "string", "expected_effect": "string" }],
    "dont": [{ "text": "string", "expected_effect": "string" }]
  },
  "followup_memory": {
    "safe_notes": "string (LLM 컨텍스트용 요약, 원문 미포함)",
    "user_questions": []
  }
}

## intensity별 깊이
- light: scores + highlights.summary_bullets(3개) + guidance(각 2개)
- standard: 전체 필드, evidence_count 기반 상위 4패턴
- deep: 전체 필드 + triggers 5개 이상 + timeline 일별 세분화`

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
    const requestData: AnalyzeRequest = await req.json()
    const {
      anonymized_messages,
      relation_type,
      date_range,
      intensity,
      user_is,
    } = requestData

    if (!anonymized_messages || anonymized_messages.length === 0) {
      throw new Error('분석할 메시지가 없습니다.')
    }

    const llm = await LLMFactory.createFromConfigAsync('chat-insight')

    const userPrompt = `관계 유형: ${relation_type}
기간: ${date_range}
분석 강도: ${intensity}
요청자: ${user_is}
메시지 수: ${anonymized_messages.length}개

대화 데이터:
${JSON.stringify(anonymized_messages.slice(0, 500))}`

    const response = await llm.generate([
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: userPrompt },
    ], {
      temperature: 0.7,
      maxTokens: 8192,
      jsonMode: true,
    })

    console.log(`✅ chat-insight-analyze 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    await UsageLogger.log({
      fortuneType: 'chat-insight-analyze',
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { relation_type, date_range, intensity, message_count: anonymized_messages.length },
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
    console.error('❌ chat-insight-analyze 에러:', error)
    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : '분석 중 오류가 발생했습니다',
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
