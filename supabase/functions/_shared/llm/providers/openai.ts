// OpenAI Provider 구현

import {
  ILLMProvider,
  LLMMessage,
  LLMResponse,
  GenerateOptions,
  ImageGenerateOptions,
  ImageResponse
} from '../types.ts'

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

  async generateImage(
    prompt: string,
    options?: ImageGenerateOptions
  ): Promise<ImageResponse> {
    const startTime = Date.now()

    try {
      const response = await fetch('https://api.openai.com/v1/images/generations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.config.apiKey}`,
        },
        body: JSON.stringify({
          model: 'dall-e-3',
          prompt: prompt,
          n: 1,
          size: options?.size ?? '1024x1792',
          quality: options?.quality ?? 'standard',
          style: options?.style ?? 'natural',
          response_format: 'b64_json',
        }),
      })

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`OpenAI Images API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()

      return {
        imageBase64: data.data[0].b64_json,
        revisedPrompt: data.data[0].revised_prompt,
        provider: 'openai',
        model: 'dall-e-3',
        latency: Date.now() - startTime,
      }
    } catch (error) {
      console.error('❌ OpenAI Images API 호출 실패:', error)
      throw error
    }
  }

  getModelInfo() {
    return {
      provider: 'openai',
      model: this.config.model,
      capabilities: ['text', 'json', 'reasoning', 'image-generation'],
    }
  }
}
