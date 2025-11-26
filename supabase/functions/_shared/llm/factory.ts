// LLM Provider Factory

import { ILLMProvider } from './types.ts'
import { GeminiProvider } from './providers/gemini.ts'
import { OpenAIProvider } from './providers/openai.ts'
import { AnthropicProvider } from './providers/anthropic.ts'
import { GrokProvider } from './providers/grok.ts'
import { getModelConfig } from './config.ts'

export class LLMFactory {
  /**
   * 운세 타입에 맞는 LLM Provider 생성
   * @param fortuneType 운세 타입 (예: 'moving', 'tarot', 'love')
   * @returns ILLMProvider 인스턴스
   */
  static createFromConfig(fortuneType: string): ILLMProvider {
    const config = getModelConfig(fortuneType)

    console.log(`🔧 LLM 설정: ${config.provider}/${config.model}`)

    switch (config.provider) {
      case 'gemini':
        return new GeminiProvider({
          apiKey: Deno.env.get('GEMINI_API_KEY') || '',
          model: config.model,
        })

      case 'openai':
        return new OpenAIProvider({
          apiKey: Deno.env.get('OPENAI_API_KEY') || '',
          model: config.model,
        })

      case 'anthropic':
        return new AnthropicProvider({
          apiKey: Deno.env.get('ANTHROPIC_API_KEY') || '',
          model: config.model,
        })

      case 'grok':
        return new GrokProvider({
          apiKey: Deno.env.get('XAI_API_KEY') || '',
          model: config.model,
        })

      default:
        throw new Error(`Unknown provider: ${config.provider}`)
    }
  }

  /**
   * 특정 Provider와 모델로 직접 생성
   * @param provider 'gemini' | 'openai' | 'anthropic' | 'grok'
   * @param model 모델 이름
   * @returns ILLMProvider 인스턴스
   */
  static create(provider: 'gemini' | 'openai' | 'anthropic' | 'grok', model: string): ILLMProvider {
    switch (provider) {
      case 'gemini':
        return new GeminiProvider({
          apiKey: Deno.env.get('GEMINI_API_KEY') || '',
          model,
        })

      case 'openai':
        return new OpenAIProvider({
          apiKey: Deno.env.get('OPENAI_API_KEY') || '',
          model,
        })

      case 'anthropic':
        return new AnthropicProvider({
          apiKey: Deno.env.get('ANTHROPIC_API_KEY') || '',
          model,
        })

      case 'grok':
        return new GrokProvider({
          apiKey: Deno.env.get('XAI_API_KEY') || '',
          model,
        })

      default:
        throw new Error(`Unknown provider: ${provider}`)
    }
  }
}
