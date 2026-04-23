/**
 * Content moderation via OpenAI `omni-moderation-latest`.
 * Apple Guideline 5.2.3 대응 — character-chat 등 UGC/AI 응답 흐름에 사용.
 *
 * - OPENAI_API_KEY 필요
 * - `MODERATION_ENABLED !== 'false'` 일 때만 실제 호출 (안전한 default-on)
 * - 결과는 `moderation_flags` 테이블에 audit log로 저장 (flagged 여부 관계없이)
 * - API 실패 시 fail-open (통과). 관측만 남기고 UX 블록 유발하지 않는다.
 *
 * 사용처:
 *   const mod = await moderateText({ text, userId, characterId, source: 'user_input' });
 *   if (mod.flagged) return fallbackResponse();
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENAI_MODERATION_ENDPOINT = 'https://api.openai.com/v1/moderations'

export type ModerationSource = 'user_input' | 'model_output' | 'user_image'

export interface ModerationInput {
  text: string
  userId?: string | null
  characterId?: string | null
  source: ModerationSource
}

export interface ModerationResult {
  flagged: boolean
  categories: Record<string, number>
  reason?: string
  /**
   * 실제 OpenAI 호출 여부. false = env 미설정/flag off/에러 등으로 우회.
   */
  evaluated: boolean
}

// 동일 입력 중복 호출 방지용 in-memory 캐시 (Deno isolate lifetime).
const hashCache = new Map<string, ModerationResult>()
const HASH_CACHE_MAX = 256

async function sha256(input: string): Promise<string> {
  const bytes = new TextEncoder().encode(input)
  const hash = await crypto.subtle.digest('SHA-256', bytes)
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

function enabled(): boolean {
  return Deno.env.get('MODERATION_ENABLED') !== 'false'
}

function openaiKey(): string | null {
  return Deno.env.get('OPENAI_API_KEY') ?? null
}

/**
 * 플래그 된 카테고리 중 가장 점수 높은 것의 label + score.
 */
function primaryCategory(
  categoryScores: Record<string, number>,
  categories: Record<string, boolean>,
): { label: string; score: number } | null {
  let topLabel: string | null = null
  let topScore = -1
  for (const [label, flagged] of Object.entries(categories)) {
    if (!flagged) continue
    const score = categoryScores[label] ?? 0
    if (score > topScore) {
      topScore = score
      topLabel = label
    }
  }
  return topLabel ? { label: topLabel, score: topScore } : null
}

async function writeAuditLog(
  input: ModerationInput,
  result: ModerationResult,
): Promise<void> {
  const url = Deno.env.get('SUPABASE_URL')
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return
  try {
    const supabase = createClient(url, key, {
      auth: { autoRefreshToken: false, persistSession: false },
    })
    await supabase.from('moderation_flags').insert({
      user_id: input.userId ?? null,
      character_id: input.characterId ?? null,
      source: input.source,
      categories: result.categories,
      flagged: result.flagged,
      text_sample: input.text.slice(0, 500),
    })
  } catch (error) {
    console.warn('[moderation] audit log 실패 (무시):', error)
  }
}

export async function moderateText(
  input: ModerationInput,
): Promise<ModerationResult> {
  if (!enabled()) {
    return { flagged: false, categories: {}, evaluated: false }
  }

  const apiKey = openaiKey()
  if (!apiKey) {
    console.warn('[moderation] OPENAI_API_KEY 미설정 — fail-open')
    return { flagged: false, categories: {}, evaluated: false }
  }

  const trimmed = input.text.trim()
  if (trimmed.length === 0) {
    return { flagged: false, categories: {}, evaluated: false }
  }

  const cacheKey = `${input.source}:${await sha256(trimmed)}`
  const cached = hashCache.get(cacheKey)
  if (cached) {
    return cached
  }

  let result: ModerationResult
  try {
    const response = await fetch(OPENAI_MODERATION_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'omni-moderation-latest',
        input: trimmed.slice(0, 4000),
      }),
    })

    if (!response.ok) {
      console.warn('[moderation] API non-200:', response.status)
      result = { flagged: false, categories: {}, evaluated: false }
    } else {
      const data = await response.json()
      const r0 = data.results?.[0]
      if (!r0) {
        result = { flagged: false, categories: {}, evaluated: true }
      } else {
        const categoryScores = (r0.category_scores ?? {}) as Record<string, number>
        const categories = (r0.categories ?? {}) as Record<string, boolean>
        const primary = primaryCategory(categoryScores, categories)
        result = {
          flagged: Boolean(r0.flagged),
          categories: categoryScores,
          reason: primary ? `${primary.label}(${primary.score.toFixed(2)})` : undefined,
          evaluated: true,
        }
      }
    }
  } catch (error) {
    console.warn('[moderation] API 호출 실패 (fail-open):', error)
    result = { flagged: false, categories: {}, evaluated: false }
  }

  // LRU trim
  if (hashCache.size >= HASH_CACHE_MAX) {
    const firstKey = hashCache.keys().next().value
    if (firstKey !== undefined) hashCache.delete(firstKey)
  }
  hashCache.set(cacheKey, result)

  // 평가된 경우만 audit log (non-evaluated 는 noise).
  if (result.evaluated) {
    // fire-and-forget
    void writeAuditLog(input, result)
  }

  return result
}

/**
 * 사용자 메시지가 차단됐을 때 캐릭터가 되돌려주는 기본 응답.
 * 캐릭터 페르소나 상관 없이 중립적으로.
 */
export const SAFETY_BLOCK_FALLBACK_RESPONSE =
  '그 이야기는 저희가 나누기 어려워요. 다른 주제로 이야기해볼까요? 🤍'

/**
 * 모델 응답이 차단됐을 때 대체 문구.
 */
export const MODEL_OUTPUT_BLOCK_FALLBACK_RESPONSE =
  '잠깐, 생각을 다듬는 데 시간이 더 필요해요. 다시 말씀해 주실래요?'
