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

// 핵심 인터페이스: 모든 Provider가 구현해야 함
export interface ILLMProvider {
  generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse>

  validateConfig(): boolean

  getModelInfo(): {
    provider: string
    model: string
    capabilities: string[]
  }
}

export interface LLMConfig {
  provider: 'openai' | 'gemini' | 'anthropic'
  model: string
  apiKey: string
  temperature?: number
  maxTokens?: number
  timeout?: number
}
