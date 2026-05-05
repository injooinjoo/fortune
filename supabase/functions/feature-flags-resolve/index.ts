// PR-0b: Feature Flag resolve Edge Function.
//
// POST /feature-flags-resolve
// Body: { installId: string }
// Header: Authorization (선택 — 인증되어 있으면 user.id 사용, 아니면 installId)
//
// Response:
// {
//   "flags": { "haneul_enabled": false, ..., "fortune_route_behavior": "legacy" },
//   "versions": { "haneul_enabled": 1, ... },     -- config_version (P0 takedown 비교용)
//   "rampPcts": { "haneul_enabled": 0, ... },     -- 운영/디버그
//   "resolvedAt": "2026-05-06T..."
// }
//
// 클라는 결과를 캐시에 저장 + safety class 별 TTL 적용. config_version 변경 감지
// 시 즉시 재요청 (kill switch 채널).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { resolveAllFlags } from "../_shared/feature_flags.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const { installId } = body as { installId?: string };

    if (!installId || typeof installId !== "string" || installId.length === 0) {
      return new Response(
        JSON.stringify({ error: "Missing installId" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Auth 옵션 — 있으면 userId 우선 sticky bucket. 없으면 installId.
    let userId: string | null = null;
    const authHeader = req.headers.get("Authorization");
    if (authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const { data: { user } } = await supabase.auth.getUser(token);
      userId = user?.id ?? null;
    }

    const result = await resolveAllFlags(supabase, { userId, installId });

    return new Response(
      JSON.stringify({
        ...result,
        resolvedAt: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("[feature-flags-resolve] error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
