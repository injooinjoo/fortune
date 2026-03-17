import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { authenticateUser } from "../_shared/auth.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

interface NotificationPreferencesPayload {
  enabled?: boolean;
  dailyFortune?: boolean;
  tokenAlert?: boolean;
  promotion?: boolean;
  characterDm?: boolean;
  dailyFortuneTime?: string | null;
}

interface SyncNotificationDeviceRequest {
  token?: string;
  platform?: "ios" | "android" | "web";
  deviceInfo?: Record<string, unknown>;
  preferences?: NotificationPreferencesPayload;
  deactivateToken?: boolean;
}

function buildBadRequest(message: string, status = 400): Response {
  return new Response(
    JSON.stringify({ success: false, error: message }),
    {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
}

function parsePreferredHour(
  dailyFortuneTime?: string | null,
): number | undefined {
  if (!dailyFortuneTime) return undefined;

  const [rawHour] = dailyFortuneTime.split(":");
  const hour = Number(rawHour);
  if (Number.isNaN(hour) || hour < 0 || hour > 23) {
    return undefined;
  }

  return hour;
}

serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) {
    return corsResponse;
  }

  if (req.method !== "POST") {
    return buildBadRequest("Method not allowed", 405);
  }

  const authResult = await authenticateUser(req);
  if (authResult.error) {
    return authResult.error;
  }

  const user = authResult.user;
  if (!user) {
    return buildBadRequest("Authentication required", 401);
  }

  let body: SyncNotificationDeviceRequest;
  try {
    body = await req.json();
  } catch {
    return buildBadRequest("Invalid JSON body");
  }

  const token = body.token?.trim();
  if (!token) {
    return buildBadRequest("token is required");
  }

  const platform = body.platform;
  if (platform !== "ios" && platform !== "android" && platform !== "web") {
    return buildBadRequest("platform must be ios, android, or web");
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const deactivatedAt = new Date().toISOString();
  const { error: deactivateError } = await supabase
    .from("fcm_tokens")
    .update({
      is_active: false,
      updated_at: deactivatedAt,
    })
    .eq("token", token)
    .eq("is_active", true);

  if (deactivateError) {
    console.error(
      "[sync-notification-device] 기존 토큰 비활성화 실패:",
      deactivateError,
    );
    return buildBadRequest("Failed to deactivate existing token", 500);
  }

  if (body.deactivateToken == true) {
    return new Response(
      JSON.stringify({
        success: true,
        deactivated: true,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const now = new Date().toISOString();
  const { error: tokenUpsertError } = await supabase
    .from("fcm_tokens")
    .upsert(
      {
        user_id: user.id,
        token,
        platform,
        device_info: body.deviceInfo ?? {},
        is_active: true,
        updated_at: now,
      },
      {
        onConflict: "user_id,token",
      },
    );

  if (tokenUpsertError) {
    console.error(
      "[sync-notification-device] fcm_tokens upsert 실패:",
      tokenUpsertError,
    );
    return buildBadRequest("Failed to upsert device token", 500);
  }

  const preferencesPayload = body.preferences;
  if (preferencesPayload != null) {
    const preferredHour = parsePreferredHour(
      preferencesPayload.dailyFortuneTime,
    );
    const preferenceRow: Record<string, unknown> = {
      user_id: user.id,
    };

    if (preferencesPayload.enabled != null) {
      preferenceRow["enabled"] = preferencesPayload.enabled;
    }
    if (preferencesPayload.dailyFortune != null) {
      preferenceRow["daily_fortune"] = preferencesPayload.dailyFortune;
    }
    if (preferencesPayload.tokenAlert != null) {
      preferenceRow["token_alert"] = preferencesPayload.tokenAlert;
    }
    if (preferencesPayload.promotion != null) {
      preferenceRow["promotion"] = preferencesPayload.promotion;
    }
    if (preferencesPayload.characterDm != null) {
      preferenceRow["character_dm"] = preferencesPayload.characterDm;
    }
    if (preferredHour != null) {
      preferenceRow["preferred_hour"] = preferredHour;
    }

    const { error: preferenceUpsertError } = await supabase
      .from("user_notification_preferences")
      .upsert(preferenceRow, {
        onConflict: "user_id",
      });

    if (preferenceUpsertError) {
      console.error(
        "[sync-notification-device] user_notification_preferences upsert 실패:",
        preferenceUpsertError,
      );
      return buildBadRequest("Failed to upsert notification preferences", 500);
    }
  }

  return new Response(
    JSON.stringify({
      success: true,
      deactivated: false,
      preferencesUpdated: preferencesPayload != null,
    }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});
