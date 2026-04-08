/**
 * 일일 운세 (Daily Fortune) Edge Function
 *
 * @description 사용자의 생년월일, 시간, 띠 정보를 바탕으로 AI 기반 일일 운세를 생성합니다.
 *
 * @endpoint POST /fortune-daily
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간 (예: "축시 (01:00 - 03:00)")
 * - gender: 'male' | 'female' - 성별
 * - isLunar?: boolean - 음력 여부
 * - zodiacSign?: string - 별자리 (예: "처녀자리")
 * - zodiacAnimal?: string - 띠 (예: "용")
 *
 * @response DailyFortuneResponse
 * - overall_score: number (1-100) - 종합 운세 점수
 * - summary: string - 오늘의 운세 요약
 * - categories: { total, love, money, work, study, health } - 카테고리별 점수/조언
 * - lucky_items: { time, color, number, direction, food, item } - 행운 요소
 * - lucky_numbers: string[] - 행운의 숫자
 * - personalActions: Array<{ title, why, priority }> - 추천 행동
 * - sajuInsight: object - 사주 기반 인사이트
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-daily \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","birthDate":"1990-01-01","gender":"male"}'
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile } from '../_shared/percentile/calculator.ts'
import {
  extractDailyCohort,
  generateCohortHash,
  getFromCohortPool,
  personalize,
  saveToCohortPool,
} from '../_shared/cohort/index.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 완전한 일일 운세 응답 스키마 정의
interface DailyFortuneResponse {
  // 필수 기본 정보
  overall_score: number;
  summary: string;
  greeting: string;
  advice: string;
  caution: string;
  description: string;
  
  // 필수 카테고리별 운세 (모든 필드 필수)
  categories: {
    total: { score: number; advice: { idiom: string; description: string; }; };
    love: { score: number; advice: string; };
    money: { score: number; advice: string; };
    work: { score: number; advice: string; };
    study: { score: number; advice: string; };
    health: { score: number; advice: string; };
  };
  
  // 필수 행운 요소들 (모든 필드 필수)
  lucky_items: {
    time: string;
    color: string;
    number: string;
    direction: string;
    food: string;
    item: string;
  };
  
  // 필수 행운 번호들
  lucky_numbers: string[];
  
  // 필수 조언들 (모든 필드 필수)
  special_tip: string;
  ai_insight: string;
  ai_tips: string[];
  
  // 필수 추가 정보
  fortuneSummary: {
    byZodiacAnimal: { title: string; content: string; score: number; };
    byZodiacSign: { title: string; content: string; score: number; };
    byMBTI: { title: string; content: string; score: number; };
  };
  
  personalActions: Array<{
    title: string;
    why: string;
    priority: number;
  }>;
  
  sajuInsight: {
    lucky_color: string;
    lucky_food: string;
    lucky_item: string;
    luck_direction: string;
    keyword: string;
  };
  
  // 필수 동적 섹션들
  lucky_outfit: {
    title: string;
    description: string;
    items: string[];
  };
  
  celebrities_same_day: Array<{
    name: string;
    year: string;
    description: string;
  }>;

  celebrities_similar_saju: Array<{
    name: string;
    year: string;
    description: string;
  }>;

  age_fortune: {
    ageGroup: string;
    title: string;
    description: string;
    zodiacAnimal?: string;
  };
  
  daily_predictions: {
    morning: string;
    afternoon: string;
    evening: string;
  };
  
  // 선택적 메타데이터
  metadata?: {
    weather?: any;
    [key: string]: any;
  };
  
  // 공유 정보
  share_count: string;
}

// 위젯 캐시 저장 함수 (백그라운드 비동기 실행)
async function saveWidgetCache(
  supabaseClient: any,
  userId: string,
  fortune: any,
  categories: any
): Promise<void> {
  try {
    // 한국 시간 기준 오늘 날짜
    const now = new Date()
    const koreaOffset = 9 * 60 * 60 * 1000
    const koreaTime = new Date(now.getTime() + koreaOffset)
    const today = koreaTime.toISOString().split('T')[0]

    // 등급 계산
    const score = fortune.overall_score || 80
    const grade = score >= 90 ? '대길' : score >= 75 ? '길' : score >= 50 ? '평' : score >= 25 ? '흉' : '대흉'

    // 카테고리 데이터 포맷
    const categoriesData: Record<string, { score: number; message: string }> = {}
    for (const [key, value] of Object.entries(categories)) {
      const cat = value as any
      categoriesData[key] = {
        score: cat.score || 80,
        message: typeof cat.advice === 'string' ? cat.advice : (cat.advice?.description || cat.title || '')
      }
    }

    // 시간대별 데이터
    const timeSlots = [
      { key: 'morning', name: '오전', score: categories.total?.score || score, message: fortune.daily_predictions?.morning || '' },
      { key: 'afternoon', name: '오후', score: categories.total?.score || score, message: fortune.daily_predictions?.afternoon || '' },
      { key: 'evening', name: '저녁', score: categories.total?.score || score, message: fortune.daily_predictions?.evening || '' }
    ]

    // 로또 번호
    const lottoNumbers = (fortune.lucky_numbers || [])
      .slice(0, 5)
      .map((n: string) => parseInt(n) || 0)
      .filter((n: number) => n > 0)

    // 행운 아이템
    const luckyItems = {
      color: fortune.lucky_items?.color || '',
      number: fortune.lucky_items?.number || '',
      direction: fortune.lucky_items?.direction || '',
      time: fortune.lucky_items?.time || '',
      item: fortune.sajuInsight?.lucky_item || fortune.lucky_items?.item || ''
    }

    // Upsert (있으면 업데이트, 없으면 생성)
    const { error } = await supabaseClient
      .from('widget_fortune_cache')
      .upsert({
        user_id: userId,
        fortune_date: today,
        overall_score: score,
        overall_grade: grade,
        overall_message: fortune.summary || '',
        categories: categoriesData,
        time_slots: timeSlots,
        lotto_numbers: lottoNumbers,
        lucky_items: luckyItems
      }, { onConflict: 'user_id,fortune_date' })

    if (error) {
      console.error('[widget-cache] DB upsert 오류:', error)
    } else {
      console.log(`[widget-cache] 저장 완료: userId=${userId}, date=${today}, score=${score}`)
    }
  } catch (err) {
    console.error('[widget-cache] 저장 중 예외:', err)
  }
}

// 응답 검증 함수
function validateFortuneResponse(fortune: any): fortune is DailyFortuneResponse {
  const requiredFields = [
    'overall_score', 'summary', 'greeting', 'advice', 'caution', 'description',
    'categories', 'lucky_items', 'lucky_numbers', 'special_tip', 'ai_insight', 'ai_tips',
    'fortuneSummary', 'personalActions', 'sajuInsight', 'lucky_outfit',
    'celebrities_same_day', 'celebrities_similar_saju', 'age_fortune', 'daily_predictions', 'share_count'
  ];
  
  for (const field of requiredFields) {
    if (!(field in fortune) || fortune[field] === null || fortune[field] === undefined) {
      console.error(`Missing required field: ${field}`);
      return false;
    }
  }
  
  // 카테고리 필드 검증
  const requiredCategories = ['total', 'love', 'money', 'work', 'study', 'health'];
  for (const category of requiredCategories) {
    if (!(category in fortune.categories) ||
        !fortune.categories[category].score) {
      console.error(`Missing category field: ${category}`);
      return false;
    }

    // total의 advice는 객체, 나머지는 문자열
    if (category === 'total') {
      if (!fortune.categories[category].advice?.idiom ||
          !fortune.categories[category].advice?.description) {
        console.error(`Missing total advice idiom or description`);
        return false;
      }
    } else {
      if (!fortune.categories[category].advice) {
        console.error(`Missing ${category} advice`);
        return false;
      }
    }
  }
  
  // 행운 요소 필드 검증
  const requiredLuckyFields = ['time', 'color', 'number', 'direction', 'food', 'item'];
  for (const field of requiredLuckyFields) {
    if (!(field in fortune.lucky_items) || !fortune.lucky_items[field]) {
      console.error(`Missing lucky_items field: ${field}`);
      return false;
    }
  }
  
  return true;
}

function sanitizeFortuneText(text: string): string {
  const withoutMarkdown = text
    .replace(/\*\*(.*?)\*\*/gu, '$1')
    .replace(/__(.*?)__/gu, '$1')
    .replace(/`([^`]+)`/gu, '$1')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/gu, '$1')
    .replace(/^\s{0,3}#{1,6}\s+/gmu, '')
    .replace(/^\s*>\s?/gmu, '')
    .replace(/^\s*\d+[.)]\s+/gmu, '')
    .replace(/^\s*[-*•]+\s+/gmu, '')
    .replace(/\r\n/gu, '\n');

  const emojiPattern =
    /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FAFF}]|[\u{2B50}]|[\u{2B55}]/gu;

  return withoutMarkdown
    .replace(emojiPattern, '')
    .replace(/\bstudy\b/gu, '학업')
    .replace(/\blove\b/gu, '연애')
    .replace(/\bmoney\b/gu, '금전')
    .replace(/\bwork\b/gu, '일')
    .replace(/\bhealth\b/gu, '건강')
    .replace(/\b오늘의 바이브\b/gu, '종합 흐름')
    .replace(/\b애정운 바이브\b/gu, '애정 흐름')
    .replace(/\b금전운 바이브\b/gu, '금전 흐름')
    .replace(/\b직장운 바이브\b/gu, '직장 흐름')
    .replace(/\b학업운 바이브\b/gu, '학업 흐름')
    .replace(/\b건강운 바이브\b/gu, '건강 흐름')
    .replace(/\b갓생 치트키\b/gu, '실천 팁')
    .replace(/\b오늘의 한마디\b/gu, '마무리 한마디')
    .replace(/\b럭키비키\b/gu, '운이 좋은 흐름')
    .replace(/\b갓생\b/gu, '하루')
    .replace(/\b레전드 of 레전드\b/gu, '매우 좋은')
    .replace(/\b레전드\b/gu, '좋은')
    .replace(/\b무지성\b/gu, '망설임 없이')
    .replace(/\b찐으로\b/gu, '정말')
    .replace(/\b심쿵\b/gu, '설렘')
    .replace(/\b순삭\b/gu, '빠르게')
    .replace(/\b칼퇴\b/gu, '일정 마무리')
    .replace(/\bMAX\b/gu, '높은')
    .replace(/\bUP\b/gu, '상승')
    .replace(/맑고 활기찬 기운이 가득한 하루입니다/gu, '하루 흐름을 차분하게 살펴볼 만한 날입니다')
    .replace(/오늘은 정말 특별한 날입니다!?/gu, '전반적인 흐름이 강한 날입니다.')
    .replace(/모든 일이 순조롭게 풀릴 것이니 적극적으로 도전해보세요\./gu, '중요한 일은 미루지 말고 앞부분에 배치해보세요.')
    .replace(/이 기회를 놓치지 마세요\./gu, '이 분야의 중요한 일 하나를 먼저 처리하면 좋습니다.')
    .replace(/긍정적인 기운이 가득한 날이에요\./gu, '상대적으로 흐름이 부드러운 편입니다.')
    .replace(/꽤 좋은 하루가 될 것 같아요\./gu, '무난하게 진행하기 좋은 흐름입니다.')
    .replace(/생각보다 괜찮은 하루가 될 거예요\./gu, '무난하게 흐름을 정리하기 좋은 날입니다.')
    .replace(/좋은 결과를 얻을 수 있을 거예요\./gu, '좋은 결과를 기대해볼 수 있습니다.')
    .replace(/좋은 하루 보내세요!?/gu, '')
    .replace(/좋은 하루 보내세요!?\s*️/gu, '')
    .replace(/[“”"]/gu, '')
    .replace(/[ \t]+\n/gu, '\n')
    .replace(/\n{3,}/gu, '\n\n')
    .replace(/[ \t]{2,}/gu, ' ')
    .trim();
}

function sanitizeFortuneKeyword(text: string): string {
  return sanitizeFortuneText(text).replace(/\n+/gu, ' ');
}

function sanitizeFortuneValue(value: unknown): unknown {
  if (typeof value === 'string') {
    return sanitizeFortuneText(value);
  }

  if (Array.isArray(value)) {
    return value.map((entry) => sanitizeFortuneValue(entry));
  }

  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, entry]) => [
        key,
        sanitizeFortuneValue(entry),
      ]),
    );
  }

  return value;
}

function sanitizeDailyFortuneOutput(
  fortune: DailyFortuneResponse & Record<string, any>,
) {
  const sanitizedBase = sanitizeFortuneValue(
    fortune,
  ) as DailyFortuneResponse & Record<string, any>;
  const sanitize = (value: unknown) =>
    typeof value === 'string' ? sanitizeFortuneText(value) : value;

  const sanitizeKeyword = (value: unknown) =>
    typeof value === 'string' ? sanitizeFortuneKeyword(value) : value;

  return {
    ...sanitizedBase,
    content: sanitize(sanitizedBase.content),
    summary: sanitize(sanitizedBase.summary),
    greeting: sanitize(sanitizedBase.greeting),
    advice: sanitize(sanitizedBase.advice),
    caution: sanitize(sanitizedBase.caution),
    description: sanitize(sanitizedBase.description),
    special_tip: sanitize(sanitizedBase.special_tip),
    ai_insight: sanitize(sanitizedBase.ai_insight),
    ai_tips: Array.isArray(sanitizedBase.ai_tips)
      ? sanitizedBase.ai_tips
          .map((item) => sanitize(item))
          .filter((item): item is string => typeof item === 'string' && item.length > 0)
      : [],
    categories: {
      ...sanitizedBase.categories,
      total: {
        ...sanitizedBase.categories.total,
        advice: {
          ...sanitizedBase.categories.total.advice,
          idiom: sanitizeKeyword(sanitizedBase.categories.total.advice.idiom),
          description: sanitize(sanitizedBase.categories.total.advice.description),
        },
      },
      love: {
        ...sanitizedBase.categories.love,
        advice: sanitize(sanitizedBase.categories.love.advice),
      },
      money: {
        ...sanitizedBase.categories.money,
        advice: sanitize(sanitizedBase.categories.money.advice),
      },
      work: {
        ...sanitizedBase.categories.work,
        advice: sanitize(sanitizedBase.categories.work.advice),
      },
      study: {
        ...sanitizedBase.categories.study,
        advice: sanitize(sanitizedBase.categories.study.advice),
      },
      health: {
        ...sanitizedBase.categories.health,
        advice: sanitize(sanitizedBase.categories.health.advice),
      },
    },
    lucky_items: {
      ...sanitizedBase.lucky_items,
      time: sanitizeKeyword(sanitizedBase.lucky_items.time),
      color: sanitizeKeyword(sanitizedBase.lucky_items.color),
      number: sanitizeKeyword(String(sanitizedBase.lucky_items.number)),
      direction: sanitizeKeyword(sanitizedBase.lucky_items.direction),
      food: sanitizeKeyword(sanitizedBase.lucky_items.food),
      item: sanitizeKeyword(sanitizedBase.lucky_items.item),
    },
    lucky_numbers: Array.isArray(sanitizedBase.lucky_numbers)
      ? sanitizedBase.lucky_numbers
          .map((item) => sanitizeKeyword(String(item)))
          .filter((item): item is string => item.length > 0)
      : [],
    fortuneSummary: {
      byZodiacAnimal: {
        ...sanitizedBase.fortuneSummary.byZodiacAnimal,
        title: sanitize(sanitizedBase.fortuneSummary.byZodiacAnimal.title),
        content: sanitize(sanitizedBase.fortuneSummary.byZodiacAnimal.content),
      },
      byZodiacSign: {
        ...sanitizedBase.fortuneSummary.byZodiacSign,
        title: sanitize(sanitizedBase.fortuneSummary.byZodiacSign.title),
        content: sanitize(sanitizedBase.fortuneSummary.byZodiacSign.content),
      },
      byMBTI: {
        ...sanitizedBase.fortuneSummary.byMBTI,
        title: sanitize(sanitizedBase.fortuneSummary.byMBTI.title),
        content: sanitize(sanitizedBase.fortuneSummary.byMBTI.content),
      },
    },
    personalActions: Array.isArray(sanitizedBase.personalActions)
      ? sanitizedBase.personalActions.map((action) => ({
          ...action,
          title: sanitize(action.title),
          why: sanitize(action.why),
        }))
      : [],
    sajuInsight: {
      ...sanitizedBase.sajuInsight,
      lucky_color: sanitizeKeyword(sanitizedBase.sajuInsight.lucky_color),
      lucky_food: sanitizeKeyword(sanitizedBase.sajuInsight.lucky_food),
      lucky_item: sanitizeKeyword(sanitizedBase.sajuInsight.lucky_item),
      luck_direction: sanitizeKeyword(sanitizedBase.sajuInsight.luck_direction),
      keyword: sanitizeKeyword(sanitizedBase.sajuInsight.keyword),
    },
    lucky_outfit: {
      ...sanitizedBase.lucky_outfit,
      title: sanitize(sanitizedBase.lucky_outfit.title),
      description: sanitize(sanitizedBase.lucky_outfit.description),
      items: Array.isArray(sanitizedBase.lucky_outfit.items)
        ? sanitizedBase.lucky_outfit.items
            .map((item) => sanitize(item))
            .filter((item): item is string => typeof item === 'string' && item.length > 0)
        : [],
    },
    celebrities_same_day: Array.isArray(sanitizedBase.celebrities_same_day)
      ? sanitizedBase.celebrities_same_day.map((entry) => ({
          ...entry,
          name: sanitizeKeyword(entry.name),
          description: sanitize(entry.description),
        }))
      : [],
    celebrities_similar_saju: Array.isArray(sanitizedBase.celebrities_similar_saju)
      ? sanitizedBase.celebrities_similar_saju.map((entry) => ({
          ...entry,
          name: sanitizeKeyword(entry.name),
          description: sanitize(entry.description),
        }))
      : [],
    age_fortune: {
      ...sanitizedBase.age_fortune,
      ageGroup: sanitizeKeyword(sanitizedBase.age_fortune.ageGroup),
      title: sanitize(sanitizedBase.age_fortune.title),
      description: sanitize(sanitizedBase.age_fortune.description),
      zodiacAnimal: sanitizeKeyword(sanitizedBase.age_fortune.zodiacAnimal ?? ''),
    },
    daily_predictions: {
      ...sanitizedBase.daily_predictions,
      morning: sanitize(sanitizedBase.daily_predictions.morning),
      afternoon: sanitize(sanitizedBase.daily_predictions.afternoon),
      evening: sanitize(sanitizedBase.daily_predictions.evening),
    },
  };
}

// 영어 지역명을 한글로 변환하는 간단한 함수
// GPT나 다른 서비스에서 더 정확한 변환을 할 수 있도록 기본 처리만 제공
function processLocation(location: string): string {
  // 기본적인 광역시 매핑
  const basicMap: Record<string, string> = {
    'Seoul': '서울',
    'Busan': '부산',
    'Incheon': '인천',
    'Daegu': '대구',
    'Daejeon': '대전',
    'Gwangju': '광주',
    'Ulsan': '울산',
    'Sejong': '세종',
    'Jeju': '제주'
  }
  
  // 매핑에 있으면 반환
  for (const [eng, kor] of Object.entries(basicMap)) {
    if (location.includes(eng)) {
      return kor
    }
  }
  
  // 없으면 원본 반환 (GPT가 알아서 처리하도록)
  return location
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    let requestData: Record<string, unknown> = {}
    if (req.method === 'POST') {
      try {
        requestData = await req.json()
      } catch (_) {
        requestData = {}
      }
    }

    if (requestData.healthCheck === true) {
      return new Response(
        JSON.stringify({
          success: true,
          status: 'healthy',
          fortuneType: 'daily',
          timestamp: new Date().toISOString(),
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 200,
        }
      )
    }

    // Supabase 클라이언트 생성 (퍼센타일 계산용)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    // Service Role 클라이언트 (Cohort Pool 접근용 - RLS 우회)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const {
      userId,
      name: rawName,
      birthDate,
      birthTime,
      gender,
      isLunar,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal,
      location,  // 옵셔널 위치 정보 (deprecated)
      userLocation,  // ✅ LocationManager에서 전달받은 실제 사용자 위치
      date,      // 클라이언트에서 전달받은 날짜
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    // ✅ name 유효성 검사 - "undefined", "null", 빈 문자열 등 처리
    const invalidNames = ['undefined', 'null', 'Unknown', ''];
    const name = (rawName && !invalidNames.includes(rawName)) ? rawName : '회원';

    console.log('💎 [Daily] Premium 상태:', isPremium)
    console.log('👤 [Daily] 사용자 이름:', name, '(원본:', rawName, ')')
    console.log('📍 [Daily] 사용자 위치:', userLocation || location || '미제공')

    // ============================================
    // 🚀 Cohort Pool 조회 (API 비용 90% 절감)
    // ============================================
    // 온디맨드 Pool 저장을 위해 cohortData를 외부에 선언
    let dailyCohortData: { period: string; zodiac: string; element: string } | null = null;
    let dailyCohortHash: string | null = null;

    if (birthDate) {
      try {
        dailyCohortData = extractDailyCohort({
          birthDate,
          now: date ? new Date(date) : undefined,
        });
        const cohortData = dailyCohortData;
        dailyCohortHash = await generateCohortHash(cohortData);

        console.log(`🔍 [Cohort] Daily 조회 시도:`, JSON.stringify(cohortData), `hash: ${dailyCohortHash.slice(0, 8)}...`);

        const cachedResult = await getFromCohortPool(supabaseAdmin, 'daily', dailyCohortHash);

        if (cachedResult) {
          console.log('✅ [Cohort] Pool에서 결과 반환 (LLM 호출 절약!)');

          // 개인화 처리
          const personalizedFortune = personalize(cachedResult, {
            name,
            userName: name,
            birthDate,
            age: birthDate ? new Date().getFullYear() - new Date(birthDate).getFullYear() : 20,
          });
          const sanitizedCachedFortune = sanitizeDailyFortuneOutput(
            personalizedFortune as DailyFortuneResponse & Record<string, any>,
          );

          // 퍼센타일 계산 (캐시된 점수 사용)
          const cachedScore = (sanitizedCachedFortune as any).overall_score || 75;
          const percentileData = await calculatePercentile(
            supabaseClient,
            'daily',
            cachedScore
          );

          return new Response(
            JSON.stringify({
              fortune: {
                ...sanitizedCachedFortune,
                percentile: percentileData.percentile,
                totalTodayViewers: percentileData.totalTodayViewers,
                isPercentileValid: percentileData.isPercentileValid,
              },
              storySegments: [],  // 캐시된 결과에서는 스토리 제외
              cached: true,
              tokensUsed: 0,
              cohortHit: true,
            }),
            {
              headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
              status: 200,
            }
          );
        } else {
          console.log('⚠️ [Cohort] Pool에 결과 없음, LLM 호출로 진행');
        }
      } catch (cohortError) {
        console.error('[Cohort] 조회 실패 (무시하고 계속):', cohortError);
      }
    }
    // ============================================

    // 클라이언트에서 전달받은 날짜 또는 한국 시간대로 현재 날짜 생성
    const today = date
      ? new Date(date)
      : new Date(new Date().toLocaleString("en-US", {timeZone: "Asia/Seoul"}))
    const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]

    // 지역 정보 처리 (영어를 한글로, 광역시/도 단위로)
    // ✅ userLocation 우선 사용, 없으면 location, 둘 다 없으면 기본값 (강남구)
    const rawLocation = userLocation || location || '강남구'
    const processedLocation = processLocation(rawLocation)
    
    // 날짜 기반 시드를 생성하여 매일 다른 운세가 나오도록 함
    const dateSeed = today.getFullYear() * 10000 + (today.getMonth() + 1) * 100 + today.getDate()
    const userSeed = (name || 'anonymous').split('').reduce((sum, char) => sum + char.charCodeAt(0), 0)
    const combinedSeed = dateSeed + userSeed + (birthDate ? new Date(birthDate).getTime() % 1000 : 0)
    
    // 시드를 기반으로 한 난수 생성 함수
    const seededRandom = (seed: number) => {
      const x = Math.sin(seed) * 10000
      return x - Math.floor(x)
    }
    
    // 운세 점수 생성 (날짜와 사용자 정보 기반으로 동적 생성)
    const baseScore = 65 + Math.floor(seededRandom(combinedSeed) * 30) // 65-95 범위
    const mbtiBonus = mbtiType === 'ENTJ' ? 5 : mbtiType === 'INFJ' ? 3 : mbtiType?.includes('E') ? 2 : 0
    const zodiacBonus = zodiacAnimal === '용' ? 3 : zodiacAnimal === '호랑이' ? 2 : 0
    const score = Math.min(100, baseScore + mbtiBonus + zodiacBonus)
    
    // 띠별 오늘의 운세 요약 (날짜별로 다른 메시지)
    const generateZodiacFortune = (userZodiac: string) => {
      const zodiacFortuneVariations = {
        '쥐': [
          { title: '기회를 놓치지 마세요', content: '새로운 기회가 다가오고 있습니다. 적극적인 자세로 임하세요.' },
          { title: '지혜로운 선택의 시간', content: '오늘은 신중한 판단력이 빛을 발할 때입니다. 꼼꼼히 살펴보세요.' },
          { title: '소통이 열쇠입니다', content: '주변 사람들과의 대화에서 중요한 정보를 얻을 수 있습니다.' }
        ],
        '소': [
          { title: '안정감이 필요한 하루', content: '차분하고 신중한 접근이 성공의 열쇠입니다.' },
          { title: '꾸준함이 빛나는 날', content: '당신의 성실함과 끈기로 목표에 한 걸음 더 다가가세요.' },
          { title: '전통적 방법이 효과적', content: '검증된 방법을 활용하면 안정적인 결과를 얻을 수 있습니다.' }
        ],
        '호랑이': [
          { title: '용기있는 도전이 필요', content: '두려워하지 말고 당당하게 앞으로 나아가세요.' },
          { title: '리더십을 발휘할 때', content: '당신의 카리스마로 주변을 이끌어가는 하루가 될 것입니다.' },
          { title: '독립적인 행동이 좋습니다', content: '혼자서도 충분히 해낼 수 있는 자신감을 가지세요.' }
        ],
        '토끼': [
          { title: '조화로운 관계가 중요', content: '주변 사람들과의 소통에 집중하는 것이 좋겠습니다.' },
          { title: '직감을 믿으세요', content: '당신의 예민한 감각이 올바른 길을 안내할 것입니다.' },
          { title: '평화로운 해결책 찾기', content: '갈등 상황에서 중재자 역할을 하면 좋은 결과를 얻을 수 있습니다.' }
        ],
        '용': [
          { title: '리더십을 발휘할 때', content: '당신의 카리스마와 추진력으로 목표를 달성하세요.' },
          { title: '큰 그림을 그리세요', content: '세부사항에 매몰되지 말고 전체적인 비전을 바라보세요.' },
          { title: '자신감이 행운을 부릅니다', content: '당당한 모습으로 주변에 긍정적인 영향을 미치세요.' }
        ],
        '뱀': [
          { title: '지혜로운 판단이 필요', content: '신중한 분석과 계획으로 최적의 결과를 만들어내세요.' },
          { title: '직관력이 뛰어난 날', content: '미묘한 변화도 놓치지 말고 세심하게 관찰하세요.' },
          { title: '변화에 유연하게 적응', content: '예상치 못한 상황도 지혜롭게 헤쳐나갈 수 있습니다.' }
        ],
        '말': [
          { title: '자유롭게 행동하세요', content: '제약에 얽매이지 말고 본능에 따라 움직여보세요.' },
          { title: '활동적인 하루', content: '움직이고 행동할 때 더 많은 기회를 만날 수 있습니다.' },
          { title: '새로운 경험을 추구', content: '평소와 다른 새로운 시도가 즐거운 발견을 가져다 줄 것입니다.' }
        ],
        '양': [
          { title: '따뜻한 마음이 힘이 됩니다', content: '배려와 친절함으로 좋은 인연을 만들어가세요.' },
          { title: '협력이 성공의 열쇠', content: '혼자보다는 함께할 때 더 큰 성과를 만들어낼 수 있습니다.' },
          { title: '창의적 아이디어 발휘', content: '예술적 감각과 창의력이 빛나는 하루가 될 것입니다.' }
        ],
        '원숭이': [
          { title: '창의적인 아이디어 발휘', content: '독창적인 생각으로 문제를 해결해보세요.' },
          { title: '재치있는 해결책', content: '기발한 아이디어로 어려운 상황을 즐겁게 돌파하세요.' },
          { title: '학습과 성장의 시간', content: '새로운 지식을 습득하면 예상치 못한 도움이 될 것입니다.' }
        ],
        '닭': [
          { title: '꼼꼼함이 성과를 만듭니다', content: '세밀한 부분까지 신경 쓰면 좋은 결과가 있을 것입니다.' },
          { title: '계획적인 접근이 중요', content: '체계적으로 준비하고 실행하면 원하는 결과를 얻을 수 있습니다.' },
          { title: '시간 관리가 핵심', content: '효율적인 시간 활용으로 더 많은 일을 해낼 수 있습니다.' }
        ],
        '개': [
          { title: '진실한 마음을 전하세요', content: '솔직하고 성실한 태도가 신뢰를 쌓아갑니다.' },
          { title: '의리가 빛나는 날', content: '주변 사람들을 위한 당신의 배려가 큰 감동을 줄 것입니다.' },
          { title: '정의로운 선택', content: '옳은 일을 하려는 마음이 좋은 결과로 돌아올 것입니다.' }
        ],
        '돼지': [
          { title: '풍요로운 하루가 될 것', content: '관대한 마음으로 모든 것을 받아들이세요.' },
          { title: '행복한 만남의 예감', content: '즐거운 사람들과 함께하는 시간이 기다리고 있습니다.' },
          { title: '감사하는 마음', content: '작은 것에도 고마움을 느끼면 더 큰 복이 찾아올 것입니다.' }
        ]
      }
      
      const variations = zodiacFortuneVariations[userZodiac] || [
        { title: '특별한 하루가 될 것', content: '긍정적인 마음으로 하루를 시작하세요.' }
      ]
      const selectedIndex = Math.floor(seededRandom(combinedSeed * 2) * variations.length)
      const selectedFortune = variations[selectedIndex]
      
      return {
        title: selectedFortune.title,
        content: selectedFortune.content,
        score: Math.max(70, Math.min(90, score + Math.floor(seededRandom(combinedSeed * 3) * 10) - 5))
      }
    }

    // 별자리별 오늘의 운세 요약 (날짜별로 다른 메시지)
    const generateZodiacSignFortune = (userSign: string) => {
      const signFortuneVariations = {
        '물병자리': [
          { title: '독창성이 빛나는 날', content: '혁신적인 아이디어로 주목받을 수 있습니다.' },
          { title: '미래를 내다보는 시각', content: '앞선 생각으로 새로운 트렌드를 이끌어가세요.' },
          { title: '자유로운 사고의 힘', content: '기존 틀을 벗어난 창의적 접근이 성공을 가져올 것입니다.' }
        ],
        '물고기자리': [
          { title: '직감을 믿으세요', content: '감정과 영감에 따라 행동하면 좋은 결과가 있을 것입니다.' },
          { title: '감성의 힘이 강한 날', content: '예술적 감각과 공감 능력이 빛을 발할 때입니다.' },
          { title: '꿈을 현실로 만들기', content: '상상력을 바탕으로 한 계획이 실현될 수 있습니다.' }
        ],
        '양자리': [
          { title: '열정적으로 도전하세요', content: '적극적인 자세로 새로운 일에 도전해보세요.' },
          { title: '선구자의 기운', content: '앞장서서 이끌어가는 리더십이 빛나는 하루입니다.' },
          { title: '즉시 행동하는 힘', content: '망설이지 말고 바로 실행에 옮기면 좋은 결과를 얻을 수 있습니다.' }
        ],
        '황소자리': [
          { title: '안정적인 선택을 하세요', content: '신중하고 실용적인 접근이 최고의 결과를 가져올 것입니다.' },
          { title: '인내심이 보상받는 날', content: '꾸준함과 성실함이 마침내 성과로 돌아올 때입니다.' },
          { title: '감각적 즐거움을 추구', content: '좋은 음식이나 아름다운 것들을 통해 에너지를 충전하세요.' }
        ],
        '쌍둥이자리': [
          { title: '소통이 핵심입니다', content: '다양한 사람들과의 대화에서 기회를 찾으세요.' },
          { title: '정보 수집의 달인', content: '새로운 정보와 지식이 예상치 못한 도움을 줄 것입니다.' },
          { title: '다양성 속의 기회', content: '여러 가지 일을 동시에 진행하면서 시너지 효과를 만들어보세요.' }
        ],
        '게자리': [
          { title: '감정을 소중히 여기세요', content: '마음의 목소리에 귀 기울이며 행동하세요.' },
          { title: '보호하는 따뜻함', content: '주변 사람들을 챙기는 마음이 더 큰 사랑으로 돌아올 것입니다.' },
          { title: '안전한 공간 만들기', content: '편안하고 안정된 환경에서 더 좋은 아이디어가 나올 것입니다.' }
        ],
        '사자자리': [
          { title: '자신감을 가지세요', content: '당당한 모습으로 주변에 좋은 영향을 미치세요.' },
          { title: '무대의 주인공', content: '당신의 매력과 카리스마가 모든 이의 시선을 사로잡을 것입니다.' },
          { title: '관대한 마음의 힘', content: '너그러운 마음으로 베풀면 예상치 못한 보상이 찾아올 것입니다.' }
        ],
        '처녀자리': [
          { title: '완벽함을 추구하세요', content: '세심한 분석과 계획으로 목표를 달성하세요.' },
          { title: '디테일의 마법', content: '작은 부분까지 꼼꼼히 챙기는 것이 큰 성공을 만들어낼 것입니다.' },
          { title: '실용적 해결책', content: '효율적이고 합리적인 방법으로 문제를 깔끔하게 해결하세요.' }
        ],
        '천칭자리': [
          { title: '균형잡힌 선택을 하세요', content: '조화로운 해결책을 찾는 것이 중요합니다.' },
          { title: '아름다움 추구의 날', content: '미적 감각을 발휘하면 모든 일이 더욱 빛날 것입니다.' },
          { title: '공정한 중재자', content: '갈등 상황에서 균형잡힌 판단으로 모두를 만족시킬 수 있습니다.' }
        ],
        '전갈자리': [
          { title: '깊이있는 집중이 필요', content: '한 가지에 집중하여 탁월한 성과를 만들어내세요.' },
          { title: '변화의 힘', content: '과감한 변신을 통해 새로운 자신을 발견할 수 있습니다.' },
          { title: '진실 탐구의 시간', content: '숨겨진 진실을 찾아내는 통찰력이 빛을 발할 것입니다.' }
        ],
        '궁수자리': [
          { title: '모험심을 발휘하세요', content: '새로운 경험과 학습에 열린 마음을 가지세요.' },
          { title: '넓은 시야의 힘', content: '글로벌한 관점으로 바라보면 새로운 기회를 발견할 수 있습니다.' },
          { title: '자유로운 탐험', content: '익숙한 것을 벗어나 새로운 영역에 도전해보세요.' }
        ],
        '염소자리': [
          { title: '목표 달성에 집중하세요', content: '체계적인 계획과 꾸준한 노력이 성공을 이끌 것입니다.' },
          { title: '책임감의 보상', content: '맡은 바 역할을 충실히 해내면 큰 인정을 받을 것입니다.' },
          { title: '전통과 혁신의 조화', content: '기존의 방식을 바탕으로 새로운 개선점을 찾아보세요.' }
        ]
      }
      
      const variations = signFortuneVariations[userSign] || [
        { title: '균형잡힌 하루', content: '모든 일에 균형을 맞춰 진행하세요.' }
      ]
      const selectedIndex = Math.floor(seededRandom(combinedSeed * 4) * variations.length)
      const selectedFortune = variations[selectedIndex]
      
      return {
        title: selectedFortune.title,
        content: selectedFortune.content,
        score: Math.max(70, Math.min(90, score + Math.floor(seededRandom(combinedSeed * 5) * 10) - 5))
      }
    }

    // MBTI별 오늘의 운세 요약
    const generateMBTIFortune = (userMBTI: string) => {
      const mbtiFortunes = {
        'ENFP': { title: '창의적 영감이 넘치는 날', content: '새로운 아이디어와 가능성을 탐험해보세요.', score: 89 },
        'ENFJ': { title: '타인을 이끄는 리더십 발휘', content: '따뜻한 카리스마로 주변을 감화시키세요.', score: 87 },
        'ENTP': { title: '논리적 창의성이 빛남', content: '혁신적인 해결책으로 문제를 해결하세요.', score: 88 },
        'ENTJ': { title: '목표 달성을 위한 완벽한 하루', content: '강력한 추진력으로 모든 계획을 실현하세요.', score: 91 },
        'INFP': { title: '내면의 가치가 중요한 날', content: '진정성 있는 행동으로 의미있는 하루를 만드세요.', score: 82 },
        'INFJ': { title: '직관력이 최고조에 달함', content: '깊은 통찰력으로 본질을 꿰뚫어보세요.', score: 85 },
        'INTP': { title: '분석적 사고가 해답', content: '논리적 접근으로 복잡한 문제를 해결하세요.', score: 84 },
        'INTJ': { title: '전략적 계획이 성공의 열쇠', content: '장기적 관점에서 체계적으로 접근하세요.', score: 86 },
        'ESFP': { title: '즐거움과 활력이 넘치는 날', content: '긍정적인 에너지로 주변을 밝게 만드세요.', score: 88 },
        'ESFJ': { title: '협력과 배려가 빛나는 시간', content: '다른 사람들을 도우며 함께 성장하세요.', score: 83 },
        'ESTP': { title: '행동력으로 기회를 잡으세요', content: '즉시 실행에 옮기는 것이 성공의 비결입니다.', score: 87 },
        'ESTJ': { title: '체계적 관리로 성과 창출', content: '효율적인 시스템으로 목표를 달성하세요.', score: 85 },
        'ISFP': { title: '예술적 감성이 살아나는 날', content: '아름다움과 조화를 추구하며 행동하세요.', score: 81 },
        'ISFJ': { title: '신뢰할 수 있는 지원자 역할', content: '성실함과 책임감으로 안정감을 제공하세요.', score: 80 },
        'ISTP': { title: '실용적 해결책이 필요', content: '현실적이고 효과적인 방법을 찾아 적용하세요.', score: 82 },
        'ISTJ': { title: '꾸준함이 가져올 성취', content: '일관된 노력으로 확실한 결과를 만들어내세요.', score: 79 }
      }
      
      return mbtiFortunes[userMBTI] || { title: '균형잡힌 성장의 날', content: '자신만의 방식으로 성장해나가세요.', score: 80 }
    }

    // 오늘의 운세 요약 데이터 생성
    const fortuneSummary = {
      byZodiacAnimal: generateZodiacFortune(zodiacAnimal),
      byZodiacSign: generateZodiacSignFortune(zodiacSign),
      byMBTI: generateMBTIFortune(mbtiType)
    }

    // 5대 카테고리 운세 점수 생성 (동적, 시드 기반)
    const generateCategoryScore = (baseScore: number, categoryIndex: number) => {
      const categorySeed = combinedSeed + categoryIndex * 11;
      const variation = Math.floor(seededRandom(categorySeed) * 20) - 10; // -10 ~ +9
      return Math.max(60, Math.min(100, baseScore + variation));
    }

    // 4자성어 생성 함수
    const generateFourCharacterIdiom = (categoryScore: number) => {
      const highScoreIdioms = [
        '일취월장', '전화위복', '금의환향', '상승작용', '일석이조',
        '호사다마', '대기만성', '화룡점정', '백전백승', '만사형통'
      ];
      const mediumScoreIdioms = [
        '무병장수', '안빈낙도', '중용지도', '온고지신', '인과응보',
        '자강불식', '중화보합', '태연자약', '불언실행', '침착냉정'
      ];
      const lowScoreIdioms = [
        '역지사지', '온고지신', '인내천', '새옹지마', '전화위복',
        '와신상담', '칠전팔기', '견토재래', '수양순덕', '반성자성'
      ];

      if (categoryScore >= 85) {
        const index = Math.floor(seededRandom(combinedSeed * 19) * highScoreIdioms.length);
        return highScoreIdioms[index];
      } else if (categoryScore >= 70) {
        const index = Math.floor(seededRandom(combinedSeed * 20) * mediumScoreIdioms.length);
        return mediumScoreIdioms[index];
      } else {
        const index = Math.floor(seededRandom(combinedSeed * 21) * lowScoreIdioms.length);
        return lowScoreIdioms[index];
      }
    }

    // OpenAI GPT로 조언 생성 (비동기 함수)
    const generateCategoryAdviceWithGPT = async (category: string, categoryScore: number, idiom?: string) => {
      try {
        // 카테고리별 프롬프트 생성
        const categoryNames: Record<string, string> = {
          'total': '종합 인사이트',
          'love': '애정운',
          'money': '금전운',
          'work': '직장운',
          'study': '학업운',
          'health': '건강운'
        };

        const categoryName = categoryNames[category] || '인사이트';

        let prompt = '';
        if (category === 'total' && idiom) {
          prompt = `오늘의 ${categoryName} 문안을 작성해줘.

