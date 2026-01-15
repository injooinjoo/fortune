/**
 * 꿈 해몽 (Dream Fortune) Edge Function
 *
 * @description 사용자가 꾼 꿈을 AI가 분석하여 심리학적/전통적 해석을 제공합니다.
 *
 * @endpoint POST /fortune-dream
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - dreamDescription: string - 꿈 내용 설명
 * - dreamEmotion?: string - 꿈에서 느낀 감정
 * - dreamTime?: string - 꿈을 꾼 시간대
 *
 * @response DreamInterpretationResponse
 * - symbols: DreamSymbol[] - 꿈에 등장한 상징들
 * - interpretation: string - 종합 해석
 * - psychologicalMeaning: string - 심리학적 의미
 * - traditionalMeaning: string - 전통적 해몽
 * - fortuneImplication: string - 길흉 예측
 * - advice: string - 조언
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-dream \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","dreamDescription":"하늘을 나는 꿈을 꿨습니다"}'
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractDreamCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// 꿈 분석 데이터 인터페이스
interface DreamSymbol {
  symbol: string
  category: string
  meaning: string
  psychologicalSignificance: string
  emotionalImpact: number // -5 to 5
}

interface DreamScene {
  sequence: number
  description: string
  emotionLevel: number // 1-10
  symbols: string[]
}

interface DreamAnalysis {
  mainTheme: string
  psychologicalInsight: string
  emotionalPattern: string
  symbolAnalysis: DreamSymbol[]
  scenes: DreamScene[]
  luckyElements: string[]
  warningElements: string[]
}

// 요청 인터페이스
interface DreamFortuneRequest {
  dream: string
  inputType?: 'text' | 'voice'
  date?: string
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
}

// 응답 인터페이스
interface DreamFortuneResponse {
  success: boolean
  data: {
    dream: string
    inputType: string
    date: string
    analysis: DreamAnalysis
    interpretation: string
    todayGuidance: string
    psychologicalState: string
    emotionalBalance: number // 1-10
    luckyKeywords: string[]
    avoidKeywords: string[]
    dreamType: string // prophetic, anxiety, wish-fulfillment, processing, symbolic
    significanceLevel: number // 1-10
    actionAdvice: string[]
    affirmations: string[]
    relatedSymbols: string[]
    timestamp: string
  }
  error?: string
}

// 꿈 카테고리 및 상징 매핑
const dreamSymbolsMap = {
  animals: {
    dog: { meaning: '충성심, 친구, 보호', emotional: 3, category: '관계' },
    cat: { meaning: '독립성, 직관, 신비', emotional: 2, category: '개성' },
    snake: { meaning: '변화, 치유, 지혜', emotional: -1, category: '변화' },
    bird: { meaning: '자유, 영감, 메시지', emotional: 4, category: '영적' },
    fish: { meaning: '무의식, 감정, 풍요', emotional: 2, category: '감정' },
    tiger: { meaning: '용기, 힘, 위험', emotional: 0, category: '도전' },
    rabbit: { meaning: '행운, 번식력, 기회', emotional: 4, category: '기회' }
  },
  nature: {
    water: { meaning: '감정, 정화, 흐름', emotional: 1, category: '감정' },
    fire: { meaning: '열정, 변화, 파괴', emotional: -2, category: '변화' },
    mountain: { meaning: '안정, 도전, 성취', emotional: 2, category: '성장' },
    ocean: { meaning: '무의식, 깊이, 광대함', emotional: 0, category: '영적' },
    forest: { meaning: '성장, 미지, 탐험', emotional: 1, category: '발전' },
    rain: { meaning: '정화, 슬픔, 새로운 시작', emotional: -1, category: '변화' },
    sun: { meaning: '에너지, 희망, 명확성', emotional: 5, category: '긍정' }
  },
  people: {
    family: { meaning: '안정, 책임, 유대감', emotional: 3, category: '관계' },
    friend: { meaning: '지지, 즐거움, 연결', emotional: 4, category: '관계' },
    stranger: { meaning: '미지, 기회, 두려움', emotional: -1, category: '변화' },
    celebrity: { meaning: '꿈, 성공, 인정', emotional: 3, category: '성취' },
    enemy: { meaning: '갈등, 도전, 성장', emotional: -3, category: '도전' }
  },
  places: {
    home: { meaning: '안전, 편안함, 개인성', emotional: 4, category: '안정' },
    school: { meaning: '학습, 성장, 평가', emotional: 0, category: '성장' },
    workplace: { meaning: '책임, 성취, 스트레스', emotional: -1, category: '도전' },
    hospital: { meaning: '치유, 건강, 관심', emotional: -2, category: '건강' },
    temple: { meaning: '영성, 평화, 지혜', emotional: 3, category: '영적' }
  },
  actions: {
    flying: { meaning: '자유, 해방, 성취', emotional: 5, category: '해방' },
    falling: { meaning: '불안, 통제상실, 변화', emotional: -4, category: '불안' },
    running: { meaning: '도피, 추구, 에너지', emotional: -2, category: '행동' },
    swimming: { meaning: '감정탐험, 적응, 흐름', emotional: 2, category: '적응' },
    climbing: { meaning: '노력, 성취, 도전', emotional: 3, category: '성장' }
  },
  objects: {
    money: { meaning: '가치, 힘, 안정', emotional: 3, category: '물질' },
    food: { meaning: '영양, 만족, 기본욕구', emotional: 2, category: '기본' },
    car: { meaning: '통제, 방향성, 진보', emotional: 1, category: '진행' },
    phone: { meaning: '소통, 연결, 정보', emotional: 0, category: '소통' },
    mirror: { meaning: '자아성찰, 진실, 인식', emotional: 0, category: '성찰' }
  }
}

// 꿈의 유형 분류
const dreamTypes = {
  prophetic: { name: '예지몽', description: '미래에 대한 통찰이 담긴 꿈' },
  anxiety: { name: '불안몽', description: '내면의 두려움이나 걱정을 반영하는 꿈' },
  'wish-fulfillment': { name: '소망충족몽', description: '바라는 것들이 실현되는 꿈' },
  processing: { name: '처리몽', description: '일상 경험을 정리하고 처리하는 꿈' },
  symbolic: { name: '상징몽', description: '깊은 무의식의 메시지가 담긴 꿈' }
}

// 꿈 분석 함수
function analyzeDreamContent(dreamText: string): DreamAnalysis {
  const words = dreamText.toLowerCase()
  const symbols: DreamSymbol[] = []
  const scenes: DreamScene[] = []
  let emotionalSum = 0
  let symbolCount = 0

  // 문장별로 나누어 장면 분석
  const sentences = dreamText.split(/[.!?]/).filter(s => s.trim().length > 0)

  sentences.forEach((sentence, index) => {
    const sceneSymbols: string[] = []
    let sceneEmotion = 5 // 중립

    // 각 카테고리별로 상징 찾기
    Object.entries(dreamSymbolsMap).forEach(([category, categorySymbols]) => {
      Object.entries(categorySymbols).forEach(([symbol, data]) => {
        if (words.includes(symbol) || words.includes(data.meaning.split(',')[0].trim())) {
          symbols.push({
            symbol,
            category: data.category,
            meaning: data.meaning,
            psychologicalSignificance: `${symbol}은(는) ${data.category} 영역에서 중요한 의미를 가집니다.`,
            emotionalImpact: data.emotional
          })
          sceneSymbols.push(symbol)
          sceneEmotion += data.emotional
          emotionalSum += data.emotional
          symbolCount++
        }
      })
    })

    if (sentence.trim()) {
      scenes.push({
        sequence: index + 1,
        description: sentence.trim(),
        emotionLevel: Math.max(1, Math.min(10, Math.round(sceneEmotion))),
        symbols: sceneSymbols
      })
    }
  })

  // 전체 감정 균형 계산
  const averageEmotion = symbolCount > 0 ? emotionalSum / symbolCount : 0

  // 주요 테마 결정
  const categoryFreq: { [key: string]: number } = {}
  symbols.forEach(symbol => {
    categoryFreq[symbol.category] = (categoryFreq[symbol.category] || 0) + 1
  })

  const mainCategory = Object.entries(categoryFreq).sort((a, b) => b[1] - a[1])[0]
  const mainTheme = mainCategory ? mainCategory[0] : '성장'

  // 긍정적/부정적 요소 분리
  const luckyElements = symbols
    .filter(s => s.emotionalImpact > 0)
    .map(s => `${s.symbol}: ${s.meaning}`)

  const warningElements = symbols
    .filter(s => s.emotionalImpact < -1)
    .map(s => `${s.symbol}: ${s.meaning}`)

  return {
    mainTheme,
    psychologicalInsight: generatePsychologicalInsight(symbols, averageEmotion),
    emotionalPattern: generateEmotionalPattern(scenes),
    symbolAnalysis: symbols,
    scenes,
    luckyElements,
    warningElements
  }
}

function generatePsychologicalInsight(symbols: DreamSymbol[], emotionalBalance: number): string {
  const dominantCategories = symbols.reduce((acc, symbol) => {
    acc[symbol.category] = (acc[symbol.category] || 0) + 1
    return acc
  }, {} as { [key: string]: number })

  const topCategory = Object.entries(dominantCategories).sort((a, b) => b[1] - a[1])[0]

  if (!topCategory) {
    return '현재 내면의 평온함과 안정을 추구하고 있는 시기입니다.'
  }

  const categoryInsights: { [key: string]: string } = {
    '관계': '대인관계에 대한 깊은 관심과 연결에 대한 욕구가 강합니다.',
    '성장': '개인적 발전과 새로운 도전에 대한 의지가 활발합니다.',
    '변화': '인생의 전환점에 서 있으며, 변화에 대한 준비가 필요합니다.',
    '도전': '현재 직면한 어려움을 극복하려는 의지가 강합니다.',
    '안정': '안전함과 확실성에 대한 욕구가 높은 상태입니다.',
    '영적': '내면의 성찰과 영적 성장에 관심이 증가하고 있습니다.'
  }

  let insight = categoryInsights[topCategory[0]] || '균형잡힌 심리 상태를 유지하고 있습니다.'

  if (emotionalBalance > 2) {
    insight += ' 전반적으로 긍정적인 에너지가 충만한 시기입니다.'
  } else if (emotionalBalance < -1) {
    insight += ' 다소 불안하거나 스트레스를 받는 상황일 수 있으니 휴식이 필요합니다.'
  }

  return insight
}

function generateEmotionalPattern(scenes: DreamScene[]): string {
  if (scenes.length === 0) return '안정적인 감정 상태'

  const emotions = scenes.map(s => s.emotionLevel)
  const avgEmotion = emotions.reduce((a, b) => a + b, 0) / emotions.length

  const trend = emotions.length > 1 ?
    emotions[emotions.length - 1] - emotions[0] : 0

  let pattern = ''

  if (avgEmotion > 7) {
    pattern = '전체적으로 긍정적이고 활기찬 감정'
  } else if (avgEmotion < 4) {
    pattern = '다소 우울하거나 불안한 감정'
  } else {
    pattern = '균형잡힌 중립적 감정'
  }

  if (trend > 2) {
    pattern += ', 점차 밝아지는 방향으로 발전'
  } else if (trend < -2) {
    pattern += ', 다소 침체되는 경향'
  }

  return pattern
}

// 꿈 타입 분류
function classifyDreamType(analysis: DreamAnalysis): string {
  // 안전성 체크
  if (!analysis || !analysis.symbolAnalysis || !Array.isArray(analysis.symbolAnalysis)) {
    return 'symbolic'
  }

  // 불안 요소가 많으면 anxiety
  if (analysis.warningElements?.length > analysis.luckyElements?.length) {
    return 'anxiety'
  }

  // 미래지향적 상징이 많으면 prophetic
  if (analysis.symbolAnalysis.some(s => ['길', 'road', '여행', 'travel', '문', 'door'].includes(s.symbol))) {
    return 'prophetic'
  }

  // 긍정적 성취 상징이 많으면 wish-fulfillment
  if (analysis.luckyElements?.length > 2) {
    return 'wish-fulfillment'
  }

  // 일상적 장면이 많으면 processing
  if (analysis.scenes?.some(s => s.description.includes('집') || s.description.includes('직장') || s.description.includes('학교'))) {
    return 'processing'
  }

  return 'symbolic'
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
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
    // ✅ 요청 헤더 로깅
    console.log('🔍 [Headers] Content-Type:', req.headers.get('content-type'))
    console.log('🔍 [Headers] Authorization:', req.headers.get('authorization')?.substring(0, 20) + '...')

    // ✅ UTF-8 수동 디코딩 (Deno Latin1 버그 우회)
    console.log('🔍 [Step 0] Reading request body as text...')
    const bodyText = await req.text()
    console.log('🔍 [Step 0] Body text length:', bodyText.length)
    console.log('🔍 [Step 0] Body text content:', bodyText)

    // 요청 데이터 파싱
    console.log('🔍 [Step 1] Parsing JSON...')
    const requestData: DreamFortuneRequest = JSON.parse(bodyText)
    const { dream, inputType = 'text', date, isPremium = false } = requestData

    console.log('🔍 [Step 1] Request received:', { dream: dream?.substring(0, 50), dreamLength: dream?.length, inputType, isPremium })

    if (!dream || dream.trim().length === 0) {
      throw new Error('꿈 내용을 입력해주세요.')
    }

    console.log('🔍 [Step 2] Request validated')

    // 기본 꿈 분석 수행
    console.log('🔍 [Step 3] Starting dream analysis')
    const analysis = analyzeDreamContent(dream)
    console.log('🔍 [Step 4] Analysis complete:', { symbolCount: analysis.symbolAnalysis.length })

    const dreamType = classifyDreamType(analysis)
    console.log('🔍 [Step 5] Dream type classified:', dreamType)

    // ✅ Cohort Pool 조회 (캐시보다 먼저 확인 - 비용 최적화)
    const cohortData = extractDreamCohort({
      dream,
      dreamCategory: dreamType,
      emotion: (requestData as any).dreamEmotion || 'neutral',
      birthDate: (requestData as any).birthDate || null,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log('🔍 [Step 5.1] Checking cohort pool:', { cohortHash, cohortData })

    const cohortResult = await getFromCohortPool(supabase, 'dream', cohortHash)
    if (cohortResult) {
      console.log('✅ [Step 5.2] Cohort pool hit! Personalizing result...')

      // 개인화 데이터 준비
      const personalData = {
        userName: (requestData as any).userName || (requestData as any).name || '회원님',
        dreamContent: dream,
        specificSymbols: analysis.symbolAnalysis.map(s => s.symbol).join(', '),
      }

      // 템플릿 개인화
      const personalizedResult = personalize(cohortResult, personalData) as any

      // 분석 데이터 병합
      personalizedResult.analysis = {
        ...personalizedResult.analysis,
        symbolAnalysis: analysis.symbolAnalysis,
        scenes: analysis.scenes,
        luckyElements: analysis.luckyElements,
        warningElements: analysis.warningElements,
      }

      // 퍼센타일 계산
      const percentileData = await calculatePercentile(supabase, 'dream', personalizedResult.score || 75)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      // Blur 로직 적용
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['psychologicalInsight', 'todayGuidance', 'symbolAnalysis', 'actionAdvice']
        : []

      const finalResult = {
        ...resultWithPercentile,
        dream,
        inputType,
        date: date || new Date().toISOString().split('T')[0],
        dreamType,
        isBlurred,
        blurredSections,
        timestamp: new Date().toISOString(),
      }

      console.log('✅ [Step 5.3] Returning cohort result')
      return new Response(JSON.stringify({ success: true, data: finalResult }), {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      })
    }
    console.log('🔄 [Step 5.2] Cohort pool miss, checking cache...')

    // 캐시 확인 (✅ UTF-8 안전 해시 생성)
    const encoder = new TextEncoder()
    const data = encoder.encode(dream + dreamType)
    const hashBuffer = await crypto.subtle.digest('SHA-256', data)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
    const cacheKey = `dream_fortune_${hashHex.slice(0, 50)}`
    console.log('🔍 [Step 6] Checking cache:', cacheKey)

    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('✅ [Step 7] Cache hit for dream fortune')
      fortuneData = cachedResult.result

      // ✅ Blur 로직 적용 (캐시된 데이터에도 적용)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['psychologicalInsight', 'todayGuidance', 'symbolAnalysis', 'actionAdvice']
        : []

      fortuneData = {
        ...fortuneData,
        isBlurred,
        blurredSections
      }

      console.log('✅ [Step 7.1] Blur logic applied to cached result:', { isPremium, isBlurred })
    } else {
      console.log('🔄 [Step 7] Cache miss, calling LLM API')

      // 고품질 프롬프트 생성
      const prompt = `당신은 꿈의 세계를 탐험하는 친근한 가이드예요! 🌙✨
심리학의 지혜를 바탕으로, 마치 좋은 친구가 조언해주듯 따뜻하고 흥미롭게 꿈을 해석해드려요.

## 스타일 가이드 💭
- 전문적인 내용이지만 딱딱하지 않게! 친구처럼 편하게 설명
- "~해요", "~거예요" 같은 친근한 말투 사용
- 심리학 용어는 쉽게 풀어서 설명 (예: "그림자" → "마음 한켠에 숨겨둔 감정")
- 이모지는 포인트에만 센스있게 🌟💫🦋
- 무서운 꿈도 긍정적인 메시지로 연결해주기

## 톤 예시
❌ "이 꿈은 무의식적 억압을 상징합니다"
✅ "이 꿈은 마음속에 꾹꾹 눌러둔 감정이 '나 좀 봐줘!' 하고 손 흔드는 거예요 👋"

❌ "융의 그림자 원형이 투사된 것입니다"
✅ "내 안의 숨겨진 또 다른 나가 꿈에서 얼굴을 내민 거예요. 무섭지만 사실 친해지면 좋은 친구가 될 수 있어요! 🤝"

🚨 [최우선 규칙] 모든 응답은 반드시 한국어로 작성하세요!
- JSON 키: 반드시 한국어 (종합해석, 오늘의지침, 심리적상태 등)
- JSON 값: 반드시 한국어 문장
- 영어 키(interpretation, guidance 등) 절대 사용 금지
- 영어 문장 절대 사용 금지

# 꿈 정보
- 꿈 내용: "${dream}"
- 꿈 유형: ${dreamTypes[dreamType as keyof typeof dreamTypes]?.name} (${dreamTypes[dreamType as keyof typeof dreamTypes]?.description})
- 입력 방식: ${inputType === 'voice' ? '음성으로 생생하게 전달' : '텍스트로 기록'}

# 해몽 작성 가이드

## 1. 종합해석 (100자 이내, 필수)
- 꿈의 핵심 메시지를 친구에게 설명하듯 1-2문장으로!
- "이 꿈은..." 또는 "당신의 마음이..."로 시작
- 심리학 배경은 유지하되 쉽고 재밌게 풀어쓰기
- 예시: "이 꿈은 당신 마음속에서 '나 좀 변하고 싶어!' 하는 목소리가 터져나온 거예요 🦋 귀신이 많이 나왔다는 건, 그동안 꾹꾹 눌러뒀던 감정들이 이제 터질 것 같다는 신호! 무섭게 느껴졌을 수 있지만, 사실 이건 좋은 징조예요. 왜냐면 '이 감정들을 이제 좀 들여다볼 준비가 됐다'는 뜻이거든요 ✨"

## 2. 오늘의지침 (80자 이내, 필수)
- 꿈을 바탕으로 한 오늘 하루 꿀팁!
- "오늘은..." 또는 "이 꿈이 말하는..."으로 시작
- 구체적이고 바로 실천할 수 있는 행동 제안
- 예시: "오늘은 감정 꾹꾹 참지 말고 좀 풀어보는 날이에요! 🌿 오전에 10분만 산책하면서 머리 비우고, 점심 먹고 친한 친구한테 카톡 한 통 보내보세요. '요즘 좀 힘들었어~' 한마디면 돼요! 부정적인 감정이 올라와도 '그래, 이것도 나야' 하고 토닥토닥 🫶 저녁엔 따뜻한 차 한 잔 마시면서 오늘 하루 칭찬해주기!"

## 3. 심리적상태 (80자 이내, 필수)
- 지금 마음 상태를 친구처럼 따뜻하게 읽어주기
- 심리학 용어는 쉽게 풀어서! (그림자 → 숨겨둔 나, 무의식 → 마음 깊은 곳)
- 힘든 상태라도 "괜찮아, 이건 성장하고 있다는 증거야!" 메시지로 연결
- 예시: "지금 당신 마음은 좀 과부하 걸린 상태인 것 같아요 💭 귀신이 많이 나온 건, 그동안 '나중에 생각하자~' 하고 미뤄뒀던 감정들이 잔뜩 쌓여있다는 뜻이에요. 심리학에서 귀신은 '내가 외면하고 싶은 나의 모습'을 의미해요. 근데 이거 사실 나쁜 게 아니에요! 이런 꿈을 꿨다는 건 '이제 그 감정들 좀 봐줄 준비가 됐다'는 마음의 신호거든요 🌟"

## 4. 행동조언 (3개 필수, 각 50자 이상)
- 오늘 당장 할 수 있는 구체적인 행동 3가지!
- "~해보세요!", "~추천해요" 같은 친근한 권유 형식
- 너무 거창하지 않게, 일상에서 쉽게 실천할 수 있는 것들
- 예시:
  ["📝 감정 일기 5분 쓰기: 오늘 자기 전에 딱 5분만! '오늘 짜증났음', '뭔가 불안했음' 이렇게 짧게 적어도 돼요. 감정에 이름 붙이는 것만으로도 마음이 한결 가벼워져요!",
   "🧘 숨 고르기 10분: 유튜브에서 '마음챙김 명상' 검색해서 하나 틀어놓고 따라해보세요. 안 좋은 생각이 떠올라도 '아 그런 생각이 있구나~' 하고 그냥 흘려보내면 돼요!",
   "📱 친한 친구한테 연락하기: 카톡이든 전화든 좋아요! '요즘 좀 힘들었어'라고 말하는 것만으로도 마음이 훨씬 가벼워질 거예요 🤗"]

## 5. 긍정확언 (3개 필수, 각 20자 이상)
- 아침에 거울 보면서 말할 수 있는 짧고 힘 나는 문장!
- "나는..." 형식으로, 읽으면 기분 좋아지는 말
- 현실적이면서도 희망적인 톤으로
- 예시:
  ["나는 모든 감정을 그냥 느껴도 괜찮아. 그게 나를 더 단단하게 만들어 주니까! 💪",
   "내 마음은 스스로 회복하는 힘이 있어. 나는 그 과정을 믿어 🌱",
   "어두웠던 시간도 지나가고 있어. 나는 매일 조금씩 밝은 쪽으로 가고 있어 ✨"]

## 6. 연관상징 (3-5개, 각 상징별 해석 필수)
- 꿈에 나온 것들이 무슨 뜻인지 쉽게 풀이!
- 각 상징: 친근하게 설명 (50자 내외)
- 예시:
  ["👻 귀신: 마음속에 숨겨둔 감정이에요. '나 좀 봐줘!' 하고 나타난 거죠",
   "📦 많이 나타남: 미뤄둔 감정이 잔뜩 쌓여있다는 신호! 정리할 때가 됐어요",
   "🌙 밤 / 어둠: 의식 아래 깊은 곳, 평소엔 안 보이는 마음의 창고 같은 곳",
   "😰 두려움: 변화가 무섭긴 하죠. 근데 이건 성장의 시작이기도 해요!"]

# 작성 스타일 📝
- 친구가 얘기해주듯 따뜻하고 공감하는 톤!
- "~거예요", "~해요" 같은 친근한 말투
- 무서운 꿈이라도 "이건 사실 좋은 신호야!" 같은 희망적 메시지로 연결
- 미신적 예언(복권 당첨, 금전운, 로또 번호 등) 절대 금지!
- 심리학 용어는 쉽게 풀어서 (무의식 → 마음 깊은 곳, 그림자 → 숨겨둔 감정)

# 응답 형식 (JSON)
{
  "종합해석": "100자 이내의 핵심 해석...",
  "오늘의지침": "80자 이내의 핵심 조언...",
  "심리적상태": "80자 이내의 내면 분석...",
  "행동조언": ["조언1 (50자+)", "조언2 (50자+)", "조언3 (50자+)"],
  "긍정확언": ["확언1", "확언2", "확언3"],
  "연관상징": ["상징1: 해석", "상징2: 해석", "상징3: 해석"]
}

위 가이드를 따라, 친구에게 따뜻하게 조언해주듯 해몽을 작성해주세요! 💭✨`

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      console.log('🔄 [Step 8] Calling LLM API for dream interpretation')
      const llm = await LLMFactory.createFromConfigAsync('dream')

      const llmResponse = await llm.generate([
        {
          role: 'system',
          content: `당신은 꿈의 세계를 안내하는 친근한 가이드예요! 🌙
심리학 지식을 바탕으로, 친한 친구처럼 따뜻하게 꿈 이야기를 들려줘요.

# 전문 배경 (참고용, 직접 언급하지 않아도 됨)
- 심리학의 지혜를 쉽게 풀어서 전달
- 무의식, 그림자 같은 개념을 일상 언어로 설명
- 무서운 꿈도 희망적 메시지로 연결

# 말투 가이드 ✨
1. 친근하게: "~거예요", "~해요" 같은 편한 말투
2. 공감하며: "그랬구나~", "힘들었겠다" 같은 공감 표현
3. 희망적으로: 어떤 꿈이든 성장과 연결해서 해석
4. 구체적으로: 오늘 바로 할 수 있는 행동 제안
5. 금지: 복권 당첨, 금전운, 로또 번호 같은 미신적 예언

# 응답 형식
반드시 JSON 형식으로, 예시처럼 따뜻하고 재밌게 작성해주세요!`
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 0.9, // 창의성 약간 낮춤 (일관성 향상)
        maxTokens: 3500, // 토큰 대폭 증가 (고품질 장문 응답)
        jsonMode: true
      })

      console.log('✅ [Step 9] LLM response received:', { provider: llmResponse.provider, model: llmResponse.model, latency: `${llmResponse.latency}ms` })

      // ✅ LLM 사용량 로깅 (비용/성능 분석용)
      await UsageLogger.log({
        fortuneType: 'dream',
        provider: llmResponse.provider,
        model: llmResponse.model,
        response: llmResponse,
        metadata: { dreamLength: dream.length, dreamType, inputType, isPremium }
      })

      const parsedResponse = JSON.parse(llmResponse.content)
      console.log('✅ [Step 10] Response parsed successfully')

      // 응답 데이터 구조화
      console.log('🔄 [Step 13] Building fortune data structure')
      // ✅ Blur 로직 적용 (DreamResultWidget의 sectionKey와 일치)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['psychologicalInsight', 'todayGuidance', 'symbolAnalysis', 'actionAdvice']
        : []

      console.log('🔍 [Step 13.1] Blur logic:', { isPremium, isBlurred, blurredSections })

      // 점수 계산 (emotionalBalance 기반, 1-10 → 0-100 스케일)
      const emotionalBalanceScore = Math.round((analysis.scenes.reduce((sum, scene) => sum + scene.emotionLevel, 0) / Math.max(analysis.scenes.length, 1)))
      const dreamScore = Math.min(100, Math.max(0, emotionalBalanceScore * 10))
      const interpretationText = parsedResponse.종합해석 || parsedResponse.interpretation || '꿈의 메시지를 해석하였습니다.'

      fortuneData = {
        // ✅ 표준화된 필드명: score, content, summary, advice
        fortuneType: 'dream',
        score: dreamScore,
        content: interpretationText,
        summary: parsedResponse.오늘의지침?.substring(0, 50) || '꿈이 전하는 메시지를 확인하세요',
        advice: parsedResponse.행동조언?.[0] || '오늘은 긍정적인 마음가짐을 유지하세요',
        // 기존 필드 유지 (하위 호환성)
        dream,
        inputType,
        date: date || new Date().toISOString(),
        dreamType,
        interpretation: interpretationText, // ✅ 무료: 공개
        analysis, // ✅ 서버는 모든 데이터 반환, 블러는 Flutter UI에서 처리
        todayGuidance: parsedResponse.오늘의지침 || parsedResponse.todayGuidance || '오늘 하루를 긍정적으로 보내세요.',
        psychologicalState: parsedResponse.심리적상태 || parsedResponse.psychologicalState || analysis.psychologicalInsight,
        emotionalBalance: Math.round((analysis.scenes.reduce((sum, scene) => sum + scene.emotionLevel, 0) / Math.max(analysis.scenes.length, 1))),
        luckyKeywords: analysis.luckyElements.slice(0, 5),
        avoidKeywords: analysis.warningElements.slice(0, 3),
        significanceLevel: Math.min(10, Math.max(1, analysis.symbolAnalysis.length + (analysis.luckyElements.length * 2))),
        actionAdvice: parsedResponse.행동조언 || parsedResponse.actionAdvice || ['오늘은 긍정적인 마음가짐을 유지하세요', '직감을 믿고 중요한 결정을 내려보세요', '주변 사람들과 좋은 관계를 유지하세요'],
        affirmations: parsedResponse.긍정확언 || parsedResponse.affirmations || ['나는 항상 올바른 선택을 할 수 있다', '내 직감은 나를 올바른 길로 안내한다', '나는 내면의 지혜를 믿는다'],
        relatedSymbols: analysis.symbolAnalysis.slice(0, 7).map(s => s.symbol),
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태 (Flutter UI에서 사용)
        blurredSections // ✅ 블러된 섹션 목록 (Flutter UI에서 사용)
      }

      console.log('✅ [Step 14] Fortune data structure complete')

      // 결과 캐싱
      console.log('🔄 [Step 15] Caching result')
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'dream',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })
      console.log('✅ [Step 16] Result cached')

      // ✅ Cohort Pool에 저장 (비동기, fire-and-forget)
      saveToCohortPool(supabase, 'dream', cohortHash, cohortData, fortuneData)
        .catch(e => console.error('[Dream] Cohort 저장 오류:', e))
    }

    // ✅ 퍼센타일 계산 (표준 score 필드 사용)
    const percentileData = await calculatePercentile(supabase, 'dream', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    // 성공 응답
    console.log('🔄 [Step 17] Building success response')
    const response: DreamFortuneResponse = {
      success: true,
      data: fortuneDataWithPercentile
    }

    console.log('✅ [Step 18] Sending response')
    return new Response(JSON.stringify(response), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Dream Fortune Error:', error)

    const errorResponse: DreamFortuneResponse = {
      success: false,
      data: {} as any,
      error: error instanceof Error ? error.message : '꿈 해몽 중 오류가 발생했습니다.'
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})