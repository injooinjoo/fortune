/**
 * 투자 운세 (Investment Fortune) Edge Function
 *
 * @description 사주와 선택한 종목을 기반으로 투자 운세를 분석합니다.
 *
 * @endpoint POST /fortune-investment
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간
 * - gender: string - 성별
 * - tickers: TickerInfo[] - 분석할 종목 정보
 *   - symbol: string - 종목 코드 (BTC, AAPL, 005930)
 *   - name: string - 종목명
 *   - type: 'crypto' | 'stock_us' | 'stock_kr' - 종목 유형
 *
 * @response InvestmentFortuneResponse
 * - overall_score: number - 투자운 점수
 * - market_luck: { timing, risk_tolerance } - 시장 운
 * - ticker_analysis: Array<{ symbol, fortune_score, advice }> - 종목별 분석
 * - best_investment_time: string - 투자 최적 시기
 * - cautions: string[] - 투자 주의사항
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-investment \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","tickers":[{"symbol":"BTC","name":"비트코인","type":"crypto"}]}'
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 티커 정보 인터페이스
interface TickerInfo {
  symbol: string;      // BTC, AAPL, 005930 등
  name: string;        // 비트코인, 애플, 삼성전자 등
  category: string;    // crypto, usStock, krStock, etf, commodity, realEstate
  exchange?: string;   // BINANCE, NASDAQ, KRX 등
}

// v2: 간소화된 요청 (투자 프로필 제거)
interface InvestmentRequest {
  ticker: TickerInfo;
  userId?: string;
  isPremium?: boolean;
}

/**
 * C03: 재물운 이미지 프롬프트 생성 (한국 전통 스타일)
 *
 * 점수와 카테고리에 따라 한국 전통 재물 이미지 프롬프트를 생성합니다.
 * - 복주머니, 금괴, 동전, 엽전
 * - 한지 배경, 붓글씨 스타일
 * - 오방색 중 황색(노란색) 강조
 */
