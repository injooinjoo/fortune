// LLM 사용량 로깅 서비스
// 호출 결과를 DB에 저장하여 비용/성능 분석 지원

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMResponse } from './types.ts'

// 프로바이더별 토큰당 비용 (USD, 2025년 기준)
const COST_PER_1M_TOKENS: Record<string, { input: number; output: number }> = {
  // Gemini
  'gemini-2.0-flash-lite': { input: 0.075, output: 0.30 },
  'gemini-2.0-flash': { input: 0.10, output: 0.40 },
  'gemini-2.5-flash': { input: 0.15, output: 0.60 },

  // OpenAI
  'gpt-4o-mini': { input: 0.15, output: 0.60 },
  'gpt-4o': { input: 2.50, output: 10.00 },
  'gpt-4-turbo': { input: 10.00, output: 30.00 },

  // Anthropic
  'claude-3-5-haiku-latest': { input: 0.80, output: 4.00 },
  'claude-3-5-sonnet-latest': { input: 3.00, output: 15.00 },
  'claude-sonnet-4-20250514': { input: 3.00, output: 15.00 },

  // Grok
  'grok-2-latest': { input: 2.00, output: 10.00 },
  'grok-2': { input: 2.00, output: 10.00 },
}

export interface UsageLogData {
  fortuneType: string
  userId?: string
  requestId?: string
  provider: string
  model: string
  isAbTest?: boolean
  response: LLMResponse
  metadata?: Record<string, unknown>
}

// Supabase 클라이언트 싱글톤
let supabaseClient: SupabaseClient | null = null

function getSupabaseClient(): SupabaseClient {
  if (!supabaseClient) {
    supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
  }
  return supabaseClient
}

/**
 * 비용 계산 (USD)
 */
function calculateCost(model: string, promptTokens: number, completionTokens: number): number {
  const pricing = COST_PER_1M_TOKENS[model]
  if (!pricing) {
    // 알 수 없는 모델은 기본값 사용 (gemini-2.0-flash-lite 기준)
    return (promptTokens * 0.075 + completionTokens * 0.30) / 1_000_000
  }

  const inputCost = (promptTokens * pricing.input) / 1_000_000
  const outputCost = (completionTokens * pricing.output) / 1_000_000

  return inputCost + outputCost
}

export class UsageLogger {
  /**
   * LLM 호출 결과 로깅
   */
  static async log(data: UsageLogData): Promise<void> {
    try {
      const supabase = getSupabaseClient()

      const estimatedCost = calculateCost(
        data.model,
        data.response.usage.promptTokens,
        data.response.usage.completionTokens
      )

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
        success: data.response.finishReason !== 'error',
        error_message: null,
        metadata: data.metadata || {},
      }

      const { error } = await supabase.from('llm_usage_logs').insert(logEntry)

      if (error) {
        console.error('❌ LLM 사용량 로깅 실패:', error)
      } else {
        console.log(
          `📊 LLM 로그 저장: ${data.provider}/${data.model} - ${data.response.usage.totalTokens} tokens, $${estimatedCost.toFixed(6)}`
        )
      }
    } catch (error) {
      // 로깅 실패는 메인 로직에 영향 주지 않음
      console.error('❌ LLM 로깅 예외:', error)
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
    metadata?: Record<string, unknown>
  ): Promise<void> {
    try {
      const supabase = getSupabaseClient()

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
        finish_reason: 'error',
        success: false,
        error_message: errorMessage,
        metadata: metadata || {},
      }

      await supabase.from('llm_usage_logs').insert(logEntry)
    } catch (error) {
      console.error('❌ 에러 로깅 실패:', error)
    }
  }
}
