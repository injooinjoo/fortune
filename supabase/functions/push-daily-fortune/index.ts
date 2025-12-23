/**
 * Push Daily Fortune Edge Function
 *
 * @description 일일 운세 푸시 알림을 발송합니다. Cron으로 15분 간격 실행 (6-9시)
 *
 * @endpoint POST /push-daily-fortune
 * @cron */15 6-9 * * * (매일 6-9시, 15분 간격)
 *
 * @flow
 * 1. 현재 시간에 알림 받을 사용자 조회
 * 2. 오늘의 운세 점수 사전 계산 (캐시에서 또는 생성)
 * 3. 개인화된 메시지 생성
 * 4. FCM 푸시 발송
 * 5. 발송 로그 기록
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 띠별 이모지 매핑
const zodiacEmojis: Record<string, string> = {
  '쥐': '',
  '소': '',
  '호랑이': '',
  '토끼': '',
  '용': '',
  '뱀': '',
  '말': '',
  '양': '',
  '원숭이': '',
  '닭': '',
  '개': '',
  '돼지': '',
}

interface NotificationMessage {
  title: string
  body: string
  payload: Record<string, string>
}

interface EligibleUser {
  user_id: string
  fcm_token: string
  platform: string
  preferred_hour: number
  timezone: string
  name?: string
  zodiac_animal?: string
  consecutive_days?: number
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 현재 시간 (KST 기준)
    const now = new Date()
    const kstHour = (now.getUTCHours() + 9) % 24

    console.log(`[push-daily-fortune] Starting at KST hour: ${kstHour}`)

    // 1. 알림 받을 사용자 조회
    const eligibleUsers = await getEligibleUsers(supabase, kstHour)
    console.log(`[push-daily-fortune] Eligible users: ${eligibleUsers.length}`)

