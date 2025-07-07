import { NextResponse } from 'next/server';
import { FortuneResponse } from '@/lib/types/fortune-system';

/**
 * Fortune API 응답을 일관된 형식으로 반환하는 유틸리티 함수
 * data 필드 안에 운세 데이터를 감싸서 반환
 */
export function handleFortuneResponse<T>(result: FortuneResponse<T>) {
  if (!result.success) {
    // 에러 응답 - data 필드 없음
    return NextResponse.json({
      success: false,
      error: result.error || '운세 생성 중 오류가 발생했습니다',
      cached: false,
      generated_at: new Date().toISOString()
    }, { status: 500 });
  }

  // 성공 응답 - data 필드에 운세 데이터 포함
  return NextResponse.json({
    success: true,
    data: result.data,
    cached: result.cached || false,
    cache_source: result.cache_source,
    generated_at: result.generated_at || new Date().toISOString()
  });
}

/**
 * Fortune API 응답을 루트 레벨에 spread하여 반환하는 유틸리티 함수
 * 기존 API와의 호환성을 위해 사용
 */
export function handleFortuneResponseWithSpread<T>(result: FortuneResponse<T>) {
  if (!result.success) {
    // 에러 응답
    return NextResponse.json({
      success: false,
      error: result.error || '운세 생성 중 오류가 발생했습니다'
    }, { status: 500 });
  }

  // 성공 응답 - 데이터를 루트에 spread
  return NextResponse.json({
    success: true,
    ...result.data,
    cached: result.cached || false,
    cache_source: result.cache_source,
    generated_at: result.generated_at || new Date().toISOString()
  });
}