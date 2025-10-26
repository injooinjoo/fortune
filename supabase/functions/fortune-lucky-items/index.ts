import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

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

    // LLM 호출
    const llm = LLMFactory.createFromConfig('fortune-lucky-items')

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
  "advice": "종합 조언 (3-5문장)"
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
    const result: LuckyItemsResponse = {
      success: true,
      data: {
        title: fortuneData.title || `행운 아이템 - ${name}님`,
        summary: fortuneData.summary || '', // ✅ 무료: 공개
        keyword: fortuneData.keyword || '', // ✅ 무료: 공개
        color: fortuneData.color || '', // ✅ 무료: 공개
        numbers: fortuneData.numbers || [3, 7, 21], // ✅ 무료: 공개
        direction: fortuneData.direction || '동쪽', // ✅ 무료: 공개
        element: fortuneData.element || '금', // ✅ 무료: 공개
        score: fortuneData.score || 75, // ✅ 무료: 공개
        fashion: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (fortuneData.fashion || []), // 🔒 유료
        food: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (fortuneData.food || []), // 🔒 유료
        jewelry: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (fortuneData.jewelry || []), // 🔒 유료
        material: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (fortuneData.material || []), // 🔒 유료
        places: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (fortuneData.places || []), // 🔒 유료
        relationships: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (fortuneData.relationships || []), // 🔒 유료
        advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (fortuneData.advice || ''), // 🔒 유료
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections, // ✅ 블러된 섹션 목록
      },
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