    if (eligibleUsers.length === 0) {
      return new Response(
        JSON.stringify({ success: true, sent: 0, message: 'No eligible users' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. 오늘 운세 점수 조회 (캐시 활용)
    const fortuneScores = await getFortuneScores(supabase, eligibleUsers.map(u => u.user_id))

    // 3. 개인화된 메시지 생성 및 발송
    const results = await Promise.allSettled(
      eligibleUsers.map(async (user) => {
        const score = fortuneScores[user.user_id]
        const message = generateMessage(user, score)

        // 알림 로그 저장
        const logResult = await supabase
          .from('notification_logs')
          .insert({
            user_id: user.user_id,
            notification_type: 'daily_fortune',
            channel: 'daily_fortune',
            title: message.title,
            body: message.body,
            payload: message.payload,
            fortune_score: score?.overall_score,
          })
          .select('id')
          .single()

        const notificationId = logResult.data?.id

        // FCM 발송
        if (fcmServerKey) {
          await sendFCMNotification(
            fcmServerKey,
            user.fcm_token,
            message,
            notificationId
          )
        }

        return { user_id: user.user_id, success: true }
      })
    )

    const sent = results.filter(r => r.status === 'fulfilled').length
    const failed = results.filter(r => r.status === 'rejected').length

    console.log(`[push-daily-fortune] Sent: ${sent}, Failed: ${failed}`)

    return new Response(
      JSON.stringify({
        success: true,
        sent,
        failed,
        timestamp: new Date().toISOString(),
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('[push-daily-fortune] Error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

/**
 * 알림 받을 사용자 조회
 */
async function getEligibleUsers(supabase: any, currentHour: number): Promise<EligibleUser[]> {
  // 오늘 이미 발송된 사용자 제외
  const today = new Date().toISOString().split('T')[0]

  const { data, error } = await supabase
    .from('user_notification_preferences')
    .select(`
      user_id,
      preferred_hour,
      optimal_send_hour,
      timezone,
      user_profiles!inner(
        name,
        chinese_zodiac
      ),
      user_statistics(
        consecutive_days
      ),
      fcm_tokens!inner(
        token,
        platform
      )
    `)
    .eq('enabled', true)
    .eq('daily_fortune', true)
    .eq('fcm_tokens.is_active', true)

  if (error) {
    console.error('[getEligibleUsers] Error:', error)
    return []
  }

  // 현재 시간에 해당하는 사용자 필터링
  const eligibleUsers = data?.filter((user: any) => {
    const userHour = user.preferred_hour ?? user.optimal_send_hour ?? 7
    return userHour === currentHour
  }) || []

  // 오늘 이미 발송된 사용자 제외
  const { data: sentToday } = await supabase
    .from('notification_logs')
    .select('user_id')
    .eq('notification_type', 'daily_fortune')
    .gte('sent_at', today)

  const sentUserIds = new Set(sentToday?.map((s: any) => s.user_id) || [])

  return eligibleUsers
    .filter((user: any) => !sentUserIds.has(user.user_id))
    .map((user: any) => ({
      user_id: user.user_id,
      fcm_token: user.fcm_tokens?.[0]?.token,
      platform: user.fcm_tokens?.[0]?.platform,
      preferred_hour: user.preferred_hour ?? user.optimal_send_hour ?? 7,
      timezone: user.timezone || 'Asia/Seoul',
      name: user.user_profiles?.name,
      zodiac_animal: user.user_profiles?.chinese_zodiac,
      consecutive_days: user.user_statistics?.consecutive_days || 0,
    }))
    .filter((user: EligibleUser) => user.fcm_token)
}

/**
 * 오늘 운세 점수 조회 (캐시 우선)
 */
async function getFortuneScores(
  supabase: any,
  userIds: string[]
): Promise<Record<string, { overall_score: number; top_category?: string }>> {
  const today = new Date().toISOString().split('T')[0]
  const scores: Record<string, { overall_score: number; top_category?: string }> = {}

  // 캐시에서 조회
  const { data: cached } = await supabase
    .from('fortune_cache')
    .select('user_id, overall_score, categories')
    .in('user_id', userIds)
    .eq('fortune_type', 'daily')
    .gte('created_at', today)

  cached?.forEach((cache: any) => {
    const categories = cache.categories || {}
    const topCategory = Object.entries(categories)
      .sort(([, a]: any, [, b]: any) => (b?.score || 0) - (a?.score || 0))[0]

    scores[cache.user_id] = {
      overall_score: cache.overall_score || 75,
      top_category: topCategory?.[0],
    }
  })

  return scores
}

/**
 * 개인화된 메시지 생성
 */
function generateMessage(
  user: EligibleUser,
  score?: { overall_score: number; top_category?: string }
): NotificationMessage {
  const zodiacEmoji = user.zodiac_animal
    ? zodiacEmojis[user.zodiac_animal] || ''
    : ''

  // 고득점 (85+)
  if (score && score.overall_score >= 85) {
    return {
      title: `${zodiacEmoji} 오늘 운세 ${score.overall_score}점!`,
      body: '대길한 하루가 예상됩니다. 지금 확인하세요!',
      payload: {
        type: 'daily_fortune',
        route: '/home',
        score: String(score.overall_score),
      },
    }
  }

  // 연속 접속 7일 이상
  if (user.consecutive_days && user.consecutive_days >= 7) {
    return {
      title: `${zodiacEmoji} ${user.consecutive_days}일 연속 접속 중!`,
      body: '오늘의 운세를 확인하고 연속 기록을 유지하세요',
      payload: {
        type: 'daily_fortune',
        route: '/home',
        streak: String(user.consecutive_days),
      },
    }
  }

  // 점수가 있는 경우
  if (score) {
    const categoryText = score.top_category
      ? getCategoryName(score.top_category)
      : ''

    return {
      title: `${zodiacEmoji} 오늘의 운세가 도착했어요`,
      body: categoryText
        ? `${categoryText} 운이 좋은 하루! 자세히 확인해보세요`
        : '어떤 행운이 기다리고 있을까요?',
      payload: {
        type: 'daily_fortune',
        route: '/home',
        score: String(score.overall_score),
      },
    }
  }

  // 기본 메시지
  return {
    title: `${zodiacEmoji} 오늘의 운세가 도착했어요`,
    body: '어떤 행운이 기다리고 있을까요?',
    payload: {
      type: 'daily_fortune',
      route: '/home',
    },
  }
}

/**
 * 카테고리 한글 이름
 */
function getCategoryName(category: string): string {
  const names: Record<string, string> = {
    love: '연애',
    money: '재물',
    work: '직장',
    study: '학업',
    health: '건강',
  }
  return names[category] || ''
}

/**
 * FCM 푸시 발송
 */
async function sendFCMNotification(
  serverKey: string,
  token: string,
  message: NotificationMessage,
  notificationId?: string
): Promise<void> {
  const payload = {
    to: token,
    notification: {
      title: message.title,
      body: message.body,
      sound: 'default',
      badge: 1,
    },
    data: {
      ...message.payload,
      notification_id: notificationId,
      channel: 'daily_fortune',
    },
    android: {
      priority: 'high',
      notification: {
        channel_id: 'daily_fortune',
        sound: 'default',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  }

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `key=${serverKey}`,
    },
    body: JSON.stringify(payload),
  })

  if (!response.ok) {
    const errorText = await response.text()
    throw new Error(`FCM Error: ${response.status} - ${errorText}`)
  }

  const result = await response.json()

  if (result.failure > 0) {
    console.warn('[sendFCMNotification] Partial failure:', result.results)
  }
}
