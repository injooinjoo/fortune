// Google Gemini Provider 구현

import { ILLMProvider, LLMMessage, LLMResponse, GenerateOptions } from '../types.ts'

export class GeminiProvider implements ILLMProvider {
  constructor(private config: { apiKey: string; model: string }) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse> {
    const startTime = Date.now()

    try {
      // Gemini API 호출
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.config.model}:generateContent?key=${this.config.apiKey}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: this.convertMessages(messages),
            generationConfig: {
              temperature: options?.temperature ?? 1,
              maxOutputTokens: options?.maxTokens ?? 8192,
              responseMimeType: options?.jsonMode ? 'application/json' : 'text/plain',
            },
          }),
        }
      )

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Gemini API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()

      if (!data.candidates || data.candidates.length === 0) {
        throw new Error('No candidates in Gemini response')
      }

      const candidate = data.candidates[0]
      const content = candidate.content?.parts?.[0]?.text || ''

      return {
        content,
        finishReason: this.mapFinishReason(candidate.finishReason),
        usage: {
          promptTokens: data.usageMetadata?.promptTokenCount || 0,
          completionTokens: data.usageMetadata?.candidatesTokenCount || 0,
          totalTokens: data.usageMetadata?.totalTokenCount || 0,
        },
        latency: Date.now() - startTime,
        provider: 'gemini',
        model: this.config.model,
      }
    } catch (error) {
      console.error('❌ Gemini API 호출 실패:', error)
      throw error
    }
  }

  private convertMessages(messages: LLMMessage[]) {
    // Gemini 형식으로 변환
    // system 메시지는 첫 user 메시지에 병합
    const systemMessage = messages.find((m) => m.role === 'system')
    const userMessages = messages.filter((m) => m.role === 'user')

    if (systemMessage && userMessages.length > 0) {
      const combinedContent = `${systemMessage.content}\n\n${userMessages[0].content}`
      return [
        {
          role: 'user',
          parts: [{ text: combinedContent }],
        },
      ]
    }

    return messages
      .filter((m) => m.role !== 'system')
      .map((msg) => ({
        role: msg.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: msg.content }],
      }))
  }

  private mapFinishReason(reason?: string): 'stop' | 'length' | 'error' {
    switch (reason) {
      case 'STOP':
        return 'stop'
      case 'MAX_TOKENS':
        return 'length'
      default:
        return 'error'
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model
  }

  getModelInfo() {
    return {
      provider: 'gemini',
      model: this.config.model,
      capabilities: ['text', 'json', 'fast'],
    }
  }
}