function generateWealthImagePrompt(score: number, categoryLabel: string): string {
  // 점수대별 재물 기운 수준
  const fortuneLevel = score >= 80 ? '대길' : score >= 60 ? '길' : score >= 40 ? '보통' : '소길';

  // 점수대별 주요 상징물
  const primarySymbols = score >= 80
    ? '황금 복주머니, 금괴 더미, 빛나는 금화'
    : score >= 60
    ? '붉은 복주머니, 은괴, 엽전 무더기'
    : score >= 40
    ? '전통 복주머니, 동전, 엽전'
    : '작은 복주머니, 동전 몇 닢';

  // 배경 요소 (점수에 따라)
  const backgroundElements = score >= 70
    ? '황금빛 구름, 상서로운 기운, 봉황 문양'
    : '은은한 안개, 전통 문양';

  // 카테고리별 추가 요소
  const categorySymbol = (() => {
    switch (categoryLabel) {
      case '암호화폐': return '디지털 금화와 전통 엽전의 조화';
      case '해외주식': return '글로벌 금화와 한국 전통 보물함';
      case '국내주식': return '조선시대 상평통보와 현대 주식 증서';
      case 'ETF': return '다양한 보물이 담긴 전통 함';
      case '원자재': return '금괴와 은괴가 쌓인 창고';
      case '부동산': return '기와집과 금으로 된 열쇠';
      default: return '전통 보물함과 금화';
    }
  })();

  return `Korean traditional wealth fortune illustration, ${fortuneLevel} level fortune:

Main elements: ${primarySymbols}
Category theme: ${categorySymbol}
Background: ${backgroundElements}

Style requirements:
- Traditional Korean hanji (한지) paper texture background
- Obangsaek (오방색) color palette with emphasis on yellow/gold (황색)
- Calligraphic brush stroke style elements
- Minhwa (민화) folk painting aesthetic
- Soft watercolor effect with gold leaf accents
- Auspicious symbols: 박쥐 (fortune bats), 구름 (clouds), 연꽃 (lotus)

Mood: ${score >= 70 ? 'Prosperous, abundant, golden glow' : 'Hopeful, steady, gentle warmth'}
Aspect ratio: 1:1, centered composition
No text, no characters, pure symbolic imagery`;
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

    const requestData: InvestmentRequest = await req.json()
    const { ticker, userId, isPremium = false } = requestData

    if (!ticker || !ticker.symbol || !ticker.name || !ticker.category) {
      throw new Error('ticker 정보가 필요합니다 (symbol, name, category)')
    }

    const { symbol: tickerSymbol, name: tickerName, category: tickerCategory, exchange: tickerExchange } = ticker

    // 카테고리 레이블 매핑
    const categoryLabels: Record<string, string> = {
      crypto: '암호화폐',
      krStock: '국내주식',
      usStock: '해외주식',
      etf: 'ETF',
      commodity: '원자재',
      realEstate: '부동산',
    }
    const categoryLabel = categoryLabels[tickerCategory] || '투자'

    console.log('💎 [Investment v2] Premium:', isPremium, '| Ticker:', tickerSymbol, tickerName, tickerCategory)

    // 캐시 확인 (간소화된 키 - 프로필 정보 없음)
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_investment_v2_${today}_${tickerSymbol}_${tickerCategory}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'investment')
      .single()

    if (cachedResult) {
      // 캐시된 결과도 블러 상태 업데이트
      const cachedFortune = { ...cachedResult.result }
      if (isPremium && cachedFortune.isBlurred) {
        cachedFortune.isBlurred = false
        cachedFortune.blurredSections = []
      }
      return new Response(
        JSON.stringify({
          fortune: cachedFortune,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // LLM 호출
    const llm = await LLMFactory.createFromConfigAsync('investment')

    const systemPrompt = `당신은 ${categoryLabel} 투자 운세 전문가입니다.
사용자가 선택한 종목(${tickerName})에 대해 투자자들이 가장 궁금해하는 정보를 운세 형식으로 제공합니다.

## 투자자들이 가장 궁금해하는 것 (리서치 기반)
1. 타이밍: 지금 살 때인가? 팔 때인가? 최적 시점은?
2. 전망: 단기/중기/장기 방향은?
3. 리스크: 주의해야 할 점은?
4. 시장 분위기: 다른 투자자들은 어떻게 생각하나?
5. 행운 요소: 좋은 기운을 받을 수 있는 요소

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 (오늘의 투자 운세 점수),
  "content": "핵심 운세 요약 (80자 내외, 오늘 이 종목에 대한 전체적인 기운)",

  "timing": {
    "buySignal": "strong" | "moderate" | "weak" | "avoid",
    "buySignalText": "매수 타이밍 설명 (50자 내외)",
    "bestTimeSlot": "morning" | "afternoon" | "evening",
    "bestTimeSlotText": "최적 시간대 설명 (30자 내외)",
    "holdAdvice": "홀딩/관망 조언 (40자 내외)"
  },

  "outlook": {
    "shortTerm": {
      "score": 0-100,
      "trend": "up" | "neutral" | "down",
      "text": "1주일 전망 (40자 내외)"
    },
    "midTerm": {
      "score": 0-100,
      "trend": "up" | "neutral" | "down",
      "text": "1개월 전망 (40자 내외)"
    },
    "longTerm": {
      "score": 0-100,
      "trend": "up" | "neutral" | "down",
      "text": "3개월+ 전망 (40자 내외)"
    }
  },

  "risks": {
    "warnings": ["주의사항 3가지 (각 30자 내외)"],
    "avoidActions": ["피해야 할 행동 2가지 (각 30자 내외)"],
    "volatilityLevel": "low" | "medium" | "high" | "extreme",
    "volatilityText": "변동성 설명 (30자 내외)"
  },

  "marketMood": {
    "categoryMood": "bullish" | "neutral" | "bearish",
    "categoryMoodText": "${categoryLabel} 시장 전체 기운 (40자 내외)",
    "investorSentiment": "투자자들의 심리 상태 (40자 내외)"
  },

  "luckyItems": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "timing": "최적 투자 시점 (예: 오후 2-4시)"
  },

  "advice": "종합 투자 조언 (80자 내외)",
  "psychologyTip": "투자 심리 조언 (60자 내외, 감정 조절, 냉정함 유지 등)"
}`

    const userPrompt = `[투자 종목 정보]
종목명: ${tickerName}
티커/심볼: ${tickerSymbol}
카테고리: ${categoryLabel}${tickerExchange ? `\n거래소: ${tickerExchange}` : ''}

[분석 요청일]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

위 종목에 대해 투자자들이 가장 궁금해하는 정보를 운세 형식으로 JSON 응답해주세요.
특히 매수/매도 타이밍, 단기/중기/장기 전망, 주의사항을 구체적으로 알려주세요.`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 4096,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'investment',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: {
        tickerSymbol,
        tickerCategory,
        isPremium,
        version: 'v2'
      }
    })

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // 블러 로직 (프리미엄 아니면 주요 섹션 블러)
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['timing', 'outlook', 'risks', 'marketMood', 'advice', 'psychologyTip']
      : []

    // 블러 처리된 데이터
    const blurredTiming = {
      buySignal: 'moderate',
      buySignalText: '🔒 프리미엄 구독으로 확인하세요',
      bestTimeSlot: 'afternoon',
      bestTimeSlotText: '🔒 프리미엄 구독으로 확인하세요',
      holdAdvice: '🔒 프리미엄 구독으로 확인하세요'
    }

    const blurredOutlook = {
      shortTerm: { score: 0, trend: 'neutral', text: '🔒 프리미엄 구독으로 확인하세요' },
      midTerm: { score: 0, trend: 'neutral', text: '🔒 프리미엄 구독으로 확인하세요' },
      longTerm: { score: 0, trend: 'neutral', text: '🔒 프리미엄 구독으로 확인하세요' }
    }

    const blurredRisks = {
      warnings: ['🔒 프리미엄 구독으로 확인하세요'],
      avoidActions: ['🔒 프리미엄 구독으로 확인하세요'],
      volatilityLevel: 'medium',
      volatilityText: '🔒 프리미엄 구독으로 확인하세요'
    }

    const blurredMarketMood = {
      categoryMood: 'neutral',
      categoryMoodText: '🔒 프리미엄 구독으로 확인하세요',
      investorSentiment: '🔒 프리미엄 구독으로 확인하세요'
    }

    // C03: 재물운 이미지 프롬프트 (한국 전통 스타일)
    const wealthImagePrompt = generateWealthImagePrompt(fortuneData.overallScore, categoryLabel)

    const result = {
      id: `investment-${Date.now()}`,
      type: 'investment',
      version: 'v2',
      userId: userId,
      ticker: {
        symbol: tickerSymbol,
        name: tickerName,
        category: tickerCategory,
        exchange: tickerExchange || null
      },
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      content: fortuneData.content,

      // 새로운 구조 (블러 적용)
      timing: isBlurred ? blurredTiming : fortuneData.timing,
      outlook: isBlurred ? blurredOutlook : fortuneData.outlook,
      risks: isBlurred ? blurredRisks : fortuneData.risks,
      marketMood: isBlurred ? blurredMarketMood : fortuneData.marketMood,

      // 기존 유지 (무료 공개)
      luckyItems: fortuneData.luckyItems,
      lucky_items: fortuneData.luckyItems,

      // 조언 (블러 적용)
      advice: isBlurred ? '🔒 프리미엄 구독으로 확인하세요' : fortuneData.advice,
      psychologyTip: isBlurred ? '🔒 프리미엄 구독으로 확인하세요' : fortuneData.psychologyTip,

      // C03: 재물 이미지 프롬프트 추가
      imagePrompt: wealthImagePrompt,

      created_at: new Date().toISOString(),
      metadata: {
        categoryLabel
      },
      isBlurred,
      blurredSections
    }

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'investment', result.overallScore)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // 캐싱 (원본 데이터 저장 - 블러 해제용)
    const cacheData = {
      ...result,
      // 원본 데이터도 저장 (프리미엄 전환 시 사용)
      _originalData: {
        timing: fortuneData.timing,
        outlook: fortuneData.outlook,
        risks: fortuneData.risks,
        marketMood: fortuneData.marketMood,
        advice: fortuneData.advice,
        psychologyTip: fortuneData.psychologyTip
      }
    }

    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'investment',
        user_id: userId || null,
        result: cacheData,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        fortune: resultWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('Error in fortune-investment:', error)

    return new Response(
      JSON.stringify({
        error: error.message,
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
