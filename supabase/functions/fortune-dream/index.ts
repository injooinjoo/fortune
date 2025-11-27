import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

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
      const prompt = `당신은 심리학 박사이자 20년 경력의 전문 꿈 해몽가입니다. 융(Jung)의 분석심리학과 현대 심리학을 기반으로 깊이 있는 해석을 제공합니다.

# 꿈 정보
- 꿈 내용: "${dream}"
- 꿈 유형: ${dreamTypes[dreamType as keyof typeof dreamTypes]?.name} (${dreamTypes[dreamType as keyof typeof dreamTypes]?.description})
- 입력 방식: ${inputType === 'voice' ? '음성으로 생생하게 전달' : '텍스트로 기록'}

# 해몽 작성 가이드

## 1. 종합해석 (최소 200자 이상, 필수)
- 꿈의 핵심 메시지를 3-4문장으로 깊이 있게 해석
- "이 꿈은..." 또는 "당신의 무의식은..."으로 시작
- 심리학적 근거를 포함하되 자연스럽게 풀어쓰기
- 예시: "이 꿈은 당신의 내면에서 변화를 갈망하는 목소리가 들리고 있음을 의미합니다. 귀신은 무의식 속 억압된 감정의 상징이며, '많이 나타난다'는 표현은 현재 정서적으로 처리하지 못한 감정들이 축적되어 있다는 신호입니다. 이는 과거의 미해결 과제나 현재의 스트레스가 당신의 정신적 평온을 방해하고 있다는 뜻입니다. 하지만 귀신을 '인지'했다는 것 자체가 문제를 직시할 준비가 되었다는 긍정적 신호이기도 합니다."

## 2. 오늘의지침 (최소 150자 이상, 필수)
- 꿈을 바탕으로 한 구체적이고 실행 가능한 조언
- "오늘은..." 또는 "이 꿈이 말하는..."으로 시작
- 시간대별 또는 상황별 행동 지침 포함
- 예시: "오늘은 감정을 억누르기보다는 건강하게 표현하는 시간을 가져보세요. 오전에는 짧은 명상이나 산책으로 마음을 정리하고, 오후에는 신뢰하는 사람과 대화를 나누거나 일기를 쓰며 내면의 목소리에 귀 기울여 보세요. 특히 부정적 감정이 올라올 때 회피하지 말고 '이런 감정도 나의 일부'라고 인정하는 연습이 필요합니다. 저녁에는 따뜻한 차 한 잔과 함께 조용히 하루를 돌아보는 시간을 가지세요."

## 3. 심리적상태 (최소 180자 이상, 필수)
- 현재 꿈꾼이의 내면 상태를 3-4문장으로 깊이 분석
- 융의 그림자 개념, 프로이트의 무의식 이론 등 심리학적 관점 활용
- 부정적 상태라도 성장 가능성과 연결
- 예시: "현재 당신의 무의식은 정서적으로 과부하 상태입니다. 귀신이 많이 나타나는 꿈은 억압된 감정, 처리되지 않은 트라우마, 또는 회피하고 싶은 현실이 잠재의식에 쌓여있다는 신호입니다. 융 심리학에서 귀신은 '그림자(Shadow)' 원형으로, 당신이 인정하고 싶지 않은 자아의 어두운 면이나 외면하고 있는 감정을 상징합니다. 하지만 이는 병리적 상태가 아니라 자기 통합(Individuation)의 과정에서 나타나는 자연스러운 현상입니다. 이 꿈은 당신에게 '이제 이 감정들을 직면할 때'라는 내면의 메시지입니다."

## 4. 행동조언 (3개 필수, 각 50자 이상)
- 즉시 실행 가능한 구체적 행동 3가지
- "~해보세요", "~하는 시간을 가져보세요" 형식
- 심리적 케어, 관계 개선, 환경 변화 등 다각도 제안
- 예시:
  ["감정 일기 쓰기: 매일 저녁 5분간 오늘 느낀 감정을 솔직하게 기록하세요. '화났다', '불안했다'처럼 감정을 명확히 명명하는 것만으로도 정서 조절에 큰 도움이 됩니다.",
   "마음챙김 명상: 하루 10분, 호흡에 집중하며 떠오르는 생각을 판단 없이 관찰하세요. 귀신처럼 떠오르는 부정적 생각도 '아, 이런 생각이 있구나' 하고 흘려보내는 연습이 필요합니다.",
   "신뢰하는 사람과 대화: 가까운 친구나 가족, 또는 전문 상담사와 최근의 스트레스나 불안을 나누세요. 말로 표현하는 것만으로도 억압된 감정이 해소됩니다."]

## 5. 긍정확언 (3개 필수, 각 20자 이상)
- 자기 암시 형태의 짧고 강력한 문장
- "나는..." 또는 "나의..." 형식
- 감정 인정 → 변화 의지 → 미래 비전 순서
- 예시:
  ["나는 모든 감정을 있는 그대로 받아들이며, 그것이 나를 더 강하게 만든다.",
   "나의 내면은 스스로 치유할 힘이 있으며, 나는 그 과정을 신뢰한다.",
   "나는 과거의 그림자에서 벗어나 밝은 미래를 향해 한 걸음씩 나아간다."]

## 6. 연관상징 (3-5개, 각 상징별 해석 필수)
- 꿈에 등장한 핵심 상징들과 심리학적 의미
- 각 상징: 간단한 해석 (50자 내외)
- 예시:
  ["귀신: 무의식의 그림자, 억압된 감정과 직면하지 않은 내면의 목소리",
   "많이 나타남: 정서적 과부하, 처리되지 않은 감정의 축적 상태",
   "밤 / 어둠: 무의식의 영역, 자아가 통제하지 못하는 잠재의식의 세계",
   "두려움: 변화에 대한 저항, 하지만 동시에 성장의 시작점"]

# 작성 스타일
- 전문적이되 따뜻하고 공감적인 톤 유지
- "~것 같습니다" 보다 "~니다" 형식의 확신 있는 표현
- 부정적 내용도 성장 가능성과 연결
- 미신적 예언(복권 당첨, 금전운 등) 절대 금지
- 심리학 용어는 자연스럽게 풀어쓰기

# 응답 형식 (JSON)
{
  "종합해석": "200자 이상의 깊이 있는 해석...",
  "오늘의지침": "150자 이상의 구체적 실행 조언...",
  "심리적상태": "180자 이상의 내면 분석...",
  "행동조언": ["조언1 (50자+)", "조언2 (50자+)", "조언3 (50자+)"],
  "긍정확언": ["확언1", "확언2", "확언3"],
  "연관상징": ["상징1: 해석", "상징2: 해석", "상징3: 해석"]
}

위 가이드를 철저히 따라 전문적이고 풍부한 해몽을 작성해주세요.`

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      console.log('🔄 [Step 8] Calling LLM API for dream interpretation')
      const llm = await LLMFactory.createFromConfigAsync('dream')

      const llmResponse = await llm.generate([
        {
          role: 'system',
          content: `당신은 융(Carl Jung) 심리학을 전공한 꿈 해몽 전문가입니다.

# 전문성 기반
- 융의 분석심리학 (집단무의식, 원형, 그림자 이론)
- 프로이트 정신분석학 (무의식, 억압, 꿈의 상징)
- 현대 인지심리학 및 신경과학
- 20년간 5만 건 이상의 꿈 해석 경험

# 작성 원칙
1. 깊이: 각 섹션은 최소 글자수를 반드시 준수 (종합해석 200자+, 심리적상태 180자+, 오늘의지침 150자+)
2. 구체성: "~할 수 있습니다" 대신 "~합니다" 확신 있는 톤
3. 심리학적 근거: 자연스럽게 심리학 이론 녹여내기
4. 공감적 톤: 판단하지 않고 이해하는 자세
5. 실행 가능성: 추상적 조언이 아닌 구체적 행동 제시
6. 금지사항: 미신적 예언, 금전운, 복권 당첨 등 언급 금지

# 응답 형식
반드시 JSON 형식으로 응답하며, 예시를 참고하여 풍부하고 전문적인 내용을 작성하세요.`
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

      fortuneData = {
        dream,
        inputType,
        date: date || new Date().toISOString(),
        dreamType,
        interpretation: parsedResponse.종합해석 || parsedResponse.interpretation || '꿈의 메시지를 해석하였습니다.', // ✅ 무료: 공개
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
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'dream', fortuneData.emotionalBalance * 10) // 1-10 → 10-100 변환
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