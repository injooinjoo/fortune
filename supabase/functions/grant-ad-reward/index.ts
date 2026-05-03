// 광고 시청 → 1 토큰 지급. 일일 5회 한도. abuse 방지.
// MVP 는 클라이언트 self-attestation (AdMob SSV 미통합) — Sprint 5+ 에서 SSV
// 시그니처 검증 추가 예정. 현재는 빈도 제한 + 인증 사용자만 허용으로 1차 가드.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { authenticateUser } from "../_shared/auth.ts";

const DAILY_AD_LIMIT = 5;
const TOKENS_PER_AD = 1;

interface GrantAdRewardRequest {
  /** AdMob ad unit id 또는 광고 식별자 (분석 용). */
  adUnit?: string;
  /** AdMob Server-Side Verification signature. 미사용 시 빈 값. */
  ssvSignature?: string;
}

interface GrantAdRewardResponse {
  success: boolean;
  tokensGranted?: number;
  newBalance?: number;
  remainingToday?: number;
  error?: string;
  errorCode?: "limit_reached" | "unauthorized" | "unknown";
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({
        success: false,
        error: "Method not allowed",
      } as GrantAdRewardResponse),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    const { user, error: authError } = await authenticateUser(req);
    if (authError || !user) {
      return authError ?? new Response(
        JSON.stringify({
          success: false,
          error: "Unauthorized",
          errorCode: "unauthorized",
        } as GrantAdRewardResponse),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const body = (await req.json().catch(() => ({}))) as GrantAdRewardRequest;

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // 일일 한도 체크.
    const today = new Date().toISOString().split("T")[0];
    const { count: todayCount } = await supabase
      .from("ad_reward_log")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .eq("reward_date", today);

    const usedToday = todayCount ?? 0;
    if (usedToday >= DAILY_AD_LIMIT) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "오늘 광고 시청 한도에 도달했어요",
          errorCode: "limit_reached",
          remainingToday: 0,
        } as GrantAdRewardResponse),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 토큰 지급 (token_balance + token_transactions).
    const { data: tokenData } = await supabase
      .from("token_balance")
      .select("balance, total_earned")
      .eq("user_id", user.id)
      .maybeSingle();

    const balanceBefore = tokenData?.balance ?? 0;
    const totalEarned = tokenData?.total_earned ?? 0;
    const newBalance = balanceBefore + TOKENS_PER_AD;

    await supabase.from("token_balance").upsert(
      {
        user_id: user.id,
        balance: newBalance,
        total_earned: totalEarned + TOKENS_PER_AD,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "user_id" },
    );

    await supabase.from("token_transactions").insert({
      user_id: user.id,
      transaction_type: "earn",
      amount: TOKENS_PER_AD,
      balance_after: newBalance,
      description: "광고 시청 보상",
      reference_type: "ad_reward",
    });

    await supabase.from("ad_reward_log").insert({
      user_id: user.id,
      reward_date: today,
      tokens_granted: TOKENS_PER_AD,
      ad_unit: body.adUnit ?? null,
      ssv_signature: body.ssvSignature ?? null,
    });

    return new Response(
      JSON.stringify({
        success: true,
        tokensGranted: TOKENS_PER_AD,
        newBalance,
        remainingToday: Math.max(0, DAILY_AD_LIMIT - usedToday - 1),
      } as GrantAdRewardResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("[grant-ad-reward] error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
        errorCode: "unknown",
      } as GrantAdRewardResponse),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
