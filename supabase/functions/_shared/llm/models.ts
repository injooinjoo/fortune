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
