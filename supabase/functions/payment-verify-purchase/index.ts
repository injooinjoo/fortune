import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Apple Receipt Validation URLs
const APPLE_PRODUCTION_URL = "https://buy.itunes.apple.com/verifyReceipt";
const APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt";
const GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token";
const GOOGLE_ANDROID_PUBLISHER_BASE_URL =
  "https://androidpublisher.googleapis.com/androidpublisher/v3";
const GOOGLE_ANDROID_PUBLISHER_SCOPE =
  "https://www.googleapis.com/auth/androidpublisher";

// Apple Receipt Status Codes
const APPLE_STATUS = {
  SUCCESS: 0,
  SANDBOX_RECEIPT_IN_PRODUCTION: 21007,
  PRODUCTION_RECEIPT_IN_SANDBOX: 21008,
};

function base64UrlEncode(input: string): string {
  return btoa(input).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function base64UrlEncodeBytes(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(
    /=+$/,
    "",
  );
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const normalizedPem = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");

  const binary = atob(normalizedPem);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}

function getErrorStack(error: unknown): string | undefined {
  if (error instanceof Error) {
    return error.stack;
  }
  return undefined;
}

async function signJwt(
  unsignedToken: string,
  privateKeyPem: string,
): Promise<string> {
  const keyData = pemToArrayBuffer(privateKeyPem);
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsignedToken),
  );

  return base64UrlEncodeBytes(new Uint8Array(signature));
}

function loadGoogleServiceAccountCredentials():
  | { clientEmail: string; privateKey: string }
  | null {
  const jsonCredential = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON") ||
    Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON");

  if (jsonCredential) {
    try {
      const parsed = JSON.parse(jsonCredential);
      const clientEmail = parsed.client_email as string | undefined;
      const privateKeyRaw = parsed.private_key as string | undefined;
      if (clientEmail && privateKeyRaw) {
        return {
          clientEmail,
          privateKey: privateKeyRaw.replace(/\\n/g, "\n"),
        };
      }
    } catch (error) {
      console.error("❌ GOOGLE_PLAY_SERVICE_ACCOUNT_JSON 파싱 실패:", error);
    }
  }

  const clientEmail = Deno.env.get("GOOGLE_PLAY_CLIENT_EMAIL") ||
    Deno.env.get("GOOGLE_CLIENT_EMAIL");
  const privateKeyRaw = Deno.env.get("GOOGLE_PLAY_PRIVATE_KEY") ||
    Deno.env.get("GOOGLE_PRIVATE_KEY");

  if (clientEmail && privateKeyRaw) {
    return {
      clientEmail,
      privateKey: privateKeyRaw.replace(/\\n/g, "\n"),
    };
  }

  return null;
}

async function getGoogleAccessToken(): Promise<string | null> {
  const credentials = loadGoogleServiceAccountCredentials();
  if (!credentials) {
    console.error("❌ Google Play 서비스 계정 환경변수가 없습니다.");
    return null;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = {
    alg: "RS256",
    typ: "JWT",
  };
  const payload = {
    iss: credentials.clientEmail,
    scope: GOOGLE_ANDROID_PUBLISHER_SCOPE,
    aud: GOOGLE_OAUTH_TOKEN_URL,
    iat: now,
    exp: now + 3600,
  };

  try {
    const encodedHeader = base64UrlEncode(JSON.stringify(header));
    const encodedPayload = base64UrlEncode(JSON.stringify(payload));
    const unsignedToken = `${encodedHeader}.${encodedPayload}`;
    const signature = await signJwt(unsignedToken, credentials.privateKey);
    const assertion = `${unsignedToken}.${signature}`;

    const response = await fetch(GOOGLE_OAUTH_TOKEN_URL, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion,
      }),
    });

    const body = await response.json();
    if (!response.ok) {
      console.error("❌ Google OAuth 토큰 발급 실패:", JSON.stringify(body));
      return null;
    }

    return body.access_token as string;
  } catch (error) {
    console.error("❌ Google OAuth 토큰 발급 중 예외:", error);
    return null;
  }
}