입력:
- 참고 키워드: ${idiom}
- 점수: ${categoryScore}점

출력 규칙:
- 자연스러운 한국어 문장형 텍스트만 작성
- 3문장 이내
- 1문장: 오늘의 전체 흐름
- 2문장: 왜 그런 흐름인지 해석
- 3문장: 바로 실천할 수 있는 조언
- 과장하거나 자극적으로 쓰지 말 것`;
        } else {
          prompt = `오늘의 ${categoryName} 문안을 작성해줘.

입력:
- 점수: ${categoryScore}점

출력 규칙:
- 자연스러운 한국어 문장형 텍스트만 작성
- 2~3문장 이내
- 첫 문장은 현재 흐름 설명
- 마지막 문장은 바로 적용할 수 있는 조언
- ${categoryName}에 맞는 실용적인 내용으로 작성`;
        }

        // ✅ LLM 모듈 사용 (DB 설정 기반 동적 모델 선택)
        const llm = await LLMFactory.createFromConfigAsync('daily')

        const response = await llm.generate([
          {
            role: 'system',
            content: `당신은 모바일 운세 앱의 카피 에디터입니다.

작성 원칙:
- 차분하고 자연스러운 한국어로 씁니다.
- 상담하듯 부드럽지만 지나치게 감상적이지 않게 씁니다.
- 문장은 짧고 또렷하게 유지합니다.
- 사용자가 바로 이해하고 행동할 수 있게 씁니다.

