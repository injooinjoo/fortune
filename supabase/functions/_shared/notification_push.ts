import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FCM_ENDPOINT = 'https://fcm.googleapis.com/fcm/send'

export interface CharacterPushPayload {
  characterId: string
  characterName: string
  messageText: string
  messageId?: string
  conversationId?: string
  roomState?: string
  type?: 'character_dm' | 'character_follow_up'
  route?: string
}

export interface CharacterPushSendResult {
  userId: string
  characterId: string
  sentCount: number
  skipped: boolean
  reason?: string
}

export interface PushDeliveryParams {
  userId: string
  title: string
  body: string
  data: Record<string, string>
}

function getCharacterDmRoute(characterId: string): string {
  const encodedCharacterId = encodeURIComponent(characterId)
  return `/character/${encodedCharacterId}?openCharacterChat=true`
}

export function buildCharacterDmPayload(
  params: CharacterPushPayload,
): Record<string, string> {
  const route = params.route ?? getCharacterDmRoute(params.characterId)

  const payload: Record<string, string> = {
    type: params.type ?? 'character_dm',
    character_id: params.characterId,
    characterId: params.characterId,
    title: params.characterName,
    body: params.messageText,
    route,
  }

  if (params.messageId) {
    payload['message_id'] = params.messageId
  }

  if (params.conversationId) {
    payload['conversation_id'] = params.conversationId
  }

  if (params.roomState) {
    payload['room_state'] = params.roomState
  }

  return payload
}

async function hasCharacterNotificationEnabled(
  supabase: SupabaseClient,
  userId: string,
): Promise<boolean> {
  const { data, error } = await supabase
    .from('user_notification_preferences')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle()

  if (error) {
    console.error('[notification_push] user_notification_preferences 조회 실패:', error)
    return true
  }

  // 사용자 선호설정 없음은 기본 허용
  if (!data) {
    return true
  }

  const row = data as Record<string, unknown>
  const enabled = (row['enabled'] as boolean | undefined)

  if (enabled === false) {
    return false
  }

  if ('character_dm' in row) {
    const characterDm = row['character_dm'] as boolean | undefined
    if (characterDm === false) {
      return false
    }
  }

  return true
}

async function getActiveCharacterTokens(
  supabase: SupabaseClient,
  userId: string,
): Promise<string[]> {
  const { data, error } = await supabase
    .from('fcm_tokens')
    .select('token')
    .eq('user_id', userId)
    .eq('is_active', true)

  if (error) {
    console.error('[notification_push] fcm_tokens 조회 실패:', error)
    return []
  }

  if (!data) return []

  return data
    .map((row) => row.token as string)
    .filter((token): token is string => Boolean(token))
}

async function sendFcmPushToToken(params: {
  token: string
  title: string
  body: string
  data: Record<string, string>
}): Promise<void> {
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')
  if (!fcmServerKey) {
    throw new Error('FCM_SERVER_KEY not configured')
  }

  const response = await fetch(FCM_ENDPOINT, {
    method: 'POST',
    headers: {
      Authorization: `key=${fcmServerKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: params.token,
      notification: {
        title: params.title,
        body: params.body,
        sound: 'default',
      },
      data: params.data,
      android: {
        priority: 'high',
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            contentAvailable: true,
          },
        },
      },
    }),
  })

  if (!response.ok) {
    const responseText = await response.text()
    throw new Error(`FCM request failed: ${response.status} ${responseText}`)
  }
}

export async function sendPushToUser(
  supabase: SupabaseClient,
  userId: string,
  params: PushDeliveryParams,
): Promise<CharacterPushSendResult> {
  const tokens = await getActiveCharacterTokens(supabase, userId)
  if (tokens.length === 0) {
    return {
      userId,
      characterId: '',
      sentCount: 0,
      skipped: true,
      reason: 'no active token',
    }
  }

  let sentCount = 0
  const results = await Promise.allSettled(
    tokens.map((token) =>
      sendFcmPushToToken({
        token,
        title: params.title,
        body: params.body,
        data: params.data,
      }),
    ),
  )

  for (const result of results) {
    if (result.status === 'fulfilled') {
      sentCount += 1
    }
  }

  return {
    userId,
    characterId: params.data.character_id || '',
    sentCount,
    skipped: sentCount === 0,
    reason: sentCount === 0 ? 'failed to send to all tokens' : undefined,
  }
}

export async function sendCharacterDmPush(params: {
  supabase: SupabaseClient
  userId: string
  characterId: string
  characterName: string
  messageText: string
  messageId?: string
  conversationId?: string
  roomState?: string
  type?: CharacterPushPayload['type']
}): Promise<CharacterPushSendResult> {
  const isEnabled = await hasCharacterNotificationEnabled(
    params.supabase,
    params.userId,
  )

  if (!isEnabled) {
    return {
      userId: params.userId,
      characterId: params.characterId,
      sentCount: 0,
      skipped: true,
      reason: 'notification disabled',
    }
  }

  const tokens = await getActiveCharacterTokens(params.supabase, params.userId)
  if (tokens.length === 0) {
    return {
      userId: params.userId,
      characterId: params.characterId,
      sentCount: 0,
      skipped: true,
      reason: 'no active token',
    }
  }

  const payload = buildCharacterDmPayload({
    characterId: params.characterId,
    characterName: params.characterName,
    messageText: params.messageText,
    messageId: params.messageId,
    conversationId: params.conversationId,
    roomState: params.roomState,
    type: params.type,
  })

  const pushResult = await sendPushToUser(params.supabase, params.userId, {
    title: params.characterName,
    body: params.messageText,
    data: payload,
  })
  
  return {
    userId: params.userId,
    characterId: params.characterId,
    sentCount: pushResult.sentCount,
    skipped: pushResult.skipped,
    reason: pushResult.reason,
  }
}

export { createClient as createSupabaseClient }