async function verifyGooglePlayPurchase(
  packageName: string,
  productId: string,
  purchaseToken: string,
): Promise<{
  isValid: boolean;
  productId?: string;
  orderId?: string;
  environment?: string;
  error?: string;
}> {
  console.log("🤖 Google Play 영수증 검증 시작...");

  const accessToken = await getGoogleAccessToken();
  if (!accessToken) {
    return {
      isValid: false,
      error: "Missing or invalid Google service account credentials",
    };
  }

  const encodedPackage = encodeURIComponent(packageName);
  const encodedProduct = encodeURIComponent(productId);
  const encodedToken = encodeURIComponent(purchaseToken);

  // 1) One-time products
  const productUrl =
    `${GOOGLE_ANDROID_PUBLISHER_BASE_URL}/applications/${encodedPackage}` +
    `/purchases/products/${encodedProduct}/tokens/${encodedToken}`;

  try {
    const productResponse = await fetch(productUrl, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });
    const productResult = await productResponse.json();

    if (productResponse.ok) {
      const purchaseState = Number(productResult.purchaseState ?? -1);
      const isValid = purchaseState === 0;
      console.log(
        `🤖 Product 구매 상태: purchaseState=${purchaseState}, valid=${isValid}`,
      );
      return {
        isValid,
        productId: productResult.productId || productId,
        orderId: productResult.orderId,
        environment: "android-product",
        error: isValid ? undefined : `Invalid purchaseState: ${purchaseState}`,
      };
    }

    console.log(`⚠️ products.get 실패: ${productResponse.status}`);
  } catch (error) {
    console.error("❌ Google products.get 호출 오류:", error);
  }

  // 2) Subscription v2
  const subscriptionV2Url =
    `${GOOGLE_ANDROID_PUBLISHER_BASE_URL}/applications/${encodedPackage}` +
    `/purchases/subscriptionsv2/tokens/${encodedToken}`;

  try {
    const subscriptionResponse = await fetch(subscriptionV2Url, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });
    const subscriptionResult = await subscriptionResponse.json();

    if (subscriptionResponse.ok) {
      const validStates = new Set([
        "SUBSCRIPTION_STATE_ACTIVE",
        "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
      ]);
      const subscriptionState = String(
        subscriptionResult.subscriptionState ?? "",
      );
      const lineItem =
        subscriptionResult.lineItems?.find((item: { productId?: string }) =>
          item?.productId === productId
        ) ||
        subscriptionResult.lineItems?.[0];
      const isValid = validStates.has(subscriptionState);

      console.log(
        `🤖 Subscription 상태: subscriptionState=${subscriptionState}, valid=${isValid}`,
      );
      return {
        isValid,
        productId: lineItem?.productId || productId,
        orderId: subscriptionResult.latestOrderId,
        environment: "android-subscription-v2",
        error: isValid
          ? undefined
          : `Invalid subscriptionState: ${subscriptionState}`,
      };
    }

    console.log(`⚠️ subscriptionsv2.get 실패: ${subscriptionResponse.status}`);
  } catch (error) {
    console.error("❌ Google subscriptionsv2.get 호출 오류:", error);
  }

  // 3) Subscription legacy fallback
  const legacySubscriptionUrl =
    `${GOOGLE_ANDROID_PUBLISHER_BASE_URL}/applications/${encodedPackage}` +
    `/purchases/subscriptions/${encodedProduct}/tokens/${encodedToken}`;

  try {
    const legacyResponse = await fetch(legacySubscriptionUrl, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });
    const legacyResult = await legacyResponse.json();

    if (legacyResponse.ok) {
      const expiryTimeMillis = Number(legacyResult.expiryTimeMillis ?? 0);
      const isValid = expiryTimeMillis > Date.now();
      console.log(
        `🤖 Legacy subscription 상태: expiryTimeMillis=${expiryTimeMillis}, valid=${isValid}`,
      );
      return {
        isValid,
        productId,
        orderId: legacyResult.orderId,
        environment: "android-subscription-legacy",
        error: isValid ? undefined : "Subscription is expired",
      };
    }

    console.log(`⚠️ subscriptions.get 실패: ${legacyResponse.status}`);
  } catch (error) {
    console.error("❌ Google subscriptions.get 호출 오류:", error);
  }

  return {
    isValid: false,
    error: "Google Play verification failed",
  };
}

/**
 * iOS 영수증 검증 (Apple 권장 방식)
 * 1. Production 서버에서 먼저 검증 시도
 * 2. 21007 에러 시 Sandbox 서버로 재시도
 */
