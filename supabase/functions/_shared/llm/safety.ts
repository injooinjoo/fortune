import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import { GcpLoggingService } from "../monitoring/gcp-logging.ts";

type LlmProvider = "gemini" | "openai" | "anthropic" | "grok";
type LlmRequestMode = "text" | "image";

interface UsageWindowStats {
  requestCount: number;
  estimatedCostUsd: number;
}

interface CachedUsageWindowStats {
  expiresAt: number;
  stats: UsageWindowStats;
}

export interface LlmSafetyCheckParams {
  provider: LlmProvider;
  model: string;
  featureName: string;
  mode: LlmRequestMode;
  requestId?: string;
  metadata?: Record<string, unknown>;
}

export class LlmSafetyError extends Error {
  constructor(
    public readonly code:
      | "provider_disabled"
      | "provider_not_allowlisted"
      | "daily_request_cap_exceeded"
      | "daily_cost_cap_exceeded"
      | "guard_verification_failed",
    message: string,
  ) {
    super(message);
    this.name = "LlmSafetyError";
  }
}

const usageWindowCache = new Map<string, CachedUsageWindowStats>();
const DEFAULT_USAGE_CACHE_TTL_MS = 60000;
const DEFAULT_USAGE_WINDOW_HOURS = 24;
const COST_QUERY_PAGE_SIZE = 1000;

let supabaseClient: SupabaseClient | null = null;

function isTruthy(value: string | null | undefined): boolean {
  if (!value) return false;

  const normalized = value.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes" ||
    normalized === "on";
}

function getPositiveIntegerEnv(name: string): number | null {
  const raw = Deno.env.get(name);
  if (!raw) return null;

  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return null;
  }

  return parsed;
}

function getPositiveNumberEnv(name: string): number | null {
  const raw = Deno.env.get(name);
  if (!raw) return null;

  const parsed = Number(raw);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return null;
  }

  return parsed;
}

function parseCsvEnv(name: string): Set<string> {
  const raw = Deno.env.get(name);
  if (!raw) return new Set();

  return new Set(
    raw
      .split(",")
      .map((value) => value.trim().toLowerCase())
      .filter(Boolean),
  );
}

function getUsageCacheTtlMs(): number {
  return getPositiveIntegerEnv("LLM_USAGE_GUARD_CACHE_TTL_MS") ||
    DEFAULT_USAGE_CACHE_TTL_MS;
}

function getUsageWindowHours(): number {
  return getPositiveIntegerEnv("GEMINI_GUARD_WINDOW_HOURS") ||
    DEFAULT_USAGE_WINDOW_HOURS;
}

function getWindowStartIso(windowHours: number): string {
  const date = new Date(Date.now() - windowHours * 60 * 60 * 1000);
  date.setSeconds(0, 0);
  return date.toISOString();
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

function getDisabledProviders(): Set<string> {
  const disabled = parseCsvEnv("LLM_DISABLED_PROVIDERS");

  if (isTruthy(Deno.env.get("GEMINI_EMERGENCY_DISABLE"))) {
    disabled.add("gemini");
  }

  return disabled;
}

function getEnabledProvidersAllowlist(): Set<string> | null {
  const allowlist = parseCsvEnv("LLM_ENABLED_PROVIDERS");
  return allowlist.size > 0 ? allowlist : null;
}

async function logBlockedRequest(
  params: LlmSafetyCheckParams,
  code: LlmSafetyError["code"],
  message: string,
  metadata?: Record<string, unknown>,
): Promise<void> {
  await GcpLoggingService.log({
    eventType: "llm_request_blocked",
    functionName: params.featureName,
    requestId: params.requestId,
    provider: params.provider,
    model: params.model,
    success: false,
    errorMessage: message,
    metadata: {
      guardCode: code,
      mode: params.mode,
      ...params.metadata,
      ...metadata,
    },
  });
}

async function getUsageWindowStats(
  provider: LlmProvider,
  windowStartIso: string,
  includeCost: boolean,
): Promise<UsageWindowStats> {
  const cacheKey = `${provider}:${windowStartIso}:${
    includeCost ? "cost" : "count"
  }`;
  const cached = usageWindowCache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.stats;
  }

  const supabase = getSupabaseClient();
  const query = supabase
    .from("llm_usage_logs")
    .select("id", { count: "exact", head: true })
    .eq("provider", provider)
    .eq("success", true)
    .gte("created_at", windowStartIso);

  const { count, error: countError } = await query;
  if (countError) {
    throw new Error(`Failed to fetch request count: ${countError.message}`);
  }

  let estimatedCostUsd = 0;

  if (includeCost) {
    for (let from = 0;; from += COST_QUERY_PAGE_SIZE) {
      const to = from + COST_QUERY_PAGE_SIZE - 1;
      const { data, error } = await supabase
        .from("llm_usage_logs")
        .select("estimated_cost")
        .eq("provider", provider)
        .eq("success", true)
        .gte("created_at", windowStartIso)
        .range(from, to);

      if (error) {
        throw new Error(`Failed to fetch estimated cost: ${error.message}`);
      }

      if (!data || data.length === 0) {
        break;
      }

      estimatedCostUsd += data.reduce((sum, row) => {
        return sum + Number(row.estimated_cost || 0);
      }, 0);

      if (data.length < COST_QUERY_PAGE_SIZE) {
        break;
      }
    }
  }

  const stats = {
    requestCount: count || 0,
    estimatedCostUsd,
  };

  usageWindowCache.set(cacheKey, {
    stats,
    expiresAt: Date.now() + getUsageCacheTtlMs(),
  });

  return stats;
}

