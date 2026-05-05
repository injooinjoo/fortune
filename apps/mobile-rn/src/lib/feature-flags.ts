/**
 * PR-0b: Feature Flag — RN 클라 측 fetch + cache + hooks.
 *
 * 디자인:
 * - Edge Function `feature-flags-resolve` 가 실제 sticky-ramp 평가 (SHA-1)
 * - 클라는 결과 캐시 + safety class 별 TTL 적용
 * - visibility flag 는 30분 캐시, safety/route 는 60초
 * - fetch 실패 시 visibility 만 last-known sticky, safety/route 는 default 강제 (fail-closed)
 * - config_version 변경 감지 시 즉시 재요청 (kill switch)
 *
 * 사용:
 * ```tsx
 * const { value, loading } = useFeatureFlag('haneul_enabled');
 * if (value) { ... }
 * ```
 */

import { useEffect, useMemo, useState } from 'react';

import {
  FLAG_CLIENT_META,
  type FlagId,
  type FlagValue,
} from '@fortune/product-contracts';

import { appEnv } from './env';
import { captureError } from './error-reporting';
import { getInstallId } from './install-id';
import { supabase } from './supabase';

const STORAGE_KEY = 'fortune.feature_flags.cache_v1';

interface FlagSnapshot {
  flags: Record<FlagId, FlagValue>;
  versions: Record<FlagId, number>;
  rampPcts: Record<FlagId, number>;
  resolvedAt: string; // ISO
  fetchedAtMs: number; // 클라 시계
}

const DEFAULT_FLAGS: Record<FlagId, FlagValue> = {
  haneul_enabled: false,
  haneul_fortune_enabled: false,
  direct_chips_enabled: false,
  fortune_route_behavior: 'legacy',
};

