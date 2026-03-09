import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  getGeminiGuardSnapshot,
  runGeminiGuardMonitor,
} from "../_shared/llm/safety.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-llm-monitor-secret",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface MonitorRequest {
  dryRun?: boolean;
  healthCheck?: boolean;
}

function getProvidedSecret(req: Request): string {
  const headerSecret = req.headers.get("x-llm-monitor-secret");
  if (headerSecret) {
    return headerSecret;
  }

  const authHeader = req.headers.get("authorization") || "";
  return authHeader.replace(/^Bearer\s+/i, "").trim();
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const configuredSecret = Deno.env.get("LLM_GUARD_MONITOR_SECRET");
  if (!configuredSecret) {
    return new Response(
      JSON.stringify({
        success: false,
        error: "LLM_GUARD_MONITOR_SECRET is not configured",
      }),
      {
        status: 503,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const providedSecret = getProvidedSecret(req);
  if (providedSecret !== configuredSecret) {
    return new Response(
      JSON.stringify({
        success: false,
        error: "Unauthorized",
      }),
      {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  let body: MonitorRequest = {};
  if (req.method === "POST") {
    try {
      body = await req.json();
    } catch {
      body = {};
    }
  }

  if (body.healthCheck) {
    return new Response(
      JSON.stringify({
        success: true,
        severity: "healthy",
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    const snapshot = body.dryRun
      ? await getGeminiGuardSnapshot(undefined, true)
      : await runGeminiGuardMonitor();

    return new Response(
      JSON.stringify({
        success: true,
        provider: "gemini",
        severity: snapshot.severity,
        breachCount: snapshot.breaches.length,
        warningCount: snapshot.warnings.length,
        actions: snapshot.actions,
        snapshot,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : "Unknown monitor error";

    return new Response(
      JSON.stringify({
        success: false,
        error: message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
