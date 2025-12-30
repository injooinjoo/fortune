/**
 * Push Winback Edge Function
 *
 * @description 휴면 사용자 재활성화 푸시 알림을 발송합니다.
 *
 * @endpoint POST /push-winback
 * @cron 0 10 * * * (매일 오전 10시)
 *
 * @segments
 * - 3일 미접속: 가벼운 리마인더
 * - 7일 미접속: 인센티브 제안
 * - 14일 미접속: 특별 혜택 제안
 * - 30일 미접속: 마지막 시도 + 강한 인센티브
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 휴면 세그먼트 정의
const DORMANT_SEGMENTS = [
  { days: 3, type: 'dormant_3d', maxPerWeek: 1 },
  { days: 7, type: 'dormant_7d', maxPerWeek: 1 },
  { days: 14, type: 'dormant_14d', maxPerWeek: 1 },
  { days: 30, type: 'dormant_30d', maxPerWeek: 1 },
]

interface DormantUser {
  user_id: string
  fcm_token: string
  platform: string
  name?: string
  zodiac_animal?: string
  last_login: string
  days_inactive: number
  favorite_fortune_type?: string
}

interface NotificationMessage {
  title: string
  body: string
  payload: Record<string, string>
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

    console.log('[push-winback] Starting winback campaign')

    const results = {
      total_sent: 0,
      total_failed: 0,
      by_segment: {} as Record<string, { sent: number; failed: number }>,
    }

    // 각 휴면 세그먼트별 처리
    for (const segment of DORMANT_SEGMENTS) {
      console.log(`[push-winback] Processing segment: ${segment.type} (${segment.days} days)`)

      const dormantUsers = await getDormantUsers(supabase, segment.days, segment.type)
      console.log(`[push-winback] Found ${dormantUsers.length} users for ${segment.type}`)

      results.by_segment[segment.type] = { sent: 0, failed: 0 }

      for (const user of dormantUsers) {
        try {
          // 주간 빈도 제한 체크
          const canSend = await checkFrequencyLimit(supabase, user.user_id, 'winback', segment.maxPerWeek)
          if (!canSend) {
            continue
          }

          const message = generateWinbackMessage(user, segment.days)

          // 알림 로그 저장
          const { data: logData } = await supabase
            .from('notification_logs')
            .insert({
              user_id: user.user_id,
              notification_type: 'winback',
              channel: 'promotion',
              title: message.title,
              body: message.body,
              payload: {
                ...message.payload,
                segment: segment.type,
                days_inactive: user.days_inactive,
              },
            })
            .select('id')
            .single()

          // FCM 발송
          if (fcmServerKey) {
            await sendFCMNotification(
              fcmServerKey,
              user.fcm_token,
              message,
              logData?.id
            )
            results.by_segment[segment.type].sent++
            results.total_sent++
          }
        } catch (error) {
          console.error(`[push-winback] Failed for user ${user.user_id}:`, error)
          results.by_segment[segment.type].failed++
          results.total_failed++
        }
      }
    }

    console.log('[push-winback] Campaign complete:', results)

    return new Response(
      JSON.stringify({
        success: true,
        ...results,
        timestamp: new Date().toISOString(),
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('[push-winback] Error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

/**
 * 휴면 사용자 조회
 */
async function getDormantUsers(
  supabase: any,
  daysInactive: number,
  segmentType: string
): Promise<DormantUser[]> {
  const now = new Date()
  const targetDate = new Date(now)
  targetDate.setDate(targetDate.getDate() - daysInactive)
  const targetDateStr = targetDate.toISOString().split('T')[0]

  // 정확히 N일 전에 마지막 접속한 사용자 조회 (범위: 해당 날짜 전체)
  const startOfDay = `${targetDateStr}T00:00:00Z`
  const endOfDay = `${targetDateStr}T23:59:59Z`

  const { data, error } = await supabase
    .from('user_statistics')
    .select(`
      user_id,
      last_login,
      favorite_fortune_type,
      user_profiles!inner(
        name,
        chinese_zodiac
      ),
      user_notification_preferences!inner(
        enabled,
        promotion
      ),
      fcm_tokens!inner(
        token,
        platform
      )
    `)
    .gte('last_login', startOfDay)
    .lte('last_login', endOfDay)
    .eq('user_notification_preferences.enabled', true)
    .eq('user_notification_preferences.promotion', true)
    .eq('fcm_tokens.is_active', true)

  if (error) {
    console.error('[getDormantUsers] Error:', error)
    return []
  }

  return (data || []).map((user: any) => ({
    user_id: user.user_id,
    fcm_token: user.fcm_tokens?.[0]?.token,
    platform: user.fcm_tokens?.[0]?.platform,
    name: user.user_profiles?.name,
    zodiac_animal: user.user_profiles?.chinese_zodiac,
    last_login: user.last_login,
    days_inactive: daysInactive,
    favorite_fortune_type: user.favorite_fortune_type,
  })).filter((user: DormantUser) => user.fcm_token)
}

/**
 * 주간 빈도 제한 체크
 */
async function checkFrequencyLimit(
  supabase: any,
  userId: string,
  notificationType: string,
  maxPerWeek: number
): Promise<boolean> {
  const weekAgo = new Date()
  weekAgo.setDate(weekAgo.getDate() - 7)

  const { count } = await supabase
    .from('notification_logs')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('notification_type', notificationType)
    .gte('sent_at', weekAgo.toISOString())

  return (count || 0) < maxPerWeek
}

/**
 * 휴면 복귀 메시지 생성
 */
function generateWinbackMessage(user: DormantUser, daysInactive: number): NotificationMessage {
  const name = user.name ? `${user.name}님` : '회원님'

  switch (daysInactive) {
    case 3:
      // 3일: 가벼운 리마인더
      return {
        title: '오늘의 인사이트가 기다리고 있어요',
        body: `${name}, 최근 인사이트 점수가 많이 올랐어요! 확인해보세요`,
        payload: {
          type: 'winback',
          route: '/home',
          segment: 'dormant_3d',
        },
      }

    case 7:
      // 7일: 인센티브 제안
      return {
        title: '일주일간 인사이트를 놓치셨어요',
        body: '오늘 복귀하시면 보너스 영혼 3개를 드려요!',
        payload: {
          type: 'winback',
          route: '/home',
          segment: 'dormant_7d',
          bonus_souls: '3',
        },
      }

    case 14:
      // 14일: 특별 혜택
      return {
        title: `${name}, 보고 싶었어요`,
        body: '특별 복귀 이벤트! 지금 접속하면 프리미엄 인사이트 1회 무료',
        payload: {
          type: 'winback',
          route: '/home',
          segment: 'dormant_14d',
          free_premium: 'true',
        },
      }

    case 30:
      // 30일: 마지막 시도
      return {
        title: '한 달 동안 많은 일이 있었어요',
        body: `${name}의 인사이트가 크게 변했어요. 새로운 시작을 확인해보세요!`,
        payload: {
          type: 'winback',
          route: '/home',
          segment: 'dormant_30d',
        },
      }

    default:
      return {
        title: '오랜만이에요!',
        body: '오늘의 인사이트를 확인해보세요',
        payload: {
          type: 'winback',
          route: '/home',
          segment: `dormant_${daysInactive}d`,
        },
      }
  }
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
      channel: 'promotion',
    },
    android: {
      priority: 'high',
      notification: {
        channel_id: 'promotion',
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
}
