// Google Gemini Provider 구현

import {
  GenerateOptions,
  ILLMProvider,
  ImageGenerateOptions,
  ImageResponse,
  LLMMessage,
  LLMResponse,
} from "../types.ts";
import { assertLlmRequestAllowed } from "../safety.ts";
import { GEMINI_IMAGE_MODEL } from "../models.ts";
import { normalizeGenerateOptions } from "../generate-options.ts";

const SAFETY_BLOCK_FINISH_REASONS = new Set<string>([
  "SAFETY",
  "PROHIBITED_CONTENT",
  "IMAGE_SAFETY",
  "RECITATION",
  "BLOCKLIST",
  "SPII",
]);

function createSafetyBlockedError(message: string): Error {
  const err = new Error(message);
  err.name = "SafetyBlockedError";
  return err;
}

export class GeminiProvider implements ILLMProvider {
  constructor(
    private config: { apiKey: string; model: string; featureName?: string },
  ) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions,
  ): Promise<LLMResponse> {
    const startTime = Date.now();

    try {
      // Gemini API 호출
      console.log("🔄 [Gemini] Converting messages...");
      const contents = this.convertMessages(messages);
      console.log(
        "✅ [Gemini] Messages converted:",
        JSON.stringify(contents).substring(0, 200),
      );

      const normalized = normalizeGenerateOptions(options, {
        providerDefault: 2048,
        providerName: "gemini",
        featureName: this.config.featureName || "shared-gemini-provider",
      });

      const requestBody = {
        contents,
        generationConfig: {
          temperature: normalized.temperature ?? 0.7,
          maxOutputTokens: normalized.maxTokens,
          responseMimeType: normalized.jsonMode
            ? "application/json"
            : "text/plain",
        },
      };

      console.log("🔄 [Gemini] Stringifying request body...");
      const bodyString = JSON.stringify(requestBody);
      console.log("✅ [Gemini] Body stringified, length:", bodyString.length);

      await assertLlmRequestAllowed({
        provider: "gemini",
        model: this.config.model,
        featureName: this.config.featureName || "shared-gemini-provider",
        mode: "text",
      });

      console.log("🔄 [Gemini] Calling Gemini API...");
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.config.model}:generateContent?key=${this.config.apiKey}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
          },
          body: bodyString,
        },
      );
      console.log("✅ [Gemini] API call completed, status:", response.status);

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Gemini API error: ${response.status} - ${errorText}`);
      }

      const data = await response.json();

      if (!data.candidates || data.candidates.length === 0) {
        throw new Error("No candidates in Gemini response");
      }

      const candidate = data.candidates[0];
      const content = candidate.content?.parts?.[0]?.text || "";

      return {
        content,
        finishReason: this.mapFinishReason(candidate.finishReason),
        usage: {
          promptTokens: data.usageMetadata?.promptTokenCount || 0,
          completionTokens: data.usageMetadata?.candidatesTokenCount || 0,
          totalTokens: data.usageMetadata?.totalTokenCount || 0,
        },
        latency: Date.now() - startTime,
        provider: "gemini",
        model: this.config.model,
      };
    } catch (error) {
      console.error("❌ Gemini API 호출 실패:", error);
      throw error;
    }
  }

  private convertMessages(messages: LLMMessage[]) {
    // Gemini 형식으로 변환
    // system 메시지는 첫 user 메시지에 병합, 나머지 히스토리는 유지
    const systemMessage = messages.find((m) => m.role === "system");
    const nonSystemMessages = messages.filter((m) => m.role !== "system");

    console.log("🔄 [Gemini] Converting messages...");
    console.log("  Total messages:", messages.length);
    console.log("  System message:", systemMessage ? "yes" : "no");
    console.log("  Non-system messages:", nonSystemMessages.length);

    const result: Array<{ role: string; parts: any[] }> = [];

    for (let i = 0; i < nonSystemMessages.length; i++) {
      const msg = nonSystemMessages[i];
      const content = msg.content;
      const isFirstUserMessage = i === 0 && msg.role === "user" &&
        systemMessage;

      // ✅ content가 배열인 경우 (Vision API)
      if (Array.isArray(content)) {
        const parts = content.map((item: any) => {
          if (item.type === "text") {
            // 첫 user 메시지면 system prompt 병합
            const text = isFirstUserMessage
              ? `${systemMessage!.content}\n\n${item.text}`
              : item.text;
            return { text };
          } else if (item.type === "image_url") {
            const base64Data = item.image_url.url.replace(
              /^data:image\/\w+;base64,/,
              "",
            );
            return {
              inline_data: {
                mime_type: "image/jpeg",
                data: base64Data,
              },
            };
          }
          return item;
        });

        result.push({
          role: msg.role === "assistant" ? "model" : "user",
          parts: parts,
        });
      } else {
        // ✅ content가 문자열인 경우 (일반 텍스트)
        // 첫 user 메시지면 system prompt 병합
        const text = isFirstUserMessage
          ? `${systemMessage!.content}\n\n${content}`
          : content;

        result.push({
          role: msg.role === "assistant" ? "model" : "user",
          parts: [{ text }],
        });
      }
    }

    // 시스템 메시지만 있고 다른 메시지가 없는 경우
    if (
      result.length === 0 && systemMessage &&
      typeof systemMessage.content === "string"
    ) {
      result.push({
        role: "user",
        parts: [{ text: systemMessage.content }],
      });
    }

    console.log("✅ [Gemini] Converted to", result.length, "messages");
    return result;
  }

  private mapFinishReason(reason?: string): "stop" | "length" | "error" {
    switch (reason) {
      case "STOP":
        return "stop";
      case "MAX_TOKENS":
        return "length";
      default:
        return "error";
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model;
  }

  getModelInfo() {
    return {
      provider: "gemini",
      model: this.config.model,
      capabilities: ["text", "json", "fast", "image"],
    };
  }

  /**
   * Gemini 2.0 Flash 이미지 생성
   * 부적 생성용 9:16 세로 비율 지원
   */
  async generateImage(
    prompt: string,
    options?: ImageGenerateOptions,
  ): Promise<ImageResponse> {
    const startTime = Date.now();

    try {
      console.log("🎨 [Gemini] Generating image...");
      console.log("📝 [Gemini] Prompt length:", prompt.length);

      // Gemini 이미지 생성 모델 사용
      const imageModel = GEMINI_IMAGE_MODEL;

      const requestBody = {
        contents: [
          {
            role: "user",
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          responseModalities: ["TEXT", "IMAGE"],
        },
      };

      await assertLlmRequestAllowed({
        provider: "gemini",
        model: imageModel,
        featureName: this.config.featureName || "shared-gemini-provider",
        mode: "image",
      });

      console.log("🔄 [Gemini] Calling Image Generation API...");
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${imageModel}:generateContent?key=${this.config.apiKey}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
          },
          body: JSON.stringify(requestBody),
        },
      );

      console.log("✅ [Gemini] API call completed, status:", response.status);

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `Gemini Image API error: ${response.status} - ${errorText}`,
        );
      }

      const data = await response.json();

      // 프롬프트 단계에서 안전 필터가 전체 응답을 차단한 경우
      const promptBlockReason = data.promptFeedback?.blockReason as
        | string
        | undefined;
      if (promptBlockReason) {
        throw createSafetyBlockedError(
          `Gemini prompt blocked: ${promptBlockReason}`,
        );
      }

      if (!data.candidates || data.candidates.length === 0) {
        throw new Error("No candidates in Gemini Image response");
      }

      // candidate 단계에서 안전/저작권/이미지 안전 필터로 차단된 경우
      const finishReason = data.candidates[0]?.finishReason as
        | string
        | undefined;
      if (finishReason && SAFETY_BLOCK_FINISH_REASONS.has(finishReason)) {
        throw createSafetyBlockedError(
          `Gemini image blocked: ${finishReason}`,
        );
      }

      // 이미지 데이터 추출
      const parts = data.candidates[0].content?.parts || [];
      const imagePart = parts.find((p: any) =>
        p.inlineData?.mimeType?.startsWith("image/")
      );

      if (!imagePart || !imagePart.inlineData) {
        // 이미지가 없고 finishReason이 STOP인데도 이미지가 없으면
        // 대부분 모델이 거부(텍스트만 반환)한 경우 → safety로 취급
        throw createSafetyBlockedError(
          `Gemini returned no image (finishReason=${finishReason ?? "unknown"})`,
        );
      }

      const latency = Date.now() - startTime;
      console.log(`✅ [Gemini] Image generated in ${latency}ms`);

      return {
        imageBase64: imagePart.inlineData.data,
        provider: "gemini",
        model: imageModel,
        latency,
      };
    } catch (error) {
      console.error("❌ [Gemini] Image generation failed:", error);
      throw error;
    }
  }
}
