// 프롬프트 관리 시스템 통합 export

export * from './types.ts'
export * from './presets.ts'
export * from './template-engine.ts'
export { PromptManager } from './manager.ts'

// 템플릿 등록을 위한 초기화 함수
import { PromptManager } from './manager.ts'

// 모든 템플릿 import
import { investmentPrompt } from './templates/investment.ts'

// 템플릿 목록
const allTemplates = [
  investmentPrompt,
  // 새 템플릿 추가 시 여기에 추가
]

/**
 * 프롬프트 시스템 초기화
 * Edge Function 시작 시 호출
 */
export async function initializePrompts(): Promise<void> {
  // 모든 템플릿 등록
  PromptManager.registerTemplates(allTemplates)
  await PromptManager.initialize()
}
