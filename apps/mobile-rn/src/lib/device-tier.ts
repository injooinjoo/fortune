/**
 * Device tier resolution for on-device LLM selection.
 *
 * 기기 스펙(RAM, iOS modelId, OS 버전)을 기반으로 온디바이스 LLM 변형을 고르는
 * 티어를 결정한다. 결과는 1회 판별 후 SecureStore 에 캐시되어 부팅 오버헤드
 * 최소화. `EXPO_PUBLIC_FORCE_TIER` 환경변수로 강제 오버라이드 가능 (시뮬레이터
 * 테스트용).
 */

import * as Device from 'expo-device';
import { Platform } from 'react-native';

import { getSecureItem, setSecureItem } from './secure-store-storage';

export type DeviceTier = 'flagship' | 'high' | 'mid' | 'ultra' | 'off';

// v2 — modelId 매핑 버그 수정 (iPhone 16 Pro 등) 반영하려고 이전 캐시 무효화.
const TIER_CACHE_KEY = 'ondo.device-tier.v2';
const VALID_TIERS: ReadonlyArray<DeviceTier> = [
  'flagship',
  'high',
  'mid',
  'ultra',
  'off',
];

let cachedTier: DeviceTier | null = null;
let resolvePromise: Promise<DeviceTier> | null = null;

export interface DeviceDescriptor {
  modelName: string | null;
  modelId: string | null;
  ramGB: number | null;
  osName: string | null;
  osVersion: string | null;
  isSimulator: boolean;
}

export function getDeviceDescriptor(): DeviceDescriptor {
  const totalMem = Device.totalMemory ?? null;
  return {
    modelName: Device.modelName ?? null,
    modelId: (Device.modelId as string | null) ?? null,
    ramGB: totalMem != null ? totalMem / 1_000_000_000 : null,
    osName: Device.osName ?? null,
    osVersion: Device.osVersion ?? null,
    isSimulator: !Device.isDevice,
  };
}

function readForcedTier(): DeviceTier | null {
  const raw = process.env.EXPO_PUBLIC_FORCE_TIER;
  if (!raw) return null;
  const normalized = raw.trim().toLowerCase() as DeviceTier;
  return VALID_TIERS.includes(normalized) ? normalized : null;
}

function parseOsMajor(osVersion: string | null): number {
  if (!osVersion) return 0;
  const match = osVersion.match(/^(\d+)/);
  if (!match) return 0;
  const parsed = Number.parseInt(match[1], 10);
  return Number.isFinite(parsed) ? parsed : 0;
}

function parseIosMajor(modelId: string | null): number {
  if (!modelId) return 0;
  const match = modelId.match(/iPhone(\d+)/i);
  if (!match) return 0;
  const parsed = Number.parseInt(match[1], 10);
  return Number.isFinite(parsed) ? parsed : 0;
}

