// PR-0b: Feature Flag — Edge Function 헬퍼.
// product-contracts/src/feature-flags.ts 와 동일 알고리즘 (SHA-1 sticky ramp).
// Deno 환경이라 crypto.subtle 으로 sha1 구현.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export type FlagId =
  | "haneul_enabled"
  | "haneul_fortune_enabled"
  | "direct_chips_enabled"
  | "fortune_route_behavior";

export type FlagSafetyClass = "visibility" | "safety" | "route";

export type FlagValue = boolean | string;

export interface FlagConfig<T extends FlagValue = FlagValue> {
  flag_name: FlagId;
  ramp_pct: number;
  default_value: T;
  target_value: T;
  safety_class: FlagSafetyClass;
  config_version: number;
  updated_at?: string;
}

export interface RampIdentity {
  userId?: string | null;
  installId: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// Edge 측 in-memory 캐시 (cold start 비용 줄이기)
// ─────────────────────────────────────────────────────────────────────────────
// per-flag TTL 차등: visibility 5분, safety/route 30초.
// kill switch: config_version 변경 시 클라가 재요청 → Edge 도 캐시 expired.
//
// 주의: Edge Function 은 instance 단위 격리라 cache 가 fresh deploy / cold restart
// 시 reset. 이는 의도된 동작 (P0 takedown 빠른 전파).

interface CachedFlag<T extends FlagValue = FlagValue> {
  config: FlagConfig<T>;
  fetchedAt: number; // ms
}

const flagCache = new Map<FlagId, CachedFlag>();

// /codex review P1: safety/route flag 은 P0 takedown 이 즉시 전파돼야 한다.
// 30초 캐시 = 30초 stale → 결제 게이팅 같은 안전성 flag 가 계속 켜짐. 짧게 둠.
// visibility 는 P0 영향 낮으니 5분 그대로.
const TTL_BY_SAFETY_CLASS: Record<FlagSafetyClass, number> = {
  visibility: 5 * 60 * 1000,
  safety: 5 * 1000, // 5초 — Edge instance 고빈도 DB 호출 방지하면서 P0 빠른 전파
  route: 5 * 1000,
};

// ─────────────────────────────────────────────────────────────────────────────
// SHA-1 (Deno Web Crypto)
// ─────────────────────────────────────────────────────────────────────────────

async function sha1Hex(input: string): Promise<string> {
  const enc = new TextEncoder().encode(input);
  const buf = await crypto.subtle.digest("SHA-1", enc);
  const bytes = new Uint8Array(buf);
  let hex = "";
  for (const b of bytes) {
    hex += b.toString(16).padStart(2, "0");
  }
  return hex;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky ramp
// ─────────────────────────────────────────────────────────────────────────────

function bucketFromHashHex(hashHex: string): number {
  const slice = hashHex.slice(0, 8);
  const num = parseInt(slice, 16);
  if (!Number.isFinite(num)) return 0;
  return num % 10000;
}

export async function isInRamp(
  flagName: FlagId,
  rampPct: number,
  identity: RampIdentity,
): Promise<boolean> {
  if (rampPct <= 0) return false;
  if (rampPct >= 100) return true;
  const id = identity.userId ?? `install:${identity.installId}`;
  const hashHex = await sha1Hex(`${flagName}:${id}`);
  const bucket = bucketFromHashHex(hashHex);
  return bucket < rampPct * 100;
}

// ─────────────────────────────────────────────────────────────────────────────
// Flag fetch + resolve
// ─────────────────────────────────────────────────────────────────────────────

async function fetchFlagConfig(
  supabase: SupabaseClient,
  flagName: FlagId,
): Promise<FlagConfig | null> {
  const { data, error } = await supabase
    .from("feature_flag_config")
    .select(
      "flag_name, ramp_pct, default_value, target_value, safety_class, config_version, updated_at",
    )
    .eq("flag_name", flagName)
    .maybeSingle();

  if (error) {
    console.error(
      `[feature_flags] fetch 실패 — flag=${flagName}:`,
      error.message,
    );
    return null;
  }
  if (!data) return null;

  return data as FlagConfig;
}

/**
 * 캐시 적용된 flag fetch. TTL 만료 시 재조회.
 */
export async function getFlagConfig(
  supabase: SupabaseClient,
  flagName: FlagId,
): Promise<FlagConfig | null> {
  const cached = flagCache.get(flagName);
  const now = Date.now();
  if (cached) {
    const ttl = TTL_BY_SAFETY_CLASS[cached.config.safety_class];
    if (now - cached.fetchedAt < ttl) {
      return cached.config;
    }
  }

  const fresh = await fetchFlagConfig(supabase, flagName);
  if (fresh) {
    flagCache.set(flagName, { config: fresh, fetchedAt: now });
  }
  return fresh;
}

/**
 * 사용자에게 보여줄 flag 값 — sticky ramp 평가.
 * fetch/평가 실패 시 fail-closed (default_value 강제).
 *
 * @returns flag 값 + (있으면) DB 의 config_version. 호출자가 응답에 같이 담아 클라에게.
 */
export async function resolveFlag<T extends FlagValue>(
  supabase: SupabaseClient,
  flagName: FlagId,
  identity: RampIdentity,
  fallback: T,
): Promise<{ value: T; configVersion: number; rampPct: number }> {
  const config = await getFlagConfig(supabase, flagName);
  if (!config) {
    return { value: fallback, configVersion: 0, rampPct: 0 };
  }

  try {
    const inRamp = await isInRamp(flagName, config.ramp_pct, identity);
    const value = (inRamp ? config.target_value : config.default_value) as T;
    return {
      value,
      configVersion: config.config_version,
      rampPct: config.ramp_pct,
    };
  } catch (err) {
    console.error(
      `[feature_flags] resolve 실패 — flag=${flagName}:`,
      (err as Error).message ?? err,
    );
    return { value: fallback, configVersion: config.config_version, rampPct: config.ramp_pct };
  }
}

/**
 * 4 flag 한 번에 — 클라가 부팅/foreground 시 일괄 요청.
 */
export async function resolveAllFlags(
  supabase: SupabaseClient,
  identity: RampIdentity,
): Promise<{
  flags: Record<FlagId, FlagValue>;
  versions: Record<FlagId, number>;
  rampPcts: Record<FlagId, number>;
}> {
  const ids: FlagId[] = [
    "haneul_enabled",
    "haneul_fortune_enabled",
    "direct_chips_enabled",
    "fortune_route_behavior",
  ];

  const fallbacks: Record<FlagId, FlagValue> = {
    haneul_enabled: false,
    haneul_fortune_enabled: false,
    direct_chips_enabled: false,
    fortune_route_behavior: "legacy",
  };

  const flags: Record<string, FlagValue> = {};
  const versions: Record<string, number> = {};
  const rampPcts: Record<string, number> = {};

  for (const id of ids) {
    const result = await resolveFlag(supabase, id, identity, fallbacks[id]);
    flags[id] = result.value;
    versions[id] = result.configVersion;
    rampPcts[id] = result.rampPct;
  }

  // /codex review P2: 의존 그래프 다운그레이드.
  // 각 flag 가 독립 hash 로 평가돼서 자식 flag 가 부모 false 일 때도 true 가능.
  // 의존이 끊어진 자식은 default 강제 — 안전성 flag 단독 노출 차단.
  //
  // 의존 그래프 (FLAG_CLIENT_META 와 동일):
  //   haneul_fortune_enabled  → haneul_enabled
  //   direct_chips_enabled    → haneul_fortune_enabled (≒ haneul_enabled 도)
  //   fortune_route_behavior  → (redirect_to_haneul 일 때만) haneul_fortune_enabled

  // 1) haneul_fortune_enabled 가 켜졌는데 haneul_enabled 가 꺼진 경우
  if (flags.haneul_fortune_enabled === true && flags.haneul_enabled === false) {
    flags.haneul_fortune_enabled = false;
  }

  // 2) direct_chips_enabled 는 haneul_fortune_enabled 의존
  //    위에서 재계산된 값을 사용 (cascade)
  if (
    flags.direct_chips_enabled === true &&
    flags.haneul_fortune_enabled === false
  ) {
    flags.direct_chips_enabled = false;
  }

  // 3) fortune_route_behavior — redirect_to_haneul 모드 전용 의존
  if (
    flags.fortune_route_behavior === "redirect_to_haneul" &&
    flags.haneul_fortune_enabled === false
  ) {
    flags.fortune_route_behavior = "legacy";
  }

  return {
    flags: flags as Record<FlagId, FlagValue>,
    versions: versions as Record<FlagId, number>,
    rampPcts: rampPcts as Record<FlagId, number>,
  };
}
