// Google Gemini Provider 구현

import {
  ILLMProvider,
  LLMMessage,
  LLMResponse,
  GenerateOptions,
  ImageResponse,
  GeminiImageGenerateOptions,
} from '../types.ts'

export class GeminiProvider implements ILLMProvider {
  constructor(private config: { apiKey: string; model: string }) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse> {
    const startTime = Date.now()

    try {
      // Gemini API 호출
      console.log('🔄 [Gemini] Converting messages...')
      const contents = this.convertMessages(messages)
      console.log('✅ [Gemini] Messages converted:', JSON.stringify(contents).substring(0, 200))

      const requestBody = {
        contents,
        generationConfig: {
          temperature: options?.temperature ?? 1,
          maxOutputTokens: options?.maxTokens ?? 8192,
          responseMimeType: options?.jsonMode ? 'application/json' : 'text/plain',
        },
      }

      console.log('🔄 [Gemini] Stringifying request body...')
      const bodyString = JSON.stringify(requestBody)
      console.log('✅ [Gemini] Body stringified, length:', bodyString.length)

      console.log('🔄 [Gemini] Calling Gemini API...')
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.config.model}:generateContent?key=${this.config.apiKey}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: bodyString,
        }
      )
      console.log('✅ [Gemini] API call completed, status:', response.status)

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
      const firstUserContent = userMessages[0].content

      // ✅ content가 배열인 경우 (Vision API)
      if (Array.isArray(firstUserContent)) {
        const parts = firstUserContent.map((item: any) => {
          if (item.type === 'text') {
            return { text: `${systemMessage.content}\n\n${item.text}` }
          } else if (item.type === 'image_url') {
            // Gemini Vision API 형식: inline_data 사용
            const base64Data = item.image_url.url.replace(/^data:image\/\w+;base64,/, '')
            return {
              inline_data: {
                mime_type: 'image/jpeg',
                data: base64Data
              }
            }
          }
          return item
        })

        return [{
          role: 'user',
          parts: parts
        }]
      }

      // ✅ content가 문자열인 경우 (일반 텍스트)
      console.log('🔄 [Gemini] Combining system and user messages...')
      console.log('  System content length:', systemMessage.content.length)
      console.log('  User content length:', firstUserContent.length)
      const combinedContent = `${systemMessage.content}\n\n${firstUserContent}`
      console.log('  Combined content length:', combinedContent.length)
      return [
        {
          role: 'user',
          parts: [{ text: combinedContent }],
        },
      ]
    }

    return messages
      .filter((m) => m.role !== 'system')
      .map((msg) => {
        const content = msg.content

        // ✅ content가 배열인 경우 (Vision API)
        if (Array.isArray(content)) {
          const parts = content.map((item: any) => {
            if (item.type === 'text') {
              return { text: item.text }
            } else if (item.type === 'image_url') {
              const base64Data = item.image_url.url.replace(/^data:image\/\w+;base64,/, '')
              return {
                inline_data: {
                  mime_type: 'image/jpeg',
                  data: base64Data
                }
              }
            }
            return item
          })

          return {
            role: msg.role === 'assistant' ? 'model' : 'user',
            parts: parts
          }
        }

        // ✅ content가 문자열인 경우 (일반 텍스트)
        return {
          role: msg.role === 'assistant' ? 'model' : 'user',
          parts: [{ text: content }],
        }
      })
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
      capabilities: ['text', 'json', 'fast', 'image'],
    }
  }

  /**
   * Gemini 2.0 Flash 이미지 생성
   * 부적 생성용 9:16 세로 비율 지원
   */
  async generateImage(
    prompt: string,
    options?: GeminiImageGenerateOptions
  ): Promise<ImageResponse> {
    const startTime = Date.now()

    try {
      console.log('🎨 [Gemini] Generating image...')
      console.log('📝 [Gemini] Prompt length:', prompt.length)

      // Gemini 이미지 생성 모델 사용 (2.5 Flash 통일)
      const imageModel = 'gemini-2.5-flash-preview-05-20'

      const requestBody = {
        contents: [
          {
            role: 'user',
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          responseModalities: ['TEXT', 'IMAGE'],
        },
      }

      console.log('🔄 [Gemini] Calling Image Generation API...')
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${imageModel}:generateContent?key=${this.config.apiKey}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: JSON.stringify(requestBody),
        }
      )

      console.log('✅ [Gemini] API call completed, status:', response.status)

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Gemini Image API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()

      if (!data.candidates || data.candidates.length === 0) {
        throw new Error('No candidates in Gemini Image response')
      }

      // 이미지 데이터 추출
      const parts = data.candidates[0].content?.parts || []
      const imagePart = parts.find((p: any) => p.inlineData?.mimeType?.startsWith('image/'))

      if (!imagePart || !imagePart.inlineData) {
        throw new Error('No image data in Gemini response')
      }

      const latency = Date.now() - startTime
      console.log(`✅ [Gemini] Image generated in ${latency}ms`)

      return {
        imageBase64: imagePart.inlineData.data,
        provider: 'gemini',
        model: imageModel,
        latency,
      }
    } catch (error) {
      console.error('❌ [Gemini] Image generation failed:', error)
      throw error
    }
  }
}
