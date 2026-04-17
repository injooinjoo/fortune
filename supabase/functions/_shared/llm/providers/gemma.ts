// Gemma Provider 구현 (Groq Cloud - OpenAI 호환 API)

import {
  ILLMProvider,
  LLMMessage,
  LLMResponse,
  GenerateOptions,
} from '../types.ts'
import { assertLlmRequestAllowed } from '../safety.ts'
import { normalizeGenerateOptions } from '../generate-options.ts'

export class GemmaProvider implements ILLMProvider {
  constructor(
    private config: { apiKey: string; model: string; featureName?: string },
  ) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse> {
    const startTime = Date.now()

    try {
      await assertLlmRequestAllowed({
        provider: 'gemma',
        model: this.config.model,
        featureName: this.config.featureName || 'shared-gemma-provider',
        mode: 'text',
      })

      const normalized = normalizeGenerateOptions(options, {
        providerDefault: 8192,
        providerName: 'gemma',
        featureName: this.config.featureName || 'shared-gemma-provider',
      })

      const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.config.apiKey}`,
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: messages,
          temperature: normalized.temperature ?? 1,
          max_tokens: normalized.maxTokens,
          response_format: normalized.jsonMode ? { type: 'json_object' } : undefined,
        }),
      })

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Gemma API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()

      return {
        content: data.choices[0].message.content,
        finishReason: data.choices[0].finish_reason === 'stop' ? 'stop' : 'length',
        usage: {
          promptTokens: data.usage?.prompt_tokens ?? 0,
          completionTokens: data.usage?.completion_tokens ?? 0,
          totalTokens: data.usage?.total_tokens ?? 0,
        },
        latency: Date.now() - startTime,
        provider: 'gemma',
        model: this.config.model,
      }
    } catch (error) {
      console.error('❌ Gemma API 호출 실패:', error)
      throw error
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model
  }

  getModelInfo() {
    return {
      provider: 'gemma',
      model: this.config.model,
      capabilities: ['text', 'json'],
    }
  }
}
