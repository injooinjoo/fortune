/**
 * PR-0c: Feature Flag exposure batch dispatcher.
 *
 * 클라 5개 surface 에서 호출 → 메모리 buffer → 10 events 또는 30초마다 flush →
 * Edge Function POST. 실패는 fail-open (다음 batch 에서 재시도 안 함).
 *
 * 사용:
 * ```ts
 * await logFlagExposure({
 *   surface: 'cost_modal',
 *   flags: { haneul_enabled: true, haneul_fortune_enabled: true, ... },
 *   versions: { haneul_enabled: 5, ... },
 *   rampPcts: { haneul_enabled: 100, ... },
 * });
 * ```
 */

import type { FlagId, FlagValue } from '@fortune/product-contracts';

import { appEnv } from './env';
import { captureError } from './error-reporting';
import { getInstallId } from './install-id';
import { supabase } from './supabase';

export type FlagExposureSurface =
  | 'chat_open'
  | 'menu_render'
  | 'cost_modal'
  | 'generation'
  | 'route_redirect';

interface BufferedEvent {
  installId: string;
  /** /codex review P2: 이벤트 발생 시점의 userId 를 per-event 캡처. flush 시점의
   *  auth state 가 다를 수 있어 (anon → 로그인 / 계정 전환) flush 시 일괄 attribution
   *  하면 잘못된 사용자에게 매핑됨. */
  userId: string | null;
  flagName: FlagId;
  resolvedValue: FlagValue;
  rampPct: number;
  configVersion: number;
  surface: FlagExposureSurface;
  evaluatedAt: string; // ISO
}

const BATCH_SIZE = 10;
const FLUSH_INTERVAL_MS = 30 * 1000;
const MAX_BUFFER_SIZE = 200; // 방어적 — 폭발 방지

let buffer: BufferedEvent[] = [];
let flushTimer: ReturnType<typeof setTimeout> | null = null;

function scheduleFlush(): void {
  if (flushTimer) return;
  flushTimer = setTimeout(() => {
    flushTimer = null;
    void flushExposureBuffer();
  }, FLUSH_INTERVAL_MS);
}

/**
 * 5개 surface 호출 시점에 호출. 4 flag 모두 한꺼번에 buffer 에 push.
 */
export async function logFlagExposure(payload: {
  surface: FlagExposureSurface;
  flags: Record<FlagId, FlagValue>;
  versions: Record<FlagId, number>;
  rampPcts: Record<FlagId, number>;
}): Promise<void> {
  if (!appEnv.isSupabaseConfigured) return;

  let installId: string;
  try {
    installId = await getInstallId();
  } catch {
    return;
  }

  // /codex review P2: 이벤트 발생 시점의 user_id 캡처. flush 시점에 하면 auth 변경
  // 시 attribution 깨짐. supabase 클라가 없으면 anon 으로 기록.
  let userId: string | null = null;
  if (supabase) {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      userId = session?.user?.id ?? null;
    } catch {
      userId = null;
    }
  }

  const evaluatedAt = new Date().toISOString();

  for (const flagName of Object.keys(payload.flags) as FlagId[]) {
    if (buffer.length >= MAX_BUFFER_SIZE) {
      // buffer 폭발 방지 — 가장 오래된 event 제거
      buffer.shift();
    }
    buffer.push({
      installId,
      userId,
      flagName,
      resolvedValue: payload.flags[flagName],
      rampPct: payload.rampPcts[flagName] ?? 0,
      configVersion: payload.versions[flagName] ?? 0,
      surface: payload.surface,
      evaluatedAt,
    });
  }

  if (buffer.length >= BATCH_SIZE) {
    void flushExposureBuffer();
  } else {
    scheduleFlush();
  }
}

/**
 * 즉시 flush — buffer 비우고 Edge 호출. 호출자가 명시적으로 (e.g. 앱 background 진입 시)
 * 사용 가능. 실패는 fail-open — buffer 는 비워짐 (분석용 데이터라 손실 acceptable).
 */
export async function flushExposureBuffer(): Promise<void> {
  if (buffer.length === 0) return;

  const events = buffer.slice(0, 100); // max 100 per request
  buffer = buffer.slice(events.length);

  if (flushTimer) {
    clearTimeout(flushTimer);
    flushTimer = null;
  }

  if (!supabase) return;

  try {
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

    await fetch(
      `${appEnv.supabaseUrl}/functions/v1/feature-flag-exposure-log`,
      {
        method: 'POST',
        headers,
        body: JSON.stringify({ events }),
      },
    );
    // 응답 무시 — fail-open
  } catch (err) {
    captureError(err, { surface: 'feature-flags:exposure-flush' }).catch(() => undefined);
    // buffer 는 이미 비웠음 — 재시도 X
  }

  // 남은 buffer 가 있으면 다음 flush 예약
  if (buffer.length > 0) {
    scheduleFlush();
  }
}

/** 테스트용 — buffer 강제 리셋. */
export function _resetExposureBufferForTest(): void {
  buffer = [];
  if (flushTimer) {
    clearTimeout(flushTimer);
    flushTimer = null;
  }
}
