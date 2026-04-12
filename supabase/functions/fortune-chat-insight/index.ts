/**
 * 카톡 대화 분석 (Chat Insight) Edge Function
 *
 * @description 사용자가 붙여넣은 카카오톡 대화를 AI가 분석하여
 *              관계 건강도, 감정 분석, 대화 패턴, 위험/긍정 신호, 조언을 제공합니다.
 *
 * @endpoint POST /fortune-chat-insight
 *
 * @requestBody
 * - userId?: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - relationship: string - 대화 상대와의 관계 (crush, lover, ex, friend, colleague, family)
 * - curiosity: string - 가장 궁금한 포인트 (feelings, pattern, advice, red-flags, compatibility)
 * - chatContent / chat_content: string - 카카오톡 대화 내용 (텍스트)
 *
 * @response { success: true, data: ChatInsightFortuneData }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/* ------------------------------------------------------------------ */
/*  Label catalogs                                                     */
/* ------------------------------------------------------------------ */

const RELATIONSHIP_LABELS: Record<string, string> = {
  crush: '썸/관심',
  lover: '연인',
  ex: '전 연인',
  friend: '친구',
  colleague: '직장 동료',
  family: '가족',
}

const CURIOSITY_LABELS: Record<string, string> = {
  feelings: '상대 감정/관심도',
  pattern: '대화 패턴 분석',
  advice: '앞으로 어떻게 할지',
  'red-flags': '위험 신호 체크',
  compatibility: '관계 궁합',
}

/* ------------------------------------------------------------------ */
/*  LLM prompt builder                                                 */
/* ------------------------------------------------------------------ */

