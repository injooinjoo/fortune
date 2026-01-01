/**
 * 경기 인사이트 (Match Insight) Edge Function
 *
 * @description 스포츠 경기 예측 인사이트를 생성합니다.
 *              사용자의 사주와 응원팀을 기반으로 운세+승률을 분석합니다.
 *
 * @endpoint POST /fortune-match-insight
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - sport: 'baseball' | 'soccer' | 'basketball' | 'volleyball' | 'esports' | 'american_football' | 'fighting'
 * - league?: string - 리그 (KBO, MLB, EPL, La Liga 등 - 미지정시 종목별 기본 리그)
 * - homeTeam: string - 홈팀 이름
 * - awayTeam: string - 원정팀 이름
 * - gameDate: string - 경기 날짜 (ISO 8601)
 * - favoriteTeam?: string - 응원팀 (선택)
 * - birthDate?: string - 사용자 생년월일 (YYYY-MM-DD)
 *
 * @response MatchInsightResponse
 * - score: number (1-100) - 종합 인사이트 점수
 * - summary: string - 요약 메시지
 * - content: string - 상세 분석
 * - advice: string - 오늘의 조언
 * - prediction: { winProbability, confidence, keyFactors, predictedScore?, mvpCandidate? }
 * - favoriteTeamAnalysis: { name, recentForm, strengths, concerns, keyPlayer?, formEmoji? }
 * - opponentAnalysis: { name, recentForm, strengths, concerns, keyPlayer?, formEmoji? }
 * - fortuneElements: { luckyColor, luckyNumber, luckyTime, luckyItem, luckySection?, luckyAction? }
 * - cautionMessage: string - 면책 메시지
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 스포츠 종목별 기본 정보
const SPORT_INFO: Record<string, { defaultLeague: string; emoji: string; displayName: string }> = {
  baseball: { defaultLeague: 'KBO', emoji: '⚾', displayName: '야구' },
  soccer: { defaultLeague: 'K리그', emoji: '⚽', displayName: '축구' },
  basketball: { defaultLeague: 'KBL', emoji: '🏀', displayName: '농구' },
  volleyball: { defaultLeague: 'V리그', emoji: '🏐', displayName: '배구' },
  esports: { defaultLeague: 'LCK', emoji: '🎮', displayName: 'e스포츠' },
  american_football: { defaultLeague: 'NFL', emoji: '🏈', displayName: '미식축구' },
  fighting: { defaultLeague: 'UFC', emoji: '🥊', displayName: '격투기' },
}

// 리그별 상세 정보 (지역, 전체 이름, 특성)
const LEAGUE_INFO: Record<string, { sport: string; displayName: string; region: string; language: string }> = {
  // 한국 리그
  'KBO': { sport: 'baseball', displayName: 'KBO 야구', region: 'KR', language: 'ko' },
  'K리그': { sport: 'soccer', displayName: 'K리그', region: 'KR', language: 'ko' },
  'KBL': { sport: 'basketball', displayName: 'KBL 농구', region: 'KR', language: 'ko' },
  'V리그': { sport: 'volleyball', displayName: 'V리그 배구', region: 'KR', language: 'ko' },
  'V리그 남자': { sport: 'volleyball', displayName: 'V리그 남자부', region: 'KR', language: 'ko' },
  'V리그 여자': { sport: 'volleyball', displayName: 'V리그 여자부', region: 'KR', language: 'ko' },
  'LCK': { sport: 'esports', displayName: 'LCK', region: 'KR', language: 'ko' },
  // 미국 리그
  'MLB': { sport: 'baseball', displayName: 'MLB 메이저리그', region: 'US', language: 'en' },
  'NBA': { sport: 'basketball', displayName: 'NBA', region: 'US', language: 'en' },
  'NFL': { sport: 'american_football', displayName: 'NFL', region: 'US', language: 'en' },
  // 유럽 축구 리그
  'EPL': { sport: 'soccer', displayName: 'EPL 프리미어리그', region: 'EU', language: 'en' },
  'La Liga': { sport: 'soccer', displayName: '라리가', region: 'EU', language: 'es' },
  'Bundesliga': { sport: 'soccer', displayName: '분데스리가', region: 'EU', language: 'de' },
  'Serie A': { sport: 'soccer', displayName: '세리에 A', region: 'EU', language: 'it' },
  'UCL': { sport: 'soccer', displayName: 'UEFA 챔피언스리그', region: 'EU', language: 'en' },
  // 격투기
  'UFC': { sport: 'fighting', displayName: 'UFC', region: 'US', language: 'en' },
}

// 응답 인터페이스
interface MatchInsightResponse {
  score: number;
  summary: string;
  content: string;
  advice: string;
  prediction: {
    winProbability: number;
    confidence: 'high' | 'medium' | 'low';
    keyFactors: string[];
    predictedScore?: string;
    mvpCandidate?: string;
  };
  favoriteTeamAnalysis: {
    name: string;
    recentForm: string;
    strengths: string[];
    concerns: string[];
    keyPlayer?: string;
    formEmoji?: string;
  };
  opponentAnalysis: {
    name: string;
    recentForm: string;
    strengths: string[];
    concerns: string[];
    keyPlayer?: string;
    formEmoji?: string;
  };
  fortuneElements: {
    luckyColor: string;
    luckyNumber: number;
    luckyTime: string;
    luckyItem: string;
    luckySection?: string;
    luckyAction?: string;
  };
  cautionMessage: string;
}

// 시스템 프롬프트
function getSystemPrompt(sport: string, league: string): string {
  const sportInfo = SPORT_INFO[sport] || SPORT_INFO.baseball;
  const leagueInfo = LEAGUE_INFO[league];
  const leagueName = leagueInfo?.displayName || league;
  const isInternational = leagueInfo?.region !== 'KR';

  return `당신은 ${leagueName} 전문 스포츠 인사이트 분석가입니다.${isInternational ? ' 해외 리그 전문가로서 한국 팬들에게 친숙하게 설명합니다.' : ''}

## 역할
- 경기 예측과 운세를 결합한 재미있는 인사이트 제공
- 팬들에게 응원의 즐거움을 더해주는 분석
- 객관적 데이터와 운세적 요소를 균형있게 제시

## 중요 사항
1. 이것은 순수 엔터테인먼트 목적입니다
2. 도박이나 베팅을 권장하지 않습니다
3. 확정적 예측이 아닌 재미있는 인사이트입니다
4. 양 팀 모두 존중하는 분석을 제공합니다

## 분석 스타일
- 한국어로 친근하고 재미있게
- 팬의 마음을 이해하는 따뜻한 톤
- 전문적이면서도 이해하기 쉬운 설명
- 응원팀에 약간의 희망을 주되 현실적으로

## JSON 응답 형식
반드시 다음 JSON 형식으로만 응답하세요:
{
  "score": 75,
  "summary": "오늘의 경기 한줄 요약",
  "content": "상세 분석 내용 (3-4문장)",
  "advice": "오늘 경기를 보는 팬에게 조언",
  "prediction": {
    "winProbability": 65,
    "confidence": "medium",
    "keyFactors": ["요인1", "요인2", "요인3"],
    "predictedScore": "3:2",
    "mvpCandidate": "선수명"
  },
  "favoriteTeamAnalysis": {
    "name": "팀명",
    "recentForm": "최근 5경기 3승 2패",
    "strengths": ["강점1", "강점2"],
    "concerns": ["우려1"],
    "keyPlayer": "핵심선수",
    "formEmoji": "🔥"
  },
  "opponentAnalysis": {
    "name": "상대팀명",
    "recentForm": "최근 5경기 2승 3패",
    "strengths": ["강점1"],
    "concerns": ["우려1", "우려2"],
    "keyPlayer": "핵심선수",
    "formEmoji": "📈"
  },
  "fortuneElements": {
    "luckyColor": "파랑",
    "luckyNumber": 7,
    "luckyTime": "3회",
    "luckyItem": "응원봉",
    "luckySection": "3회",
    "luckyAction": "파도타기"
  },
  "cautionMessage": "이 인사이트는 순수 재미 목적입니다. 도박이나 베팅에 활용하지 마세요."
}`;
}

// 사용자 프롬프트 생성
function getUserPrompt(
  sport: string,
  league: string,
  homeTeam: string,
  awayTeam: string,
  gameDate: string,
  favoriteTeam?: string,
  birthDate?: string
): string {
  const sportInfo = SPORT_INFO[sport] || SPORT_INFO.baseball;
  const leagueInfo = LEAGUE_INFO[league];
  const leagueName = leagueInfo?.displayName || league;
  const formattedDate = new Date(gameDate).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  });

  let prompt = `## 경기 정보
- 종목: ${sportInfo.displayName}
- 리그: ${leagueName}
- 경기: ${homeTeam} vs ${awayTeam}
- 날짜: ${formattedDate}
${favoriteTeam ? `- 응원팀: ${favoriteTeam}` : ''}
${birthDate ? `- 사용자 생년월일: ${birthDate}` : ''}

## 요청
위 경기에 대한 인사이트를 제공해주세요.
${favoriteTeam ? `${favoriteTeam} 팬의 관점에서 분석해주세요.` : '중립적 관점에서 분석해주세요.'}

## 주의사항
- 확정적 표현 대신 "~할 것으로 보입니다", "~가 기대됩니다" 등 사용
- 양 팀 모두 존중하는 분석
- JSON 형식으로만 응답`;

  return prompt;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const {
      userId,
      sport,
      league: requestedLeague,
      homeTeam,
      awayTeam,
      gameDate,
      favoriteTeam,
      birthDate,
    } = await req.json();

    // 필수 파라미터 검증
    if (!userId || !sport || !homeTeam || !awayTeam || !gameDate) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 종목 검증
    if (!SPORT_INFO[sport]) {
      return new Response(
        JSON.stringify({ error: 'Invalid sport type' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 리그 결정 (요청에서 지정하거나 종목별 기본값 사용)
    const sportInfo = SPORT_INFO[sport];
    const league = requestedLeague || sportInfo.defaultLeague;

    // LLM 호출
    const llm = LLMFactory.createFromConfig('fortune-match-insight');

    const systemPrompt = getSystemPrompt(sport, league);
    const userPrompt = getUserPrompt(
      sport,
      league,
      homeTeam,
      awayTeam,
      gameDate,
      favoriteTeam,
      birthDate
    );

    const response = await llm.generate(
      [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      {
        temperature: 0.7,
        maxTokens: 2000,
      }
    );

    console.log(`✅ [MatchInsight] LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`);

    // 응답 파싱
    let result: MatchInsightResponse;
    try {
      const content = response.content || response.message?.content || '';
      // JSON 추출 (```json ... ``` 형태도 처리)
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }
      result = JSON.parse(jsonMatch[0]);
    } catch (parseError) {
      console.error('Parse error:', parseError);
      // 기본 응답 생성
      result = {
        score: 50,
        summary: `${homeTeam} vs ${awayTeam} 경기 분석 중 오류가 발생했습니다.`,
        content: '분석을 다시 시도해주세요.',
        advice: '경기를 즐기세요!',
        prediction: {
          winProbability: 50,
          confidence: 'low',
          keyFactors: ['데이터 분석 중'],
        },
        favoriteTeamAnalysis: {
          name: favoriteTeam || homeTeam,
          recentForm: '확인 필요',
          strengths: [],
          concerns: [],
        },
        opponentAnalysis: {
          name: favoriteTeam === homeTeam ? awayTeam : homeTeam,
          recentForm: '확인 필요',
          strengths: [],
          concerns: [],
        },
        fortuneElements: {
          luckyColor: '파랑',
          luckyNumber: 7,
          luckyTime: '경기 시작',
          luckyItem: '응원봉',
        },
        cautionMessage: '이 인사이트는 순수 재미 목적입니다. 도박이나 베팅에 활용하지 마세요.',
      };
    }

    // 백분위 계산
    const percentile = await calculatePercentile(
      supabase,
      'match-insight',
      result.score
    );

    // 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'match-insight',
      userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: {
        sport,
        league,
        homeTeam,
        awayTeam,
        favoriteTeam,
      }
    });

    // 최종 응답
    const finalResponse = {
      id: crypto.randomUUID(),
      fortuneType: 'match-insight',
      score: result.score,
      content: result.content,
      summary: result.summary,
      advice: result.advice,
      prediction: result.prediction,
      favoriteTeamAnalysis: result.favoriteTeamAnalysis,
      opponentAnalysis: result.opponentAnalysis,
      fortuneElements: result.fortuneElements,
      cautionMessage: result.cautionMessage,
      isBlurred: false,
      blurredSections: [],
      timestamp: new Date().toISOString(),
      percentile,
      // 경기 정보
      sport,
      homeTeam,
      awayTeam,
      gameDate,
      favoriteTeam,
      league,
      sportEmoji: sportInfo.emoji,
    };

    return new Response(
      JSON.stringify(finalResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
