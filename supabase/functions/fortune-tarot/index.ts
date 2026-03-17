/**
 * 타로 카드 리딩 (Tarot Reading) Edge Function
 *
 * @description 사용자가 선택한 타로 카드를 AI가 분석하여 위치별 해석과 종합 리딩을 제공합니다.
 *              78장 전체 카드 인덱스를 받아 안정적인 payload로 응답합니다.
 *
 * @endpoint POST /fortune-tarot
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractTarotCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'
import {
  AVAILABLE_TAROT_DECKS,
  TarotCatalogEntry,
  getRandomDeck,
  getTarotCardCatalogEntry,
  getTarotDeckDisplayName,
} from './tarotCatalog.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const SPREAD_POSITIONS: Record<string, { key: string; name: string; desc: string }[]> = {
  single: [
    { key: 'core', name: '핵심 메시지', desc: '현재 상황의 핵심' },
  ],
  threeCard: [
    { key: 'past', name: '과거', desc: '지나간 영향과 원인' },
    { key: 'present', name: '현재', desc: '현재 상황과 에너지' },
    { key: 'future', name: '미래', desc: '다가올 가능성' },
  ],
  relationship: [
    { key: 'myFeelings', name: '나의 마음', desc: '당신의 진심' },
    { key: 'theirFeelings', name: '상대의 마음', desc: '상대방의 감정' },
    { key: 'pastConnection', name: '과거의 연결', desc: '함께한 역사' },
    { key: 'currentDynamic', name: '현재 관계', desc: '지금의 에너지' },
    { key: 'futureOutlook', name: '미래 전망', desc: '관계의 방향' },
  ],
  celticCross: [
    { key: 'presentSituation', name: '현재 상황', desc: '지금 당신이 있는 곳' },
    { key: 'challenge', name: '도전', desc: '극복해야 할 것' },
    { key: 'distantPast', name: '먼 과거', desc: '상황의 뿌리' },
    { key: 'recentPast', name: '최근 과거', desc: '최근의 영향' },
    { key: 'possibleOutcome', name: '가능한 미래', desc: '현재 경로의 결과' },
    { key: 'immediateFuture', name: '가까운 미래', desc: '곧 일어날 일' },
    { key: 'yourApproach', name: '당신의 태도', desc: '당신의 접근 방식' },
    { key: 'externalInfluences', name: '외부 영향', desc: '주변 환경과 사람들' },
    { key: 'hopesAndFears', name: '희망과 두려움', desc: '내면의 감정' },
    { key: 'finalOutcome', name: '최종 결과', desc: '궁극적인 결과' },
  ],
}

const SPREAD_NAMES: Record<string, string> = {
  single: '원카드 리딩',
  threeCard: '3카드 스프레드',
  relationship: '관계 스프레드',
  celticCross: '켈틱 크로스',
}

type SelectedCard = {
  index: number
  isReversed: boolean
}

type PromptCard = SelectedCard & {
  entry: TarotCatalogEntry
  positionKey: string
  positionName: string
  positionDesc: string
}

function sanitizeDeck(rawDeck: unknown): string {
  const deck = typeof rawDeck === 'string' ? rawDeck.trim() : ''
  return AVAILABLE_TAROT_DECKS.includes(deck) ? deck : getRandomDeck()
}

function normalizeQuestion(rawQuestion: unknown, rawPurpose: unknown): string {
  const question = typeof rawQuestion === 'string' ? rawQuestion.trim() : ''
  if (question.length > 0) {
    return question
  }

  switch (rawPurpose) {
    case 'love':
      return '연애와 관계의 흐름이 궁금해요.'
    case 'career':
      return '일과 커리어의 방향이 궁금해요.'
    case 'decision':
      return '지금 앞에 놓인 선택의 흐름이 궁금해요.'
    case 'guidance':
    default:
      return '지금 제게 필요한 조언이 궁금해요.'
  }
}

function normalizeSpreadType(rawSpreadType: unknown): string {
  const spreadType = typeof rawSpreadType === 'string' ? rawSpreadType.trim() : ''
  if (spreadType in SPREAD_POSITIONS) {
    return spreadType
  }
  return 'threeCard'
}

function extractSelectedCards(body: Record<string, any>, tarotSelection: Record<string, any>): SelectedCard[] {
  const candidates = [
    body.selectedCards,
    tarotSelection.selectedCards,
    body.selectedCardIndices,
    tarotSelection.selectedCardIndices,
    body.cards,
  ]

  for (const candidate of candidates) {
    const normalized = normalizeSelectedCards(candidate)
    if (normalized.length > 0) {
      return normalized
    }
  }

  return []
}

function normalizeSelectedCards(input: unknown): SelectedCard[] {
  if (!Array.isArray(input)) {
    return []
  }

  return input
    .map((item): SelectedCard | null => {
      if (typeof item === 'number') {
        return item >= 0 && item < 78 ? { index: item, isReversed: false } : null
      }

      if (item && typeof item === 'object') {
        const indexValue = typeof item.index === 'number'
          ? item.index
          : typeof item.cardIndex === 'number'
            ? item.cardIndex
            : typeof item.index === 'string'
              ? Number(item.index)
              : typeof item.cardIndex === 'string'
                ? Number(item.cardIndex)
                : NaN

        if (Number.isNaN(indexValue) || indexValue < 0 || indexValue >= 78) {
          return null
        }

        return {
          index: indexValue,
          isReversed: item.isReversed === true || item.is_reversed === true,
        }
      }

      return null
    })
    .filter((card): card is SelectedCard => card !== null)
}

function buildPromptCards(
  selectedCards: SelectedCard[],
  spreadType: string,
  deckId: string
): PromptCard[] {
  const positions = SPREAD_POSITIONS[spreadType] || SPREAD_POSITIONS.threeCard

  return selectedCards.map((card, index) => {
    const position = positions[index] || {
      key: `card${index + 1}`,
      name: `카드 ${index + 1}`,
      desc: '지금 이 순간의 추가 흐름',
    }

    return {
      ...card,
      entry: getTarotCardCatalogEntry(card.index, deckId),
      positionKey: position.key,
      positionName: position.name,
      positionDesc: position.desc,
    }
  })
}

function buildStorytellingPrompt(
  question: string,
  spreadType: string,
  cards: PromptCard[],
  userName?: string,
  birthDate?: string
): string {
  const cardDescriptions = cards.map((card, index) => {
    const orientation = card.isReversed ? '역방향' : '정방향'
    const meaning = card.isReversed ? card.entry.reversedMeaning : card.entry.uprightMeaning
    return `${index + 1}. **${card.positionName}** (${card.positionDesc})
   카드: ${card.entry.cardNameKr} (${card.entry.cardName}) - ${orientation}
   키워드: ${card.entry.keywords.join(', ')}
   기본 의미: ${meaning}
   원소: ${card.entry.element}`
  }).join('\n\n')

  const storyGuide = cards.length > 1
    ? `
## 스토리텔링 가이드 (중요!)
이 ${cards.length}장의 카드는 하나의 연결된 이야기를 들려줍니다.
- 카드들 사이의 흐름과 관계를 파악하세요
- 각 위치가 어떻게 다음 위치로 자연스럽게 연결되는지 서술하세요
- 마치 한 편의 짧은 이야기처럼 전체 해석을 구성하세요
- 특히 ${spreadType === 'relationship' ? '두 사람의 감정 흐름과 관계의 발전' : spreadType === 'threeCard' ? '과거→현재→미래의 시간적 흐름' : '각 위치간의 인과관계'}을 강조하세요
`
    : ''

  return `당신은 신비로운 타로 세계의 안내자예요! ✨
카드들이 속삭이는 이야기를 마치 친한 친구에게 들려주듯이, 따뜻하고 흥미진진하게 전해주세요.

## 스타일 가이드 🎴
- 신비로운 분위기는 유지하되, 딱딱하지 않게
- "~해요", "~거예요" 같은 친근한 말투 사용
- 카드가 전하는 메시지를 마치 드라마 스토리처럼 흥미롭게 전달
- 조언은 "~해보세요"처럼 부드럽게

## 질문자 정보
- 질문/주제: "${question}"
${userName ? `- 이름: ${userName}` : ''}
${birthDate ? `- 생년월일: ${birthDate}` : ''}
- 스프레드: ${SPREAD_NAMES[spreadType] || spreadType} (${cards.length}장)

## 펼쳐진 카드
${cardDescriptions}
${storyGuide}

## 응답 형식 (JSON)
{
  "cardInterpretations": [
    {
      "positionKey": "string",
      "interpretation": "string"
    }
  ],
  "overallReading": "string",
  "storyTitle": "string",
  "guidance": "string",
  "advice": "string",
  "energyLevel": number,
  "keyThemes": ["string", "string", "string"],
  "luckyElement": "string",
  "focusAreas": ["string", "string"],
  "timeFrame": "string"
}

## 중요
1. 각 카드 해석은 친근한 말투 3-4문장으로 작성
2. overallReading은 시작-전개-결말이 느껴지도록 6-8문장으로 작성
3. 정방향/역방향에 따라 뉘앙스를 분명히 다르게 작성
4. 반드시 유효한 JSON만 출력`
}

function parseJsonResponse(content: string): Record<string, any> | null {
  try {
    const jsonMatch = content.match(/\{[\s\S]*\}/)
    if (!jsonMatch) {
      return null
    }
    return JSON.parse(jsonMatch[0])
  } catch (_) {
    return null
  }
}

function normalizeStringArray(value: unknown, fallback: string[] = []): string[] {
  if (!Array.isArray(value)) {
    return fallback
  }

  const list = value
    .map(item => typeof item === 'string' ? item.trim() : '')
    .filter(Boolean)

  return list.length > 0 ? list : fallback
}

function buildFallbackResponse(cards: PromptCard[]): Record<string, any> {
  return {
    cardInterpretations: cards.map(card => ({
      positionKey: card.positionKey,
      interpretation: `${card.positionName} 자리의 ${card.entry.cardNameKr} 카드는 지금 흐름에서 ${card.isReversed ? card.entry.reversedMeaning : card.entry.uprightMeaning}`,
    })),
    overallReading: '카드들이 지금 당신에게 중요한 흐름 변화를 보여주고 있어요. 서두르기보다 의미를 차분히 따라가 보세요.',
    storyTitle: '카드가 들려주는 지금의 흐름',
    guidance: '지금 보이는 감정과 현실 신호를 함께 읽는 것이 중요해요.',
    advice: '결론을 급히 내리기보다, 각 카드가 말하는 우선순위를 하나씩 실천해 보세요.',
    energyLevel: 70,
    keyThemes: cards.slice(0, 3).flatMap(card => card.entry.keywords).slice(0, 3),
    luckyElement: cards[0]?.entry.element ?? '공기',
    focusAreas: cards.slice(0, 2).map(card => card.positionName),
    timeFrame: '향후 2-3주',
  }
}

function buildStableTarotData(
  source: Record<string, any>,
  params: {
    question: string
    deckId: string
    spreadType: string
    cards: PromptCard[]
  }
) {
  const cardInterpretations = Array.isArray(source.cardInterpretations)
    ? source.cardInterpretations
    : []

  const legacyPositionInterpretations =
    source.positionInterpretations && typeof source.positionInterpretations === 'object'
      ? source.positionInterpretations
      : source.position_interpretations && typeof source.position_interpretations === 'object'
        ? source.position_interpretations
        : {}

  const positionInterpretations = params.cards.reduce<Record<string, string>>((acc, card) => {
    const matched = cardInterpretations.find((entry: any) => entry?.positionKey === card.positionKey)
    acc[card.positionKey] =
      typeof matched?.interpretation === 'string' && matched.interpretation.trim().length > 0
        ? matched.interpretation.trim()
        : typeof legacyPositionInterpretations[card.positionKey] === 'string'
          ? legacyPositionInterpretations[card.positionKey]
          : `${card.positionName}의 ${card.entry.cardNameKr} 카드는 ${card.isReversed ? card.entry.reversedMeaning : card.entry.uprightMeaning}`
    return acc
  }, {})

  return {
    question: params.question,
    deckId: params.deckId,
    deckName: getTarotDeckDisplayName(params.deckId),
    spreadType: params.spreadType,
    spreadDisplayName: SPREAD_NAMES[params.spreadType] || params.spreadType,
    storyTitle:
      typeof source.storyTitle === 'string' && source.storyTitle.trim().length > 0
        ? source.storyTitle.trim()
        : '카드가 들려주는 오늘의 흐름',
    overallReading:
      typeof source.overallReading === 'string' && source.overallReading.trim().length > 0
        ? source.overallReading.trim()
        : typeof source.overall_interpretation === 'string' && source.overall_interpretation.trim().length > 0
          ? source.overall_interpretation.trim()
          : '카드가 전하는 흐름을 바탕으로 다음 선택을 정리해 보세요.',
    guidance:
      typeof source.guidance === 'string' && source.guidance.trim().length > 0
        ? source.guidance.trim()
        : '카드가 강조한 흐름을 기준으로 지금의 우선순위를 가볍게 정리해 보세요.',
    advice:
      typeof source.advice === 'string' && source.advice.trim().length > 0
        ? source.advice.trim()
        : '하루 안에 실천할 수 있는 가장 작은 행동 하나부터 시작해 보세요.',
    keyThemes: normalizeStringArray(source.keyThemes || source.key_themes, params.cards[0]?.entry.keywords.slice(0, 3) ?? ['통찰', '흐름', '선택']),
    luckyElement:
      typeof source.luckyElement === 'string' && source.luckyElement.trim().length > 0
        ? source.luckyElement.trim()
        : typeof source.lucky_element === 'string' && source.lucky_element.trim().length > 0
          ? source.lucky_element.trim()
          : params.cards[0]?.entry.element ?? '',
    focusAreas: normalizeStringArray(source.focusAreas || source.focus_areas, params.cards.slice(0, 2).map(card => card.positionName)),
    timeFrame:
      typeof source.timeFrame === 'string' && source.timeFrame.trim().length > 0
        ? source.timeFrame.trim()
        : typeof source.time_frame === 'string' && source.time_frame.trim().length > 0
          ? source.time_frame.trim()
          : '향후 2-3주',
    energyLevel: typeof source.energyLevel === 'number' ? source.energyLevel : 70,
    positionInterpretations,
    cards: params.cards.map(card => ({
      index: card.index,
      cardId: card.entry.cardId,
      arcana: card.entry.arcana,
      suit: card.entry.suit,
      rank: card.entry.rank,
      cardName: card.entry.cardName,
      cardNameKr: card.entry.cardNameKr,
      imagePath: card.entry.imagePath,
      isReversed: card.isReversed,
      orientationLabel: card.isReversed ? '역방향' : '정방향',
      positionKey: card.positionKey,
      positionName: card.positionName,
      positionDesc: card.positionDesc,
      interpretation: positionInterpretations[card.positionKey],
      keywords: card.entry.keywords,
      element: card.entry.element,
    })),
    timestamp: typeof source.timestamp === 'string' && source.timestamp.trim().length > 0
      ? source.timestamp
      : new Date().toISOString(),
  }
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    console.log('📥 받은 요청 body 키:', Object.keys(body))

    const tarotSelection = body.answers?.tarotSelection || body.tarotSelection || {}
    const userId =
      body.userId ||
      body.user_id ||
      body.answers?.userId ||
      body.answers?.user_id ||
      'anonymous'
    const purpose = body.purpose || body.answers?.purpose
    const question = normalizeQuestion(
      body.question || tarotSelection.question || body.questionText || body.answers?.questionText,
      purpose
    )
    const spreadType = normalizeSpreadType(body.spreadType || tarotSelection.spreadType)
    const deckId = sanitizeDeck(body.deck || body.deckId || tarotSelection.deck || tarotSelection.deckId)
    const userName = body.name
    const birthDate = body.birthDate

    const selectedCards = extractSelectedCards(body, tarotSelection)
    const cardIndices = selectedCards.map(card => card.index)

    console.log(`🃏 추출된 카드 인덱스: [${cardIndices.join(', ')}] (${cardIndices.length}장)`)

    if (selectedCards.length === 0) {
      return new Response(
        JSON.stringify({ success: false, error: '필수 필드 누락: selectedCards' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const promptCards = buildPromptCards(selectedCards, spreadType, deckId)
    const supabaseClient = createClient(supabaseUrl, supabaseKey)

    const cohortData = extractTarotCohort({
      spreadType,
      question,
      birthDate,
    })
    const cohortHash = await generateCohortHash(cohortData)

    if (Object.keys(cohortData).length > 0) {
      console.log(`🎯 [Tarot] Cohort: ${JSON.stringify(cohortData)}`)

      const poolResult = await getFromCohortPool(supabaseClient, 'tarot', cohortHash)
      if (poolResult) {
        console.log('✅ [Tarot] Cohort Pool 히트! LLM 호출 생략')

        const personalized = personalize(poolResult, {
          userName: userName || '회원님',
          question,
        })

        const normalized = buildStableTarotData(personalized, {
          question,
          deckId,
          spreadType,
          cards: promptCards,
        })
        const percentileData = await calculatePercentile(
          supabaseClient,
          'tarot',
          normalized.energyLevel || 70
        )
        const resultWithPercentile = addPercentileToResult(normalized, percentileData)

        return new Response(
          JSON.stringify({
            success: true,
            data: {
              ...resultWithPercentile,
              timestamp: new Date().toISOString(),
            },
            cohortHit: true,
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    const llm = LLMFactory.createFromConfig('tarot')
    const prompt = buildStorytellingPrompt(
      question,
      spreadType,
      promptCards,
      userName,
      birthDate
    )

    console.log('🔮 LLM 스토리텔링 호출 시작...')
    const startTime = Date.now()
    const llmResult = await llm.generate(
      [{ role: 'user', content: prompt }],
      {
        maxTokens: 2500,
        temperature: 0.85,
        jsonMode: true,
      }
    )
    const elapsed = Date.now() - startTime
    console.log(`✅ LLM 응답 완료 (${elapsed}ms)`)

    const parsedResponse = parseJsonResponse(llmResult.content) ?? buildFallbackResponse(promptCards)
    const normalized = buildStableTarotData(parsedResponse, {
      question,
      deckId,
      spreadType,
      cards: promptCards,
    })

    UsageLogger.log({
      userId,
      fortuneType: 'tarot',
      provider: llmResult.provider,
      model: llmResult.model,
      response: llmResult,
    }).catch(console.error)

    if (Object.keys(cohortData).length > 0) {
      saveToCohortPool(supabaseClient, 'tarot', cohortHash, cohortData, normalized)
        .catch(e => console.error('[Tarot] Cohort 저장 오류:', e))
    }

    const percentileData = await calculatePercentile(
      supabaseClient,
      'tarot',
      normalized.energyLevel || 70
    )
    const resultWithPercentile = addPercentileToResult(normalized, percentileData)

    console.log(`🎴 타로 리딩 완료 - ${normalized.cards.length}장, 에너지: ${normalized.energyLevel}`)

    return new Response(
      JSON.stringify({
        success: true,
        data: resultWithPercentile,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('❌ 타로 리딩 오류:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다',
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
