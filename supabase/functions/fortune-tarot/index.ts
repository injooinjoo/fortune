import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface TarotFortuneRequest {
  question: string;
  spreadType: 'single' | 'three' | 'celtic' | 'relationship' | 'decision';
  selectedCards?: number[]; // 선택된 카드 ID들
  userId?: string;
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
}

interface TarotCard {
  id: number;
  name: string;
  keywords: string[];
  uprightMeaning: string;
  reversedMeaning: string;
  element: string;
  astrology?: string;
  numerology?: number;
  imagery: string;
  advice: string;
  isReversed: boolean;
  position?: string; // 스프레드에서의 위치 의미
}

interface TarotFortuneResponse {
  success: boolean;
  data: {
    question: string;
    spreadType: string;
    spreadName: string;
    cards: TarotCard[];
    overallReading: string;
    guidance: string;
    keyThemes: string[];
    energyLevel: number; // 1-10
    timeFrame: string;
    advice: string;
    luckyElement: string;
    focusAreas: string[];
    timestamp: string;
    isBlurred?: boolean; // ✅ 블러 상태
    blurredSections?: string[]; // ✅ 블러 처리된 섹션 목록
  };
  error?: string;
}

// 메이저 아르카나 22장의 기본 정보
const MAJOR_ARCANA_CARDS = [
  {
    id: 0,
    name: '바보 (The Fool)',
    keywords: ['새로운 시작', '순수함', '자유', '모험'],
    uprightMeaning: '새로운 여정의 시작, 무한한 가능성, 순수한 마음',
    reversedMeaning: '무모함, 위험한 선택, 준비 부족',
    element: '공기',
    astrology: '천왕성',
    numerology: 0,
    imagery: '절벽 끝에 서 있는 젊은이, 하얀 개, 태양',
    advice: '두려움 없이 새로운 도전을 받아들이세요'
  },
  {
    id: 1,
    name: '마법사 (The Magician)',
    keywords: ['의지력', '창조', '기술', '자신감'],
    uprightMeaning: '목표 실현의 능력, 모든 도구를 갖춤, 집중력',
    reversedMeaning: '재능 낭비, 속임수, 자신감 부족',
    element: '모든 원소',
    astrology: '수성',
    numerology: 1,
    imagery: '테이블 위의 4원소, 무한대 기호, 지팡이',
    advice: '당신의 모든 능력을 활용하여 목표를 달성하세요'
  },
  {
    id: 2,
    name: '여사제 (The High Priestess)',
    keywords: ['직관', '신비', '잠재의식', '지혜'],
    uprightMeaning: '내면의 목소리, 숨겨진 지식, 인내',
    reversedMeaning: '비밀 공개, 직관 무시, 표면적 판단',
    element: '물',
    astrology: '달',
    numerology: 2,
    imagery: '두 기둥 사이의 여사제, 초승달, 석류',
    advice: '직관을 믿고 내면의 지혜에 귀 기울이세요'
  },
  {
    id: 3,
    name: '여황제 (The Empress)',
    keywords: ['풍요', '모성', '창조', '자연'],
    uprightMeaning: '창조성과 풍요, 양육과 성장, 감각적 즐거움',
    reversedMeaning: '창조적 막힘, 과잉 보호, 의존성',
    element: '땅',
    astrology: '금성',
    numerology: 3,
    imagery: '왕좌의 여황제, 밀밭, 금성 기호',
    advice: '자연과 조화를 이루며 창조적 에너지를 발산하세요'
  },
  {
    id: 4,
    name: '황제 (The Emperor)',
    keywords: ['권위', '구조', '아버지', '안정'],
    uprightMeaning: '리더십, 권위, 안정적인 기반, 보호',
    reversedMeaning: '독재, 경직성, 권력 남용',
    element: '불',
    astrology: '양자리',
    numerology: 4,
    imagery: '왕좌의 황제, 양의 머리, 붉은 옷',
    advice: '책임감을 갖고 안정적인 구조를 만들어가세요'
  },
  {
    id: 5,
    name: '교황 (The Hierophant)',
    keywords: ['전통', '가르침', '신념', '사회적 규범'],
    uprightMeaning: '전통적 가치, 영적 지도, 교육과 학습',
    reversedMeaning: '독단적 사고, 전통에 대한 의문, 비순응',
    element: '땅',
    astrology: '황소자리',
    numerology: 5,
    imagery: '종교적 인물, 두 기둥, 두 제자',
    advice: '지혜로운 조언을 구하고 전통에서 배우세요'
  },
  {
    id: 6,
    name: '연인들 (The Lovers)',
    keywords: ['사랑', '선택', '조화', '관계'],
    uprightMeaning: '사랑과 조화, 중요한 선택, 가치관의 일치',
    reversedMeaning: '불화, 나쁜 선택, 가치관 충돌',
    element: '공기',
    astrology: '쌍둥이자리',
    numerology: 6,
    imagery: '두 연인, 천사, 에덴동산',
    advice: '마음의 소리를 듣고 진정한 선택을 하세요'
  },
  {
    id: 7,
    name: '전차 (The Chariot)',
    keywords: ['의지', '결단', '승리', '통제'],
    uprightMeaning: '의지력으로 얻는 승리, 자기 통제, 결단력',
    reversedMeaning: '통제력 상실, 공격성, 방향성 부족',
    element: '물',
    astrology: '게자리',
    numerology: 7,
    imagery: '전차를 모는 전사, 스핑크스, 별이 빛나는 천장',
    advice: '목표를 향해 결단력 있게 전진하세요'
  },
  {
    id: 8,
    name: '힘 (Strength)',
    keywords: ['내적 힘', '용기', '인내', '자비'],
    uprightMeaning: '내면의 힘, 부드러운 통제, 용기와 인내',
    reversedMeaning: '자기 의심, 약함, 인내력 부족',
    element: '불',
    astrology: '사자자리',
    numerology: 8,
    imagery: '사자를 다루는 여인, 무한대 기호',
    advice: '부드러운 힘으로 어려움을 극복하세요'
  },
  {
    id: 9,
    name: '은둔자 (The Hermit)',
    keywords: ['내면 탐구', '지혜', '고독', '안내'],
    uprightMeaning: '내면의 탐구, 영적 깨달음, 혼자만의 시간',
    reversedMeaning: '고립, 외로움, 내면 회피',
    element: '땅',
    astrology: '처녀자리',
    numerology: 9,
    imagery: '등불을 든 노인, 산꼭대기, 지팡이',
    advice: '내면의 빛을 따라 진실을 찾으세요'
  },
  {
    id: 10,
    name: '운명의 수레바퀴 (Wheel of Fortune)',
    keywords: ['변화', '순환', '운명', '기회'],
    uprightMeaning: '행운의 전환점, 새로운 기회, 운명의 순환',
    reversedMeaning: '불운, 통제력 상실, 저항',
    element: '불',
    astrology: '목성',
    numerology: 10,
    imagery: '회전하는 바퀴, 스핑크스, 동물 상징',
    advice: '변화의 흐름을 받아들이고 기회를 포착하세요'
  },
  {
    id: 11,
    name: '정의 (Justice)',
    keywords: ['공정', '균형', '진실', '책임'],
    uprightMeaning: '공정한 판단, 균형과 조화, 인과응보',
    reversedMeaning: '불공정, 편견, 책임 회피',
    element: '공기',
    astrology: '천칭자리',
    numerology: 11,
    imagery: '저울과 검을 든 인물, 두 기둥',
    advice: '진실과 공정함을 추구하세요'
  },
  {
    id: 12,
    name: '매달린 사람 (The Hanged Man)',
    keywords: ['희생', '관점 전환', '인내', '깨달음'],
    uprightMeaning: '자발적 희생, 새로운 관점, 영적 깨달음',
    reversedMeaning: '무의미한 희생, 정체, 지연',
    element: '물',
    astrology: '해왕성',
    numerology: 12,
    imagery: '거꾸로 매달린 사람, 후광, 나무',
    advice: '다른 관점에서 상황을 바라보세요'
  },
  {
    id: 13,
    name: '죽음 (Death)',
    keywords: ['변화', '종료', '변혁', '재생'],
    uprightMeaning: '큰 변화, 한 주기의 끝, 변혁과 재생',
    reversedMeaning: '변화 거부, 정체, 두려움',
    element: '물',
    astrology: '전갈자리',
    numerology: 13,
    imagery: '해골 기사, 검은 말, 떠오르는 태양',
    advice: '끝은 새로운 시작을 위한 준비입니다'
  },
  {
    id: 14,
    name: '절제 (Temperance)',
    keywords: ['균형', '조화', '인내', '통합'],
    uprightMeaning: '균형과 조화, 인내심, 중용의 미덕',
    reversedMeaning: '불균형, 과잉, 조급함',
    element: '불',
    astrology: '사수자리',
    numerology: 14,
    imagery: '천사, 두 잔의 물, 붓꽃',
    advice: '인내심을 갖고 균형을 찾으세요'
  },
  {
    id: 15,
    name: '악마 (The Devil)',
    keywords: ['속박', '유혹', '물질주의', '그림자'],
    uprightMeaning: '속박과 중독, 물질적 집착, 억압된 욕망',
    reversedMeaning: '해방, 속박에서 벗어남, 각성',
    element: '땅',
    astrology: '염소자리',
    numerology: 15,
    imagery: '악마, 쇠사슬에 묶인 남녀, 거꾸로 된 오각별',
    advice: '자신을 속박하는 것에서 벗어나세요'
  },
  {
    id: 16,
    name: '탑 (The Tower)',
    keywords: ['파괴', '각성', '충격', '해방'],
    uprightMeaning: '갑작스런 변화, 기존 구조의 붕괴, 각성',
    reversedMeaning: '변화 회피, 재난 예방, 내적 변화',
    element: '불',
    astrology: '화성',
    numerology: 16,
    imagery: '번개 맞은 탑, 떨어지는 사람들, 왕관',
    advice: '파괴는 때로 필요한 정화 과정입니다'
  },
  {
    id: 17,
    name: '별 (The Star)',
    keywords: ['희망', '영감', '치유', '갱신'],
    uprightMeaning: '희망과 영감, 영적 인도, 치유와 갱신',
    reversedMeaning: '절망, 신념 상실, 단절감',
    element: '공기',
    astrology: '물병자리',
    numerology: 17,
    imagery: '물을 붓는 여인, 일곱 개의 작은 별, 하나의 큰 별',
    advice: '희망을 품고 미래를 믿으세요'
  },
  {
    id: 18,
    name: '달 (The Moon)',
    keywords: ['환상', '두려움', '잠재의식', '직관'],
    uprightMeaning: '환상과 불안, 숨겨진 진실, 직관의 메시지',
    reversedMeaning: '환상에서 깨어남, 명확성, 두려움 극복',
    element: '물',
    astrology: '물고기자리',
    numerology: 18,
    imagery: '달, 개와 늑대, 가재, 두 탑',
    advice: '직관을 신뢰하되 환상에 주의하세요'
  },
  {
    id: 19,
    name: '태양 (The Sun)',
    keywords: ['성공', '활력', '기쁨', '성취'],
    uprightMeaning: '성공과 성취, 활력과 기쁨, 긍정적 에너지',
    reversedMeaning: '일시적 좌절, 과도한 낙관, 자만',
    element: '불',
    astrology: '태양',
    numerology: 19,
    imagery: '빛나는 태양, 아이와 말, 해바라기',
    advice: '당신의 빛을 세상과 나누세요'
  },
  {
    id: 20,
    name: '심판 (Judgement)',
    keywords: ['부활', '각성', '용서', '재평가'],
    uprightMeaning: '영적 각성, 과거의 정리, 새로운 시작',
    reversedMeaning: '자기 비판, 용서 부족, 과거에 매임',
    element: '불',
    astrology: '명왕성',
    numerology: 20,
    imagery: '천사의 나팔, 부활하는 사람들, 깃발',
    advice: '과거를 용서하고 새롭게 태어나세요'
  },
  {
    id: 21,
    name: '세계 (The World)',
    keywords: ['완성', '성취', '통합', '전체성'],
    uprightMeaning: '완성과 성취, 한 주기의 완료, 조화와 통합',
    reversedMeaning: '미완성, 지연, 외적 성공 내적 공허',
    element: '땅',
    astrology: '토성',
    numerology: 21,
    imagery: '월계관 속의 춤추는 인물, 네 생명체',
    advice: '성취를 축하하고 새로운 여정을 준비하세요'
  }
]

