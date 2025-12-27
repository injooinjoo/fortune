/**
 * 관상 운세 Watch 경량 API
 *
 * @description Apple Watch용 경량 관상 데이터를 제공합니다.
 * 최신 관상 분석 결과에서 Watch 데이터를 추출하거나,
 * 없을 경우 사용자 생년월일 기반 간단한 데이터를 생성합니다.
 *
 * @endpoint POST /fortune-face-reading-watch
 *
 * @requestBody
 * - userId: string - 사용자 ID (필수)
 *
 * @response WatchFaceReadingData (경량)
 * - luckyDirection: 행운 방향
 * - luckyColor: 행운 색상
 * - luckyTimePeriods: 행운 시간대
 * - dailyReminderMessage: 리마인더 메시지
 * - conditionScore: 컨디션 점수
 * - smileScore: 미소 점수
 * - briefFortune: 간단한 운세 메시지
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 방향 목록
const DIRECTIONS = ['동', '서', '남', '북', '동북', '동남', '서북', '서남']

// 색상 목록 (이름, HEX)
const COLORS = [
  { name: '빨강', hex: '#FF6B6B' },
  { name: '주황', hex: '#FFA94D' },
  { name: '노랑', hex: '#FFE066' },
  { name: '초록', hex: '#69DB7C' },
  { name: '파랑', hex: '#4DABF7' },
  { name: '남색', hex: '#5C7CFA' },
  { name: '보라', hex: '#CC5DE8' },
  { name: '분홍', hex: '#F783AC' },
  { name: '흰색', hex: '#F8F9FA' },
  { name: '검정', hex: '#343A40' },
]

// 시간대 목록
const TIME_PERIODS = [
  '오전 6-8시',
  '오전 9-11시',
  '낮 12-2시',
  '오후 3-5시',
  '오후 6-8시',
  '저녁 9-11시',
]

// 응원 메시지 목록 (2-30대 여성 타겟, 친근한 말투)
const REMINDER_MESSAGES = [
  '오늘도 당신은 충분히 잘하고 있어요 ✨',
  '잠깐 숨 고르기! 1분만 쉬어도 괜찮아요 🧘',
  '오늘의 미소가 행운을 불러올 거예요 😊',
  '지금 이 순간, 당신은 빛나고 있어요 💫',
  '조금 지쳐도 괜찮아요. 오늘 하루도 수고했어요 💝',
  '따뜻한 차 한 잔 어때요? ☕',
  '오늘 하루도 당신답게! 응원해요 🌸',
  '잘하고 있어요. 조금만 더 힘내봐요 💪',
  '지금 표정이 제일 예뻐요 😌',
  '좋은 일이 생길 거예요. 기대해도 좋아요! 🍀',
]

// 간단한 운세 메시지 목록
const BRIEF_FORTUNES = [
  '좋은 사람과의 만남이 예상되는 하루예요',
  '마음이 편안해지는 소식이 올 거예요',
  '작은 기쁨이 찾아오는 날이에요',
  '노력이 빛을 발하는 시간이 다가와요',
  '감사한 마음이 행운을 불러올 거예요',
  '차분하게 하루를 시작하면 좋은 일이 생겨요',
  '오늘은 새로운 시작에 좋은 날이에요',
  '긍정적인 에너지가 넘치는 하루예요',
  '소중한 인연이 더 깊어지는 날이에요',
  '당신의 매력이 빛나는 날이에요',
]

/**
 * 오늘 날짜 기반 랜덤 시드 생성
 */
function getDailyRandomSeed(userId: string): number {
  const today = new Date().toISOString().split('T')[0]
  const seed = `${userId}-${today}`
  let hash = 0
  for (let i = 0; i < seed.length; i++) {
    const char = seed.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash
  }
  return Math.abs(hash)
}

/**
 * 시드 기반 랜덤 선택
 */
function seededRandom<T>(array: T[], seed: number, offset: number = 0): T {
  const index = (seed + offset) % array.length
  return array[index]
}

/**
 * 기본 Watch 데이터 생성 (캐시된 데이터가 없을 때)
 */
