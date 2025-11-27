// 프롬프트 관리자

import { PromptTemplate, PromptContext, GenerationConfig, RenderedPrompt } from './types.ts'
import { TemplateEngine } from './template-engine.ts'
import { getPresetForFortune } from './presets.ts'

// 등록된 프롬프트 템플릿 저장소
const templates: Map<string, PromptTemplate> = new Map()

// 초기화 상태
let initialized = false

export class PromptManager {
  /**
   * 프롬프트 매니저 초기화
   * 모든 템플릿을 로드합니다
   */
  static async initialize(): Promise<void> {
    if (initialized) return

    // 템플릿 파일들을 동적으로 import
    // 주의: Deno에서는 동적 import가 제한적이므로
    // 템플릿을 명시적으로 등록하는 방식 사용
    initialized = true
    console.log(`✅ PromptManager 초기화 완료 (${templates.size}개 템플릿)`)
  }

  /**
   * 프롬프트 템플릿 등록
   */
  static registerTemplate(template: PromptTemplate): void {
    templates.set(template.fortuneType, template)
  }

  /**
   * 여러 템플릿 일괄 등록
   */
  static registerTemplates(templateList: PromptTemplate[]): void {
    for (const template of templateList) {
      this.registerTemplate(template)
    }
  }

  /**
   * 템플릿 가져오기
   */
  static getTemplate(fortuneType: string): PromptTemplate | undefined {
    return templates.get(fortuneType)
  }

  /**
   * 시스템 프롬프트 가져오기 (변수 치환 적용)
   */
  static getSystemPrompt(fortuneType: string, context?: PromptContext): string {
    const template = templates.get(fortuneType)
    if (!template) {
      throw new Error(`프롬프트 템플릿을 찾을 수 없습니다: ${fortuneType}`)
    }

    return context
      ? TemplateEngine.render(template.systemPrompt, context)
      : template.systemPrompt
  }

  /**
   * 사용자 프롬프트 가져오기 (변수 치환 적용)
   */
  static getUserPrompt(fortuneType: string, context: PromptContext): string {
    const template = templates.get(fortuneType)
    if (!template) {
      throw new Error(`프롬프트 템플릿을 찾을 수 없습니다: ${fortuneType}`)
    }

    return TemplateEngine.render(template.userPromptTemplate, context)
  }

  /**
   * Generation 설정 가져오기
   * 템플릿에 정의된 설정 > 프리셋 > 기본값 순으로 적용
   */
  static getGenerationConfig(fortuneType: string): GenerationConfig {
    const template = templates.get(fortuneType)

    if (template?.generationConfig) {
      return template.generationConfig
    }

    return getPresetForFortune(fortuneType)
  }

  /**
   * 프롬프트 전체 렌더링 (시스템 + 사용자 + 설정)
   */
  static render(fortuneType: string, context: PromptContext): RenderedPrompt {
    const template = templates.get(fortuneType)
    if (!template) {
      throw new Error(`프롬프트 템플릿을 찾을 수 없습니다: ${fortuneType}`)
    }

    return {
      systemPrompt: TemplateEngine.render(template.systemPrompt, context),
      userPrompt: TemplateEngine.render(template.userPromptTemplate, context),
      generationConfig: template.generationConfig || getPresetForFortune(fortuneType),
    }
  }

  /**
   * 등록된 모든 템플릿 타입 목록
   */
  static getRegisteredTypes(): string[] {
    return Array.from(templates.keys())
  }

  /**
   * 템플릿 존재 여부 확인
   */
  static hasTemplate(fortuneType: string): boolean {
    return templates.has(fortuneType)
  }

  /**
   * 초기화 상태 확인
   */
  static isInitialized(): boolean {
    return initialized
  }

  /**
   * 초기화 리셋 (테스트용)
   */
  static reset(): void {
    templates.clear()
    initialized = false
  }
}
