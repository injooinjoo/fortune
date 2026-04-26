import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';

const isWeb = Platform.OS === 'web';

// SecureStore 는 iOS Keychain / Android EncryptedSharedPreferences 에서 키당
// ~2048 바이트 한도. UTF-8 기준 바이트 크기를 재서 chunk 를 나눠야 한다. 한글
// 같이 3바이트 차지하는 문자가 많을 경우 문자 수 기준으로 자르면 금방 바이트
// 한도를 넘어감.
// 안전 여유 두고 1800 bytes 로 제한 (2048 - 여유 248).
const secureStoreChunkBytes = 1800;

// === Atomic 2-version (double-buffer) chunk layout ===
// 옛 layout (`.__chunk_count` + `.__chunk_<i>`) 은 multi-chunk write 도중
// 앱 재시작/OTA reloadAsync/crash 가 떨어지면 옛 chunks 는 이미 지웠는데 새
// chunks 는 안 써져서 데이터가 통째로 사라지는 결함이 있었다 (러츠 등 모든
// 캐릭터 대화 기록 wipe 회귀의 원인). 새 layout 은 active version pointer 를
// 단일 atomic write 로 swap 해서 어느 시점 interrupt 가 떨어져도 옛/새 한
// 쪽이 항상 온전하게 보존된다.
//   {key}.__active_v        → "0" / "1"   (단일 atomic commit point)
//   {key}.__v0.count        → 버전 0 의 chunk 개수
//   {key}.__v0.chunk.<i>    → 버전 0 의 chunk <i>
//   {key}.__v1.count, .chunk.<i> → 버전 1
// 옛 데이터 (legacy `.__chunk_count` + `.__chunk_<i>` + un-chunked plain key)
// 는 read 경로에서 fallback 으로 계속 지원 — 다음 write 시 새 layout 으로
// 자연스럽게 마이그레이션.
const ACTIVE_VERSION_SUFFIX = '.__active_v';
const VERSION_COUNT_SUFFIX = (v: 0 | 1) => `.__v${v}.count`;
const VERSION_CHUNK_SUFFIX = (v: 0 | 1, index: number) =>
  `.__v${v}.chunk.${index}`;

// Legacy (non-atomic) layout — read-only fallback for data written before
// the atomic layout migration.
const legacyChunkCountSuffix = '.__chunk_count';
const legacyChunkItemPrefix = '.__chunk_';

function resolveActiveVersionKey(key: string) {
  return `${key}${ACTIVE_VERSION_SUFFIX}`;
}

function resolveVersionCountKey(key: string, v: 0 | 1) {
  return `${key}${VERSION_COUNT_SUFFIX(v)}`;
}

function resolveVersionChunkKey(key: string, v: 0 | 1, index: number) {
  return `${key}${VERSION_CHUNK_SUFFIX(v, index)}`;
}

function resolveLegacyCountKey(key: string) {
  return `${key}${legacyChunkCountSuffix}`;
}

function resolveLegacyChunkKey(key: string, index: number) {
  return `${key}${legacyChunkItemPrefix}${index}`;
}

function normalizeChunkCount(value: string | null) {
  if (!value) {
    return 0;
  }

  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
}

async function readActiveVersion(key: string): Promise<0 | 1 | null> {
  const raw = await SecureStore.getItemAsync(resolveActiveVersionKey(key));
  if (raw === '0') return 0;
  if (raw === '1') return 1;
  return null;
}

async function readLegacyChunkCount(key: string) {
  return normalizeChunkCount(
    await SecureStore.getItemAsync(resolveLegacyCountKey(key)),
  );
}

async function clearLegacyChunkedValue(key: string) {
  const chunkCount = await readLegacyChunkCount(key);

  if (chunkCount === 0) {
    return;
  }

  for (let index = 0; index < chunkCount; index += 1) {
    await SecureStore.deleteItemAsync(resolveLegacyChunkKey(key, index));
  }

  await SecureStore.deleteItemAsync(resolveLegacyCountKey(key));
}

async function clearVersionChunks(key: string, v: 0 | 1) {
  const count = normalizeChunkCount(
    await SecureStore.getItemAsync(resolveVersionCountKey(key, v)),
  );

  for (let index = 0; index < count; index += 1) {
    await SecureStore.deleteItemAsync(resolveVersionChunkKey(key, v, index));
  }

  if (count > 0) {
    await SecureStore.deleteItemAsync(resolveVersionCountKey(key, v));
  }
}

async function readVersionedValue(key: string, v: 0 | 1): Promise<string | null> {
  const count = normalizeChunkCount(
    await SecureStore.getItemAsync(resolveVersionCountKey(key, v)),
  );

  if (count === 0) {
    return null;
  }

  let value = '';
  for (let index = 0; index < count; index += 1) {
    const chunk = await SecureStore.getItemAsync(
      resolveVersionChunkKey(key, v, index),
    );
    if (typeof chunk !== 'string') {
      // Partial / interrupted write detected on this version — caller should
      // fall back to the other version (or legacy/un-chunked).
      return null;
    }
    value += chunk;
  }
  return value;
}

function byteLength(s: string): number {
  // UTF-8 인코딩 후의 바이트 수.
  // 대부분 환경에서 TextEncoder 사용 가능 (RN Hermes 포함).
  try {
    return new TextEncoder().encode(s).length;
  } catch {
    // fallback — 모든 문자를 3바이트로 가정 (한글 worst case).
    return s.length * 3;
  }
}

