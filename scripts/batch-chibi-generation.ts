#!/usr/bin/env -S deno run --allow-net --allow-env

/**
 * 치비 캐릭터 일괄 생성 스크립트
 *
 * 사용법:
 *   deno run --allow-net --allow-env scripts/batch-chibi-generation.ts
 *
 * 환경 변수:
 *   SUPABASE_URL - Supabase 프로젝트 URL
 *   SUPABASE_ANON_KEY - Supabase Anon Key
 *
 * 제한:
 *   - DALL-E 3 Rate Limit: 분당 5개 (12초 간격)
 *   - 동시 실행: 1개 (순차 처리)
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// ===== 설정 =====
const BATCH_SIZE = 50 // 한 번에 가져올 유명인 수
const DELAY_BETWEEN_REQUESTS = 15000 // 15초 간격 (안전 마진)
const MAX_RETRIES = 2

// Supabase 설정
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error(
    'SUPABASE_URL and SUPABASE_ANON_KEY environment variables are required.',
  )
}

const supabaseUrl = SUPABASE_URL
const supabaseAnonKey = SUPABASE_ANON_KEY
const EDGE_FUNCTION_URL = `${supabaseUrl}/functions/v1/generate-celebrity-character`

// ===== Types =====
interface Celebrity {
  id: string
  name: string
  gender: string
  celebrity_type: string
  profession_data: Record<string, unknown> | null
}

interface GenerationResult {
  celebrityId: string
  celebrityName: string
  success: boolean
  url?: string
  error?: string
  duration: number
}

// ===== Helper Functions =====

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

async function generateCharacter(
  celebrity: Celebrity,
  retryCount = 0
): Promise<GenerationResult> {
  const startTime = Date.now()

  try {
    const response = await fetch(EDGE_FUNCTION_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${supabaseAnonKey}`,
      },
      body: JSON.stringify({
        celebrityId: celebrity.id,
        celebrityName: celebrity.name,
        gender: celebrity.gender,
        celebrityType: celebrity.celebrity_type,
        professionData: celebrity.profession_data,
      }),
    })

    const data = await response.json()
    const duration = Date.now() - startTime

    if (data.success) {
      return {
        celebrityId: celebrity.id,
        celebrityName: celebrity.name,
        success: true,
        url: data.characterImageUrl,
        duration,
      }
    } else {
      // 재시도 로직
      if (retryCount < MAX_RETRIES) {
        console.log(`  ⚠️ 재시도 ${retryCount + 1}/${MAX_RETRIES}: ${celebrity.name}`)
        await sleep(5000) // 5초 대기 후 재시도
        return generateCharacter(celebrity, retryCount + 1)
      }

      return {
        celebrityId: celebrity.id,
        celebrityName: celebrity.name,
        success: false,
        error: data.error || 'Unknown error',
        duration,
      }
    }
  } catch (error) {
    const duration = Date.now() - startTime
    const errorMessage = error instanceof Error ? error.message : String(error)

    // 재시도 로직
    if (retryCount < MAX_RETRIES) {
      console.log(`  ⚠️ 재시도 ${retryCount + 1}/${MAX_RETRIES}: ${celebrity.name} (${errorMessage})`)
      await sleep(5000)
      return generateCharacter(celebrity, retryCount + 1)
    }

    return {
      celebrityId: celebrity.id,
      celebrityName: celebrity.name,
      success: false,
      error: errorMessage,
      duration,
    }
  }
}

// ===== Main =====

async function main() {
  console.log('🎨 치비 캐릭터 일괄 생성 시작')
  console.log(`📍 Supabase URL: ${supabaseUrl}`)
  console.log(`⏱️  요청 간격: ${DELAY_BETWEEN_REQUESTS / 1000}초`)
  console.log('')

  // Supabase 클라이언트 생성
  const supabase = createClient(supabaseUrl, supabaseAnonKey)

  // 이미지가 없는 유명인 수 확인
  const { count: totalCount } = await supabase
    .from('celebrities')
    .select('*', { count: 'exact', head: true })
    .is('character_image_url', null)

  console.log(`📊 생성 대상: ${totalCount}명`)
  console.log(`⏳ 예상 소요 시간: ${Math.ceil((totalCount || 0) * DELAY_BETWEEN_REQUESTS / 1000 / 60)}분`)
  console.log('')

  let processed = 0
  let successCount = 0
  let failCount = 0
  const failures: GenerationResult[] = []

  // 배치 처리
  while (true) {
    // 다음 배치 가져오기
    const { data: celebrities, error } = await supabase
      .from('celebrities')
      .select('id, name, gender, celebrity_type, profession_data')
      .is('character_image_url', null)
      .order('celebrity_type')
      .limit(BATCH_SIZE)

    if (error) {
      console.error('❌ DB 조회 오류:', error.message)
      break
    }

    if (!celebrities || celebrities.length === 0) {
      console.log('✅ 모든 유명인 처리 완료!')
      break
    }

    console.log(`📦 배치 처리: ${celebrities.length}명`)

    for (const celebrity of celebrities) {
      processed++
      const progress = `[${processed}/${totalCount}]`

      console.log(`${progress} 🎭 ${celebrity.name} (${celebrity.celebrity_type})`)

      const result = await generateCharacter(celebrity)

      if (result.success) {
        successCount++
        console.log(`  ✅ 성공 (${(result.duration / 1000).toFixed(1)}s)`)
      } else {
        failCount++
        failures.push(result)
        console.log(`  ❌ 실패: ${result.error}`)
      }

      // Rate limiting
      if (celebrities.indexOf(celebrity) < celebrities.length - 1) {
        await sleep(DELAY_BETWEEN_REQUESTS)
      }
    }

    console.log('')
    console.log(`📈 진행 상황: 성공 ${successCount}, 실패 ${failCount}`)
    console.log('')
  }

  // 결과 요약
  console.log('═══════════════════════════════════════')
  console.log('📊 최종 결과')
  console.log(`   총 처리: ${processed}`)
  console.log(`   성공: ${successCount} (${((successCount / processed) * 100).toFixed(1)}%)`)
  console.log(`   실패: ${failCount}`)
  console.log('')

  if (failures.length > 0) {
    console.log('❌ 실패 목록:')
    for (const f of failures) {
      console.log(`   - ${f.celebrityName} (${f.celebrityId}): ${f.error}`)
    }
  }

  // 비용 추정
  const estimatedCost = successCount * 0.04 // DALL-E 3 1024x1024 standard: $0.04
  console.log('')
  console.log(`💰 예상 비용: $${estimatedCost.toFixed(2)}`)
}

main().catch(console.error)
