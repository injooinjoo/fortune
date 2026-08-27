import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { getWebPaymentProduct } from "../_shared/web_payment_core.ts";

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

  if (Deno.env.get("TOSS_PAYMENTS_ENABLED") !== "true" || !Deno.env.get("TOSS_SECRET_KEY")) {
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

  try {
    const body = await req.json();
    const product = getWebPaymentProduct((body as Record<string, unknown>).productId);
    const orderId = `ondo_${crypto.randomUUID()}`;
    const { error } = await supabase.from("web_payment_orders").insert({
      order_id: orderId,
      user_id: user.id,
      product_id: product.id,
      order_name: product.name,
      amount: product.amount,
      base_tokens: product.tokens,
    });
    if (error) {
      console.error("[web-payment-create-order] order insert failed", error.code);
      return json(req, 500, { error: "ORDER_CREATE_FAILED" });
    }
    return json(req, 200, {
      orderId,
      orderName: product.name,
      amount: product.amount,
      productId: product.id,
      tokens: product.tokens,
    });
  } catch (error) {
    if (error instanceof TypeError) return json(req, 400, { error: "INVALID_PRODUCT" });
    console.error("[web-payment-create-order] unexpected failure");
    return json(req, 500, { error: "ORDER_CREATE_FAILED" });
  }
});
