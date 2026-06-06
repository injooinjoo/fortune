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
  { period: "monthly" | "yearly"; days: number; monthlyTokens: number }
> = {
  "com.beyond.fortune.subscription.lite": {
    period: "monthly",
    days: 30,
    monthlyTokens: 200,
  },
  "com.beyond.fortune.subscription.pro": {
    period: "monthly",
    days: 30,
    monthlyTokens: 500,
  },
  "com.beyond.fortune.subscription.max": {
    period: "monthly",
    days: 30,
    monthlyTokens: 2000,
  },
  "com.beyond.fortune.subscription.monthly": {
    period: "monthly",
    days: 30,
    monthlyTokens: 30000,
  },
};

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

    const subscriptionProduct = SUBSCRIPTION_PRODUCTS[productId];
    if (!subscriptionProduct) {
      console.log(`❌ Unsupported subscription product: ${productId}`);
      return new Response(
        JSON.stringify({
          success: false,
          error: "Unsupported subscription product",
          productId,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const clientIP = req.headers.get("x-forwarded-for") ||
      req.headers.get("x-real-ip") ||
      "unknown";

    const { data: activationResult, error: activationError } = await supabase
      .rpc(
        "activate_subscription_purchase_atomic",
        {
          p_user_id: user.id,
          p_product_id: productId,
          p_platform: platform,
          p_purchase_id: purchaseId,
          p_duration_days: subscriptionProduct.days,
          p_monthly_tokens: subscriptionProduct.monthlyTokens,
          p_ip_address: clientIP,
        },
      );

    if (activationError) {
      const details = activationError.message ??
        "Subscription activation failed";
      const isUnverified = details.includes("VERIFIED_PURCHASE_NOT_FOUND");
      const isMismatch = details.includes("VERIFIED_PRODUCT_MISMATCH");
      console.error("❌ Subscription activation RPC failed:", details);

      return new Response(
        JSON.stringify({
          success: false,
          error: isUnverified
            ? "결제 검증되지 않은 구독 — payment-verify-purchase 를 먼저 호출하세요."
            : isMismatch
            ? "Product ID mismatch with verified purchase"
            : "Failed to activate subscription",
          details,
        }),
        {
          status: isUnverified || isMismatch ? 403 : 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.log(`✅ Subscription activated successfully`);
    console.log(`   - Result: ${JSON.stringify(activationResult)}`);

    return new Response(
      JSON.stringify(activationResult),
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
