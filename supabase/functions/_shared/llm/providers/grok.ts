// xAI Grok Provider 구현 (OpenAI 호환 API)

import {
  ILLMProvider,
  LLMMessage,
  LLMResponse,
  GenerateOptions,
} from '../types.ts'

export class GrokProvider implements ILLMProvider {
  constructor(private config: { apiKey: string; model: string }) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse> {
    const startTime = Date.now()

    try {
      const response = await fetch('https://api.x.ai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.config.apiKey}`,
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: messages,
          temperature: options?.temperature ?? 1,
          max_tokens: options?.maxTokens ?? 8192,
          // Grok은 OpenAI 호환 API이므로 response_format 지원
          response_format: options?.jsonMode ? { type: 'json_object' } : undefined,
        }),
      })

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Grok API error: ${response.status} - ${errorText}`)
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
        provider: 'grok',
        model: this.config.model,
      }
    } catch (error) {
      console.error('❌ Grok API 호출 실패:', error)
      throw error
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model
  }

  getModelInfo() {
    return {
      provider: 'grok',
      model: this.config.model,
      capabilities: ['text', 'json', 'realtime-data'],
    }
  }
}
