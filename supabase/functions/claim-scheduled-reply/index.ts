/**
 * Foreground scheduled reply claim.
 *
 * The client intentionally does not render the LLM response immediately. It
 * waits until deliver_at, then claims the scheduled row here. If the row was
 * canceled by a newer user message, no message is returned.
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { authenticateUser } from "../_shared/auth.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import {
  buildScheduledReplyMessages,
  persistScheduledReplyMessages,
} from "../_shared/scheduled_reply_message.ts";

interface ClaimScheduledReplyRequest {
  scheduledId?: string;
}

interface ScheduledReplyRow {
  id: string;
  user_id: string;
  character_id: string;
  content: string;
  segments: unknown;
  emotion_tag: string | null;
  deliver_at: string;
  delivered_at: string | null;
  canceled_at: string | null;
  client_acked_at: string | null;
}

function toStringSegments(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  return value.filter((item): item is string => typeof item === "string");
}

function buildDeliveredResponse(row: ScheduledReplyRow, timestamp: string) {
  const messages = buildScheduledReplyMessages({
    scheduledId: row.id,
    content: row.content,
    segments: toStringSegments(row.segments),
    emotionTag: row.emotion_tag,
    timestamp,
  });

  return { messages };
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

  let body: ClaimScheduledReplyRequest;
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

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: row, error: selectError } = await supabase
    .from("scheduled_character_replies")
    .select(
      "id, user_id, character_id, content, segments, emotion_tag, deliver_at, delivered_at, canceled_at, client_acked_at",
    )
    .eq("id", scheduledId)
    .eq("user_id", user.id)
    .maybeSingle();

  if (selectError) {
    console.error("[claim-scheduled-reply] select failed:", selectError);
    return new Response(
      JSON.stringify({ success: false, error: selectError.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const scheduledRow = row as ScheduledReplyRow | null;
  if (!scheduledRow || scheduledRow.canceled_at) {
    return new Response(
      JSON.stringify({ success: true, status: "canceled" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  if (scheduledRow.delivered_at || scheduledRow.client_acked_at) {
    // Race-safe foreground delivery: a cron/previous claim may mark the row as
    // delivered between the client's generated delay and this foreground claim.
    // Returning no messages here made the client hide the typing indicator and
    // render nothing ("..." disappears, no reply). The scheduled row still has
    // canonical content, so return the same message payload idempotently.
    const deliveredTimestamp = scheduledRow.client_acked_at ??
      scheduledRow.delivered_at ?? new Date().toISOString();
    const { messages } = buildDeliveredResponse(
      scheduledRow,
      deliveredTimestamp,
    );
    return new Response(
      JSON.stringify({ success: true, status: "delivered", messages }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  if (Date.parse(scheduledRow.deliver_at) > Date.now()) {
    return new Response(
      JSON.stringify({ success: true, status: "not_due" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const now = new Date().toISOString();
  const { data: claimed, error: claimError } = await supabase
    .from("scheduled_character_replies")
    .update({
      client_acked_at: now,
      delivered_at: now,
    })
    .eq("id", scheduledId)
    .eq("user_id", user.id)
    .is("delivered_at", null)
    .is("canceled_at", null)
    .is("client_acked_at", null)
    .lte("deliver_at", now)
    .select("id")
    .maybeSingle();

  if (claimError) {
    console.error("[claim-scheduled-reply] claim failed:", claimError);
    return new Response(
      JSON.stringify({ success: false, error: claimError.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  if (!claimed) {
    const deliveredTimestamp = scheduledRow.client_acked_at ??
      scheduledRow.delivered_at ??
      new Date().toISOString();
    const { messages } = buildDeliveredResponse(
      scheduledRow,
      deliveredTimestamp,
    );
    return new Response(
      JSON.stringify({ success: true, status: "delivered", messages }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const { messages } = buildDeliveredResponse(scheduledRow, now);

  const persistResult = await persistScheduledReplyMessages({
    supabase,
    userId: user.id,
    characterId: scheduledRow.character_id,
    messages,
  });

  if (persistResult.persistError) {
    console.error(
      "[claim-scheduled-reply] conversation merge failed:",
      persistResult.persistError,
    );
  }

  return new Response(
    JSON.stringify({
      success: true,
      status: "delivered",
      messages,
      persistError: persistResult.persistError,
    }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});
