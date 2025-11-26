// LLM Provider 공통 타입 정의

export interface LLMMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

export interface LLMResponse {
  content: string
  finishReason: 'stop' | 'length' | 'error'
  usage: {
    promptTokens: number
    completionTokens: number
    totalTokens: number
  }
  latency: number // ms
  provider: string
  model: string
}

export interface GenerateOptions {
  temperature?: number
  maxTokens?: number
  jsonMode?: boolean
  stopSequences?: string[]
  timeout?: number
}

// 이미지 생성 옵션
export interface ImageGenerateOptions {
  size?: '1024x1024' | '1024x1792' | '1792x1024' // DALL-E 3 지원 크기
  quality?: 'standard' | 'hd'
  style?: 'vivid' | 'natural'
}

// 이미지 생성 응답
export interface ImageResponse {
  imageBase64: string
  revisedPrompt?: string // DALL-E 3가 수정한 프롬프트
  provider: string
  model: string
  latency: number // ms
}

// 핵심 인터페이스: 모든 Provider가 구현해야 함
export interface ILLMProvider {
  generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse>

  // 이미지 생성 (선택적)
  generateImage?(
    prompt: string,
    options?: ImageGenerateOptions
  ): Promise<ImageResponse>

  validateConfig(): boolean

  getModelInfo(): {
    provider: string
    model: string
    capabilities: string[]
  }
}

export interface LLMConfig {
  provider: 'openai' | 'gemini' | 'anthropic' | 'grok'
  model: string
  apiKey: string
  temperature?: number
  maxTokens?: number
  timeout?: number
}
