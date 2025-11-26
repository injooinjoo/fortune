import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

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

interface InvestmentRequest {
  // 새로운 티커 기반 요청
  ticker?: TickerInfo;

  // 기존 호환성 유지
  investmentType?: 'stock' | 'crypto' | 'real_estate' | 'startup' | 'fund' | 'krStock' | 'usStock' | 'etf' | 'commodity' | 'realEstate';
  targetName?: string;

  // 투자 프로필
  amount?: number;
  timeframe: string; // '단기 (1개월 이내)', '중기 (3-6개월)', '장기 (1년 이상)'
  riskTolerance: 'conservative' | 'moderate' | 'aggressive';
  purpose: string; // '수익 창출', '자산 증식', '노후 대비' 등
  experience: 'beginner' | 'intermediate' | 'expert';
  userId?: string;
  isPremium?: boolean;
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
    const {
      ticker,
      investmentType: legacyType,
      targetName: legacyTargetName,
      amount,
      timeframe,
      riskTolerance,
      purpose,
      experience,
      userId,
      isPremium = false
    } = requestData

    // 티커 정보 추출 (새 방식 우선, 기존 방식 호환)
    const tickerSymbol = ticker?.symbol || legacyTargetName || 'Unknown'
    const tickerName = ticker?.name || legacyTargetName || '알 수 없는 종목'
    const tickerCategory = ticker?.category || legacyType || 'stock'
    const tickerExchange = ticker?.exchange || ''

    // 카테고리 레이블 매핑
    const categoryLabels: Record<string, string> = {
      crypto: '암호화폐',
      krStock: '국내주식',
      usStock: '해외주식',
      etf: 'ETF',
      commodity: '원자재',
      realEstate: '부동산',
      stock: '주식',
      real_estate: '부동산',
      startup: '스타트업',
      fund: '펀드'
    }
    const categoryLabel = categoryLabels[tickerCategory] || '투자'

    console.log('💎 [Investment] Premium:', isPremium, '| Ticker:', tickerSymbol, tickerName, tickerCategory)

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_investment_${today}_${tickerSymbol}_${tickerCategory}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'investment')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          fortune: cachedResult.result,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // OpenAI API 호출
    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('investment')

    const systemPrompt = `당신은 ${categoryLabel} 투자 운세 전문가입니다. 사용자가 선택한 종목(${tickerName})에 대한 투자 운세와 실용적인 조언을 제공합니다.

해당 종목의 특성과 시장 상황을 고려하여 분석해주세요.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (투자 운세 점수),
  "content": "투자 운세 분석 (300자 내외, ${tickerName}(${tickerSymbol})의 현재 상황과 투자자 상태를 고려한 종합 분석)",
  "description": "상세 분석 (500자 내외, 투자 시점, 예상 시나리오, 위험 요소 등)",
  "luckyItems": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "timing": "최적 투자 시점"
  },
  "hexagonScores": {
    "timing": 0-100 (투자 타이밍 점수),
    "value": 0-100 (가치 평가 점수),
    "risk": 0-100 (리스크 관리 점수),
    "trend": 0-100 (시장 트렌드 점수),
    "emotion": 0-100 (감정 통제 점수),
    "knowledge": 0-100 (정보력 점수)
  },
  "recommendations": [
    "긍정적인 추천 사항 3가지"
  ],
  "warnings": [
    "주의해야 할 사항 3가지"
  ],
  "advice": "종합 투자 조언 (200자 내외)"
}`

    // 투자금액 표시 (없으면 생략)
    const amountText = amount ? `투자 예정 금액: ${amount.toLocaleString()}원` : ''

    const userPrompt = `[투자 종목 정보]
종목명: ${tickerName}
티커/심볼: ${tickerSymbol}
카테고리: ${categoryLabel}${tickerExchange ? `\n거래소: ${tickerExchange}` : ''}

[투자자 프로필]
${amountText ? amountText + '\n' : ''}투자 기간: ${timeframe}
위험 감수도: ${riskTolerance === 'conservative' ? '안정형' : riskTolerance === 'moderate' ? '중립형' : '공격형'}
투자 목적: ${purpose}
투자 경험: ${experience === 'beginner' ? '초보' : experience === 'intermediate' ? '중급' : '전문가'}

[분석 요청일]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

위 정보를 바탕으로 ${tickerName}(${tickerSymbol}) 투자 운세를 JSON 형식으로 분석해주세요.
해당 종목의 특성과 카테고리(${categoryLabel})를 고려하여 긍정적이면서도 현실적인 조언을 제공해주세요.`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['description', 'hexagonScores', 'recommendations', 'warnings', 'advice']
      : []

    const result = {
      id: `investment-${Date.now()}`,
      type: 'investment',
      userId: userId,
      // 새 티커 정보
      ticker: {
        symbol: tickerSymbol,
        name: tickerName,
        category: tickerCategory,
        exchange: tickerExchange || null
      },
      // 기존 호환성 유지
      targetName: tickerName,
      investmentType: tickerCategory,
      amount: amount || null,
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      content: fortuneData.content,
      description: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.description,
      luckyItems: fortuneData.luckyItems,
      lucky_items: fortuneData.luckyItems,
      hexagonScores: isBlurred ? {
        timing: 0,
        value: 0,
        risk: 0,
        trend: 0,
        emotion: 0,
        knowledge: 0
      } : fortuneData.hexagonScores,
      recommendations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.recommendations,
      warnings: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.warnings,
      advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.advice,
      created_at: new Date().toISOString(),
      metadata: {
        timeframe,
        riskTolerance,
        purpose,
        experience,
        categoryLabel
      },
      isBlurred,
      blurredSections
    }

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'investment',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        fortune: result,
        cached: false,
        tokensUsed: response.tokensUsed || 0
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
