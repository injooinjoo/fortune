/**
 * 캐릭터 Follow-up 푸시 알림 Edge Function
 *
 * @description 사용자가 앱을 닫은 후 일정 시간이 지나면
 *              캐릭터가 먼저 연락하는 푸시 알림을 전송합니다.
 *
 * @trigger
 * 1. Supabase pg_cron (매 5분마다 실행)
 * 2. 클라이언트에서 앱 백그라운드 진입 시 호출
 *
 * @endpoint POST /character-follow-up
 *
 * @requestBody (클라이언트 호출 시)
 * - userId: string - 사용자 ID
 * - characterId: string - 캐릭터 ID
 * - action: 'schedule' | 'cancel' - 스케줄 등록/취소
 * - delayMinutes?: number - 알림까지 대기 시간 (분)
 *
 * @requestBody (cron job 호출 시)
 * - action: 'process' - 대기 중인 알림 처리
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { sendCharacterDmPush } from '../_shared/notification_push.ts'

// 캐릭터별 Follow-up 메시지 템플릿 (랜덤 선택됨)
const FOLLOW_UP_TEMPLATES: Record<string, string[]> = {
  // 러츠 - 사용자 선제 신호 전까지는 중립 톤 유지
  'luts': [
    '지금 잠깐 시간 괜찮아요?',
    '한동안 답장이 없어서 안부 남겨요.',
    '오늘은 어떻게 보내고 계세요?',
    '*창밖을 보며* 오늘 달이 꽤 맑네요.',
    '바쁘면 나중에 편할 때 답 주세요.',
    '무리하지 말고 식사는 챙기세요.',
    '잠깐 안부만 남길게요. 오늘도 고생 많았어요.',
  ],
  // 정태윤 - 정중한 존댓말
  'jung_tae_yoon': [
    '바쁘신가 보네요. 시간 되실 때 연락 주세요.',
    '오늘 하루 어떠셨어요? 저는... 괜히 신경 쓰였습니다.',
    '무리하지 마세요. 옆에 없어도 걱정은 하고 있으니까요.',
  ],
  // 서윤재 - 게임 용어, 반말/존댓말 스위칭
  'seo_yoonjae': [
    '...세이브포인트가 끊겼나?',
    '혹시 버그야? 접속 안 되는 거야? 🎮',
    '음... 내일 다시 시도해볼게. 굿나잇 ✨',
    '어... 혹시 나 블록당한 거야? 😰',
    '지금 테스트 플레이 중이야? 나도 끼워줘.',
    '*커피 마시며* 이 감정 롤백할 수 있으면 좋겠다...',
    '게임 만드는 건 쉬운데 기다리는 건 어렵네.',
    '내일 회사에서 보면... 모른 척 할 수 있을까?',
  ],
  // 강하린 - 정중하지만 은근히 집착적
  'kang_harin': [
    '괜찮으신가요?',
    '혹시 무슨 일 있으신 건 아니죠?',
    '일정 확인해봤는데... 지금 여유 시간이실 텐데요.',
    '커피 한 잔 가져다드릴까요? 제가 가는 김에.',
    '저, 근처에 있어요. 우연히요. 정말 우연이에요.',
    '답장 기다리고 있었어요. ...아, 바쁘셨군요.',
    '*메모를 보며* 오늘 점심 뭐 드셨는지 궁금하네요.',
  ],
  // 제이든 - 우아하고 신비로운
  'jayden_angel': [
    '...괜찮은 거지? 인간들은 자주 사라지니까.',
    '*날개를 접으며* 천년을 기다렸으니, 하루쯤은 더...',
    '네 안부가 궁금했어. 그게 다야.',
    '*창가에 서서* 오늘 밤하늘이 네 생각나게 하더라.',
  ],
  // 시엘 - 집사 말투, 충성스러운
  'ciel_butler': [
    '주인님, 혹시 제가 불편하게 해드렸나요?',
    '기다리고 있겠습니다. 언제든 불러주세요.',
    '주인님, 오늘 저녁 준비해두었습니다. 차가워지기 전에...',
    '제가 곁에 없어도 괜찮으신 건지 걱정됩니다.',
    '*시계를 보며* 평소 이 시간엔 연락을 주셨는데요.',
  ],
  // 이도윤 - 귀엽고 에너지 넘치는
  'lee_doyoon': [
    '선배! 뭐해요? 🐕',
    '선배... 저 심심해요! 언제 와요? 😢',
    '알았어요... 바쁘신 거죠? 힘내세요 선배! 💪✨',
    '선배~ 저 오늘 칭찬받았어요! 들어줘요 🐕',
    '혹시 화났어요...? 제가 뭐 잘못했나 😢',
    '*폰 들여다보며* 왜 안 읽어요... 바쁜가...',
    '선배 생각하면서 라면 먹는 중이에요 🍜',
    '오늘 하루 어땠어요? 저는 선배 생각했어요!',
    '자고 있는 거예요? 그럼... 굿나잇? 💤',
  ],
  // 한서준 - 쿨하고 무심한
  'han_seojun': [
    '...다음 공연 때 봐.',
    '*기타를 만지며* 새 곡 만들었어. 네가 먼저 들어줬으면.',
    '바쁜 거 알아. 근데 가끔은 생각나.',
  ],
  // 백현우 - follow-up 안 보냄
  'baek_hyunwoo': [],
  // 민준혁 - 따뜻하고 배려 깊은
  'min_junhyuk': [
    '오늘 카페 늦게까지 열어둘게요. 힘드시면 언제든요.',
    '따뜻한 거 한 잔 준비해둘게요. ☕',
    '비 올 것 같던데, 우산 챙기셨어요?',
    '오늘 새로운 레시피 개발했어요. 와서 맛봐주실래요?',
    '가게 정리하면서 당신 생각이 나더라고요.',
  ],
}

interface FollowUpRequest {
  userId?: string
  characterId?: string
  action: 'schedule' | 'cancel' | 'process'
  delayMinutes?: number
  fcmToken?: string
}

interface ScheduledFollowUp {
  id: string
  user_id: string
  character_id: string
  scheduled_at: string
  attempt_number: number
  fcm_token: string
  status: 'pending' | 'sent' | 'cancelled'
}

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const body: FollowUpRequest = await req.json()
    const { action, userId, characterId, delayMinutes, fcmToken } = body

    switch (action) {
      case 'schedule': {
        // Follow-up 스케줄 등록
        if (!userId || !characterId || !fcmToken) {
          return new Response(
            JSON.stringify({ success: false, error: 'userId, characterId, fcmToken 필수' }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
          )
        }

        // 기존 스케줄 취소
        await supabase
          .from('character_follow_ups')
          .update({ status: 'cancelled' })
          .eq('user_id', userId)
          .eq('character_id', characterId)
          .eq('status', 'pending')

        // 새 스케줄 등록
        const scheduledAt = new Date(Date.now() + (delayMinutes || 5) * 60 * 1000)

        const { error } = await supabase.from('character_follow_ups').insert({
          user_id: userId,
          character_id: characterId,
          scheduled_at: scheduledAt.toISOString(),
          attempt_number: 1,
          fcm_token: fcmToken,
          status: 'pending',
        })

        if (error) {
          console.error('스케줄 등록 실패:', error)
          return new Response(
            JSON.stringify({ success: false, error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
          )
        }

        return new Response(
          JSON.stringify({ success: true, scheduledAt: scheduledAt.toISOString() }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      case 'cancel': {
        // Follow-up 취소 (사용자가 앱으로 돌아왔을 때)
        if (!userId || !characterId) {
          return new Response(
            JSON.stringify({ success: false, error: 'userId, characterId 필수' }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
          )
        }

        await supabase
          .from('character_follow_ups')
          .update({ status: 'cancelled' })
          .eq('user_id', userId)
          .eq('character_id', characterId)
          .eq('status', 'pending')

        return new Response(
          JSON.stringify({ success: true }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      case 'process': {
        // 대기 중인 Follow-up 처리 (cron job에서 호출)
        const now = new Date().toISOString()

        // 실행 시간이 된 스케줄 조회
        const { data: pendingFollowUps, error: fetchError } = await supabase
          .from('character_follow_ups')
          .select('*')
          .eq('status', 'pending')
          .lte('scheduled_at', now)
          .limit(100)

        if (fetchError) {
          console.error('스케줄 조회 실패:', fetchError)
          return new Response(
            JSON.stringify({ success: false, error: fetchError.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
          )
        }

        const results: { id: string; success: boolean; error?: string }[] = []

        for (const followUp of (pendingFollowUps || []) as ScheduledFollowUp[]) {
          try {
            // 캐릭터별 메시지 선택
            const templates = FOLLOW_UP_TEMPLATES[followUp.character_id] || []
            if (templates.length === 0) {
              // 이 캐릭터는 Follow-up을 보내지 않음
              await supabase
                .from('character_follow_ups')
                .update({ status: 'cancelled' })
                .eq('id', followUp.id)
              continue
            }

            // 랜덤 선택으로 다양성 확보
            const messageIndex = Math.floor(Math.random() * templates.length)
            const message = templates[messageIndex]

            // 캐릭터 이름 조회 (간단히 ID에서 추출)
            const characterName = getCharacterName(followUp.character_id)

            // FCM 푸시 전송
            await sendCharacterDmPush({
              supabase,
              userId: followUp.user_id,
              characterId: followUp.character_id,
              characterName,
              messageText: message,
              messageId: followUp.id,
              type: 'character_follow_up',
              roomState: 'follow_up',
            })

            // 상태 업데이트
            await supabase
              .from('character_follow_ups')
              .update({ status: 'sent' })
              .eq('id', followUp.id)

            results.push({ id: followUp.id, success: true })
          } catch (error) {
            console.error(`Follow-up 전송 실패 (${followUp.id}):`, error)
            results.push({
              id: followUp.id,
              success: false,
              error: error instanceof Error ? error.message : 'Unknown error',
            })
          }
        }

        return new Response(
          JSON.stringify({ success: true, processed: results.length, results }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      default:
        return new Response(
          JSON.stringify({ success: false, error: 'Invalid action' }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
  } catch (error) {
    console.error('character-follow-up 에러:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})

// 캐릭터 ID에서 이름 추출
function getCharacterName(characterId: string): string {
  const names: Record<string, string> = {
    'luts': '러츠',
    'jung_tae_yoon': '정태윤',
    'seo_yoonjae': '서윤재',
    'kang_harin': '강하린',
    'jayden_angel': '제이든',
    'ciel_butler': '시엘',
    'lee_doyoon': '이도윤',
    'han_seojun': '한서준',
    'baek_hyunwoo': '백현우',
    'min_junhyuk': '민준혁',
  }
  return names[characterId] || characterId
}
