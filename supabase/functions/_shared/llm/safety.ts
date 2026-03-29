import {
  createClient,
  type SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import { sendLlmGuardAlert } from "./alerts.ts";
import {
  GEMINI_PREVIEW_TEXT_MODEL,
  getBuiltInAllowedGeminiModels,
  isHighCostGeminiModel,
  isKnownGeminiModel,
  isPreviewGeminiModel,
} from "./models.ts";
import { GcpLoggingService } from "../monitoring/gcp-logging.ts";

type LlmProvider = "gemini" | "openai" | "anthropic" | "grok";
type LlmRequestMode = "text" | "image";
type GuardSeverity = "healthy" | "warning" | "critical";
type GuardStatus = "healthy" | "warning" | "blocked";
type GuardMetric = "request_count" | "estimated_cost";
type GuardWindowLabel = "daily" | "burst";
type GuardScope = "provider" | "feature";
type GuardThresholdCode =
  | "provider_disabled"
  | "provider_not_allowlisted"
  | "model_not_allowlisted"
  | "preview_model_blocked"
  | "high_cost_model_blocked"
  | "circuit_open"
  | "daily_request_cap_exceeded"
  | "daily_cost_cap_exceeded"
  | "burst_request_cap_exceeded"
  | "burst_cost_cap_exceeded"
  | "feature_burst_request_cap_exceeded"
  | "feature_burst_cost_cap_exceeded"
  | "guard_verification_failed";

interface UsageWindowStats {
  requestCount: number;
  estimatedCostUsd: number;
}

interface UsageWindowSummary extends UsageWindowStats {
  windowMinutes: number;
  featureName?: string;
}

interface CachedUsageWindowStats {
  expiresAt: number;
  stats: UsageWindowStats;
}

interface CachedProviderGuardState {
  expiresAt: number;
  state: LlmGuardState | null;
}

export interface LlmGuardState {
  provider: string;
  status: GuardStatus;
  reason?: string | null;
  thresholdCode?: string | null;
  triggeredBy?: string | null;
  triggeredModel?: string | null;
  requestCount?: number | null;
  estimatedCostUsd?: number | null;
  blockedUntil?: string | null;
  lastAlertAt?: string | null;
  alertCount?: number | null;
  metadata?: Record<string, unknown> | null;
}

export interface GeminiGuardThreshold {
  code: GuardThresholdCode;
  scope: GuardScope;
  metric: GuardMetric;
  windowLabel: GuardWindowLabel;
  windowMinutes: number;
  current: number;
  limit: number;
  featureName?: string;
}

interface GeminiGuardLimits {
  dailyRequestLimit: number | null;
  dailyCostLimitUsd: number | null;
  burstWindowMinutes: number;
  burstRequestLimit: number | null;
  burstCostLimitUsd: number | null;
  featureBurstRequestLimit: number | null;
  featureBurstCostLimitUsd: number | null;
  circuitCooldownMinutes: number;
  alertThresholdRatio: number;
}

interface GeminiBurstFeatureSummary {
  featureName: string;
  requestCount: number;
  estimatedCostUsd: number;
}

export interface GeminiGuardSnapshot {
  provider: "gemini";
  severity: GuardSeverity;
  usageTrackingAvailable: boolean;
  usageTrackingError?: string | null;
  currentCircuitState: LlmGuardState | null;
  limits: GeminiGuardLimits;
  windows: {
    daily: UsageWindowSummary;
    burst: UsageWindowSummary;
    featureBurst?: UsageWindowSummary;
    topBurstFeatures: GeminiBurstFeatureSummary[];
  };
  breaches: GeminiGuardThreshold[];
  warnings: GeminiGuardThreshold[];
  actions: string[];
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
    public readonly code: GuardThresholdCode,
    message: string,
  ) {
    super(message);
    this.name = "LlmSafetyError";
  }
}

const usageWindowCache = new Map<string, CachedUsageWindowStats>();
const providerStateCache = new Map<string, CachedProviderGuardState>();
let usageLogRelationAvailable: boolean | null = null;
let lastUsageTrackingError: string | null = null;

const DEFAULT_USAGE_CACHE_TTL_MS = 60_000;
const DEFAULT_PROVIDER_STATE_CACHE_TTL_MS = 10_000;
const DEFAULT_USAGE_WINDOW_HOURS = 24;
const DEFAULT_BURST_WINDOW_MINUTES = 10;
const DEFAULT_CIRCUIT_COOLDOWN_MINUTES = 30;
const DEFAULT_ALERT_THRESHOLD_RATIO = 0.85;
const DEFAULT_ALERT_DEDUP_WINDOW_MINUTES = 30;
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

function getProviderStateCacheTtlMs(): number {
  return getPositiveIntegerEnv("LLM_GUARD_STATE_CACHE_TTL_MS") ||
    DEFAULT_PROVIDER_STATE_CACHE_TTL_MS;
}

