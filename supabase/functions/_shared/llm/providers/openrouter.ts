// OpenRouter Provider 구현 (OpenAI 호환 chat-completions API)
//
// 키 하나로 여러 벤더 모델을 라우팅한다.
// - 제품 자체 호출: LLMFactory 가 OPENROUTER_API_KEY 로 생성
// - BYOK(사용자 키) 호출: 같은 클래스를 사용자 키로 직접 생성
// 두 경로가 같은 코드를 쓰기 위해 이 파일은 절대 Deno.env 를 읽지 않는다.
// 키는 반드시 생성자로만 주입한다.

import {
  GenerateOptions,
  ILLMProvider,
  LLMMessage,
  LLMResponse,
} from "../types.ts";
import {
  assertLlmRequestAllowed,
  type LlmBillingOwner,
} from "../safety.ts";
import { normalizeGenerateOptions } from "../generate-options.ts";

const OPENROUTER_CHAT_COMPLETIONS_URL =
  "https://openrouter.ai/api/v1/chat/completions";

/**
 * 프로바이더 에러 본문에서 크리덴셜처럼 보이는 문자열을 지우고 길이를 자른다.
 *
 * BYOK 레인에서는 **사용자의 API 키**가 이 경로를 지난다. 업스트림 응답을
 * 원문 그대로 던지거나 로깅하면 키가 로그/클라이언트로 새어나갈 수 있다.
 */
function redactProviderError(raw: string): string {
  return raw
    .replace(/sk-[A-Za-z0-9_-]{8,}/g, "sk-***")
    .replace(/Bearer\s+[A-Za-z0-9._-]{8,}/gi, "Bearer ***")
    .slice(0, 300);
}

export class OpenRouterProvider implements ILLMProvider {
  constructor(
    private config: {
      apiKey: string;
      model: string;
      featureName?: string;
      /** 사용자 키(BYOK)로 생성할 때만 "user". 미지정이면 플랫폼 예산 가드 적용. */
      billingOwner?: LlmBillingOwner;
    },
  ) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions,
  ): Promise<LLMResponse> {
    const startTime = Date.now();
    const featureName = this.config.featureName || "shared-openrouter-provider";

    try {
      await assertLlmRequestAllowed({
        provider: "openrouter",
        model: this.config.model,
        featureName,
        mode: "text",
        billingOwner: this.config.billingOwner,
      });

      const normalized = normalizeGenerateOptions(options, {
        providerDefault: 8192,
        providerName: "openrouter",
        featureName,
      });

      const response = await fetch(OPENROUTER_CHAT_COMPLETIONS_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${this.config.apiKey}`,
          // OpenRouter 대시보드 귀속용 (아웃바운드 전용 헤더)
          "X-Title": "Ondo",
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: messages,
          temperature: normalized.temperature ?? 1,
          max_tokens: normalized.maxTokens,
          response_format: normalized.jsonMode
            ? { type: "json_object" }
            : undefined,
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `OpenRouter API error: ${response.status} - ${
            redactProviderError(errorText)
          }`,
        );
      }

      const data = await response.json();
      const choice = data?.choices?.[0];

      // OpenRouter 는 업스트림 장애를 200 + error 필드로 돌려주기도 한다.
      if (!choice) {
        throw new Error(
          `OpenRouter API error: no choices returned - ${
            redactProviderError(JSON.stringify(data?.error ?? {}))
          }`,
        );
      }

      return {
        content: choice.message?.content ?? "",
        finishReason: choice.finish_reason === "stop" ? "stop" : "length",
        usage: {
          promptTokens: data.usage?.prompt_tokens ?? 0,
          completionTokens: data.usage?.completion_tokens ?? 0,
          totalTokens: data.usage?.total_tokens ?? 0,
        },
        latency: Date.now() - startTime,
        provider: "openrouter",
        model: this.config.model,
      };
    } catch (error) {
      // 에러 객체 원문 대신 마스킹된 메시지만 남긴다 (BYOK 키 유출 방지).
      console.error(
        "❌ OpenRouter API 호출 실패:",
        redactProviderError(
          error instanceof Error ? error.message : String(error),
        ),
      );
      throw error;
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model;
  }

  getModelInfo() {
    return {
      provider: "openrouter",
      model: this.config.model,
      capabilities: ["text", "json"],
    };
  }
}