function emptySnapshot(): FlagSnapshot {
  return {
    flags: { ...DEFAULT_FLAGS },
    versions: {
      haneul_enabled: 0,
      haneul_fortune_enabled: 0,
      direct_chips_enabled: 0,
      fortune_route_behavior: 0,
    },
    rampPcts: {
      haneul_enabled: 0,
      haneul_fortune_enabled: 0,
      direct_chips_enabled: 0,
      fortune_route_behavior: 0,
    },
    resolvedAt: '',
    fetchedAtMs: 0,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Singleton snapshot + listeners
// ─────────────────────────────────────────────────────────────────────────────

let currentSnapshot: FlagSnapshot = emptySnapshot();
const listeners = new Set<(s: FlagSnapshot) => void>();
let inFlightFetch: Promise<FlagSnapshot> | null = null;

function notify() {
  for (const fn of listeners) {
    try {
      fn(currentSnapshot);
    } catch {
      // listener 에러는 무시
    }
  }
}

function setSnapshot(next: FlagSnapshot) {
  currentSnapshot = next;
  notify();
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch
// ─────────────────────────────────────────────────────────────────────────────

interface FetchResponse {
  flags: Record<FlagId, FlagValue>;
  versions: Record<FlagId, number>;
  rampPcts: Record<FlagId, number>;
  resolvedAt: string;
}

async function callResolveEndpoint(): Promise<FetchResponse | null> {
  if (!appEnv.isSupabaseConfigured) return null;

  try {
    const installId = await getInstallId();

    // Authorization 옵션 — 로그인 상태면 user JWT, 아니면 anon
    if (!supabase) return null;
    const { data: { session } } = await supabase.auth.getSession();
    const headers: Record<string, string> = {
      apikey: appEnv.supabaseAnonKey,
      'Content-Type': 'application/json',
    };
    if (session?.access_token) {
      headers.Authorization = `Bearer ${session.access_token}`;
    } else {
      headers.Authorization = `Bearer ${appEnv.supabaseAnonKey}`;
    }

    const resp = await fetch(
      `${appEnv.supabaseUrl}/functions/v1/feature-flags-resolve`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify({ installId }),
      },
    );

    if (!resp.ok) {
      return null;
    }

    const json = (await resp.json()) as FetchResponse;
    return json;
  } catch (err) {
    captureError(err, { surface: 'feature-flags:fetch' }).catch(() => undefined);
    return null;
  }
}

/**
 * 강제 fetch — 캐시 무시. config_version_bump 트리거 또는 cost gate 직전 호출.
 */
export async function refreshFeatureFlags(): Promise<FlagSnapshot> {
  if (inFlightFetch) return inFlightFetch;

  inFlightFetch = (async () => {
    const fetched = await callResolveEndpoint();
    const now = Date.now();

    if (!fetched) {
      // fail-closed: visibility 는 last-known 유지, safety/route 는 default 강제
      const fallbackFlags: Record<FlagId, FlagValue> = { ...currentSnapshot.flags };
      for (const id of Object.keys(FLAG_CLIENT_META) as FlagId[]) {
        const meta = FLAG_CLIENT_META[id];
        if (meta.safetyClass !== 'visibility') {
          fallbackFlags[id] = DEFAULT_FLAGS[id];
        }
      }
      const snapshot: FlagSnapshot = {
        ...currentSnapshot,
        flags: fallbackFlags,
        fetchedAtMs: now,
      };
      setSnapshot(snapshot);
      return snapshot;
    }

    const snapshot: FlagSnapshot = {
      flags: fetched.flags,
      versions: fetched.versions,
      rampPcts: fetched.rampPcts,
      resolvedAt: fetched.resolvedAt,
      fetchedAtMs: now,
    };
    setSnapshot(snapshot);
    return snapshot;
  })().finally(() => {
    inFlightFetch = null;
  });

  return inFlightFetch;
}

/**
 * TTL 기반 fetch — 만료된 flag 가 있으면 재조회, 모두 fresh 면 캐시 그대로.
 */
async function ensureFreshIfNeeded(): Promise<FlagSnapshot> {
  const now = Date.now();
  if (currentSnapshot.fetchedAtMs === 0) {
    return refreshFeatureFlags();
  }

  // 가장 짧은 TTL 의 flag 가 만료됐으면 전체 refresh.
  // 실제로는 flag 별 다른 TTL 적용이 좀 복잡한데, 단순화: 보수적으로 가장 짧은 TTL 기준.
  const ageMs = now - currentSnapshot.fetchedAtMs;
  const minTtlSec = Math.min(
    ...Object.values(FLAG_CLIENT_META).map((m) => m.clientCacheTtlSec),
  );
  if (ageMs > minTtlSec * 1000) {
    return refreshFeatureFlags();
  }

  return currentSnapshot;
}

/**
 * Refresh trigger — 호출자가 의미 있는 시점에 호출 (ROUTE_ENTRY, PRE_PAID_ACTION 등).
 * 보수적으로 항상 강제 refresh.
 */
export async function refreshOnTrigger(
  trigger: 'app_foreground' | 'route_entry' | 'pre_paid_action' | 'config_version_bump',
): Promise<FlagSnapshot> {
  // 모든 트리거에서 강제 refresh — 캐시 무시.
  // 향후 트리거 별 fine-grained 차등 가능 (예: app_foreground 는 visibility 만).
  void trigger;
  return refreshFeatureFlags();
}

// ─────────────────────────────────────────────────────────────────────────────
// React hook
// ─────────────────────────────────────────────────────────────────────────────

export interface UseFeatureFlagResult<T extends FlagValue = FlagValue> {
  value: T;
  loading: boolean;
  rampPct: number;
  configVersion: number;
}

/**
 * Boolean flag 용. 첫 렌더 시 default(false) 반환 + 비동기 fetch.
 */
export function useFeatureFlag<T extends FlagValue = boolean>(
  flagId: FlagId,
): UseFeatureFlagResult<T> {
  const [snapshot, setLocalSnapshot] = useState<FlagSnapshot>(currentSnapshot);

  useEffect(() => {
    const listener = (s: FlagSnapshot) => setLocalSnapshot(s);
    listeners.add(listener);

    // mount 시점에 fresh 확보
    void ensureFreshIfNeeded();

    return () => {
      listeners.delete(listener);
    };
  }, []);

  return useMemo(() => {
    const value = snapshot.flags[flagId] ?? DEFAULT_FLAGS[flagId];
    return {
      value: value as T,
      loading: snapshot.fetchedAtMs === 0,
      rampPct: snapshot.rampPcts[flagId] ?? 0,
      configVersion: snapshot.versions[flagId] ?? 0,
    };
  }, [snapshot, flagId]);
}

/**
 * 동기 readonly 접근 — 컴포넌트가 아닌 곳 (e.g. Edge call 직전 last-known check) 에서.
 * Hook 사용 권장. 이 함수는 마지막 fetch 결과 그대로 (stale 가능).
 */
export function getFeatureFlagSnapshot(): FlagSnapshot {
  return currentSnapshot;
}

/**
 * 테스트/디버그 — 외부에서 snapshot 강제 주입.
 */
export function _setFeatureFlagSnapshotForTest(s: FlagSnapshot): void {
  currentSnapshot = s;
  notify();
}

// ─────────────────────────────────────────────────────────────────────────────
// Bootstrap
// ─────────────────────────────────────────────────────────────────────────────

/**
 * 앱 부팅 시 한 번 호출 — 백그라운드 fetch 시작.
 * AsyncStorage 영속 캐시 (앱 재시작 후에도 last-known 즉시 사용 가능) 는 향후 추가.
 */
export async function bootstrapFeatureFlags(): Promise<void> {
  try {
    await refreshFeatureFlags();
  } catch (err) {
    captureError(err, { surface: 'feature-flags:bootstrap' }).catch(() => undefined);
  }
}