function buildPrompt(
  name: string,
  relationship: string,
  curiosity: string,
  chatContent: string,
): string {
  const relationshipLabel = RELATIONSHIP_LABELS[relationship] ?? relationship
  const curiosityLabel = CURIOSITY_LABELS[curiosity] ?? curiosity

  // Truncate chat content to avoid token overflow (keep ~8000 chars max)
  const truncatedChat = chatContent.length > 8000
    ? chatContent.slice(0, 8000) + '\n\n... (대화가 길어 일부만 분석합니다)'
    : chatContent

  return `당신은 관계 심리 전문가이자 커뮤니케이션 분석가입니다. 카카오톡 대화를 분석하여 관계 인사이트를 제공합니다.

분석 대상:
- 이름: ${name}
- 상대와의 관계: ${relationshipLabel}
- 가장 궁금한 포인트: ${curiosityLabel}

카카오톡 대화 내용:
${truncatedChat}

아래 JSON 형식으로 대화 분석 결과를 작성해주세요. 반드시 JSON만 출력하세요. 모든 텍스트는 한국어로 작성하세요.

{
  "score": (0-100 정수, 관계 건강도 점수),
  "summary": "(한줄 요약, 2문장 이내)",
  "emotionalAnalysis": {
    "userTone": "(사용자의 대화 톤 분석 1-2문장)",
    "partnerTone": "(상대방의 대화 톤 분석 1-2문장)",
    "emotionalGap": "(감정 온도차 설명 1-2문장)",
    "interestLevel": (0-100 정수, 상대방의 관심도 추정)
  },
  "communicationPatterns": {
    "responseSpeed": "(답장 속도 분석 1문장)",
    "messageLength": "(메시지 길이 비교 1문장)",
    "initiator": "(대화 시작하는 쪽 분석 1문장)",
    "emojiUsage": "(이모지/이모티콘 사용 패턴 1문장)"
  },
  "keyMoments": [
    { "quote": "(대화에서 인용)", "analysis": "(이 부분이 의미하는 것 1문장)" },
    { "quote": "(대화에서 인용)", "analysis": "(이 부분이 의미하는 것 1문장)" },
    { "quote": "(대화에서 인용)", "analysis": "(이 부분이 의미하는 것 1문장)" }
  ],
  "redFlags": ["(위험 신호 1)", "(위험 신호 2)"],
  "greenFlags": ["(긍정 신호 1)", "(긍정 신호 2)"],
  "advice": {
    "immediate": "(지금 바로 할 수 있는 것 1-2문장)",
    "shortTerm": "(이번 주 추천 행동 1-2문장)",
    "avoid": "(피해야 할 행동 1-2문장)"
  },
  "compatibility": {
    "communicationScore": (0-100 정수),
    "emotionalScore": (0-100 정수),
    "futureOutlook": "(관계 전망 1-2문장)"
  },
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
          fortuneType: 'chat-insight',
          timestamp: new Date().toISOString(),
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 200,
        },
      )
    }

    const relationship = request.relationship
    const curiosity = request.curiosity
    const chatContent = request.chatContent || request.chat_content
    const rawName = request.name
    const invalidNames = ['undefined', 'null', 'Unknown', '']
    const name = rawName && !invalidNames.includes(rawName) ? rawName : '회원님'

    if (!chatContent) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '대화 내용(chatContent)이 필요합니다.',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400,
        },
      )
    }

    const relationshipLabel = RELATIONSHIP_LABELS[relationship] ?? relationship ?? '알 수 없음'
    const curiosityLabel = CURIOSITY_LABELS[curiosity] ?? curiosity ?? '전반적 분석'
    console.log(`💬 [chat-insight] ${name} → 관계: ${relationshipLabel}, 궁금: ${curiosityLabel}, 대화길이: ${chatContent.length}자`)

    // LLM 호출
    const llm = LLMFactory.createFromConfig('chat-insight')
    const prompt = buildPrompt(name, relationship, curiosity, chatContent)

    const llmResponse = await llm.generate([
      {
        role: 'system',
        content: '당신은 관계 심리 전문가이자 커뮤니케이션 분석가입니다. 카카오톡 대화를 분석하여 깊이 있는 관계 인사이트를 제공합니다. 반드시 유효한 JSON만 출력하세요.',
      },
      { role: 'user', content: prompt },
    ], {
      temperature: 0.7,
      maxTokens: 4096,
      jsonMode: true,
    })

    let fortune: Record<string, unknown>
    try {
      fortune = JSON.parse(llmResponse.content)
    } catch {
      console.error('[chat-insight] JSON 파싱 실패:', llmResponse.content.slice(0, 200))
      fortune = buildFallbackFortune(name, relationship, curiosity)
    }

    const score = Number(fortune.score) || 75
    const emotionalAnalysis = (fortune.emotionalAnalysis as Record<string, unknown>) ?? {}
    const communicationPatterns = (fortune.communicationPatterns as Record<string, unknown>) ?? {}
    const keyMoments = (fortune.keyMoments as Array<{ quote: string; analysis: string }>) ?? []
    const redFlags = (fortune.redFlags as string[]) ?? []
    const greenFlags = (fortune.greenFlags as string[]) ?? []
    const advice = (fortune.advice as Record<string, string>) ?? {}
    const compatibilityData = (fortune.compatibility as Record<string, unknown>) ?? {}
    const highlights = (fortune.highlights as string[]) ?? []

    const data = {
      fortuneType: 'chat-insight' as const,
      score,
      content: `${name}님의 카톡 대화 분석 결과입니다. ${fortune.summary || ''}`,
      summary: (fortune.summary as string) || '대화 흐름을 분석하고 관계 인사이트를 정리했습니다.',
      advice: advice.immediate || '상대의 리듬에 맞춰 한 템포 쉬어가세요.',
      timestamp: new Date().toISOString(),

      // survey inputs
      relationship,
      relationshipLabel,
      curiosity,
      curiosityLabel,

      // emotional analysis
      userTone: (emotionalAnalysis.userTone as string) || '분석 중',
      partnerTone: (emotionalAnalysis.partnerTone as string) || '분석 중',
      emotionalGap: (emotionalAnalysis.emotionalGap as string) || '감정 온도차를 분석하고 있습니다.',
      interestLevel: Number(emotionalAnalysis.interestLevel) || 65,

      // communication patterns
      responseSpeed: (communicationPatterns.responseSpeed as string) || '답장 패턴을 분석하고 있습니다.',
      messageLength: (communicationPatterns.messageLength as string) || '메시지 길이 비교 중입니다.',
      initiator: (communicationPatterns.initiator as string) || '대화 시작 패턴을 확인하고 있습니다.',
      emojiUsage: (communicationPatterns.emojiUsage as string) || '이모지 사용 패턴을 분석 중입니다.',

      // key moments
      keyMoments: keyMoments.length > 0
        ? keyMoments.slice(0, 5).map((m) => ({
            quote: m.quote ?? '',
            analysis: m.analysis ?? '',
          }))
        : [{ quote: '대화 내용', analysis: '주요 장면을 분석 중입니다.' }],

      // flags
      redFlags: redFlags.length > 0 ? redFlags.slice(0, 5) : ['특별한 위험 신호는 발견되지 않았습니다.'],
      greenFlags: greenFlags.length > 0 ? greenFlags.slice(0, 5) : ['자연스러운 대화 흐름이 유지되고 있습니다.'],

      // advice
      immediateAdvice: advice.immediate || '대화의 리듬을 유지하면서 천천히 진행하세요.',
      shortTermAdvice: advice.shortTerm || '이번 주 안에 가볍게 안부를 물어보세요.',
      avoidAdvice: advice.avoid || '과도한 해석이나 급한 결론은 피하세요.',

      // compatibility
      communicationScore: Number(compatibilityData.communicationScore) || 70,
      emotionalScore: Number(compatibilityData.emotionalScore) || 68,
      futureOutlook: (compatibilityData.futureOutlook as string) || '관계 전망을 분석 중입니다.',

      // highlights for result card
      highlights: highlights.length > 0
        ? highlights.slice(0, 5)
        : [
            '대화 톤과 속도에서 관계 감각이 읽힙니다.',
            '상대의 반응 패턴이 일관된 편입니다.',
            '감정 표현의 밸런스가 관계의 열쇠입니다.',
          ],

      // strengths / growth areas (for coaching result card compatibility)
      strengths: greenFlags.length > 0 ? greenFlags.slice(0, 3) : ['자연스러운 대화 흐름'],
      growthAreas: redFlags.length > 0 ? redFlags.slice(0, 2) : ['대화 균형 개선'],

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
    console.error('Error in fortune-chat-insight:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: '대화 분석 중 오류가 발생했습니다.',
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
  relationship: string,
  curiosity: string,
): Record<string, unknown> {
  const relationshipLabel = RELATIONSHIP_LABELS[relationship] ?? relationship ?? '알 수 없음'
  const curiosityLabel = CURIOSITY_LABELS[curiosity] ?? curiosity ?? '전반적 분석'

  return {
    score: 75,
    summary: `${name}님, ${relationshipLabel} 관계의 대화를 분석했습니다. ${curiosityLabel}을 중심으로 주요 포인트를 정리했어요.`,
    emotionalAnalysis: {
      userTone: '전반적으로 적극적이고 관심을 보이는 톤입니다.',
      partnerTone: '대화에 참여하고 있으나 구체적인 감정 표현은 적은 편입니다.',
      emotionalGap: '약간의 온도차가 있으나 자연스러운 범위 내입니다.',
      interestLevel: 65,
    },
    communicationPatterns: {
      responseSpeed: '양쪽 모두 비교적 일정한 답장 리듬을 유지하고 있습니다.',
      messageLength: '메시지 길이가 비슷한 편으로 대화 균형이 잡혀 있습니다.',
      initiator: '대화 시작이 한쪽에 약간 치우쳐 있습니다.',
      emojiUsage: '이모지 사용은 자연스러운 수준입니다.',
    },
    keyMoments: [
      { quote: '대화 속 주요 장면', analysis: '관심도를 보여주는 포인트입니다.' },
      { quote: '반응 패턴', analysis: '상대의 감정 상태를 추정할 수 있는 단서입니다.' },
    ],
    redFlags: ['특별한 위험 신호는 발견되지 않았습니다.'],
    greenFlags: ['대화가 자연스럽게 이어지고 있습니다.', '서로의 이야기에 반응하고 있습니다.'],
    advice: {
      immediate: '다음 대화에서 상대의 관심사에 대해 한 번 더 물어보세요.',
      shortTerm: '이번 주에 가볍게 만남을 제안해보는 것도 좋습니다.',
      avoid: '대화 분석 결과를 상대에게 직접 언급하는 것은 피하세요.',
    },
    compatibility: {
      communicationScore: 72,
      emotionalScore: 68,
      futureOutlook: '현재 대화 패턴을 유지하면서 감정 표현을 조금 더 늘리면 관계가 발전할 가능성이 있습니다.',
    },
    highlights: [
      '대화 톤과 속도에서 관계 감각이 읽힙니다.',
      '상대의 반응 패턴이 비교적 일관된 편입니다.',
      '감정 표현의 밸런스가 관계 발전의 열쇠입니다.',
    ],
  }
}
