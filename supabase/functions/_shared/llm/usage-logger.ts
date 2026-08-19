// LLM 사용량 로깅 서비스
// 호출 결과를 DB에 저장하여 비용/성능 분석 지원

import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import { LLMResponse } from "./types.ts";
import { GcpLoggingService } from "../monitoring/gcp-logging.ts";
import { getGeminiModelPricing, type ModelPricing } from "./models.ts";

// 프로바이더별 토큰당 비용 (USD, 2025년 기준)
const COST_PER_1M_TOKENS: Record<string, { input: number; output: number }> = {
  // Gemini
  "gemini-2.0-flash-lite": { input: 0.075, output: 0.30 },
  "gemini-2.0-flash": { input: 0.10, output: 0.40 },
  "gemini-2.5-flash-lite": { input: 0.10, output: 0.40 },
  "gemini-2.5-flash": { input: 0.30, output: 2.50 },
  "gemini-2.5-flash-image": { input: 0.30, output: 30.00 },
  "gemini-3.1-flash-lite": { input: 0.25, output: 1.50 },

  // OpenAI
  "gpt-4o-mini": { input: 0.15, output: 0.60 },
  "gpt-4o": { input: 2.50, output: 10.00 },
  "gpt-4-turbo": { input: 10.00, output: 30.00 },

  // Anthropic
  "claude-3-5-haiku-latest": { input: 0.80, output: 4.00 },
  "claude-3-5-sonnet-latest": { input: 3.00, output: 15.00 },
  "claude-sonnet-4-20250514": { input: 3.00, output: 15.00 },

  // Grok
  "grok-2-latest": { input: 2.00, output: 10.00 },
  "grok-2": { input: 2.00, output: 10.00 },
  "grok-3-mini-fast": { input: 0.30, output: 0.50 },

  // Gemma (via Groq)
  "gemma-4-27b": { input: 0.20, output: 0.40 },
  "gemma-4-12b": { input: 0.10, output: 0.20 },
  "gemma-3-27b-it": { input: 0.20, output: 0.40 },

  // OpenRouter — 모델 ID 가 "<vendor>/<model>" 슬러그라 위 벤더 키와 겹치지 않는다.
  // 여기 없으면 calculateCost 가 gemini-flash-lite 단가로 **과소 추정**하고,
  // 그 추정치가 그대로 safety.ts 의 OpenRouter 일일 지출 상한 판정에 쓰인다.
  // 새 슬러그를 config/모델 상수에 추가하면 이 표에도 같이 추가할 것.
  // 단가 출처: https://openrouter.ai/api/v1/models 실조회 (2026-08-19).
  "google/gemini-2.5-flash-lite": { input: 0.10, output: 0.40 },
  "google/gemini-2.5-flash": { input: 0.30, output: 2.50 },
  "google/gemini-2.5-pro": { input: 1.25, output: 10.00 },
  "google/gemini-2.5-flash-image": { input: 0.30, output: 2.50 },
  "google/gemini-3.1-flash-lite-image": { input: 0.25, output: 1.50 },
  "openai/gpt-4o-mini": { input: 0.15, output: 0.60 },
  "openai/gpt-4.1-mini": { input: 0.40, output: 1.60 },
  "anthropic/claude-3.5-haiku": { input: 0.80, output: 4.00 },
  "deepseek/deepseek-chat": { input: 0.26, output: 1.03 },
  "meta-llama/llama-3.3-70b-instruct": { input: 0.10, output: 0.32 },
};

// 단가표에 없는 모델은 모델당 한 번만 경고한다.
// (요청마다 찍으면 로그가 묻히고, 안 찍으면 잘못된 추정치가 조용히 쌓인다)
const unpricedModelsWarned = new Set<string>();

export interface UsageLogData {
  fortuneType: string;
  userId?: string;
  requestId?: string;
  provider: string;
  model: string;
  isAbTest?: boolean;
  response: LLMResponse;
  metadata?: Record<string, unknown>;
}

// Supabase 클라이언트 싱글톤
let supabaseClient: SupabaseClient | null = null;

function getSupabaseClient(): SupabaseClient {
  if (!supabaseClient) {
    supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
  }
  return supabaseClient;
}

/**
 * 모델 단가 조회.
 *
 * 정확한 키를 먼저 찾고, 없으면 마지막 "/" 뒤 모델명으로 한 번 더 찾는다.
 * OpenRouter 가 같은 모델을 새 슬러그로 내놔도("<vendor>/<model>") 표에 없는 채로
 * 기본 추정치로 떨어지지 않고 대략 맞는 단가가 잡힌다.
 */
