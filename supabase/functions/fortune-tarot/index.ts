/**
 * 타로 카드 리딩 (Tarot Reading) Edge Function
 *
 * @description 사용자가 선택한 타로 카드를 AI가 분석하여 위치별 해석과 종합 리딩을 제공합니다.
 *              인덱스만 받아도 자동으로 카드 메타데이터를 구축합니다.
 *
 * @endpoint POST /fortune-tarot
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - question: string - 사용자 질문 또는 카테고리
 * - spreadType: 'single' | 'threeCard' | 'relationship' | 'celticCross' - 스프레드 유형
 * - selectedCards: number[] - 선택된 카드 인덱스 배열
 * - deck?: string - 덱 타입 (기본: rider_waite)
 *
 * @response TarotReadingResponse
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

// CORS 헤더
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// 환경 변수
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// ===== 타로 메타데이터 =====

const MAJOR_ARCANA: Record<number, {
  name: string
  nameKr: string
  keywords: string[]
  element: string
  uprightMeaning: string
  reversedMeaning: string
  fileName: string
}> = {
  0: { name: 'The Fool', nameKr: '바보', keywords: ['새로운 시작', '순수함', '모험'], element: '바람', uprightMeaning: '새로운 여정의 시작, 순수한 마음으로의 도전', reversedMeaning: '무모함, 경솔한 결정', fileName: '00_fool.jpg' },
  1: { name: 'The Magician', nameKr: '마법사', keywords: ['의지력', '창조', '능력'], element: '바람', uprightMeaning: '능력의 발휘, 창조적 실현', reversedMeaning: '속임수, 재능 낭비', fileName: '01_magician.jpg' },
  2: { name: 'The High Priestess', nameKr: '여사제', keywords: ['직관', '비밀', '잠재의식'], element: '물', uprightMeaning: '내면의 지혜, 직관을 믿음', reversedMeaning: '직관 무시, 숨겨진 의도', fileName: '02_high_priestess.jpg' },
  3: { name: 'The Empress', nameKr: '여황제', keywords: ['풍요', '모성', '창조'], element: '땅', uprightMeaning: '풍요와 창조, 양육의 에너지', reversedMeaning: '창조적 막힘, 의존성', fileName: '03_empress.jpg' },
  4: { name: 'The Emperor', nameKr: '황제', keywords: ['권위', '구조', '아버지'], element: '불', uprightMeaning: '안정과 권위, 체계적 접근', reversedMeaning: '독재, 유연성 부족', fileName: '04_emperor.jpg' },
  5: { name: 'The Hierophant', nameKr: '교황', keywords: ['전통', '교육', '신앙'], element: '땅', uprightMeaning: '전통과 가르침, 영적 지도', reversedMeaning: '맹목적 추종, 규칙 거부', fileName: '05_hierophant.jpg' },
  6: { name: 'The Lovers', nameKr: '연인', keywords: ['사랑', '선택', '조화'], element: '바람', uprightMeaning: '진정한 사랑, 중요한 선택', reversedMeaning: '불화, 잘못된 선택', fileName: '06_lovers.jpg' },
  7: { name: 'The Chariot', nameKr: '전차', keywords: ['승리', '의지', '결단'], element: '물', uprightMeaning: '승리와 전진, 강한 의지력', reversedMeaning: '통제 상실, 방향 상실', fileName: '07_chariot.jpg' },
  8: { name: 'Strength', nameKr: '힘', keywords: ['용기', '인내', '자기통제'], element: '불', uprightMeaning: '내면의 힘, 부드러운 용기', reversedMeaning: '자기 의심, 나약함', fileName: '08_strength.jpg' },
  9: { name: 'The Hermit', nameKr: '은둔자', keywords: ['내면 탐구', '지혜', '고독'], element: '땅', uprightMeaning: '내면 성찰, 지혜 추구', reversedMeaning: '고립, 지나친 은둔', fileName: '09_hermit.jpg' },
  10: { name: 'Wheel of Fortune', nameKr: '운명의 수레바퀴', keywords: ['운명', '변화', '순환'], element: '불', uprightMeaning: '행운의 전환점, 좋은 변화', reversedMeaning: '불운, 저항할 수 없는 변화', fileName: '10_wheel_of_fortune.jpg' },
  11: { name: 'Justice', nameKr: '정의', keywords: ['공정', '진실', '책임'], element: '바람', uprightMeaning: '공정한 판단, 진실의 승리', reversedMeaning: '불공정, 책임 회피', fileName: '11_justice.jpg' },
  12: { name: 'The Hanged Man', nameKr: '매달린 사람', keywords: ['희생', '새로운 관점', '기다림'], element: '물', uprightMeaning: '새로운 시각, 필요한 희생', reversedMeaning: '불필요한 희생, 지연', fileName: '12_hanged_man.jpg' },
  13: { name: 'Death', nameKr: '죽음', keywords: ['변화', '끝', '재탄생'], element: '물', uprightMeaning: '변화와 재탄생, 과거와의 이별', reversedMeaning: '변화에 저항, 집착', fileName: '13_death.jpg' },
  14: { name: 'Temperance', nameKr: '절제', keywords: ['균형', '조화', '인내'], element: '불', uprightMeaning: '조화와 균형, 절제의 미덕', reversedMeaning: '불균형, 극단', fileName: '14_temperance.jpg' },
  15: { name: 'The Devil', nameKr: '악마', keywords: ['유혹', '속박', '물질'], element: '땅', uprightMeaning: '속박에서 벗어남의 필요성', reversedMeaning: '자유를 향한 움직임', fileName: '15_devil.jpg' },
  16: { name: 'The Tower', nameKr: '탑', keywords: ['붕괴', '해방', '계시'], element: '불', uprightMeaning: '갑작스런 변화, 구조의 붕괴', reversedMeaning: '피할 수 없는 변화, 저항', fileName: '16_tower.jpg' },
  17: { name: 'The Star', nameKr: '별', keywords: ['희망', '영감', '평화'], element: '바람', uprightMeaning: '희망과 영감, 내면의 평화', reversedMeaning: '희망 상실, 낙담', fileName: '17_star.jpg' },
  18: { name: 'The Moon', nameKr: '달', keywords: ['환상', '불안', '잠재의식'], element: '물', uprightMeaning: '직관을 따름, 숨겨진 진실', reversedMeaning: '혼란, 기만', fileName: '18_moon.jpg' },
  19: { name: 'The Sun', nameKr: '태양', keywords: ['성공', '기쁨', '활력'], element: '불', uprightMeaning: '성공과 기쁨, 밝은 전망', reversedMeaning: '일시적 좌절, 자만', fileName: '19_sun.jpg' },
  20: { name: 'Judgement', nameKr: '심판', keywords: ['재생', '각성', '부름'], element: '불', uprightMeaning: '재탄생, 내면의 부름', reversedMeaning: '자기 비판, 과거 집착', fileName: '20_judgement.jpg' },
  21: { name: 'The World', nameKr: '세계', keywords: ['완성', '통합', '성취'], element: '땅', uprightMeaning: '완성과 성취, 통합', reversedMeaning: '미완성, 목표 지연', fileName: '21_world.jpg' },
}

// 스프레드별 포지션 정보
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

// 카드 이미지 경로 생성
function getCardImagePath(cardIndex: number, deck: string = 'rider_waite'): string {
  const card = MAJOR_ARCANA[cardIndex]
  if (!card) return ''
  return `assets/images/tarot/decks/${deck}/major/${card.fileName}`
}

// ===== 스토리텔링 프롬프트 =====

function buildStorytellingPrompt(
  question: string,
  spreadType: string,
  cards: { index: number; isReversed: boolean; positionName: string; positionDesc: string }[],
  userName?: string,
  birthDate?: string
): string {
  const cardDescriptions = cards.map((card, i) => {
    const cardData = MAJOR_ARCANA[card.index]
    const orientation = card.isReversed ? '역방향' : '정방향'
    const meaning = card.isReversed ? cardData?.reversedMeaning : cardData?.uprightMeaning
    return `${i + 1}. **${card.positionName}** (${card.positionDesc})
   카드: ${cardData?.nameKr} (${cardData?.name}) - ${orientation}
   키워드: ${cardData?.keywords?.join(', ')}
   기본 의미: ${meaning}
   원소: ${cardData?.element}`
  }).join('\n\n')

  // 멀티카드 스토리텔링 가이드
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

  return `당신은 숙련된 타로 마스터입니다. 카드들이 전하는 이야기를 감성적이면서도 구체적으로 들려주세요.

## 질문자 정보
- 질문/주제: "${question}"
${userName ? `- 이름: ${userName}` : ''}
${birthDate ? `- 생년월일: ${birthDate}` : ''}
- 스프레드: ${SPREAD_NAMES[spreadType]} (${cards.length}장)

## 펼쳐진 카드
${cardDescriptions}
${storyGuide}

## 응답 형식 (JSON)
{
  "cardInterpretations": [
    {
      "positionKey": "string (위치 키)",
      "interpretation": "string (이 위치에서 이 카드의 의미, 3-4문장. 이전 카드와의 연결점 언급)"
    }
  ],
  "overallReading": "string (${cards.length}장의 카드가 하나로 연결되어 전하는 이야기. 6-8문장으로 드라마틱하게 서술. 시작-전개-결말 구조)",
  "storyTitle": "string (이 리딩을 한 문장으로 요약한 제목)",
  "guidance": "string (질문에 대한 핵심 방향성, 2-3문장)",
  "advice": "string (구체적이고 실천 가능한 조언, 3-4문장)",
  "energyLevel": number (1-100, 현재 에너지/기운 점수),
  "keyThemes": ["string", "string", "string"] (3개의 핵심 키워드),
  "luckyElement": "string (행운의 원소/색상)",
  "focusAreas": ["string", "string"] (집중해야 할 2가지 영역),
  "timeFrame": "string (이 리딩의 유효 기간, 예: '향후 2-3주')"
}

중요:
1. 각 카드 해석에서 이전 카드와의 연결점을 자연스럽게 언급하세요
2. overallReading은 모든 카드를 관통하는 하나의 연속된 이야기여야 합니다
3. 정방향/역방향에 따라 의미가 크게 달라집니다
4. 반드시 유효한 JSON만 출력하세요`
}

// ===== 메인 핸들러 =====

serve(async (req: Request) => {
  // CORS 프리플라이트
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()

    console.log('📥 받은 요청 body 키:', Object.keys(body))

    // 중첩된 tarotSelection 객체에서 데이터 추출 지원
    // 앱에서 answers.tarotSelection.selectedCards 형식으로 보냄
    const tarotSelection = body.answers?.tarotSelection || body.tarotSelection || {}
    console.log('📋 tarotSelection 키:', Object.keys(tarotSelection))

    // 요청 데이터 정규화 (다양한 형식 지원)
    const userId = body.userId
    const question = body.question || tarotSelection.question || body.answers?.purpose || body.purpose || 'guidance'
    const spreadType = body.spreadType || tarotSelection.spreadType || 'single'
    const deck = body.deck || tarotSelection.deck || 'rider_waite'
    const userName = body.name
    const birthDate = body.birthDate

    // 카드 인덱스 추출 (여러 형식 및 위치 지원)
    let cardIndices: number[] = []

    // 1. 최상위 레벨 selectedCards
    if (body.selectedCards && Array.isArray(body.selectedCards) && body.selectedCards.length > 0) {
      cardIndices = body.selectedCards.map((c: any) =>
        typeof c === 'number' ? c : c.index
      )
    }
    // 2. tarotSelection.selectedCards (앱에서 주로 사용하는 구조!)
    else if (tarotSelection.selectedCards && Array.isArray(tarotSelection.selectedCards) && tarotSelection.selectedCards.length > 0) {
      cardIndices = tarotSelection.selectedCards.map((c: any) =>
        typeof c === 'number' ? c : c.index
      )
    }
    // 3. selectedCardIndices (최상위)
    else if (body.selectedCardIndices && Array.isArray(body.selectedCardIndices) && body.selectedCardIndices.length > 0) {
      cardIndices = body.selectedCardIndices
    }
    // 4. tarotSelection.selectedCardIndices
    else if (tarotSelection.selectedCardIndices && Array.isArray(tarotSelection.selectedCardIndices) && tarotSelection.selectedCardIndices.length > 0) {
      cardIndices = tarotSelection.selectedCardIndices
    }
    // 5. cards 배열
    else if (body.cards && Array.isArray(body.cards) && body.cards.length > 0) {
      cardIndices = body.cards.map((c: any) =>
        typeof c === 'number' ? c : c.index
      )
    }

    console.log(`🃏 추출된 카드 인덱스: [${cardIndices.join(', ')}] (${cardIndices.length}장)`)

    // 유효성 검사
    if (!userId || cardIndices.length === 0) {
      return new Response(
        JSON.stringify({ success: false, error: '필수 필드 누락: userId, selectedCards' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`🎴 타로 리딩 요청 - 사용자: ${userId}, 스프레드: ${spreadType}, 카드: [${cardIndices.join(', ')}]`)

    // Supabase 클라이언트 생성
    const supabaseClient = createClient(supabaseUrl, supabaseKey)

    // ===== Cohort Pool 조회 (API 비용 절감) =====
    // 타로는 선택 카드가 다양해서 Pool hit율은 낮지만, 동일 카드 조합 재사용 가능
    const cohortData = extractTarotCohort({
      spreadType: spreadType,
      question: question,
      selectedCards: cardIndices,
    })
    const cohortHash = await generateCohortHash(cohortData)

    if (Object.keys(cohortData).length > 0) {
      console.log(`🎯 [Tarot] Cohort: ${JSON.stringify(cohortData)}`)

      const poolResult = await getFromCohortPool(supabaseClient, 'tarot', cohortHash)

      if (poolResult) {
        console.log('✅ [Tarot] Cohort Pool 히트! LLM 호출 생략')

        // 개인화 (플레이스홀더 치환)
        const personalized = personalize(poolResult, {
          userName: userName || '회원님',
          question: question,
        })

        // 백분위 추가
        const resultWithPercentile = addPercentileToResult(
          personalized,
          calculatePercentile(personalized.energyLevel || 70)
        )

        return new Response(
          JSON.stringify({
            success: true,
            data: {
              ...resultWithPercentile,
              timestamp: new Date().toISOString(),
              isBlurred: false,
              blurredSections: [],
            },
            cohortHit: true,
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }
    // ===== Cohort Pool 미스 - LLM 호출 진행 =====

    // 포지션 정보 가져오기
    const positions = SPREAD_POSITIONS[spreadType] || SPREAD_POSITIONS['single']

    // 카드 데이터 구축 (인덱스로부터)
    const cardsForPrompt = cardIndices.map((index, i) => {
      const position = positions[i] || { key: `card${i}`, name: `카드 ${i + 1}`, desc: '' }
      // 기본적으로 정방향 (앱에서 역방향 정보 넘기면 그것 사용)
      const isReversed = body.selectedCards?.[i]?.isReversed ?? false
      return {
        index,
        isReversed,
        positionKey: position.key,
        positionName: position.name,
        positionDesc: position.desc,
      }
    })

    // LLM 호출 - generate() 메서드 사용 (generateJSON은 존재하지 않음!)
    const llm = LLMFactory.createFromConfig('tarot')
    const prompt = buildStorytellingPrompt(question, spreadType, cardsForPrompt, userName, birthDate)

    console.log('🔮 LLM 스토리텔링 호출 시작...')
    const startTime = Date.now()

    // FIX: generateJSON() → generate() with jsonMode: true
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

    // 응답 파싱 - llmResult.content에서 JSON 추출
    let parsedResponse: any
    try {
      const responseText = llmResult.content
      const jsonMatch = responseText.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        parsedResponse = JSON.parse(jsonMatch[0])
      } else {
        throw new Error('JSON 형식을 찾을 수 없습니다')
      }
    } catch (parseError) {
      console.error('❌ JSON 파싱 실패:', parseError)
      // 기본 응답 생성
      parsedResponse = {
        cardInterpretations: cardsForPrompt.map(card => ({
          positionKey: card.positionKey,
          interpretation: `${MAJOR_ARCANA[card.index]?.nameKr} 카드가 ${card.positionName} 위치에 나타났습니다.`
        })),
        overallReading: '타로 카드들이 당신에게 중요한 메시지를 전달합니다.',
        storyTitle: '새로운 시작의 이야기',
        guidance: '내면의 목소리에 귀 기울여 보세요.',
        advice: '지금은 신중하게 결정하고, 직관을 믿어보세요.',
        energyLevel: 70,
        keyThemes: ['변화', '성장', '기회'],
        luckyElement: '보라색',
        focusAreas: ['자기 성찰', '관계'],
        timeFrame: '향후 2-3주'
      }
    }

    // 최종 카드 결과 생성 (이미지 경로 포함)
    const cardResults = cardsForPrompt.map((card, i) => {
      const cardData = MAJOR_ARCANA[card.index]
      const interpretation = parsedResponse.cardInterpretations?.find(
        (ci: any) => ci.positionKey === card.positionKey
      )?.interpretation || `${cardData?.nameKr} 카드의 메시지를 묵상해 보세요.`

      return {
        index: card.index,
        cardName: cardData?.name || 'Unknown',
        cardNameKr: cardData?.nameKr || '알 수 없음',
        imagePath: getCardImagePath(card.index, deck),
        isReversed: card.isReversed,
        positionKey: card.positionKey,
        positionName: card.positionName,
        positionDesc: card.positionDesc,
        interpretation,
        keywords: cardData?.keywords || [],
        element: cardData?.element || '',
      }
    })

    // 프리미엄 체크는 클라이언트에서 - 서버는 항상 전체 데이터 반환
    // (블러 처리는 클라이언트가 결정)
    const response = {
      success: true,
      data: {
        question,
        spreadType,
        spreadDisplayName: SPREAD_NAMES[spreadType] || spreadType,
        spreadName: SPREAD_NAMES[spreadType] || spreadType,
        deckName: 'Rider-Waite',
        cards: cardResults,
        overallReading: parsedResponse.overallReading || '',
        storyTitle: parsedResponse.storyTitle || '',
        guidance: parsedResponse.guidance || '',
        advice: parsedResponse.advice || '',
        energyLevel: parsedResponse.energyLevel || 70,
        keyThemes: parsedResponse.keyThemes || [],
        luckyElement: parsedResponse.luckyElement || '',
        focusAreas: parsedResponse.focusAreas || [],
        timeFrame: parsedResponse.timeFrame || '',
        timestamp: new Date().toISOString(),
        // 블러 항상 false - 프리미엄 사용자는 다 볼 수 있어야 함
        isBlurred: false,
        blurredSections: [],
      },
    }

    // 사용량 로깅 - llmResult는 LLMResponse 타입
    UsageLogger.log({
      userId,
      fortuneType: 'tarot',
      provider: llmResult.provider,
      model: llmResult.model,
      response: llmResult,
    }).catch(console.error)

    // ===== Cohort Pool 저장 (fire-and-forget) =====
    if (Object.keys(cohortData).length > 0) {
      saveToCohortPool(supabaseClient, 'tarot', cohortHash, cohortData, response.data)
        .catch(e => console.error('[Tarot] Cohort 저장 오류:', e))
    }

    console.log(`🎴 타로 리딩 완료 - ${cardResults.length}장, 에너지: ${response.data.energyLevel}`)

    return new Response(
      JSON.stringify(response),
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
