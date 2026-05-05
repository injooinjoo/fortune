import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// 구독 상품 정보
const SUBSCRIPTION_PRODUCTS: Record<
  string,
  { period: "monthly" | "yearly"; days: number }
> = {
  "com.beyond.fortune.subscription.monthly": { period: "monthly", days: 30 },
  "com.beyond.fortune.subscription.yearly": { period: "yearly", days: 365 },
  "com.beyond.fortune.subscription.max": { period: "monthly", days: 30 },
};

/**
 * 구독 기간 계산
 */
function calculateExpiryDate(productId: string, fromDate?: Date): Date {
  const now = fromDate || new Date();
  const product = SUBSCRIPTION_PRODUCTS[productId];

  if (!product) {
    // 알 수 없는 상품은 기본 30일
    console.warn(`⚠️ Unknown product ID: ${productId}, defaulting to 30 days`);
    return new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
  }

  return new Date(now.getTime() + product.days * 24 * 60 * 60 * 1000);
}

/**
 * 구독 활성화 Edge Function
 *
 * POST /subscription/activate
 *
 * Request Body:
 * - productId: string (구독 상품 ID)
 * - purchaseId: string (스토어 거래 ID)
 * - platform: 'ios' | 'android' | 'web'
 *
 * Response:
 * - { success: boolean, expiresAt?: string, error?: string }
 */
serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  // POST 요청만 허용
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ success: false, error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    // 요청 바디 파싱
    const body = await req.json();
    const { productId, purchaseId, platform } = body;

    // 필수 파라미터 검증.
    // /ultrareview BM P0 #1: purchaseId (Apple/Google verified transaction id) 필수.
    // 이 id 로 verified_purchases 테이블 lookup → payment-verify-purchase 가 미리
    // 등록한 row 가 없으면 거부. 클라가 productId 만 들고 임의 활성화하던 경로 차단.
    if (!productId || !platform || !purchaseId) {
      console.log("❌ Missing required parameters");
      return new Response(
        JSON.stringify({
          success: false,
          error: "Missing required parameters: productId, platform, purchaseId",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 인증 토큰 추출
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      console.log("❌ No authorization header");
      return new Response(
        JSON.stringify({ success: false, error: "No authorization" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // JWT에서 사용자 ID 추출
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabase.auth.getUser(
      token,
    );

    if (userError || !user) {
      console.log("❌ User authentication failed:", userError?.message);
      return new Response(
        JSON.stringify({ success: false, error: "Authentication failed" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.log(`🔑 Activating subscription for user: ${user.id}`);
    console.log(`   - Product: ${productId}`);
    console.log(`   - Platform: ${platform}`);
    console.log(`   - Purchase ID: ${purchaseId}`);

    // /ultrareview BM P0 #1: verified_purchases 에 정합한 row 가 있는지 확인.
    // payment-verify-purchase 가 Apple/Google 검증 통과 후 INSERT 한 row 만 매치됨.
    // - user_id 동일 (JWT 에서 추출)
    // - platform 동일
    // - verified_transaction_id 동일 (purchaseId)
    // - verified_product_id == productId (mismatch 차단)
    // - 아직 subscription 활성화에 사용 안 됨 (consumed_for_subscription = false)
    const { data: vp, error: vpErr } = await supabase
      .from("verified_purchases")
      .select("id, verified_product_id, consumed_for_subscription")
      .eq("user_id", user.id)
      .eq("platform", platform)
      .eq("verified_transaction_id", purchaseId)
      .maybeSingle();
    if (vpErr) {
      console.error("❌ verified_purchases lookup 실패:", vpErr.message);
      return new Response(
        JSON.stringify({
          success: false,
          error: "Verified purchase lookup failed",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    if (!vp) {
      console.log(
        `❌ verified_purchases row 없음 — 결제 미검증 또는 위조 시도. user=${user.id} txn=${purchaseId}`,
      );
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "결제 검증되지 않은 구독 — payment-verify-purchase 를 먼저 호출하세요.",
        }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    if (vp.verified_product_id !== productId) {
      console.log(
        `❌ productId mismatch — verified=${vp.verified_product_id} requested=${productId}`,
      );
      return new Response(
        JSON.stringify({
          success: false,
          error: "Product ID mismatch with verified purchase",
        }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    if (vp.consumed_for_subscription) {
      console.log(
        `🔁 verified_purchases 이미 subscription 활성화에 사용됨 — replay`,
      );
      return new Response(
        JSON.stringify({
          success: false,
          error: "Subscription already activated for this transaction",
        }),
        {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 1. 기존 활성 구독 만료 처리
    const { error: expireError } = await supabase
      .from("subscriptions")
      .update({
        status: "expired",
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", user.id)
      .eq("status", "active");

    if (expireError) {
      console.warn("⚠️ Error expiring old subscriptions:", expireError.message);
      // 계속 진행 (기존 구독이 없을 수도 있음)
    }

    // 2. 만료일 계산
    const expiresAt = calculateExpiryDate(productId);

    // 3. 새 구독 생성
    const { data: subscription, error: insertError } = await supabase
      .from("subscriptions")
      .insert({
        user_id: user.id,
        product_id: productId,
        platform,
        purchase_id: purchaseId || null,
        status: "active",
        started_at: new Date().toISOString(),
        expires_at: expiresAt.toISOString(),
        auto_renewing: true,
      })
      .select("id")
      .single();

    if (insertError) {
      console.error("❌ Error creating subscription:", insertError.message);
      return new Response(
        JSON.stringify({
          success: false,
          error: "Failed to create subscription",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // /ultrareview BM P0 #1: verified_purchases 의 consumed_for_subscription
    // 마킹 — 같은 transaction id 로 두 번 활성화 못 하도록.
    const { error: vpUpdateErr } = await supabase
      .from("verified_purchases")
      .update({ consumed_for_subscription: true })
      .eq("id", vp.id);
    if (vpUpdateErr) {
      console.warn(
        `⚠️ verified_purchases consume 마킹 실패 (계속 진행): ${vpUpdateErr.message}`,
      );
    }

    // 4. 이벤트 로깅
    const clientIP = req.headers.get("x-forwarded-for") ||
      req.headers.get("x-real-ip") ||
      "unknown";

    await supabase.from("subscription_events").insert({
      user_id: user.id,
      subscription_id: subscription.id,
      event_type: "activated",
      product_id: productId,
      platform,
      purchase_id: purchaseId,
      ip_address: clientIP,
      metadata: {
        activated_at: new Date().toISOString(),
        expires_at: expiresAt.toISOString(),
      },
    });

    console.log(`✅ Subscription activated successfully`);
    console.log(`   - Subscription ID: ${subscription.id}`);
    console.log(`   - Expires: ${expiresAt.toISOString()}`);

    return new Response(
      JSON.stringify({
        success: true,
        subscriptionId: subscription.id,
        expiresAt: expiresAt.toISOString(),
        productId,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("❌ Subscription activation error:", error);
    return new Response(
      JSON.stringify({ success: false, error: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
