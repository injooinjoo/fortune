import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 저장된 사주 데이터 조회 함수
async function getSavedSajuData(supabase: any, userId: string) {
  try {
    const { data: sajuData, error } = await supabase
      .from('user_saju')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle()
    
    if (error) {
      console.log('⚠️ Error fetching saju data:', error)
      return null
    }
    
    if (!sajuData) {
      console.log('ℹ️ No saju data found for user')
      return null
    }
    
    // 사주 데이터를 기존 analyzeSaju 형식으로 변환
    return {
      천간: sajuData.year_cheongan,
      지지: sajuData.year_jiji,
      오행: {
        목: sajuData.element_wood,
        화: sajuData.element_fire,
        토: sajuData.element_earth,
        금: sajuData.element_metal,
        수: sajuData.element_water
      },
      간지: `${sajuData.year_cheongan}${sajuData.year_jiji}`,
      부족한오행: sajuData.weak_element,
      보충방법: sajuData.enhancement_method,
      상세사주: {
        년주: { 천간: sajuData.year_cheongan, 지지: sajuData.year_jiji },
        월주: { 천간: sajuData.month_cheongan, 지지: sajuData.month_jiji },
        일주: { 천간: sajuData.day_cheongan, 지지: sajuData.day_jiji },
        시주: { 천간: sajuData.hour_cheongan, 지지: sajuData.hour_jiji }
      },
      성격: sajuData.personality_traits,
      운세요약: sajuData.fortune_summary,
      전체분석: sajuData.gpt_analysis
    }
  } catch (e) {
    console.log('❌ Exception fetching saju data:', e)
    return null
  }
}