function getUsageWindowHours(): number {
  return getPositiveIntegerEnv("GEMINI_GUARD_WINDOW_HOURS") ||
    DEFAULT_USAGE_WINDOW_HOURS;
}

function getBurstWindowMinutes(): number {
  return getPositiveIntegerEnv("GEMINI_BURST_WINDOW_MINUTES") ||
    DEFAULT_BURST_WINDOW_MINUTES;
}

function getCircuitCooldownMinutes(): number {
  return getPositiveIntegerEnv("GEMINI_CIRCUIT_BREAKER_COOLDOWN_MINUTES") ||
    DEFAULT_CIRCUIT_COOLDOWN_MINUTES;
}

function getAlertThresholdRatio(): number {
  const raw = Number(Deno.env.get("LLM_GUARD_ALERT_THRESHOLD_RATIO") || "");
  if (!Number.isFinite(raw)) {
    return DEFAULT_ALERT_THRESHOLD_RATIO;
  }

  return Math.min(Math.max(raw, 0.5), 0.99);
}

function getAlertDedupeWindowMinutes(): number {
  return getPositiveIntegerEnv("LLM_GUARD_ALERT_DEDUP_WINDOW_MINUTES") ||
    DEFAULT_ALERT_DEDUP_WINDOW_MINUTES;
}

function getWindowStartIso(windowMinutes: number): string {
  const date = new Date(Date.now() - windowMinutes * 60 * 1000);
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

function isMissingUsageLogRelationError(error: unknown): boolean {
  const message = error instanceof Error
    ? error.message
    : error && typeof error === "object" && "message" in error
    ? String((error as { message?: unknown }).message || "")
    : String(error || "");
  return message.includes("llm_usage_logs") &&
    message.includes("does not exist");
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  if (error && typeof error === "object" && "message" in error) {
    return String((error as { message?: unknown }).message || "");
  }

  return String(error || "");
}

function markUsageLogRelationUnavailable(error?: unknown): void {
  usageLogRelationAvailable = false;
  lastUsageTrackingError = error ? getErrorMessage(error) : "unknown_error";
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

function isPreviewModelsAllowed(): boolean {
  return isTruthy(Deno.env.get("LLM_ALLOW_PREVIEW_MODELS"));
}

function isHighCostModelsAllowed(): boolean {
  return isTruthy(Deno.env.get("LLM_ALLOW_HIGH_COST_MODELS"));
}

function getAllowedGeminiModels(): Set<string> {
  const configured = parseCsvEnv("GEMINI_MODEL_ALLOWLIST");
  if (configured.size > 0) {
    return configured;
  }

  const allowlist = getBuiltInAllowedGeminiModels();
  if (isPreviewModelsAllowed()) {
    allowlist.add(GEMINI_PREVIEW_TEXT_MODEL);
  }
  return allowlist;
}

function getAllowedOpenAiImageModels(): Set<string> {
  const configured = parseCsvEnv("OPENAI_IMAGE_MODEL_ALLOWLIST");
  if (configured.size > 0) {
    return configured;
  }

  return new Set([
    "dall-e-3",
    "gpt-image-1-mini",
    "gpt-image-1",
  ]);
}

function isKnownOpenAiImageModel(model: string): boolean {
  const normalized = model.trim().toLowerCase();
  return normalized === "dall-e-3" || normalized === "gpt-image-1-mini" ||
    normalized === "gpt-image-1";
}

function isHighCostOpenAiImageModel(model: string): boolean {
  return model.trim().toLowerCase() === "gpt-image-1";
}

function validateOpenAiImageModel(
  model: string,
): { code: GuardThresholdCode; message: string } | null {
  const normalized = model.trim().toLowerCase();
  const allowlist = getAllowedOpenAiImageModels();

  if (!allowlist.has(normalized) && !isKnownOpenAiImageModel(normalized)) {
    return {
      code: "model_not_allowlisted",
      message: `OpenAI image model is not in the allowed catalog: ${model}`,
    };
  }

  if (!allowlist.has(normalized)) {
    return {
      code: "model_not_allowlisted",
      message:
        `OpenAI image model is not in OPENAI_IMAGE_MODEL_ALLOWLIST: ${model}`,
    };
  }

  if (isHighCostOpenAiImageModel(normalized) && !isHighCostModelsAllowed()) {
    return {
      code: "high_cost_model_blocked",
      message:
        `High-cost OpenAI image model requires LLM_ALLOW_HIGH_COST_MODELS=true: ${model}`,
    };
  }

  return null;
}

function getGeminiLimits(): GeminiGuardLimits {
  return {
    dailyRequestLimit: getPositiveIntegerEnv("GEMINI_DAILY_REQUEST_LIMIT"),
    dailyCostLimitUsd: getPositiveNumberEnv("GEMINI_DAILY_COST_LIMIT_USD"),
    burstWindowMinutes: getBurstWindowMinutes(),
    burstRequestLimit: getPositiveIntegerEnv("GEMINI_BURST_REQUEST_LIMIT"),
    burstCostLimitUsd: getPositiveNumberEnv("GEMINI_BURST_COST_LIMIT_USD"),
    featureBurstRequestLimit: getPositiveIntegerEnv(
      "GEMINI_FEATURE_BURST_REQUEST_LIMIT",
    ),
    featureBurstCostLimitUsd: getPositiveNumberEnv(
      "GEMINI_FEATURE_BURST_COST_LIMIT_USD",
    ),
    circuitCooldownMinutes: getCircuitCooldownMinutes(),
    alertThresholdRatio: getAlertThresholdRatio(),
  };
}

function isGuardStateBlocked(state: LlmGuardState | null): boolean {
  if (!state || state.status !== "blocked" || !state.blockedUntil) {
    return false;
  }

  return new Date(state.blockedUntil).getTime() > Date.now();
}

function normalizeGuardState(
  row: Record<string, unknown>,
): LlmGuardState {
  const metadata = row.metadata && typeof row.metadata === "object"
    ? row.metadata as Record<string, unknown>
    : {};
  const guardState = metadata.guardState &&
      typeof metadata.guardState === "object"
    ? metadata.guardState as Record<string, unknown>
    : metadata;

  return {
    provider: String(guardState.provider || row.provider || ""),
    status: String(guardState.status || "healthy") as GuardStatus,
    reason: guardState.reason ? String(guardState.reason) : null,
    thresholdCode: guardState.thresholdCode
      ? String(guardState.thresholdCode)
      : null,
    triggeredBy: guardState.triggeredBy ? String(guardState.triggeredBy) : null,
    triggeredModel: guardState.triggeredModel
      ? String(guardState.triggeredModel)
      : null,
    requestCount:
      guardState.requestCount !== null && guardState.requestCount !== undefined
        ? Number(guardState.requestCount)
        : null,
    estimatedCostUsd: guardState.estimatedCostUsd !== null &&
        guardState.estimatedCostUsd !== undefined
      ? Number(guardState.estimatedCostUsd)
      : null,
    blockedUntil: guardState.blockedUntil
      ? String(guardState.blockedUntil)
      : null,
    lastAlertAt: guardState.lastAlertAt ? String(guardState.lastAlertAt) : null,
    alertCount:
      guardState.alertCount !== null && guardState.alertCount !== undefined
        ? Number(guardState.alertCount)
        : null,
    metadata: guardState.metadata && typeof guardState.metadata === "object"
      ? guardState.metadata as Record<string, unknown>
      : {},
  };
}

async function getProviderGuardState(
  provider: LlmProvider,
): Promise<LlmGuardState | null> {
  if (usageLogRelationAvailable === false) {
    return null;
  }

  const cached = providerStateCache.get(provider);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.state;
  }

  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("llm_usage_logs")
    .select("provider, metadata")
    .eq("fortune_type", "llm-guard")
    .eq("provider", provider)
    .eq("model", "guard-state")
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    markUsageLogRelationUnavailable(error);
    return null;
  }

  usageLogRelationAvailable = true;
  lastUsageTrackingError = null;
  const state = data
    ? normalizeGuardState(data as Record<string, unknown>)
    : null;
  providerStateCache.set(provider, {
    state,
    expiresAt: Date.now() + getProviderStateCacheTtlMs(),
  });
  return state;
}