type AppleReceiptLineItem = {
  product_id?: string;
  transaction_id?: string;
  original_transaction_id?: string;
  purchase_date_ms?: string;
};

function selectAppleReceiptLineItem(
  validationResult: {
    latest_receipt_info?: AppleReceiptLineItem[];
    receipt?: { in_app?: AppleReceiptLineItem[] };
  },
  requestedProductId: string,
  requestedTransactionId?: string | null,
): AppleReceiptLineItem | null {
  const allItems = [
    ...(validationResult.latest_receipt_info ?? []),
    ...(validationResult.receipt?.in_app ?? []),
  ].filter((item): item is AppleReceiptLineItem => !!item);

  const matchingItems = allItems.filter((item) => {
    if (item.product_id !== requestedProductId) {
      return false;
    }

    if (!requestedTransactionId) {
      return true;
    }

    return item.transaction_id === requestedTransactionId ||
      item.original_transaction_id === requestedTransactionId;
  });

  matchingItems.sort((a, b) => {
    const aDate = Number(a.purchase_date_ms ?? 0);
    const bDate = Number(b.purchase_date_ms ?? 0);
    return bDate - aDate;
  });

  return matchingItems[0] ?? null;
}

async function verifyAppleReceipt(
  receipt: string,
  requestedProductId: string,
  requestedTransactionId?: string | null,
  sharedSecret?: string,
): Promise<{
  isValid: boolean;
  productId?: string;
  transactionId?: string;
  environment?: string;
  error?: string;
}> {
  const requestBody = {
    "receipt-data": receipt,
    ...(sharedSecret && { "password": sharedSecret }),
    "exclude-old-transactions": true,
  };

  const extractVerifiedLine = (
    validationResult: {
      latest_receipt_info?: AppleReceiptLineItem[];
      receipt?: { in_app?: AppleReceiptLineItem[] };
    },
    environment: string,
  ) => {
    const receiptLine = selectAppleReceiptLineItem(
      validationResult,
      requestedProductId,
      requestedTransactionId,
    );

    if (!receiptLine?.product_id || !receiptLine?.transaction_id) {
      return {
        isValid: false,
        environment,
        error:
          "Apple receipt valid, but no line item matched requested product/transaction",
      };
    }

    return {
      isValid: true,
      productId: receiptLine.product_id,
      transactionId: receiptLine.transaction_id,
      environment,
    };
  };

  console.log("🍎 Apple 영수증 검증 시작...");

  // 1. Production 서버에서 먼저 시도
  console.log("🍎 [1/2] Production 서버 검증 시도...");
  try {
    const productionResponse = await fetch(APPLE_PRODUCTION_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(requestBody),
    });

    const productionResult = await productionResponse.json();
    console.log(`🍎 Production 응답 status: ${productionResult.status}`);

    // 성공
    if (productionResult.status === APPLE_STATUS.SUCCESS) {
      console.log("✅ Production 서버 검증 성공!");
      return extractVerifiedLine(productionResult, "production");
    }

    // 2. Sandbox 영수증인 경우 (21007) → Sandbox 서버로 재시도
    if (
      productionResult.status === APPLE_STATUS.SANDBOX_RECEIPT_IN_PRODUCTION
    ) {
      console.log("🍎 [2/2] Sandbox 영수증 감지 → Sandbox 서버로 재시도...");

      const sandboxResponse = await fetch(APPLE_SANDBOX_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(requestBody),
      });

      const sandboxResult = await sandboxResponse.json();
      console.log(`🍎 Sandbox 응답 status: ${sandboxResult.status}`);

      if (sandboxResult.status === APPLE_STATUS.SUCCESS) {
        console.log("✅ Sandbox 서버 검증 성공!");
        return extractVerifiedLine(sandboxResult, "sandbox");
      }

      console.log(`❌ Sandbox 검증 실패: status=${sandboxResult.status}`);
      return {
        isValid: false,
        error: `Sandbox validation failed: ${sandboxResult.status}`,
      };
    }

    // 기타 에러
    console.log(`❌ Production 검증 실패: status=${productionResult.status}`);
    return {
      isValid: false,
      error: `Apple validation failed: ${productionResult.status}`,
    };
  } catch (error) {
    console.error("❌ Apple 서버 통신 오류:", error);
    return {
      isValid: false,
      error: `Network error: ${getErrorMessage(error)}`,
    };
  }
}

