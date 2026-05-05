/**
 * 캐릭터 답장 지연 발송 cron worker
 *
 * @description pg_cron 이 매분 호출. scheduled_character_replies 에서 deliver_at
 * 도달 + 클라이언트 ack 미수신 + 미취소 row 를 찾아 character_conversations 에
 * append + 푸시 발송. 클라이언트가 foreground 에서 자체 처리한 row 는 ack 로
 * 표시되어 여기서 스킵.
 *
 * @endpoint POST /deliver-due-replies
 * @body {} (cron 호출이라 페이로드 없음)
 *
 * 처리 정책:
 *   - deliver_at <= now() - 20초 grace: 클라이언트 ACK 가 약간 늦더라도 cron
 *     이 먼저 가로채서 푸시 중복 발송하는 사고 방지. 20초면 RN setTimeout +
 *     ack invoke 1라운드 충분.
 *   - LIMIT 100: 1분 단위 cron 처리량 상한. 부하 큰 케이스에서도 cron 실행
 *     시간이 polling 주기보다 길어지지 않도록.
 *   - row 별 try/catch: 1개 실패가 다음 row 처리 막지 않도록.
 *
 * 인증: 다른 cron 워커들과 동일하게 anon JWT 로 호출되지만 auth 검증 없이
 * service role 로 동작. cron-only 엔드포인트 (외부 노출 X).
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { persistAndPushCharacterMessage } from "../_shared/character_message_helper.ts";
import { requireWorkerAuth } from "../_shared/worker_auth.ts";

interface ScheduledReplyRow {
  id: string;
  user_id: string;
  character_id: string;
  character_name: string;
  content: string;
  segments: string[] | null;
  emotion_tag: string | null;
  delay_sec: number;
  deliver_at: string;
}

interface DeliveryResult {
  scheduledId: string;
  userId: string;
  characterId: string;
  pushSent: boolean;
  reason?: string;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // /ultrareview SRE P0 #6: cron worker 인증 강제.
  const authError = requireWorkerAuth(req);
  if (authError) return authError;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const startedAt = Date.now();
  const delivered: DeliveryResult[] = [];
  const failed: { scheduledId: string; error: string }[] = [];

  try {
    // 처리 대상 조회. 20초 grace 로 클라이언트 ACK 와의 race 회피.
    const graceCutoff = new Date(Date.now() - 20_000).toISOString();
    const { data: rows, error: queryError } = await supabase
      .from("scheduled_character_replies")
      .select(
        "id, user_id, character_id, character_name, content, segments, emotion_tag, delay_sec, deliver_at",
      )
      .is("delivered_at", null)
      .is("canceled_at", null)
      .is("client_acked_at", null)
      .lte("deliver_at", graceCutoff)
      .order("deliver_at", { ascending: true })
      .limit(100);

    if (queryError) {
      console.error("[deliver-due-replies] 조회 실패:", queryError);
      return new Response(
        JSON.stringify({ success: false, error: queryError.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const dueRows = (rows ?? []) as ScheduledReplyRow[];

    for (const row of dueRows) {
      try {
        // 1. 원자적으로 처리 권한 확보: delivered_at 을 set 시도. 동시 cron
        //    인스턴스가 같은 row 를 처리하려고 해도 두 번째 UPDATE 는
        //    matched=0 으로 떨어짐.
        const claimAt = new Date().toISOString();
        const { data: claimed, error: claimError } = await supabase
          .from("scheduled_character_replies")
          .update({ delivered_at: claimAt })
          .eq("id", row.id)
          .is("delivered_at", null)
          .is("canceled_at", null)
          .is("client_acked_at", null)
          .select("id")
          .maybeSingle();

        if (claimError) {
          failed.push({
            scheduledId: row.id,
            error: `claim failed: ${claimError.message}`,
          });
          continue;
        }
        if (!claimed) {
          // 다른 cron 인스턴스가 먼저 가로챘거나 클라이언트가 ack 함 → 스킵
          continue;
        }

        // 2+3. character_conversations 머지 + push 발송 통합.
        // _shared/character_message_helper.persistAndPushCharacterMessage 가
        // RPC merge (advisory lock + id-dedup + cap) + sendCharacterDmPush 를
        // 함께 처리. proactive-message-dispatch 와 동일 helper — "서버 한 곳"
        // 정책. fail-soft: merge 실패해도 push 시도, 그 반대도 마찬가지.
        // scheduledId 별도 필드: 클라가 받자마자 ack-scheduled-reply 호출 →
        // client_acked_at 마킹 → 같은 row 재처리 방지. messageId 는 옛 OTA
        // 클라 호환을 위해 1 릴리스 유지 (helper 내부에서 messageId 로 전달).
        const result = await persistAndPushCharacterMessage({
          supabase,
          userId: row.user_id,
          characterId: row.character_id,
          characterName: row.character_name,
          messageContent: row.content,
          messageId: `scheduled-${row.id}`,
          emotionTag: row.emotion_tag ?? undefined,
          scheduledId: row.id,
          pushType: "character_dm",
          roomState: "character_chat",
        });
        if (result.persistError) {
          failed.push({
            scheduledId: row.id,
            error: `conversation merge: ${result.persistError}`,
          });
          // claim 은 이미 됐지만 merge 가 실패. 다음 cron 에서는 delivered_at
          // NOT NULL 이라 스킵 → 알림센터 history 누락 (push 는 helper 가 시도).
          continue;
        }

        // 4. push_sent_at 마킹
        const pushSentAt = result.pushSentCount > 0
          ? new Date().toISOString()
          : null;
        await supabase
          .from("scheduled_character_replies")
          .update({ push_sent_at: pushSentAt })
          .eq("id", row.id);

        delivered.push({
          scheduledId: row.id,
          userId: row.user_id,
          characterId: row.character_id,
          pushSent: result.pushSentCount > 0,
          reason: result.pushSkipReason,
        });
      } catch (rowError) {
        failed.push({
          scheduledId: row.id,
          error: rowError instanceof Error ? rowError.message : String(rowError),
        });
      }
    }

    const elapsedMs = Date.now() - startedAt;
    console.log(
      `[deliver-due-replies] processed=${dueRows.length} delivered=${delivered.length} failed=${failed.length} elapsedMs=${elapsedMs}`,
    );

    return new Response(
      JSON.stringify({
        success: true,
        processed: dueRows.length,
        delivered,
        failed,
        elapsedMs,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[deliver-due-replies] 예외:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
