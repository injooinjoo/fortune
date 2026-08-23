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
import {
  extractLuckyItemsCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'
import {
  refundFortuneCharge,
  requirePaidFortuneCaller,
  storeFortuneResult,
  withTokenCharge,
} from '../_shared/fortune_charge.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 서버 차감 게이트 전용 클라이언트 (token RPC + fortune_result_cache 는 service_role 필요)
const fortuneChargeAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
)

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
  };
  error?: string;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // 차감 후 생성이 실패하면 catch 에서 환불하기 위한 핸들
  let paidCharge: { userId: string; idempotencyKey: string } | null = null

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

    const requestBody: LuckyItemsRequest = await req.json()
    const {
      userId,
      name,
      birthDate,
      birthTime,
      gender,
      interests,
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestBody

    // SECURITY: 서버에서 인증 + 토큰 차감. 클라 soul-consume 의존 제거.
    const paidCaller = await requirePaidFortuneCaller(
      req,
      fortuneChargeAdmin,
      'lucky-items',
      requestBody,
    )
    if ('error' in paidCaller) {
      return paidCaller.error
    }
    if (paidCaller.replayed) {
      // TTL 안의 동일 요청 — LLM 재호출 없이 저장된 응답 그대로.
      return new Response(
        JSON.stringify(withTokenCharge(paidCaller.cached, paidCaller.tokenCharge)),
        {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json; charset=utf-8'
          }
        }
      )
    }
    paidCharge = paidCaller

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
    console.log(`[fortune-lucky-items] 🎯 선택된 관심사:`, interests)

    // ✅ 카테고리 집중 로직 (선택된 카테고리에 3배 상세한 정보 제공)
    const categoryFocusMap: Record<string, string> = {
      'food': '🍽️ 음식/음료',
      'fashion': '👔 패션/액세서리',
      'color': '🎨 색상',
      'place': '🧭 장소/방향',
      'number': '🔢 숫자',
      'game': '🎮 게임/엔터테인먼트',
      'shopping': '🛍️ 쇼핑/구매',
      'health': '💪 운동/건강',
      'lifestyle': '🏠 라이프스타일'
    };

    // ✅ Cohort Pool 조회 (API 비용 90% 절감)
    const cohortData = extractLuckyItemsCohort({ category: interests?.[0], interests })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[fortune-lucky-items] 🔍 Cohort: ${JSON.stringify(cohortData)}, Hash: ${cohortHash.substring(0, 16)}...`)

    const cachedResult = await getFromCohortPool(supabaseClient, 'lucky-items', cohortHash)
    if (cachedResult) {
      console.log(`[fortune-lucky-items] ✅ Cohort Pool HIT! 캐시된 결과 사용`)

      // 개인화 후처리
      const personalizedResult = personalize(cachedResult, {
        userName: name,
        birthDate,
        gender,
        interests,
      })

      // ✅ Percentile 계산
      const percentileData = await calculatePercentile(supabaseClient, 'lucky-items', personalizedResult.score || 75)
      const resultWithPercentile = addPercentileToResult({
        ...personalizedResult,
        fortuneType: 'lucky-items',
        selectedCategory: interests?.[0] || 'fashion',
        selectedCategoryLabel: categoryFocusMap[interests?.[0] || 'fashion'] || 'fashion',
        timestamp: new Date().toISOString()
      }, percentileData)

      const cohortPayload = { success: true, data: resultWithPercentile }

      await storeFortuneResult(
        fortuneChargeAdmin,
        paidCaller.idempotencyKey,
        paidCaller.userId,
        'lucky-items',
        cohortPayload,
      )

      return new Response(
        JSON.stringify(withTokenCharge(cohortPayload, paidCaller.tokenCharge)),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    console.log(`[fortune-lucky-items] ⚡ Cohort Pool MISS - LLM 호출 필요`)

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('fortune-lucky-items')

    // 'all' 제거됨 - 기본값을 'fashion'으로 변경
    const selectedCategory = interests?.[0] || 'fashion';
    const categoryLabel = categoryFocusMap[selectedCategory] || selectedCategory;

    // 선택된 카테고리만 상세하게 생성
    const categoryFocusPrompt = `
## 🎯 집중 카테고리 (CRITICAL - 반드시 따르세요!)
사용자가 선택한 카테고리: **${categoryLabel}**

**중요 지시사항**:
1. 선택된 카테고리(${categoryLabel})를 **3배 더 상세하게** 작성하세요:
   - 구체적인 아이템 5개 이상
   - 각 아이템마다 상세한 이유, 활용법, 시간대별 추천 포함
   - 오행 연결 설명을 풍부하게

2. 나머지 카테고리는 **간략히** (각 1-2개 아이템, 짧은 이유만)

