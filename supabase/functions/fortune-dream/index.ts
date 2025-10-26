import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

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
  // 불안 요소가 많으면 anxiety
  if (analysis.warningElements.length > analysis.luckyElements.length) {
    return 'anxiety'
  }

  // 미래지향적 상징이 많으면 prophetic
  if (analysis.symbols.some(s => ['길', 'road', '여행', 'travel', '문', 'door'].includes(s.symbol))) {
    return 'prophetic'
  }

  // 긍정적 성취 상징이 많으면 wish-fulfillment
  if (analysis.luckyElements.length > 2) {
    return 'wish-fulfillment'
  }

  // 일상적 장면이 많으면 processing
  if (analysis.scenes.some(s => s.description.includes('집') || s.description.includes('직장') || s.description.includes('학교'))) {
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
    // 요청 데이터 파싱
    const requestData: DreamFortuneRequest = await req.json()
    const { dream, inputType = 'text', date, isPremium = false } = requestData

    if (!dream || dream.trim().length === 0) {
      throw new Error('꿈 내용을 입력해주세요.')
    }

    console.log('Dream fortune request:', { dream: dream.substring(0, 100) + '...', inputType, isPremium })

    // 기본 꿈 분석 수행
    const analysis = analyzeDreamContent(dream)
    const dreamType = classifyDreamType(analysis)

    // 캐시 확인
    const cacheKey = `dream_fortune_${btoa(dream + dreamType).slice(0, 50)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for dream fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      // OpenAI API 호출을 위한 프롬프트 생성
      const prompt = `당신은 한국의 전문 꿈 해몽가입니다. 다음 꿈 내용을 분석하여 전문적이고 구체적인 해몽을 제공해주세요.

꿈 내용: "${dream}"
꿈의 유형: ${dreamTypes[dreamType as keyof typeof dreamTypes]?.name}
입력 방식: ${inputType === 'voice' ? '음성' : '텍스트'}

다음 정보를 포함하여 해몽해주세요:

1. 종합 해석: 이 꿈의 전체적인 의미와 메시지
2. 오늘의 지침: 이 꿈을 바탕으로 한 오늘 하루의 구체적인 조언
3. 심리적 상태: 현재 꿈꾼이의 내면 상태와 잠재의식의 메시지
4. 행동 조언: 구체적으로 실행할 수 있는 3가지 조언
5. 긍정 확언: 마음을 다잡을 수 있는 3가지 긍정 확언
6. 연관 상징: 꿈에서 주목해야 할 상징들과 그 의미

전문적이고 희망적이면서도 현실적인 조언을 제공해주세요. 미신적이거나 근거 없는 예언은 피하고, 심리학적 통찰과 실용적 지침에 중점을 둬주세요.`

      // ✅ LLM 모듈 사용
      const llm = LLMFactory.createFromConfig('dream')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 한국의 전문 꿈 해몽가이며, 심리학과 전통 해몽학을 바탕으로 따뜻하고 지혜로운 조언을 제공합니다. 항상 한국어로 응답하며, 희망적이고 건설적인 관점을 유지합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      if (!response.content) {
        throw new Error('LLM API 응답을 받을 수 없습니다.')
      }

      // JSON 파싱
      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('JSON parsing error:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // 응답 데이터 구조화
      // ✅ Blur 로직 적용
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['analysis', 'psychologicalState', 'emotionalBalance', 'luckyKeywords', 'avoidKeywords', 'significanceLevel', 'actionAdvice', 'affirmations', 'relatedSymbols', 'todayGuidance']
        : []

      fortuneData = {
        dream,
        inputType,
        date: date || new Date().toISOString(),
        dreamType,
        interpretation: parsedResponse.종합해석 || parsedResponse.interpretation || '꿈의 메시지를 해석하였습니다.', // ✅ 무료: 공개
        analysis: isBlurred ? {
          mainTheme: '🔒 프리미엄 전용',
          psychologicalInsight: '🔒 프리미엄 결제 후 확인 가능합니다',
          emotionalPattern: '🔒 프리미엄 전용',
          symbolAnalysis: [{ symbol: '🔒', category: '프리미엄', meaning: '프리미엄 결제 후 확인 가능', psychologicalSignificance: '🔒', emotionalImpact: 0 }],
          scenes: [{ sequence: 1, description: '🔒 프리미엄 결제 후 확인 가능합니다', emotionLevel: 0, symbols: ['🔒'] }],
          luckyElements: ['🔒 프리미엄 전용'],
          warningElements: ['🔒 프리미엄 전용']
        } : analysis, // 🔒 유료
        todayGuidance: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.오늘의지침 || parsedResponse.todayGuidance || '오늘 하루를 긍정적으로 보내세요.'), // 🔒 유료
        psychologicalState: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.심리적상태 || parsedResponse.psychologicalState || analysis.psychologicalInsight), // 🔒 유료
        emotionalBalance: isBlurred ? 0 : Math.round((analysis.scenes.reduce((sum, scene) => sum + scene.emotionLevel, 0) / Math.max(analysis.scenes.length, 1))), // 🔒 유료
        luckyKeywords: isBlurred ? ['🔒 프리미엄 전용'] : analysis.luckyElements.slice(0, 5), // 🔒 유료
        avoidKeywords: isBlurred ? ['🔒 프리미엄 전용'] : analysis.warningElements.slice(0, 3), // 🔒 유료
        significanceLevel: isBlurred ? 0 : Math.min(10, Math.max(1, analysis.symbolAnalysis.length + (analysis.luckyElements.length * 2))), // 🔒 유료
        actionAdvice: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.행동조언 || parsedResponse.actionAdvice || ['오늘은 긍정적인 마음가짐을 유지하세요', '직감을 믿고 중요한 결정을 내려보세요', '주변 사람들과 좋은 관계를 유지하세요']), // 🔒 유료
        affirmations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.긍정확언 || parsedResponse.affirmations || ['나는 항상 올바른 선택을 할 수 있다', '내 직감은 나를 올바른 길로 안내한다', '나는 내면의 지혜를 믿는다']), // 🔒 유료
        relatedSymbols: isBlurred ? ['🔒'] : analysis.symbolAnalysis.slice(0, 7).map(s => s.symbol), // 🔒 유료
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections // ✅ 블러된 섹션 목록
      }

      // 결과 캐싱
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'dream',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })
    }

    // 성공 응답
    const response: DreamFortuneResponse = {
      success: true,
      data: fortuneData
    }

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