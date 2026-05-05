// 광고 시청 → 1 토큰 지급. 일일 5회 한도. abuse 방지.
//
// 두 가지 호출 경로:
// (A) GET   — AdMob 서버가 SSV 콜백으로 직접 호출. ECDSA P-256 서명 검증 후 토큰 지급.
//             user_id 는 query string `custom_data` 에 클라이언트가 ad request 시 주입.
// (B) POST  — RN 클라이언트가 광고 시청 완료 후 호출 (self-attestation, fallback).
//             SSV 가 활성화되면 (B) 는 비활성화 권장.
//
// 운영 시 AdMob 콘솔의 SSV callback URL 에 이 함수 GET URL 등록:
//   https://hayjukwfcsdmppairazc.supabase.co/functions/v1/grant-ad-reward

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { authenticateUser } from "../_shared/auth.ts";
import { verifyAdMobSsv } from "./ssv-verify.ts";

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

/** 토큰 지급 + 한도 체크 공통 로직. SSV (GET) / 클라이언트 (POST) 둘 다 사용. */
// deno-lint-ignore no-explicit-any
async function grantTokensForUser(
  supabase: any,
  userId: string,
  metadata: { adUnit?: string | null; ssvSignature?: string | null },
): Promise<Response> {
  const today = new Date().toISOString().split("T")[0];
  const { count: todayCount } = await supabase
    .from("ad_reward_log")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
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

  const { data: tokenData } = await supabase
    .from("token_balance")
    .select("balance, total_earned")
    .eq("user_id", userId)
    .maybeSingle();

  const balanceBefore = tokenData?.balance ?? 0;
  const totalEarned = tokenData?.total_earned ?? 0;
  const newBalance = balanceBefore + TOKENS_PER_AD;

  await supabase.from("token_balance").upsert(
    {
      user_id: userId,
      balance: newBalance,
      total_earned: totalEarned + TOKENS_PER_AD,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  await supabase.from("token_transactions").insert({
    user_id: userId,
    transaction_type: "earn",
    amount: TOKENS_PER_AD,
    balance_after: newBalance,
    description: "광고 시청 보상",
    reference_type: "ad_reward",
  });

  await supabase.from("ad_reward_log").insert({
    user_id: userId,
    reward_date: today,
    tokens_granted: TOKENS_PER_AD,
    ad_unit: metadata.adUnit ?? null,
    ssv_signature: metadata.ssvSignature ?? null,
  });

  return new Response(
    JSON.stringify({
      success: true,
      tokensGranted: TOKENS_PER_AD,
      newBalance,
      remainingToday: Math.max(0, DAILY_AD_LIMIT - usedToday - 1),
    } as GrantAdRewardResponse),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // === GET: AdMob SSV 콜백 경로 ===
  // AdMob 콘솔의 ad unit 설정에서 이 함수 URL 을 SSV callback 으로 등록하면
  // 광고 시청 완료 시 Google 서버가 GET 요청 + signature query string 으로 호출.
  if (req.method === "GET") {
    try {
      const result = await verifyAdMobSsv(req.url);
      if (!result.valid) {
        console.warn(
          "[grant-ad-reward] SSV verification failed:",
          result.reason,
        );
        return new Response(
          JSON.stringify({ success: false, error: result.reason }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      // AdMob 가 ad request 시 클라이언트가 주입한 custom_data 에서 user_id 추출.
      // RN 클라이언트는 useRewardedAd 호출 시 customData=user_id 로 전달해야 함.
      const userId = result.params?.["custom_data"] ??
        result.params?.["user_id"];
      if (!userId) {
        return new Response(
          JSON.stringify({
            success: false,
            error: "missing custom_data (user_id)",
          }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      return await grantTokensForUser(supabase, userId, {
        adUnit: result.params?.["ad_unit"] ?? null,
        ssvSignature: result.params?.["transaction_id"] ?? null,
      });
    } catch (err) {
      console.error("[grant-ad-reward] SSV error:", err);
      return new Response(
        JSON.stringify({
          success: false,
          error: err instanceof Error ? err.message : "unknown",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
  }

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

  // === POST: RN 클라이언트 self-attestation 경로 (fallback) ===
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

    return await grantTokensForUser(supabase, user.id, {
      adUnit: body.adUnit ?? null,
      ssvSignature: body.ssvSignature ?? null,
    });
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
