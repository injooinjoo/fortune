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
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { sendCharacterDmPush } from "../_shared/notification_push.ts";

// 캐릭터별 Follow-up 메시지 템플릿 (랜덤 선택됨)
const FOLLOW_UP_TEMPLATES: Record<string, string[]> = {
  "luts": [
    "잠깐 안부 남겨요. 지금 괜찮으세요?",
    "답장이 없어도 괜찮아요. 편할 때 이야기해요.",
    "오늘은 어떻게 보내고 계세요?",
    "무리하지 말고 식사는 챙기세요.",
  ],
  "jung_tae_yoon": [
    "바쁘시면 나중에 괜찮습니다. 편할 때 답 주세요.",
    "오늘 하루는 어떠셨어요?",
    "무리하지 마세요. 저는 여기서 기다리고 있을게요.",
  ],
  "seo_yoonjae": [
    "세이브포인트가 잠깐 멈춘 느낌이네. 편할 때 다시 이어가자.",
    "혹시 지금 바빠? 아니면 잠깐 얘기할래?",
    "게임은 일시정지도 되니까 천천히 와.",
  ],
  "kang_harin": [
    "괜찮으신가요? 편하실 때만 답 주셔도 됩니다.",
    "오늘 일정이 길었나요. 잠깐 쉬어가세요.",
    "무리하지 마세요. 저는 기다리고 있겠습니다.",
  ],
  "jayden_angel": [
    "오늘 밤은 유난히 조용하네요. 당신 안부가 궁금했어요.",
    "바쁘면 천천히 와도 괜찮아.",
    "지금 기분은 어때?",
  ],
  "ciel_butler": [
    "주인님, 편안하신가요?",
    "답은 서두르지 않으셔도 됩니다. 저는 기다리겠습니다.",
    "오늘도 무리하지 마시고 식사는 챙기세요.",
  ],
  "lee_doyoon": [
    "선배, 잠깐 안부 왔어요 ㅎㅎ 지금 괜찮아요?",
    "바쁘면 나중에 답해줘요. 저는 기다릴게요 ^^",
    "오늘 하루 어땠어요?",
  ],
  "han_seojun": [
    "바쁘면 괜찮아. 편할 때 와.",
    "새 곡 조금 만졌어. 나중에 들려줄게.",
    "오늘은 어떻게 보냈어?",
  ],
  "baek_hyunwoo": [],
  "min_junhyuk": [
    "오늘도 고생 많으셨어요. 잠깐 쉬고 계세요.",
    "따뜻한 음료 한 잔 생각나는 시간이에요.",
    "컨디션은 어떠세요?",
  ],
};

interface FollowUpRequest {
  userId?: string;
  characterId?: string;
  action: "schedule" | "cancel" | "process";
  delayMinutes?: number;
  fcmToken?: string;
}

