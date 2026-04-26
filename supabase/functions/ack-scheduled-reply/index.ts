/**
 * 클라이언트 foreground 렌더 완료 ACK
 *
 * @description 클라이언트가 setTimeout 만료 시점에 캐릭터 답장을 렌더한 직후
 * 호출. 해당 scheduled row 를 client_acked_at 으로 마킹해서 cron worker 가
 * 같은 메시지를 푸시로 또 보내지 않도록 한다.
 *
 * @endpoint POST /ack-scheduled-reply
 * @body { scheduledId: string }
 * @response { success: boolean, alreadyDelivered?: boolean }
 *
 * 시퀀스:
 *   1. 클라가 character-chat 응답에서 scheduledId + deliverAt 받음
 *   2. setTimeout(deliverAt - now) 에서 메시지 렌더 + saveCharacterConversation
 *      (character_conversations 갱신)
 *   3. ack-scheduled-reply 호출 → 이 row 의 client_acked_at, delivered_at set
 *   4. cron 매분 deliver-due-replies 가 client_acked_at NOT NULL row 는 스킵
 *
 * Race window: 클라 ACK 와 cron 이 동시에 처리 시도하는 케이스.
 *   - cron 쿼리는 deliver_at <= now() - interval '20 seconds' 를 기준으로
 *     20초 grace 를 둠. 이 안에 클라 ACK 가 도착하면 cron 은 스킵.
 *   - 그래도 race 발생 시: ack 는 character_conversations 를 클라가 직접
 *     write 하므로 멱등 (같은 messageId 재추가는 client save 가 dedup).
 *     cron 은 push 만 보내고 char_conversations 는 update 하지 않음 → 중복
 *     write 위험은 없음. 푸시 1회 노이즈는 발생할 수 있음 (acceptable).
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { authenticateUser } from "../_shared/auth.ts";

interface AckRequest {
  scheduledId?: string;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ success: false, error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const auth = await authenticateUser(req);
  if (auth.error) return auth.error;
  const user = auth.user;
  if (!user) {
    return new Response(
      JSON.stringify({ success: false, error: "Unauthorized" }),
      {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  let body: AckRequest;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ success: false, error: "Invalid JSON" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const scheduledId = body.scheduledId?.trim();
  if (!scheduledId) {
    return new Response(
      JSON.stringify({ success: false, error: "scheduledId is required" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  // service role 로 UPDATE — RLS 우회 X. 위에서 user 검증했고 WHERE user_id
  // 로 ownership 강제하므로 안전. service role 을 쓰는 이유는 이 row 는 RLS
  // SELECT 정책상 사용자 본인이 읽을 수 있지만, character-chat 이 service
  // role 로 INSERT 한 row 의 일부 컬럼 갱신을 사용자 컨텍스트로 해도 RLS
  // UPDATE 정책이 통과하므로 사실 service role 안 써도 됨. 다만 ownership
  // 누락된 row 가 와도 카운트 0 으로 떨어지므로 명시적으로 service role 사용.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const now = new Date().toISOString();
  const { data: updated, error: updateError } = await supabase
    .from("scheduled_character_replies")
    .update({
      client_acked_at: now,
      delivered_at: now,
    })
    .eq("id", scheduledId)
    .eq("user_id", user.id)
    .is("delivered_at", null)
    .is("canceled_at", null)
    .select("id")
    .maybeSingle();

  if (updateError) {
    console.error("[ack-scheduled-reply] update 실패:", updateError);
    return new Response(
      JSON.stringify({ success: false, error: updateError.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  // updated == null 이면:
  //   - 이미 cron 이 처리했거나 (delivered_at NOT NULL)
  //   - canceled 됐거나 (canceled_at NOT NULL)
  //   - 존재하지 않는 row 거나 (다른 사용자 owns)
  // 어느 쪽이든 클라이언트는 더 할 일 없음 → success=true 로 반환 (멱등).
  return new Response(
    JSON.stringify({
      success: true,
      alreadyDelivered: updated == null,
    }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});
