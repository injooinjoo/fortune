import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface LuckySeriesFortuneRequest {
  name: string;
  birthDate: string;
  genre?: string;
  platform?: string;
  userId?: string;
}

interface SeriesRecommendation {
  title: string;
  platform: string;
  genre: string;
  description: string;
  rating: number; // 1-10
  reason: string;
  mood: string;
  timeToWatch: string;
  keyElements: string[];
}

interface LuckySeriesFortuneResponse {
  success: boolean;
  data: {
    name: string;
    birthDate: string;
    genre: string;
    platform: string;
    mainSeries: SeriesRecommendation;
    subSeries: SeriesRecommendation;
    avoidSeries: {
      title: string;
      reason: string;
    };
    weeklyTheme: string;
    luckyGenres: string[];
    recommendations: string[];
    energyBooster: string;
    timestamp: string;
  };
  error?: string;
}

// 장르별 특성
const GENRE_CHARACTERISTICS = {
  '드라마': {
    keywords: ['감정', '인간관계', '현실', '일상'],
    energy: '감정적 치유',
    platforms: ['Netflix', '웨이브', '티빙']
  },
  '예능': {
    keywords: ['유머', '활력', '소통', '즐거움'],
    energy: '에너지 충전',
    platforms: ['YouTube', '웨이브', '티빙']
  },
  '영화': {
    keywords: ['완성도', '깊이', '예술', '감동'],
    energy: '영감과 감동',
    platforms: ['Netflix', '쿠팡플레이', '디즈니+']
  },
  '애니메이션': {
    keywords: ['상상력', '판타지', '순수', '창의성'],
    energy: '창의적 영감',
    platforms: ['Netflix', '디즈니+', 'YouTube']
  },
  '다큐멘터리': {
    keywords: ['지식', '현실', '교육', '깨달음'],
    energy: '지적 자극',
    platforms: ['Netflix', 'YouTube', '디즈니+']
  },
  'K-POP': {
    keywords: ['리듬', '열정', '문화', '트렌드'],
    energy: '활력 증진',
    platforms: ['YouTube', 'Spotify', '웨이브']
  },
  '팟캐스트': {
    keywords: ['대화', '정보', '사유', '소통'],
    energy: '마음의 평화',
    platforms: ['Spotify', 'YouTube', '네이버']
  },
  '웹툰': {
    keywords: ['스토리', '시각적', '연재', '몰입'],
    energy: '상상력 자극',
    platforms: ['카카오페이지', '네이버웹툰', '레진코믹스']
  },
  '소설': {
    keywords: ['문학', '상상', '깊이', '사색'],
    energy: '내면적 성찰',
    platforms: ['카카오페이지', '네이버시리즈', '리디북스']
  }
}

// 플랫폼별 특징
const PLATFORM_FEATURES = {
  'Netflix': {
    strengths: ['글로벌 콘텐츠', '오리지널', '고품질'],
    mood: '세련되고 글로벌한',
    genres: ['드라마', '영화', '다큐멘터리', '애니메이션']
  },
  '웨이브': {
    strengths: ['국내 콘텐츠', '예능', '방송'],
    mood: '친근하고 재미있는',
    genres: ['예능', '드라마', 'K-POP']
  },
  '티빙': {
    strengths: ['실시간 방송', '스포츠', '종합'],
    mood: '활기찬',
    genres: ['예능', '드라마', '스포츠']
  },
  '쿠팡플레이': {
    strengths: ['영화', '해외 콘텐츠', '독점'],
    mood: '시네마틱한',
    genres: ['영화', '드라마']
  },
  '디즈니+': {
    strengths: ['가족', '애니메이션', '마블'],
    mood: '따뜻하고 모험적인',
    genres: ['애니메이션', '영화', '가족']
  },
  'YouTube': {
    strengths: ['개인 크리에이터', '다양성', '접근성'],
    mood: '자유롭고 창의적인',
    genres: ['예능', 'K-POP', '다큐멘터리', '교육']
  },
  'Spotify': {
    strengths: ['음악', '팟캐스트', '개인화'],
    mood: '음악적이고 개성있는',
    genres: ['K-POP', '팟캐스트']
  },
  '카카오페이지': {
    strengths: ['웹툰', '웹소설', '완결'],
    mood: '몰입감 있는',
    genres: ['웹툰', '소설']
  },
  '네이버웹툰': {
    strengths: ['다양한 장르', '요일연재', '무료'],
    mood: '일상적이고 친근한',
    genres: ['웹툰']
  }
}

