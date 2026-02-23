// Google Cloud Logging helper
// Writes structured usage/audit logs so API call patterns can be inspected in GCP.

const GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token";
const GOOGLE_LOGGING_API_URL =
  "https://logging.googleapis.com/v2/entries:write";
const GOOGLE_LOGGING_SCOPE = "https://www.googleapis.com/auth/logging.write";
const DEFAULT_LOG_NAME = "fortune-api-usage";

interface GoogleServiceAccountCredentials {
  clientEmail: string;
  privateKey: string;
  projectId: string;
}

interface CachedAccessToken {
  token: string;
  expiresAt: number;
}

export interface GcpUsageLogData {
  eventType: string;
  functionName: string;
  requestId?: string;
  userId?: string;
  provider?: string;
  model?: string;
  promptTokens?: number;
  completionTokens?: number;
  totalTokens?: number;
  estimatedCostUsd?: number;
  latencyMs?: number;
  statusCode?: number;
  success: boolean;
  errorMessage?: string;
  metadata?: Record<string, unknown>;
}

let cachedToken: CachedAccessToken | null = null;

function isTruthy(value: string | null | undefined): boolean {
  if (!value) return false;
  const normalized = value.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" ||
    normalized === "on";
}

function isLoggingEnabled(): boolean {
  const explicitFlag = Deno.env.get("GCP_LOGGING_ENABLED");
  if (explicitFlag !== undefined) {
    return isTruthy(explicitFlag);
  }

  return Boolean(
    Deno.env.get("GCP_LOGGING_SERVICE_ACCOUNT_JSON") ||
      Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON"),
  );
}

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

function loadCredentials(): GoogleServiceAccountCredentials | null {
  const jsonCredential = Deno.env.get("GCP_LOGGING_SERVICE_ACCOUNT_JSON") ||
    Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON");

  if (jsonCredential) {
    try {
      const parsed = JSON.parse(jsonCredential);
      const clientEmail = parsed.client_email as string | undefined;
      const privateKeyRaw = parsed.private_key as string | undefined;
      const projectIdFromJson = parsed.project_id as string | undefined;
      const projectId = projectIdFromJson ||
        Deno.env.get("GCP_PROJECT_ID") ||
        Deno.env.get("GOOGLE_CLOUD_PROJECT") ||
        Deno.env.get("GOOGLE_PROJECT_ID");

      if (clientEmail && privateKeyRaw && projectId) {
        return {
          clientEmail,
          privateKey: privateKeyRaw.replace(/\\n/g, "\n"),
          projectId,
        };
      }
    } catch (error) {
      console.error("❌ [GCPLogging] Service account JSON parse error:", error);
    }
  }

  const clientEmail = Deno.env.get("GCP_LOGGING_CLIENT_EMAIL") ||
    Deno.env.get("GOOGLE_CLIENT_EMAIL");
  const privateKeyRaw = Deno.env.get("GCP_LOGGING_PRIVATE_KEY") ||
    Deno.env.get("GOOGLE_PRIVATE_KEY");
  const projectId = Deno.env.get("GCP_PROJECT_ID") ||
    Deno.env.get("GOOGLE_CLOUD_PROJECT") ||
    Deno.env.get("GOOGLE_PROJECT_ID");

  if (clientEmail && privateKeyRaw && projectId) {
    return {
      clientEmail,
      privateKey: privateKeyRaw.replace(/\\n/g, "\n"),
      projectId,
    };
  }

  return null;
}

async function getAccessToken(
  credentials: GoogleServiceAccountCredentials,
): Promise<string | null> {
  const nowSeconds = Math.floor(Date.now() / 1000);

  if (cachedToken && cachedToken.expiresAt > nowSeconds + 60) {
    return cachedToken.token;
  }

  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const payload = {
    iss: credentials.clientEmail,
    scope: GOOGLE_LOGGING_SCOPE,
    aud: GOOGLE_OAUTH_TOKEN_URL,
    iat: nowSeconds,
    exp: nowSeconds + 3600,
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
      console.error(
        "❌ [GCPLogging] Failed to obtain OAuth token:",
        JSON.stringify(body),
      );
      return null;
    }

    const token = body.access_token as string | undefined;
    const expiresIn = Number(body.expires_in ?? 3600);

    if (!token) {
      return null;
    }

    cachedToken = {
      token,
      expiresAt: nowSeconds + Math.max(60, expiresIn - 60),
    };

    return token;
  } catch (error) {
    console.error("❌ [GCPLogging] OAuth token request error:", error);
    return null;
  }
}

function getEnvironmentLabel(): string {
  return Deno.env.get("APP_ENV") || Deno.env.get("ENVIRONMENT") || "unknown";
}

export class GcpLoggingService {
  static async log(data: GcpUsageLogData): Promise<void> {
    if (!isLoggingEnabled()) {
      return;
    }

    const credentials = loadCredentials();
    if (!credentials) {
      return;
    }

    try {
      const accessToken = await getAccessToken(credentials);
      if (!accessToken) {
        return;
      }

      const environment = getEnvironmentLabel();
      const logId = Deno.env.get("GCP_LOGGING_LOG_NAME") || DEFAULT_LOG_NAME;
      const severity = data.success ? "INFO" : "ERROR";

      const body = {
        logName: `projects/${credentials.projectId}/logs/${
          encodeURIComponent(logId)
        }`,
        resource: {
          type: "global",
          labels: {
            project_id: credentials.projectId,
          },
        },
        entries: [
          {
            severity,
            labels: {
              service: "fortune-edge",
              environment,
              function_name: data.functionName,
            },
            jsonPayload: {
              ...data,
              service: "fortune-edge",
              environment,
              timestamp: new Date().toISOString(),
            },
          },
        ],
      };

      const response = await fetch(GOOGLE_LOGGING_API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error("❌ [GCPLogging] Failed to write log entry:", {
          status: response.status,
          body: errorText.substring(0, 500),
        });
      }
    } catch (error) {
      console.error("❌ [GCPLogging] Unexpected error:", error);
    }
  }
}
