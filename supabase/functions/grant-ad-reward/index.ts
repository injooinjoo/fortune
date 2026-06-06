// 광고 시청 → 1 토큰 지급. 일일 5회 한도. abuse 방지.
//
// 호출 경로:
// (A) GET   — AdMob 서버가 SSV 콜백으로 직접 호출. ECDSA P-256 서명 검증 후 토큰 지급.
//             user_id 는 query string `custom_data` 에 클라이언트가 ad request 시 주입.
//
// 운영 원칙: RN 클라이언트 POST self-attestation 은 유료 재화에 해당하는 토큰을
// 광고 시청 증명 없이 발급할 수 있으므로 비활성화한다.
//
// 운영 시 AdMob 콘솔의 SSV callback URL 에 이 함수 GET URL 등록:
//   https://hayjukwfcsdmppairazc.supabase.co/functions/v1/grant-ad-reward

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { verifyAdMobSsv } from "./ssv-verify.ts";

const DAILY_AD_LIMIT = 5;
const TOKENS_PER_AD = 1;

interface GrantAdRewardRequest {
  /** 클라이언트 POST self-attestation 은 운영에서 허용하지 않는다. */
  adUnit?: string;
}

interface GrantAdRewardResponse {
  success: boolean;
  tokensGranted?: number;
  newBalance?: number;
  remainingToday?: number;
  duplicate?: boolean;
  error?: string;
  errorCode?:
    | "limit_reached"
    | "unauthorized"
    | "ssv_required"
    | "missing_transaction"
    | "invalid_configuration"
    | "unknown";
}

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}

/** 검증된 AdMob SSV transaction_id 기준으로 토큰을 원자적/멱등 지급한다. */
// deno-lint-ignore no-explicit-any
async function grantTokensForVerifiedSsv(
  supabase: any,
  userId: string,
  metadata: { adUnit?: string | null; transactionId: string },
): Promise<Response> {
  const { data, error } = await supabase.rpc("grant_ad_reward_atomic", {
    p_user_id: userId,
    p_ad_unit: metadata.adUnit ?? null,
    p_transaction_id: metadata.transactionId,
    p_tokens: TOKENS_PER_AD,
    p_daily_limit: DAILY_AD_LIMIT,
  });

  if (error) {
    console.error("[grant-ad-reward] atomic grant failed:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message ?? "ad reward grant failed",
        errorCode: "unknown",
      } as GrantAdRewardResponse),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const response = data as GrantAdRewardResponse;
  const status = response.errorCode === "limit_reached" ? 429 : 200;
  return new Response(JSON.stringify(response), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey) {
    console.error("[grant-ad-reward] missing Supabase service configuration", {
      hasSupabaseUrl: Boolean(supabaseUrl),
      hasServiceRoleKey: Boolean(serviceRoleKey),
    });
    return new Response(
      JSON.stringify({
        success: false,
        error: "Supabase service configuration is missing",
        errorCode: "invalid_configuration",
      } as GrantAdRewardResponse),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
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
      if (!userId || !isUuid(userId)) {
        return new Response(
          JSON.stringify({
            success: false,
            error: !userId
              ? "missing custom_data (user_id)"
              : "invalid custom_data (user_id)",
            errorCode: "unauthorized",
          } as GrantAdRewardResponse),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      const transactionId = result.params?.["transaction_id"];
      if (!transactionId) {
        return new Response(
          JSON.stringify({
            success: false,
            error: "missing AdMob transaction_id",
            errorCode: "missing_transaction",
          } as GrantAdRewardResponse),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      return await grantTokensForVerifiedSsv(supabase, userId, {
        adUnit: result.params?.["ad_unit"] ?? null,
        transactionId,
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

  // === POST: RN 클라이언트 self-attestation 경로 비활성화 ===
  // 유료 재화와 교환 가능한 토큰은 검증된 AdMob SSV GET 콜백에서만 지급한다.
  const body = (await req.json().catch(() => ({}))) as GrantAdRewardRequest;
  console.warn("[grant-ad-reward] blocked client POST self-attestation", {
    adUnit: body.adUnit ?? null,
  });
  return new Response(
    JSON.stringify({
      success: false,
      error: "Ad reward grants require verified AdMob SSV callback",
      errorCode: "ssv_required",
    } as GrantAdRewardResponse),
    {
      status: 403,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});
