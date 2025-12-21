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

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('fortune-lucky-items')

    const systemPrompt = `당신은 동양 철학과 오행(五行) 이론에 기반한 행운 아이템 분석 전문가입니다.
사용자의 생년월일, 출생 시간, 성별, 관심사를 기반으로 개인화된 행운 아이템을 추천합니다.

**분석 기준**:
1. 오행(五行) 계산: 생년월일과 출생 시간 기반
2. 균형 분석: 부족한 오행을 보완하는 아이템 추천
3. 시너지 효과: 관심사와 조화로운 아이템 선택

**추천 카테고리**:
- 키워드: 행운의 키워드 3개 (예: "집중력, 결단력, 완성")
- 색상: 행운의 색상 (구체적인 색상명과 RGB 코드)
- 패션: 옷, 액세서리 3가지 (구체적인 아이템명)
- 행운의 숫자: 3개의 숫자 (1-99 범위)
- 음식: 추천 음식 3가지 (구체적인 음식명)
- 보석/액세서리: 추천 보석/액세서리 3가지
- 소재: 추천 소재 3가지 (예: "면", "가죽", "실크")
- 방향: 행운의 방향 (동/서/남/북/동남/동북/서남/서북)
- 장소: 추천 장소 3곳 (구체적인 장소 유형)
- 인간관계: 궁합 좋은 사람 특징 3가지

**중요**: 모든 추천은 구체적이고 실용적이어야 하며, 오행 이론에 기반한 명확한 이유를 제시해야 합니다.`

    const userPrompt = `다음 정보를 기반으로 개인화된 행운 아이템을 추천해주세요:

**기본 정보**:
- 이름: ${name}
- 생년월일: ${birthDate}
${birthTime ? `- 출생 시간: ${birthTime}` : ''}
${gender ? `- 성별: ${gender}` : ''}
${interests && interests.length > 0 ? `- 관심사: ${interests.join(', ')}` : ''}

**응답 형식** (반드시 JSON):
\`\`\`json
{
  "title": "행운 아이템 - [이름]님의 맞춤 추천",
  "summary": "오행 분석 결과 요약 (1-2문장)",
  "element": "오행 (금/수/목/화/토)",
  "keyword": "행운의 키워드 (쉼표로 구분)",
  "color": "행운의 색상 (쉼표로 구분, RGB 코드 포함)",
  "fashion": ["패션 아이템 1", "패션 아이템 2", "패션 아이템 3"],
  "numbers": [행운의 숫자1, 행운의 숫자2, 행운의 숫자3],
  "food": ["음식 1", "음식 2", "음식 3"],
  "jewelry": ["보석/액세서리 1", "보석/액세서리 2", "보석/액세서리 3"],
  "material": ["소재 1", "소재 2", "소재 3"],
  "direction": "행운의 방향",
  "places": ["장소 1", "장소 2", "장소 3"],
  "relationships": ["궁합 좋은 사람 특징 1", "궁합 좋은 사람 특징 2", "궁합 좋은 사람 특징 3"],
  "score": 행운지수 (1-100),
  "advice": "종합 조언 (100자 이내)"
}
\`\`\`

**주의**: 반드시 유효한 JSON 형식으로만 응답하세요. 다른 텍스트는 포함하지 마세요.`

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

    // 응답 데이터 구성
    const resultData = {
      title: fortuneData.title || `행운 아이템 - ${name}님`,
      summary: fortuneData.summary || '', // ✅ 무료: 공개
      keyword: fortuneData.keyword || '', // ✅ 무료: 공개
      color: fortuneData.color || '', // ✅ 무료: 공개
      numbers: fortuneData.numbers || [3, 7, 21], // ✅ 무료: 공개
      direction: fortuneData.direction || '동쪽', // ✅ 무료: 공개
      element: fortuneData.element || '금', // ✅ 무료: 공개
      score: fortuneData.score || 75, // ✅ 무료: 공개
      fashion: fortuneData.fashion || [],
      food: fortuneData.food || [],
      jewelry: fortuneData.jewelry || [],
      material: fortuneData.material || [],
      places: fortuneData.places || [],
      relationships: fortuneData.relationships || [],
      advice: fortuneData.advice || '',
      timestamp: new Date().toISOString(),
      isBlurred, // ✅ 블러 상태
      blurredSections, // ✅ 블러된 섹션 목록
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
