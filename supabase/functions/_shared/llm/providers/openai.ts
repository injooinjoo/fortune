// OpenAI Provider 구현

import {
  GenerateOptions,
  ILLMProvider,
  ImageGenerateOptions,
  ImageResponse,
  LLMMessage,
  LLMResponse,
} from "../types.ts";
import { assertLlmRequestAllowed } from "../safety.ts";
import { normalizeGenerateOptions } from "../generate-options.ts";

export class OpenAIProvider implements ILLMProvider {
  constructor(
    private config: { apiKey: string; model: string; featureName?: string },
  ) {}

  private _normalizeImageModel(model?: string): string {
    return (model ?? this.config.model).trim() || "dall-e-3";
  }

  private _resolveImageSize(
    model: string,
    size?: ImageGenerateOptions["size"],
  ) {
    if (model.startsWith("gpt-image-1")) {
      if (
        size === "1024x1024" ||
        size === "1024x1536" ||
        size === "1536x1024"
      ) {
        return size;
      }
      return "1024x1536";
    }

    if (
      size === "1024x1024" ||
      size === "1024x1792" ||
      size === "1792x1024"
    ) {
      return size;
    }
    return "1024x1792";
  }

  private _resolveImageQuality(
    model: string,
    quality?: ImageGenerateOptions["quality"],
  ) {
    if (model.startsWith("gpt-image-1")) {
      if (quality === "low" || quality === "medium" || quality === "high") {
        return quality;
      }
      if (quality === "hd") {
        return "high";
      }
      return "medium";
    }

    if (quality === "hd" || quality === "standard") {
      return quality;
    }
    return "standard";
  }

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions,
  ): Promise<LLMResponse> {
    const startTime = Date.now();

    try {
      await assertLlmRequestAllowed({
        provider: "openai",
        model: this.config.model,
        featureName: this.config.featureName || "shared-openai-provider",
        mode: "text",
      });

      const normalized = normalizeGenerateOptions(options, {
        providerDefault: 16_000,
        providerName: "openai",
        featureName: this.config.featureName || "shared-openai-provider",
      });

      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${this.config.apiKey}`,
          },
          body: JSON.stringify({
            model: this.config.model,
            messages: messages,
            temperature: normalized.temperature ?? 1,
            max_completion_tokens: normalized.maxTokens,
            response_format: normalized.jsonMode
              ? { type: "json_object" }
              : undefined,
          }),
        },
      );

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`OpenAI API error: ${response.status} - ${errorText}`);
      }

      const data = await response.json();

      return {
        content: data.choices[0].message.content,
        finishReason: data.choices[0].finish_reason === "stop"
          ? "stop"
          : "length",
        usage: {
          promptTokens: data.usage.prompt_tokens,
          completionTokens: data.usage.completion_tokens,
          totalTokens: data.usage.total_tokens,
        },
        latency: Date.now() - startTime,
        provider: "openai",
        model: this.config.model,
      };
    } catch (error) {
      console.error("❌ OpenAI API 호출 실패:", error);
      throw error;
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model;
  }

  async generateImage(
    prompt: string,
    options?: ImageGenerateOptions,
  ): Promise<ImageResponse> {
    const startTime = Date.now();
    const imageModel = this._normalizeImageModel(options?.model);
    const requestBody: Record<string, unknown> = {
      model: imageModel,
      prompt: prompt,
      n: 1,
      size: this._resolveImageSize(imageModel, options?.size),
      quality: this._resolveImageQuality(imageModel, options?.quality),
      response_format: "b64_json",
    };

    if (!imageModel.startsWith("gpt-image-1")) {
      requestBody.style = options?.style ?? "natural";
    }

    try {
      await assertLlmRequestAllowed({
        provider: "openai",
        model: imageModel,
        featureName: this.config.featureName || "shared-openai-provider",
        mode: "image",
      });

      const response = await fetch(
        "https://api.openai.com/v1/images/generations",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${this.config.apiKey}`,
          },
          body: JSON.stringify(requestBody),
        },
      );

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `OpenAI Images API error: ${response.status} - ${errorText}`,
        );
      }

      const data = await response.json();

      return {
        imageBase64: data.data[0].b64_json,
        revisedPrompt: data.data[0].revised_prompt,
        provider: "openai",
        model: imageModel,
        latency: Date.now() - startTime,
      };
    } catch (error) {
      console.error("❌ OpenAI Images API 호출 실패:", error);
      throw error;
    }
  }

  getModelInfo() {
    return {
      provider: "openai",
      model: this.config.model,
      capabilities: ["text", "json", "reasoning", "image-generation"],
    };
  }
}
