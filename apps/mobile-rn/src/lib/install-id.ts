/**
 * PR-0b: 디바이스/install 단위 unique ID — feature flag sticky ramp 의 fallback
 * (userId 없는 anon 사용자에게도 같은 ramp bucket 보장).
 *
 * 첫 호출 시 UUID 생성 후 SecureStore 영속. 같은 디바이스에서 재호출하면 같은 값.
 * 앱 재설치 시 재생성 (의도된 동작 — 디바이스 간 sticky 가 아니라 install 단위).
 */

import * as Crypto from 'expo-crypto';

import { getSecureItem, setSecureItem } from './secure-store-storage';

const INSTALL_ID_KEY = 'fortune.install_id';

let cachedInstallId: string | null = null;

export async function getInstallId(): Promise<string> {
  if (cachedInstallId) {
    return cachedInstallId;
  }

  try {
    const stored = await getSecureItem(INSTALL_ID_KEY);
    if (stored && typeof stored === 'string' && stored.length > 0) {
      cachedInstallId = stored;
      return stored;
    }
  } catch {
    // SecureStore 읽기 실패 — 새로 생성하고 진행
  }

  const next = Crypto.randomUUID();
  try {
    await setSecureItem(INSTALL_ID_KEY, next);
  } catch {
    // 쓰기 실패 — in-memory 만으로 세션 동안 유지
  }
  cachedInstallId = next;
  return next;
}

/** 테스트용 — 캐시 리셋. 프로덕션에서는 사용 X. */
export function _resetInstallIdCacheForTest(): void {
  cachedInstallId = null;
}
