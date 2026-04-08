import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { FORTUNE_TOKEN_COSTS } from "../_shared/types.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/**
 * 토큰 환불 Edge Function
 *
 * POST /soul-refund
 * Body: { fortuneType: string, referenceId?: string, reason?: string }
 *
 * 운세 생성 실패 시 선차감된 토큰을 환불합니다.
 *
 * Response:
 * {
 *   "balance": {
 *     "totalTokens": 500,
 *     "usedTokens": 14,
 *     "remainingTokens": 486,
 *     "lastUpdated": "2025-12-21T10:00:00Z",
 *     "hasUnlimitedAccess": false
 *   }
 * }
 */
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  // POST only
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    // Auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "No authorization" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Body
    const body = await req.json();
    const { fortuneType, reason, referenceId } = body;

    if (!fortuneType) {
      return new Response(JSON.stringify({ error: "Missing fortuneType" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(
      `🔄 Soul refund request: fortuneType=${fortuneType}, referenceId=${referenceId}, reason=${reason}`,
    );

    // Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // User
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser(token);

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Authentication failed" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(`👤 User: ${user.id}`);

    // 1. 구독 유저는 환불 불필요 (토큰 차감 안됨)
    const { data: subscription } = await supabase
      .from("subscriptions")
      .select("id")
      .eq("user_id", user.id)
      .eq("status", "active")
      .gt("expires_at", new Date().toISOString())
      .limit(1)
      .maybeSingle();

    if (subscription) {
      console.log(`⏭️ Subscriber — no refund needed`);
      // 현재 잔액 조회하여 반환
      const { data: tokenData } = await supabase
        .from("token_balance")
        .select("balance, total_earned, total_spent")
        .eq("user_id", user.id)
        .single();

      return new Response(
        JSON.stringify({
          balance: {
            totalTokens: tokenData?.total_earned ?? 0,
            usedTokens: tokenData?.total_spent ?? 0,
            remainingTokens: tokenData?.balance ?? 0,
            lastUpdated: new Date().toISOString(),
            hasUnlimitedAccess: true,
          },
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 2. 현재 잔액 조회
    const { data: tokenData } = await supabase
      .from("token_balance")
      .select("balance, total_earned, total_spent")
      .eq("user_id", user.id)
      .single();

    const currentBalance = tokenData?.balance ?? 0;
    const totalEarned = tokenData?.total_earned ?? 0;
    const totalSpent = tokenData?.total_spent ?? 0;

    let refundAmount =
      FORTUNE_TOKEN_COSTS[fortuneType as keyof typeof FORTUNE_TOKEN_COSTS] ?? 1;

    if (referenceId) {
      const { data: existingRefund } = await supabase
        .from("token_transactions")
        .select("id")
        .eq("user_id", user.id)
        .eq("transaction_type", "refund")
        .eq("reference_type", "fortune_refund")
        .eq("reference_id", referenceId)
        .limit(1)
        .maybeSingle();

      if (existingRefund) {
        console.log(
          `⏭️ Refund already processed for referenceId=${referenceId}`,
        );
        return new Response(
          JSON.stringify({
            balance: {
              totalTokens: totalEarned,
              usedTokens: totalSpent,
              remainingTokens: currentBalance,
              lastUpdated: new Date().toISOString(),
              hasUnlimitedAccess: false,
            },
            alreadyRefunded: true,
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      const { data: consumeTx } = await supabase
        .from("token_transactions")
        .select("amount")
        .eq("user_id", user.id)
        .eq("transaction_type", "consumption")
        .eq("reference_type", "fortune")
        .eq("reference_id", referenceId)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      const matchedConsumeAmount =
        typeof consumeTx?.amount === "number"
          ? Math.abs(consumeTx.amount)
          : Number.isFinite(Number(consumeTx?.amount))
            ? Math.abs(Number(consumeTx?.amount))
            : null;

      if (matchedConsumeAmount && matchedConsumeAmount > 0) {
        refundAmount = matchedConsumeAmount;
      } else {
        console.log(
          `⏭️ No matching consumption found for referenceId=${referenceId}`,
        );
        return new Response(
          JSON.stringify({
            balance: {
              totalTokens: totalEarned,
              usedTokens: totalSpent,
              remainingTokens: currentBalance,
              lastUpdated: new Date().toISOString(),
              hasUnlimitedAccess: false,
            },
            refunded: false,
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
    }

    // 3. 잔액 복구
    const newBalance = currentBalance + refundAmount;
    const newTotalSpent = Math.max(0, totalSpent - refundAmount);

    const { error: updateError } = await supabase.from("token_balance").upsert(
      {
        user_id: user.id,
        balance: newBalance,
        total_earned: totalEarned,
        total_spent: newTotalSpent,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "user_id" },
    );

    if (updateError) {
      console.error(`❌ Refund balance update failed: ${updateError.message}`);
      return new Response(
        JSON.stringify({ error: "Failed to refund tokens" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 4. 환불 거래 이력 기록
    const { error: txError } = await supabase
      .from("token_transactions")
      .insert({
        user_id: user.id,
        transaction_type: "refund",
        amount: refundAmount,
        balance_after: newBalance,
        description: `${fortuneType} 환불 (${reason || "fortune_generation_failed"})`,
        reference_type: "fortune_refund",
        reference_id: referenceId || null,
      });

    if (txError) {
      console.error(`⚠️ Refund transaction record failed: ${txError.message}`);
    }

    console.log(
      `✅ Token refunded: ${currentBalance} → ${newBalance} (refund: ${refundAmount})`,
    );

    return new Response(
      JSON.stringify({
        balance: {
          totalTokens: totalEarned,
          usedTokens: newTotalSpent,
          remainingTokens: newBalance,
          lastUpdated: new Date().toISOString(),
          hasUnlimitedAccess: false,
        },
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("❌ Soul refund error:", error);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
