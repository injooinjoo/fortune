export interface ModelPricing {
  input: number;
  output: number;
}

interface GeminiModelCatalogEntry {
  kind: "text" | "image";
  stability: "ga" | "preview";
  pricing?: ModelPricing;
}

const GEMINI_MODEL_CATALOG: Record<string, GeminiModelCatalogEntry> = {
  "gemini-2.0-flash-lite": {
    kind: "text",
    stability: "ga",
    pricing: { input: 0.075, output: 0.30 },
  },
  "gemini-2.0-flash": {
    kind: "text",
    stability: "ga",
    pricing: { input: 0.10, output: 0.40 },
  },
  "gemini-2.5-flash-lite": {
    kind: "text",
    stability: "ga",
    pricing: { input: 0.10, output: 0.40 },
  },
  "gemini-2.5-flash": {
    kind: "text",
    stability: "ga",
    pricing: { input: 0.30, output: 2.50 },
  },
  "gemini-2.5-flash-image": {
    kind: "image",
    stability: "ga",
    pricing: { input: 0.30, output: 30.00 },
  },
  "gemini-3.1-flash-lite": {
    kind: "text",
    stability: "preview",
    pricing: { input: 0.25, output: 1.50 },
  },
};

const DEFAULT_SAFE_TEXT_MODEL = "gemini-2.0-flash-lite";
const DEFAULT_CHAT_MODEL = "gemini-2.5-flash-lite";
const DEFAULT_IMAGE_MODEL = "gemini-2.5-flash-image";
const DEFAULT_PREVIEW_TEXT_MODEL = "gemini-3.1-flash-lite";

function normalizeModelName(model: string): string {
  return model.trim().toLowerCase();
}

function resolveConfiguredModel(
  envName: string,
  fallback: string,
): string {
  const configured = Deno.env.get(envName);
  if (!configured) return fallback;

  const normalized = normalizeModelName(configured);
  return GEMINI_MODEL_CATALOG[normalized] ? normalized : fallback;
}

export const GEMINI_SAFE_TEXT_MODEL = resolveConfiguredModel(
  "GEMINI_SAFE_TEXT_MODEL",
  DEFAULT_SAFE_TEXT_MODEL,
);

export const GEMINI_CHAT_MODEL = resolveConfiguredModel(
  "GEMINI_CHAT_MODEL",
  DEFAULT_CHAT_MODEL,
);

export const GEMINI_IMAGE_MODEL = resolveConfiguredModel(
  "GEMINI_IMAGE_MODEL",
  DEFAULT_IMAGE_MODEL,
);

export const GEMINI_PREVIEW_TEXT_MODEL = resolveConfiguredModel(
  "GEMINI_PREVIEW_TEXT_MODEL",
  DEFAULT_PREVIEW_TEXT_MODEL,
);

const DEFAULT_GROK_IMAGE_MODEL = "grok-2-image-1212";
export const GROK_IMAGE_MODEL =
  Deno.env.get("GROK_IMAGE_MODEL")?.trim() || DEFAULT_GROK_IMAGE_MODEL;

// ── OpenRouter 저비용 텍스트 모델 ──────────────────────────────────────────
// 짧은 한국어 운세 텍스트(수백~2천 토큰)에 쓸 후보만 추린 목록.
// 괄호 안은 1M 토큰당 USD (입력 / 출력) — OpenRouter 표시가 기준.
// 모델 ID 는 OpenRouter 슬러그("<vendor>/<model>") 형식이며 벤더 원본 ID 와 다르다.

/**
 * OpenRouter 모델 — 2026-08-19 https://openrouter.ai/api/v1/models 실조회로 검증한 slug.
 * 존재하지 않는 slug 를 쓰면 404 "No endpoints found" 가 난다 (google/gemini-2.0-flash-001 이 그랬다).
 * 단가는 $/1M 토큰 (입력/출력).
 */

/** ($0.10 / $0.40) 기본. 기존 gemini-2.5-flash-lite 와 같은 모델이라 원가 구조가 그대로다.
 *  입력이 text+image+file+audio+video 라 이미지 해석까지 이 하나로 커버된다. */
export const OPENROUTER_TEXT_MODEL = "google/gemini-2.5-flash-lite";

/** ($0.30 / $2.50) 이미지 해석 품질을 올리고 싶을 때. 관상/손금/OOTD 처럼 사진 판독이 핵심인 운세용. */
export const OPENROUTER_VISION_MODEL = "google/gemini-2.5-flash";

/** ($0.30 / $2.50) 이미지 생성. BM 문서가 상정한 gemini-2.5-flash-image 와 동일 모델. */
export const OPENROUTER_IMAGE_MODEL = "google/gemini-2.5-flash-image";

/** ($0.25 / $1.50) 더 싼 이미지 생성. 부적/포스터처럼 장식성 이미지에. */
export const OPENROUTER_IMAGE_LITE_MODEL = "google/gemini-3.1-flash-lite-image";

/** ($0.15 / $0.60) JSON 스키마 준수가 가장 안정적. 구조화 출력이 자주 깨지면 이걸로. */
export const OPENROUTER_STRUCTURED_MODEL = "openai/gpt-4o-mini";

/** OpenRouter 기본 모델. OPENROUTER_DEFAULT_MODEL 환경변수로 교체 가능. */
export const OPENROUTER_SAFE_TEXT_MODEL =
  Deno.env.get("OPENROUTER_DEFAULT_MODEL")?.trim() ||
  OPENROUTER_TEXT_MODEL;

export function getGeminiModelPricing(model: string): ModelPricing | undefined {
  return GEMINI_MODEL_CATALOG[normalizeModelName(model)]?.pricing;
}

export function isKnownGeminiModel(model: string): boolean {
  return Boolean(GEMINI_MODEL_CATALOG[normalizeModelName(model)]);
}

export function isPreviewGeminiModel(model: string): boolean {
  return GEMINI_MODEL_CATALOG[normalizeModelName(model)]?.stability ===
    "preview";
}

export function isHighCostGeminiModel(model: string): boolean {
  const normalized = normalizeModelName(model);
  const entry = GEMINI_MODEL_CATALOG[normalized];
  if (!entry) {
    return (
      normalized.startsWith("gemini-3") ||
      normalized.includes("-pro") ||
      normalized.includes("-ultra")
    );
  }

  if (entry.stability === "preview") {
    return true;
  }

  const pricing = entry.pricing;
  if (!pricing) return false;

  return pricing.input >= 0.25 || pricing.output >= 1.50;
}

export function getBuiltInAllowedGeminiModels(): Set<string> {
  return new Set([
    GEMINI_SAFE_TEXT_MODEL,
    GEMINI_CHAT_MODEL,
    GEMINI_IMAGE_MODEL,
    "gemini-2.0-flash",
    "gemini-2.5-flash-lite",
    "gemini-2.5-flash",
  ]);
}
