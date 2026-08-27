import {
  GEMINI_SAFE_TEXT_MODEL,
  OPENROUTER_SAFE_TEXT_MODEL,
  OPENROUTER_STRUCTURED_MODEL,
  OPENROUTER_VISION_MODEL,
} from "./models.ts";

export type PlatformProviderId = "gemini" | "openai" | "anthropic" | "grok" | "gemma" | "openrouter";
export type OpenRouterRoutingMode = "legacy" | "shadow" | "openrouter";

export interface PlatformLlmRoute {
  provider: PlatformProviderId;
  model: string;
  reason: "legacy" | "shadow" | "openrouter" | "openrouter-key-missing";
  shadowModel?: string;
}

const VISION_FEATURES = ["face-reading", "palm-reading", "ootd", "vision", "photo"];
const STRUCTURED_FEATURES = ["chat-insight", "match-insight", "analysis-json"];
const ALLOWED_OPENROUTER_MODELS = new Set([
  OPENROUTER_SAFE_TEXT_MODEL,
  OPENROUTER_STRUCTURED_MODEL,
  OPENROUTER_VISION_MODEL,
]);

export function parseOpenRouterRoutingMode(value: string | undefined): OpenRouterRoutingMode {
  const normalized = value?.trim().toLowerCase();
  return normalized === "shadow" || normalized === "openrouter" ? normalized : "legacy";
}

export function openRouterAliasForFeature(featureName: string): string {
  const normalized = featureName.trim().toLowerCase();
  if (VISION_FEATURES.some((feature) => normalized.includes(feature))) {
    return OPENROUTER_VISION_MODEL;
  }
  if (STRUCTURED_FEATURES.some((feature) => normalized.includes(feature))) {
    return OPENROUTER_STRUCTURED_MODEL;
  }
  return OPENROUTER_SAFE_TEXT_MODEL;
}

function requestedOpenRouterModel(featureName: string, provider: PlatformProviderId, model: string): string {
  const normalized = model.trim();
  if (provider === "openrouter" && ALLOWED_OPENROUTER_MODELS.has(normalized)) {
    return normalized;
  }
  return openRouterAliasForFeature(featureName);
}

export function resolvePlatformLlmRoute(input: {
  featureName: string;
  requestedProvider: PlatformProviderId;
  requestedModel: string;
  mode: OpenRouterRoutingMode;
  hasOpenRouterKey: boolean;
}): PlatformLlmRoute {
  const requestedModel = input.requestedModel.trim();
  const fallbackProvider = input.requestedProvider === "openrouter" ? "gemini" : input.requestedProvider;
  const fallbackModel = input.requestedProvider === "openrouter"
    ? GEMINI_SAFE_TEXT_MODEL
    : requestedModel || GEMINI_SAFE_TEXT_MODEL;
  const candidate = requestedOpenRouterModel(
    input.featureName,
    input.requestedProvider,
    requestedModel,
  );

  if (input.mode === "legacy") {
    if (input.requestedProvider === "openrouter" && !input.hasOpenRouterKey) {
      return { provider: "gemini", model: GEMINI_SAFE_TEXT_MODEL, reason: "openrouter-key-missing" };
    }
    return {
      provider: input.requestedProvider,
      model: input.requestedProvider === "openrouter"
        ? candidate
        : (requestedModel || GEMINI_SAFE_TEXT_MODEL),
      reason: "legacy",
    };
  }

  if (input.mode === "shadow") {
    return {
      provider: fallbackProvider,
      model: fallbackModel,
      reason: "shadow",
      ...(input.hasOpenRouterKey ? { shadowModel: candidate } : {}),
    };
  }

  if (!input.hasOpenRouterKey) {
    return {
      provider: fallbackProvider,
      model: fallbackModel,
      reason: "openrouter-key-missing",
    };
  }

  return { provider: "openrouter", model: candidate, reason: "openrouter" };
}