serve(async (req) => {
  console.log('🚀 Function invoked:', new Date().toISOString())
  console.log('Method:', req.method)
  console.log('Headers:', Object.fromEntries(req.headers.entries()))
  
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    console.log('📦 Request body:', JSON.stringify(body))
    
    const { 
      userName, 
      userProfile,
      weather, 
      fortune, 
      date, 
      storyConfig 
    } = body

    // OpenAI API 키 확인
    const openAIApiKey = Deno.env.get('OPENAI_API_KEY')
    console.log('🔑 OpenAI API key configured:', !!openAIApiKey)
    
    if (!openAIApiKey) {
      console.log('⚠️ OpenAI API key not configured, returning default story')
      const defaultSegments = createDefaultStory(userName, fortune, userProfile, weather)
      console.log('🎭 Default story created with', defaultSegments.length, 'segments')
      return new Response(
        JSON.stringify({ 
          segments: defaultSegments 
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200 
        }
      )
    }

    // Supabase 클라이언트 초기화
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    
    // 사용자 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Authorization header is required')
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      throw new Error('Invalid authorization token')
    }

    // 저장된 사주 데이터 조회
    console.log('🔮 Fetching saved Saju data for user:', userName)
    const sajuAnalysis = await getSavedSajuData(supabase, user.id);
    console.log('🎯 Saju analysis result:', sajuAnalysis ? '데이터 있음' : '데이터 없음');
    
    // GPT-4로 종합 운세 및 스토리 생성
    const systemPrompt = `당신은 한국의 전통 사주명리학과 현대적 감성을 결합한 전문 운세 스토리텔러입니다.
사용자의 사주팔자, 오행 균형, 현재 날씨, 오늘의 운세를 바탕으로 종합적인 운세 데이터와 15페이지 스토리를 만들어주세요.

중요: 절대 "사용자님"이라고 하지 마세요. 반드시 제공된 실제 이름(userName)을 사용하세요.
예를 들어 userName이 "김인주"라면 "김인주님"이라고 호칭하세요.

반드시 다음 JSON 형식으로 응답하세요:
{
  "meta": {
    "date": "2025-08-17",
    "weekday": "일요일", 
    "timezone": "Asia/Seoul",
    "city": "서울"
  },
  "weatherSummary": {
    "icon": "☀",
    "condition": "맑음",
    "temp_high": 30,
    "temp_low": 22,
    "uv_index": 7,
    "aqi_label": "보통"
  },
  "overall": {
    "score": 78,
    "grade": "A-",
    "trend_vs_yesterday": "상승",
    "summary": "안정 속 성과. 오후엔 체력관리에 신경 쓰면 좋습니다."
  },
  "categories": {
    "love": {
      "score": 74,
      "short": "대화가 통하는 날",
      "advice": "직설보단 부드럽게.",
      "do": ["감사 표현"],
      "dont": ["답장 지연"],
      "lucky_time": "19:00-21:00"
    },
    "money": {
      "score": 66,
      "short": "지출 관리가 핵심",
      "advice": "큰 지출은 미루기.",
      "do": ["예산 점검"],
      "dont": ["충동구매"]
    },
    "work": {
      "score": 82,
      "short": "꾸준함이 성과로",
      "advice": "회의에서 한 문장으로 요지 정리.",
      "do": ["우선순위 확정"],
      "dont": ["일정 낙관"]
    },
    "health": {
      "score": 70,
      "short": "소화기 주의",
      "advice": "따뜻한 차와 가벼운 걷기.",
      "do": ["스트레칭"],
      "dont": ["야식"]
    },
    "social": {
      "score": 76,
      "short": "관계 회복의 운",
      "advice": "사소한 안부가 효과적."
    }
  },
  "sajuInsight": {
    "day_master": "을",
    "favorable_elements": ["수", "목"],
    "unfavorable_elements": ["토"],
    "luck_direction": "동쪽",
    "lucky_color": "파란색",
    "lucky_item": "작은 노트",
    "keyword": "정돈"
  },
  "personalActions": [
    { "title": "오전 우선순위 3개 확정", "why": "일간(木)과 안정 운, 집중력 상승" },
    { "title": "점심 산책 10분", "why": "건강운(소화) + 날씨 맑음" },
    { "title": "지출 알림 켜기", "why": "금전운 주의 신호" }
  ],
  "notification": {
    "title": "오늘 운세 도착!",
    "body": "A- 컨디션. 오후엔 체력관리+지출 체크하면 베스트 👍"
  },
  "shareCard": {
    "title": "오늘의 운세 A-",
    "subtitle": "꾸준함=성과",
    "hashtags": ["#데일리운세", "#행운컬러파랑"],
    "emoji": "✨"
  },
  "segments": [
    { 
      "text": "텍스트", 
      "fontSize": 24, 
      "fontWeight": 300,
      "category": "인사|사주|운세|조언|요약",
      "emoji": "이모지 (선택적)",
      "subtitle": "부제목 (선택적)"
    },
    ... (총 15개 페이지)
  ]
}

각 섹션별 요구사항:
- meta: 오늘 날짜 정보
- weatherSummary: 제공된 날씨 정보 기반 생성
- overall: 전체 운세 점수 (0-100), 등급 (A~D), 어제 대비 트렌드, 한 줄 요약
- categories: 5대 분야별 점수와 조언 (각각 0-100점)
- sajuInsight: 사주 기반 행운 요소들
- personalActions: 실천 가능한 추천 활동 3개
- notification: 푸시 알림용 짧은 메시지
- shareCard: SNS 공유용 텍스트
- segments: 기존 스토리 (15페이지)
- subtitle: 작은 부제목 (선택적)

스토리는 다음 흐름을 따라야 합니다:
1. 인사 및 환영 (실제 이름으로 따뜻한 인사)
2. 오늘 날짜와 절기 소개
3. 사주 간지 소개 (천간지지)
4. 오행 균형 분석
5. 오늘의 기운과 사주의 조화
6. 새벽/아침 운세 (오전 6-12시)
7. 오후 운세 (오후 12-6시)
8. 저녁/밤 운세 (오후 6시-자정)
9. 대인관계 운
10. 재물운과 사업운
11. 건강운과 주의사항
12. 오늘의 행운 요소 (색상, 숫자, 방향)
13. 사주 기반 맞춤 조언
14. 내일을 위한 준비
15. 종합 요약 및 마무리 (격려의 메시지)`

    const userPrompt = `사용자 정보:
- 이름: ${userName} (절대적으로 중요: 이 이름 "${userName}"을 반드시 사용하세요. 절대로 "사용자님"이라고 하지 마세요. 반드시 "${userName}님"으로 호칭하세요)
${userProfile ? `- 생년월일: ${userProfile.birthDate}
- 생시: ${userProfile.birthTime || '모름'}
- 성별: ${userProfile.gender || '비공개'}
- 음력 여부: ${userProfile.isLunar ? '음력' : '양력'}
- 띠: ${userProfile.zodiacAnimal || ''}
- 별자리: ${userProfile.zodiacSign || ''}
- MBTI: ${userProfile.mbti || ''}
- 혈액형: ${userProfile.bloodType || ''}` : ''}

날씨 정보:
- 상태: ${weather.description}
- 온도: ${weather.temperature}°C
- 지역: ${weather.cityName} (이 지역명이 영어인 경우 한글로 변환하고, 상세 주소는 광역시/도 단위로 간소화하세요. 예: "Seoul" → "서울", "Suwon-si" → "경기도", "Gangnam-gu" → "서울")

운세 정보:
- 점수: ${fortune.score}/100
- 요약: ${fortune.summary || ''}
- 행운의 색: ${fortune.luckyColor || ''}
- 행운의 숫자: ${fortune.luckyNumber || ''}
- 행운의 시간: ${fortune.luckyTime || ''}
- 조언: ${fortune.advice || ''}
사주 분석:
${sajuAnalysis ? `- 천간: ${sajuAnalysis.천간}
- 지지: ${sajuAnalysis.지지}
- 간지: ${sajuAnalysis.간지}
- 오행 균형: 목(${sajuAnalysis.오행.목}), 화(${sajuAnalysis.오행.화}), 토(${sajuAnalysis.오행.토}), 금(${sajuAnalysis.오행.금}), 수(${sajuAnalysis.오행.수})
- 부족한 오행: ${sajuAnalysis.부족한오행}
- 보충 방법: ${sajuAnalysis.보충방법}
- 성격 분석: ${sajuAnalysis.성격 || '없음'}
- 운세 요약: ${sajuAnalysis.운세요약 || '없음'}` : '사주 정보 없음 (기본 운세로 진행)'}

10페이지 분량의 운세 스토리를 만들어주세요.
반드시 segments 키 안에 10개의 페이지 배열을 포함하세요.
그리고 sajuAnalysis 객체도 함께 반함하세요.`

    console.log('🤖 Calling LLM API...')

    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('fortune-story')

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)
    console.log(`📝 Token 사용량: prompt=${response.usage.promptTokens}, completion=${response.usage.completionTokens}, total=${response.usage.totalTokens}`)

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const storyContent = JSON.parse(response.content)
    console.log('📦 Story content type:', typeof storyContent)
    console.log('📦 Story content keys:', Object.keys(storyContent))

    // 확장된 응답 구조 처리
    let segments = [];
    let meta = null;
    let weatherSummary = null;
    let overall = null;
    let categories = null;
    let sajuInsight = null;
    let personalActions = null;
    let notification = null;
    let shareCard = null;

    if (storyContent.segments && Array.isArray(storyContent.segments)) {
      segments = storyContent.segments;
      
      // 확장된 데이터 추출
      meta = storyContent.meta || null;
      weatherSummary = storyContent.weatherSummary || null;
      overall = storyContent.overall || null;
      categories = storyContent.categories || null;
      sajuInsight = storyContent.sajuInsight || null;
      personalActions = storyContent.personalActions || null;
      notification = storyContent.notification || null;
      shareCard = storyContent.shareCard || null;
    } else {
      // 기본 형식으로 변환 시도
      segments = createDefaultStory(userName, fortune, userProfile, weather);
      
      // 기본 데이터 생성
      const now = new Date();
      meta = {
        date: now.toISOString().split('T')[0],
        weekday: getWeekday(now.getDay()),
        timezone: "Asia/Seoul",
        city: "서울"
      };
      
      overall = {
        score: fortune?.score || 75,
        grade: getGrade(fortune?.score || 75),
        trend_vs_yesterday: "유지",
        summary: "오늘도 좋은 하루가 되길 바랍니다."
      };
    }
    
    console.log(`🎉 Returning ${segments.length} story segments with enhanced data`)
    
    // 확장된 응답 데이터
    const responseData = {
      segments,
      sajuAnalysis: sajuAnalysis,
      meta,
      weatherSummary,
      overall,
      categories,
      sajuInsight,
      personalActions,
      notification,
      shareCard
    }
    
    return new Response(
      JSON.stringify(responseData),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('❌ Error generating story:', error)
    console.error('Stack trace:', error.stack)
    
    // 에러 시 기본 스토리 반환 (userName이 없을 때만 '사용자' 사용)
    const fallbackName = req.json?.userName || ''
    return new Response(
      JSON.stringify({ 
        segments: createDefaultStory(fallbackName, { score: 75 }, null, null) 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  }
})

// 기본 스토리 생성 함수 (동적)
function createDefaultStory(userName: string, fortune: any, userProfile: any, weather: any) {
  const score = fortune?.score || 75
  const now = new Date()
  
  // 날짜 기반 시드 생성
  const dateSeed = now.getFullYear() * 10000 + (now.getMonth() + 1) * 100 + now.getDate()
  const userSeed = (userName || 'anonymous').split('').reduce((sum, char) => sum + char.charCodeAt(0), 0)
  const combinedSeed = dateSeed + userSeed
  
  // 시드를 기반으로 한 난수 생성 함수
  const seededRandom = (seed: number) => {
    const x = Math.sin(seed) * 10000
    return x - Math.floor(x)
  }
  
  // Ensure we use the actual name, not '사용자'
  const displayName = (userName && userName !== '사용자') ? `${userName}님` : '오늘의 주인공'
  
  // 동적 에너지 메시지
  const energyMessages = score >= 80 
    ? ['특별한 에너지가\n넘치는 날', '빛나는 기운이\n함께하는 날', '모든 일이 순조로운\n행운의 날']
    : score >= 60 
    ? ['차분하고 안정적인\n하루', '균형잡힌\n평온한 하루', '꾸준함이 빛나는\n의미있는 하루']
    : ['천천히 가도\n괜찮은 날', '마음의 여유가\n필요한 날', '휴식과 재충전의\n소중한 시간']
    
  const energyIndex = Math.floor(seededRandom(combinedSeed) * energyMessages.length)
  
  // 동적 기회 메시지
  const opportunityMessages = [
    '오늘 당신에게는\n새로운 기회가\n찾아올 것입니다',
    '예상치 못한\n좋은 소식이\n들려올 수 있습니다',
    '소중한 인연이\n당신을 기다리고\n있을지도 모릅니다',
    '평소 관심있던 일에\n진전이 있을\n수 있습니다'
  ]
  const oppIndex = Math.floor(seededRandom(combinedSeed * 2) * opportunityMessages.length)
  
  // 동적 아침 메시지
  const morningMessages = [
    '아침에는\n맑은 정신으로\n하루를 시작하세요',
    '새벽의 고요함 속에서\n내면의 평화를\n찾아보세요',
    '아침 햇살처럼\n밝은 마음으로\n시작하시길'
  ]
  const morningIndex = Math.floor(seededRandom(combinedSeed * 3) * morningMessages.length)
  
  // 동적 오후 메시지
  const afternoonMessages = [
    '오후에는\n중요한 결정을\n내릴 수 있습니다',
    '점심 이후\n활발한 소통이\n기다리고 있습니다',
    '오후 시간에\n창의적 영감이\n떠오를 것입니다'
  ]
  const afternoonIndex = Math.floor(seededRandom(combinedSeed * 4) * afternoonMessages.length)
  
  // 동적 주의사항
  const cautionMessages = [
    '급하게 서두르지 말고\n신중하게 행동하세요',
    '감정적인 결정보다는\n이성적 판단을\n우선하세요',
    '완벽을 추구하기보다\n최선을 다하는\n마음가짐이 중요합니다'
  ]
  const cautionIndex = Math.floor(seededRandom(combinedSeed * 5) * cautionMessages.length)
  
  // 동적 의미 메시지
  const meaningMessages = [
    '오늘은 작은 것에서\n큰 의미를 발견하는\n특별한 하루입니다',
    '평범한 순간들이\n특별한 기억으로\n남을 것입니다',
    '당신의 따뜻한 마음이\n주변에 좋은 영향을\n미칠 것입니다'
  ]
  const meaningIndex = Math.floor(seededRandom(combinedSeed * 6) * meaningMessages.length)
  
  // 동적 마무리 메시지
  const closingMessages = [
    '좋은 하루 되세요',
    '행복한 하루 보내세요',
    '의미있는 하루가 되길',
    '평안한 하루 되시길'
  ]
  const closingIndex = Math.floor(seededRandom(combinedSeed * 7) * closingMessages.length)
  
  // 운세 데이터에서 실제 정보 추출
  const luckyColor = fortune?.advice?.includes('색') ? 
    fortune.advice.match(/(빨간색|주황색|노란색|초록색|파란색|남색|보라색|하늘색|분홍색|검은색|흰색|회색)/)?.[0] || '하늘색'
    : fortune?.luckyColor || '하늘색'
    
  const luckyNumber = fortune?.content?.match(/\d+/)?.[0] || 
    fortune?.luckyNumber || 
    String(Math.floor(seededRandom(combinedSeed * 8) * 9) + 1)
  
  return [
    {
      text: displayName,
      fontSize: 36,
      fontWeight: 200
    },
    {
      text: `${now.getMonth() + 1}월 ${now.getDate()}일\n${getWeekday(now.getDay())}`,
      fontSize: 28,
      fontWeight: 300
    },
    {
      text: energyMessages[energyIndex],
      fontSize: 26,
      fontWeight: 300
    },
    {
      text: opportunityMessages[oppIndex],
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: morningMessages[morningIndex],
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: afternoonMessages[afternoonIndex],
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: cautionMessages[cautionIndex],
      fontSize: 22,
      fontWeight: 300
    },
    {
      text: `행운의 색: ${luckyColor}\n행운의 숫자: ${luckyNumber}`,
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: meaningMessages[meaningIndex],
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: closingMessages[closingIndex],
      fontSize: 28,
      fontWeight: 300
    }
  ]
}

function getWeekday(day: number): string {
  const weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일']
  return weekdays[day]
}

function getGrade(score: number): string {
  if (score >= 90) return 'A+';
  if (score >= 85) return 'A';
  if (score >= 80) return 'A-';
  if (score >= 75) return 'B+';
  if (score >= 70) return 'B';
  if (score >= 65) return 'B-';
  if (score >= 60) return 'C+';
  if (score >= 55) return 'C';
  if (score >= 50) return 'C-';
  return 'D';
}