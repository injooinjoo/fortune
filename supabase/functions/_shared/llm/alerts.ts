import {
  createClient,
  type SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import { sendPushToUser } from "../notification_push.ts";
import { GcpLoggingService } from "../monitoring/gcp-logging.ts";

export type LlmGuardAlertSeverity = "warning" | "critical" | "info";

export interface LlmGuardAlertParams {
  severity: LlmGuardAlertSeverity;
  title: string;
  message: string;
  provider: string;
  model?: string;
  featureName?: string;
  thresholdCode?: string;
  metadata?: Record<string, unknown>;
}

let supabaseClient: SupabaseClient | null = null;

function isTruthy(value: string | null | undefined): boolean {
  if (!value) return false;

  const normalized = value.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" ||
    normalized === "on";
}

function getSupabaseClient(): SupabaseClient {
  if (supabaseClient) {
    return supabaseClient;
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY is missing");
  }

  supabaseClient = createClient(supabaseUrl, serviceRoleKey);
  return supabaseClient;
}

function buildSlackPayload(params: LlmGuardAlertParams) {
  const color = params.severity === "critical"
    ? "#d92d20"
    : params.severity === "warning"
    ? "#f79009"
    : "#1570ef";

  return {
    attachments: [
      {
        color,
        blocks: [
          {
            type: "header",
            text: {
              type: "plain_text",
              text: params.title,
              emoji: false,
            },
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: params.message,
            },
          },
          {
            type: "section",
            fields: [
              {
                type: "mrkdwn",
                text: `*Provider:*\n\`${params.provider}\``,
              },
              {
                type: "mrkdwn",
                text: `*Severity:*\n\`${params.severity}\``,
              },
              {
                type: "mrkdwn",
                text: `*Feature:*\n\`${params.featureName || "llm-guard"}\``,
              },
              {
                type: "mrkdwn",
                text: `*Threshold:*\n\`${params.thresholdCode || "n/a"}\``,
              },
            ],
          },
        ],
      },
    ],
  };
}

async function postWebhookAlert(
  webhookUrl: string,
  params: LlmGuardAlertParams,
): Promise<void> {
  const isSlackWebhook = webhookUrl.includes("hooks.slack.com");
  const body = isSlackWebhook ? buildSlackPayload(params) : {
    severity: params.severity,
    title: params.title,
    message: params.message,
    provider: params.provider,
    model: params.model,
    featureName: params.featureName,
    thresholdCode: params.thresholdCode,
    metadata: params.metadata || {},
    timestamp: new Date().toISOString(),
  };

  const response = await fetch(webhookUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const responseText = await response.text();
    throw new Error(
      `Webhook alert failed: ${response.status} ${
        responseText.substring(0, 300)
      }`,
    );
  }
}

async function sendPushAlert(params: LlmGuardAlertParams): Promise<void> {
  if (!isTruthy(Deno.env.get("LLM_GUARD_PUSH_ALERTS_ENABLED"))) {
    return;
  }

  const adminUserId = Deno.env.get("LLM_GUARD_ALERT_ADMIN_USER_ID");
  if (!adminUserId) {
    return;
  }

  const supabase = getSupabaseClient();
  await sendPushToUser(supabase, adminUserId, {
    userId: adminUserId,
    title: params.title,
    body: params.message,
    data: {
      type: "llm_guard_alert",
      provider: params.provider,
      severity: params.severity,
      threshold_code: params.thresholdCode || "",
      route: "/profile/notifications",
    },
  });
}

export async function sendLlmGuardAlert(
  params: LlmGuardAlertParams,
): Promise<void> {
  const webhookUrl = Deno.env.get("LLM_GUARD_ALERT_WEBHOOK_URL");

  try {
    if (webhookUrl) {
      await postWebhookAlert(webhookUrl, params);
    }

    await sendPushAlert(params);
  } catch (error) {
    console.error("[llm_guard_alert] Alert delivery failed:", error);
  }

  await GcpLoggingService.log({
    eventType: "llm_guard_alert",
    functionName: params.featureName || "llm-guard",
    provider: params.provider,
    model: params.model,
    success: params.severity !== "critical",
    errorMessage: params.message,
    metadata: {
      severity: params.severity,
      thresholdCode: params.thresholdCode,
      ...params.metadata,
    },
  });
}