// 요일별 에너지
const DAILY_ENERGY = {
  '일요일': { mood: '휴식과 재충전', energy: 'healing' },
  '월요일': { mood: '새로운 시작', energy: 'motivation' },
  '화요일': { mood: '집중과 몰입', energy: 'focus' },
  '수요일': { mood: '균형과 조화', energy: 'balance' },
  '목요일': { mood: '창의와 영감', energy: 'creativity' },
  '금요일': { mood: '해방과 즐거움', energy: 'joy' },
  '토요일': { mood: '자유와 모험', energy: 'adventure' }
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

    const { name, birthDate, genre, platform, userId }: LuckySeriesFortuneRequest = await req.json()

    // 입력 데이터 검증
    if (!name || !birthDate) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '이름과 생년월일이 모두 필요합니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }

    // 캐시 확인 (오늘 같은 사용자로 생성된 행운 시리즈 운세가 있는지)
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_lucky_series_${name}_${today}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'lucky_series')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult.result
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 생년월일에서 운세 요소 추출
    const birthDateObj = new Date(birthDate)
    const birthMonth = birthDateObj.getMonth() + 1
    const birthDay = birthDateObj.getDate()
    const zodiacSign = getZodiacSign(birthMonth, birthDay)
    const currentDay = new Date().toLocaleDateString('ko-KR', { weekday: 'long' })

    // 선호 장르와 플랫폼
    const preferredGenre = genre || '전체'
    const preferredPlatform = platform || '전체'

    // OpenAI API 호출
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-oss-20b',
        messages: [
          {
            role: 'system',
            content: `당신은 전문적인 콘텐츠 큐레이터이자 운세 전문가입니다. 사용자의 개인정보와 취향을 바탕으로 오늘 특별히 행운을 가져다줄 시리즈나 콘텐츠를 추천합니다.

다음 JSON 형식으로 응답해주세요:
{
  "mainSeries": {
    "title": "메인 추천 시리즈/콘텐츠 제목",
    "platform": "추천 플랫폼",
    "genre": "장르",
    "description": "200자 내외의 매력적인 설명",
    "rating": 추천도 점수 (1-10),
    "reason": "왜 오늘 이 콘텐츠가 행운을 가져다줄지 설명",
    "mood": "이 콘텐츠가 주는 기분/분위기",
    "timeToWatch": "시청하기 좋은 시간대",
    "keyElements": ["핵심 요소1", "핵심 요소2", "핵심 요소3"]
  },
  "subSeries": {
    "title": "보조 추천 시리즈/콘텐츠",
    "platform": "플랫폼",
    "genre": "장르",
    "description": "150자 내외 설명",
    "rating": 점수 (1-10),
    "reason": "추천 이유",
    "mood": "분위기",
    "timeToWatch": "시청 시간대",
    "keyElements": ["요소1", "요소2"]
  },
  "avoidSeries": {
    "title": "오늘 피해야 할 콘텐츠 유형",
    "reason": "피해야 하는 이유"
  },
  "weeklyTheme": "이번 주 콘텐츠 테마",
  "luckyGenres": ["행운의 장르1", "행운의 장르2", "행운의 장르3"],
  "recommendations": ["실용적 조언1", "실용적 조언2", "실용적 조언3"],
  "energyBooster": "에너지를 충전할 수 있는 특별 추천"
}

모든 추천은 실제 존재하는 콘텐츠 또는 현실적인 콘텐츠 유형을 기반으로 해야 하며, 긍정적이고 희망적인 메시지를 담아야 합니다.`
          },
          {
            role: 'user',
            content: `이름: ${name}
생년월일: ${birthDate} (별자리: ${zodiacSign})
선호 장르: ${preferredGenre}
선호 플랫폼: ${preferredPlatform}
오늘: ${currentDay}
날짜: ${new Date().toLocaleDateString('ko-KR')}

이 정보를 바탕으로 ${name}님에게 오늘 특별한 행운과 긍정적인 에너지를 가져다줄 시리즈나 콘텐츠를 추천해주세요. 개인의 특성과 오늘의 에너지를 고려하여 가장 적합한 콘텐츠를 골라주세요.`
          }
        ],
        response_format: { type: "json_object" },
        temperature: 0.8,
        max_tokens: 2000
      }),
    })

    if (!openaiResponse.ok) {
      throw new Error(`OpenAI API 오류: ${openaiResponse.status}`)
    }

    const openaiResult = await openaiResponse.json()
    const fortuneData = JSON.parse(openaiResult.choices[0].message.content)

    const result: LuckySeriesFortuneResponse['data'] = {
      name,
      birthDate,
      genre: preferredGenre,
      platform: preferredPlatform,
      mainSeries: fortuneData.mainSeries || {
        title: "특별한 시리즈",
        platform: preferredPlatform,
        genre: preferredGenre,
        description: "오늘 당신에게 특별한 행운을 가져다줄 콘텐츠입니다.",
        rating: 8,
        reason: "당신의 에너지와 완벽하게 조화를 이룹니다.",
        mood: "긍정적이고 희망찬",
        timeToWatch: "저녁 시간",
        keyElements: ["행운", "긍정", "에너지"]
      },
      subSeries: fortuneData.subSeries || {
        title: "보조 추천",
        platform: preferredPlatform,
        genre: preferredGenre,
        description: "메인 추천과 함께 보면 더욱 좋은 콘텐츠입니다.",
        rating: 7,
        reason: "추가적인 긍정 에너지를 제공합니다.",
        mood: "편안하고 즐거운",
        timeToWatch: "자유 시간",
        keyElements: ["힐링", "재미"]
      },
      avoidSeries: fortuneData.avoidSeries || {
        title: "무거운 분위기의 콘텐츠",
        reason: "오늘은 가벼운 마음으로 즐길 수 있는 것이 좋습니다."
      },
      weeklyTheme: fortuneData.weeklyTheme || "긍정적인 에너지 충전",
      luckyGenres: fortuneData.luckyGenres || [preferredGenre, "힐링", "코미디"],
      recommendations: fortuneData.recommendations || [
        "자신만의 시간을 가지며 콘텐츠를 즐기세요",
        "좋아하는 간식과 함께 시청하면 더욱 좋습니다",
        "감동적인 장면에서는 마음껏 감정을 표현하세요"
      ],
      energyBooster: fortuneData.energyBooster || "따뜻한 차 한 잔과 함께하는 힐링 타임",
      timestamp: new Date().toISOString()
    }

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'lucky_series',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        data: result
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Lucky Series Fortune API Error:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '행운 시리즈 운세 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})

// 생년월일로 별자리 계산
function getZodiacSign(month: number, day: number): string {
  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return '양자리'
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return '황소자리'
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return '쌍둥이자리'
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return '게자리'
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return '사자자리'
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return '처녀자리'
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return '천칭자리'
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return '전갈자리'
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return '사수자리'
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return '염소자리'
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return '물병자리'
  return '물고기자리'
}