카테고리별 집중 가이드:
- 'food' → 음식 섹션: 아침/점심/저녁/간식별 추천, 조합 추천, 효능 상세 설명
- 'fashion' → 패션 섹션: 상의/하의/액세서리 조합, 색상 코디, 소재별 추천
- 'color' → 색상 섹션: 메인색/서브색/포인트색, 조합법, 피해야 할 색, 활용 장소
- 'place' → 장소/방향 섹션: 구체적 장소 5곳+ (예: "강남역 교보문고", "근처 대형마트 지하1층", "한강공원 잠원지구"), 방문 추천 시간대, 나침반 방향(동/서/남/북/동남/동북/서남/서북)
- 'number' → 숫자 섹션: 행운 숫자 3-4개 (1-30 범위), 각 숫자의 오행 의미, 활용법(비밀번호, 선택, 로또 등), 피해야 할 숫자
- 'game' → 게임/엔터 섹션: 행운의 게임 종류, 승률 높은 시간대, 피해야 할 게임
- 'shopping' → 쇼핑 섹션: 구매 추천 아이템, 쇼핑 장소, 최적 시간대, 할인받기 좋은 요일
- 'health' → 건강 섹션: 오늘 좋은 운동, 피해야 할 운동, 건강 관리 팁
- 'lifestyle' → 라이프스타일: 집안일 추천, 휴식 방법, 에너지 충전법
`;

    const systemPrompt = `당신은 동양 철학과 오행(五行) 이론에 기반한 행운 아이템 분석 전문가입니다.
사용자의 사주(생년월일/시)와 오늘의 기운을 종합하여 실질적인 행운 아이템을 추천합니다.

📅 **오늘 정보**: ${year}년 ${month}월 ${day}일 (${weekday}요일) ${timeOfDay}, ${season}
🌿 **계절 기운**: ${seasonElement} - ${season}의 기운이 강함
${categoryFocusPrompt}

**분석 프레임워크**:
1. 사주 오행 분석: 생년월일/시 → 부족한 오행 파악
2. 계절 오행 반영: ${season}철(${seasonElement}) 기운과의 조화
3. 시간대 최적화: ${timeOfDay}에 효과적인 아이템 우선
4. **선택 카테고리 집중**: 사용자가 선택한 ${categoryLabel} 카테고리를 최우선으로 상세 추천

**추천 원칙**:
- 모든 아이템마다 "왜 이것인지" 오행 기반 이유 필수
- 오늘 바로 실행 가능한 구체적 제안
- ${season}철에 특히 효과적인 아이템 우선
- **선택된 카테고리(${categoryLabel})는 다른 카테고리보다 3배 상세하게!**
- **오행 표기 형식**: 반드시 "목(木)", "화(火)", "토(土)", "금(金)", "수(水)" 형식 사용. "木" 또는 "목"만 단독 사용 금지!