// 스프레드별 설정
const TAROT_SPREADS = {
  'single': {
    name: '원 카드 리딩',
    cardCount: 1,
    positions: ['현재 상황/오늘의 메시지'],
    description: '오늘의 메시지나 즉각적인 통찰'
  },
  'three': {
    name: '쓰리 카드 스프레드',
    cardCount: 3,
    positions: ['과거/상황', '현재/행동', '미래/결과'],
    description: '과거-현재-미래 또는 상황-행동-결과'
  },
  'celtic': {
    name: '켈틱 크로스',
    cardCount: 10,
    positions: [
      '현재 상황',
      '도전/십자가',
      '먼 과거/기초',
      '최근 과거',
      '가능한 미래',
      '가까운 미래',
      '당신의 접근',
      '외부 영향',
      '희망과 두려움',
      '최종 결과'
    ],
    description: '가장 상세한 10장 스프레드'
  },
  'relationship': {
    name: '관계 스프레드',
    cardCount: 7,
    positions: [
      '나의 감정',
      '상대의 감정',
      '관계의 기초',
      '나의 도전',
      '상대의 도전',
      '관계의 잠재력',
      '조언'
    ],
    description: '두 사람 사이의 관계 분석'
  },
  'decision': {
    name: '결정 스프레드',
    cardCount: 7,
    positions: [
      '현재 상황',
      '선택지 1',
      '선택지 1의 결과',
      '선택지 2',
      '선택지 2의 결과',
      '중요한 요소',
      '최종 조언'
    ],
    description: '중요한 선택을 위한 가이드'
  }
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

    const { question, spreadType, selectedCards, userId, isPremium }: TarotFortuneRequest = await req.json()

    console.log(`[Tarot] Request - User: ${userId}, Premium: ${isPremium}, Spread: ${spreadType}`)

    // 입력 데이터 검증
    if (!question || !spreadType) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '질문과 스프레드 타입이 모두 필요합니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400
        }
      )
    }

    // 스프레드 타입 유효성 검증
    if (!TAROT_SPREADS[spreadType as keyof typeof TAROT_SPREADS]) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '유효하지 않은 스프레드 타입입니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400
        }
      )
    }

    // 캐시 확인 (오늘 같은 사용자, 같은 질문으로 생성된 타로 운세가 있는지)
    const today = new Date().toISOString().split('T')[0]
    const questionHash = question.slice(0, 50) // 질문의 첫 50자로 캐시 키 생성
    const cacheKey = `${userId || 'anonymous'}_tarot_${spreadType}_${questionHash}_${today}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'tarot')
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

    const spreadConfig = TAROT_SPREADS[spreadType as keyof typeof TAROT_SPREADS]

    // 카드 선택 (랜덤 또는 사용자가 선택한 카드)
    let drawnCards: number[] = []
    if (selectedCards && selectedCards.length === spreadConfig.cardCount) {
      drawnCards = selectedCards
    } else {
      // 랜덤하게 카드 뽑기 (중복 없이)
      const availableCards = Array.from({ length: 22 }, (_, i) => i)
      drawnCards = []
      for (let i = 0; i < spreadConfig.cardCount; i++) {
        const randomIndex = Math.floor(Math.random() * availableCards.length)
        drawnCards.push(availableCards[randomIndex])
        availableCards.splice(randomIndex, 1)
      }
    }

    // 각 카드에 대해 정/역방향 결정
    const cards: TarotCard[] = drawnCards.map((cardId, index) => {
      const cardInfo = MAJOR_ARCANA_CARDS.find(c => c.id === cardId)!
      const isReversed = Math.random() < 0.3 // 30% 확률로 역방향

      return {
        ...cardInfo,
        isReversed,
        position: spreadConfig.positions[index]
      }
    })

    // 카드 정보를 기반으로 프롬프트 생성
    const cardDescriptions = cards.map((card, index) => {
      const orientation = card.isReversed ? '역방향' : '정방향'
      const meaning = card.isReversed ? card.reversedMeaning : card.uprightMeaning
      return `${index + 1}번 위치 "${card.position}": ${card.name} (${orientation})
      - 의미: ${meaning}
      - 키워드: ${card.keywords.join(', ')}
      - 조언: ${card.advice}
      - 원소: ${card.element}`
    }).join('\n\n')

    // ✅ LLM 모듈 사용 (Provider 자동 선택)
    const llm = LLMFactory.createFromConfig('tarot')

    const systemPrompt = `당신은 전문적인 타로 리더입니다. 타로 카드의 상징과 의미를 깊이 이해하고 있으며, 한국어로 정확하고 직관적인 해석을 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallReading": "전체적인 리딩 (300자 내외)",
  "guidance": "핵심 가이던스 (200자 내외)",
  "keyThemes": ["주요 테마1", "주요 테마2", "주요 테마3"],
  "energyLevel": 에너지 레벨 (1-10),
  "timeFrame": "타임프레임 (예: 1-3개월, 가까운 미래 등)",
  "advice": "실용적 조언 (200자 내외)",
  "luckyElement": "행운의 원소 (불/물/공기/땅 중 하나)",
  "focusAreas": ["집중해야 할 영역1", "집중해야 할 영역2", "집중해야 할 영역3"]
}