/**
 * ============================================================
 * 테이블 참조 (중요!)
 * ============================================================
 * - token_balance (단수!): 토큰 잔액 (balance, total_earned, total_spent)
 * - token_transactions: 토큰 거래 이력 (구매/사용)
 * - subscription_events: 결제 이벤트 로그
 * ============================================================
 */

// 상품별 토큰 수량 매핑 (BM v2.2 + 레거시 복원)
const PRODUCT_TOKENS: Record<string, number> = {
  // BM v2.2 신규 패키지 (Apple Korea tier 정합 — Starter 50→30 으로 축소)
  "com.beyond.fortune.tokens.starter": 30,
  "com.beyond.fortune.tokens.basic": 150,
  "com.beyond.fortune.tokens.popular": 400,
  "com.beyond.fortune.tokens.heavy": 1000,
  // BM v2.2 신규 구독 (월간 보너스 토큰)
  "com.beyond.fortune.subscription.lite": 200,
  "com.beyond.fortune.subscription.pro": 500,
  "com.beyond.fortune.subscription.max": 2000,
  // Legacy 토큰 (restore 시 보조)
  "com.beyond.fortune.tokens10": 10,
  "com.beyond.fortune.tokens50": 50,
  "com.beyond.fortune.tokens100": 100,
  "com.beyond.fortune.tokens200": 200,
  "com.beyond.fortune.points300": 350,
  "com.beyond.fortune.points600": 700,
  "com.beyond.fortune.points1200": 1650,
  "com.beyond.fortune.points3000": 4400,
  // Legacy 구독 (이전 분량 그대로 복원)
  "com.beyond.fortune.subscription.monthly": 30000,
};

// 허용된 product_id 화이트리스트.
// packages/product-contracts/src/products.ts 의 allProductIds 와 동기화 필수.
// 이 목록에 없는 ID 는 결제 검증 단계에서 차단 (DB 오염 방지).
const ALLOWED_PRODUCT_IDS = new Set<string>([
  // BM v2.2 storefront consumables
  "com.beyond.fortune.tokens.starter",
  "com.beyond.fortune.tokens.basic",
  "com.beyond.fortune.tokens.popular",
  "com.beyond.fortune.tokens.heavy",
  // BM v2.2 storefront subscriptions
  "com.beyond.fortune.subscription.lite",
  "com.beyond.fortune.subscription.pro",
  "com.beyond.fortune.subscription.max",
  // Non-consumable
  "com.beyond.fortune.premium_saju_lifetime",
  // Legacy consumables (restore-only)
  "com.beyond.fortune.tokens10",
  "com.beyond.fortune.tokens50",
  "com.beyond.fortune.tokens100",
  "com.beyond.fortune.tokens200",
  "com.beyond.fortune.points300",
  "com.beyond.fortune.points600",
  "com.beyond.fortune.points1200",
  "com.beyond.fortune.points3000",
  // Legacy subscription (restore-only)
  "com.beyond.fortune.subscription.monthly",
]);

