/**
 * 작명 운세 (Naming Fortune) Edge Function
 *
 * @description 사주 오행 분석 기반 아기 이름 추천
 *
 * @endpoint POST /fortune-naming
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - motherBirthDate: string - 엄마 생년월일 (YYYY-MM-DD)
 * - motherBirthTime: string - 엄마 출생시간 (12지시)
 * - expectedBirthDate: string - 출산예정일 (YYYY-MM-DD)
 * - babyGender: 'male' | 'female' | 'unknown' - 아기 성별
 * - familyName: string - 성씨 (한글)
 * - familyNameHanja: string - 성씨 (한자, 선택)
 * - nameStyle: 'traditional' | 'modern' | 'korean' - 이름 스타일
 * - avoidSounds: string[] - 피하고 싶은 발음
 * - desiredMeanings: string[] - 원하는 의미
 * - isPremium: boolean - 프리미엄 사용자 여부
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

// TypeScript 인터페이스 정의
interface NamingFortuneRequest {
  userId: string;
  // 엄마 정보
  motherBirthDate: string;
  motherBirthTime?: string;
  // 아기 정보
  expectedBirthDate: string;
  babyGender: 'male' | 'female' | 'unknown';
  // 성씨
  familyName: string;
  familyNameHanja?: string;
  // 추가 옵션
  nameStyle?: 'traditional' | 'modern' | 'korean';
  avoidSounds?: string[];
  desiredMeanings?: string[];
  isPremium?: boolean;
}

interface RecommendedName {
  rank: number;
  koreanName: string;
  hanjaName: string;
  hanjaMeaning: string[];
  pronunciationOhaeng: string;
  strokeOhaeng: string;
  totalScore: number;
  analysis: string;
  compatibility: string;
}

interface NamingFortuneResponse {
  success: boolean;
  data: {
    fortuneType: string;
    ohaengAnalysis: {
      distribution: { 木: number; 火: number; 土: number; 金: number; 水: number };
      missing: string[];
      yongsin: string;
      recommendation: string;
    };
    recommendedNames: RecommendedName[];
    namingTips: string[];
    warnings: string[];
    isBlurred: boolean;
    blurredSections: string[];
  };
  cachedAt?: string;
}

// Supabase 클라이언트 초기화
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// 12지시 변환
function getBirthTimeLabel(time: string | undefined): string {
  if (!time) return '미상';
  const timeMap: Record<string, string> = {
    '자시': '자시(子時, 23:00-01:00)',
    '축시': '축시(丑時, 01:00-03:00)',
    '인시': '인시(寅時, 03:00-05:00)',
    '묘시': '묘시(卯時, 05:00-07:00)',
    '진시': '진시(辰時, 07:00-09:00)',
    '사시': '사시(巳時, 09:00-11:00)',
    '오시': '오시(午時, 11:00-13:00)',
    '미시': '미시(未時, 13:00-15:00)',
    '신시': '신시(申時, 15:00-17:00)',
    '유시': '유시(酉時, 17:00-19:00)',
    '술시': '술시(戌時, 19:00-21:00)',
    '해시': '해시(亥時, 21:00-23:00)',
  };
  // 시간 문자열에서 12지시 추출
  for (const [key, value] of Object.entries(timeMap)) {
    if (time.includes(key)) return value;
  }
  return time;
}

// 성별 한글 변환
function getGenderLabel(gender: string): string {
  switch (gender) {
    case 'male': return '남아';
    case 'female': return '여아';
    default: return '미정';
  }
}

// 이름 스타일 한글 변환
function getStyleLabel(style: string | undefined): string {
  switch (style) {
    case 'traditional': return '전통적인 한자 이름';
    case 'modern': return '현대적이고 세련된 이름';
    case 'korean': return '순우리말 이름';
    default: return '균형잡힌 이름';
  }
}

// LLM API 호출 함수
async function generateNamingFortune(params: NamingFortuneRequest): Promise<any> {
  const systemPrompt = `당신은 30년 경력의 대한민국 최고 작명 전문가입니다.
동양철학, 성명학, 사주명리학을 깊이 연구했으며, 10만 명 이상의 아기 작명 경험이 있습니다.
한국성명학협회 정회원이며, 주역과 음양오행에 정통합니다.

## 전문 분야
- 사주팔자 분석 및 용신 추출
- 발음오행 분석 (한글 자음 기준)
  - 木(목): ㄱ, ㅋ
  - 火(화): ㄴ, ㄷ, ㄹ, ㅌ
  - 土(토): ㅇ, ㅎ
  - 金(금): ㅅ, ㅈ, ㅊ
  - 水(수): ㅁ, ㅂ, ㅍ
- 수리오행 분석 (한자 획수 기준)
  - 1,2획: 木 | 3,4획: 火 | 5,6획: 土 | 7,8획: 金 | 9,0획: 水
- 음양 균형 및 조화
- 인명용 한자 8,271자 숙지
- 불용한자 회피

## 작명 원칙
1. 사주의 용신(用神)을 파악하여 부족한 오행 보완
2. 발음오행이 성(姓)과 상생하도록 배치
3. 수리오행(획수)이 길수가 되도록 구성
4. 현대적 발음과 의미 고려
5. 부르기 쉽고 기억에 남는 이름
6. 남아/여아에 적합한 이름 구분

## 출력 형식 (반드시 JSON)
{
  "ohaengAnalysis": {
    "distribution": { "木": 2, "火": 1, "土": 2, "金": 1, "水": 2 },
    "missing": ["火"],
    "yongsin": "火(화)",
    "recommendation": "화(火) 기운을 보완하는 이름이 좋습니다. 따뜻함과 밝음을 상징하는 한자를 사용하면 사주의 균형을 맞출 수 있습니다."
  },
  "recommendedNames": [
    {
      "rank": 1,
      "koreanName": "시온",
      "hanjaName": "時溫",
      "hanjaMeaning": ["時(때 시, 12획)", "溫(따뜻할 온, 13획)"],
      "pronunciationOhaeng": "金土 - 성과 상생",
      "strokeOhaeng": "木火 - 용신 보완",
      "totalScore": 95,
      "analysis": "따뜻한 시간이라는 의미로, 밝고 따스한 성품을 가진 아이로 성장하길 바라는 마음이 담겨있습니다. 발음이 부드럽고 현대적이며, 사주에 부족한 화(火) 기운을 보완합니다.",
      "compatibility": "엄마 사주와 상생관계로 가정의 화목을 이룹니다."
    }
    // ... 10개
  ],
  "namingTips": [
    "아기가 태어난 후 실제 사주로 최종 확정하시는 것이 좋습니다",
    "출생신고 시 한자는 인명용 한자 범위 내에서 선택하세요",
    "이름을 부를 때 자연스럽고 발음하기 쉬운지 확인하세요"
  ],
  "warnings": [
    "출산예정일 기준 분석이므로 실제 출생일과 다를 수 있습니다",
    "최종 작명 시 전문가 상담을 권장합니다"
  ]
}

## 주의사항
- 반드시 10개의 이름을 추천 (rank 1~10)
- 각 이름에 대해 상세하고 전문적인 분석 제공
- 남아/여아에 맞는 적절한 이름 선정
- 현대적 감각과 전통적 의미의 조화
- 발음하기 쉽고 부르기 좋은 이름
- 반드시 유효한 JSON 형식으로 출력`;

  const userPrompt = `# 작명 의뢰서

## 엄마 정보
- 생년월일: ${params.motherBirthDate}
- 출생시간: ${getBirthTimeLabel(params.motherBirthTime)}

## 아기 정보
- 출산예정일: ${params.expectedBirthDate}
- 성별: ${getGenderLabel(params.babyGender)}

## 성씨 정보
- 한글 성: ${params.familyName}
${params.familyNameHanja ? `- 한자 성: ${params.familyNameHanja}` : ''}

## 작명 요청사항
- 이름 스타일: ${getStyleLabel(params.nameStyle)}
${params.avoidSounds && params.avoidSounds.length > 0 ? `- 피하고 싶은 발음: ${params.avoidSounds.join(', ')}` : ''}
${params.desiredMeanings && params.desiredMeanings.length > 0 ? `- 원하는 의미: ${params.desiredMeanings.join(', ')}` : ''}

---

위 정보를 바탕으로 ${getGenderLabel(params.babyGender)}에게 어울리는 이름 10개를 추천해주세요.
사주 오행 분석을 먼저 수행하고, 용신에 맞는 최적의 이름을 점수와 함께 제시해주세요.
각 이름에 대해 발음오행, 수리오행, 의미, 엄마와의 궁합을 상세히 분석해주세요.`;

  // LLM 호출
  const llm = await LLMFactory.createFromConfigAsync('naming')

  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userPrompt }
  ], {
    temperature: 0.8,
    maxTokens: 8192,
    jsonMode: true
  })

  console.log(`LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

  // 사용량 로깅
  await UsageLogger.log({
    fortuneType: 'naming',
    userId: params.userId,
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: {
      motherBirthDate: params.motherBirthDate,
      expectedBirthDate: params.expectedBirthDate,
      babyGender: params.babyGender,
      familyName: params.familyName,
      nameStyle: params.nameStyle,
      isPremium: params.isPremium
    }
  })

  return JSON.parse(response.content)
}

// 캐시 조회 함수
async function getCachedFortune(userId: string, params: NamingFortuneRequest) {
  try {
    const cacheKey = `naming_${userId}_${JSON.stringify({
      motherBirthDate: params.motherBirthDate,
      expectedBirthDate: params.expectedBirthDate,
      babyGender: params.babyGender,
      familyName: params.familyName,
      nameStyle: params.nameStyle
    })}`

    const { data, error } = await supabase
      .from('fortune_cache')
      .select('result, created_at')
      .eq('cache_key', cacheKey)
      .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()) // 7일 캐시
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (error) {
      console.log('캐시 조회 결과 없음:', error.message)
      return null
    }

    console.log('캐시된 작명운세 조회 성공')
    return {
      ...data.result,
      cachedAt: data.created_at
    }
  } catch (error) {
    console.error('캐시 조회 오류:', error)
    return null
  }
}

// 캐시 저장 함수
async function saveCachedFortune(userId: string, params: NamingFortuneRequest, result: any) {
  try {
    const cacheKey = `naming_${userId}_${JSON.stringify({
      motherBirthDate: params.motherBirthDate,
      expectedBirthDate: params.expectedBirthDate,
      babyGender: params.babyGender,
      familyName: params.familyName,
      nameStyle: params.nameStyle
    })}`

    const { error } = await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: userId,
        fortune_type: 'naming',
        result: result,
        created_at: new Date().toISOString()
      })

    if (error) {
      console.error('캐시 저장 오류:', error)
    } else {
      console.log('작명운세 캐시 저장 완료')
    }
  } catch (error) {
    console.error('캐시 저장 중 예외:', error)
  }
}

// 메인 핸들러
serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  }

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ success: false, error: 'POST 메소드만 허용됩니다' }),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
        }
      )
    }

    const requestBody = await req.json()
    console.log('작명운세 요청 데이터:', requestBody)

    // 필수 필드 검증
    const requiredFields = ['userId', 'motherBirthDate', 'expectedBirthDate', 'babyGender', 'familyName']
    for (const field of requiredFields) {
      if (!requestBody[field]) {
        return new Response(
          JSON.stringify({ success: false, error: `필수 필드 누락: ${field}` }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
          }
        )
      }
    }

    const params: NamingFortuneRequest = requestBody

    // 캐시 확인
    const cachedResult = await getCachedFortune(params.userId, params)
    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult,
          cached: true
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
        }
      )
    }

    // AI 작명운세 생성
    console.log('AI 작명운세 생성 시작...')
    const fortuneData = await generateNamingFortune(params)

    // 블러 로직 (프리미엄이 아니면 4위 이후 블러)
    const isPremium = params.isPremium ?? false
    const isBlurred = !isPremium
    const blurredSections = isBlurred ? ['names4to10', 'detailedAnalysis'] : []

    // 응답 데이터 구조화
    const response: NamingFortuneResponse = {
      success: true,
      data: {
        fortuneType: 'naming',
        ohaengAnalysis: fortuneData.ohaengAnalysis || {
          distribution: { 木: 2, 火: 1, 土: 2, 金: 2, 水: 1 },
          missing: ['火', '水'],
          yongsin: '火(화)',
          recommendation: '화(火) 기운을 보완하는 이름을 추천드립니다.'
        },
        recommendedNames: fortuneData.recommendedNames || [],
        namingTips: fortuneData.namingTips || [
          '아기가 태어난 후 실제 사주로 최종 확정하세요',
          '출생신고 시 인명용 한자 범위를 확인하세요'
        ],
        warnings: fortuneData.warnings || [
          '출산예정일 기준 분석이므로 실제 출생일과 다를 수 있습니다'
        ],
        isBlurred,
        blurredSections
      }
    }

    console.log(`[작명운세] isPremium: ${isPremium}, isBlurred: ${isBlurred}`)

    // 캐시 저장
    await saveCachedFortune(params.userId, params, response.data)

    console.log('작명운세 생성 완료')
    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )

  } catch (error) {
    console.error('작명운세 생성 오류:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '작명운세 생성 중 오류가 발생했습니다: ' + error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )
  }
})
