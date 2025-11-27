/**
 * 퍼센타일 계산 유틸리티
 * 오늘 해당 운세를 본 사람들 중 상위 몇 %인지 계산
 */

import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface PercentileResult {
  percentile: number | null       // 상위 퍼센타일 (예: 15 = 상위 15%)
  totalTodayViewers: number       // 오늘 해당 운세를 본 총 인원수
  isPercentileValid: boolean      // 최소 샘플 수 충족 여부 (10명 이상)
}

/**
 * PostgreSQL 함수를 호출하여 퍼센타일 계산
 * @param supabaseClient Supabase 클라이언트
 * @param fortuneType 운세 타입 (예: 'daily', 'talent', 'mbti' 등)
 * @param score 운세 점수 (0-100)
 * @returns 퍼센타일 결과
 */
export async function calculatePercentile(
  supabaseClient: SupabaseClient,
  fortuneType: string,
  score: number | null | undefined
): Promise<PercentileResult> {
  // 점수가 없으면 퍼센타일 계산 불가
  if (score === null || score === undefined) {
    return {
      percentile: null,
      totalTodayViewers: 0,
      isPercentileValid: false
    }
  }

  try {
    const { data, error } = await supabaseClient.rpc('get_fortune_percentile', {
      target_fortune_type: fortuneType,
      target_score: score
    })

    if (error) {
      console.error('❌ Percentile calculation error:', error)
      return {
        percentile: null,
        totalTodayViewers: 0,
        isPercentileValid: false
      }
    }

    // PostgreSQL 함수는 단일 row 반환
    const result = data?.[0] || data

    if (!result) {
      return {
        percentile: null,
        totalTodayViewers: 0,
        isPercentileValid: false
      }
    }

    return {
      percentile: result.is_valid ? result.percentile : null,
      totalTodayViewers: result.total_today || 0,
      isPercentileValid: result.is_valid || false
    }
  } catch (error) {
    console.error('❌ Percentile calculation exception:', error)
    return {
      percentile: null,
      totalTodayViewers: 0,
      isPercentileValid: false
    }
  }
}

/**
 * 퍼센타일 결과를 응답에 추가
 * @param result 기존 운세 결과 객체
 * @param percentileData 퍼센타일 계산 결과
 * @returns 퍼센타일이 추가된 결과 객체
 */
export function addPercentileToResult<T extends Record<string, unknown>>(
  result: T,
  percentileData: PercentileResult
): T & PercentileResult {
  return {
    ...result,
    percentile: percentileData.percentile,
    totalTodayViewers: percentileData.totalTodayViewers,
    isPercentileValid: percentileData.isPercentileValid
  }
}
