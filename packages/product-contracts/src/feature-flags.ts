/**
 * PR-0b: Feature Flag typed contract.
 *
 * 클라 (RN) 와 Edge Function (Deno) 양쪽이 동일 알고리즘으로 평가하도록 SHA-1
 * 기반 sticky ramp 구현. 같은 사용자/install 은 한 번 ramp 들어가면 계속 들어감.
 *
 * 사용:
 * ```ts
 * import { resolveFeatureFlag, type FlagId } from '@fortune/product-contracts';
 *
 * const enabled = resolveFeatureFlag(
 *   'haneul_enabled',
 *   { ramp_pct: 5, default_value: false, target_value: true },
 *   { userId: '...', installId: '...' },
 * );
 * ```
 */

export type FlagId =
  | 'haneul_enabled'
  | 'haneul_fortune_enabled'
  | 'direct_chips_enabled'
  | 'fortune_route_behavior';

export type FlagSafetyClass = 'visibility' | 'safety' | 'route';

export type FlagValue = boolean | string;

/**
 * DB 의 feature_flag_config row 와 동일 형태.
 */
export interface FlagConfig<T extends FlagValue = FlagValue> {
  flag_name: FlagId;
  ramp_pct: number; // 0..100
  default_value: T;
  target_value: T;
  safety_class: FlagSafetyClass;
  config_version: number;
  /** 서버가 반환하는 ISO timestamp. 클라 캐시 무효화 비교용. */
  updated_at?: string;
}

/**
 * sticky ramp 평가에 필요한 사용자 식별자.
 */
export interface RampIdentity {
  /** Supabase userId (있으면 우선). 로그아웃 상태면 null/undefined. */
  userId?: string | null;
  /** install / device id (anon 사용자 fallback). */
  installId: string;
}

/**
 * 4 flag 의 클라 측 메타데이터 — TTL/refresh trigger 결정에 사용.
 */
export interface FlagClientMeta {
  id: FlagId;
  safetyClass: FlagSafetyClass;
  /** 클라 메모리/AsyncStorage 캐시 TTL. visibility=30분, safety/route=60초. */
  clientCacheTtlSec: number;
  /** Edge 측 in-memory 캐시 TTL. */
  edgeCacheTtlSec: number;
  /** 캐시 fetch 실패 시 fail-closed (default 강제) 여부. true 면 default 우선. */
  failClosed: boolean;
  /** 어떤 이벤트에서 강제 refresh 할지. */
  refreshTriggers: ReadonlyArray<
    'app_foreground' | 'route_entry' | 'pre_paid_action' | 'config_version_bump'
  >;
  /** 의존 그래프 — 의존 flag 가 false 면 본 flag 도 default 강제 (다운그레이드). */
  dependsOn?: ReadonlyArray<FlagId>;
}

export const FLAG_CLIENT_META: Readonly<Record<FlagId, FlagClientMeta>> = {
  haneul_enabled: {
    id: 'haneul_enabled',
    safetyClass: 'visibility',
    clientCacheTtlSec: 30 * 60,
    edgeCacheTtlSec: 5 * 60,
    failClosed: true,
    refreshTriggers: ['app_foreground', 'config_version_bump'],
  },
  haneul_fortune_enabled: {
    id: 'haneul_fortune_enabled',
    safetyClass: 'safety',
    clientCacheTtlSec: 60,
    edgeCacheTtlSec: 30,
    failClosed: true,
    refreshTriggers: ['route_entry', 'pre_paid_action', 'config_version_bump'],
    dependsOn: ['haneul_enabled'],
  },
  direct_chips_enabled: {
    id: 'direct_chips_enabled',
    safetyClass: 'safety',
    clientCacheTtlSec: 60,
    edgeCacheTtlSec: 30,
    failClosed: true,
    refreshTriggers: ['route_entry', 'pre_paid_action', 'config_version_bump'],
    dependsOn: ['haneul_fortune_enabled'],
  },
  fortune_route_behavior: {
    id: 'fortune_route_behavior',
    safetyClass: 'route',
    clientCacheTtlSec: 60,
    edgeCacheTtlSec: 30,
    failClosed: true,
    refreshTriggers: ['route_entry', 'config_version_bump'],
    // dependsOn: 'haneul_fortune_enabled' (only in redirect_to_haneul mode — 평가 함수에서 처리)
  },
};

