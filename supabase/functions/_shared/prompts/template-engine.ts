// 프롬프트 템플릿 엔진
// {{variable}}, {{#if condition}}...{{/if}}, {{#each items}}...{{/each}} 지원

import { PromptContext } from './types.ts'

export class TemplateEngine {
  /**
   * 템플릿 렌더링
   * - {{variable}} → 값 치환
   * - {{nested.path}} → 중첩 객체 접근
   * - {{#if condition}}...{{/if}} → 조건부 블록
   * - {{#each items}}{{this}}{{/each}} → 반복 블록
   */
  static render(template: string, context: PromptContext): string {
    let result = template

    // 1. 조건부 블록 처리 {{#if condition}}...{{/if}}
    result = this.processConditionals(result, context)

    // 2. 반복 블록 처리 {{#each items}}...{{/each}}
    result = this.processLoops(result, context)

    // 3. 단순 변수 치환 {{variable}}
    result = result.replace(/\{\{([^#/][^}]*)\}\}/g, (match, path) => {
      const trimmedPath = path.trim()
      const value = this.getNestedValue(context, trimmedPath)
      return value !== undefined && value !== null ? String(value) : ''
    })

    // 4. 빈 줄 정리 (연속된 빈 줄을 하나로)
    result = result.replace(/\n{3,}/g, '\n\n')

    return result.trim()
  }

  /**
   * 중첩 객체에서 값 가져오기
   * 예: getNestedValue({user: {name: 'John'}}, 'user.name') → 'John'
   */
  private static getNestedValue(obj: unknown, path: string): unknown {
    return path.split('.').reduce((acc, key) => {
      if (acc && typeof acc === 'object') {
        return (acc as Record<string, unknown>)[key]
      }
      return undefined
    }, obj)
  }

  /**
   * 조건부 블록 처리
   * {{#if condition}}content{{/if}}
   * {{#if condition}}content{{else}}alternative{{/if}}
   */
  private static processConditionals(template: string, context: PromptContext): string {
    // {{#if condition}}...{{else}}...{{/if}} 패턴
    const ifElsePattern = /\{\{#if\s+([^}]+)\}\}([\s\S]*?)\{\{else\}\}([\s\S]*?)\{\{\/if\}\}/g
    let result = template.replace(ifElsePattern, (_, condition, ifContent, elseContent) => {
      const value = this.getNestedValue(context, condition.trim())
      return this.isTruthy(value) ? ifContent : elseContent
    })

    // {{#if condition}}...{{/if}} 패턴 (else 없음)
    const ifPattern = /\{\{#if\s+([^}]+)\}\}([\s\S]*?)\{\{\/if\}\}/g
    result = result.replace(ifPattern, (_, condition, content) => {
      const value = this.getNestedValue(context, condition.trim())
      return this.isTruthy(value) ? content : ''
    })

    return result
  }

  /**
   * 반복 블록 처리
   * {{#each items}}{{this}}{{/each}}
   * {{#each items}}{{this.name}}{{/each}}
   */
  private static processLoops(template: string, context: PromptContext): string {
    const eachPattern = /\{\{#each\s+([^}]+)\}\}([\s\S]*?)\{\{\/each\}\}/g

    return template.replace(eachPattern, (_, arrayPath, content) => {
      const array = this.getNestedValue(context, arrayPath.trim())
      if (!Array.isArray(array)) return ''

      return array
        .map((item, index) => {
          // {{this}}를 현재 아이템으로 치환
          let itemContent = content.replace(/\{\{this\}\}/g, String(item))

          // {{this.property}}를 현재 아이템의 속성으로 치환
          itemContent = itemContent.replace(/\{\{this\.([^}]+)\}\}/g, (_, prop) => {
            if (typeof item === 'object' && item !== null) {
              const value = (item as Record<string, unknown>)[prop.trim()]
              return value !== undefined ? String(value) : ''
            }
            return ''
          })

          // {{@index}}를 인덱스로 치환
          itemContent = itemContent.replace(/\{\{@index\}\}/g, String(index))

          return itemContent
        })
        .join('')
    })
  }

  /**
   * 값이 truthy인지 확인
   */
  private static isTruthy(value: unknown): boolean {
    if (value === undefined || value === null) return false
    if (typeof value === 'boolean') return value
    if (typeof value === 'string') return value.length > 0
    if (typeof value === 'number') return value !== 0
    if (Array.isArray(value)) return value.length > 0
    return true
  }
}