interface ScheduledFollowUp {
  id: string;
  user_id: string;
  character_id: string;
  scheduled_at: string;
  attempt_number: number;
  fcm_token: string;
  status: "pending" | "sent" | "cancelled";
}

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const body: FollowUpRequest = await req.json();
    const { action, userId, characterId, delayMinutes, fcmToken } = body;

    switch (action) {
      case "schedule": {
        // Follow-up 스케줄 등록
        if (!userId || !characterId || !fcmToken) {
          return new Response(
            JSON.stringify({
              success: false,
              error: "userId, characterId, fcmToken 필수",
            }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
              status: 400,
            },
          );
        }

        // 기존 스케줄 취소
        await supabase
          .from("character_follow_ups")
          .update({ status: "cancelled" })
          .eq("user_id", userId)
          .eq("character_id", characterId)
          .eq("status", "pending");

        // 새 스케줄 등록
        const scheduledAt = new Date(
          Date.now() + (delayMinutes || 5) * 60 * 1000,
        );

        const { error } = await supabase.from("character_follow_ups").insert({
          user_id: userId,
          character_id: characterId,
          scheduled_at: scheduledAt.toISOString(),
          attempt_number: 1,
          fcm_token: fcmToken,
          status: "pending",
        });

        if (error) {
          console.error("스케줄 등록 실패:", error);
          return new Response(
            JSON.stringify({ success: false, error: error.message }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
              status: 500,
            },
          );
        }

        return new Response(
          JSON.stringify({
            success: true,
            scheduledAt: scheduledAt.toISOString(),
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      case "cancel": {
        // Follow-up 취소 (사용자가 앱으로 돌아왔을 때)
        if (!userId || !characterId) {
          return new Response(
            JSON.stringify({
              success: false,
              error: "userId, characterId 필수",
            }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
              status: 400,
            },
          );
        }

        await supabase
          .from("character_follow_ups")
          .update({ status: "cancelled" })
          .eq("user_id", userId)
          .eq("character_id", characterId)
          .eq("status", "pending");

        return new Response(
          JSON.stringify({ success: true }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      case "process": {
        // 대기 중인 Follow-up 처리 (cron job에서 호출)
        const now = new Date().toISOString();

        // 실행 시간이 된 스케줄 조회
        const { data: pendingFollowUps, error: fetchError } = await supabase
          .from("character_follow_ups")
          .select("*")
          .eq("status", "pending")
          .lte("scheduled_at", now)
          .limit(100);

        if (fetchError) {
          console.error("스케줄 조회 실패:", fetchError);
          return new Response(
            JSON.stringify({ success: false, error: fetchError.message }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
              status: 500,
            },
          );
        }

        const results: { id: string; success: boolean; error?: string }[] = [];

        for (
          const followUp of (pendingFollowUps || []) as ScheduledFollowUp[]
        ) {
          try {
            // 캐릭터별 메시지 선택
            const templates = FOLLOW_UP_TEMPLATES[followUp.character_id] || [];
            if (templates.length === 0) {
              // 이 캐릭터는 Follow-up을 보내지 않음
              await supabase
                .from("character_follow_ups")
                .update({ status: "cancelled" })
                .eq("id", followUp.id);
              continue;
            }

            // 랜덤 선택으로 다양성 확보
            const messageIndex = Math.floor(Math.random() * templates.length);
            const message = templates[messageIndex];

            // 캐릭터 이름 조회 (간단히 ID에서 추출)
            const characterName = getCharacterName(followUp.character_id);

            // FCM 푸시 전송
            await sendCharacterDmPush({
              supabase,
              userId: followUp.user_id,
              characterId: followUp.character_id,
              characterName,
              messageText: message,
              messageId: followUp.id,
              type: "character_follow_up",
              roomState: "follow_up",
            });

            // 상태 업데이트
            await supabase
              .from("character_follow_ups")
              .update({ status: "sent" })
              .eq("id", followUp.id);

            results.push({ id: followUp.id, success: true });
          } catch (error) {
            console.error(`Follow-up 전송 실패 (${followUp.id}):`, error);
            results.push({
              id: followUp.id,
              success: false,
              error: error instanceof Error ? error.message : "Unknown error",
            });
          }
        }

        return new Response(
          JSON.stringify({ success: true, processed: results.length, results }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      default:
        return new Response(
          JSON.stringify({ success: false, error: "Invalid action" }),
          {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 400,
          },
        );
    }
  } catch (error) {
    console.error("character-follow-up 에러:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
});

// 캐릭터 ID에서 이름 추출
function getCharacterName(characterId: string): string {
  const names: Record<string, string> = {
    "luts": "러츠",
    "jung_tae_yoon": "정태윤",
    "seo_yoonjae": "서윤재",
    "kang_harin": "강하린",
    "jayden_angel": "제이든",
    "ciel_butler": "시엘",
    "lee_doyoon": "이도윤",
    "han_seojun": "한서준",
    "baek_hyunwoo": "백현우",
    "min_junhyuk": "민준혁",
  };
  return names[characterId] || characterId;
}
