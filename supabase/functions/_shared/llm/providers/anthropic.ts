// Anthropic Claude Provider 구현

import {
  GenerateOptions,
  ILLMProvider,
  LLMMessage,
  LLMResponse,
} from "../types.ts";
import { assertLlmRequestAllowed } from "../safety.ts";
import { normalizeGenerateOptions } from "../generate-options.ts";

export class AnthropicProvider implements ILLMProvider {
  constructor(
    private config: { apiKey: string; model: string; featureName?: string },
  ) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions,
  ): Promise<LLMResponse> {
    const startTime = Date.now();

    // Anthropic API는 system message를 별도 파라미터로 받음
    const systemMessage = messages.find((m) => m.role === "system");
    const nonSystemMessages = messages.filter((m) => m.role !== "system");
    const systemContent = typeof systemMessage?.content === "string"
      ? systemMessage.content
      : undefined;

    try {
      await assertLlmRequestAllowed({
        provider: "anthropic",
        model: this.config.model,
        featureName: this.config.featureName || "shared-anthropic-provider",
        mode: "text",
      });

      const normalized = normalizeGenerateOptions(options, {
        providerDefault: 8192,
        providerName: "anthropic",
        featureName: this.config.featureName || "shared-anthropic-provider",
      });

      const requestBody: Record<string, unknown> = {
        model: this.config.model,
        max_tokens: normalized.maxTokens,
        messages: nonSystemMessages.map((m) => ({
          role: m.role,
          content: m.content,
        })),
        temperature: normalized.temperature ?? 1,
      };

      // system message가 있으면 별도 파라미터로 추가
      if (systemContent) {
        requestBody.system = systemContent;
      }

      // jsonMode 처리: Anthropic은 네이티브 JSON mode 미지원
      // system prompt에 JSON 지시를 추가하는 방식으로 처리
      if (options?.jsonMode && systemContent) {
        requestBody.system =
          `${systemContent}\n\n중요: 반드시 유효한 JSON 형식으로만 응답하세요. 다른 텍스트 없이 JSON만 출력하세요.`;
      }

      const response = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": this.config.apiKey,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `Anthropic API error: ${response.status} - ${errorText}`,
        );
      }

      const data = await response.json();

      return {
        content: data.content[0].text,
        finishReason: this.mapFinishReason(data.stop_reason),
        usage: {
          promptTokens: data.usage.input_tokens,
          completionTokens: data.usage.output_tokens,
          totalTokens: data.usage.input_tokens + data.usage.output_tokens,
        },
        latency: Date.now() - startTime,
        provider: "anthropic",
        model: this.config.model,
      };
    } catch (error) {
      console.error("❌ Anthropic API 호출 실패:", error);
      throw error;
    }
  }

  private mapFinishReason(reason?: string): "stop" | "length" | "error" {
    switch (reason) {
      case "end_turn":
        return "stop";
      case "max_tokens":
        return "length";
      case "stop_sequence":
        return "stop";
      default:
        return "error";
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model;
  }

  getModelInfo() {
    return {
      provider: "anthropic",
      model: this.config.model,
      capabilities: ["text", "json", "reasoning", "coding"],
    };
  }
}
