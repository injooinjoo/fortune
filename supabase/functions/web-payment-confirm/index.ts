import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import {
  validateConfirmedPayment,
  validateConfirmRequest,
} from "../_shared/web_payment_core.ts";

const ALLOWED_ORIGINS = new Set([
  "https://zpzg.co.kr",
  "https://www.zpzg.co.kr",
  "http://localhost:3100",
]);

function headers(req: Request): Record<string, string> {
  const origin = req.headers.get("origin") ?? "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.has(origin) ? origin : "https://zpzg.co.kr",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Content-Type": "application/json; charset=utf-8",
    "Vary": "Origin",
  };
}

function json(req: Request, status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: headers(req) });
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: headers(req) });
  if (req.method !== "POST") return json(req, 405, { error: "METHOD_NOT_ALLOWED" });

  const secretKey = Deno.env.get("TOSS_SECRET_KEY");
  if (Deno.env.get("TOSS_PAYMENTS_ENABLED") !== "true" || !secretKey) {
    return json(req, 503, { error: "PAYMENTS_NOT_READY" });
  }

  const authHeader = req.headers.get("authorization");
  if (!authHeader?.startsWith("Bearer ")) return json(req, 401, { error: "AUTH_REQUIRED" });
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceKey) return json(req, 503, { error: "SERVICE_NOT_READY" });

  const supabase = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: { user }, error: userError } = await supabase.auth.getUser(
    authHeader.slice("Bearer ".length),
  );
  if (userError || !user || user.is_anonymous) {
    return json(req, 401, { error: "LINKED_ACCOUNT_REQUIRED" });
  }

  let confirmation;
  try {
    confirmation = validateConfirmRequest(await req.json());
  } catch {
    return json(req, 400, { error: "INVALID_CONFIRMATION" });
  }

  const { data: order, error: orderError } = await supabase
    .from("web_payment_orders")
    .select("order_id,user_id,amount,status,payment_key,granted_tokens")
    .eq("order_id", confirmation.orderId)
    .eq("user_id", user.id)
    .maybeSingle();
  if (orderError || !order) return json(req, 404, { error: "ORDER_NOT_FOUND" });
  if (order.amount !== confirmation.amount) return json(req, 400, { error: "AMOUNT_MISMATCH" });
  if (order.status === "paid") {
    if (order.payment_key !== confirmation.paymentKey) {
      return json(req, 409, { error: "PAYMENT_REPLAY_MISMATCH" });
    }
    return json(req, 200, {
      paid: true,
      replayed: true,
      orderId: order.order_id,
      grantedTokens: order.granted_tokens,
    });
  }
  if (order.status !== "pending") return json(req, 409, { error: "ORDER_NOT_PENDING" });

  let tossResponse: Response;
  try {
    tossResponse = await fetch("https://api.tosspayments.com/v1/payments/confirm", {
      method: "POST",
      headers: {
        "Authorization": `Basic ${btoa(`${secretKey}:`)}`,
        "Content-Type": "application/json",
        "Idempotency-Key": `confirm:${confirmation.orderId}`,
      },
      body: JSON.stringify(confirmation),
    });
  } catch {
    return json(req, 502, { error: "PAYMENT_CONFIRMATION_UNCERTAIN", retryable: true });
  }

  let tossBody: unknown;
  try {
    tossBody = await tossResponse.json();
  } catch {
    return json(req, 502, { error: "PAYMENT_PROVIDER_INVALID_RESPONSE", retryable: true });
  }

  if (!tossResponse.ok) {
    const providerCode = tossBody && typeof tossBody === "object" &&
        typeof (tossBody as Record<string, unknown>).code === "string"
      ? String((tossBody as Record<string, unknown>).code).slice(0, 80)
      : "TOSS_CONFIRM_FAILED";
    await supabase.from("web_payment_orders").update({
      failure_code: providerCode,
      updated_at: new Date().toISOString(),
    }).eq("order_id", confirmation.orderId).eq("user_id", user.id);
    return json(req, tossResponse.status >= 500 ? 502 : 400, {
      error: "PAYMENT_CONFIRMATION_FAILED",
      retryable: tossResponse.status >= 500,
    });
  }

  let confirmed;
  try {
    confirmed = validateConfirmedPayment(tossBody, confirmation);
  } catch {
    return json(req, 502, { error: "PAYMENT_PROVIDER_MISMATCH", retryable: false });
  }

  const { data: completion, error: completionError } = await supabase.rpc(
    "complete_web_payment_atomic",
    {
      p_user_id: user.id,
      p_order_id: confirmed.orderId,
      p_payment_key: confirmed.paymentKey,
      p_toss_transaction_key: confirmed.transactionKey,
      p_payment_method: confirmed.method,
      p_approved_at: confirmed.approvedAt,
    },
  );
  if (completionError) {
    console.error("[web-payment-confirm] ledger completion failed", completionError.code);
    return json(req, 500, { error: "PAYMENT_LEDGER_PENDING", retryable: true });
  }

  const result = completion as Record<string, unknown>;
  return json(req, 200, {
    paid: true,
    replayed: result.replayed === true,
    orderId: confirmed.orderId,
    grantedTokens: Number(result.granted_tokens ?? 0),
    balance: Number(result.balance ?? 0),
  });
});
