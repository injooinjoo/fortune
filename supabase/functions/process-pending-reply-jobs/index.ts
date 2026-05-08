/**
 * pending_character_reply_jobs cron worker.
 *
 * @description pg_cron 매분 호출. claim_next_pending_reply_job RPC 로 가장 오래된
 * pending row 클레임 (FOR UPDATE SKIP LOCKED + 30초 grace), 저장된 request_payload
 * 와 jobId 로 character-chat Edge Function 을 인보크. character-chat 가 LLM 호출,
 * scheduled_character_replies INSERT, 그리고 jobs row done 마킹까지 책임짐.
 *
 * @endpoint POST /process-pending-reply-jobs
 * @body {} (cron 호출이라 페이로드 없음)
 *
 * 처리 정책:
 *   - tick 당 최대 5개 (BATCH_LIMIT). 1분 cron 인터벌 내 충분히 처리 가능 +
 *     LLM 비용 폭주 방지. 큐가 길면 다음 tick 에서 이어서.
 *   - 30초 grace: claim_next_pending_reply_job 의 default 인자. 클라 invoke
 *     경로가 우선 처리할 시간 양보.
 *   - row 별 try/catch: 1개 실패가 다음 row 처리 막지 않음.
 *   - character-chat 호출은 await — 응답 받아야 jobs done 마킹이 일관됨.
 *     claim 후 invoke 가 실패하면 jobs row 는 'processing' 으로 남음 →
 *     recover_stuck_pending_reply_jobs (hourly) 가 5분 후 pending 복귀.
 *
 * 인증: requireWorkerAuth (SUPABASE_SERVICE_ROLE_KEY 또는 CRON_SECRET).
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { requireWorkerAuth } from "../_shared/worker_auth.ts";

const BATCH_LIMIT = 5;
const GRACE_SECONDS = 30;

interface PendingJobRow {
  id: string;
  user_id: string;
  character_id: string;
  character_name: string;
  user_message_id: string;
  user_message: string;
  request_payload: Record<string, unknown>;
  status: string;
  attempt_count: number;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const authError = requireWorkerAuth(req);
  if (authError) return authError;

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceKey) {
    return new Response(
      JSON.stringify({
        success: false,
        error: "missing_supabase_env",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const supabase = createClient(supabaseUrl, serviceKey);

  const startedAt = Date.now();
  const results: Array<{
    jobId: string;
    status: "invoked" | "skipped" | "error";
    reason?: string;
  }> = [];

  for (let i = 0; i < BATCH_LIMIT; i++) {
    let claimed: PendingJobRow | null = null;
    try {
      const { data, error } = await supabase.rpc(
        "claim_next_pending_reply_job",
        { p_grace_seconds: GRACE_SECONDS },
      );
      if (error) {
        console.error("[process-pending-reply-jobs] claim 실패:", error.message);
        break;
      }
      // RPC 가 RETURNS pending_character_reply_jobs (record). 클레임할 row 없으면
      // 모든 컬럼 NULL row 가 나옴 — id 없으면 노op 처리.
      claimed = data && (data as { id?: string }).id ? (data as PendingJobRow) : null;
    } catch (claimEx) {
      console.error("[process-pending-reply-jobs] claim 예외:", claimEx);
      break;
    }

    if (!claimed) break; // 더 이상 픽업할 row 없음

    const jobId = claimed.id;
    try {
      // 저장된 request_payload 로 character-chat 인보크. jobId 를 항상 덮어
      // 써서 character-chat 의 atomic 클레임 분기로 들어가지 않도록 — 우리가
      // 이미 클레임했으니 character-chat 의 claim_pending_reply_job_by_id 는
      // 'pending' 이 아니라 'processing' 이라 NULL 리턴 → noop. 따라서 jobId
      // 안 보내고 그냥 LLM 만 돌리는 게 정상. 단, 그러면 character-chat 가
      // 정상 종료해도 jobs row done 마킹이 안 됨. 해결: 우리가 invoke 후 직접
      // done/failed 마킹.
      const payload: Record<string, unknown> = {
        ...claimed.request_payload,
        // 우리가 이미 row 클레임했으므로 character-chat 가 다시 claim 시도 →
        // NULL 받고 noop 으로 빠지면 LLM 호출이 안 됨. 따라서 jobId 빼고 호출.
        // 호출 결과는 우리가 직접 done/failed 마킹.
        // 또한 service_role 토큰으로 invoke 하면 character-chat 의 auth.getUser
        // 가 user 못 찾으므로 trustedUserId 로 식별.
        trustedUserId: claimed.user_id,
      };
      delete payload.jobId;

      const { data: chatData, error: chatErr } = await supabase
        .functions.invoke("character-chat", { body: payload });

      if (chatErr) {
        // 호출 실패 — 재시도 대상. attempt_count 가 3 이상이면 failed.
        const errMsg = (chatErr as Error).message ?? String(chatErr);
        if (claimed.attempt_count >= 3) {
          await supabase
            .from("pending_character_reply_jobs")
            .update({
              status: "failed",
              error_message: errMsg.slice(0, 500),
              completed_at: new Date().toISOString(),
            })
            .eq("id", jobId);
          results.push({ jobId, status: "error", reason: "max_attempts" });
        } else {
          const delayMin = claimed.attempt_count >= 2 ? 15 : 5;
          await supabase
            .from("pending_character_reply_jobs")
            .update({
              status: "pending",
              next_attempt_at: new Date(Date.now() + delayMin * 60_000).toISOString(),
              error_message: errMsg.slice(0, 500),
            })
            .eq("id", jobId);
          results.push({ jobId, status: "error", reason: "retry_scheduled" });
        }
        continue;
      }

      // 정상 — character-chat 가 success/segments 또는 noop/safety 응답을 줬을 것.
      // 어느 쪽이든 큐 관점에선 처리 완료.
      const responseSuccess = (chatData as { success?: boolean })?.success ?? true;
      await supabase
        .from("pending_character_reply_jobs")
        .update({
          status: responseSuccess ? "done" : "failed",
          error_message: responseSuccess
            ? null
            : ((chatData as { error?: string })?.error?.slice(0, 500) ?? null),
          completed_at: new Date().toISOString(),
        })
        .eq("id", jobId);
      results.push({
        jobId,
        status: "invoked",
        reason: responseSuccess ? "ok" : "chat_failed",
      });
    } catch (invokeEx) {
      const errMsg = invokeEx instanceof Error
        ? invokeEx.message
        : String(invokeEx);
      console.error(
        "[process-pending-reply-jobs] character-chat invoke 예외:",
        errMsg,
      );
      // 예외 발생 시 row 는 processing 으로 남음 — recover_stuck cron 이 5분 후
      // pending 복귀. 여기선 단순 로그.
      results.push({ jobId, status: "error", reason: "invoke_exception" });
    }
  }

  return new Response(
    JSON.stringify({
      success: true,
      processed: results.length,
      results,
      durationMs: Date.now() - startedAt,
    }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});