**추천 카테고리** (각각 reason 포함):
- 색상: 행운 색상 + 오행 보완 이유 ${selectedCategory === 'color' ? '⭐ (상세히!)' : ''}
- 패션: 오늘 입으면 좋은 아이템 + 이유 ${selectedCategory === 'fashion' ? '⭐ (상세히!)' : ''}
- 숫자: 행운 숫자 ${selectedCategory === 'number' ? '⭐ (상세히!)' : ''}
- 음식: ${timeOfDay}에 먹으면 좋은 음식 + 이유 ${selectedCategory === 'food' ? '⭐ (상세히!)' : ''}
- 보석/액세서리: 에너지 보완 아이템 + 이유
- 소재: 오늘 좋은 소재 + 이유
- 방향: 행운의 방향 + 이유 ${selectedCategory === 'place' ? '⭐ (상세히!)' : ''}
- 장소: 가면 좋은 장소 + 이유 ${selectedCategory === 'place' ? '⭐ (상세히!)' : ''}
- 인연: 오늘 만나면 좋은 사람 특징 + 이유

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
  "title": "${name}님의 오늘 ${categoryLabel} 행운",
  "summary": "오행 분석 결과 한 줄 요약",
  "content": "${name}님의 사주를 분석한 결과... (3-4문장의 상세 본문. 오행 균형, 계절 영향, 오늘 특별히 중요한 포인트 설명)",
  "element": "주요 오행 - 반드시 '목(木)', '화(火)', '토(土)', '금(金)', '수(水)' 중 하나 선택",
  "keyword": "오늘의 핵심 키워드 3개 (쉼표 구분)",
  "color": {"primary": "메인 행운색", "secondary": "보조 행운색", "reason": "왜 이 색이 좋은지 오행 기반 설명"},
  "fashion": [
    {"item": "패션 아이템 1", "reason": "오행 보완 이유"},
    {"item": "패션 아이템 2", "reason": "오행 보완 이유"},
    {"item": "패션 아이템 3", "reason": "오행 보완 이유"}
  ],
  "numbers": [행운숫자1, 행운숫자2, 행운숫자3, 행운숫자4],
  "numbersExplanation": "각 숫자의 오행적 의미 설명 (예: 3은 목 기운...)",
  "avoidNumbers": [피해야할숫자1, 피해야할숫자2],
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
  "direction": {
    "primary": "동남",
    "compass": "동남",
    "angle": 135,
    "reason": "방향 추천 이유 (오행 기반)"
  },
  "places": [
    {"place": "강남역 교보문고", "category": "서점/도서관", "reason": "지식의 수(水) 기운", "timing": "오후 2-5시"},
    {"place": "근처 대형 백화점 5층", "category": "백화점", "reason": "금(金) 기운 보완", "timing": "저녁 시간"},
    {"place": "한강공원 잠원지구", "category": "공원/자연", "reason": "목(木) 기운 충전", "timing": "아침 일찍"},
    {"place": "동네 카페", "category": "카페", "reason": "화(火) 기운과 소통", "timing": "점심 후"},
    {"place": "미술관/갤러리", "category": "문화시설", "reason": "창의력 충전", "timing": "오후"}
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
    "overall": "오늘 하루 종합 조언"
  },
  "todayTip": "💡 오늘 핵심 팁 한 줄"
}
\`\`\`

**주의**:
1. 반드시 유효한 JSON 형식으로만 응답
2. content 필드는 반드시 3-4문장으로 작성
3. 모든 reason은 오행 이론에 기반하여 구체적으로 작성
4. **numbers는 반드시 1-30 범위의 정수 3-4개만** (예: [3, 7, 15, 22])
5. **direction.compass는 8방위 중 하나만** (동, 서, 남, 북, 동남, 동북, 서남, 서북)
6. **places는 구체적인 장소명 포함** (예: "강남역 교보문고", "이마트 성수점")`

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
      title: fortuneData.title || `${name}님의 오늘 ${categoryLabel} 행운`,
      // ✅ 선택된 카테고리 정보 추가 (UI에서 필터링용)
      selectedCategory: selectedCategory,
      selectedCategoryLabel: categoryLabel,
      lucky_summary: fortuneData.summary || '',
      keyword: fortuneData.keyword || '',
      color: normalizeColor(fortuneData.color),
      // 숫자: 1-30 범위로 필터링, 3-4개
      numbers: (fortuneData.numbers || [3, 7, 15, 22])
        .filter((n: number) => n >= 1 && n <= 30)
        .slice(0, 4),
      numbersExplanation: fortuneData.numbersExplanation || '',
      avoidNumbers: (fortuneData.avoidNumbers || [])
        .filter((n: number) => n >= 1 && n <= 30),
      direction: normalizeDirection(fortuneData.direction),
      directionCompass: fortuneData.direction?.compass || normalizeDirection(fortuneData.direction),
      directionAngle: fortuneData.direction?.angle || 0,
      element: fortuneData.element || '금',
      fashion: normalizeToStringArray(fortuneData.fashion),
      food: normalizeToStringArray(fortuneData.food),
      jewelry: normalizeToStringArray(fortuneData.jewelry),
      material: normalizeToStringArray(fortuneData.material),
      places: normalizeToStringArray(fortuneData.places),
      relationships: normalizeToStringArray(fortuneData.relationships),
      lucky_advice: normalizeAdvice(fortuneData.advice),
      timestamp: new Date().toISOString(),

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

    // ✅ Cohort Pool에 저장 (비동기, 에러 무시)
    saveToCohortPool(supabaseClient, 'lucky-items', cohortHash, cohortData, resultData)
      .then(() => console.log(`[fortune-lucky-items] 💾 Cohort Pool에 저장 완료`))
      .catch((err) => console.warn(`[fortune-lucky-items] ⚠️ Cohort Pool 저장 실패 (무시됨):`, err.message))

    const result: LuckyItemsResponse = {
      success: true,
      data: resultDataWithPercentile as LuckyItemsResponse['data'],
    }

    console.log(`[fortune-lucky-items] ✅ 응답 생성 완료`)

    await storeFortuneResult(
      fortuneChargeAdmin,
      paidCaller.idempotencyKey,
      paidCaller.userId,
      'lucky-items',
      result,
    )

    return new Response(
      JSON.stringify(withTokenCharge(result, paidCaller.tokenCharge)),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )

  } catch (error) {
    console.error('[fortune-lucky-items] ❌ Error:', error)

    // 차감 후 생성 실패 — 환불 후 에러 응답
    if (paidCharge) {
      await refundFortuneCharge(
        fortuneChargeAdmin,
        paidCharge.userId,
        paidCharge.idempotencyKey,
        'lucky-items',
      )
    }

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
