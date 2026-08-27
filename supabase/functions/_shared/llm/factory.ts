// LLM Provider Factory

import { ILLMProvider } from "./types.ts";
import { GeminiProvider } from "./providers/gemini.ts";
import { OpenAIProvider } from "./providers/openai.ts";
import { AnthropicProvider } from "./providers/anthropic.ts";
import { GrokProvider } from "./providers/grok.ts";
import { GemmaProvider } from "./providers/gemma.ts";
import { OpenRouterProvider } from "./providers/openrouter.ts";
import { getModelConfig } from "./config.ts";
import { ConfigService } from "./config-service.ts";
import { createUserLlmProvider } from "./user_key.ts";
import { BoundedFallbackProvider } from "./fallback-provider.ts";
import { GEMINI_SAFE_TEXT_MODEL } from "./models.ts";
import {
  parseOpenRouterRoutingMode,
  resolvePlatformLlmRoute,
} from "./routing.ts";

type ProviderId =
  | "gemini"
  | "openai"
  | "anthropic"
  | "grok"
  | "gemma"
  | "openrouter";

function envEnabled(name: string): boolean {
  return ["1", "true", "yes", "on"].includes((Deno.env.get(name) ?? "").trim().toLowerCase());
}

function getPlatformOpenRouterKey(): string {
  const workspaceKey = Deno.env.get("OPENROUTER_WORKSPACE_API_KEY")?.trim() ?? "";
  if (workspaceKey) return workspaceKey;
  return envEnabled("OPENROUTER_ALLOW_LEGACY_PLATFORM_KEY")
    ? (Deno.env.get("OPENROUTER_API_KEY")?.trim() ?? "")
    : "";
}

export class LLMFactory {
  /**
   * [비동기] DB 기반 동적 설정으로 LLM Provider 생성
   * DB에서 설정을 조회하고, A/B 테스트 지원
   *
   * @param fortuneType 운세 타입
   * @param userId **JWT 에서 파생한** user id (`deriveUserIdFromJwt`). 넘기면
   *               그 사용자가 연결한 자기 키(BYOK)를 먼저 찾아 쓰고, 없으면
   *               플랫폼 키로 폴백한다. 클라이언트가 body 로 준 id 를 넘기지 말 것 —
   *               남의 키로 생성하는 경로가 된다.
   * @returns ILLMProvider 인스턴스
   */
  static async createFromConfigAsync(
    fortuneType: string,
    userId?: string | null,
  ): Promise<ILLMProvider> {
    // 사용자 키가 있으면 그게 1순위. 조회/복호화 실패는 null 로 떨어져 폴백한다.
    const userProvider = await createUserLlmProvider(userId, fortuneType);
    if (userProvider) {
      return userProvider.llm;
    }

    const config = await ConfigService.getModelConfig(fortuneType);
    return this.createRoutedProvider(config.provider, config.model, fortuneType, config.isAbTest);
  }

  /**
   * [동기] 정적 설정으로 LLM Provider 생성 (기존 호환성 유지)
   *
   * ⚠️ 이 경로는 **BYOK(사용자 키)를 쓰지 않는다** — 키 조회/복호화가 비동기라
   * 동기 시그니처로는 불가능하다. 사용자 키를 쓰게 하려면 호출부를
   * `await LLMFactory.createFromConfigAsync(fortuneType, userId)` 로 바꿀 것.
   *
   * @param fortuneType 운세 타입 (예: 'moving', 'tarot', 'love')
   * @returns ILLMProvider 인스턴스
   */
  static createFromConfig(fortuneType: string): ILLMProvider {
    const config = getModelConfig(fortuneType);
    return this.createRoutedProvider(config.provider, config.model, fortuneType, false);
  }

  /**
   * 특정 Provider와 모델로 직접 생성
   * @param provider 'gemini' | 'openai' | 'anthropic' | 'grok' | 'gemma' | 'openrouter'
   * @param model 모델 이름
   * @returns ILLMProvider 인스턴스
   */
  static create(
    provider: ProviderId,
    model: string,
    featureName = "direct",
  ): ILLMProvider {
    return this.createProvider(provider, model, featureName);
  }

  private static createRoutedProvider(
    provider: ProviderId,
    model: string,
    featureName: string,
    isAbTest = false,
  ): ILLMProvider {
    const openRouterKey = getPlatformOpenRouterKey();
    const route = resolvePlatformLlmRoute({
      featureName,
      requestedProvider: provider,
      requestedModel: model,
      mode: parseOpenRouterRoutingMode(Deno.env.get("OPENROUTER_ROUTING_MODE")),
      hasOpenRouterKey: openRouterKey.length > 0,
    });

    console.log(
      `[llm-router] ${featureName}: ${route.provider}/${route.model} reason=${route.reason}${
        route.shadowModel ? ` shadow=${route.shadowModel}` : ""
      }${isAbTest ? " ab=true" : ""}`,
    );

    const primary = this.createProvider(route.provider, route.model, featureName);
    if (route.provider !== "openrouter" || !envEnabled("OPENROUTER_RUNTIME_FALLBACK_ENABLED")) {
      return primary;
    }

    const fallbackProvider: ProviderId = provider === "openrouter" ? "gemini" : provider;
    const fallbackModel = provider === "openrouter" ? GEMINI_SAFE_TEXT_MODEL : model;
    return new BoundedFallbackProvider(
      primary,
      this.createProvider(fallbackProvider, fallbackModel, featureName),
      featureName,
    );
  }

  /**
   * Provider 인스턴스 생성 (내부용)
   */
  private static createProvider(
    provider: ProviderId,
    model: string,
    featureName: string,
  ): ILLMProvider {
    switch (provider) {
      case "gemini":
        return new GeminiProvider({
          apiKey: Deno.env.get("GEMINI_API_KEY") || "",
          model,
          featureName,
        });

      case "openai":
        return new OpenAIProvider({
          apiKey: Deno.env.get("OPENAI_API_KEY") || "",
          model,
          featureName,
        });

      case "anthropic":
        return new AnthropicProvider({
          apiKey: Deno.env.get("ANTHROPIC_API_KEY") || "",
          model,
          featureName,
        });

      case "grok":
        return new GrokProvider({
          apiKey: Deno.env.get("XAI_API_KEY") || "",
          model,
          featureName,
        });

      case "gemma":
        return new GemmaProvider({
          apiKey: Deno.env.get("GROQ_API_KEY") || "",
          model,
          featureName,
        });

      // 제품 자체 호출용. 사용자 키(BYOK)로 쓸 때는 팩토리를 거치지 않고
      // OpenRouterProvider 를 사용자 키로 직접 생성한다.
      case "openrouter":
        return new OpenRouterProvider({
          apiKey: getPlatformOpenRouterKey(),
          model,
          featureName,
        });

      default:
        throw new Error(`Unknown provider: ${provider}`);
    }
  }
}