function splitIntoChunks(value: string) {
  const chunks: string[] = [];
  if (byteLength(value) <= secureStoreChunkBytes) {
    chunks.push(value);
    return chunks;
  }

  // 문자 단위로 잘라가며 바이트 누적. 서로게이트 쌍/이모지가 조각나지 않도록
  // 문자 기준으로 자르되 누적 바이트가 한도에 도달하면 새 chunk 시작.
  let current = '';
  let currentBytes = 0;
  for (const ch of value) {
    const chBytes = byteLength(ch);
    if (currentBytes + chBytes > secureStoreChunkBytes && current.length > 0) {
      chunks.push(current);
      current = '';
      currentBytes = 0;
    }
    current += ch;
    currentBytes += chBytes;
  }
  if (current.length > 0) chunks.push(current);

  return chunks;
}

export async function getSecureItem(key: string) {
  if (isWeb) {
    return localStorage.getItem(key);
  }

  // Read 우선순위: active version → 옛 (다른) version (active write 도중
  // 인터럽트 났을 가능성) → legacy chunk_count layout → un-chunked plain key.
  const active = await readActiveVersion(key);

  if (active !== null) {
    const fromActive = await readVersionedValue(key, active);
    if (fromActive !== null) {
      return fromActive;
    }

    // active version 의 chunks 가 partial 이면 다른 버전을 시도. 정상 운영
    // 에선 거의 없는 경로지만, active pointer 만 commit 되고 chunks 가 미처
    // 다 안 써졌을 때 (전원 차단 같은 케이스) 옛 version 으로라도 복원.
    const fallback = active === 0 ? 1 : 0;
    const fromFallback = await readVersionedValue(key, fallback);
    if (fromFallback !== null) {
      return fromFallback;
    }
  }

  // Legacy fallback — 옛 layout 으로 저장된 데이터 (마이그레이션 전 write).
  const legacyCount = await readLegacyChunkCount(key);
  if (legacyCount > 0) {
    let value = '';
    for (let index = 0; index < legacyCount; index += 1) {
      const chunk = await SecureStore.getItemAsync(
        resolveLegacyChunkKey(key, index),
      );
      if (typeof chunk !== 'string') return null;
      value += chunk;
    }
    return value;
  }

  // Un-chunked plain value (작은 데이터 또는 첫 write 안 된 키).
  return SecureStore.getItemAsync(key);
}

export async function setSecureItem(key: string, value: string) {
  if (isWeb) {
    localStorage.setItem(key, value);
    return;
  }

  const chunks = splitIntoChunks(value);

  // Single chunk: un-chunked plain key 에 직접 쓰기 — SecureStore.setItemAsync
  // 자체가 atomic 이라 안전. 옛 layout (legacy chunks + version chunks +
  // active pointer) 은 best-effort cleanup. cleanup 도중 인터럽트 나도
  // un-chunked 값이 이미 commit 됐으므로 read 는 정상.
  if (chunks.length <= 1) {
    await SecureStore.setItemAsync(key, value);
    // Cleanup 옛 layout — 실패해도 무시 (orphan 은 다음 write 때 재정리).
    await SecureStore.deleteItemAsync(resolveActiveVersionKey(key)).catch(
      () => undefined,
    );
    await clearVersionChunks(key, 0).catch(() => undefined);
    await clearVersionChunks(key, 1).catch(() => undefined);
    await clearLegacyChunkedValue(key).catch(() => undefined);
    return;
  }

  // Multi-chunk: 새 version 슬롯에 쓰고, active pointer 를 swap (atomic
  // commit), 그 다음 옛 version cleanup. interrupt 가 commit 전이면 옛
  // version 이 그대로 보존되고, commit 후면 새 version 이 보존.
  const currentActive = await readActiveVersion(key);
  const targetVersion: 0 | 1 = currentActive === 0 ? 1 : 0;

  // 새 version 슬롯에 옛 leftover 가 있으면 먼저 비움 (혹시 모를 stale).
  await clearVersionChunks(key, targetVersion).catch(() => undefined);

  // 1) 새 version chunks 쓰기
  for (let index = 0; index < chunks.length; index += 1) {
    await SecureStore.setItemAsync(
      resolveVersionChunkKey(key, targetVersion, index),
      chunks[index],
    );
  }

  // 2) chunk count 쓰기 (이 시점까진 active pointer 는 옛 version 가리킴 —
  // read 는 여전히 옛 데이터 반환)
  await SecureStore.setItemAsync(
    resolveVersionCountKey(key, targetVersion),
    String(chunks.length),
  );

  // 3) **ATOMIC COMMIT** — active pointer swap. 이 한 줄이 전체 write 의
  // commit point. 이전엔 옛 데이터, 이후엔 새 데이터.
  await SecureStore.setItemAsync(
    resolveActiveVersionKey(key),
    String(targetVersion),
  );

  // 4) 옛 version cleanup + legacy / un-chunked cleanup. 실패해도 무시 —
  // active pointer 가 이미 새 version 을 가리키므로 read 는 안전.
  if (currentActive !== null) {
    await clearVersionChunks(key, currentActive).catch(() => undefined);
  }
  await clearLegacyChunkedValue(key).catch(() => undefined);
  await SecureStore.deleteItemAsync(key).catch(() => undefined);
}

export async function deleteSecureItem(key: string) {
  if (isWeb) {
    localStorage.removeItem(key);
    return;
  }

  await SecureStore.deleteItemAsync(key);
  await SecureStore.deleteItemAsync(resolveActiveVersionKey(key)).catch(
    () => undefined,
  );
  await clearVersionChunks(key, 0).catch(() => undefined);
  await clearVersionChunks(key, 1).catch(() => undefined);
  await clearLegacyChunkedValue(key).catch(() => undefined);
}
