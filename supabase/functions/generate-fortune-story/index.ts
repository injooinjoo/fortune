/**
 * 운세 스토리 생성 (Generate Fortune Story) Edge Function
 *
 * @description 사용자의 사주 데이터를 기반으로 개인화된 운세 스토리를 생성합니다.
 *              저장된 사주 데이터(v1.0/v2.0)를 활용하여 일일/주간/월간 스토리를 만듭니다.
 *
 * @endpoint POST /generate-fortune-story
 *
 * @requestBody
 * - userId: string - 사용자 ID (필수)
 * - storyType?: string - 스토리 유형 ('daily', 'weekly', 'monthly')
 * - theme?: string - 테마 ('career', 'love', 'health', 'wealth')
 * - includeAdvice?: boolean - 조언 포함 여부
 *
 * @response FortuneStoryResponse
 * - story: object - 생성된 스토리
 *   - title: string - 스토리 제목
 *   - content: string - 스토리 내용
 *   - highlights: string[] - 주요 포인트
 *   - advice: string - 조언 (옵션)
 * - sajuContext: object - 사주 컨텍스트 정보
 *   - dayMaster: string - 일간
 *   - elements: object - 오행 분포
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "storyType": "daily",
 *   "theme": "career",
 *   "includeAdvice": true
 * }
 *
 * // Response
 * {
 *   "success": true,
 *   "data": {
 *     "story": {
 *       "title": "오늘의 커리어 운세",
 *       "content": "오늘은 새로운 기회가...",
 *       "highlights": ["회의에서 좋은 아이디어", "상사의 인정"]
 *     }
 *   }
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 저장된 사주 데이터 조회 함수 (v1.0/v2.0 스키마 모두 지원)
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

    const version = sajuData.calculation_version || 'v1.0'
    console.log('✅ Saju data found, version:', version)

    // 기존 스키마 컬럼명 사용 (year_stem, year_branch, etc.)
    // v2.0에서도 같은 컬럼명 사용하도록 통일
    const dayCheongan = sajuData.day_stem
    const dayJiji = sajuData.day_branch
    const yearCheongan = sajuData.year_stem
    const yearJiji = sajuData.year_branch
    const monthCheongan = sajuData.month_stem
    const monthJiji = sajuData.month_branch
    const hourCheongan = sajuData.hour_stem
    const hourJiji = sajuData.hour_branch

    // element_balance에서 오행 추출 (기존 스키마)
    const elementBalance = sajuData.element_balance || {}
    const 목 = sajuData.element_wood ?? elementBalance?.목 ?? elementBalance?.['목'] ?? 0
    const 화 = sajuData.element_fire ?? elementBalance?.화 ?? elementBalance?.['화'] ?? 0
    const 토 = sajuData.element_earth ?? elementBalance?.토 ?? elementBalance?.['토'] ?? 0
    const 금 = sajuData.element_metal ?? elementBalance?.금 ?? elementBalance?.['금'] ?? 0
    const 수 = sajuData.element_water ?? elementBalance?.수 ?? elementBalance?.['수'] ?? 0

    // 부족/강한 오행 (신규 컬럼 또는 기존 컬럼에서)
    const weakElement = sajuData.weak_element || sajuData.lacking_element
    const strongElement = sajuData.strong_element || sajuData.dominant_element

    // ten_gods에서 십신 추출 (기존 스키마)
    const tenGods = sajuData.ten_gods || {}
    const 십신 = {
      년주: sajuData.tenshin_year || (tenGods.year ? { cheongan: tenGods.year[0] } : null),
      월주: sajuData.tenshin_month || (tenGods.month ? { cheongan: tenGods.month[0] } : null),
      일주: sajuData.tenshin_day || null,
      시주: sajuData.tenshin_hour || (tenGods.hour ? { cheongan: tenGods.hour[0] } : null)
    }

    // spirits에서 신살 추출 (기존 스키마)
    const spirits = sajuData.spirits || []
    const 길신 = sajuData.sinsal_gilsin || spirits.filter((s: string) => !s.includes('살'))
    const 흉신 = sajuData.sinsal_hyungsin || spirits.filter((s: string) => s.includes('살'))

    return {
      // 기본 정보
      천간: dayCheongan,
      지지: dayJiji,
      일간: dayCheongan,

      // 오행 균형
      오행: { 목, 화, 토, 금, 수 },

      // 사주팔자
      간지: `${dayCheongan}${dayJiji}`,
      부족한오행: weakElement,
      강한오행: strongElement,
      보충방법: sajuData.enhancement_method,

      // 상세 사주 (4주8자)
      상세사주: {
        년주: { 천간: yearCheongan, 지지: yearJiji, 한자: `${sajuData.year_stem_hanja || ''}${sajuData.year_branch_hanja || ''}` },
        월주: { 천간: monthCheongan, 지지: monthJiji, 한자: `${sajuData.month_stem_hanja || ''}${sajuData.month_branch_hanja || ''}` },
        일주: { 천간: dayCheongan, 지지: dayJiji, 한자: `${sajuData.day_stem_hanja || ''}${sajuData.day_branch_hanja || ''}` },
        시주: hourCheongan ? { 천간: hourCheongan, 지지: hourJiji, 한자: `${sajuData.hour_stem_hanja || ''}${sajuData.hour_branch_hanja || ''}` } : null
      },

      // 십신
      십신,

      // 지장간 (v2.0)
      지장간: {
        년주: sajuData.jijanggan_year,
        월주: sajuData.jijanggan_month,
        일주: sajuData.jijanggan_day,
        시주: sajuData.jijanggan_hour
      },

      // 12운성 (v2.0)
      운성: sajuData.twelve_stages,

      // 합충형파해 (v2.0)
      관계: sajuData.relations,

      // 신살
      길신,
      흉신,

      // 공망 (v2.0)
      공망: sajuData.gongmang,

      // 대운 정보 (기존)
      대운: sajuData.daeun_info || sajuData.current_daewoon,

      // LLM 분석 (v2.0 우선, 기존 fallback)
      성격: sajuData.personality_traits || sajuData.personality_analysis,
      운세요약: sajuData.fortune_summary || sajuData.interpretation,
      직업운: sajuData.career_fortune || sajuData.career_guidance,
      재물운: sajuData.wealth_fortune,
      애정운: sajuData.love_fortune || sajuData.relationship_advice,
      건강운: sajuData.health_fortune,
      전체분석: sajuData.gpt_analysis,

      // 버전 정보
      version
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
      storyConfig,
      userLocation  // ✅ LocationManager에서 전달받은 실제 사용자 위치
    } = body

    console.log('📍 [Story] 사용자 위치:', userLocation || weather?.cityName || '미제공')

    // OpenAI API 키 확인
    const openAIApiKey = Deno.env.get('OPENAI_API_KEY')
    console.log('🔑 OpenAI API key configured:', !!openAIApiKey)

    if (!openAIApiKey) {
      console.error('❌ OpenAI API key not configured')
      throw new Error('OpenAI API key not configured')
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
    console.log('🔮 Fetching saved Saju data for user:', userName, 'userId:', user.id)
    const sajuAnalysis = await getSavedSajuData(supabase, user.id);
    if (sajuAnalysis) {
      console.log('✅ Saju analysis found:')
      console.log('  - 천간:', sajuAnalysis.천간)
      console.log('  - 지지:', sajuAnalysis.지지)
      console.log('  - 간지:', sajuAnalysis.간지)
      console.log('  - 오행:', JSON.stringify(sajuAnalysis.오행))
      console.log('  - 부족한 오행:', sajuAnalysis.부족한오행)
    } else {
      console.log('⚠️ No Saju data found for user - will generate basic fortune')
    }
    
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
    "city": "${userLocation || weather?.cityName || '위치 정보 없음'}"
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
      "advice": "새로운 만남에 열린 마음을 가지세요. 상대방의 감정을 존중하며 진심을 담은 대화를 나누면 좋은 결과가 있을 것입니다. 솔로라면 주변 사람들과의 소소한 만남을 소중히 여기고, 연인이 있다면 감사한 마음을 표현하는 것이 관계를 더욱 깊게 만들어줄 것입니다. 때로는 작은 배려와 관심이 큰 감동을 선물합니다. 상대방의 입장에서 생각하고 이해하려는 노력이 사랑을 키우는 비결입니다.",
      "do": ["감사 표현", "진심 어린 대화"],
      "dont": ["답장 지연", "직설적 표현"],
      "lucky_time": "19:00-21:00"
    },
    "money": {
      "score": 66,
      "short": "지출 관리가 핵심",
      "advice": "계획적인 소비가 도움이 될 것입니다. 충동구매를 자제하고 장기적인 재테크 계획을 세워보세요. 특히 오늘은 불필요한 지출을 줄이고 미래를 위한 저축에 집중하는 것이 좋습니다. 작은 돈도 아끼는 습관이 큰 재산을 만드는 첫걸음입니다. 투자를 고민 중이라면 충분한 정보 수집과 전문가 상담 후 신중하게 결정하세요. 단기적인 이익보다는 장기적인 안정성을 우선시하는 것이 현명합니다.",
      "do": ["예산 점검", "저축 계획"],
      "dont": ["충동구매", "고액 지출"]
    },
    "work": {
      "score": 82,
      "short": "꾸준함이 성과로",
      "advice": "꾸준한 노력이 성과로 이어질 것입니다. 동료들과의 협력을 통해 더 큰 성과를 만들어보세요. 오늘은 팀워크가 특히 중요한 날입니다. 혼자 모든 것을 해내려 하기보다는 동료들의 강점을 활용하고 서로의 부족한 부분을 채워주는 것이 성공의 열쇠입니다. 새로운 아이디어가 있다면 주저하지 말고 제안해보세요. 상사나 동료들이 당신의 열정과 창의성을 높이 평가할 것입니다.",
      "do": ["우선순위 확정", "팀워크 강화"],
      "dont": ["일정 낙관", "독단적 결정"]
    },
    "health": {
      "score": 70,
      "short": "소화기 주의",
      "advice": "규칙적인 생활습관을 유지하세요. 충분한 수면과 적절한 운동으로 건강을 지킬 수 있습니다. 오늘은 특히 수면의 질에 신경 쓰는 것이 좋습니다. 잠들기 전 스마트폰 사용을 줄이고 편안한 환경을 만들어보세요. 가벼운 스트레칭이나 산책으로 몸을 움직이면 혈액순환이 좋아지고 기분도 한결 상쾌해질 것입니다. 물을 충분히 마시고 건강한 식사를 하는 것도 잊지 마세요.",
      "do": ["스트레칭", "충분한 수면"],
      "dont": ["야식", "과도한 음주"]
    },
    "social": {
      "score": 76,
      "short": "관계 회복의 운",
      "advice": "주변 사람들과의 관계가 더욱 돈독해지는 날입니다. 사소한 안부 인사가 큰 감동을 줄 수 있습니다. 오랜만에 연락하지 못했던 지인에게 먼저 연락해보는 것도 좋습니다. 진심 어린 한마디가 관계를 회복하고 더욱 깊게 만들어줄 것입니다. 듣는 것에 집중하고 상대방의 이야기에 공감하며 반응해주세요. 작은 배려와 관심이 인간관계를 풍요롭게 만듭니다."
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
  ⚠️ 중요: advice는 반드시 상세하고 구체적인 단락 형태로 작성하세요 (최소 200자 이상, 3-5문장).
  예시처럼 짧은 한 문장이 아니라, 구체적인 상황과 실천 방법을 포함한 긴 조언을 제공하세요.
  절대로 "직설보단 부드럽게", "큰 지출은 미루기" 같은 짧은 조언을 작성하지 마세요!
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

    // ✅ 현재 날짜 명확히 추출
    const now = new Date(date || new Date()) // date 파라미터 우선 사용
    const currentDate = now.toISOString().split('T')[0] // YYYY-MM-DD
    const currentYear = now.getFullYear()
    const currentMonth = now.getMonth() + 1
    const currentDay = now.getDate()
    const weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일']
    const currentWeekday = weekdays[now.getDay()]

    const userPrompt = `⚠️ 절대 중요: 오늘 날짜는 ${currentYear}년 ${currentMonth}월 ${currentDay}일 ${currentWeekday}입니다. 이 날짜를 반드시 사용하세요!

사용자 정보:
- 이름: ${userName} (절대적으로 중요: 이 이름 "${userName}"을 반드시 사용하세요. 절대로 "사용자님"이라고 하지 마세요. 반드시 "${userName}님"으로 호칭하세요)
${userProfile ? `- 생년월일: ${userProfile.birthDate}
- 생시: ${userProfile.birthTime || '모름'}
- 성별: ${userProfile.gender || '비공개'}
- 음력 여부: ${userProfile.isLunar ? '음력' : '양력'}
- 띠: ${userProfile.zodiacAnimal || ''}
- 별자리: ${userProfile.zodiacSign || ''}
- MBTI: ${userProfile.mbti || ''}
- 혈액형: ${userProfile.bloodType || ''}` : ''}

날짜 정보 (절대 중요!):
- 오늘 날짜: ${currentYear}년 ${currentMonth}월 ${currentDay}일 ${currentWeekday}
- ISO 형식: ${currentDate}
- ⚠️ 이 날짜가 아닌 다른 날짜를 사용하지 마세요!

날씨 정보:
- 상태: ${weather.description}
- 온도: ${weather.temperature}°C
- 지역: ${userLocation || weather.cityName} (이 지역명이 영어인 경우 한글로 변환하고, 상세 주소는 광역시/도 단위로 간소화하세요. 예: "Seoul" → "서울", "Suwon-si" → "경기도", "Gangnam-gu" → "서울")

운세 정보:
- 점수: ${fortune.score}/100
- 요약: ${fortune.summary || ''}
- 행운의 색: ${fortune.luckyColor || ''}
- 행운의 숫자: ${fortune.luckyNumber || ''}
- 행운의 시간: ${fortune.luckyTime || ''}
- 조언: ${fortune.advice || ''}
사주 분석:
${sajuAnalysis ? `📊 사주팔자 (v${sajuAnalysis.version || '2.0'}):
- 일간(나): ${sajuAnalysis.일간 || sajuAnalysis.천간} (${sajuAnalysis.강한오행 || ''}의 기운)
- 년주: ${sajuAnalysis.상세사주?.년주?.천간}${sajuAnalysis.상세사주?.년주?.지지}
- 월주: ${sajuAnalysis.상세사주?.월주?.천간}${sajuAnalysis.상세사주?.월주?.지지}
- 일주: ${sajuAnalysis.상세사주?.일주?.천간}${sajuAnalysis.상세사주?.일주?.지지}
- 시주: ${sajuAnalysis.상세사주?.시주 ? `${sajuAnalysis.상세사주.시주.천간}${sajuAnalysis.상세사주.시주.지지}` : '미상'}

🔥 오행 균형:
- 목: ${sajuAnalysis.오행?.목?.toFixed?.(1) || sajuAnalysis.오행?.목 || 0}
- 화: ${sajuAnalysis.오행?.화?.toFixed?.(1) || sajuAnalysis.오행?.화 || 0}
- 토: ${sajuAnalysis.오행?.토?.toFixed?.(1) || sajuAnalysis.오행?.토 || 0}
- 금: ${sajuAnalysis.오행?.금?.toFixed?.(1) || sajuAnalysis.오행?.금 || 0}
- 수: ${sajuAnalysis.오행?.수?.toFixed?.(1) || sajuAnalysis.오행?.수 || 0}
- 부족한 오행: ${sajuAnalysis.부족한오행} → 보충: ${sajuAnalysis.보충방법}

⭐ 십신 분석:
- 년주 십신: ${JSON.stringify(sajuAnalysis.십신?.년주 || {})}
- 월주 십신: ${JSON.stringify(sajuAnalysis.십신?.월주 || {})}
- 일지 십신: ${JSON.stringify(sajuAnalysis.십신?.일주 || {})}

🔄 12운성: ${JSON.stringify(sajuAnalysis.운성 || {})}

🎯 신살:
- 길신: ${sajuAnalysis.길신?.join(', ') || '없음'}
- 흉신: ${sajuAnalysis.흉신?.join(', ') || '없음'}

⚡ 공망: ${sajuAnalysis.공망?.join(', ') || '없음'}

💡 성격 분석: ${sajuAnalysis.성격 || '분석 대기'}
📝 운세 요약: ${sajuAnalysis.운세요약 || '분석 대기'}` : `⚠️ 사주 데이터 없음 - 기본 정보로 운세 생성

✅ 반드시 사용자 정보를 기반으로 구체적인 운세를 작성하세요:
${userProfile?.zodiacAnimal ? `- 띠: ${userProfile.zodiacAnimal}띠` : '- 띠: 용띠 (기본값)'}
${userProfile?.zodiacSign ? `- 별자리: ${userProfile.zodiacSign}` : '- 별자리: 처녀자리 (기본값)'}
${userProfile?.birthDate ? `- 생년월일: ${userProfile.birthDate}` : ''}

🚫 절대 사용 금지 표현: "분석 중", "알 수 없음", "확인 중", "정보가 없습니다"
✅ 반드시 긍정적이고 구체적인 내용으로 작성하세요!`}

10페이지 분량의 운세 스토리를 만들어주세요.
반드시 segments 키 안에 10개의 페이지 배열을 포함하세요.
그리고 sajuAnalysis 객체도 함께 반함하세요.`

    console.log('🤖 Calling LLM API...')
    console.log('📤 System prompt length:', systemPrompt.length)
    console.log('📤 User prompt length:', userPrompt.length)
    console.log('📤 User prompt:', userPrompt) // 전체 프롬프트 확인

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('fortune-story')

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 0.7, // ✅ 1에서 0.7로 낮춤 (더 일관된 응답)
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)
    console.log(`📝 Token 사용량: prompt=${response.usage.promptTokens}, completion=${response.usage.completionTokens}, total=${response.usage.totalTokens}`)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'fortune-story',
      userId: user.id,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { userName, userLocation, hasSajuAnalysis: !!sajuAnalysis }
    })

    if (!response.content) {
      console.error('❌ LLM API returned empty content')
      throw new Error('LLM API 응답 없음')
    }

    console.log('📥 Raw LLM response:', response.content.substring(0, 500)) // 처음 500자 확인

    let storyContent
    try {
      storyContent = JSON.parse(response.content)
      console.log('✅ JSON parsing successful')
      console.log('📦 Story content type:', typeof storyContent)
      console.log('📦 Story content keys:', Object.keys(storyContent))

      // ✅ 핵심 필드 존재 여부 로깅
      console.log('🔍 Field validation:')
      console.log('  - segments:', Array.isArray(storyContent.segments) ? `${storyContent.segments.length}개` : '없음')
      console.log('  - meta:', storyContent.meta ? '있음' : '없음')
      console.log('  - overall:', storyContent.overall ? '있음' : '없음')
      console.log('  - categories:', storyContent.categories ? '있음' : '없음')
      console.log('  - sajuInsight:', storyContent.sajuInsight ? '있음' : '없음')
    } catch (parseError) {
      console.error('❌ JSON parsing failed:', parseError)
      console.error('📥 Failed content:', response.content)
      throw new Error('LLM 응답 JSON 파싱 실패')
    }

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
      // GPT 응답에 segments가 없으면 에러
      console.error('❌ No segments in GPT response')
      throw new Error('GPT response missing segments')
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

  } catch (error: unknown) {
    const err = error as Error
    console.error('❌ Error generating story:', err.message)
    console.error('Stack trace:', err.stack)

    // 에러 시 500 에러 반환 (클라이언트에서 처리)
    return new Response(
      JSON.stringify({
        error: err.message || 'Story generation failed',
        segments: null
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})