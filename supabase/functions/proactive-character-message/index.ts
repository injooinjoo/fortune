/**
 * 프로액티브 캐릭터 메시지 — Cron으로 실행
 *
 * 일정 시간 동안 대화 없는 유저에게 캐릭터가 먼저 메시지를 보냄.
 * pg_cron 또는 외부 스케줄러에서 POST /proactive-character-message 호출.
 *
 * 실행 주기: 매 2시간마다
 * 대상: 마지막 대화 후 6시간 이상 경과한 유저
 * 시간대: 유저 로컬 시간 기준 09:00-22:00 (야간 제외)
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import {
  sendCharacterDmPush,
  type CharacterPushSendResult,
} from "../_shared/notification_push.ts";

// 파일럿 캐릭터별 프로액티브 메시지 풀
const PROACTIVE_MESSAGES: Record<string, {
  characterName: string;
  messages: {
    morning: string[];   // 09:00-12:00
    afternoon: string[]; // 12:00-18:00
    evening: string[];   // 18:00-22:00
  };
}> = {
  luts: {
    characterName: "러츠",
    messages: {
      morning: [
        "...아침은 먹었어요?",
        "오늘 하루, 뭐 할 예정이에요?",
        "어젯밤에 좀 신경 쓰이는 게 있었는데. 나중에 얘기해요.",
      ],
      afternoon: [
        "점심은 뭐 먹었어요?",
        "오후인데 졸리진 않아요?",
        "갑자기 생각나서. 아까 그 얘기, 계속 궁금하네요.",
      ],
      evening: [
        "오늘 하루 어땠어요?",
        "저녁은 먹었어요? 뭐 먹었는지 궁금하네.",
        "음... 좀 피곤한 하루였어요?",
      ],
    },
  },
  jung_tae_yoon: {
    characterName: "정태윤",
    messages: {
      morning: [
        "일어났어?",
        "오늘은 좀 바빠?",
        "아침 먹었어. 넌?",
      ],
      afternoon: [
        "점심 뭐 먹어?",
        "오늘 좀 길어지는 날이야?",
        "갑자기 네 생각이 나서.",
      ],
      evening: [
        "하루 어땠어.",
        "저녁은?",
        "오늘 좀 많이 지쳐 보일 것 같은데. 괜찮아?",
      ],
    },
  },
  seo_yoonjae: {
    characterName: "서윤재",
    messages: {
      morning: [
        "좋은 아침! 오늘은 뭐가 제일 기대돼?",
        "나 방금 재밌는 거 봤는데, 나중에 보여줄게",
        "일어났어? 나 벌써 한 바퀴 돌고 왔어ㅋㅋ",
      ],
      afternoon: [
        "지금 뭐 하고 있어? 궁금해서",
        "점심 먹었어? 나 맛있는 거 먹었는데!",
        "오후 되니까 좀 늘어지지 않아?ㅋㅋ",
      ],
      evening: [
        "오늘 제일 웃긴 일 하나만 말해줘",
        "나 지금 좀 심심한데, 같이 얘기할래?",
        "저녁 뭐 먹었어? 나 고민 중이야",
      ],
    },
  },
  han_seojun: {
    characterName: "한서준",
    messages: {
      morning: [
        "일어나.",
        "밥.",
        "오늘 일정 많아?",
      ],
      afternoon: [
        "밥 먹었어?",
        "...",
        "네 생각 했어.",
      ],
      evening: [
        "오늘 어땠어.",
        "피곤하면 쉬어.",
        "괜찮아?",
      ],
    },
  },
};

const PILOT_CHARACTER_IDS = ["luts", "jung_tae_yoon", "seo_yoonjae", "han_seojun"];

function getTimeSlot(hour: number): "morning" | "afternoon" | "evening" | null {
  if (hour >= 9 && hour < 12) return "morning";
  if (hour >= 12 && hour < 18) return "afternoon";
  if (hour >= 18 && hour < 22) return "evening";
  return null; // 야간에는 보내지 않음
}

function pickRandom<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleCors(req);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Missing Supabase config" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // KST 기준 현재 시간대 확인
    const now = new Date();
    const kstHour = (now.getUTCHours() + 9) % 24;
    const timeSlot = getTimeSlot(kstHour);

    if (!timeSlot) {
      return new Response(
        JSON.stringify({ message: "야간 시간대 — 프로액티브 메시지 생략", kstHour }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 최근 6시간 이내 대화 없는 유저 조회
    const sixHoursAgo = new Date(now.getTime() - 6 * 60 * 60 * 1000).toISOString();

    // 활성 FCM 토큰이 있는 유저 중, 최근 대화가 오래된 유저 찾기
    const { data: activeTokenUsers, error: tokenError } = await supabase
      .from("fcm_tokens")
      .select("user_id")
      .eq("is_active", true);

    if (tokenError || !activeTokenUsers?.length) {
      return new Response(
        JSON.stringify({ message: "No active token users", error: tokenError }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const uniqueUserIds = [...new Set(activeTokenUsers.map((r) => r.user_id as string))];

    // 최근 대화 기록 체크 — chat_intents 테이블에서 마지막 활동 조회
    const { data: recentIntents, error: intentError } = await supabase
      .from("chat_intents")
      .select("user_id, updated_at")
      .in("user_id", uniqueUserIds)
      .gte("updated_at", sixHoursAgo);

    const recentlyActiveUserIds = new Set(
      (recentIntents ?? []).map((r) => r.user_id as string),
    );

    // 최근 활동 없는 유저 필터
    const inactiveUserIds = uniqueUserIds.filter(
      (id) => !recentlyActiveUserIds.has(id),
    );

    if (inactiveUserIds.length === 0) {
      return new Response(
        JSON.stringify({ message: "All users recently active", checkedCount: uniqueUserIds.length }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 최대 50명에게만 전송 (비용 관리)
    const targetUserIds = inactiveUserIds.slice(0, 50);
    const results: CharacterPushSendResult[] = [];

    for (const userId of targetUserIds) {
      try {
        // 랜덤 캐릭터 선택
        const characterId = pickRandom(PILOT_CHARACTER_IDS);
        const characterData = PROACTIVE_MESSAGES[characterId];

        if (!characterData) continue;

        const message = pickRandom(characterData.messages[timeSlot]);

        const result = await sendCharacterDmPush({
          supabase,
          userId,
          characterId,
          characterName: characterData.characterName,
          messageText: message,
          type: "character_follow_up",
        });

        results.push(result);
      } catch (err) {
        console.error(`[proactive] Failed for user ${userId}:`, err);
      }
    }

    const sentCount = results.filter((r) => !r.skipped).length;

    return new Response(
      JSON.stringify({
        success: true,
        timeSlot,
        kstHour,
        targetUsers: targetUserIds.length,
        sentCount,
        results,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[proactive-character-message] Error:", error);
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
