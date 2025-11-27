// 프롬프트 관리 시스템 타입 정의

export interface PromptVariable {
  name: string
  type: 'string' | 'number' | 'date' | 'array' | 'object' | 'boolean'
  required: boolean
  defaultValue?: unknown
  description?: string
}

export interface GenerationConfig {
  temperature: number
  maxTokens: number
  jsonMode: boolean
  stopSequences?: string[]
  timeout?: number
}

export interface PromptTemplate {
  id: string
  fortuneType: string
  version: number
  systemPrompt: string
  userPromptTemplate: string // {{variable}} 형식 지원
  generationConfig: GenerationConfig
  variables: PromptVariable[]
  metadata?: Record<string, unknown>
}

export interface PromptContext {
  [key: string]: unknown
}

// 프롬프트 렌더링 결과
export interface RenderedPrompt {
  systemPrompt: string
  userPrompt: string
  generationConfig: GenerationConfig
}