모든 해석은 희망적이고 건설적이며 실용적인 조언을 포함해야 합니다.`

    const userPrompt = `질문: ${question}
스프레드: ${spreadConfig.name} (${spreadConfig.description})
날짜: ${new Date().toLocaleDateString('ko-KR')}

뽑힌 카드들:
${cardDescriptions}

이 타로 카드들을 바탕으로 질문자에게 깊이 있는 해석과 조언을 JSON 형식으로 해주세요.`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료:`)
    console.log(`  Provider: ${response.provider}`)
    console.log(`  Model: ${response.model}`)
    console.log(`  Latency: ${response.latency}ms`)
    console.log(`  Tokens: ${response.usage.totalTokens}`)

    // 응답 파싱
    if (!response.content) {
      throw new Error(`LLM API 오류: 응답 없음`)
    }

    const fortuneData = JSON.parse(response.content)

    // ✅ Premium 여부에 따라 Blur 처리
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['guidance', 'keyThemes', 'timeFrame', 'advice', 'luckyElement', 'focusAreas']
      : []

    const result: TarotFortuneResponse['data'] = {
      question,
      spreadType,
      spreadName: spreadConfig.name,
      cards,
      overallReading: fortuneData.overallReading, // ✅ 무료: 공개
      guidance: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.guidance, // 🔒 유료
      keyThemes: isBlurred ? ['🔒 프리미엄 전용'] : (fortuneData.keyThemes || []), // 🔒 유료
      energyLevel: fortuneData.energyLevel || 5, // ✅ 무료: 공개
      timeFrame: isBlurred ? '🔒 프리미엄 전용' : (fortuneData.timeFrame || '가까운 미래'), // 🔒 유료
      advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.advice, // 🔒 유료
      luckyElement: isBlurred ? '🔒' : (fortuneData.luckyElement || '공기'), // 🔒 유료
      focusAreas: isBlurred ? ['🔒 프리미엄 전용'] : (fortuneData.focusAreas || []), // 🔒 유료
      timestamp: new Date().toISOString(),
      isBlurred, // ✅ Blur 상태
      blurredSections, // ✅ Blur 처리된 섹션 목록
    }

    console.log(`[Tarot] Result generated - Blurred: ${isBlurred}, Sections: ${blurredSections.length}`)

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'tarot',
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
    console.error('Tarot Fortune API Error:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '타로 운세 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})