/**
 * SHA-1 first-8-hex → 0..2^32-1 → mod 10000 → 0..9999.
 * ramp_pct=5 면 buckets [0..499] 가 in-ramp.
 *
 * 환경 의존성 회피: 호출자가 sha1 함수를 주입한다 (RN: expo-crypto, Edge: Deno crypto).
 */
export function bucketFromHashHex(hashHex: string): number {
  // 첫 8 hex (= 32 bit) 만 사용.
  const slice = hashHex.slice(0, 8);
  const num = parseInt(slice, 16);
  if (!Number.isFinite(num)) return 0;
  return num % 10000;
}

/**
 * sticky ramp 결정. 호출자가 sha1Hex 함수를 주입.
 * - userId 우선, 없으면 `install:${installId}` 사용
 * - 결과는 deterministic — 같은 (flagName, identity) 는 항상 같은 bucket
 */
export function isInRamp(
  flagName: FlagId,
  rampPct: number,
  identity: RampIdentity,
  sha1Hex: (input: string) => string,
): boolean {
  if (rampPct <= 0) return false;
  if (rampPct >= 100) return true;
  const id = identity.userId ?? `install:${identity.installId}`;
  const hashHex = sha1Hex(`${flagName}:${id}`);
  const bucket = bucketFromHashHex(hashHex);
  return bucket < rampPct * 100;
}

/**
 * Flag 값 평가 — config + identity → 실제 사용자에게 보여줄 값.
 *
 * @param sha1Hex SHA-1 hash function. RN 은 expo-crypto, Edge 는 Deno std/crypto.
 */
export function resolveFeatureFlag<T extends FlagValue>(
  flagName: FlagId,
  config: Pick<FlagConfig<T>, 'ramp_pct' | 'default_value' | 'target_value'>,
  identity: RampIdentity,
  sha1Hex: (input: string) => string,
): T {
  return isInRamp(flagName, config.ramp_pct, identity, sha1Hex)
    ? config.target_value
    : config.default_value;
}

/**
 * 의존 그래프 다운그레이드 — 의존 flag 가 default 면 본 flag 도 default 강제.
 *
 * 예: fortune_route_behavior=redirect_to_haneul + haneul_fortune_enabled=false
 *     → 자동 'legacy' 다운그레이드 (불가능한 상태 거름).
 */
export function downgradeIfDepsUnmet<T extends FlagValue>(
  flagName: FlagId,
  resolvedValue: T,
  resolvedFlags: Partial<Record<FlagId, FlagValue>>,
  defaultValue: T,
): T {
  const meta = FLAG_CLIENT_META[flagName];
  if (!meta.dependsOn || meta.dependsOn.length === 0) {
    return resolvedValue;
  }
  for (const depId of meta.dependsOn) {
    const depValue = resolvedFlags[depId];
    if (depValue === undefined) continue; // 의존 flag 정보 없음 — 그대로 둠
    const depMeta = FLAG_CLIENT_META[depId];
    // 의존 flag 가 boolean 인 경우만 체크 (현재 모든 dependsOn 은 boolean)
    if (depMeta.safetyClass !== 'route' && depValue === false) {
      return defaultValue;
    }
  }
  return resolvedValue;
}

/**
 * fortune_route_behavior 의 특수 의존성 — `redirect_to_haneul` 일 때만
 * `haneul_fortune_enabled=true` 필요. legacy/disabled 는 의존 없음.
 */
export function downgradeFortuneRouteBehavior(
  resolvedValue: string,
  haneulFortuneEnabled: boolean | undefined,
): string {
  if (resolvedValue === 'redirect_to_haneul' && haneulFortuneEnabled === false) {
    return 'legacy';
  }
  return resolvedValue;
}
