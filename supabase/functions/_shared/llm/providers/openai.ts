// OpenAI Provider 구현

import { ILLMProvider, LLMMessage, LLMResponse, GenerateOptions } from '../types.ts'

export class OpenAIProvider implements ILLMProvider {
  constructor(private config: { apiKey: string; model: string }) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse> {
    const startTime = Date.now()

    try {
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.config.apiKey}`,
        },
        body: JSON.stringify({
          model: this.config.model,
          messages: messages,
          temperature: options?.temperature ?? 1,
          max_completion_tokens: options?.maxTokens ?? 16000,
          response_format: options?.jsonMode ? { type: 'json_object' } : undefined,
        }),
      })

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`OpenAI API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()

      return {
        content: data.choices[0].message.content,
        finishReason: data.choices[0].finish_reason === 'stop' ? 'stop' : 'length',
        usage: {
          promptTokens: data.usage.prompt_tokens,
          completionTokens: data.usage.completion_tokens,
          totalTokens: data.usage.total_tokens,
        },
        latency: Date.now() - startTime,
        provider: 'openai',
        model: this.config.model,
      }
    } catch (error) {
      console.error('❌ OpenAI API 호출 실패:', error)
      throw error
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model
  }

  getModelInfo() {
    return {
      provider: 'openai',
      model: this.config.model,
      capabilities: ['text', 'json', 'reasoning'],
    }
  }
}