function decideIosTier(): DeviceTier {
  const modelId = (Device.modelId as string | null) ?? '';
  const major = parseIosMajor(modelId);
  const osMajor = parseOsMajor(Device.osVersion);
  const ramBytes = Device.totalMemory ?? 0;
  const ramGB = ramBytes / 1_000_000_000;

  // iOS 14 이하는 llama.rn/Metal 최신 기능 신뢰 불가.
  if (osMajor > 0 && osMajor < 15) return 'off';

  // 시뮬레이터 또는 modelId 추출 실패 — 보수적으로 mid.
  if (!major) {
    if (!Device.isDevice) return 'mid';
    return 'off';
  }

  // 주의: iPhone 마케팅 이름과 하드웨어 modelId 는 한 세대씩 엇갈려 있다.
  //   iPhone 16 Pro  = iPhone17,x  (A18, 8GB)
  //   iPhone 15 Pro  = iPhone16,x  (A17 Pro, 8GB)
  //   iPhone 14 Pro  = iPhone15,x  (A16, 6GB)
  //   iPhone 13 Pro  = iPhone14,x  (A15, 6GB — 일반 13/13 mini 는 4GB)
  //   iPhone 12 Pro  = iPhone13,x  (A14, 6GB — 일반 12/12 mini 는 4GB)
  //   iPhone 11 Pro  = iPhone12,x  (A13, 4GB)
  // major 만으로는 6GB/4GB 혼재(iPhone13/14 세대)가 구분 안 되어 RAM 으로 세분화.

  // iPhone 17 Pro 이상 (A19 Pro, 12GB+) → flagship.
  if (major >= 18) return 'flagship';

  // iPhone 15 Pro / iPhone 16 전 라인 (A17 Pro / A18, 8GB) → high.
  if (major >= 16) return 'high';

  // iPhone 14 Pro / iPhone 15 전 라인 (A16, 6GB) → mid.
  if (major >= 15) return 'mid';

  // iPhone 13 (major=14) / iPhone 12 (major=13) 세대 — 6GB 와 4GB 혼재.
  // 6GB(Pro 계열, 14/14 Plus) 이상만 mid, 나머지는 ultra.
  if (major >= 13) {
    if (ramGB >= 5.5) return 'mid';
    return 'ultra';
  }

  // iPhone 11 계열 (major=12, A13, 4GB).
  if (major >= 12) return 'ultra';

  // iPhone X/XR/XS 및 그 이전 — 지원 안 함.
  return 'off';
}

function decideAndroidTier(): DeviceTier {
  const ramBytes = Device.totalMemory ?? 0;
  const ramGB = ramBytes / 1_000_000_000;
  const osMajor = parseOsMajor(Device.osVersion);

  if (ramGB >= 11 && osMajor >= 13) return 'flagship';
  if (ramGB >= 7.5 && osMajor >= 12) return 'high';
  if (ramGB >= 5.5 && osMajor >= 11) return 'mid';
  if (ramGB >= 3.5) return 'ultra';
  return 'off';
}

function decideTier(): DeviceTier {
  const forced = readForcedTier();
  if (forced) return forced;

  if (Platform.OS === 'ios') return decideIosTier();
  if (Platform.OS === 'android') return decideAndroidTier();
  return 'off';
}

async function readCachedTier(): Promise<DeviceTier | null> {
  try {
    const raw = await getSecureItem(TIER_CACHE_KEY);
    if (!raw) return null;
    const trimmed = raw.trim() as DeviceTier;
    return VALID_TIERS.includes(trimmed) ? trimmed : null;
  } catch {
    return null;
  }
}

/**
 * 동기 캐시 값 — `resolveDeviceTier()` 가 최소 1회 완료된 뒤 UI 에서 사용.
 * 완료 전이면 `null`.
 */
export function getCachedTierSync(): DeviceTier | null {
  return cachedTier;
}

export async function resolveDeviceTier(): Promise<DeviceTier> {
  if (cachedTier) return cachedTier;
  if (resolvePromise) return resolvePromise;

  const forced = readForcedTier();
  if (forced) {
    cachedTier = forced;
    return forced;
  }

  resolvePromise = (async (): Promise<DeviceTier> => {
    // SecureStore 캐시 우선.
    const stored = await readCachedTier();
    if (stored) {
      cachedTier = stored;
      return stored;
    }

    const decided = decideTier();
    cachedTier = decided;
    // best-effort 저장 — 실패해도 판별은 동작.
    setSecureItem(TIER_CACHE_KEY, decided).catch(() => undefined);
    return decided;
  })();

  try {
    return await resolvePromise;
  } finally {
    resolvePromise = null;
  }
}

/** 테스트/설정 변경 시 캐시 리셋 — 다음 `resolveDeviceTier()` 가 재판별. */
export async function resetDeviceTierCache(): Promise<void> {
  cachedTier = null;
  resolvePromise = null;
  try {
    await setSecureItem(TIER_CACHE_KEY, '');
  } catch {
    // no-op
  }
}