export async function assertLlmRequestAllowed(
  params: LlmSafetyCheckParams,
): Promise<void> {
  const disabledProviders = getDisabledProviders();
  const enabledProviders = getEnabledProvidersAllowlist();

  if (disabledProviders.has(params.provider)) {
    const message =
      `${params.provider} provider is disabled by LLM safety guard`;
    await logBlockedRequest(params, "provider_disabled", message);
    throw new LlmSafetyError("provider_disabled", message);
  }

  if (enabledProviders && !enabledProviders.has(params.provider)) {
    const message =
      `${params.provider} provider is not in LLM_ENABLED_PROVIDERS`;
    await logBlockedRequest(params, "provider_not_allowlisted", message);
    throw new LlmSafetyError("provider_not_allowlisted", message);
  }

  if (params.provider !== "gemini") {
    return;
  }

  const dailyRequestLimit = getPositiveIntegerEnv("GEMINI_DAILY_REQUEST_LIMIT");
  const dailyCostLimitUsd = getPositiveNumberEnv("GEMINI_DAILY_COST_LIMIT_USD");

  if (dailyRequestLimit === null && dailyCostLimitUsd === null) {
    return;
  }

  const windowHours = getUsageWindowHours();
  const windowStartIso = getWindowStartIso(windowHours);

  let stats: UsageWindowStats;
  try {
    stats = await getUsageWindowStats(
      "gemini",
      windowStartIso,
      dailyCostLimitUsd !== null,
    );
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : "Failed to verify Gemini usage limits";

    await logBlockedRequest(params, "guard_verification_failed", message, {
      windowHours,
    });
    throw new LlmSafetyError("guard_verification_failed", message);
  }

  if (dailyRequestLimit !== null && stats.requestCount >= dailyRequestLimit) {
    const message =
      `Gemini daily request limit reached: ${stats.requestCount}/${dailyRequestLimit} in the last ${windowHours}h`;
    await logBlockedRequest(params, "daily_request_cap_exceeded", message, {
      requestCount: stats.requestCount,
      requestLimit: dailyRequestLimit,
      windowHours,
    });
    throw new LlmSafetyError("daily_request_cap_exceeded", message);
  }

  if (
    dailyCostLimitUsd !== null && stats.estimatedCostUsd >= dailyCostLimitUsd
  ) {
    const message = `Gemini daily cost limit reached: ${
      stats.estimatedCostUsd.toFixed(4)
    }/${dailyCostLimitUsd} USD in the last ${windowHours}h`;
    await logBlockedRequest(params, "daily_cost_cap_exceeded", message, {
      estimatedCostUsd: stats.estimatedCostUsd,
      dailyCostLimitUsd,
      windowHours,
    });
    throw new LlmSafetyError("daily_cost_cap_exceeded", message);
  }
}
