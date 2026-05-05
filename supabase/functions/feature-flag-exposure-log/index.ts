// PR-0c: Feature Flag exposure batch insert.
//
// POST /feature-flag-exposure-log
// Body: { events: ExposureEvent[] }
//
// ExposureEvent:
//   { installId, userId? (Authorization header 에서 추출되면 우선), flagName,
//     resolvedValue, rampPct, configVersion, surface, evaluatedAt }
//
// - 한 요청에 max 100 events
// - service_role 로 직접 INSERT (RLS bypass)
// - 실패는 fail-open — 클라가 다음 batch 에서 재시도하지 않음 (분석용 데이터라
//   완벽 도착 보장 불필요)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const MAX_EVENTS_PER_REQUEST = 100;

const ALLOWED_SURFACES = new Set([
  "chat_open",
  "menu_render",
  "cost_modal",
  "generation",
  "route_redirect",
]);

const ALLOWED_FLAG_NAMES = new Set([
  "haneul_enabled",
  "haneul_fortune_enabled",
  "direct_chips_enabled",
  "fortune_route_behavior",
]);

interface ExposureEventInput {
  installId?: string;
  /** /codex review P2: per-event userId. 클라가 이벤트 발생 시점에 캡처해 보냄.
   *  flush 시점의 Authorization 보다 정확. anon 이면 null. */
  userId?: string | null;
  flagName?: string;
  resolvedValue?: unknown;
  rampPct?: number;
  configVersion?: number;
  surface?: string;
  evaluatedAt?: string; // ISO
}

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
    const { events } = body as { events?: ExposureEventInput[] };

    if (!Array.isArray(events) || events.length === 0) {
      return new Response(
        JSON.stringify({ error: "Missing events" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (events.length > MAX_EVENTS_PER_REQUEST) {
      return new Response(
        JSON.stringify({ error: `Too many events (max ${MAX_EVENTS_PER_REQUEST})` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // /codex review P2: 클라가 per-event userId 를 보냄. flush 시 auth header 있어도
    // 그 값이 이벤트 발생 시점이라는 보장 없음. 클라 값을 신뢰 (analytics-only,
    // 보안 결정에 사용 X). auth header 는 검증 / 일관성 체크용으로만 추출.
    let currentAuthUserId: string | null = null;
    const authHeader = req.headers.get("Authorization");
    if (authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const { data: { user } } = await supabase.auth.getUser(token);
      currentAuthUserId = user?.id ?? null;
    }

    // 입력 검증 + 변환
    const rows = [];
    let invalid = 0;
    const nowIso = new Date().toISOString();
    for (const ev of events) {
      if (
        !ev.installId ||
        typeof ev.installId !== "string" ||
        !ev.flagName ||
        typeof ev.flagName !== "string" ||
        !ALLOWED_FLAG_NAMES.has(ev.flagName) ||
        ev.surface == null ||
        typeof ev.surface !== "string" ||
        !ALLOWED_SURFACES.has(ev.surface) ||
        ev.resolvedValue === undefined
      ) {
        invalid++;
        continue;
      }

      // 클라 per-event userId 신뢰. 추가 안전장치: 클라가 string userId 를 보냈는데
      // 현재 auth 와 다른 사용자 — 그래도 클라 값 사용 (이벤트 발생 시 정확).
      // null 또는 undefined 면 fallback 으로 현재 auth user.
      const eventUserId = typeof ev.userId === "string" && ev.userId.length > 0
        ? ev.userId
        : currentAuthUserId;

      rows.push({
        user_id: eventUserId,
        install_id: ev.installId,
        flag_name: ev.flagName,
        resolved_value: ev.resolvedValue,
        ramp_pct: typeof ev.rampPct === "number" ? Math.max(0, Math.min(100, Math.floor(ev.rampPct))) : 0,
        config_version: typeof ev.configVersion === "number" && Number.isFinite(ev.configVersion)
          ? Math.floor(ev.configVersion)
          : 0,
        surface: ev.surface,
        evaluated_at: ev.evaluatedAt && typeof ev.evaluatedAt === "string"
          ? ev.evaluatedAt
          : nowIso,
      });
    }

    if (rows.length === 0) {
      return new Response(
        JSON.stringify({ inserted: 0, invalid }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { error } = await supabase
      .from("feature_flag_exposures")
      .insert(rows);

    if (error) {
      console.error("[feature-flag-exposure-log] insert 실패:", error.message);
      return new Response(
        JSON.stringify({ error: "Insert failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ inserted: rows.length, invalid }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("[feature-flag-exposure-log] error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