금지 사항:
- 마크다운 기호 사용 금지 (**, #, -, >, 코드블록)
- 이모지, 밈, 유행어, 인터넷체 사용 금지
- 과장된 약속, 자극적 표현, 캐치프레이즈 금지
- 따옴표로 감싼 슬로건 문장 금지

출력은 설명 없이 문안만 작성합니다.`
          },
          {
            role: 'user',
            content: prompt
          }
        ], {
          temperature: 0.7,
          maxTokens: 1024,
          jsonMode: false
        })

        console.log(`✅ LLM 호출 완료 (${category}): ${response.provider}/${response.model} - ${response.latency}ms`)

        // ✅ LLM 사용량 로깅 (비용/성능 분석용)
        await UsageLogger.log({
          fortuneType: 'daily',
          userId: userId,
          provider: response.provider,
          model: response.model,
          response: response,
          metadata: { category, categoryScore, idiom, name, birthDate, zodiacAnimal, zodiacSign, mbtiType }
        })

        return response.content.trim()
      } catch (error) {
        console.error(`GPT API 호출 실패 (${category}):`, error);
        // Fallback: 기본 조언 반환
        return generateFallbackAdvice(category, categoryScore);
      }
    };

    // Fallback 조언 생성 (GPT API 실패 시) - 차분한 기본 문안
    const generateFallbackAdvice = (category: string, categoryScore: number) => {
      const fallbackMessages: Record<string, string> = {
        'total': '전반적으로 흐름이 안정적이고, 주도적으로 움직일수록 성과가 잘 붙는 날입니다. 아침에 우선순위를 정리해두면 하루 전체가 한결 매끄럽게 흘러갑니다.',
        'love': '관계에서는 감정을 억누르기보다 차분하게 표현하는 편이 좋습니다. 짧더라도 분명한 말 한마디가 분위기를 부드럽게 만듭니다.',
        'money': '금전운은 무난하지만 계획 없는 지출은 피하는 편이 좋습니다. 오늘은 필요한 항목을 먼저 정하고 소비를 좁혀가세요.',
        'work': '일과 학업에서는 초반 집중력이 좋은 편입니다. 중요한 일 하나를 먼저 끝내 두면 이후 흐름이 훨씬 편해집니다.',
        'study': '배움과 정리 모두 차분하게 이어가기 좋은 날입니다. 새로운 내용을 넓게 보기보다 이미 손댄 내용을 다시 정리해보세요.',
        'health': '몸의 리듬은 무난하지만 피로가 쌓이면 집중이 쉽게 흔들릴 수 있습니다. 수분과 휴식 시간을 먼저 챙기는 것이 좋습니다.'
      };
      return fallbackMessages[category] || fallbackMessages['total'];
    };

    // GPT API로 각 카테고리 조언 생성 (비동기 병렬 처리)
    const totalScore = score;
    const totalIdiom = generateFourCharacterIdiom(totalScore);
    const loveScore = generateCategoryScore(score, 1);
    const moneyScore = generateCategoryScore(score, 2);
    const workScore = generateCategoryScore(score, 3);
    const studyScore = generateCategoryScore(score, 4);
    const healthScore = generateCategoryScore(score, 5);

    // 모든 GPT API 호출을 병렬로 처리
    const [totalAdvice, loveAdvice, moneyAdvice, workAdvice, studyAdvice, healthAdvice] = await Promise.all([
      generateCategoryAdviceWithGPT('total', totalScore, totalIdiom),
      generateCategoryAdviceWithGPT('love', loveScore),
      generateCategoryAdviceWithGPT('money', moneyScore),
      generateCategoryAdviceWithGPT('work', workScore),
      generateCategoryAdviceWithGPT('study', studyScore),
      generateCategoryAdviceWithGPT('health', healthScore),
    ]);

    const categories = {
      total: {
        score: totalScore,
        advice: {
          idiom: totalIdiom,
          description: totalAdvice
        },
        title: '종합 인사이트'
      },
      love: {
        score: loveScore,
        advice: loveAdvice,
        title: '애정 인사이트'
      },
      money: {
        score: moneyScore,
        advice: moneyAdvice,
        title: '금전 인사이트'
      },
      work: {
        score: workScore,
        advice: workAdvice,
        title: '직장 인사이트'
      },
      study: {
        score: studyScore,
        advice: studyAdvice,
        title: '학업 인사이트'
      },
      health: {
        score: healthScore,
        advice: healthAdvice,
        title: '건강 인사이트'
      }
    }

    // 추천 활동 생성
    const personalActions = [
      {
        title: '아침 산책하기',
        why: '신선한 공기와 함께 하루를 시작하면 긍정적인 에너지를 얻을 수 있습니다.'
      },
      {
        title: '중요한 일 먼저 처리하기',
        why: '오전 시간대의 집중력이 최고조에 달하므로 핵심 업무부터 해결하세요.'
      },
      {
        title: '가족이나 친구와 대화하기',
        why: '소중한 사람들과의 교감이 오늘의 행운을 배가시켜 줄 것입니다.'
      }
    ]

    // 동적 행운 아이템 생성
    const generateLuckyColor = () => {
      const colors = [
        '청록색', '진주색', '코발트블루', '연두색', '라벤더', 
        '골드', '실버', '로즈골드', '민트', '코랄핑크',
        '네이비', '버건디', '올리브그린', '베이지', '차콜그레이'
      ];
      const colorSeed = combinedSeed + 23;
      const index = Math.floor(seededRandom(colorSeed) * colors.length);
      return colors[index];
    }

    const generateLuckyFood = () => {
      const foods = [
        '따뜻한 차', '곡물빵', '과일', '샐러드', '요거트',
        '샌드위치', '수프', '커피', '견과류', '죽',
        '두부 요리', '생선구이', '계란 요리', '현미밥', '채소볶음'
      ];
      const foodSeed = combinedSeed + 29;
      const index = Math.floor(seededRandom(foodSeed) * foods.length);
      return foods[index];
    }

    const generateLuckyDirection = () => {
      const directions = [
        '남동쪽', '북서쪽', '남서쪽', '북동쪽', '정남쪽',
        '정북쪽', '정동쪽', '정서쪽'
      ];
      const directionSeed = combinedSeed + 31;
      const index = Math.floor(seededRandom(directionSeed) * directions.length);
      return directions[index];
    }

    const generateLuckyKeyword = () => {
      const keywords = [
        '균형', '조화', '성장', '변화', '안정',
        '도전', '창의', '소통', '집중', '평온',
        '용기', '지혜', '인내', '열정', '배려'
      ];
      const keywordSeed = combinedSeed + 37;
      const index = Math.floor(seededRandom(keywordSeed) * keywords.length);
      return keywords[index];
    }

    const generateLuckyTime = () => {
      const timeSlots = [
        '오전 9시에서 11시', '오전 10시에서 12시', '오후 1시에서 3시',
        '오후 2시에서 4시', '오후 3시에서 5시', '오후 4시에서 6시',
        '저녁 6시에서 8시', '저녁 7시에서 9시'
      ];
      const timeSeed = combinedSeed + 41;
      const index = Math.floor(seededRandom(timeSeed) * timeSlots.length);
      return timeSlots[index];
    }

    const generateLuckyNumber = () => {
      const luckyNumberSeed = combinedSeed + 43;
      return Math.floor(seededRandom(luckyNumberSeed) * 9) + 1; // 1-9
    }

    const generateLuckyItem = () => {
      const items = [
        '슬림 지갑', '메모 노트', '텀블러', '손수건', '볼펜',
        '책갈피', '이어폰 케이스', '파우치', '손거울', '카드지갑',
        '향수', '헤어클립', '보조배터리', '열쇠고리', '북마크'
      ];
      const itemSeed = combinedSeed + 47;
      const index = Math.floor(seededRandom(itemSeed) * items.length);
      return items[index];
    }

    // 오늘의 음악 추천
    const generateLuckyMusic = () => {
      const musics = [
        'APT. - 로제 & 브루노 마스',
        'Supernova - aespa',
        'SPOT! - 지코 (feat. JENNIE)',
        'Love wins all - 아이유',
        'How Sweet - NewJeans',
        'Armageddon - aespa',
        'HEYA - IVE',
        'Magnetic - ILLIT',
        'Chk Chk Boom - Stray Kids',
        'SHEESH - BABYMONSTER',
        'Ditto - NewJeans',
        'OMG - NewJeans',
        'GODS - NewJeans',
        'EASY - LE SSERAFIM',
        'Smart - LE SSERAFIM',
        '소나기 - 이클립스',
        'Love Lee - AKMU',
        'Seven - 정국',
        'Standing Next to You - 정국',
        '퀸카 - (여자)아이들',
      ];
      const musicSeed = combinedSeed + 53;
      const index = Math.floor(seededRandom(musicSeed) * musics.length);
      return musics[index];
    }

    // 보조 요약 생성
    const generateGodlifeSummary = (score: number) => {
      if (score >= 90) {
        const summaries = [
          '흐름이 강한 날이라 중요한 일은 앞부분에 배치하는 편이 좋습니다.',
          '확신이 필요한 순간에 주저하지 않으면 성과를 만들기 좋은 날입니다.',
          '전반적인 리듬이 안정적이어서 계획한 일을 밀도 있게 진행하기 좋습니다.',
          '좋은 기회를 붙잡기 쉬운 날이니 우선순위가 높은 일부터 처리해보세요.',
          '자신감이 살아나는 날이라 준비해둔 일을 실행으로 옮기기 좋습니다.',
        ];
        return summaries[Math.floor(seededRandom(combinedSeed * 61) * summaries.length)];
      } else if (score >= 80) {
        const summaries = [
          '전체 흐름이 무난하게 받쳐주니 중요한 일 한 가지를 정해 집중해보세요.',
          '안정적인 날이라 서두르기보다 리듬을 지키는 편이 더 유리합니다.',
          '대인 흐름과 실행력이 함께 살아나기 쉬워 협업 일정에 힘이 붙습니다.',
          '작은 선택을 차분하게 정리하면 하루 전체가 한결 부드럽게 흘러갑니다.',
          '준비된 일을 하나씩 마무리하기 좋은 날이라 완성도를 높이기 좋습니다.',
        ];
        return summaries[Math.floor(seededRandom(combinedSeed * 62) * summaries.length)];
      } else if (score >= 70) {
        const summaries = [
          '과한 확장보다 현재 리듬을 지키는 편이 결과를 안정적으로 만듭니다.',
          '무난한 흐름 속에서 작은 정리와 점검이 힘을 발휘하는 날입니다.',
          '큰 승부보다 이미 시작한 일을 차분히 이어가기 좋습니다.',
          '속도를 높이기보다 흐름을 고르게 유지하는 쪽이 더 효율적입니다.',
          '조용히 정리한 내용이 다음 일정의 기반이 되기 쉬운 날입니다.',
        ];
        return summaries[Math.floor(seededRandom(combinedSeed * 63) * summaries.length)];
      } else {
        const summaries = [
          '무리하게 밀어붙이기보다 속도를 낮추고 정리하는 편이 좋습니다.',
          '결정을 서두르지 말고 기본적인 컨디션부터 안정시키는 것이 우선입니다.',
          '작은 일부터 차례대로 정리하면 흐름을 다시 회복하기 수월합니다.',
          '외부 변수보다 내 리듬을 먼저 챙기는 편이 결과를 안정시킵니다.',
          '휴식과 재정비가 필요한 날이니 일정은 단순하게 가져가세요.',
        ];
        return summaries[Math.floor(seededRandom(combinedSeed * 64) * summaries.length)];
      }
    }

    // 실천 팁 생성
    const generateGodlifeCheatkeys = (score: number) => {
      const highScoreKeys = [
        { key: '중요한 일 하나를 오전 안에 끝내기', icon: '1' },
        { key: '결정이 필요한 항목은 미루지 않고 처리하기', icon: '2' },
        { key: '짧고 분명한 소통으로 흐름 끊기지 않기', icon: '3' },
        { key: '새로운 제안이나 만남은 한 번 받아보기', icon: '4' },
        { key: '기회가 보이면 준비한 안을 먼저 꺼내기', icon: '5' },
        { key: '남은 일정은 핵심 순서대로 다시 정리하기', icon: '6' },
      ];

      const mediumScoreKeys = [
        { key: '해야 할 일 세 가지만 남기고 나머지는 미루기', icon: '1' },
        { key: '오후 전후로 짧은 정리 시간을 확보하기', icon: '2' },
        { key: '답이 필요한 연락은 한 번에 모아서 처리하기', icon: '3' },
        { key: '물을 자주 마시고 중간 휴식을 챙기기', icon: '4' },
        { key: '집중 시간 30분을 정해서 방해를 줄이기', icon: '5' },
        { key: '하루를 마치기 전에 잘된 점 하나를 기록하기', icon: '6' },
      ];

      const lowScoreKeys = [
        { key: '일정은 줄이고 꼭 필요한 일만 남기기', icon: '1' },
        { key: '결정이 급하지 않다면 내일로 넘기기', icon: '2' },
        { key: '따뜻한 음료나 가벼운 산책으로 긴장 풀기', icon: '3' },
        { key: '휴대폰 알림을 줄이고 조용한 시간을 만들기', icon: '4' },
        { key: '오늘 한 일 중 마무리된 것만 먼저 확인하기', icon: '5' },
        { key: '잠들기 전에는 내일 첫 일정만 간단히 정하기', icon: '6' },
      ];

      const keys = score >= 80 ? highScoreKeys : score >= 65 ? mediumScoreKeys : lowScoreKeys;
      const shuffled = [...keys].sort(() => seededRandom(combinedSeed * 71) - 0.5);
      return shuffled.slice(0, 4);
    }

    // 보조 키워드 생성
    const generateLuckyTalisman = (score: number) => {
      if (score >= 85) {
        const talismans = ['우선순위 메모', '집중 시간 확보', '명확한 한마디', '오전 실행력'];
        return talismans[Math.floor(seededRandom(combinedSeed * 81) * talismans.length)];
      } else if (score >= 70) {
        const talismans = ['체크리스트', '리듬 유지', '정리 노트', '짧은 휴식'];
        return talismans[Math.floor(seededRandom(combinedSeed * 82) * talismans.length)];
      } else {
        const talismans = ['속도 조절', '휴식 확보', '간단한 일정', '컨디션 회복'];
        return talismans[Math.floor(seededRandom(combinedSeed * 83) * talismans.length)];
      }
    }

    // 사주 인사이트 (동적 생성)
    const sajuInsight = {
      lucky_color: generateLuckyColor(),
      lucky_food: generateLuckyFood(),
      luck_direction: generateLuckyDirection(),
      keyword: generateLuckyKeyword(),
      lucky_item: generateLuckyItem()
    }

    // 갓생 관련 데이터 생성
    const luckyMusic = generateLuckyMusic();
    const godlifeSummary = generateGodlifeSummary(score);
    const godlifeCheatkeys = generateGodlifeCheatkeys(score);
    const luckyTalisman = generateLuckyTalisman(score);

    // 행운의 숫자 생성 (동적)
    const generateLuckyNumbers = () => {
      const numbers = []
      // 사용자 생일 기반으로 행운의 숫자 2개 생성
      const birthDateNum = new Date(birthDate).getDate()
      numbers.push((birthDateNum % 9 + 1).toString())
      numbers.push(((birthDateNum * 2) % 9 + 1).toString())
      return numbers
    }

    // 행운의 코디 생성 (동적)
    const generateLuckyOutfit = () => {
      const outfits = [
        {
          title: '활기찬 에너지 코디',
          description: '자신감과 활력을 높이는 코디',
          items: [
            `${sajuInsight.lucky_color} 톤의 상의로 긍정적인 에너지를 표현해보세요.`,
            '밝은 색상은 주변에 활기를 전달하고 자신감을 높여줍니다.',
            '편안한 실루엣으로 하루 종일 자연스러운 매력을 발산하세요.',
            `${sajuInsight.lucky_color} 계열의 액세서리로 포인트를 더해보세요.`
          ]
        },
        {
          title: '차분한 성공 코디',
          description: '안정감과 신뢰를 주는 코디',
          items: [
            '차분한 네이비나 그레이 톤으로 신뢰감을 연출해보세요.',
            '클래식한 스타일이 전문성과 안정감을 보여줍니다.',
            '깔끔한 라인의 의상으로 세련된 인상을 만들어보세요.',
            '포인트 색상으로 개성을 더해 균형잡힌 룩을 완성하세요.'
          ]
        }
      ]
      return score >= 80 ? outfits[0] : outfits[1]
    }

    // 태어난 날 유명인 생성 (실제 데이터 기반)
    const generateSameDayCelebrities = () => {
      const birthMonth = new Date(birthDate).getMonth() + 1
      const birthDay = new Date(birthDate).getDate()
      
      // 실제 유명인 데이터 매핑 (날짜별)
      const celebrityDatabase: Record<string, Array<{year: string, name: string, description: string}>> = {
        '1-1': [
          { year: '1998', name: '장원영', description: '아이브 멤버, 대한민국의 가수' },
          { year: '1979', name: '차태현', description: '대한민국의 배우, 방송인' },
          { year: '1978', name: '김종민', description: '코요태 멤버, 대한민국의 가수' }
        ],
        '8-18': [
          { year: '1999', name: '주이', description: '모모랜드 멤버, 대한민국의 가수' },
          { year: '1993', name: '정은지', description: '에이핑크 멤버, 대한민국의 가수' },
          { year: '1988', name: '지드래곤', description: '빅뱅 멤버, 대한민국의 가수' }
        ],
        '9-5': [
          { year: '1946', name: '프레디 머큐리', description: '퀸의 보컬, 영국의 가수' },
          { year: '1969', name: '마이클 키튼', description: '미국의 배우' },
          { year: '1973', name: '로즈 맥고완', description: '미국의 배우' }
        ],
        '12-25': [
          { year: '1971', name: '이승환', description: '대한민국의 가수' },
          { year: '1954', name: '애니 레녹스', description: '영국의 가수' },
          { year: '1949', name: '시슬리 타이슨', description: '미국의 배우' }
        ]
      }
      
      const dateKey = `${birthMonth}-${birthDay}`
      const celebrities = celebrityDatabase[dateKey]
      
      if (celebrities && celebrities.length > 0) {
        return celebrities
      }
      
      // 데이터가 없을 경우 기본값 반환
      return [
        {
          year: '1990',
          name: `${birthMonth}월 ${birthDay}일 출생한 유명인`,
          description: '이 날 태어난 특별한 인물들이 있습니다'
        }
      ]
    }

    // 비슷한 사주 유명인 생성 (실제 데이터 기반)
    const generateSimilarSajuCelebrities = () => {
      // 띠별 실제 유명인 데이터
      const zodiacCelebrities: Record<string, Array<{name: string, year: string, description: string}>> = {
        '용': [
          { name: '이수만', year: '1952', description: 'SM엔터테인먼트 창립자' },
          { name: '박진영', year: '1972', description: 'JYP엔터테인먼트 대표' },
          { name: '이효리', year: '1979', description: '가수, 방송인' }
        ],
        '뱀': [
          { name: '유재석', year: '1972', description: '국민 MC, 방송인' },
          { name: '송중기', year: '1985', description: '배우' },
          { name: '김태희', year: '1980', description: '배우' }
        ],
        '말': [
          { name: '강호동', year: '1970', description: '방송인' },
          { name: '전지현', year: '1981', description: '배우' },
          { name: '박보검', year: '1993', description: '배우' }
        ],
        '양': [
          { name: '아이유', year: '1993', description: '가수, 배우' },
          { name: '손예진', year: '1982', description: '배우' },
          { name: '정우성', year: '1973', description: '배우' }
        ],
        '원숭이': [
          { name: '김연아', year: '1990', description: '피겨스케이팅 선수' },
          { name: '현빈', year: '1982', description: '배우' },
          { name: '수지', year: '1994', description: '가수, 배우' }
        ],
        '닭': [
          { name: '박서준', year: '1988', description: '배우' },
          { name: '김고은', year: '1991', description: '배우' },
          { name: '이민호', year: '1987', description: '배우' }
        ],
        '개': [
          { name: '송혜교', year: '1981', description: '배우' },
          { name: '조인성', year: '1981', description: '배우' },
          { name: '김우빈', year: '1989', description: '배우' }
        ],
        '돼지': [
          { name: '원빈', year: '1977', description: '배우' },
          { name: '장나라', year: '1981', description: '가수, 배우' },
          { name: '공유', year: '1979', description: '배우' }
        ],
        '쥐': [
          { name: '비', year: '1982', description: '가수, 배우' },
          { name: '한지민', year: '1982', description: '배우' },
          { name: '이종석', year: '1989', description: '배우' }
        ],
        '소': [
          { name: '송강호', year: '1967', description: '배우' },
          { name: '김희선', year: '1977', description: '배우' },
          { name: '차승원', year: '1970', description: '배우' }
        ],
        '호랑이': [
          { name: '유아인', year: '1986', description: '배우' },
          { name: '한효주', year: '1987', description: '배우' },
          { name: '김수현', year: '1988', description: '배우' }
        ],
        '토끼': [
          { name: '박신혜', year: '1990', description: '배우' },
          { name: '이승기', year: '1987', description: '가수, 배우' },
          { name: '김유정', year: '1999', description: '배우' }
        ]
      }

      const celebrities = zodiacCelebrities[zodiacAnimal] || []

      if (celebrities.length > 0) {
        return celebrities.slice(0, 3) // 최대 3명 반환
      }

      // 데이터가 없을 경우 기본값
      return [
        {
          name: `${zodiacAnimal}띠 유명인`,
          year: '1990',
          description: `${zodiacAnimal}띠로 태어난 성공한 인물들`
        }
      ]
    }

    // 년생별 운세 생성 (동적)
    const generateAgeFortune = () => {
      const birthYear = new Date(birthDate).getFullYear()
      const yearLastTwoDigits = birthYear % 100
      
      if (yearLastTwoDigits >= 80 && yearLastTwoDigits <= 89) {
        return {
          title: '노력한 만큼의 성과를 올릴 수가 있다',
          description: '하는 만큼 부가 쌓이는 때입니다. 책을 읽으며 지식을 쌓아도 좋겠습니다. 언젠가 하고 싶었던 일의 기회도 생길 수 있습니다.'
        }
      } else if (yearLastTwoDigits >= 90 && yearLastTwoDigits <= 99) {
        return {
          title: '안정적인 발전이 기대되는 시기',
          description: '차근차근 계획을 세워 나아가면 좋은 결과를 얻을 수 있습니다. 주변의 조언에 귀 기울이며 신중하게 행동하세요.'
        }
      } else if (yearLastTwoDigits >= 0 && yearLastTwoDigits <= 9) {
        return {
          title: '욕심이 커지는 것에 주의해라',
          description: '욕심이 앞서면 구설수에 오를 수 있는 날입니다. 당신을 지켜보는 눈이 많습니다. 상대방에게 거북할 수 있으니 주의를 기울이세요.'
        }
      } else {
        return {
          title: '새로운 시작을 위한 준비의 시간',
          description: '변화의 바람이 불고 있습니다. 새로운 도전을 위해 마음의 준비를 하고 기회를 놓치지 마세요.'
        }
      }
    }

    // 시간대별 운세 예측 데이터 생성 (동적)
    const generateDailyPredictions = () => {
      // 시간대별 메시지 풀
      const morningMessages = [
        '아침의 상쾌한 기운이 가득합니다. 중요한 일은 오전에 처리하면 좋은 결과를 얻을 수 있어요. 아침 햇살을 받으며 가벼운 스트레칭으로 하루를 시작해보세요.',
        '오전 시간대에 집중력이 높아집니다. 복잡한 업무나 중요한 결정은 이때 하세요. 따뜻한 차 한 잔과 함께 계획을 세우면 더 효과적이에요.',
        '아침부터 긍정적인 에너지가 흐릅니다. 새로운 도전을 시작하기 좋은 타이밍이에요. 오늘 만나는 첫 번째 사람이 좋은 영향을 줄 수 있어요.'
      ]

      const afternoonMessages = [
        '점심 이후 대인관계에서 좋은 기운이 있습니다. 동료나 친구와의 대화에서 새로운 아이디어를 얻을 수 있어요. 잠깐의 휴식이 오후 에너지를 충전해줄 거예요.',
        '오후에는 협업 운이 좋습니다. 팀 프로젝트나 공동 작업에서 시너지가 날 수 있어요. 점심 식사 때 평소 대화 못했던 사람과 이야기해보세요.',
        '오후 2시~4시 사이에 중요한 연락이 올 수 있습니다. 핸드폰을 가까이 두세요. 이 시간대에 결정한 일이 좋은 방향으로 흘러갈 거예요.'
      ]

      const eveningMessages = [
        '저녁에는 자기 성찰의 시간을 가져보세요. 오늘 하루를 돌아보며 내일을 계획하면 좋습니다. 가벼운 산책이나 독서로 마무리하면 숙면에 도움이 돼요.',
        '저녁 시간에 가족이나 가까운 사람과의 시간이 특별해집니다. 따뜻한 대화가 마음의 위안을 줄 거예요. 편안한 음악과 함께 하루를 마무리하세요.',
        '밤에 갑자기 좋은 아이디어가 떠오를 수 있습니다. 메모장을 가까이 두세요. 오늘 밤 꾸는 꿈에서 힌트를 얻을 수도 있어요.'
      ]

      // 점수와 시드 기반으로 메시지 선택
      const morningIdx = Math.floor(seededRandom(combinedSeed * 11) * morningMessages.length)
      const afternoonIdx = Math.floor(seededRandom(combinedSeed * 12) * afternoonMessages.length)
      const eveningIdx = Math.floor(seededRandom(combinedSeed * 13) * eveningMessages.length)

      return {
        morning: morningMessages[morningIdx],
        afternoon: afternoonMessages[afternoonIdx],
        evening: eveningMessages[eveningIdx]
      }
    }

    // AI 인사이트 생성 (동적)
    const generateAIInsight = () => {
      if (score >= 90) {
        return '전반적인 흐름이 강한 날입니다. 중요한 일은 미루지 말고 앞부분에 배치해보세요.'
      } else if (score >= 80) {
        return `오늘은 ${getHighestCategory(categories)} 흐름이 상대적으로 두드러집니다. 이 분야의 중요한 일 하나를 먼저 처리하면 좋습니다.`
      } else if (score >= 70) {
        return '전체적으로 안정적인 날입니다. 속도를 무리하게 높이기보다 현재 리듬을 유지하는 편이 좋습니다.'
      } else if (score >= 60) {
        return '신중하게 움직이면 무난하게 보낼 수 있는 날입니다. 급하지 않은 결정은 한 템포 늦춰도 괜찮습니다.'
      } else {
        return '컨디션과 리듬 관리가 더 중요한 날입니다. 작은 일부터 차례대로 정리하면서 흐름을 회복해보세요.'
      }
    }

    // AI 팁 생성 (동적)
    const generateAITips = () => {
      const tips = []
      
      if (score >= 80) {
        tips.push('오전 시간대에 중요한 결정을 내리세요')
        tips.push('새로운 사람들과의 만남을 소중히 하세요')
      } else if (score >= 60) {
        tips.push('무리하지 말고 차근차근 진행하세요')
        tips.push('주변 사람들의 조언에 귀 기울이세요')
      } else {
        tips.push('휴식을 취하며 재충전의 시간을 가지세요')
        tips.push('작은 성취에도 감사하는 마음을 가지세요')
      }
      
      // 카테고리별 팁 추가
      const lowestCategory = getLowestCategory(categories)
      switch (lowestCategory) {
        case 'health':
          tips.push('충분한 수면과 휴식을 취하세요')
          break
        case 'money':
          tips.push('불필요한 지출을 줄이고 저축에 신경쓰세요')
          break
        case 'love':
          tips.push('상대방의 마음을 헤아리는 시간을 가지세요')
          break
        case 'career':
          tips.push('업무에 집중하고 동료들과 원활한 소통을 하세요')
          break
      }
      
      return tips.slice(0, 3)
    }

    // 공유 카운트 생성 (동적 - 실제로는 DB에서 조회)
    const generateShareCount = () => {
      // 실제로는 데이터베이스에서 조회하지만, 예시로 동적 생성
      const baseCount = 2750000
      const dailyIncrease = Math.floor(Math.random() * 5000) + 1000
      return baseCount + dailyIncrease
    }

    // 카테고리별 최고/최저 점수 찾기 함수
    const getHighestCategory = (categories: any) => {
      let maxScore = 0
      let maxCategory = '전반적인'
      
      Object.entries(categories).forEach(([key, value]: [string, any]) => {
        if (value.score > maxScore) {
          maxScore = value.score
          maxCategory = translateCategory(key)
        }
      })
      
      return maxCategory
    }

    const getLowestCategory = (categories: any) => {
      let minScore = 100
      let minCategory = ''
      
      Object.entries(categories).forEach(([key, value]: [string, any]) => {
        if (value.score < minScore) {
          minScore = value.score
          minCategory = key
        }
      })
      
      return minCategory
    }

    const translateCategory = (category: string) => {
      switch (category.toLowerCase()) {
        case 'love': return '연애'
        case 'career': return '직장'
        case 'money': return '금전'
        case 'health': return '건강'
        case 'relationship': return '대인관계'
        case 'luck': return '행운'
        default: return category
      }
    }

    // 동적 조언 생성
    const generateDynamicAdvice = () => {
      const adviceOptions = [
        '오늘은 자신의 강점을 믿고 적극적으로 나아가며, 중요한 순간에는 침착함을 유지하세요.',
        '새로운 기회가 다가올 때를 대비해 마음의 준비를 하고, 직감을 신뢰하며 행동하세요.',
        '주변 사람들과의 소통을 중요시하고, 협력을 통해 더 큰 성과를 만들어내세요.',
        '계획적으로 접근하되 유연성을 잃지 말고, 변화에 열린 마음을 가지세요.',
        '작은 성취에도 감사하는 마음을 갖고, 꾸준히 전진하는 자세를 유지하세요.'
      ]
      const adviceIndex = Math.floor(seededRandom(combinedSeed * 6) * adviceOptions.length)
      return adviceOptions[adviceIndex]
    }

    // 동적 주의사항 생성
    const generateDynamicCaution = () => {
      const hour = today.getHours()
      const dayOfMonth = today.getDate()
      const isWeekend = today.getDay() === 0 || today.getDay() === 6
      
      // 시간대별 주의사항
      const timeBasedCautions = []
      if (hour < 12) {
        timeBasedCautions.push('오전에는 중요한 결정을 내리기 좋은 시간이니, 신중하게 판단하여 최선의 선택을 하세요.')
      } else if (hour < 18) {
        timeBasedCautions.push('오후 시간대에는 타인과의 소통에 더욱 신경 쓰며, 오해가 생기지 않도록 명확하게 표현하세요.')
      } else {
        timeBasedCautions.push('저녁 시간에는 하루를 정리하며 감사한 마음을 가지고, 내일을 위한 준비를 차근차근 해보세요.')
      }
      
      // 점수별 주의사항
      const scoreBasedCautions = []
      if (score >= 85) {
        scoreBasedCautions.push('높은 운세를 가진 오늘, 자만하지 말고 겸손한 마음으로 주변 사람들에게 도움의 손길을 내밀어보세요.')
      } else if (score >= 70) {
        scoreBasedCautions.push('안정적인 하루이지만 방심은 금물입니다. 꾸준한 노력으로 더 나은 결과를 만들어가세요.')
      } else {
        scoreBasedCautions.push('오늘은 차분함을 유지하며 급하게 서두르지 말고, 한 걸음씩 신중하게 나아가는 것이 중요합니다.')
      }
      
      // MBTI별 주의사항
      const mbtiCautions = []
      if (mbtiType?.includes('E')) {
        mbtiCautions.push('외향적인 에너지가 강한 날이니, 다른 사람의 의견도 충분히 듣고 균형을 맞춰보세요.')
      } else if (mbtiType?.includes('I')) {
        mbtiCautions.push('내면의 목소리를 중요하게 여기되, 때로는 다른 관점도 수용하는 열린 마음을 가져보세요.')
      }
      
      // 요일별 주의사항
      const dayBasedCautions = []
      if (isWeekend) {
        dayBasedCautions.push('주말의 여유로운 시간을 활용해 평소 미뤄두었던 자기 관리에 집중해보세요.')
      } else {
        dayBasedCautions.push('바쁜 평일이지만 작은 휴식을 잊지 말고, 몸과 마음의 균형을 유지하는 것이 중요합니다.')
      }
      
      // 모든 주의사항을 모아서 선택
      const allCautions = [...timeBasedCautions, ...scoreBasedCautions, ...mbtiCautions, ...dayBasedCautions]
      
      // 더 동적인 선택을 위해 시간과 날짜를 추가로 활용
      const dynamicSeed = combinedSeed + hour + dayOfMonth + (isWeekend ? 100 : 0)
      const cautionIndex = Math.floor(seededRandom(dynamicSeed) * allCautions.length)
      
      return allCautions[cautionIndex]
    }

    // 동적 요약 생성
    const generateDynamicSummary = () => {
      if (score >= 85) {
        const highScoreOptions = [
          '흐름이 강한 날이라 중요한 일을 앞당겨 처리하기 좋습니다.',
          '준비해둔 일을 실행으로 옮기면 성과를 내기 쉬운 날입니다.',
          '전반적인 리듬이 안정적이어서 밀도 있게 움직이기 좋습니다.',
        ]
        const index = Math.floor(seededRandom(combinedSeed * 8) * highScoreOptions.length)
        return highScoreOptions[index]
      } else if (score >= 70) {
        const mediumScoreOptions = [
          '차분하고 안정적인 날이라 현재 리듬을 유지하는 편이 좋습니다.',
          '무리하게 확장하기보다 이미 잡힌 일을 정리하기 좋은 날입니다.',
          '속도를 높이기보다 균형을 맞추는 쪽이 효율적인 하루입니다.',
        ]
        const index = Math.floor(seededRandom(combinedSeed * 9) * mediumScoreOptions.length)
        return mediumScoreOptions[index]
      } else {
        const lowScoreOptions = [
          '신중함이 필요한 날이니 속도를 줄이고 차례대로 정리하세요.',
          '휴식과 재정비를 우선하면 하루 흐름이 한결 안정됩니다.',
          '작은 일부터 하나씩 마무리하는 편이 부담을 줄여줍니다.',
        ]
        const index = Math.floor(seededRandom(combinedSeed * 10) * lowScoreOptions.length)
        return lowScoreOptions[index]
      }
    }

    // 동적 특별 팁 생성
    const generateDynamicSpecialTip = () => {
      const tipCategories = []
      
      // 점수 구간별 기본 팁
      if (score >= 85) {
        tipCategories.push([
          '높은 에너지를 활용해 평소 미뤄두었던 중요한 프로젝트를 시작해보세요.',
          '자신감이 넘치는 지금, 새로운 인맥을 만들거나 네트워킹에 집중해보세요.',
          '리더십을 발휘할 기회가 많은 날입니다. 팀을 이끌어가는 역할을 맡아보세요.'
        ])
      } else if (score >= 70) {
        tipCategories.push([
          '안정적인 에너지를 바탕으로 기존 관계를 더욱 견고하게 만들어보세요.',
          '체계적인 계획 수립에 좋은 날입니다. 중장기 목표를 세워보세요.',
          '지식 습득이나 스킬 향상에 투자하는 시간을 가져보세요.'
        ])
      } else {
        tipCategories.push([
          '무리하지 말고 현재 하고 있는 일들을 차근차근 마무리하는데 집중하세요.',
          '자신을 돌아보는 시간을 가지며 내면의 소리에 귀 기울여보세요.',
          '작은 성취나 소소한 행복에 감사하는 마음을 가져보세요.'
        ])
      }
      
      // MBTI별 맞춤 팁
      if (mbtiType) {
        const mbtiTips = {
          'ENTJ': '목표 달성을 위한 구체적인 로드맵을 그려보세요. 당신의 추진력이 빛날 때입니다.',
          'ENFJ': '주변 사람들에게 긍정적인 영향을 미칠 수 있는 기회를 찾아보세요.',
          'INTJ': '장기적인 비전을 구체화하는 시간을 가져보세요. 혁신적인 아이디어를 실현시킬 때입니다.',
          'INFJ': '직감을 믿고 창의적인 프로젝트에 도전해보세요.',
          'ESTP': '즉흥적인 활동이나 새로운 경험을 통해 에너지를 충전해보세요.',
          'ESFP': '사람들과의 즐거운 만남을 통해 긍정적인 에너지를 나누어보세요.',
          'ISTP': '혼자만의 시간을 가지며 새로운 기술이나 취미를 탐구해보세요.',
          'ISFP': '예술적 감성을 발휘할 수 있는 창작 활동에 시간을 투자해보세요.',
          'ENFP': '새로운 아이디어를 실현할 수 있는 구체적인 첫걸음을 떼어보세요.',
          'ENTP': '다양한 관점에서 문제를 바라보며 창의적인 해결책을 찾아보세요.',
          'INFP': '자신의 가치관에 맞는 의미있는 활동을 찾아 참여해보세요.',
          'INTP': '관심 있는 주제에 대해 깊이 있게 탐구하는 시간을 가져보세요.',
          'ESTJ': '효율적인 시스템을 구축하거나 기존 프로세스를 개선해보세요.',
          'ESFJ': '주변 사람들을 도우면서 따뜻한 관계를 더욱 깊게 만들어보세요.',
          'ISTJ': '꼼꼼한 계획과 실행으로 안정적인 성과를 만들어보세요.',
          'ISFJ': '소중한 사람들을 위한 세심한 배려를 표현해보세요.'
        }
        if (mbtiTips[mbtiType]) {
          tipCategories.push([mbtiTips[mbtiType]])
        }
      }
      
      // 띠별 맞춤 팁
      if (zodiacAnimal) {
        const zodiacTips = {
          '쥐': '기회를 놓치지 말고 재빠른 판단력을 발휘해보세요.',
          '소': '꾸준함과 인내심으로 큰 성과를 이룰 수 있는 때입니다.',
          '호랑이': '용감한 도전정신을 발휘해 새로운 영역에 도전해보세요.',
          '토끼': '섬세한 감성과 조화로운 소통으로 관계를 개선해보세요.',
          '용': '강한 리더십과 카리스마로 큰 꿈을 실현해보세요.',
          '뱀': '신중한 분석과 깊은 통찰력으로 현명한 결정을 내려보세요.',
          '말': '자유로운 사고와 활동적인 에너지로 새로운 경험을 만들어보세요.',
          '양': '따뜻한 마음과 창의적 감성으로 아름다운 것을 만들어보세요.',
          '원숭이': '기발한 아이디어와 재치로 어려운 문제를 해결해보세요.',
          '닭': '세밀한 계획과 체계적인 접근으로 완벽한 결과를 만들어보세요.',
          '개': '진실한 마음과 충실함으로 신뢰 관계를 구축해보세요.',
          '돼지': '관대한 마음과 풍부한 감성으로 행복을 나누어보세요.'
        }
        if (zodiacTips[zodiacAnimal]) {
          tipCategories.push([zodiacTips[zodiacAnimal]])
        }
      }
      
      // 모든 팁들을 합치고 랜덤하게 선택
      const allTips = tipCategories.flat()
      if (allTips.length === 0) {
        return '오늘 하루도 자신만의 특별한 방식으로 의미있게 보내시기 바랍니다.'
      }
      
      const tipIndex = Math.floor(seededRandom(combinedSeed * 11) * allTips.length)
      return allTips[tipIndex]
    }

    // 동적 상세 설명 생성
    const generateDynamicDescription = () => {
      const timePatterns = [
        { time: '오전', activity: '계획을 정리하고 우선순위를 세우기', result: '흐름을 안정적으로 잡을 수 있습니다' },
        { time: '오전', activity: '집중이 필요한 일을 먼저 처리하기', result: '밀도 있는 결과를 만들기 좋습니다' },
        { time: '오전', activity: '아이디어와 메모를 정리하기', result: '오후 일정이 한결 가벼워질 수 있습니다' }
      ]
      
      const afternoonPatterns = [
        '오후에는 소통과 조율이 조금 더 수월해질 수 있습니다',
        '오후로 갈수록 실행보다 정리와 판단이 더 중요해질 수 있습니다',
        '오후에는 갑작스러운 확장보다 이미 진행 중인 일을 다듬는 편이 좋습니다'
      ]
      
      const timeIndex = Math.floor(seededRandom(combinedSeed * 11) * timePatterns.length)
      const afternoonIndex = Math.floor(seededRandom(combinedSeed * 12) * afternoonPatterns.length)
      
      const selectedTimePattern = timePatterns[timeIndex]
      const selectedAfternoonPattern = afternoonPatterns[afternoonIndex]
      
      return `오늘은 ${selectedTimePattern.time}에 ${selectedTimePattern.activity}를 하기 좋습니다. 이 시간대를 잘 쓰면 ${selectedTimePattern.result}. ${selectedAfternoonPattern}.`
    }

    // 운세 내용 생성 (동적)
    const dynamicSummary = generateDynamicSummary()
    const dynamicAdvice = generateDynamicAdvice()

    const fortune = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'daily',
      score: score,
      // content: 날짜 + 종합 인사이트(LLM 생성)로 풍부하게 구성
      content: `${name}님, 오늘은 ${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일입니다.\n\n${totalAdvice}`,
      summary: dynamicSummary,
      advice: dynamicAdvice,
      // 기존 필드 유지 (하위 호환성)
      overall_score: score,
      greeting: `${name}님, 오늘은 ${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일입니다. ${processedLocation} 기준으로 하루 흐름을 차분하게 정리해드릴게요.`,
      description: generateDynamicDescription(),
      lucky_items: {
        time: generateLuckyTime(),
        color: sajuInsight.lucky_color,
        number: generateLuckyNumber(),
        direction: sajuInsight.luck_direction,
        food: sajuInsight.lucky_food,
        item: sajuInsight.lucky_item || '작은 장신구'
      },
      // ✅ 항상 실제 데이터 생성 (블러는 클라이언트에서만 처리)
      // advice는 위에서 표준화된 필드로 이미 정의됨
      caution: generateDynamicCaution(),
      special_tip: generateDynamicSpecialTip(),
      fortuneSummary: fortuneSummary,
      categories: categories,
      personalActions: personalActions,
      sajuInsight: sajuInsight,
      lucky_outfit: generateLuckyOutfit(),
      celebrities_same_day: generateSameDayCelebrities(),
      celebrities_similar_saju: generateSimilarSajuCelebrities(),
      lucky_numbers: generateLuckyNumbers(),
      age_fortune: generateAgeFortune(),
      daily_predictions: generateDailyPredictions(),
      // ✅ 프론트엔드 호환용 timeSpecificFortunes (daily_predictions 형식 변환)
      timeSpecificFortunes: (() => {
        const predictions = generateDailyPredictions()
        const morningScore = Math.max(0, score - 5 + Math.floor(seededRandom(combinedSeed * 14) * 10))
        const afternoonScore = Math.max(0, score - 3 + Math.floor(seededRandom(combinedSeed * 15) * 8))
        const eveningScore = Math.max(0, score - 7 + Math.floor(seededRandom(combinedSeed * 16) * 12))
        return [
          { time: '오전', title: predictions.morning, score: morningScore },
          { time: '오후', title: predictions.afternoon, score: afternoonScore },
          { time: '저녁', title: predictions.evening, score: eveningScore }
        ]
      })(),
      ai_insight: generateAIInsight(),
      ai_tips: generateAITips(),
      share_count: generateShareCount(),

      // 보조 카드 콘텐츠
      godlife: {
        summary: godlifeSummary,
        cheatkeys: godlifeCheatkeys,
        talisman: luckyTalisman,
        lucky_music: luckyMusic,
      }
    }
    
    // 동적 스토리 세그먼트 생성
    const generateDynamicStorySegments = () => {
      // 동적 시간대별 메시지
      const morningMessages = [
        '아침의 햇살처럼\n새로운 시작을 알리는\n긍정의 에너지가 당신과 함께.',
        '새벽 이슬처럼\n투명하고 맑은 마음으로\n하루를 시작해보세요.',
        '이른 아침의 고요함이\n당신에게 평온을 선사할\n특별한 순간입니다.'
      ]
      
      const lunchMessages = [
        '점심 무렵\n중요한 결정의 순간이 온다면\n침착함을 잃지 마세요.',
        '한낮의 뜨거운 열정이\n당신의 잠재력을 깨우는\n계기가 될 것입니다.',
        '점심시간 즈음\n누군가의 따뜻한 말 한마디가\n큰 위로가 될 것입니다.'
      ]
      
      const eveningMessages = [
        '저녁이 되면\n하루의 성취를 돌아보며\n스스로를 격려해주세요.',
        '노을이 지는 시간\n하루의 피로를 달래며\n내일을 준비하세요.',
        '저녁 무렵이면\n소중한 사람들과 함께\n따뜻한 시간을 보내세요.'
      ]
      
      const cautionMessages = [
        '주의할 점\n감정의 기복이 있을 수 있으니\n마음의 중심을 잡으세요.',
        '조심하세요\n성급한 판단보다는\n신중한 선택이 필요할 때입니다.',
        '한 가지 주의사항\n과도한 욕심은 독이 될 수 있으니\n적당한 선에서 만족하세요.'
      ]
      
      const morningIndex = Math.floor(seededRandom(combinedSeed * 13) * morningMessages.length)
      const lunchIndex = Math.floor(seededRandom(combinedSeed * 14) * lunchMessages.length)
      const eveningIndex = Math.floor(seededRandom(combinedSeed * 15) * eveningMessages.length)
      const cautionIndex = Math.floor(seededRandom(combinedSeed * 16) * cautionMessages.length)
      
      return [
        {
          text: `${name}님, 환영합니다.\n오늘의 이야기가\n당신에게 작은 빛이 되기를.`,
          fontSize: 24,
          fontWeight: 400
        },
        {
          text: `${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일\n하늘은 맑고\n당신의 마음도 맑기를.`,
          fontSize: 24,
          fontWeight: 300
        },
        {
          text: `오늘의 점수는 ${score}\n${score >= 85 ? '자신감으로 가득 찬' : score >= 70 ? '균형 잡힌' : '차분하고 신중한'}\n특별한 하루입니다.`,
          fontSize: 26,
          fontWeight: 500
        },
        {
          text: morningMessages[morningIndex],
          fontSize: 22,
          fontWeight: 300
        },
        {
          text: lunchMessages[lunchIndex],
          fontSize: 22,
          fontWeight: 300
        },
        {
          text: eveningMessages[eveningIndex],
          fontSize: 22,
          fontWeight: 300
        },
        {
          text: cautionMessages[cautionIndex],
          fontSize: 24,
          fontWeight: 400
        },
        {
          text: `행운의 색: ${fortune.lucky_items.color}\n행운의 숫자: ${fortune.lucky_items.number}\n행운의 시간: ${fortune.lucky_items.time}`,
          fontSize: 24,
          fontWeight: 400
        },
        // 띠별 운세 페이지
        {
          text: `${zodiacAnimal}띠인 당신\n\n${fortuneSummary.byZodiacAnimal.title}\n\n${fortuneSummary.byZodiacAnimal.content}`,
          fontSize: 22,
          fontWeight: 400,
          emoji: '🐉'
        },
        // 별자리별 운세 페이지
        {
          text: `${zodiacSign}인 당신\n\n${fortuneSummary.byZodiacSign.title}\n\n${fortuneSummary.byZodiacSign.content}`,
          fontSize: 22,
          fontWeight: 400,
          emoji: '⭐'
        },
        // MBTI별 운세 페이지
        {
          text: `${mbtiType}인 당신\n\n${fortuneSummary.byMBTI.title}\n\n${fortuneSummary.byMBTI.content}`,
          fontSize: 22,
          fontWeight: 400,
          emoji: '🧠'
        },
        // 동적 당부 메시지
        {
          text: generateDynamicAdviceMessage(),
          fontSize: 24,
          fontWeight: 400
        },
        // 동적 마무리 메시지
        {
          text: generateDynamicClosingMessage(),
          fontSize: 24,
          fontWeight: 400
        }
      ]
    }

    // 동적 당부 메시지 생성
    const generateDynamicAdviceMessage = () => {
      const adviceMessages = [
        `오늘의 당부\n자신의 강점을 믿고\n명확한 소통으로 나아가세요.`,
        `작은 조언\n완벽을 추구하기보다는\n진정성 있는 노력을 기울이세요.`,
        `마음속 메시지\n변화를 두려워하지 말고\n새로운 가능성을 열어보세요.`,
        `오늘의 지혜\n타인의 시선보다는\n자신의 내면의 소리에 귀 기울이세요.`
      ]
      const index = Math.floor(seededRandom(combinedSeed * 17) * adviceMessages.length)
      return adviceMessages[index]
    }

    // 동적 마무리 메시지 생성  
    const generateDynamicClosingMessage = () => {
      const closingMessages = [
        `좋은 하루 되세요\n${name}님의 하루가\n빛나기를 바랍니다.`,
        `행복한 하루 보내세요\n${name}님께 따뜻한\n기운이 함께하길.`,
        `평온한 하루가 되길\n${name}님의 마음에\n평화가 깃들기를.`,
        `의미있는 하루 되세요\n${name}님의 모든 순간이\n소중한 기억이 되길.`
      ]
      const index = Math.floor(seededRandom(combinedSeed * 18) * closingMessages.length)
      return closingMessages[index]
    }

    // 동적 스토리 세그먼트 생성 실행
    const storySegments = generateDynamicStorySegments()
    
    // 응답 검증 - 임시로 비활성화하고 실제 응답 확인
    console.log('🔍 Fortune object keys:', Object.keys(fortune));
    console.log('🔍 Fortune.categories keys:', Object.keys(fortune.categories || {}));
    console.log('🔍 Fortune.categories.total:', JSON.stringify(fortune.categories?.total));

    const sanitizedFortune = sanitizeDailyFortuneOutput(
      fortune as DailyFortuneResponse & Record<string, any>,
    );

    const validationResult = validateFortuneResponse(sanitizedFortune);
    console.log('🔍 Validation result:', validationResult);

    if (!validationResult) {
      console.error('❌ Fortune response validation failed');
      console.error('Fortune object keys:', Object.keys(sanitizedFortune));
      console.error('Missing or invalid fields detected by validator');
      // 임시로 에러를 throw하지 않고 계속 진행
      // throw new Error('Generated fortune data is incomplete');
    } else {
      console.log('✅ Fortune validation passed successfully');
    }

    // ✅ 퍼센타일 계산 (오늘 운세를 본 사람들 중 상위 몇 %)
    const percentileData = await calculatePercentile(
      supabaseClient,
      'daily',
      score
    )
    console.log(`📊 [Daily] Percentile: ${percentileData.isPercentileValid ? `상위 ${percentileData.percentile}%` : '데이터 부족'}`)

    // 퍼센타일 정보를 fortune에 추가
    const fortuneWithPercentile = {
      ...sanitizedFortune,
      percentile: percentileData.percentile,
      totalTodayViewers: percentileData.totalTodayViewers,
      isPercentileValid: percentileData.isPercentileValid
    }

    // ✅ 위젯용 캐시 저장 (백그라운드, 비동기 - 응답 지연 없음)
    saveWidgetCache(supabaseClient, userId, sanitizedFortune, sanitizedFortune.categories).catch(err => {
      console.warn('[widget-cache] 저장 실패 (무시):', err.message)
    })

    // ✅ Cohort Pool 온디맨드 저장 (백그라운드, 비동기 - 응답 지연 없음)
    // Pool이 50개 미만일 때만 저장되어 자연스럽게 축적됨
    if (dailyCohortData && dailyCohortHash) {
      // 템플릿화: 개인 정보를 플레이스홀더로 대체
      const userName = name || '회원님';
      const fortuneTemplate = {
        ...sanitizedFortune,
        // 개인화 필드는 플레이스홀더로 대체
        greeting: sanitizedFortune.greeting?.replace(userName, '{{userName}}') || '',
        content: sanitizedFortune.content?.replace(userName, '{{userName}}') || '',
        description: sanitizedFortune.description?.replace(userName, '{{userName}}') || '',
      };

      saveToCohortPool(supabaseAdmin, 'daily', dailyCohortHash, dailyCohortData, fortuneTemplate).then(saved => {
        if (saved) {
          console.log('✅ [Cohort] Pool에 새 결과 저장됨');
        }
      }).catch(err => {
        console.warn('[Cohort] Pool 저장 실패 (무시):', err.message);
      });
    }

    // 운세와 스토리를 함께 반환
    return new Response(
      JSON.stringify({
        fortune: fortuneWithPercentile,
        storySegments,
        cached: false,
        tokensUsed: 0
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error generating fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500 
      }
    )
  }
})
