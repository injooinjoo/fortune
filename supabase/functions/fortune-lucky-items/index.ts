/**
 * 행운의 아이템 운세 (Lucky Items Fortune) Edge Function
 *
 * @description 사용자의 사주와 관심사를 기반으로 오늘의 행운 아이템, 색상, 숫자, 방향 등을 분석합니다.
 *
 * @endpoint POST /fortune-lucky-items
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (ISO 8601)
 * - birthTime?: string - 출생 시간 (HH:MM)
 * - gender?: string - 성별 ("male" | "female")
 * - interests?: string[] - 관심 분야 목록
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response LuckyItemsResponse
 * - title: string - 오늘의 행운 제목
 * - summary: string - 행운 요약
 * - keyword: string - 오늘의 키워드
 * - color: string - 행운의 색상
 * - fashion: string[] - 추천 패션 아이템
 * - numbers: number[] - 행운의 숫자들
 * - food: string[] - 행운의 음식
 * - jewelry: string[] - 행운의 보석/액세서리
 * - material: string[] - 행운의 소재
 * - direction: string - 행운의 방향
 * - places: string[] - 행운의 장소
 * - relationships: string[] - 행운의 인연
 * - element: string - 오행 (목, 화, 토, 금, 수)
 * - score: number - 행운 점수 (0-100)
 * - advice: string - 조언
 * - isBlurred: boolean - 블러 상태
 * - blurredSections: string[] - 블러된 섹션 목록
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "name": "홍길동",
 *   "birthDate": "1990-05-15",
 *   "birthTime": "14:30",
 *   "gender": "male",
 *   "interests": ["패션", "음식"],
 *   "isPremium": true
 * }
 *
 * // Response
 * {
 *   "success": true,
 *   "data": {
 *     "title": "오늘의 행운",
 *     "color": "파란색",
 *     "numbers": [3, 7, 12],
 *     "direction": "동쪽",
 *     "score": 85,
 *     ...
 *   }
 * }
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

interface LuckyItemsRequest {
  userId: string;
  name: string;
  birthDate: string; // ISO 8601
  birthTime?: string; // "HH:MM"
  gender?: string; // "male" | "female"
  interests?: string[];
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
}

interface LuckyItemsResponse {
  success: boolean;
  data: {
    title: string;
    summary: string;
    keyword: string;
    color: string;
    fashion: string[];
    numbers: number[];
    food: string[];
    jewelry: string[];
    material: string[];
    direction: string;
    places: string[];
    relationships: string[];
    element: string; // 오행
    score: number;
    advice: string;
    timestamp: string;
    isBlurred?: boolean; // ✅ 블러 상태
    blurredSections?: string[]; // ✅ 블러된 섹션 목록
  };
  error?: string;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const {
      userId,
      name,
      birthDate,
      birthTime,
      gender,
      interests,
      isPremium = false // ✅ 프리미엄 사용자 여부
    }: LuckyItemsRequest = await req.json()

    console.log('💎 [LuckyItems] Premium 상태:', isPremium)
    console.log(`[fortune-lucky-items] 🎯 Request received:`, { userId, name, birthDate })

    // ✅ 오늘 날짜/시간 컨텍스트 (한국 시간 기준)
    const now = new Date();
    const koreaTime = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Seoul' }));
    const year = koreaTime.getFullYear();
    const month = koreaTime.getMonth() + 1;
    const day = koreaTime.getDate();
    const hour = koreaTime.getHours();
    const weekday = ['일', '월', '화', '수', '목', '금', '토'][koreaTime.getDay()];

    const timeOfDay = hour < 6 ? '새벽' : hour < 12 ? '오전' : hour < 18 ? '오후' : '저녁';
    const season = month >= 3 && month <= 5 ? '봄' :
                   month >= 6 && month <= 8 ? '여름' :
                   month >= 9 && month <= 11 ? '가을' : '겨울';

    // 계절별 오행 기운
    const seasonElement = season === '봄' ? '목(木)' :
                          season === '여름' ? '화(火)' :
                          season === '가을' ? '금(金)' : '수(水)';

    console.log(`[fortune-lucky-items] 📅 Today: ${year}년 ${month}월 ${day}일 (${weekday}) ${timeOfDay}, ${season}`)

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('fortune-lucky-items')

    const systemPrompt = `당신은 동양 철학과 오행(五行) 이론에 기반한 행운 아이템 분석 전문가입니다.
사용자의 사주(생년월일/시)와 오늘의 기운을 종합하여 실질적인 행운 아이템을 추천합니다.

📅 **오늘 정보**: ${year}년 ${month}월 ${day}일 (${weekday}요일) ${timeOfDay}, ${season}
🌿 **계절 기운**: ${seasonElement} - ${season}의 기운이 강함

**분석 프레임워크**:
1. 사주 오행 분석: 생년월일/시 → 부족한 오행 파악
2. 계절 오행 반영: ${season}철(${seasonElement}) 기운과의 조화
3. 시간대 최적화: ${timeOfDay}에 효과적인 아이템 우선
4. 관심사 맞춤화: 사용자 관심사와 오행 연결

**추천 원칙**:
- 모든 아이템마다 "왜 이것인지" 오행 기반 이유 필수
- 오늘 바로 실행 가능한 구체적 제안
- ${season}철에 특히 효과적인 아이템 우선

**추천 카테고리** (각각 reason 포함):
- 색상: 행운 색상 + 오행 보완 이유
- 패션: 오늘 입으면 좋은 아이템 3가지 + 이유
- 숫자: 행운 숫자 3개 (1-99)
- 음식: ${timeOfDay}에 먹으면 좋은 음식 3가지 + 이유
- 보석/액세서리: 에너지 보완 아이템 3가지 + 이유
- 소재: 오늘 좋은 소재 3가지 + 이유
- 방향: 행운의 방향 + 이유
- 장소: 가면 좋은 장소 3곳 + 이유
- 인연: 오늘 만나면 좋은 사람 특징 3가지 + 이유

**중요**: 응답의 'content' 필드에 3-4문장으로 사용자 맞춤 분석 본문을 반드시 작성하세요.`

    const userPrompt = `다음 정보를 기반으로 개인화된 행운 아이템을 추천해주세요:

**기본 정보**:
- 이름: ${name}
- 생년월일: ${birthDate}
${birthTime ? `- 출생 시간: ${birthTime}` : ''}
${gender ? `- 성별: ${gender === 'male' ? '남성' : '여성'}` : ''}
${interests && interests.length > 0 ? `- 관심사: ${interests.join(', ')}` : ''}

**오늘 컨텍스트**:
- 날짜: ${year}년 ${month}월 ${day}일 (${weekday}요일)
- 시간대: ${timeOfDay}
- 계절: ${season} (${seasonElement})

**응답 형식** (반드시 JSON):
\`\`\`json
{
  "title": "${name}님의 오늘 행운 아이템",
  "summary": "오행 분석 결과 한 줄 요약",
  "content": "${name}님의 사주를 분석한 결과... (3-4문장의 상세 본문. 오행 균형, 계절 영향, 오늘 특별히 중요한 포인트 설명)",
  "element": "주요 오행 (금/수/목/화/토)",
  "keyword": "오늘의 핵심 키워드 3개 (쉼표 구분)",
  "color": {"primary": "메인 행운색", "secondary": "보조 행운색", "reason": "왜 이 색이 좋은지 오행 기반 설명"},
  "fashion": [
    {"item": "패션 아이템 1", "reason": "오행 보완 이유"},
    {"item": "패션 아이템 2", "reason": "오행 보완 이유"},
    {"item": "패션 아이템 3", "reason": "오행 보완 이유"}
  ],
  "numbers": [행운숫자1, 행운숫자2, 행운숫자3],
  "food": [
    {"item": "음식 1", "reason": "오행 보완 이유", "timing": "추천 시간"},
    {"item": "음식 2", "reason": "오행 보완 이유", "timing": "추천 시간"},
    {"item": "음식 3", "reason": "오행 보완 이유", "timing": "추천 시간"}
  ],
  "jewelry": [
    {"item": "보석/액세서리 1", "reason": "에너지 보완 이유"},
    {"item": "보석/액세서리 2", "reason": "에너지 보완 이유"},
    {"item": "보석/액세서리 3", "reason": "에너지 보완 이유"}
  ],
  "material": [
    {"item": "소재 1", "reason": "오행 보완 이유"},
    {"item": "소재 2", "reason": "오행 보완 이유"},
    {"item": "소재 3", "reason": "오행 보완 이유"}
  ],
  "direction": {"primary": "행운 방향", "reason": "방향 추천 이유"},
  "places": [
    {"place": "장소 1", "reason": "방문 추천 이유"},
    {"place": "장소 2", "reason": "방문 추천 이유"},
    {"place": "장소 3", "reason": "방문 추천 이유"}
  ],
  "relationships": [
    {"type": "인연 유형 1", "reason": "궁합 좋은 이유"},
    {"type": "인연 유형 2", "reason": "궁합 좋은 이유"},
    {"type": "인연 유형 3", "reason": "궁합 좋은 이유"}
  ],
  "score": 행운지수 (1-100),
  "advice": {
    "morning": "오전에 하면 좋은 행동",
    "afternoon": "오후에 하면 좋은 행동",
    "evening": "저녁에 하면 좋은 행동",
    "overall": "오늘 하루 종합 조언 (50자 이내)"
  },
  "todayTip": "💡 오늘 핵심 팁 한 줄"
}
\`\`\`

**주의**:
1. 반드시 유효한 JSON 형식으로만 응답
2. content 필드는 반드시 3-4문장으로 작성
3. 모든 reason은 오행 이론에 기반하여 구체적으로 작성`

    console.log(`[fortune-lucky-items] 🔄 LLM 호출 시작...`)

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`[fortune-lucky-items] ✅ LLM 응답 수신 (${response.latency}ms, ${response.usage?.totalTokens || 0} tokens)`)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'lucky-items',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { name, birthDate, gender, interests, isPremium }
    })

    // JSON 파싱
    let fortuneData: any
    try {
      fortuneData = typeof response.content === 'string'
        ? JSON.parse(response.content)
        : response.content
    } catch (parseError) {
      console.error(`[fortune-lucky-items] ❌ JSON 파싱 실패:`, parseError)
      throw new Error('LLM 응답을 파싱할 수 없습니다')
    }

    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['fashion', 'food', 'jewelry', 'material', 'places', 'relationships', 'advice']
      : []

    // ✅ 헬퍼 함수: 객체 배열 → 문자열 배열 정규화 (하위 호환성)
    const normalizeToStringArray = (items: any[]): string[] => {
      if (!items || !Array.isArray(items)) return [];
      return items.map((i: any) => {
        if (typeof i === 'string') return i;
        return i.item || i.place || i.type || String(i);
      });
    };

    // ✅ 헬퍼 함수: advice 객체/문자열 정규화
    const normalizeAdvice = (advice: any): string => {
      if (typeof advice === 'string') return advice;
      if (typeof advice === 'object' && advice?.overall) return advice.overall;
      return '';
    };

    // ✅ 헬퍼 함수: color 객체/문자열 정규화
    const normalizeColor = (color: any): string => {
      if (typeof color === 'string') return color;
      if (typeof color === 'object' && color?.primary) {
        return color.secondary ? `${color.primary}, ${color.secondary}` : color.primary;
      }
      return '';
    };

    // ✅ 헬퍼 함수: direction 객체/문자열 정규화
    const normalizeDirection = (direction: any): string => {
      if (typeof direction === 'string') return direction;
      if (typeof direction === 'object' && direction?.primary) return direction.primary;
      return '동쪽';
    };

    // 응답 데이터 구성 (하위 호환성 + 신규 상세 필드)
    const resultData = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'lucky-items',
      score: fortuneData.score || 75,
      content: fortuneData.content || fortuneData.summary || '오늘의 행운 아이템을 확인하세요.',
      summary: `오늘의 행운 키워드: ${fortuneData.keyword || '행운'}`,
      advice: normalizeAdvice(fortuneData.advice),

      // 기존 필드 유지 (하위 호환성) - 문자열/배열로 정규화
      title: fortuneData.title || `${name}님의 오늘 행운 아이템`,
      lucky_summary: fortuneData.summary || '',
      keyword: fortuneData.keyword || '',
      color: normalizeColor(fortuneData.color),
      numbers: fortuneData.numbers || [3, 7, 21],
      direction: normalizeDirection(fortuneData.direction),
      element: fortuneData.element || '금',
      fashion: normalizeToStringArray(fortuneData.fashion),
      food: normalizeToStringArray(fortuneData.food),
      jewelry: normalizeToStringArray(fortuneData.jewelry),
      material: normalizeToStringArray(fortuneData.material),
      places: normalizeToStringArray(fortuneData.places),
      relationships: normalizeToStringArray(fortuneData.relationships),
      lucky_advice: normalizeAdvice(fortuneData.advice),
      timestamp: new Date().toISOString(),
      isBlurred,
      blurredSections,

      // ✅ 신규 상세 필드 (reason 포함된 원본 객체)
      colorDetail: fortuneData.color,
      directionDetail: fortuneData.direction,
      fashionDetail: fortuneData.fashion,
      foodDetail: fortuneData.food,
      jewelryDetail: fortuneData.jewelry,
      materialDetail: fortuneData.material,
      placesDetail: fortuneData.places,
      relationshipsDetail: fortuneData.relationships,
      adviceDetail: fortuneData.advice,
      todayTip: fortuneData.todayTip || '',
    }

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabaseClient, 'lucky-items', resultData.score)
    const resultDataWithPercentile = addPercentileToResult(resultData, percentileData)

    const result: LuckyItemsResponse = {
      success: true,
      data: resultDataWithPercentile as LuckyItemsResponse['data'],
    }

    console.log(`[fortune-lucky-items] ✅ 응답 생성 완료`)

    return new Response(
      JSON.stringify(result),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )

  } catch (error) {
    console.error('[fortune-lucky-items] ❌ Error:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )
  }
})
