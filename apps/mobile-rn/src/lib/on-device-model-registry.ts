/**
 * On-device LLM model registry.
 *
 * Tier 별로 다운로드/로드할 GGUF 모델 변형을 정의한다. 모든 URL 은 HuggingFace
 * unsloth 리포지토리에서 검증된 파일. 새 tier 추가 시 `MODEL_REGISTRY` 에 엔트리
 * 를 하나 더하고 소비자는 별도 수정 불필요.
 */

import { type DeviceTier } from './device-tier';

export type ModelVariantId =
  | 'gemma-4-e4b-q4km'
  | 'phi-4-mini-q4km'
  | 'gemma-4-e2b-q4km'
  | 'qwen3-0_6b-q4km';

export interface ModelMmproj {
  filename: string;
  url: string;
  approxBytes: number;
  /** 다운로드 완료 여부 sanity check (HTML 에러 페이지 구분용). */
  minBytes: number;
}

export interface ModelVariant {
  id: ModelVariantId;
  /** UI 에 표시할 짧은 라벨. */
  displayName: string;
  modelFilename: string;
  modelUrl: string;
  approxModelBytes: number;
  minModelBytes: number;
  /** Vision projector. 없으면 텍스트 전용. */
  mmproj: ModelMmproj | null;
  /** initLlama 컨텍스트 길이. RAM 절감 위해 기본 1024 통일. */
  nCtx: number;
  nGpuLayersIOS: number;
  nGpuLayersAndroid: number;
}

export const MODEL_REGISTRY: Record<DeviceTier, ModelVariant | null> = {
  flagship: {
    id: 'gemma-4-e4b-q4km',
    displayName: 'Gemma 4 E4B',
    modelFilename: 'gemma-4-E4B-it-Q4_K_M.gguf',
    modelUrl:
      'https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf',
    approxModelBytes: 5_100_000_000,
    minModelBytes: 1_000_000_000,
    mmproj: {
      filename: 'mmproj-E4B-F16.gguf',
      url: 'https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/mmproj-F16.gguf',
      approxBytes: 987_000_000,
      minBytes: 400_000_000,
    },
    nCtx: 1024,
    nGpuLayersIOS: 99,
    nGpuLayersAndroid: 32,
  },
  high: {
    id: 'phi-4-mini-q4km',
    displayName: 'Phi-4 mini',
    modelFilename: 'Phi-4-mini-instruct-Q4_K_M.gguf',
    modelUrl:
      'https://huggingface.co/unsloth/Phi-4-mini-instruct-GGUF/resolve/main/Phi-4-mini-instruct-Q4_K_M.gguf',
    approxModelBytes: 2_490_000_000,
    minModelBytes: 800_000_000,
    mmproj: null,
    nCtx: 1024,
    nGpuLayersIOS: 99,
    nGpuLayersAndroid: 32,
  },
  mid: {
    id: 'gemma-4-e2b-q4km',
    displayName: 'Gemma 4 E2B',
    modelFilename: 'gemma-4-E2B-it-Q4_K_M.gguf',
    modelUrl:
      'https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q4_K_M.gguf',
    approxModelBytes: 3_100_000_000,
    minModelBytes: 500_000_000,
    mmproj: {
      filename: 'mmproj-F16.gguf',
      url: 'https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/mmproj-F16.gguf',
      approxBytes: 987_000_000,
      minBytes: 400_000_000,
    },
    nCtx: 1024,
    nGpuLayersIOS: 99,
    nGpuLayersAndroid: 32,
  },
  ultra: {
    id: 'qwen3-0_6b-q4km',
    displayName: 'Qwen3 0.6B',
    modelFilename: 'Qwen3-0.6B-Q4_K_M.gguf',
    modelUrl:
      'https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_K_M.gguf',
    approxModelBytes: 430_000_000,
    minModelBytes: 150_000_000,
    mmproj: null,
    nCtx: 1024,
    nGpuLayersIOS: 99,
    nGpuLayersAndroid: 24,
  },
  off: null,
};

export function getVariant(tier: DeviceTier): ModelVariant | null {
  return MODEL_REGISTRY[tier];
}

/** Legacy/cross-tier 파일 정리용. MODEL_DIR 에 남은 파일 중 이 목록에 있고
 * 현재 active variant 에 속하지 않으면 삭제. */
export function getAllKnownFilenames(): string[] {
  const names = new Set<string>();
  for (const variant of Object.values(MODEL_REGISTRY)) {
    if (!variant) continue;
    names.add(variant.modelFilename);
    if (variant.mmproj) names.add(variant.mmproj.filename);
  }
  // 이전 세대 파일.
  names.add('gemma-2b-it-q4_k_m.gguf');
  return Array.from(names);
}

/** 총 다운로드 필요 용량 (mmproj 포함). UI 에 "약 N GB" 표시용. */
export function getVariantTotalBytes(variant: ModelVariant): number {
  return variant.approxModelBytes + (variant.mmproj?.approxBytes ?? 0);
}