function lookupModelPricing(model: string): ModelPricing | undefined {
  const exact = COST_PER_1M_TOKENS[model] || getGeminiModelPricing(model);
  if (exact) return exact;

  const separatorIndex = model.lastIndexOf("/");
  if (separatorIndex < 0) return undefined;

  const bareModel = model.slice(separatorIndex + 1);
  if (!bareModel) return undefined;

  return COST_PER_1M_TOKENS[bareModel] || getGeminiModelPricing(bareModel);
}

/**
 * 비용 계산 (USD)
 */
function calculateCost(
  model: string,
  promptTokens: number,
  completionTokens: number,
): number {
  const pricing = lookupModelPricing(model);
  if (!pricing) {
    // 알 수 없는 모델은 기본값 사용 (gemini-2.0-flash-lite 기준)
    if (!unpricedModelsWarned.has(model)) {
      unpricedModelsWarned.add(model);
      console.warn(
        `⚠️ 단가 미등록 모델: ${model} — 기본 추정치로 계산합니다. COST_PER_1M_TOKENS 에 추가하세요.`,
      );
    }
    return (promptTokens * 0.075 + completionTokens * 0.30) / 1_000_000;
  }

  const inputCost = (promptTokens * pricing.input) / 1_000_000;
  const outputCost = (completionTokens * pricing.output) / 1_000_000;

  return inputCost + outputCost;
}

export class UsageLogger {
  /**
   * LLM 호출 결과 로깅
   */
  static async log(data: UsageLogData): Promise<void> {
    try {
      const supabase = getSupabaseClient();

      const estimatedCost = calculateCost(
        data.model,
        data.response.usage.promptTokens,
        data.response.usage.completionTokens,
      );

      await GcpLoggingService.log({
        eventType: "llm_usage",
        functionName: data.fortuneType,
        requestId: data.requestId,
        userId: data.userId,
        provider: data.provider,
        model: data.model,
        promptTokens: data.response.usage.promptTokens,
        completionTokens: data.response.usage.completionTokens,
        totalTokens: data.response.usage.totalTokens,
        estimatedCostUsd: estimatedCost,
        latencyMs: data.response.latency,
        success: data.response.finishReason !== "error",
        metadata: data.metadata,
      });

      const logEntry = {
        fortune_type: data.fortuneType,
        user_id: data.userId || null,
        request_id: data.requestId || null,
        provider: data.provider,
        model: data.model,
        is_ab_test: data.isAbTest || false,
        prompt_tokens: data.response.usage.promptTokens,
        completion_tokens: data.response.usage.completionTokens,
        total_tokens: data.response.usage.totalTokens,
        latency_ms: data.response.latency,
        estimated_cost: estimatedCost,
        finish_reason: data.response.finishReason,
        success: data.response.finishReason !== "error",
        error_message: null,
        metadata: data.metadata || {},
      };

      const { error } = await supabase.from("llm_usage_logs").insert(logEntry);

      if (error) {
        console.error("❌ LLM 사용량 로깅 실패:", error);
      } else {
        console.log(
          `📊 LLM 로그 저장: ${data.provider}/${data.model} - ${data.response.usage.totalTokens} tokens, $${
            estimatedCost.toFixed(6)
          }`,
        );
      }
    } catch (error) {
      // 로깅 실패는 메인 로직에 영향 주지 않음
      console.error("❌ LLM 로깅 예외:", error);
    }
  }

  /**
   * 에러 로깅
   */
  static async logError(
    fortuneType: string,
    provider: string,
    model: string,
    errorMessage: string,
    userId?: string,
    metadata?: Record<string, unknown>,
  ): Promise<void> {
    try {
      const supabase = getSupabaseClient();

      const logEntry = {
        fortune_type: fortuneType,
        user_id: userId || null,
        provider: provider,
        model: model,
        is_ab_test: false,
        prompt_tokens: 0,
        completion_tokens: 0,
        total_tokens: 0,
        latency_ms: 0,
        estimated_cost: 0,
        finish_reason: "error",
        success: false,
        error_message: errorMessage,
        metadata: metadata || {},
      };

      await GcpLoggingService.log({
        eventType: "llm_usage_error",
        functionName: fortuneType,
        userId: userId,
        provider: provider,
        model: model,
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
        estimatedCostUsd: 0,
        latencyMs: 0,
        success: false,
        errorMessage: errorMessage,
        metadata: metadata,
      });

      await supabase.from("llm_usage_logs").insert(logEntry);
    } catch (error) {
      console.error("❌ 에러 로깅 실패:", error);
    }
  }
}