serve(async (req) => {
  console.log("========================================");
  console.log("🚀 payment-verify-purchase v20 시작");
  console.log("🍎 Apple 영수증 검증: Production → Sandbox fallback 지원");
  console.log("========================================");

  // CORS preflight
  if (req.method === "OPTIONS") {
    console.log("📌 OPTIONS preflight 요청");
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    console.log(`❌ 잘못된 메소드: ${req.method}`);
    return new Response(
      JSON.stringify({ valid: false, error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    console.log("📥 요청 body 파싱 시작...");
    const body = await req.json();
    // /ultrareview BM P0 #3: raw receipt full-body 로깅 금지. receipt 본문에는
    // Apple/Google transaction 메타가 포함될 수 있어 logs sink 노출 위험.
    // 개별 필드만 안전하게 마킹해서 log.

    const {
      platform,
      productId,
      purchaseToken,
      receipt,
      orderId,
      transactionId,
      packageName,
    } = body;
    console.log(`📦 platform: ${platform}`);
    console.log(`📦 productId: ${productId}`);
    console.log(`📦 purchaseToken: ${purchaseToken ? "있음" : "없음"}`);
    console.log(
      `📦 receipt: ${
        receipt ? "있음 (길이:" + String(receipt).length + ")" : "없음"
      }`,
    );
    console.log(`📦 orderId: ${orderId ? "있음" : "없음"}`);
    console.log(`📦 transactionId: ${transactionId ? "있음" : "없음"}`);
    console.log(`📦 packageName: ${packageName || "없음(기본값 사용 예정)"}`);

    // 필수 파라미터 검증
    if (!platform || !productId) {
      console.log("❌ 필수 파라미터 누락!");
      return new Response(
        JSON.stringify({ valid: false, error: "Missing required parameters" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // product_id 화이트리스트 검증.
    // 정의되지 않은 productId 로 결제 시도 시 차단 (DB 에 87 건 오염 사례 발견됨).
    if (!ALLOWED_PRODUCT_IDS.has(productId)) {
      console.log(`❌ 허용되지 않은 productId: ${productId}`);
      return new Response(
        JSON.stringify({
          valid: false,
          error: "Unknown product_id",
          productId,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    console.log(`🔌 Supabase URL: ${supabaseUrl}`);
    console.log(`🔌 Service Key 존재: ${supabaseServiceKey ? "예" : "아니오"}`);

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });
    console.log("✅ Supabase 클라이언트 생성 완료");

    // 사용자 인증
    let userId: string | null = null;
    const authHeader = req.headers.get("Authorization");
    console.log(`🔐 Authorization 헤더: ${authHeader ? "있음" : "없음"}`);

    if (authHeader) {
      const token = authHeader.replace("Bearer ", "");
      console.log(`🔐 토큰 길이: ${token.length}`);
      console.log("🔐 토큰 본문: [REDACTED]");

      const { data: { user }, error: authError } = await supabase.auth.getUser(
        token,
      );

      if (authError) {
        console.log(`❌ 인증 에러: ${JSON.stringify(authError)}`);
      }

      userId = user?.id || null;
      console.log(`👤 인증된 userId: ${userId}`);
      console.log(
        `👤 user 객체: ${
          user ? JSON.stringify({ id: user.id, email: user.email }) : "null"
        }`,
      );
    } else {
      console.log("⚠️ Authorization 헤더 없음 - 익명 요청");
    }

    console.log(
      `🔍 검증 시작: ${platform}/${productId} for user ${
        userId || "anonymous"
      }`,
    );

    // 플랫폼별 영수증 검증
    let isValid = false;
    let verifiedProductId = productId;
    let verifiedTransactionId = transactionId || orderId;
    let environment = "unknown";

    if (platform === "ios") {
      console.log("📱 iOS 플랫폼 검증");

      if (!receipt) {
        console.error("❌ iOS: receipt 없음 - 검증 불가");
        return new Response(
          JSON.stringify({ valid: false, error: "Missing iOS receipt" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      // Apple App Store 공유 시크릿 (환경 변수에서 로드)
      const appleSharedSecret = Deno.env.get("APPLE_SHARED_SECRET");

      // Apple 영수증 검증 (Production → Sandbox fallback)
      // iOS app receipt can contain many historical IAP rows. Bind the verified
      // row to the product/transaction received from StoreKit before granting.
      const appleResult = await verifyAppleReceipt(
        receipt,
        productId,
        transactionId,
        appleSharedSecret,
      );

      isValid = appleResult.isValid;
      environment = appleResult.environment || "unknown";

      if (appleResult.isValid) {
        verifiedProductId = appleResult.productId || productId;
        verifiedTransactionId = appleResult.transactionId || transactionId;
        console.log(`✅ iOS 검증 성공 (${environment}): ${verifiedProductId}`);
      } else {
        console.error(`❌ iOS 검증 실패: ${appleResult.error}`);
      }
    } else if (platform === "android") {
      console.log("🤖 Android 플랫폼 검증");

      if (!purchaseToken) {
        console.error("❌ Android: purchaseToken 없음 - 검증 불가");
        return new Response(
          JSON.stringify({
            valid: false,
            error: "Missing Android purchase token",
          }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      const targetPackageName = packageName ||
        Deno.env.get("GOOGLE_PLAY_PACKAGE_NAME") || "com.beyond.fortune";
      const androidResult = await verifyGooglePlayPurchase(
        targetPackageName,
        productId,
        purchaseToken,
      );

      isValid = androidResult.isValid;
      environment = androidResult.environment || "android";

      if (androidResult.isValid) {
        verifiedProductId = androidResult.productId || productId;
        verifiedTransactionId = androidResult.orderId || orderId ||
          transactionId || purchaseToken;
        console.log(
          `✅ Android 검증 성공 (${environment}): ${verifiedProductId}`,
        );
      } else {
        console.error(`❌ Android 검증 실패: ${androidResult.error}`);
      }
    } else {
      console.warn(`⚠️ 알 수 없는 플랫폼: ${platform}`);
      isValid = false;
    }

    console.log(
      `✅ 플랫폼 검증 결과: isValid = ${isValid}, environment = ${environment}`,
    );

    // /ultrareview BM P0 #1/#3: verified store transaction is the single
    // truth. Replay is global across app accounts, not per user.
    let alreadyGranted = false;
    let replayOwnedByCurrentUser = true;
    if (userId && isValid && verifiedTransactionId) {
      const { data: existingVerified, error: existingVerifiedErr } =
        await supabase
          .from("verified_purchases")
          .select("user_id")
          .eq("platform", platform)
          .eq("verified_transaction_id", verifiedTransactionId)
          .limit(1)
          .maybeSingle();

      if (existingVerifiedErr) {
        console.warn(
          `⚠️ verified_purchases replay 체크 실패: ${existingVerifiedErr.message}`,
        );
      }

      if (existingVerified) {
        alreadyGranted = true;
        replayOwnedByCurrentUser = existingVerified.user_id === userId;
        console.log(
          `🔁 verifiedTransactionId=${verifiedTransactionId} 는 이미 검증됨 — owner=current? ${replayOwnedByCurrentUser}`,
        );
      }

      if (!existingVerified) {
        const { error: vpInsertErr } = await supabase
          .from("verified_purchases")
          .insert({
            user_id: userId,
            platform,
            verified_product_id: verifiedProductId,
            verified_transaction_id: verifiedTransactionId,
            environment,
          });
        // duplicate key error 는 replay 로 취급. Global UNIQUE 가 최종 방어선.
        if (vpInsertErr) {
          if (vpInsertErr.message?.includes("duplicate")) {
            alreadyGranted = true;
            console.log(
              `🔁 verified_purchases global UNIQUE hit — replay로 처리`,
            );
          } else {
            console.warn(
              `⚠️ verified_purchases insert 실패: ${vpInsertErr.message}`,
            );
          }
        }
      }
    }

    // /ultrareview BM P0 #3: verified productId (Apple/Google 응답) 사용.
    // 이전엔 클라가 보낸 productId 로 토큰 지급 → 낮은 가격 receipt 로 비싼 product
    // 요청 시 비싼 양 지급되는 mismatch 공격 가능했음.
    const tokensToAdd = PRODUCT_TOKENS[verifiedProductId] || 0;
    console.log(
      `💰 추가할 토큰 수: ${tokensToAdd} (verifiedProductId: ${verifiedProductId}, requestedProductId: ${productId})`,
    );
    if (verifiedProductId !== productId) {
      console.warn(
        `⚠️ verifiedProductId 와 requestedProductId 불일치 — verified 기준으로 지급`,
      );
    }

    // 첫 구매 보너스 관련 변수 (응답에서도 사용)
    let actualTokensToAdd = tokensToAdd;
    let bonusTokens = 0;
    let isFirstPurchase = false;
    let newBalance: number | null = null;

    if (!userId) {
      console.log("⚠️ userId가 없어서 토큰 추가 건너뜀");
    }
    if (!isValid) {
      console.log("⚠️ isValid=false 라서 토큰 추가 건너뜀");
    }
    if (tokensToAdd <= 0) {
      console.log(`⚠️ tokensToAdd=${tokensToAdd} 라서 토큰 추가 건너뜀`);
    }
    if (alreadyGranted) {
      console.log(
        `⚠️ alreadyGranted=true (이전에 같은 store transaction 처리됨) — 토큰 추가 건너뜀`,
      );
    }

    if (userId && isValid && tokensToAdd > 0 && !alreadyGranted) {
      console.log("========================================");
      console.log("💰 Atomic 토큰 구매 지급 시작");
      console.log("========================================");

      const purchaseDescription = `토큰 ${tokensToAdd}개 구매`;
      const { data: grantResult, error: grantError } = await supabase.rpc(
        "grant_purchase_tokens_atomic",
        {
          p_user_id: userId,
          p_base_amount: tokensToAdd,
          p_description: purchaseDescription,
          p_reference_type: "in_app_purchase",
          p_reference_id: verifiedTransactionId,
          p_idempotency_key: verifiedTransactionId
            ? `purchase:${platform}:${verifiedTransactionId}`
            : null,
        },
      );

      if (grantError) {
        console.error(
          `❌ Atomic 토큰 구매 지급 실패: ${grantError.message}`,
        );
        throw grantError;
      }

      const grant = grantResult as {
        balance?: number;
        granted?: boolean;
        replayed?: boolean;
        owned_by_current_user?: boolean;
        tokens_added?: number;
        base_tokens?: number;
        bonus_tokens?: number;
        is_first_purchase?: boolean;
      };

      alreadyGranted = grant.replayed === true;
      replayOwnedByCurrentUser = grant.owned_by_current_user !== false;
      actualTokensToAdd = Number(grant.tokens_added ?? tokensToAdd);
      bonusTokens = Number(grant.bonus_tokens ?? 0);
      isFirstPurchase = grant.is_first_purchase === true;
      newBalance = typeof grant.balance === "number" ? grant.balance : null;

      if (!replayOwnedByCurrentUser) {
        return new Response(
          JSON.stringify({
            valid: false,
            error: "Purchase transaction already linked to another account",
            productId: verifiedProductId,
            transactionId: verifiedTransactionId,
            platform,
            environment,
          }),
          {
            status: 409,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          },
        );
      }

      console.log(
        `✅ Atomic 토큰 구매 지급 완료: granted=${grant.granted}, replayed=${grant.replayed}, tokensAdded=${actualTokensToAdd}, balance=${newBalance}`,
      );

      // 이벤트 로깅
      console.log("📊 이벤트 로깅 시작...");
      const eventData = {
        user_id: userId,
        event_type: "purchase_verified",
        product_id: verifiedProductId,
        platform,
        purchase_id: verifiedTransactionId,
        metadata: {
          requested_product_id: productId,
          tokens_added: actualTokensToAdd,
          base_tokens: tokensToAdd,
          bonus_tokens: bonusTokens,
          is_first_purchase: isFirstPurchase,
          new_balance: newBalance,
        },
      };

      const { error: eventError } = await supabase
        .from("subscription_events")
        .insert(eventData);

      console.log(
        `📊 이벤트 로깅 결과: ${
          eventError ? JSON.stringify(eventError) : "성공"
        }`,
      );

      console.log("========================================");
      console.log("✅ 토큰 추가 프로세스 완료");
      console.log("========================================");
    } else if (!replayOwnedByCurrentUser) {
      return new Response(
        JSON.stringify({
          valid: false,
          error: "Purchase transaction already linked to another account",
          productId: verifiedProductId,
          transactionId: verifiedTransactionId,
          platform,
          environment,
        }),
        {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 응답 데이터에 보너스 정보 포함
    const responseData = {
      valid: isValid,
      productId: verifiedProductId,
      transactionId: verifiedTransactionId,
      platform,
      environment,
      tokensAdded: isValid ? actualTokensToAdd : 0,
      bonusTokens: bonusTokens,
      isFirstPurchase: isFirstPurchase,
      verifiedAt: new Date().toISOString(),
    };
    console.log("📤 응답 데이터:", JSON.stringify(responseData, null, 2));
    console.log("========================================");
    console.log("🏁 payment-verify-purchase 종료");
    console.log("========================================");

    return new Response(
      JSON.stringify(responseData),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("========================================");
    console.error("❌ 치명적 오류 발생!");
    console.error("========================================");
    console.error("❌ 에러:", error);
    console.error("❌ 에러 메시지:", getErrorMessage(error));
    console.error("❌ 에러 스택:", getErrorStack(error));
    return new Response(
      JSON.stringify({
        valid: false,
        error: "Verification failed",
        details: getErrorMessage(error),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
