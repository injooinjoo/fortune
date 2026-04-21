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

const TIER_CACHE_KEY = 'ondo.device-tier.v1';
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

  // iOS 14 이하는 llama.rn/Metal 최신 기능 신뢰 불가.
  if (osMajor > 0 && osMajor < 15) return 'off';

  // 시뮬레이터 또는 modelId 추출 실패 — 보수적으로 mid (기존 기본).
  if (!major) {
    if (!Device.isDevice) return 'mid';
    return 'off';
  }

  // iPhone17 계열 이상 (A19 Pro, 12GB RAM) — 2025 후반 출시 예상.
  if (major >= 17) return 'flagship';
  // iPhone15 Pro / iPhone16 계열 (A17 Pro / A18, 8GB RAM).
  if (major >= 15) return 'high';
  // iPhone13 / iPhone14 계열 (A15 / A16, 6GB RAM).
  if (major >= 13) return 'mid';
  // iPhone11 / iPhone12 계열 (A13 / A14, 4~6GB RAM).
  if (major >= 11) return 'ultra';
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