async function persistProviderGuardState(
  provider: LlmProvider,
  updates: Partial<LlmGuardState>,
): Promise<LlmGuardState> {
  const current = await getProviderGuardState(provider);
  const now = new Date().toISOString();
  const nextState: LlmGuardState = {
    provider,
    status: updates.status || current?.status || "healthy",
    reason: updates.reason ?? current?.reason ?? null,
    thresholdCode: updates.thresholdCode ?? current?.thresholdCode ?? null,
    triggeredBy: updates.triggeredBy ?? current?.triggeredBy ?? null,
    triggeredModel: updates.triggeredModel ?? current?.triggeredModel ?? null,
    requestCount: updates.requestCount ?? current?.requestCount ?? 0,
    estimatedCostUsd: updates.estimatedCostUsd ?? current?.estimatedCostUsd ??
      0,
    blockedUntil: updates.blockedUntil ?? current?.blockedUntil ?? null,
    lastAlertAt: updates.lastAlertAt ?? current?.lastAlertAt ?? null,
    alertCount: updates.alertCount ?? current?.alertCount ?? 0,
    metadata: updates.metadata ?? current?.metadata ?? {},
  };

  const row = {
    fortune_type: "llm-guard",
    provider,
    model: "guard-state",
    is_ab_test: false,
    prompt_tokens: 0,
    completion_tokens: 0,
    total_tokens: 0,
    latency_ms: 0,
    estimated_cost: 0,
    finish_reason: "error",
    success: false,
    error_message: nextState.reason ?? `${nextState.status} guard state`,
    metadata: {
      kind: "guard_state",
      updatedAt: now,
      guardState: nextState,
    },
  };

  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from("llm_usage_logs")
    .insert(row)
    .select("provider, metadata")
    .single();

  if (error) {
    markUsageLogRelationUnavailable(error);
    return nextState;
  }

  usageLogRelationAvailable = true;
  lastUsageTrackingError = null;
  const normalized = normalizeGuardState(data as Record<string, unknown>);
  providerStateCache.set(provider, {
    state: normalized,
    expiresAt: Date.now() + getProviderStateCacheTtlMs(),
  });

  return normalized;
}

