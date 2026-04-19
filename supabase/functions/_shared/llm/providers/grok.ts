// xAI Grok Provider 구현 (OpenAI 호환 API)

import {
  GenerateOptions,
  ILLMProvider,
  ImageGenerateOptions,
  ImageResponse,
  LLMMessage,
  LLMResponse,
} from '../types.ts'
import { assertLlmRequestAllowed } from '../safety.ts'
import { normalizeGenerateOptions } from '../generate-options.ts'
import { GROK_IMAGE_MODEL } from '../models.ts'

export class GrokProvider implements ILLMProvider {
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
        provider: 'grok',
        model: this.config.model,
        featureName: this.config.featureName || 'shared-grok-provider',
        mode: 'text',
      })

      const normalized = normalizeGenerateOptions(options, {
        providerDefault: 8192,
        providerName: 'grok',
        featureName: this.config.featureName || 'shared-grok-provider',
      })

      const response = await fetch('https://api.x.ai/v1/chat/completions', {
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
          // Grok은 OpenAI 호환 API이므로 response_format 지원
          response_format: normalized.jsonMode ? { type: 'json_object' } : undefined,
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

  /**
   * xAI Aurora 이미지 생성 (grok-2-image-1212 등)
   * OpenAI /v1/images/generations 호환. 응답은 { data: [{ b64_json }] } 형식.
   */
  async generateImage(
    prompt: string,
    _options?: ImageGenerateOptions,
  ): Promise<ImageResponse> {
    const startTime = Date.now()

    const imageModel = GROK_IMAGE_MODEL

    await assertLlmRequestAllowed({
      provider: 'grok',
      model: imageModel,
      featureName: this.config.featureName || 'shared-grok-provider',
      mode: 'image',
    })

    console.log('🎨 [Grok] Generating image via Aurora...')
    console.log('📝 [Grok] Prompt length:', prompt.length)

    const response = await fetch('https://api.x.ai/v1/images/generations', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.config.apiKey}`,
      },
      body: JSON.stringify({
        model: imageModel,
        prompt,
        n: 1,
        response_format: 'b64_json',
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(
        `Grok Image API error: ${response.status} - ${errorText}`,
      )
    }

    const data = await response.json()
    const first = data?.data?.[0]
    const b64 = first?.b64_json as string | undefined
    if (!b64) {
      throw new Error('No image data in Grok response')
    }

    const latency = Date.now() - startTime
    console.log(`✅ [Grok] Image generated in ${latency}ms`)

    return {
      imageBase64: b64,
      revisedPrompt: first?.revised_prompt as string | undefined,
      provider: 'grok',
      model: imageModel,
      latency,
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model
  }

  getModelInfo() {
    return {
      provider: 'grok',
      model: this.config.model,
      capabilities: ['text', 'json', 'realtime-data', 'image'],
    }
  }
}
