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
import { deriveUserIdFromJwt } from '../_shared/auth.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractInvestmentCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

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

// 사주 데이터 인터페이스
interface SajuData {
  yearPillar: string;    // 년주 (예: 무진)
  monthPillar: string;   // 월주
  dayPillar: string;     // 일주
  hourPillar: string;    // 시주
  dayMaster: string;     // 일간
  fiveElements: {        // 오행 분포
    목: number;
    화: number;
    토: number;
    금: number;
    수: number;
  };
}

// v2: 간소화된 요청 (투자 프로필 제거) + 사주 데이터
interface InvestmentRequest {
  ticker: TickerInfo;
  userId?: string;
  isPremium?: boolean;
  sajuData?: SajuData;
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

/**
 * 오행과 투자 카테고리 궁합 분석
 * 사주의 오행 분포와 투자 카테고리의 관련 오행을 비교하여 궁합 점수와 인사이트 생성
 */
function analyzeSajuInvestmentFit(
  fiveElements: Record<string, number> | undefined,
  category: string,
  dayMaster: string
): { score: number; insight: string; mindset: string } {
  // 카테고리별 관련 오행
  const categoryElement: Record<string, string> = {
    crypto: '수',      // 암호화폐: 수(水) - 유동성, 변화
    usStock: '금',     // 해외주식: 금(金) - 서방, 금융
    krStock: '토',     // 국내주식: 토(土) - 안정, 중앙
    etf: '토',         // ETF: 토(土) - 분산, 안정
    commodity: '금',   // 원자재: 금(金) - 금속, 자원
    realEstate: '토',  // 부동산: 토(土) - 땅, 안정
  };

  const element = categoryElement[category] || '토';
  const userElementStrength = fiveElements?.[element] || 1.0;

  // 점수 계산 (오행 강도 기반)
  const score = Math.min(100, Math.round(50 + userElementStrength * 15));

  // 일간 기반 인사이트 (민감한 전략 언급 X)
  const insights: Record<string, string> = {
    '갑': '새로운 시작의 기운이 있습니다. 도전적인 마음가짐이 필요한 날입니다.',
    '을': '유연한 접근이 좋습니다. 급하게 결정하지 마세요.',
    '병': '열정이 넘치는 시기입니다. 냉정함을 유지하세요.',
    '정': '신중한 판단이 빛나는 날입니다. 직감을 믿어보세요.',
    '무': '안정을 추구하는 기운입니다. 무리하지 마세요.',
    '기': '현실적인 판단이 필요합니다. 기본에 충실하세요.',
    '경': '결단력이 강한 시기입니다. 신중하게 행동하세요.',
    '신': '섬세한 분석이 빛나는 날입니다. 꼼꼼히 살펴보세요.',
    '임': '변화에 열린 마음을 가지세요. 흐름을 읽으세요.',
    '계': '통찰력이 뛰어난 시기입니다. 본질을 보세요.',
  };

  const mindsets: Record<string, string> = {
    '갑': '자신감을 갖되 겸손함을 잃지 마세요.',
    '을': '인내심을 가지고 기다리는 것도 전략입니다.',
    '병': '뜨거운 마음을 진정시키고 한 발 물러서 보세요.',
    '정': '마음의 평정을 유지하면 좋은 기회가 보입니다.',
    '무': '욕심을 버리고 현재에 집중하세요.',
    '기': '작은 것에 감사하는 마음으로 임하세요.',
    '경': '결과에 집착하지 말고 과정을 즐기세요.',
    '신': '완벽을 추구하기보다 유연하게 대처하세요.',
    '임': '변화를 두려워하지 마세요.',
    '계': '조용히 관찰하고 때를 기다리세요.',
  };

  return {
    score,
    insight: insights[dayMaster] || '오늘의 흐름을 읽고 신중하게 판단하세요.',
    mindset: mindsets[dayMaster] || '마음의 평정을 유지하세요.',
  };
}

serve(async (req) => {
  console.log('💎 [Investment] 요청 수신')

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('💎 [Step 0] Supabase 클라이언트 생성')
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )
    console.log('💎 [Step 0] Supabase 클라이언트 생성 완료')

    console.log('💎 [Step 0.5] 요청 body 파싱 시작')
    let requestData: InvestmentRequest
    try {
      requestData = await req.json()
      console.log('💎 [Step 0.5] 요청 body:', JSON.stringify(requestData).substring(0, 300))
    } catch (parseErr) {
      console.error('💎 [Step 0.5] 요청 body 파싱 실패:', parseErr)
      throw new Error(`요청 body 파싱 실패: ${parseErr}`)
    }

    const { ticker, isPremium = false, sajuData } = requestData
    // SECURITY: body.userId 무시. JWT 에서만 파생. 게스트는 'anonymous'.
    const userId = (await deriveUserIdFromJwt(req)) ?? 'anonymous'

    if (!ticker || !ticker.symbol || !ticker.name || !ticker.category) {
      console.error('💎 [Step 1] ticker 검증 실패:', JSON.stringify(ticker))
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
    console.log('💎 [Step 1] Ticker 검증 통과')

    // ✅ Cohort Pool에서 먼저 조회 (LLM 비용 90% 절감)
    const cohortData = extractInvestmentCohort({
      birthDate: (requestData as any).birthDate,
      age: (requestData as any).age,
      sajuData: sajuData ? { dayMaster: { element: sajuData.dayMaster } } : undefined,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log('💎 [Cohort] Cohort 추출:', JSON.stringify(cohortData), '| Hash:', cohortHash)

    const poolResult = await getFromCohortPool(supabaseClient, 'investment', cohortHash)
    if (poolResult) {
      console.log('💎 [Cohort] Pool HIT! - LLM 호출 생략')

      // 개인화 적용
      const personalizedResult = personalize(poolResult, {
        userName: (requestData as any).userName || '회원님',
        ticker: tickerSymbol,
        tickerName: tickerName,
        categoryLabel: categoryLabel,
      })

      // Percentile 적용
      const percentileData = await calculatePercentile(supabaseClient, 'investment', personalizedResult.overallScore || 70)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      return new Response(
        JSON.stringify({
          fortune: resultWithPercentile,
          cached: true,
          tokensUsed: 0,
          cohortHit: true
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }
    console.log('💎 [Cohort] Pool MISS - LLM 호출 필요')

    // 캐시 확인 (간소화된 키 - 프로필 정보 없음)
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_investment_v2_${today}_${tickerSymbol}_${tickerCategory}`

    // ✅ .maybeSingle()은 결과 없을 때 null 반환 (에러 X)
    console.log('💎 [Step 2] 캐시 확인 시작:', cacheKey)
    const { data: cachedResult, error: cacheError } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'investment')
      .maybeSingle()

    if (cacheError) {
      console.error('💎 [Step 2] 캐시 조회 에러:', cacheError)
    }
    console.log('💎 [Step 2] 캐시 결과:', cachedResult ? '캐시 있음' : '캐시 없음')

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

    // LLM 호출
    console.log('💎 [Step 3] LLM Factory 호출 시작')
    const llm = await LLMFactory.createFromConfigAsync('investment')
    console.log('💎 [Step 3] LLM Factory 완료')

    const systemPrompt = `당신은 ${categoryLabel} 투자 인사이트 전문가입니다.
사용자가 선택한 종목(${tickerName})에 대해 오늘의 기운과 마음가짐을 인사이트 형식으로 제공합니다.

## 중요 원칙 (반드시 준수)
- 구체적인 투자 전략, 매매 시점, 목표가, 투자 기간은 절대 언급하지 마세요
- 마음가짐과 심리 상태 중심으로 조언하세요
- 모든 투자 결정은 본인의 선택과 책임임을 명시하세요
- "~하세요", "~해야 합니다" 대신 "~해보시는 건 어떨까요", "~도 좋겠네요" 같은 부드러운 표현 사용

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 (오늘의 투자 기운 점수),
  "content": "핵심 요약 (150자 내외, 오늘의 투자 기운과 마음가짐 중심, 구체적 전략 X)",

  "sajuInsight": {
    "elementFit": "사용자 오행과 종목 카테고리의 조화 설명 (100자 내외)",
    "todayEnergy": "오늘 일주 기운이 투자 심리에 미치는 영향 (80자 내외)",
    "mindsetAdvice": "오늘의 마음가짐 조언 (60자 내외)"
  },

  "timing": {
    "buySignal": "strong" | "moderate" | "weak" | "avoid",
    "generalAdvice": "전체적인 분위기 설명 (80자 내외, 구체적 시점 언급 X)",
    "emotionalTip": "감정 조절 팁 (50자 내외)"
  },

  "outlook": {
    "general": {
      "mood": "positive" | "neutral" | "cautious",
      "text": "전반적인 기운 흐름 (80자 내외, 기간 언급 X)"
    }
  },

  "risks": {
    "emotionalRisks": ["감정적 위험 요소 3가지 (각 40자, 심리 중심)"],
    "mindfulReminders": ["마음챙김 조언 2가지 (각 40자)"]
  },

  "marketMood": {
    "categoryMood": "bullish" | "neutral" | "bearish",
    "categoryMoodText": "${categoryLabel} 시장 전체 기운 (50자 내외)",
    "investorSentiment": "투자자들의 심리 상태 (50자 내외)"
  },

  "luckyItems": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "element": "오행 중 오늘 도움이 되는 기운"
  },

  "advice": "종합 조언 (120자 내외, 마음가짐 + 인사이트 관점, 전략 X)",
  "psychologyTip": "투자 심리 조언 (80자 내외, 감정 조절, 평정심 유지)",
  "disclaimer": "투자는 본인의 선택과 책임입니다. 이 내용은 재미로 참고하시기 바랍니다."
}`

    // 사주 정보 문자열 생성
    const sajuInfoText = sajuData ? `
[사용자 사주 정보]
일간(Day Master): ${sajuData.dayMaster}
사주: ${sajuData.yearPillar} ${sajuData.monthPillar} ${sajuData.dayPillar} ${sajuData.hourPillar}
오행 분포: 목${sajuData.fiveElements?.목 || 0} 화${sajuData.fiveElements?.화 || 0} 토${sajuData.fiveElements?.토 || 0} 금${sajuData.fiveElements?.금 || 0} 수${sajuData.fiveElements?.수 || 0}
` : '[사주 정보 없음]';

    const userPrompt = `[투자 종목 정보]
종목명: ${tickerName}
티커/심볼: ${tickerSymbol}
카테고리: ${categoryLabel}${tickerExchange ? `\n거래소: ${tickerExchange}` : ''}
${sajuInfoText}
[오늘]
${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}

마음가짐과 오늘의 인사이트 관점에서 투자 기운을 알려주세요.
중요: 구체적인 매매 전략, 목표가, 투자 기간은 절대 언급하지 마세요.`

    console.log('💎 [Step 4] LLM generate 호출 시작')
    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 4096,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)
    console.log('💎 [Step 4] LLM 응답 내용 길이:', response.content?.length || 0)

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

    console.log('💎 [Step 5] JSON 파싱 시작')
    let fortuneData
    try {
      fortuneData = JSON.parse(response.content)
      console.log('💎 [Step 5] JSON 파싱 성공, overallScore:', fortuneData.overallScore)
    } catch (parseError) {
      console.error('💎 [Step 5] JSON 파싱 실패:', parseError)
      console.error('💎 [Step 5] 원본 응답:', response.content?.substring(0, 500))
      throw new Error(`JSON 파싱 실패: ${parseError.message}`)
    }

    // C03: 재물운 이미지 프롬프트 (한국 전통 스타일)
    const wealthImagePrompt = generateWealthImagePrompt(fortuneData.overallScore, categoryLabel)

    // 사주 분석 결과 계산 (사주 데이터가 있을 경우)
    const sajuAnalysisResult = sajuData
      ? analyzeSajuInvestmentFit(sajuData.fiveElements, tickerCategory, sajuData.dayMaster)
      : null;

    const result = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'investment',
      score: fortuneData.overallScore,
      content: fortuneData.content,
      summary: `${tickerName}(${tickerSymbol}) 투자운 ${fortuneData.overallScore}점`,
      advice: fortuneData.advice || '신중한 투자 결정을 하세요.',

      // 기존 필드 유지 (하위 호환성)
      id: `investment-${Date.now()}`,
      type: 'investment',
      version: 'v3',  // v3: 사주 분석 추가
      userId: userId,
      ticker: {
        symbol: tickerSymbol,
        name: tickerName,
        category: tickerCategory,
        exchange: tickerExchange || null
      },
      overallScore: fortuneData.overallScore,
      overall_score: fortuneData.overallScore,
      investment_content: fortuneData.content,

      // ✅ NEW: 사주 인사이트 (LLM 생성)
      sajuInsight: fortuneData.sajuInsight || null,

      // ✅ NEW: 사주 분석 결과 (로컬 계산)
      sajuAnalysis: sajuAnalysisResult,

      // ✅ 실제 데이터 반환 (클라이언트에서 블러 처리)
      timing: fortuneData.timing,
      outlook: fortuneData.outlook,
      risks: fortuneData.risks,
      marketMood: fortuneData.marketMood,

      // 기존 유지 (무료 공개)
      luckyItems: fortuneData.luckyItems,
      lucky_items: fortuneData.luckyItems,

      // ✅ 실제 데이터 반환 (클라이언트에서 블러 처리)
      advice: fortuneData.advice,
      psychologyTip: fortuneData.psychologyTip,

      // ✅ NEW: 면책 문구
      disclaimer: fortuneData.disclaimer || '투자는 본인의 선택과 책임입니다. 이 내용은 재미로 참고하시기 바랍니다.',

      // C03: 재물 이미지 프롬프트 추가
      imagePrompt: wealthImagePrompt,

      created_at: new Date().toISOString(),
      metadata: {
        categoryLabel,
        hasSajuData: !!sajuData
      }
    }

    // Percentile 계산
    console.log('💎 [Step 6] Percentile 계산 시작')
    const percentileData = await calculatePercentile(supabaseClient, 'investment', result.overallScore)
    console.log('💎 [Step 6] Percentile 계산 완료:', percentileData)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    // 캐싱 (실제 데이터 저장 - _originalData 불필요)
    console.log('💎 [Step 7] 캐싱 시작')
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'investment',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    // ✅ Cohort Pool에 저장 (비동기, fire-and-forget)
    saveToCohortPool(supabaseClient, 'investment', cohortHash, cohortData, resultWithPercentile)
      .catch(e => console.error('[Investment] Cohort 저장 오류:', e))

    // ✅ 응답 형식 통일: 캐시와 동일하게 { fortune, cached, tokensUsed }
    console.log('💎 [Step 8] 응답 반환 시작')
    return new Response(
      JSON.stringify({
        fortune: resultWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : String(error)
    console.error('❌ [Investment] 전체 에러:', errorMessage)
    console.error('❌ [Investment] 에러 스택:', error instanceof Error ? error.stack : 'N/A')
    console.error('Error in fortune-investment:', error)

    return new Response(
      JSON.stringify({
        error: errorMessage,
        details: String(error)
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