async function maybeClearExpiredProviderBlock(
  provider: LlmProvider,
): Promise<LlmGuardState | null> {
  const state = await getProviderGuardState(provider);
  if (!state || state.status !== "blocked" || !state.blockedUntil) {
    return state;
  }

  if (new Date(state.blockedUntil).getTime() > Date.now()) {
    return state;
  }

  return await persistProviderGuardState(provider, {
    status: "healthy",
    reason: null,
    thresholdCode: null,
    blockedUntil: null,
    metadata: {
      ...(state.metadata || {}),
      autoRecoveredAt: new Date().toISOString(),
    },
  });
}

function buildUsageWindowCacheKey(
  provider: LlmProvider,
  windowStartIso: string,
  includeCost: boolean,
  featureName?: string,
): string {
  return `${provider}:${windowStartIso}:${includeCost ? "cost" : "count"}:${
    featureName || "all"
  }`;
}

async function getUsageWindowStats(
  provider: LlmProvider,
  windowStartIso: string,
  includeCost: boolean,
  featureName?: string,
): Promise<UsageWindowStats> {
  if (usageLogRelationAvailable === false) {
    return {
      requestCount: 0,
      estimatedCostUsd: 0,
    };
  }

  const cacheKey = buildUsageWindowCacheKey(
    provider,
    windowStartIso,
    includeCost,
    featureName,
  );
  const cached = usageWindowCache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.stats;
  }

  const supabase = getSupabaseClient();
  let countQuery = supabase
    .from("llm_usage_logs")
    .select("id", { count: "exact", head: true })
    .eq("provider", provider)
    .eq("success", true)
    .gte("created_at", windowStartIso);

  if (featureName) {
    countQuery = countQuery.eq("fortune_type", featureName);
  }

  const { count, error: countError } = await countQuery;
  if (countError) {
    markUsageLogRelationUnavailable(countError);
    return {
      requestCount: 0,
      estimatedCostUsd: 0,
    };
  }

  let estimatedCostUsd = 0;

  if (includeCost) {
    for (let from = 0;; from += COST_QUERY_PAGE_SIZE) {
      const to = from + COST_QUERY_PAGE_SIZE - 1;
      let costQuery = supabase
        .from("llm_usage_logs")
        .select("estimated_cost")
        .eq("provider", provider)
        .eq("success", true)
        .gte("created_at", windowStartIso)
        .range(from, to);

      if (featureName) {
        costQuery = costQuery.eq("fortune_type", featureName);
      }

      const { data, error } = await costQuery;

      if (error) {
        markUsageLogRelationUnavailable(error);
        return {
          requestCount: count || 0,
          estimatedCostUsd: 0,
        };
      }

      if (!data || data.length === 0) {
        break;
      }

      estimatedCostUsd += data.reduce((sum, row) => {
        const typedRow = row as Record<string, unknown>;
        return sum + Number(typedRow.estimated_cost || 0);
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

  usageLogRelationAvailable = true;
  lastUsageTrackingError = null;

  usageWindowCache.set(cacheKey, {
    stats,
    expiresAt: Date.now() + getUsageCacheTtlMs(),
  });

  return stats;
}

async function getTopBurstFeatures(
  provider: LlmProvider,
  windowStartIso: string,
  limit = 5,
): Promise<GeminiBurstFeatureSummary[]> {
  if (usageLogRelationAvailable === false) {
    return [];
  }

  const supabase = getSupabaseClient();
  const rows: Array<Record<string, unknown>> = [];

  for (let from = 0;; from += COST_QUERY_PAGE_SIZE) {
    const to = from + COST_QUERY_PAGE_SIZE - 1;
    const { data, error } = await supabase
      .from("llm_usage_logs")
      .select("fortune_type, estimated_cost")
      .eq("provider", provider)
      .eq("success", true)
      .gte("created_at", windowStartIso)
      .range(from, to);

    if (error) {
      markUsageLogRelationUnavailable(error);
      return [];
    }

    if (!data || data.length === 0) {
      break;
    }

    rows.push(...(data as Array<Record<string, unknown>>));
    if (data.length < COST_QUERY_PAGE_SIZE) {
      break;
    }
  }

  const summary = new Map<string, GeminiBurstFeatureSummary>();
  for (const row of rows) {
    const featureName = String(row.fortune_type || "unknown");
    const cost = Number(row.estimated_cost || 0);
    const current = summary.get(featureName) || {
      featureName,
      requestCount: 0,
      estimatedCostUsd: 0,
    };
    current.requestCount += 1;
    current.estimatedCostUsd += cost;
    summary.set(featureName, current);
  }

  return Array.from(summary.values())
    .sort((left, right) => {
      if (right.requestCount !== left.requestCount) {
        return right.requestCount - left.requestCount;
      }
      return right.estimatedCostUsd - left.estimatedCostUsd;
    })
    .slice(0, limit);
}

function maybePushThreshold(
  collection: GeminiGuardThreshold[],
  limit: number | null,
  current: number,
  code: GuardThresholdCode,
  scope: GuardScope,
  metric: GuardMetric,
  windowLabel: GuardWindowLabel,
  windowMinutes: number,
  featureName?: string,
): void {
  if (limit === null || current < limit) {
    return;
  }

  collection.push({
    code,
    scope,
    metric,
    windowLabel,
    windowMinutes,
    current,
    limit,
    featureName,
  });
}

function maybePushWarning(
  collection: GeminiGuardThreshold[],
  limit: number | null,
  current: number,
  ratio: number,
  code: GuardThresholdCode,
  scope: GuardScope,
  metric: GuardMetric,
  windowLabel: GuardWindowLabel,
  windowMinutes: number,
  featureName?: string,
): void {
  if (limit === null) {
    return;
  }

  const thresholdValue = limit * ratio;
  if (current < thresholdValue || current >= limit) {
    return;
  }

  collection.push({
    code,
    scope,
    metric,
    windowLabel,
    windowMinutes,
    current,
    limit,
    featureName,
  });
}

function buildThresholdMessage(
  threshold: GeminiGuardThreshold,
): string {
  const metricLabel = threshold.metric === "request_count"
    ? "requests"
    : "estimated cost";
  const scopeLabel = threshold.scope === "feature" && threshold.featureName
    ? `${threshold.featureName} feature`
    : "Gemini provider";

  const currentValue = threshold.metric === "estimated_cost"
    ? `${threshold.current.toFixed(4)} USD`
    : String(threshold.current);
  const limitValue = threshold.metric === "estimated_cost"
    ? `${threshold.limit} USD`
    : String(threshold.limit);

  return `${scopeLabel} ${metricLabel} reached ${currentValue}/${limitValue} in the last ${threshold.windowMinutes}m`;
}

function shouldSendGuardAlert(
  state: LlmGuardState | null,
  nextStatus: GuardStatus,
  thresholdCode: string,
): boolean {
  if (!state?.lastAlertAt) {
    return true;
  }

  if (state.status !== nextStatus || state.thresholdCode !== thresholdCode) {
    return true;
  }

  const dedupeWindowMs = getAlertDedupeWindowMinutes() * 60 * 1000;
  return Date.now() - new Date(state.lastAlertAt).getTime() >= dedupeWindowMs;
}

async function logBlockedRequest(
  params: LlmSafetyCheckParams,
  code: GuardThresholdCode,
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

function validateGeminiModel(
  model: string,
): { code: GuardThresholdCode; message: string } | null {
  const normalized = model.trim().toLowerCase();
  const allowlist = getAllowedGeminiModels();

  if (!allowlist.has(normalized) && !isKnownGeminiModel(normalized)) {
    return {
      code: "model_not_allowlisted",
      message: `Gemini model is not in the allowed catalog: ${model}`,
    };
  }

  if (!allowlist.has(normalized)) {
    return {
      code: "model_not_allowlisted",
      message: `Gemini model is not in GEMINI_MODEL_ALLOWLIST: ${model}`,
    };
  }

  if (isPreviewGeminiModel(normalized) && !isPreviewModelsAllowed()) {
    return {
      code: "preview_model_blocked",
      message:
        `Preview Gemini model requires LLM_ALLOW_PREVIEW_MODELS=true: ${model}`,
    };
  }

  if (isHighCostGeminiModel(normalized) && !isHighCostModelsAllowed()) {
    return {
      code: "high_cost_model_blocked",
      message:
        `High-cost Gemini model requires LLM_ALLOW_HIGH_COST_MODELS=true: ${model}`,
    };
  }

  return null;
}

export async function getGeminiGuardSnapshot(
  featureName?: string,
  includeTopFeatures = false,
): Promise<GeminiGuardSnapshot> {
  const limits = getGeminiLimits();
  const dailyWindowMinutes = getUsageWindowHours() * 60;
  const burstWindowMinutes = limits.burstWindowMinutes;
  const includeCost = [
    limits.dailyCostLimitUsd,
    limits.burstCostLimitUsd,
    limits.featureBurstCostLimitUsd,
  ].some((value) => value !== null);

  const currentCircuitState = await maybeClearExpiredProviderBlock("gemini");
  const [dailyStats, burstStats, featureBurstStats, topBurstFeatures] =
    await Promise.all([
      getUsageWindowStats(
        "gemini",
        getWindowStartIso(dailyWindowMinutes),
        includeCost,
      ),
      getUsageWindowStats(
        "gemini",
        getWindowStartIso(burstWindowMinutes),
        includeCost,
      ),
      featureName
        ? getUsageWindowStats(
          "gemini",
          getWindowStartIso(burstWindowMinutes),
          includeCost,
          featureName,
        )
        : Promise.resolve<UsageWindowStats | null>(null),
      includeTopFeatures
        ? getTopBurstFeatures("gemini", getWindowStartIso(burstWindowMinutes))
        : Promise.resolve([]),
    ]);

  const breaches: GeminiGuardThreshold[] = [];
  const warnings: GeminiGuardThreshold[] = [];

  maybePushThreshold(
    breaches,
    limits.dailyRequestLimit,
    dailyStats.requestCount,
    "daily_request_cap_exceeded",
    "provider",
    "request_count",
    "daily",
    dailyWindowMinutes,
  );
  maybePushThreshold(
    breaches,
    limits.dailyCostLimitUsd,
    dailyStats.estimatedCostUsd,
    "daily_cost_cap_exceeded",
    "provider",
    "estimated_cost",
    "daily",
    dailyWindowMinutes,
  );
  maybePushThreshold(
    breaches,
    limits.burstRequestLimit,
    burstStats.requestCount,
    "burst_request_cap_exceeded",
    "provider",
    "request_count",
    "burst",
    burstWindowMinutes,
  );
  maybePushThreshold(
    breaches,
    limits.burstCostLimitUsd,
    burstStats.estimatedCostUsd,
    "burst_cost_cap_exceeded",
    "provider",
    "estimated_cost",
    "burst",
    burstWindowMinutes,
  );

  if (featureName && featureBurstStats) {
    maybePushThreshold(
      breaches,
      limits.featureBurstRequestLimit,
      featureBurstStats.requestCount,
      "feature_burst_request_cap_exceeded",
      "feature",
      "request_count",
      "burst",
      burstWindowMinutes,
      featureName,
    );
    maybePushThreshold(
      breaches,
      limits.featureBurstCostLimitUsd,
      featureBurstStats.estimatedCostUsd,
      "feature_burst_cost_cap_exceeded",
      "feature",
      "estimated_cost",
      "burst",
      burstWindowMinutes,
      featureName,
    );
  }

  maybePushWarning(
    warnings,
    limits.dailyRequestLimit,
    dailyStats.requestCount,
    limits.alertThresholdRatio,
    "daily_request_cap_exceeded",
    "provider",
    "request_count",
    "daily",
    dailyWindowMinutes,
  );
  maybePushWarning(
    warnings,
    limits.dailyCostLimitUsd,
    dailyStats.estimatedCostUsd,
    limits.alertThresholdRatio,
    "daily_cost_cap_exceeded",
    "provider",
    "estimated_cost",
    "daily",
    dailyWindowMinutes,
  );
  maybePushWarning(
    warnings,
    limits.burstRequestLimit,
    burstStats.requestCount,
    limits.alertThresholdRatio,
    "burst_request_cap_exceeded",
    "provider",
    "request_count",
    "burst",
    burstWindowMinutes,
  );
  maybePushWarning(
    warnings,
    limits.burstCostLimitUsd,
    burstStats.estimatedCostUsd,
    limits.alertThresholdRatio,
    "burst_cost_cap_exceeded",
    "provider",
    "estimated_cost",
    "burst",
    burstWindowMinutes,
  );

  if (featureName && featureBurstStats) {
    maybePushWarning(
      warnings,
      limits.featureBurstRequestLimit,
      featureBurstStats.requestCount,
      limits.alertThresholdRatio,
      "feature_burst_request_cap_exceeded",
      "feature",
      "request_count",
      "burst",
      burstWindowMinutes,
      featureName,
    );
    maybePushWarning(
      warnings,
      limits.featureBurstCostLimitUsd,
      featureBurstStats.estimatedCostUsd,
      limits.alertThresholdRatio,
      "feature_burst_cost_cap_exceeded",
      "feature",
      "estimated_cost",
      "burst",
      burstWindowMinutes,
      featureName,
    );
  }

  const severity: GuardSeverity = isGuardStateBlocked(currentCircuitState) ||
      breaches.length > 0
    ? "critical"
    : usageLogRelationAvailable === false
    ? "warning"
    : warnings.length > 0
    ? "warning"
    : "healthy";

  return {
    provider: "gemini",
    severity,
    usageTrackingAvailable: usageLogRelationAvailable !== false,
    usageTrackingError: usageLogRelationAvailable === false
      ? lastUsageTrackingError
      : null,
    currentCircuitState,
    limits,
    windows: {
      daily: {
        ...dailyStats,
        windowMinutes: dailyWindowMinutes,
      },
      burst: {
        ...burstStats,
        windowMinutes: burstWindowMinutes,
      },
      featureBurst: featureName && featureBurstStats
        ? {
          ...featureBurstStats,
          featureName,
          windowMinutes: burstWindowMinutes,
        }
        : undefined,
      topBurstFeatures,
    },
    breaches,
    warnings,
    actions: [],
  };
}

export async function openGeminiGuardCircuit(
  params: Pick<LlmSafetyCheckParams, "featureName" | "model" | "requestId">,
  snapshot: GeminiGuardSnapshot,
  threshold: GeminiGuardThreshold,
): Promise<GeminiGuardSnapshot> {
  const currentState = snapshot.currentCircuitState;
  const message = buildThresholdMessage(threshold);
  const blockedUntil = new Date(
    Date.now() + snapshot.limits.circuitCooldownMinutes * 60 * 1000,
  ).toISOString();

  const requestCount = threshold.metric === "request_count"
    ? threshold.current
    : threshold.scope === "feature" && snapshot.windows.featureBurst
    ? snapshot.windows.featureBurst.requestCount
    : snapshot.windows.burst.requestCount;
  const estimatedCostUsd = threshold.metric === "estimated_cost"
    ? threshold.current
    : threshold.scope === "feature" && snapshot.windows.featureBurst
    ? snapshot.windows.featureBurst.estimatedCostUsd
    : snapshot.windows.burst.estimatedCostUsd;

  const shouldAlert = shouldSendGuardAlert(
    currentState,
    "blocked",
    threshold.code,
  );

  const nextState = await persistProviderGuardState("gemini", {
    status: "blocked",
    reason: message,
    thresholdCode: threshold.code,
    triggeredBy: params.featureName,
    triggeredModel: params.model,
    requestCount,
    estimatedCostUsd,
    blockedUntil,
    lastAlertAt: shouldAlert
      ? new Date().toISOString()
      : currentState?.lastAlertAt,
    alertCount: shouldAlert
      ? (currentState?.alertCount || 0) + 1
      : currentState?.alertCount || 0,
    metadata: {
      ...(currentState?.metadata || {}),
      scope: threshold.scope,
      windowLabel: threshold.windowLabel,
      windowMinutes: threshold.windowMinutes,
      requestId: params.requestId,
      featureName: threshold.featureName || params.featureName,
    },
  });

  if (shouldAlert) {
    await sendLlmGuardAlert({
      severity: "critical",
      title: "[Ondo] Gemini circuit opened",
      message,
      provider: "gemini",
      model: params.model,
      featureName: params.featureName,
      thresholdCode: threshold.code,
      metadata: {
        blockedUntil,
        requestCount,
        estimatedCostUsd,
      },
    });
  }

  return {
    ...snapshot,
    severity: "critical",
    currentCircuitState: nextState,
    actions: [...snapshot.actions, "circuit_opened"],
  };
}

export async function recordGeminiGuardWarning(
  snapshot: GeminiGuardSnapshot,
): Promise<GeminiGuardSnapshot> {
  if (
    snapshot.warnings.length === 0 ||
    isGuardStateBlocked(snapshot.currentCircuitState)
  ) {
    return snapshot;
  }

  const warning = snapshot.warnings[0];
  const message = buildThresholdMessage(warning);
  const currentState = snapshot.currentCircuitState;
  const shouldAlert = shouldSendGuardAlert(
    currentState,
    "warning",
    warning.code,
  );

  const nextState = await persistProviderGuardState("gemini", {
    status: "warning",
    reason: message,
    thresholdCode: warning.code,
    triggeredBy: warning.featureName || currentState?.triggeredBy || null,
    triggeredModel: currentState?.triggeredModel || null,
    requestCount: warning.metric === "request_count"
      ? warning.current
      : snapshot.windows.burst.requestCount,
    estimatedCostUsd: warning.metric === "estimated_cost"
      ? warning.current
      : snapshot.windows.burst.estimatedCostUsd,
    blockedUntil: null,
    lastAlertAt: shouldAlert
      ? new Date().toISOString()
      : currentState?.lastAlertAt,
    alertCount: shouldAlert
      ? (currentState?.alertCount || 0) + 1
      : currentState?.alertCount || 0,
    metadata: {
      ...(currentState?.metadata || {}),
      scope: warning.scope,
      windowLabel: warning.windowLabel,
      windowMinutes: warning.windowMinutes,
      featureName: warning.featureName,
    },
  });

  if (shouldAlert) {
    await sendLlmGuardAlert({
      severity: "warning",
      title: "[Ondo] Gemini usage approaching limit",
      message,
      provider: "gemini",
      featureName: warning.featureName || "monitor-llm-usage",
      thresholdCode: warning.code,
      metadata: {
        requestCount: nextState.requestCount,
        estimatedCostUsd: nextState.estimatedCostUsd,
      },
    });
  }

  return {
    ...snapshot,
    severity: "warning",
    currentCircuitState: nextState,
    actions: [...snapshot.actions, "warning_recorded"],
  };
}

export async function markGeminiGuardHealthy(
  snapshot: GeminiGuardSnapshot,
): Promise<GeminiGuardSnapshot> {
  const currentState = snapshot.currentCircuitState;
  if (!currentState || currentState.status === "healthy") {
    return snapshot;
  }

  const notifyOnRecovery = isTruthy(
    Deno.env.get("LLM_GUARD_NOTIFY_ON_RECOVERY"),
  );

  const nextState = await persistProviderGuardState("gemini", {
    status: "healthy",
    reason: null,
    thresholdCode: null,
    blockedUntil: null,
    metadata: {
      ...(currentState.metadata || {}),
      recoveredAt: new Date().toISOString(),
    },
  });

  if (notifyOnRecovery) {
    await sendLlmGuardAlert({
      severity: "info",
      title: "[Ondo] Gemini guard recovered",
      message: "Gemini traffic is back under the configured limits.",
      provider: "gemini",
      featureName: "monitor-llm-usage",
      metadata: {
        previousStatus: currentState.status,
      },
    });
  }

  return {
    ...snapshot,
    severity: "healthy",
    currentCircuitState: nextState,
    actions: [...snapshot.actions, "state_marked_healthy"],
  };
}

export async function runGeminiGuardMonitor(): Promise<GeminiGuardSnapshot> {
  let snapshot = await getGeminiGuardSnapshot(undefined, true);

  if (!snapshot.usageTrackingAvailable) {
    return {
      ...snapshot,
      severity: "warning",
      actions: [...snapshot.actions, "usage_tracking_unavailable"],
    };
  }

  if (isGuardStateBlocked(snapshot.currentCircuitState)) {
    return {
      ...snapshot,
      severity: "critical",
      actions: [...snapshot.actions, "circuit_still_active"],
    };
  }

  if (snapshot.breaches.length > 0) {
    snapshot = await openGeminiGuardCircuit(
      {
        featureName: "monitor-llm-usage",
        model: "monitor",
      },
      snapshot,
      snapshot.breaches[0],
    );
    return snapshot;
  }

  if (snapshot.warnings.length > 0) {
    return await recordGeminiGuardWarning(snapshot);
  }

  return await markGeminiGuardHealthy(snapshot);
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

  if (params.provider === "openai" && params.mode === "image") {
    const modelValidation = validateOpenAiImageModel(params.model);
    if (modelValidation) {
      await logBlockedRequest(
        params,
        modelValidation.code,
        modelValidation.message,
      );
      throw new LlmSafetyError(modelValidation.code, modelValidation.message);
    }
    return;
  }

  if (params.provider !== "gemini") {
    return;
  }

  const modelValidation = validateGeminiModel(params.model);
  if (modelValidation) {
    await logBlockedRequest(
      params,
      modelValidation.code,
      modelValidation.message,
    );
    throw new LlmSafetyError(modelValidation.code, modelValidation.message);
  }

  let currentState: LlmGuardState | null;
  try {
    currentState = await maybeClearExpiredProviderBlock("gemini");
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : "Failed to verify Gemini circuit state";

    await logBlockedRequest(params, "guard_verification_failed", message);
    throw new LlmSafetyError("guard_verification_failed", message);
  }

  if (isGuardStateBlocked(currentState)) {
    const message = currentState?.reason ||
      `Gemini circuit is open until ${currentState?.blockedUntil}`;
    await logBlockedRequest(params, "circuit_open", message, {
      blockedUntil: currentState?.blockedUntil,
      thresholdCode: currentState?.thresholdCode,
    });
    throw new LlmSafetyError("circuit_open", message);
  }

  const limits = getGeminiLimits();
  const noLimitsConfigured = [
    limits.dailyRequestLimit,
    limits.dailyCostLimitUsd,
    limits.burstRequestLimit,
    limits.burstCostLimitUsd,
    limits.featureBurstRequestLimit,
    limits.featureBurstCostLimitUsd,
  ].every((value) => value === null);

  if (noLimitsConfigured) {
    return;
  }

  let snapshot: GeminiGuardSnapshot;
  try {
    snapshot = await getGeminiGuardSnapshot(params.featureName);
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : "Failed to verify Gemini usage limits";

    await logBlockedRequest(params, "guard_verification_failed", message, {
      featureName: params.featureName,
    });
    throw new LlmSafetyError("guard_verification_failed", message);
  }

  if (!snapshot.usageTrackingAvailable) {
    await GcpLoggingService.log({
      eventType: "llm_guard_degraded",
      functionName: params.featureName,
      requestId: params.requestId,
      provider: params.provider,
      model: params.model,
      success: false,
      errorMessage:
        "llm_usage_logs relation is unavailable; request caps are bypassed",
      metadata: {
        mode: params.mode,
      },
    });
    return;
  }

  if (snapshot.breaches.length === 0) {
    return;
  }

  const nextSnapshot = await openGeminiGuardCircuit(
    params,
    snapshot,
    snapshot.breaches[0],
  );
  const threshold = nextSnapshot.breaches[0];
  const message = buildThresholdMessage(threshold);

  await logBlockedRequest(params, threshold.code, message, {
    blockedUntil: nextSnapshot.currentCircuitState?.blockedUntil,
    thresholdCode: threshold.code,
    scope: threshold.scope,
    windowLabel: threshold.windowLabel,
    windowMinutes: threshold.windowMinutes,
  });

  throw new LlmSafetyError(threshold.code, message);
}