function generateDefaultWatchData(userId: string): {
  luckyDirection: string
  luckyColor: { colorName: string; colorCode: string }
  luckyTimePeriods: string[]
  dailyReminderMessage: string
  conditionScore: number
  smileScore: number
  briefFortune: string
} {
  const seed = getDailyRandomSeed(userId)

  const direction = seededRandom(DIRECTIONS, seed, 0)
  const color = seededRandom(COLORS, seed, 1)

  // 2개의 행운 시간대 선택
  const timePeriod1 = seededRandom(TIME_PERIODS, seed, 2)
  let timePeriod2 = seededRandom(TIME_PERIODS, seed, 3)
  if (timePeriod1 === timePeriod2) {
    timePeriod2 = TIME_PERIODS[(TIME_PERIODS.indexOf(timePeriod1) + 1) % TIME_PERIODS.length]
  }

  const reminder = seededRandom(REMINDER_MESSAGES, seed, 4)
  const briefFortune = seededRandom(BRIEF_FORTUNES, seed, 5)

  // 점수는 70-90 범위로 랜덤 생성 (하루 고정)
  const conditionScore = 70 + (seed % 21)
  const smileScore = 70 + ((seed + 7) % 21)

  return {
    luckyDirection: direction,
    luckyColor: {
      colorName: color.name,
      colorCode: color.hex,
    },
    luckyTimePeriods: [timePeriod1, timePeriod2],
    dailyReminderMessage: reminder,
    conditionScore,
    smileScore,
    briefFortune,
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { userId } = await req.json()

    if (!userId) {
      return new Response(
        JSON.stringify({ error: 'userId is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Supabase 클라이언트 초기화
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // =====================================================
    // 1. 오늘의 관상 분석 결과에서 Watch 데이터 조회
    // =====================================================
    const today = new Date().toISOString().split('T')[0]

    const { data: recentFortune, error: fortuneError } = await supabase
      .from('fortunes')
      .select('result')
      .eq('user_id', userId)
      .eq('type', 'face-reading')
      .gte('created_at', `${today}T00:00:00Z`)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    let watchData

    if (recentFortune?.result?.details?.watchData) {
      // ✅ 오늘 분석한 데이터가 있음 - Watch 데이터 추출
      console.log('📱 [Watch] Found today\'s face reading data')
      const cachedWatchData = recentFortune.result.details.watchData

      watchData = {
        luckyDirection: cachedWatchData.luckyDirection || '동',
        luckyColor: {
          colorName: cachedWatchData.luckyColor || '파랑',
          colorCode: cachedWatchData.luckyColorHex || '#4DABF7',
        },
        luckyTimePeriods: cachedWatchData.luckyTimePeriods || ['오전 9-11시'],
        dailyReminderMessage: cachedWatchData.dailyReminderMessage || '오늘도 화이팅!',
        conditionScore: recentFortune.result.details.faceCondition?.overallConditionScore || 75,
        smileScore: recentFortune.result.details.emotionAnalysis?.smilePercentage || 75,
        briefFortune: recentFortune.result.mainFortune || '좋은 하루 되세요!',
      }
    } else {
      // ⚠️ 오늘 분석 데이터 없음 - 기본 데이터 생성
      console.log('📱 [Watch] No today\'s data, generating default')
      watchData = generateDefaultWatchData(userId)
    }

    // =====================================================
    // 2. 응답 반환
    // =====================================================
    const response = {
      success: true,
      data: {
        // ✅ 표준화된 필드명: score, content, summary, advice
        fortuneType: 'face-reading-watch',
        score: watchData.conditionScore,
        content: watchData.briefFortune,
        summary: `오늘의 컨디션 ${watchData.conditionScore}점`,
        advice: watchData.dailyReminderMessage,

        // 기존 필드 유지 (하위 호환성)
        ...watchData
      },
      source: recentFortune ? 'cached' : 'generated',
      cached: !!recentFortune,
      timestamp: new Date().toISOString(),
    }

    console.log(`✅ [Watch] Response: ${response.source}`)

    return new Response(
      JSON.stringify(response),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )

  } catch (error) {
    console.error('❌ [Watch] Error:', error)

    return new Response(
      JSON.stringify({
        error: error.message || 'Failed to get watch data',
        details: error.toString()
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
